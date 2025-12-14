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
        $taskFileId   = (int)($payload['task_file_id'] ?? 0);   // 🔥 LẤY TỪ FE
        $approvers   = array_values(array_unique(array_filter(array_map('intval', $payload['approver_ids'] ?? []))));

        if ($convertedId <= 0) return $this->failValidationErrors('Thiếu converted_id');
        if (empty($approvers)) return $this->failValidationErrors('Thiếu approver_ids');

        $convertedM = new DocumentConvertedModel();
        $signM = new DocumentSignStatusModel();
        $userM = new UserModel();

        // Check document exists
        $doc = $convertedM->find($convertedId);
        if (!$doc) return $this->failNotFound('Tài liệu convert không tồn tại');

        // Xóa chuỗi ký cũ nếu có
        $signM->where('converted_id', $convertedId)->delete();

        // Tạo danh sách bước ký mới
        $batch = [];
        $index = 1;

        foreach ($approvers as $uid) {

            // lấy tên để lưu vào approver_name
            $u = $userM->find($uid);
            $approverName = $u['name'] ?? null;

            $batch[] = [
                'converted_id'   => $convertedId,
                'approver_id'    => $uid,
                'approver_name'  => $approverName,
                'signed_by_id'   => null,
                'signed_by_name' => null,
                'order_index'    => $index,
                'status'         => ($index === 1 ? 'pending' : 'waiting'),
                'signed_at'      => null,
                'signed_pdf_url' => null,
                'signature_url'  => null,
                'task_file_id'   => $taskFileId > 0 ? $taskFileId : null,  // 🔥 UPDATE
                'created_at'     => date('Y-m-d H:i:s'),
            ];

            $index++;
        }

        $signM->insertBatch($batch);

        return $this->respondCreated([
            'message'      => 'Gửi ký thành công',
            'converted_id' => $convertedId,
            'total_steps'  => count($batch),
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

        // 1) Lấy các bước ký của user
        $rows = $signM
            ->where('approver_id', $uid)
            ->whereIn('status', ['pending', 'signed'])
            ->orderBy('order_index', 'ASC')
            ->findAll();

        $result = [];

        foreach ($rows as $s) {

            $doc = $convertedM->find($s['converted_id']);
            if (!$doc) continue;

            // 2) Lấy toàn bộ chain ký
            $chain = $db->table('document_sign_status ds')
                ->select('
                ds.id,
                ds.converted_id,
                ds.approver_id,
                u.name AS approver_name,
                ds.order_index,
                ds.status,
                ds.signed_at,
                ds.signed_pdf_url
            ')
                ->join('users u', 'u.id = ds.approver_id', 'left')
                ->where('ds.converted_id', $s['converted_id'])
                ->orderBy('ds.order_index', 'ASC')
                ->get()->getResultArray();

            $steps = array_map(fn($x) => [
                'id'            => $x['id'],
                'sequence'      => $x['order_index'],
                'approver_id'   => $x['approver_id'],
                'approver_name' => $x['approver_name'] ?? '—',
                'status'        => $x['status'],
                'signed_pdf_url'=> $x['signed_pdf_url'],
                'is_current'    => $x['status'] === 'pending',
                'is_approved'   => $x['status'] === 'signed',
            ], $chain);

            // 3) Nếu user đã ký → hiển thị file đã ký
            $signedUrl = $s['signed_pdf_url'] ?? null;
            $fileUrl = $signedUrl ?: $doc['file_url'];

            $result[] = [
                'id'            => $s['id'],
                'converted_id'  => $s['converted_id'],
                'title'         => $doc['title'],
                'url'           => $fileUrl,
                'original_url'  => $doc['file_url'],
                'signed_url'    => $signedUrl,
                'task_file_id'  => $s['task_file_id'] ?? null,
                'uploader_name' => $doc['uploader_name'],
                'created_at'    => $doc['wp_created_at'],  // ✔ sort theo cái này
                'sequence'      => $s['order_index'],
                'status'        => $s['status'],
                'steps'         => $steps,
                'doc_type'      => $doc['doc_type'] ?? null, // nếu không cần thì xóa
            ];
        }

        // 4) Sắp xếp theo created_at giảm dần (mới nhất lên đầu)
        usort($result, function ($a, $b) {
            return strtotime($b['created_at']) - strtotime($a['created_at']);
        });

        return $this->respond(['items' => $result]);
    }



    /* ====================================================
       3. SIGN DOCUMENT (STEP-BY-STEP)
       POST /api/document-sign/sign
       ==================================================== */
    /**
     * @throws ReflectionException
     */
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
            ->where('approver_id', $uid)   // ✅ ĐÚNG
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

    public function delete($id = null)
    {
        if (!$id) {
            return $this->failValidationErrors('Thiếu ID');
        }

        $signM = new DocumentSignStatusModel();

        $step = $signM->find($id);
        if (!$step) {
            return $this->failNotFound('Step ký không tồn tại');
        }

        $signM->delete($id);

        return $this->respondDeleted([
            'message' => 'Xoá bước ký thành công'
        ]);
    }



}
