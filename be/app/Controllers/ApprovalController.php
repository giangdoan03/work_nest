<?php

namespace App\Controllers;

use App\Models\ApprovalInstanceModel;
use App\Models\ApprovalStepModel;
use App\Models\ApprovalLogModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use ReflectionException;

class ApprovalController extends ResourceController
{
    protected $format = 'json';

    /* ======================= Helpers dùng chung ======================= */

    /** Kiểm tra admin theo session (is_admin | role_id=1 | role/super admin) */
    private function isAdminSession(): bool
    {
        $s     = session();
        $role  = strtolower((string)($s->get('role') ?? ''));
        $roles = array_map('strtolower', (array)($s->get('roles') ?? []));

        return ($s->get('is_admin') ?? false)
            || (int)($s->get('role_id') ?? 0) === 1
            || in_array($role, ['admin', 'super admin'], true)
            || in_array('admin', $roles, true)
            || in_array('super admin', $roles, true);
    }

    /** Map target_type -> tên bảng */
    private function tableFor(string $type): ?string
    {
        return match ($type) {
            'bidding'        => 'biddings',
            'contract'       => 'contracts',
            'bidding_step'   => 'bidding_steps',
            'contract_step'  => 'contract_steps',
            'task'           => 'tasks',
            'document'           => 'document',
            default          => null,
        };
    }

    /** Decode steps (mảng/JSON/TEXT -> array) */
    private function decodeSteps($raw): array
    {
        if (is_array($raw)) return $raw;
        if (is_string($raw) && $raw !== '') {
            $tmp = json_decode($raw, true);
            return is_array($tmp) ? $tmp : [];
        }
        return [];
    }

    /** Build steps = pending từ danh sách approver_ids */
    private function buildStepsFromIds(array $approverIds): array
    {
        $steps = [];
        foreach ($approverIds as $i => $uid) {
            $steps[] = [
                'level'        => $i + 1,
                'approver_id'  => (int)$uid,
                'status'       => 'pending',
                'commented_at' => null,
                'note'         => null,
            ];
        }
        return $steps;
    }

    /** Đồng bộ bảng đích khi GỬI DUYỆT / RESET STEPS */
    private function syncTargetOnSend(string $type, int $id, array $approverIds): void
    {
        $table = $this->tableFor($type);
        if (!$table || $id <= 0) return;

        $steps = $this->buildStepsFromIds($approverIds);

        db_connect()->table($table)->where('id', $id)->update([
            'approval_steps'  => json_encode($steps, JSON_UNESCAPED_UNICODE),
            'current_level'   => 0,              // 0-based
            'approval_status' => 'pending',
            'updated_at'      => date('Y-m-d H:i:s'),
        ]);
    }

    /** Đồng bộ bảng đích khi APPROVE một cấp (hoặc hoàn tất) */
    private function syncTargetOnApprove(array $ai, int $currLevel0, ?string $note, bool $hasNext): void
    {
        $table = $this->tableFor((string)$ai['target_type']);
        if (!$table) return;

        $db  = db_connect();
        $row = $db->table($table)
            ->select('id, approval_steps, current_level')
            ->where('id', (int)$ai['target_id'])
            ->get()->getRowArray();
        if (!$row) return;

        $steps = $this->decodeSteps($row['approval_steps'] ?? null);
        if (isset($steps[$currLevel0])) {
            $steps[$currLevel0]['status']       = 'approved';
            $steps[$currLevel0]['commented_at'] = date('Y-m-d H:i:s');
            if ($note !== null) $steps[$currLevel0]['note'] = $note;
        }

        $db->table($table)->where('id', (int)$ai['target_id'])->update([
            'approval_steps'  => json_encode($steps, JSON_UNESCAPED_UNICODE),
            'current_level'   => $hasNext ? ($currLevel0 + 1) : $currLevel0,
            'approval_status' => $hasNext ? 'pending' : 'approved',
            'updated_at'      => date('Y-m-d H:i:s'),
        ]);
    }

    /** Đồng bộ bảng đích khi REJECT cấp hiện tại */
    private function syncTargetOnReject(array $ai, int $currLevel0, ?string $note): void
    {
        $table = $this->tableFor((string)$ai['target_type']);
        if (!$table) return;

        $db  = db_connect();
        $row = $db->table($table)
            ->select('id, approval_steps')
            ->where('id', (int)$ai['target_id'])
            ->get()->getRowArray();
        if (!$row) return;

        $steps = $this->decodeSteps($row['approval_steps'] ?? null);
        if (isset($steps[$currLevel0])) {
            $steps[$currLevel0]['status']       = 'rejected';
            $steps[$currLevel0]['commented_at'] = date('Y-m-d H:i:s');
            if ($note !== null) $steps[$currLevel0]['note'] = $note;
        }

        $db->table($table)->where('id', (int)$ai['target_id'])->update([
            'approval_steps'  => json_encode($steps, JSON_UNESCAPED_UNICODE),
            'approval_status' => 'rejected',
            'updated_at'      => date('Y-m-d H:i:s'),
        ]);
    }

    /* ======================= API chính ======================= */

    /** Inbox phê duyệt */
    public function inbox(): ResponseInterface
    {
        $db = db_connect();
        $session = session();
        $userId  = (int) ($session->get('user_id') ?? 0);
        $roleId  = (int) ($session->get('role_id') ?? 0);
        $role    = strtolower((string) ($session->get('role') ?? ''));
        $isAdmin = (bool) ($session->get('is_admin') ?? false)
            || $roleId === 1
            || in_array($role, ['admin','super admin'], true);

        $per    = min(100, max(1, (int) ($this->request->getGet('per_page') ?? 10)));
        $page   = max(1, (int) ($this->request->getGet('page') ?? 1));
        $off    = ($page - 1) * $per;
        $search = trim((string) ($this->request->getGet('search') ?? ''));

        // 👇 Lấy CSV target_types (nếu có), mặc định 5 loại
        $targetCsv = (string) ($this->request->getGet('target_types') ?? '');
        $allowedDefault = ['bidding', 'contract', 'bidding_step', 'contract_step', 'task'];
        $targetTypes = $targetCsv !== ''
            ? array_values(array_filter(array_map('trim', explode(',', $targetCsv))))
            : $allowedDefault;

        // Bảo vệ: chỉ chấp nhận các giá trị trong whitelist
        $whitelist = array_flip($allowedDefault);
        $targetTypes = array_values(array_filter($targetTypes, fn($t) => isset($whitelist[$t])));
        if (empty($targetTypes)) $targetTypes = $allowedDefault;

        $base = $db->table('approval_instances ai')
            ->join(
                'approval_steps s',
                's.approval_instance_id = ai.id AND s.level = ai.current_level + 1',
                'inner'
            )
            ->where('ai.is_active', 1)
            ->where('ai.status', 'pending')
            ->where('s.status', 'pending')
            ->whereIn('ai.target_type', $targetTypes); // ✅ đa loại

        if (!$isAdmin) {
            $base->where('s.approver_id', $userId);
        }

        if ($search !== '') {
            $base->groupStart()
                ->like('JSON_UNQUOTE(JSON_EXTRACT(ai.meta_json, "$.title"))', $search, 'both', false)
                ->orLike('ai.target_type', $search)
                ->groupEnd();
        }

        $total = (clone $base)
            ->select('COUNT(DISTINCT ai.id) AS cnt', false)
            ->get()->getRow('cnt') ?: 0;

        $rows = (clone $base)
            ->select(
                'ai.*, ' .
                's.level AS _curr_level, ' .
                's.approver_id AS _curr_approver, ' .
                '(SELECT COUNT(*) FROM approval_steps s2 WHERE s2.approval_instance_id = ai.id) AS _total_steps',
                false
            )
            ->groupBy('ai.id')
            ->orderBy('ai.submitted_at', 'DESC')
            ->limit($per, $off)
            ->get()->getResultArray();

        return $this->respond([
            'data'  => $rows,
            'pager' => [
                'total'        => (int) $total,
                'per_page'     => $per,
                'current_page' => $page,
            ],
        ]);
    }

    /** Lấy chi tiết 1 phiên duyệt */
    public function show($id = null)
    {
        $aiModel = new ApprovalInstanceModel();
        $asModel = new ApprovalStepModel();

        $ai = $aiModel->find((int) $id);
        if (!$ai) return $this->failNotFound('Không tìm thấy phiên duyệt.');

        $steps = $asModel
            ->where('approval_instance_id', $ai['id'])
            ->orderBy('level')
            ->findAll();

        return $this->respond([
            'instance' => $ai,
            'steps'    => $steps,
        ]);
    }

    /** Gửi duyệt (khởi động phiên active mới hoặc reset phiên active hiện tại)
     * @throws ReflectionException
     */
    public function send(): ResponseInterface
    {
        $payload = $this->request->getJSON(true) ?? $this->request->getPost();
        $type = (string) ($payload['target_type'] ?? '');
        $tid  = (int) ($payload['target_id'] ?? 0);
        $approverIds = array_values(array_unique(array_filter(array_map('intval', (array) ($payload['approver_ids'] ?? [])))));
        $meta = $payload['meta'] ?? null; // ví dụ: ['title'=>'...', 'url'=>'...']

        if (!$type || $tid <= 0 || count($approverIds) < 1) {
            return $this->failValidationErrors('Thiếu target_type/target_id hoặc danh sách approver.');
        }

        $policy = $this->checkPolicyBeforeSend($type, $tid);
        if ($policy !== true) {
            return $this->failValidationErrors(['policy' => $policy]);
        }

        $session = session();
        $userId = (int) ($session->get('user_id') ?? 0);

        $aiModel = new ApprovalInstanceModel();
        $asModel = new ApprovalStepModel();
        $logModel = new ApprovalLogModel();
        $db = db_connect();

        $current = $aiModel
            ->where(['target_type' => $type, 'target_id' => $tid, 'is_active' => 1])
            ->first();

        $db->transStart();

        if ($current) {
            $aiModel->update($current['id'], ['is_active' => 0]);
        }

        $maxVersion = (int) $aiModel->selectMax('version', 'v')
            ->where(['target_type' => $type, 'target_id' => $tid])
            ->get()->getRow('v');
        $newVersion = $maxVersion > 0 ? ($maxVersion + 1) : 1;

        $aiId = $aiModel->insert([
            'target_type'   => $type,
            'target_id'     => $tid,
            'version'       => $newVersion,
            'is_active'     => 1,
            'status'        => 'pending',
            'current_level' => 0,
            'submitted_by'  => $userId ?: null,
            'submitted_at'  => date('Y-m-d H:i:s'),
            'meta_json'     => $meta ?: null,
        ], true);

        $rows = [];
        foreach ($approverIds as $i => $uid) {
            $rows[] = [
                'approval_instance_id' => $aiId,
                'level'       => $i + 1, // 1-based
                'approver_id' => $uid,
                'status'      => 'pending',
            ];
        }
        if ($rows) $asModel->insertBatch($rows);

        // Đồng bộ về bảng đích CHUNG
        $this->syncTargetOnSend($type, $tid, $approverIds);

        $logModel->insert([
            'approval_instance_id' => $aiId,
            'actor_id'  => $userId ?: null,
            'action'    => 'send',
            'data_json' => ['approver_ids' => $approverIds, 'meta' => $meta],
            'created_at'=> date('Y-m-d H:i:s'),
        ]);

        $db->transComplete();

        return $this->respondCreated([
            'message' => 'Đã gửi phê duyệt.',
            'approval_instance_id' => $aiId,
            'version' => $newVersion,
        ]);
    }

    /** DUYỆT cấp hiện tại
     * @throws ReflectionException
     * @throws ReflectionException
     * @throws ReflectionException
     * @throws ReflectionException
     * @throws ReflectionException
     */
    public function approve($id = null): ResponseInterface
    {
        $id   = (int) $id;
        $note = $this->request->getPost('note') ?? ($this->request->getJSON(true)['note'] ?? null);

        $aiModel  = new ApprovalInstanceModel();
        $asModel  = new ApprovalStepModel();
        $logModel = new ApprovalLogModel();

        $ai = $aiModel->find($id);
        if (!$ai) return $this->failNotFound('Không tìm thấy phiên duyệt.');
        if ($ai['status'] !== 'pending') return $this->failValidationErrors('Phiên không ở trạng thái chờ duyệt.');

        $userId  = (int) (session()->get('user_id') ?? 0);
        $isAdmin = $this->isAdminSession();
        if (!$isAdmin && $userId <= 0) {
            return $this->failForbidden('Bạn cần đăng nhập để phê duyệt.');
        }

        $currLevel = (int) $ai['current_level'] + 1; // 1-based
        $step = $asModel->where('approval_instance_id', $id)->where('level', $currLevel)->first();
        if (!$step) return $this->failValidationErrors('Thiếu cấu hình cấp duyệt.');
        if (($step['status'] ?? '') === 'approved') {
            return $this->respond(['message' => 'Cấp hiện tại đã duyệt trước đó.', 'instance_status' => $ai['status']]);
        }
        if (!$isAdmin && (int) $step['approver_id'] !== $userId) {
            return $this->failForbidden('Bạn không phải người duyệt ở cấp hiện tại.');
        }

        $db = db_connect();
        $db->transStart();

        // Khoá chống race
        $db->query('SELECT id FROM approval_instances WHERE id = ? FOR UPDATE', [$id]);
        $db->query('SELECT id FROM approval_steps WHERE approval_instance_id = ? AND level = ? FOR UPDATE', [$id, $currLevel]);

        // 1) cập nhật step
        $asModel->update($step['id'], [
            'status'       => 'approved',
            'commented_at' => date('Y-m-d H:i:s'),
            'note'         => $note,
            'acted_by'     => $userId ?: null,
            'acted_role'   => $isAdmin ? 'admin' : 'approver',
        ]);

        // 2) còn cấp sau?
        $hasNext = $asModel->where('approval_instance_id', $id)->where('level >', $currLevel)->countAllResults() > 0;
        if ($hasNext) {
            $aiModel->update($id, [
                'current_level' => (int) $ai['current_level'] + 1, // 0-based
                'status'        => 'pending',
            ]);
        } else {
            $aiModel->update($id, [
                'status'       => 'approved',
                'finalized_at' => date('Y-m-d H:i:s'),
            ]);
        }

        // 3) Đồng bộ bảng đích CHUNG
        $curr0 = $currLevel - 1; // 0-based
        $this->syncTargetOnApprove($ai, $curr0, $note, $hasNext);

        // 4) Log
        $logModel->insert([
            'approval_instance_id' => $id,
            'actor_id'   => $userId ?: null,
            'action'     => 'approve',
            'data_json'  => ['note' => $note],
            'created_at' => date('Y-m-d H:i:s'),
        ]);

        $db->transComplete();
        if ($db->transStatus() === false) {
            return $this->failServerError('Không thể cập nhật phê duyệt, vui lòng thử lại.');
        }

        // Callback sau commit
        if (!$hasNext) {
            try {
                $fresh = $aiModel->find($id);
                if (method_exists($this, 'onApproved')) {
                    $this->onApproved($fresh ?? $ai);
                }
            } catch (\Throwable $e) {
                log_message('error', 'onApproved error: ' . $e->getMessage());
            }
        }

        return $this->respond([
            'message'         => $hasNext ? 'Đã duyệt cấp hiện tại.' : 'Đã duyệt hoàn tất.',
            'has_next'        => $hasNext,
            'instance_status' => $hasNext ? 'pending' : 'approved',
            'target_type'     => $ai['target_type'],
            'target_id'       => (int) $ai['target_id'],
        ]);
    }

    /** TỪ CHỐI cấp hiện tại */
    public function reject($id = null): ResponseInterface
    {
        $id   = (int) $id;
        $note = $this->request->getPost('note') ?? ($this->request->getJSON(true)['note'] ?? null);

        $aiModel  = new ApprovalInstanceModel();
        $asModel  = new ApprovalStepModel();
        $logModel = new ApprovalLogModel();

        $ai = $aiModel->find($id);
        if (!$ai) return $this->failNotFound('Không tìm thấy phiên duyệt.');
        if ($ai['status'] !== 'pending') return $this->failValidationErrors('Phiên không ở trạng thái chờ duyệt.');

        $userId  = (int) (session()->get('user_id') ?? 0);
        $isAdmin = $this->isAdminSession();

        $currLevel = (int) $ai['current_level'] + 1; // 1-based
        $step = $asModel->where('approval_instance_id', $id)->where('level', $currLevel)->first();
        if (!$step) return $this->failValidationErrors('Thiếu cấu hình cấp duyệt.');
        if (!$isAdmin && (int) $step['approver_id'] !== $userId) {
            return $this->failForbidden('Bạn không phải người duyệt ở cấp hiện tại.');
        }

        $db = db_connect();
        $db->transStart();

        $asModel->update($step['id'], [
            'status'       => 'rejected',
            'commented_at' => date('Y-m-d H:i:s'),
            'note'         => $note,
            'acted_by'     => $userId ?: null,
            'acted_role'   => $isAdmin ? 'admin' : 'approver',
        ]);

        $aiModel->update($id, [
            'status'       => 'rejected',
            'finalized_at' => date('Y-m-d H:i:s'),
        ]);

        // Đồng bộ bảng đích CHUNG
        $curr0 = (int) $ai['current_level']; // 0-based
        $this->syncTargetOnReject($ai, $curr0, $note);

        // Log
        $logModel->insert([
            'approval_instance_id' => $id,
            'actor_id'   => $userId ?: null,
            'action'     => 'reject',
            'data_json'  => ['note' => $note],
            'created_at' => date('Y-m-d H:i:s'),
        ]);

        $db->transComplete();

        return $this->respond([
            'message'         => 'Đã từ chối.',
            'instance_status' => 'rejected',
            'target_type'     => $ai['target_type'],
            'target_id'       => (int) $ai['target_id'],
        ]);
    }

    /** Cập nhật lại danh sách người duyệt cho một instance
     * @throws ReflectionException
     * @throws ReflectionException
     * @throws ReflectionException
     */
    public function updateSteps($id = null): ResponseInterface
    {
        $id = (int) $id;
        $payload = $this->request->getJSON(true) ?? $this->request->getPost();
        $approverIds = array_values(array_unique(array_filter(array_map('intval', (array) ($payload['approver_ids'] ?? [])))));

        if (count($approverIds) < 1) {
            return $this->failValidationErrors('Cần tối thiểu 1 approver.');
        }

        $aiModel  = new ApprovalInstanceModel();
        $asModel  = new ApprovalStepModel();
        $logModel = new ApprovalLogModel();
        $db       = db_connect();

        $ai = $aiModel->find($id);
        if (!$ai) return $this->failNotFound('Không tìm thấy phiên duyệt.');

        $userId = (int) (session()->get('user_id') ?? 0);

        $db->transStart();

        // ===== Nếu phiên đã APPROVED → tạo phiên mới =====
        if (($ai['status'] ?? '') === 'approved') {
            $aiModel->where([
                'target_type' => $ai['target_type'],
                'target_id'   => $ai['target_id'],
                'is_active'   => 1,
            ])->set(['is_active' => 0])->update();

            $maxVersion = (int) $aiModel->selectMax('version', 'v')
                ->where(['target_type' => $ai['target_type'], 'target_id' => $ai['target_id']])
                ->get()->getRow('v');
            $newVersion = $maxVersion > 0 ? ($maxVersion + 1) : 1;

            $newId = $aiModel->insert([
                'target_type'   => $ai['target_type'],
                'target_id'     => (int) $ai['target_id'],
                'version'       => $newVersion,
                'is_active'     => 1,
                'status'        => 'pending',
                'current_level' => 0,
                'submitted_by'  => $userId ?: null,
                'submitted_at'  => date('Y-m-d H:i:s'),
                'meta_json'     => $ai['meta_json'] ?? null,
            ], true);

            $rows = [];
            foreach ($approverIds as $i => $uid) {
                $rows[] = [
                    'approval_instance_id' => $newId,
                    'level'       => $i + 1,
                    'approver_id' => $uid,
                    'status'      => 'pending',
                ];
            }
            if ($rows) $asModel->insertBatch($rows);

            // Đồng bộ bảng đích CHUNG
            $this->syncTargetOnSend((string)$ai['target_type'], (int)$ai['target_id'], $approverIds);

            $logModel->insert([
                'approval_instance_id' => $newId,
                'actor_id'   => $userId ?: null,
                'action'     => 'resend',
                'data_json'  => ['approver_ids' => $approverIds, 'from_instance_id' => $id],
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            $db->transComplete();
            if ($db->transStatus() === false) {
                return $this->failServerError('Không thể tạo phiên duyệt mới, vui lòng thử lại.');
            }

            return $this->respond([
                'message'                => 'Đã tạo phiên duyệt mới.',
                'approval_instance_id'   => $newId,
                'version'                => $newVersion,
                'approval_status'        => 'pending',
                'current_level'          => 0,
            ]);
        }

        // ===== Chưa approved → reset steps trong cùng phiên =====
        $db->query('SELECT id FROM approval_instances WHERE id = ? FOR UPDATE', [$id]);

        $asModel->where('approval_instance_id', $id)->delete();
        $rows = [];
        foreach ($approverIds as $i => $uid) {
            $rows[] = [
                'approval_instance_id' => $id,
                'level'       => $i + 1,
                'approver_id' => $uid,
                'status'      => 'pending',
            ];
        }
        if ($rows) $asModel->insertBatch($rows);

        $aiModel->update($id, [
            'current_level' => 0,
            'status'        => 'pending',
        ]);

        // Đồng bộ bảng đích CHUNG
        $this->syncTargetOnSend((string)$ai['target_type'], (int)$ai['target_id'], $approverIds);

        $logModel->insert([
            'approval_instance_id' => $id,
            'actor_id'   => $userId ?: null,
            'action'     => 'update_steps',
            'data_json'  => ['approver_ids' => $approverIds],
            'created_at' => date('Y-m-d H:i:s'),
        ]);

        $db->transComplete();
        if ($db->transStatus() === false) {
            return $this->failServerError('Không thể cập nhật người duyệt, vui lòng thử lại.');
        }

        return $this->respond([
            'message'          => 'Cập nhật người duyệt thành công.',
            'approval_status'  => 'pending',
            'current_level'    => 0,
        ]);
    }

    /* =========================== POLICY & HOOKS =========================== */

    /** Kiểm tra điều kiện nghiệp vụ trước khi gửi */
    private function checkPolicyBeforeSend(string $type, int $id): bool|string
    {
        // TODO: Viết query thật theo nghiệp vụ của bạn
        switch ($type) {
            case 'bidding':
            case 'contract_step':
            case 'bidding_step':
            case 'task':
            case 'document':
            case 'contract':
                return true;
            default:
                return 'Loại đối tượng không hợp lệ.';
        }
    }

    /** Hook khi phiên duyệt approved hoàn tất (tác động entity gốc nếu cần) */
    private function onApproved(array $instance): void
    {
        // Ví dụ: nếu target_type='bidding' -> set status WON...
    }

    /** Danh sách phiên theo filter */
    public function list(): ResponseInterface
    {
        $per    = min(100, max(1, (int) ($this->request->getGet('per_page') ?? 20)));
        $page   = max(1, (int) ($this->request->getGet('page') ?? 1));
        $offset = ($page - 1) * $per;

        $statusCsv = trim((string) ($this->request->getGet('status') ?? ''));   // "approved,rejected" | "pending"
        $actedByMe = (int) ($this->request->getGet('acted_by_me') ?? 0) === 1;
        $search    = trim((string) ($this->request->getGet('search') ?? ''));
        $userId    = (int) (session()->get('user_id') ?? 0);

        $db = db_connect();

        $base = $db->table('approval_instances ai');
        if ($statusCsv !== '') {
            $statuses = array_filter(array_map('trim', explode(',', $statusCsv)));
            if ($statuses) {
                $base->whereIn('ai.status', $statuses);
            }
        }
        if ($actedByMe && $userId > 0) {
            $base->join('approval_steps s', 's.approval_instance_id = ai.id', 'inner');
            $base->where('s.acted_by', $userId);
        }
        if ($search !== '') {
            $base->groupStart()
                ->like('JSON_UNQUOTE(JSON_EXTRACT(ai.meta_json, "$.title"))', $search, 'both', false)
                ->orLike('ai.target_type', $search)
                ->groupEnd();
        }

        $total = (clone $base)
            ->select('COUNT(DISTINCT ai.id) AS cnt', false)
            ->get()->getRow('cnt');
        $total = (int) ($total ?? 0);

        $rows = (clone $base)
            ->select("
                ai.*,
                (SELECT COUNT(*) FROM approval_steps s2 WHERE s2.approval_instance_id = ai.id) AS _total_steps
            ", false)
            ->groupBy('ai.id')
            ->orderBy('ai.submitted_at', 'DESC')
            ->limit($per, $offset)
            ->get()->getResultArray();

        return $this->respond([
            'data'  => $rows,
            'pager' => [
                'total'        => $total,
                'per_page'     => $per,
                'current_page' => $page,
            ],
        ]);
    }

    public function activeByTarget(): ResponseInterface
    {
        $type = (string) ($this->request->getGet('target_type') ?? '');
        $tid  = (int) ($this->request->getGet('target_id') ?? 0);

        if ($type === '' || $tid <= 0) {
            return $this->failValidationErrors('Thiếu target_type hoặc target_id.');
        }

        $db = db_connect();

        // phiên active (is_active=1)
        $instance = $db->table('approval_instances')
            ->where('target_type', $type)
            ->where('target_id', $tid)
            ->where('is_active', 1)
            ->get()->getRowArray();

        $steps = [];
        if ($instance) {
            $steps = $db->table('approval_steps')
                ->where('approval_instance_id', (int) $instance['id'])
                ->orderBy('level', 'ASC')
                ->get()->getResultArray();
        }

        return $this->respond([
            'instance' => $instance ?: null,
            'steps'    => $steps,
        ]);
    }



}
