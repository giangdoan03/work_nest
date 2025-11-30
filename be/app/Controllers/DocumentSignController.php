<?php

namespace App\Controllers;

use App\Models\DocumentConvertedModel;
use App\Models\DocumentSignStatusModel;
use App\Models\UserModel;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;
use ReflectionException;

class DocumentSignController extends ResourceController
{
    protected $format = 'json';

    /* ====================================================
       1. SEND DOCUMENT FOR SIGNING (CREATE STEPS)
       POST /api/document-sign/send
       ==================================================== */
    /**
     * @throws ReflectionException
     */
    public function send(): ResponseInterface
    {
        $userId = (int)(session()->get('user_id') ?? 0);
        if ($userId <= 0) {
            return $this->failUnauthorized('Chưa đăng nhập');
        }

        $payload = $this->request->getJSON(true);
        $convertedId = (int)($payload['converted_id'] ?? 0);
        $approvers   = array_values(array_unique(array_filter(array_map('intval', $payload['approver_ids'] ?? []))));

        if ($convertedId <= 0) return $this->failValidationErrors('Thiếu converted_id');
        if (empty($approvers)) return $this->failValidationErrors('Thiếu approver_ids');

        $convertedM = new DocumentConvertedModel();
        $signM = new DocumentSignStatusModel();

        // Check document exists
        $doc = $convertedM->find($convertedId);
        if (!$doc) return $this->failNotFound('Tài liệu convert không tồn tại');

        // Optional: clear old signing chain
        $signM->where('converted_id', $convertedId)->delete();

        // Create signing steps
        $batch = [];
        $index = 1;

        foreach ($approvers as $uid) {
            $batch[] = [
                'converted_id' => $convertedId,
                'user_id'      => $uid,
                'user_name'    => null,
                'order_index'  => $index++,
                'status'       => $index === 2 ? 'pending' : 'waiting',
                'signed_at'    => null
            ];
        }

        $signM->insertBatch($batch);

        return $this->respondCreated([
            'message' => 'Gửi ký thành công',
            'converted_id' => $convertedId,
            'total_steps' => count($batch)
        ]);
    }

    /* ====================================================
       2. FETCH INBOX (FILE USER NEEDS TO SIGN)
       GET /api/document-sign/inbox
       ==================================================== */
    public function inbox(): ResponseInterface
    {
        $uid = (int)(session()->get('user_id') ?? 0);
        if ($uid <= 0) return $this->failUnauthorized('Chưa đăng nhập');

        $signM = new DocumentSignStatusModel();
        $convertedM = new DocumentConvertedModel();
        $db = db_connect();

        // 1) Lấy step pending của user đang login
        $rows = $signM->where('user_id', $uid)
            ->where('status', 'pending')
            ->orderBy('order_index', 'ASC')
            ->findAll();

        $result = [];

        foreach ($rows as $s) {
            $doc = $convertedM->find($s['converted_id']);
            if (!$doc) continue;

            // 2) JOIN lấy full chain + user name
            $chain = $db->table('document_sign_status ds')
                ->select('
                ds.id,
                ds.converted_id,
                ds.user_id,
                u.name AS approver_name,
                ds.order_index,
                ds.status,
                ds.signed_at
            ')
                ->join('users u', 'u.id = ds.user_id', 'left')
                ->where('ds.converted_id', $s['converted_id'])
                ->orderBy('ds.order_index', 'ASC')
                ->get()->getResultArray();

            // 3) Mapping theo định dạng FE yêu cầu
            $steps = array_map(fn($x) => [
                'id' => $x['id'],
                'sequence' => $x['order_index'],
                'approver_id' => $x['user_id'],
                'approver_name' => $x['approver_name'] ?? '—',
                'status' => $x['status'],
                'is_current' => $x['status'] === 'pending',
                'is_approved' => $x['status'] === 'signed',
            ], $chain);

            // 4) Push vào kết quả trả về FE
            $result[] = [
                'id' => $s['id'],
                'converted_id' => $s['converted_id'],
                'title' => $doc['title'],
                'url' => $doc['file_url'],
                'uploader_name' => $doc['uploader_name'],
                'created_at' => $doc['wp_created_at'],
                'sequence' => $s['order_index'],
                'status' => $s['status'],
                'steps' => $steps
            ];
        }

        return $this->respond(['items' => $result]);
    }


    /* ====================================================
       3. SIGN DOCUMENT (STEP-BY-STEP)
       POST /api/document-sign/sign
       ==================================================== */
    public function sign(): ResponseInterface
    {
        $uid = (int)(session()->get('user_id') ?? 0);
        if ($uid <= 0) return $this->failUnauthorized('Chưa đăng nhập');

        $payload = $this->request->getJSON(true);
        $convertedId = (int)($payload['converted_id'] ?? 0);
        $signatureUrl = $payload['signature_url'] ?? null;
        $signedPdfUrl = $payload['signed_pdf_url'] ?? null;
        $comment = $payload['comment'] ?? null;

        if ($convertedId <= 0) return $this->failValidationErrors('Thiếu converted_id');

        $signM = new DocumentSignStatusModel();

        // Find current step for user
        $step = $signM->where('converted_id', $convertedId)
            ->where('user_id', $uid)
            ->where('status', 'pending')
            ->first();

        if (!$step)
            return $this->failForbidden('Không phải lượt ký của bạn.');

        // Mark signed
        $signM->update($step['id'], [
            'status' => 'signed',
            'signed_at' => date('Y-m-d H:i:s'),
            'signature_url' => $signatureUrl,
            'signed_pdf_url' => $signedPdfUrl,
            'comment' => $comment
        ]);

        // Open next step
        $next = $signM->where('converted_id', $convertedId)
            ->where('order_index >', $step['order_index'])
            ->orderBy('order_index', 'ASC')
            ->first();

        if ($next) {
            $signM->update($next['id'], ['status' => 'pending']);
        }

        return $this->respond(['message' => 'Đã ký thành công']);
    }

    /* ====================================================
       4. REJECT
       POST /api/document-sign/reject
       ==================================================== */
    /**
     * @throws ReflectionException
     */
    public function reject(): ResponseInterface
    {
        $uid = (int)(session()->get('user_id') ?? 0);
        if ($uid <= 0) return $this->failUnauthorized('Chưa đăng nhập');

        $payload = $this->request->getJSON(true);
        $convertedId = (int)($payload['converted_id'] ?? 0);
        $comment = $payload['comment'] ?? null;

        $signM = new DocumentSignStatusModel();

        $step = $signM->where('converted_id', $convertedId)
            ->where('user_id', $uid)
            ->where('status', 'pending')
            ->first();

        if (!$step) return $this->failForbidden('Không phải lượt ký của bạn.');

        $signM->update($step['id'], [
            'status' => 'rejected',
            'comment' => $comment,
            'signed_at' => date('Y-m-d H:i:s')
        ]);

        return $this->respond(['message' => 'Đã từ chối']);
    }

    /* ====================================================
       5. DETAIL OF SIGNING CHAIN
       GET /api/document-sign/detail/{converted_id}
       ==================================================== */
    public function detail($convertedId): ResponseInterface
    {
        $convertedId = (int)$convertedId;
        $signM = new DocumentSignStatusModel();
        $convertedM = new DocumentConvertedModel();

        $doc = $convertedM->find($convertedId);
        if (!$doc) return $this->failNotFound('Không tìm thấy tài liệu');

        $chain = $signM->where('converted_id', $convertedId)
            ->orderBy('order_index', 'ASC')
            ->findAll();

        return $this->respond([
            'document' => $doc,
            'steps' => $chain
        ]);
    }


}
