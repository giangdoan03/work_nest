<?php
namespace App\Controllers;

use App\Models\DocumentModel;
use App\Models\ApprovalInstanceModel;
use App\Models\ApprovalStepModel;
use App\Models\ApprovalLogModel;
use CodeIgniter\I18n\Time;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class DocumentApprovalController extends ResourceController
{
    protected $format = 'json';

    private function nowVN(): string
    {
        return Time::now('Asia/Ho_Chi_Minh')->toDateTimeString();
    }

    private function isAdminSession(): bool
    {
        $s     = session();
        $role  = strtolower((string)($s->get('role') ?? ''));
        $roles = array_map('strtolower', (array)($s->get('roles') ?? []));
        return ($s->get('is_admin') ?? false)
            || (int)($s->get('role_id') ?? 0) === 1
            || in_array($role, ['admin','super admin'], true)
            || in_array('admin', $roles, true)
            || in_array('super admin', $roles, true);
    }

    private function buildSteps(array $approverIds): array
    {
        // level: 1..n ; tất cả status=pending
        return array_map(
            fn($uid, $i) => [
                'level'        => $i + 1,
                'approver_id'  => (int)$uid,
                'status'       => 'pending',
                'commented_at' => null,
                'note'         => null,
            ],
            $approverIds,
            array_keys($approverIds)
        );
    }

    /** Gửi duyệt (chọn sẵn danh sách approver theo thứ tự) */
    public function send(): ResponseInterface
    {
        $p = $this->request->getJSON(true) ?? $this->request->getPost();
        $docId = (int)($p['document_id'] ?? 0);
        $approverIds = array_values(array_unique(array_filter(array_map('intval', (array)($p['approver_ids'] ?? [])))));
        if ($docId <= 0 || count($approverIds) < 1) {
            return $this->failValidationErrors('Cần document_id và ít nhất 1 approver.');
        }

        $docM = new DocumentModel();
        $doc  = $docM->find($docId);
        if (!$doc) return $this->failNotFound('Không tìm thấy tài liệu.');

        // Không cho gửi khi đang "pending" active
        if (($doc['approval_status'] ?? 'draft') === 'pending') {
            return $this->respond(['message' => 'Tài liệu đang chờ duyệt.'], 409);
        }

        $aiM  = new ApprovalInstanceModel();
        $asM  = new ApprovalStepModel();
        $logM = new ApprovalLogModel();
        $db   = db_connect();
        $db->transStart();

        // deactivate phiên active cũ (nếu có)
        $aiM->where(['target_type'=>'document', 'target_id'=>$docId, 'is_active'=>1])
            ->set(['is_active'=>0])->update();

        // version mới
        $maxV = (int)$aiM->selectMax('version','v')->where(['target_type'=>'document','target_id'=>$docId])->get()->getRow('v');
        $newV = $maxV > 0 ? ($maxV + 1) : 1;

        $userId = (int)(session()->get('user_id') ?? 0);
        $meta = [
            'title' => (string)($doc['title'] ?? ''),
            'url'   => (string)($doc['file_path'] ?? ''),
        ];

        $aiId = $aiM->insert([
            'target_type'   => 'document',
            'target_id'     => $docId,
            'version'       => $newV,
            'is_active'     => 1,
            'status'        => 'pending',
            'current_level' => 0,
            'submitted_by'  => $userId ?: null,
            'submitted_at'  => $this->nowVN(),
            'meta_json'     => $meta,
        ], true);

        // tạo steps tuần tự
        $rows = [];
        foreach ($approverIds as $i => $uid) {
            $rows[] = [
                'approval_instance_id' => $aiId,
                'level'       => $i + 1,
                'approver_id' => $uid,
                'status'      => 'pending',
            ];
        }
        if ($rows) $asM->insertBatch($rows);

        // đồng bộ documents
        $docM->update($docId, [
            'approval_status' => 'pending',
            'current_level'   => 0, // 0-based
            'approval_steps'  => json_encode($this->buildSteps($approverIds), JSON_UNESCAPED_UNICODE),
            'updated_at'      => $this->nowVN(),
        ]);

        // log
        $logM->insert([
            'approval_instance_id' => $aiId,
            'actor_id'   => $userId ?: null,
            'action'     => 'send',
            'data_json'  => ['approver_ids' => $approverIds, 'meta' => $meta],
            'created_at' => $this->nowVN(),
        ]);

        $db->transComplete();
        if (!$db->transStatus()) return $this->failServerError('Không thể gửi phê duyệt.');

        return $this->respondCreated([
            'message' => 'Đã gửi phê duyệt.',
            'approval_instance_id' => $aiId,
            'version' => $newV,
            'total_steps' => count($approverIds),
            'current_level' => 0
        ]);
    }

    /** Duyệt cấp hiện tại (chỉ current approver hoặc admin) */
    public function approve($instanceId = null): ResponseInterface
    {
        $id = (int)$instanceId;
        $note = $this->request->getPost('note') ?? ($this->request->getJSON(true)['note'] ?? null);

        $aiM  = new ApprovalInstanceModel();
        $asM  = new ApprovalStepModel();
        $logM = new ApprovalLogModel();

        $ai = $aiM->find($id);
        if (!$ai) return $this->failNotFound('Không tìm thấy phiên duyệt.');
        if ($ai['status'] !== 'pending') return $this->failValidationErrors('Phiên không ở trạng thái chờ duyệt.');

        $userId  = (int)(session()->get('user_id') ?? 0);
        $isAdmin = $this->isAdminSession();
        if (!$isAdmin && $userId <= 0) {
            return $this->failForbidden('Bạn cần đăng nhập để duyệt.');
        }

        $db = db_connect();
        $db->transStart();

        // Khoá chống race (cùng lúc có 2 người bấm)
        $db->query('SELECT id FROM approval_instances WHERE id = ? FOR UPDATE', [$id]);

        // Xác định cấp hiện tại (1-based) và step tương ứng
        $currLevel1 = (int)$ai['current_level'] + 1;
        $step = $asM->where('approval_instance_id', $id)->where('level', $currLevel1)->first();
        if (!$step) {
            $db->transComplete();
            return $this->failValidationErrors('Thiếu cấu hình cấp duyệt.');
        }

        // Chỉ current approver mới được duyệt (trừ admin)
        if (!$isAdmin && (int)$step['approver_id'] !== $userId) {
            $db->transComplete();
            return $this->failForbidden('Bạn không phải người duyệt ở cấp hiện tại.');
        }
        if (($step['status'] ?? '') === 'approved') {
            $db->transComplete();
            return $this->respond(['message' => 'Cấp hiện tại đã duyệt trước đó.', 'instance_status' => $ai['status']]);
        }

        // Cập nhật step hiện tại -> approved
        $asM->update($step['id'], [
            'status'       => 'approved',
            'commented_at' => $this->nowVN(),
            'note'         => $note,
            'acted_by'     => $userId ?: null,
            'acted_role'   => $isAdmin ? 'admin' : 'approver',
        ]);

        // Còn cấp sau?
        $hasNext = $asM->where('approval_instance_id', $id)->where('level >', $currLevel1)->countAllResults() > 0;

        if ($hasNext) {
            // Sang cấp kế tiếp (tuần tự)
            $aiM->update($id, [
                'current_level' => (int)$ai['current_level'] + 1, // 0-based
                'status'        => 'pending',
            ]);
        } else {
            // Hoàn tất phiên
            $aiM->update($id, [
                'status'       => 'approved',
                'finalized_at' => $this->nowVN(),
            ]);

            // Đồng bộ bảng documents
            $docM = new DocumentModel();
            $docM->update((int)$ai['target_id'], [
                'approval_status' => 'approved',
                'updated_at'      => $this->nowVN(),
            ]);
        }

        // Log
        $logM->insert([
            'approval_instance_id' => $id,
            'actor_id'   => $userId ?: null,
            'action'     => 'approve',
            'data_json'  => ['note' => $note, 'level' => $currLevel1],
            'created_at' => $this->nowVN(),
        ]);

        $db->transComplete();
        if (!$db->transStatus()) return $this->failServerError('Không thể cập nhật phê duyệt.');

        return $this->respond([
            'message'         => $hasNext ? 'Đã duyệt cấp hiện tại.' : 'Đã duyệt hoàn tất.',
            'has_next'        => $hasNext,
            'instance_status' => $hasNext ? 'pending' : 'approved',
            'current_level'   => $hasNext ? ((int)$ai['current_level'] + 1) : (int)$ai['current_level'],
        ]);
    }

    /** Từ chối ở cấp hiện tại (chỉ current approver hoặc admin) */
    public function reject($instanceId = null): ResponseInterface
    {
        $id = (int)$instanceId;
        $note = $this->request->getPost('note') ?? ($this->request->getJSON(true)['note'] ?? null);

        $aiM  = new ApprovalInstanceModel();
        $asM  = new ApprovalStepModel();
        $logM = new ApprovalLogModel();

        $ai = $aiM->find($id);
        if (!$ai) return $this->failNotFound('Không tìm thấy phiên duyệt.');
        if ($ai['status'] !== 'pending') return $this->failValidationErrors('Phiên không ở trạng thái chờ duyệt.');

        $userId  = (int)(session()->get('user_id') ?? 0);
        $isAdmin = $this->isAdminSession();
        if (!$isAdmin && $userId <= 0) {
            return $this->failForbidden('Bạn cần đăng nhập để từ chối.');
        }

        $db = db_connect();
        $db->transStart();
        $db->query('SELECT id FROM approval_instances WHERE id = ? FOR UPDATE', [$id]);

        $currLevel1 = (int)$ai['current_level'] + 1;
        $step = $asM->where('approval_instance_id', $id)->where('level', $currLevel1)->first();
        if (!$step) { $db->transComplete(); return $this->failValidationErrors('Thiếu cấu hình cấp duyệt.'); }
        if (!$isAdmin && (int)$step['approver_id'] !== $userId) {
            $db->transComplete(); return $this->failForbidden('Bạn không phải người duyệt ở cấp hiện tại.');
        }

        // step -> rejected, instance -> rejected, document -> rejected
        $asM->update($step['id'], [
            'status'       => 'rejected',
            'commented_at' => $this->nowVN(),
            'note'         => $note,
            'acted_by'     => $userId ?: null,
            'acted_role'   => $isAdmin ? 'admin' : 'approver',
        ]);

        $aiM->update($id, [
            'status'       => 'rejected',
            'finalized_at' => $this->nowVN(),
        ]);

        (new DocumentModel())->update((int)$ai['target_id'], [
            'approval_status' => 'rejected',
            'updated_at'      => $this->nowVN(),
        ]);

        $logM->insert([
            'approval_instance_id' => $id,
            'actor_id'   => $userId ?: null,
            'action'     => 'reject',
            'data_json'  => ['note' => $note, 'level' => $currLevel1],
            'created_at' => $this->nowVN(),
        ]);

        $db->transComplete();
        if (!$db->transStatus()) return $this->failServerError('Không thể từ chối.');

        return $this->respond(['message'=>'Đã từ chối.','instance_status'=>'rejected']);
    }

    /** (Tuỳ chọn) thay đổi danh sách approver khi CHƯA hoàn tất */
    public function updateSteps($instanceId = null): ResponseInterface
    {
        $id = (int)$instanceId;
        $p  = $this->request->getJSON(true) ?? $this->request->getPost();
        $approverIds = array_values(array_unique(array_filter(array_map('intval', (array)($p['approver_ids'] ?? [])))));
        if (count($approverIds) < 1) return $this->failValidationErrors('Cần tối thiểu 1 approver.');

        // Có thể reuse ApprovalController::updateSteps() của bạn
        return (new \App\Controllers\ApprovalController())->updateSteps($id);
    }
}
