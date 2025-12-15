<?php

namespace App\Controllers;

use App\Models\BiddingModel;
use App\Models\ContractModel;
use App\Models\DocumentConvertedModel;
use App\Models\DocumentSignStatusModel;
use App\Models\TaskModel;
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



    private function getLinkedEntity(
        string $type,
        int $linkedId,
        ?int $taskStepId = null
    ): ?array
    {
        $db = db_connect();

        /* ===============================
           BIDDING
           =============================== */
        if ($type === 'bidding') {
            $bidding = (new \App\Models\BiddingModel())->find($linkedId);
            if (!$bidding) return null;

            $step = null;
            if ($taskStepId) {
                $step = $db->table('bidding_steps')
                    ->select('step_number, title')
                    ->where('id', $taskStepId)
                    ->where('bidding_id', $linkedId)
                    ->get()
                    ->getRowArray();
            }

            return [
                'type' => 'bidding',
                'id'   => $bidding['id'],
                'code' => null,
                'name' => $bidding['title'],
                'step' => $step ? [
                    'number' => (int)$step['step_number'],
                    'title'  => $step['title'],
                ] : null,
            ];
        }

        /* ===============================
           CONTRACT
           =============================== */
        if ($type === 'contract') {
            $contract = (new \App\Models\ContractModel())->find($linkedId);
            if (!$contract) return null;

            $step = null;
            if ($taskStepId) {
                $step = $db->table('contract_steps')
                    ->select('step_number, title')
                    ->where('id', $taskStepId)
                    ->where('contract_id', $linkedId)
                    ->get()
                    ->getRowArray();
            }

            return [
                'type' => 'contract',
                'id'   => $contract['id'],
                'code' => $contract['code'],
                'name' => $contract['title'],
                'step' => $step ? [
                    'number' => (int)$step['step_number'],
                    'title'  => $step['title'],
                ] : null,
            ];
        }

        return null;
    }





    /* ====================================================
       2. FETCH INBOX (FILE USER NEEDS TO SIGN)
       GET /api/document-sign/inbox
       ==================================================== */
    public function inbox(): ResponseInterface
    {
        $uid = (int)(session()->get('user_id') ?? 0);
        if ($uid <= 0) {
            return $this->failUnauthorized('Chưa đăng nhập');
        }

        $convertedM = new DocumentConvertedModel();
        $taskM      = new TaskModel();
        $db         = db_connect();

        /* =========================================
           1. LẤY DANH SÁCH DOCUMENT USER CÓ THAM GIA KÝ
           ========================================= */
        $rows = $db->table('document_sign_status')
            ->distinct()
            ->select('converted_id')
            ->where('approver_id', $uid)
            ->get()
            ->getResultArray();

        if (!$rows) {
            return $this->respond(['items' => []]);
        }

        $result = [];

        foreach ($rows as $r) {

            $convertedId = (int)$r['converted_id'];

            /* ===============================
               DOCUMENT
               =============================== */
            $doc = $convertedM->find($convertedId);
            if (!$doc) continue;

            /* ===============================
               SIGN CHAIN (FULL)
               =============================== */
            $chain = $db->table('document_sign_status ds')
                ->select('
                ds.id,
                ds.converted_id,
                ds.approver_id,
                u.name AS approver_name,
                ds.order_index,
                ds.status,
                ds.signed_at,
                ds.signed_pdf_url,
                ds.task_file_id
            ')
                ->join('users u', 'u.id = ds.approver_id', 'left')
                ->where('ds.converted_id', $convertedId)
                ->orderBy('ds.order_index', 'ASC')
                ->get()
                ->getResultArray();

            if (!$chain) continue;

            /* ===============================
               STEP CỦA USER HIỆN TẠI
               =============================== */
            $myStep = null;
            foreach ($chain as $c) {
                if ((int)$c['approver_id'] === $uid) {
                    $myStep = $c;
                    break;
                }
            }

            if (!$myStep) continue; // an toàn

            /* ===============================
               MAP STEPS CHO FE
               =============================== */
            $steps = array_map(static fn ($x) => [
                'id'             => $x['id'],
                'sequence'       => $x['order_index'],
                'approver_id'    => $x['approver_id'],
                'approver_name'  => $x['approver_name'] ?? '—',
                'status'         => $x['status'] ?: 'waiting',
                'signed_pdf_url' => $x['signed_pdf_url'],
                'is_current'     => $x['status'] === 'pending',
                'is_approved'    => $x['status'] === 'signed',
            ], $chain);

            /* ===============================
               TASK + LINKED ENTITY
               =============================== */
            $task   = null;
            $linked = null;

            if (!empty($myStep['task_file_id'])) {
                $taskRow = $taskM->find((int)$myStep['task_file_id']);
                if ($taskRow) {
                    $task = [
                        'id'       => $taskRow['id'],
                        'title'    => $taskRow['title'],
                        'status'   => $taskRow['status'],
                        'progress' => $taskRow['progress'],
                        'priority' => $taskRow['priority'] ?? null,
                    ];

                    $linked = $this->getLinkedEntity(
                        $taskRow['linked_type'],
                        (int)$taskRow['linked_id'],
                        $taskRow['step_id'] ?? null
                    );
                }
            }

            /* ===============================
               FILE URL
               =============================== */
            $signedUrl = $myStep['signed_pdf_url'] ?? null;
            $fileUrl   = $signedUrl ?: $doc['file_url'];

            /* ===============================
               PUSH RESULT
               =============================== */
            $result[] = [
                'id'            => $myStep['id'],
                'converted_id'  => $convertedId,
                'title'         => $doc['title'],
                'url'           => $fileUrl,
                'original_url'  => $doc['file_url'],
                'signed_url'    => $signedUrl,

                'task_file_id'  => $myStep['task_file_id'],
                'task'          => $task,
                'linked'        => $linked,

                'uploader_name' => $doc['uploader_name'],
                'created_at'    => $doc['wp_created_at'],
                'sequence'      => $myStep['order_index'],
                'status'        => $myStep['status'] ?: 'waiting', // 🔥 CỰC QUAN TRỌNG
                'steps'         => $steps,
                'doc_type'      => $doc['doc_type'] ?? null,
            ];
        }

        usort($result, static fn ($a, $b) =>
            strtotime($b['created_at']) <=> strtotime($a['created_at'])
        );

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
        if ($uid <= 0) {
            return $this->failUnauthorized('Chưa đăng nhập');
        }

        $payload = $this->request->getJSON(true);

        $convertedId  = (int)($payload['converted_id'] ?? 0);
        $signatureUrl = $payload['signature_url'] ?? null;
        $signedPdfUrl = $payload['signed_pdf_url'] ?? null;
        $comment      = $payload['comment'] ?? null;

        if ($convertedId <= 0) {
            return $this->failValidationErrors('Thiếu converted_id');
        }

        $db    = db_connect();
        $signM = new DocumentSignStatusModel();

        /* =====================================================
           1. LẤY STEP CỦA USER (CHO PHÉP pending + waiting)
           ===================================================== */
        $step = $db->table('document_sign_status ds')
            ->select('ds.*, p.level AS approver_level')
            ->join('users u', 'u.id = ds.approver_id')
            ->join('positions p', 'p.id = u.position_id', 'left')
            ->where('ds.converted_id', $convertedId)
            ->where('ds.approver_id', $uid)
            ->whereIn('ds.status', ['pending', 'waiting']) // 🔥 QUAN TRỌNG
            ->orderBy('ds.order_index', 'ASC')
            ->get()
            ->getRowArray();

        if (!$step) {
            return $this->failForbidden('Không phải lượt ký của bạn.');
        }

        $currentLevel = (int)($step['approver_level'] ?? 0);

        /* =====================================================
           2. ĐÁNH DẤU STEP HIỆN TẠI = SIGNED
           ===================================================== */
        $signM->update($step['id'], [
            'status'         => 'signed',
            'signed_at'      => date('Y-m-d H:i:s'),
            'signature_url'  => $signatureUrl,
            'signed_pdf_url' => $signedPdfUrl,
            'comment'        => $comment,
        ]);

        /* =====================================================
           3. OVERRIDE LOGIC – CẤP CAO KÝ TRƯỚC
           ===================================================== */
        // Quy ước:
        // level >= 3  → Phó GĐ, GĐ (tuỳ hệ thống của bạn)
        $OVERRIDE_LEVEL = 3;

        if ($currentLevel >= $OVERRIDE_LEVEL) {

            // Skip toàn bộ step còn lại có level thấp hơn
            $lowerSteps = $db->table('document_sign_status ds')
                ->select('ds.id')
                ->join('users u', 'u.id = ds.approver_id')
                ->join('positions p', 'p.id = u.position_id', 'left')
                ->where('ds.converted_id', $convertedId)
                ->whereIn('ds.status', ['pending', 'waiting'])
                ->where('p.level <', $currentLevel)
                ->get()
                ->getResultArray();

            if (!empty($lowerSteps)) {
                $ids = array_column($lowerSteps, 'id');

                $signM->whereIn('id', $ids)
                    ->set([
                        'status'    => 'skipped',
                        'signed_at' => date('Y-m-d H:i:s'),
                    ])
                    ->update();
            }

            // ❗ KHÔNG mở step tiếp theo
            return $this->respond([
                'message'  => 'Đã ký (override chuỗi ký)',
                'override' => true,
            ]);
        }

        /* =====================================================
           4. LOGIC CŨ – KÝ TUẦN TỰ
           ===================================================== */
        $next = $signM
            ->where('converted_id', $convertedId)
            ->where('order_index >', $step['order_index'])
            ->where('status', 'waiting')
            ->orderBy('order_index', 'ASC')
            ->first();

        if ($next) {
            $signM->update($next['id'], [
                'status' => 'pending',
            ]);
        }

        return $this->respond([
            'message' => 'Đã ký thành công',
        ]);
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
