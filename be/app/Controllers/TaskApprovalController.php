<?php

namespace App\Controllers;

use App\Enums\TaskStatus;
use App\Models\TaskApprovalLogModel;
use App\Models\TaskApprovalModel;
use App\Models\TaskModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use ReflectionException;

class TaskApprovalController extends ResourceController
{
    protected $format = 'json';

    /* ============================
     * Helpers (giữ + bổ sung)
     * ============================ */

    private function getUserId(): ?int
    {
        $session = session();
        return $session->get('user_id');
    }

    private function getJsonBody(): array
    {
        $data = $this->request->getJSON(true);
        if (is_array($data)) return $data;
        $post = $this->request->getPost();
        return is_array($post) ? $post : [];
    }

    private function computePermission(array $task, array $approval, int $userId): array
    {
        if (($approval['status'] ?? '') !== 'pending' || (int)$approval['level'] !== (int)$task['current_level']) {
            return [false, false, 'Không ở cấp đang chờ duyệt'];
        }
        $isApprover = $this->userIsApproverOfLevel((int)$task['id'], (int)$task['current_level'], $userId);
        if (!$isApprover) {
            return [false, false, 'Bạn không nằm trong danh sách phê duyệt cấp này'];
        }
        return [true, true, null];
    }

    private function userIsApproverOfLevel(int $taskId, int $level, int $userId): bool
    {
        return true;
    }

    private function computeProgress(?int $currentLevel, int $total, string $status): int
    {
        if ($total <= 0) return 0;
        if ($status === 'approved') return 100;
        if ($status === 'rejected') return (int) round((($currentLevel - 1) / $total) * 100);
        $done = max(0, min($currentLevel - 1, $total));
        return (int) round(($done / $total) * 100);
    }

    private function getRoleId(): ?int
    {
        $session = session();
        $rid = $session->get('role_id');
        if (!empty($rid)) return (int) $rid;

        $uid = $session->get('user_id');
        if (empty($uid)) return null;

        $db  = db_connect();
        $row = $db->table('users')->select('role_id')->where('id', (int)$uid)->get()->getRowArray();
        if ($row && isset($row['role_id'])) {
            $session->set('role_id', (int)$row['role_id']);
            return (int)$row['role_id'];
        }
        return null;
    }

    private function canViewApprovalList(): bool
    {
        $roleId = $this->getRoleId();
        if (in_array((int)$roleId, [1, 2], true)) return true;

        $session   = session();
        $roleName  = strtolower((string)$session->get('role_name') ?: (string)$session->get('role'));
        if (in_array($roleName, ['super admin', 'admin'], true)) return true;

        return false;
    }

    /* ========= New helpers cho ROSTER (chip duyệt/ký) ========= */

    /** Lấy task row */
    private function getTaskRow(int $taskId): ?array
    {
        $db = db_connect();
        return $db->table('tasks')->where('id', $taskId)->get()->getRowArray();
    }

    /** Đọc roster từ task.approval_roster_json → array */
    private function readRoster(array $taskRow): array
    {
        $json = $taskRow['approval_roster_json'] ?? '[]';
        $arr  = is_string($json) ? json_decode($json, true) : $json;
        return is_array($arr) ? $arr : [];
    }

    /** Ghi roster vào task.approval_roster_json */
    private function writeRoster(int $taskId, array $roster): void
    {
        $db = db_connect();
        $db->table('tasks')->where('id', $taskId)->update([
            'approval_roster_json' => json_encode(array_values($roster), JSON_UNESCAPED_UNICODE),
        ]);
    }

    /** Chuẩn hoá 1 mention (FE gửi) */
    private function normalizeMention(array $m): ?array
    {
        $uid  = (int)($m['user_id'] ?? 0);
        $name = trim((string)($m['name'] ?? ''));
        $role = strtolower((string)($m['role'] ?? 'approve'));
        if ($uid <= 0) return null;
        if (!in_array($role, ['approve', 'sign'], true)) $role = 'approve';

        $status = 'pending';
        if (true) {
            $in = strtolower((string)($m['status'] ?? ''));
            if (in_array($in, ['pending','approved','rejected'], true)) {
                $status = $in;
            }
        }

        // nếu có status=approved|rejected mà chưa có acted_at thì thêm
        $actedAt = null;
        if (in_array($status, ['approved','rejected'], true)) {
            $actedAt = $m['acted_at'] ?? date('Y-m-d H:i:s');
        }

        return [
            'user_id'  => $uid,
            'name'     => $name ?: ("#" . $uid),
            'role'     => $role,
            'status'   => $status,
            'acted_at' => $actedAt,
            'note'     => $m['note'] ?? null,
        ];
    }


    /** Tính % tiến độ theo roster (tổng approved / tổng thành viên) */
    private function computeRosterProgress(array $roster, string $taskApprovalStatus): int
    {
        if (empty($roster)) {
            return $taskApprovalStatus === 'approved' ? 100 : 0;
        }
        if ($taskApprovalStatus === 'approved') return 100;

        $total = count($roster);
        $done  = 0;
        foreach ($roster as $r) {
            if (($r['status'] ?? '') === 'approved') $done++;
        }
        return (int) round(($done / max(1, $total)) * 100);
    }

    /** Kiểm tra quyền: user có trong roster và còn pending */
    private function canUserActOnRoster(array $roster, int $userId): array
    {
        $foundIdx = null;
        foreach ($roster as $idx => $r) {
            if ((int)$r['user_id'] === $userId) {
                $foundIdx = $idx;
                $st = (string)($r['status'] ?? 'pending');
                if ($st !== 'pending') return [false, $idx, 'Bạn đã xử lý rồi'];
                return [true, $idx, null];
            }
        }
        // Có người khác đang pending?
        $someonePending = array_filter($roster, fn($r) => ($r['status'] ?? 'pending') === 'pending');
        if ($someonePending) return [false, null, 'Đây là lượt của người khác'];
        return [false, null, 'Bạn không nằm trong danh sách duyệt/ký'];
    }


    private function computeProgressByApprovedCount(int $approvedCount, int $total, string $taskApprovalStatus): int
    {
        if ($total <= 0) return 0;
        if ($taskApprovalStatus === 'approved') return 100;
        $approvedCount = max(0, min($approvedCount, $total));
        return (int) round(($approvedCount / $total) * 100);
    }

    private function computeProgressSmart(int $taskId, int $stepsTotal, string $taskApprStatus): int
    {
        if ($stepsTotal <= 0) return 0;
        if ($taskApprStatus === 'approved') return 100;
        if ($taskApprStatus === 'rejected') return 0;

        $db = db_connect();
        $approvedCount = $db->table('task_approval_logs')
            ->where('task_id', $taskId)
            ->where('status', 'approved')
            ->countAllResults();

        return (int) round(($approvedCount / $stepsTotal) * 100);
    }

    /* ============================
     * API (giữ + bổ sung)
     * ============================ */

    /** Danh sách duyệt theo tab: pending | resolved (giữ nguyên, có tối ưu) */
    public function index()
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }
        if (!$this->canViewApprovalList()) {
            return $this->failForbidden('Bạn không có quyền xem danh sách duyệt');
        }

        $userId = $this->getUserId();
        $model  = new TaskApprovalModel();

        $status = $this->request->getGet('status') ?? 'pending';
        $search = $this->request->getGet('search');
        $page   = (int)($this->request->getGet('page') ?? 1);
        $limit  = (int)($this->request->getGet('limit') ?? 10);

        $builder = $model
            ->select('task_approvals.*, 
                  tasks.title, 
                  tasks.current_level, 
                  tasks.approval_steps, 
                  tasks.approval_status AS task_approval_status, 
                  u_assigned.name AS assigned_to_name, 
                  u_approver.name AS approved_by_name')
            ->join('tasks', 'tasks.id = task_approvals.task_id')
            ->join('users u_assigned', 'u_assigned.id = tasks.assigned_to', 'left')
            ->join('users u_approver', 'u_approver.id = task_approvals.approved_by', 'left');

        if ($status === 'pending') {
            $builder->where('task_approvals.status', 'pending')
                ->where('tasks.current_level = task_approvals.level');
        } else {
            $builder->where('task_approvals.status !=', 'pending')
                ->orderBy('task_approvals.approved_at', 'DESC');
        }

        if ($search) {
            $builder->like('tasks.title', $search);
        }

        $rows  = $builder->paginate($limit, 'default', $page);
        $total = $model->pager->getTotal();

        $taskIds = array_values(array_unique(array_map(fn($r) => (int)$r['task_id'], $rows ?: [])));
        $approvedMap = [];

        if (!empty($taskIds)) {
            $db = db_connect();
            $approvedRows = $db->table('task_approval_logs')
                ->select('task_id, COUNT(DISTINCT level) AS approved_levels')
                ->whereIn('task_id', $taskIds)
                ->where('status', 'approved')
                ->groupBy('task_id')
                ->get()
                ->getResultArray();

            foreach ($approvedRows as $ar) {
                $approvedMap[(int)$ar['task_id']] = (int)$ar['approved_levels'];
            }
        }

        $data = array_map(function ($r) use ($approvedMap) {
            $stepsTotal     = (int)($r['approval_steps'] ?? 0);
            $currentLevel   = (int)($r['current_level'] ?? 0);
            $rowStatus      = (string)($r['status'] ?? '');
            $taskApprStatus = (string)($r['task_approval_status'] ?? '');
            $taskId         = (int)$r['task_id'];

            $approvedCount = $approvedMap[$taskId] ?? 0;
            $progress = $this->computeProgressByApprovedCount($approvedCount, $stepsTotal, $taskApprStatus);
            $can      = ($rowStatus === 'pending' && (int)$r['level'] === $currentLevel);

            return array_merge($r, [
                'approved_levels'       => $approvedCount,
                'approval_steps_total'  => $stepsTotal,
                'approval_progress'     => $progress,
                'is_final_level'        => ($taskApprStatus === 'approved' || $approvedCount >= $stepsTotal),
                'can_approve'           => $can,
                'can_reject'            => $can,
                'cannot_reason'         => $can ? null : 'Không ở cấp đang chờ duyệt',
            ]);
        }, $rows ?? []);

        return $this->respond([
            'status'     => 'success',
            'data'       => $data,
            'total'      => $total,
            'pagination' => [
                'page'      => $page,
                'limit'     => $limit,
                'last_page' => (int)ceil($total / max(1, $limit)),
            ],
        ]);
    }

    /** Kiểm tra quyền trước khi mở modal duyệt/từ chối theo cấp */
    public function canAct($id): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) return $this->failUnauthorized('Bạn chưa đăng nhập');

        $userId    = $this->getUserId();
        $model     = new TaskApprovalModel();
        $taskModel = new TaskModel();

        $approval = $model->find($id);
        if (!$approval) return $this->failNotFound('Approval not found');

        $task = $taskModel->find($approval['task_id']);
        if (!$task) return $this->failNotFound('Task not found');

        [$canApprove, $canReject, $reason] = $this->computePermission($task, $approval, (int)$userId);

        return $this->respond([
            'can_approve'    => $canApprove,
            'can_reject'     => $canReject,
            'cannot_reason'  => $reason,
            'is_final_level' => ((int)$task['current_level'] === (int)$task['approval_steps']),
        ]);
    }

    /** Phê duyệt theo cấp (giữ nguyên)
     * @throws ReflectionException
     */
    public function approve($id): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) return $this->failUnauthorized('Bạn chưa đăng nhập');

        $userId    = (int)$this->getUserId();
        $model     = new TaskApprovalModel();
        $taskModel = new TaskModel();

        $approval = $model->find($id);
        if (!$approval) return $this->failNotFound('Approval not found');

        if (($approval['status'] ?? '') !== 'pending') {
            return $this->failResourceExists('Bản ghi đã được xử lý trước đó');
        }

        $task = $taskModel->find($approval['task_id']);
        if (!$task) return $this->failNotFound('Task not found');

        [$canApprove,, $reason] = $this->computePermission($task, $approval, $userId);
        if (!$canApprove) return $this->failForbidden($reason ?? 'Không có quyền duyệt');

        $payload = $this->getJsonBody();
        $comment = $payload['comment'] ?? null;

        $db = db_connect();
        $db->transStart();

        $model->update($id, [
            'status'      => 'approved',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        $db->table('task_approval_logs')->insert([
            'task_id'     => $approval['task_id'],
            'level'       => $approval['level'],
            'status'      => 'approved',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        $currentLevel  = (int)$approval['level'];
        $approvalSteps = (int)($task['approval_steps'] ?? 0);

        if ($approvalSteps <= 0 || $currentLevel >= $approvalSteps) {
            $taskModel->update($task['id'], [
                'approval_status' => 'approved',
                'status'          => TaskStatus::DONE,
                'progress'        => 100,
                'current_level'   => $approvalSteps,
            ]);
        } else {
            $model->insert([
                'task_id'    => $task['id'],
                'level'      => $currentLevel + 1,
                'status'     => 'pending',
            ]);

            $progress = (int) round(($currentLevel / max(1, $approvalSteps)) * 100);
            $taskModel->update($task['id'], [
                'current_level' => $currentLevel + 1,
                'progress'      => $progress
            ]);
        }

        $db->transComplete();
        if (!$db->transStatus()) return $this->fail('Không thể cập nhật duyệt');

        return $this->respond(['message' => 'Approved successfully']);
    }

    /** Từ chối theo cấp (giữ nguyên)
     * @throws ReflectionException
     */
    public function reject($id): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) return $this->failUnauthorized('Bạn chưa đăng nhập');

        $userId    = (int)$this->getUserId();
        $model     = new TaskApprovalModel();
        $taskModel = new TaskModel();

        $approval = $model->find($id);
        if (!$approval) return $this->failNotFound('Approval not found');

        if (($approval['status'] ?? '') !== 'pending') {
            return $this->failResourceExists('Bản ghi đã được xử lý trước đó');
        }

        $task = $taskModel->find($approval['task_id']);
        if (!$task) return $this->failNotFound('Task not found');

        [,$canReject, $reason] = $this->computePermission($task, $approval, $userId);
        if (!$canReject) return $this->failForbidden($reason ?? 'Không có quyền từ chối');

        $payload = $this->getJsonBody();
        $comment = $payload['comment'] ?? null;

        $db = db_connect();
        $db->transStart();

        $model->update($id, [
            'status'      => 'rejected',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        $db->table('task_approval_logs')->insert([
            'task_id'     => $approval['task_id'],
            'level'       => $approval['level'],
            'status'      => 'rejected',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        $taskModel->update($approval['task_id'], [
            'approval_status' => 'rejected',
            'status'          => TaskStatus::TODO
        ]);

        $db->transComplete();
        if (!$db->transStatus()) return $this->fail('Không thể cập nhật từ chối');

        return $this->respond(['message' => 'Rejected successfully']);
    }

    /** Lịch sử theo cấp (giữ nguyên) */
    public function history($taskId): ResponseInterface
    {
        $logModel = new TaskApprovalLogModel();

        $logs = $logModel
            ->select('task_approval_logs.*, users.name AS approved_by_name')
            ->join('users', 'users.id = task_approval_logs.approved_by', 'left')
            ->where('task_approval_logs.task_id', $taskId)
            ->orderBy('task_approval_logs.level ASC, task_approval_logs.approved_at ASC')
            ->findAll();

        return $this->respond($logs);
    }

    /** Timeline theo cấp (giữ nguyên) */
    public function fullApprovalStatus($taskId): ResponseInterface
    {
        $db = db_connect();

        $task = $db->table('tasks')->where('id', $taskId)->get()->getRowArray();
        if (!$task) return $this->failNotFound('Task not found');

        $approvalSteps = (int) $task['approval_steps'];
        $currentLevel  = (int) $task['current_level'];

        $logs = $db->table('task_approval_logs as l')
            ->select('l.level, l.status, l.approved_at, u.name AS approved_by_name, l.comment')
            ->join('users u', 'u.id = l.approved_by', 'left')
            ->where('l.task_id', $taskId)
            ->orderBy('l.level ASC')
            ->get()
            ->getResultArray();

        $result = [];
        for ($i = 1; $i <= $approvalSteps; $i++) {
            $log = null;
            foreach ($logs as $item) {
                if ((int)$item['level'] === $i) { $log = $item; break; }
            }

            $row = [
                'level'            => $i,
                'status'           => 'waiting',
                'is_current_level' => false,
                'approved_by_name' => null,
                'approved_at'      => null,
                'comment'          => null,
            ];

            if ($log) {
                $row['status']           = $log['status'];
                $row['approved_by_name'] = $log['approved_by_name'];
                $row['approved_at']      = $log['approved_at'];
                $row['comment']          = $log['comment'];
            } elseif ($i === $currentLevel) {
                $row['status']           = 'pending';
                $row['is_current_level'] = true;
            }

            $result[] = $row;
        }

        return $this->respond($result);
    }

    /** Duyệt theo task: tìm approval pending đúng cấp rồi gọi approve($approvalId) (giữ nguyên)
     * @throws ReflectionException
     */
    public function approveByTask($taskId): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) return $this->failUnauthorized('Bạn chưa đăng nhập');

        $taskId = (int) $taskId;
        $db   = db_connect();
        $row  = $db->table('task_approvals ta')
            ->select('ta.id AS approval_id, ta.level, t.current_level')
            ->join('tasks t', 't.id = ta.task_id', 'inner')
            ->where('ta.task_id', $taskId)
            ->where('ta.status', 'pending')
            ->where('ta.level = t.current_level')
            ->get()->getRowArray();

        if (!$row) return $this->failNotFound('Không tìm thấy cấp duyệt đang chờ cho task này');
        return $this->approve((int)$row['approval_id']);
    }

    /** Từ chối theo task (giữ nguyên)
     * @throws ReflectionException
     */
    public function rejectByTask($taskId): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) return $this->failUnauthorized('Bạn chưa đăng nhập');

        $taskId = (int) $taskId;
        $db     = db_connect();

        $row  = $db->table('task_approvals ta')
            ->select('ta.id AS approval_id, ta.level, t.current_level')
            ->join('tasks t', 't.id = ta.task_id', 'inner')
            ->where('ta.task_id', $taskId)
            ->where('ta.status', 'pending')
            ->where('ta.level = t.current_level')
            ->get()->getRowArray();

        if (!$row) return $this->failNotFound('Không tìm thấy cấp duyệt đang chờ cho task này');
        return $this->reject((int)$row['approval_id']);
    }

    /** GET /tasks/{id}/roster: trả roster + progress tính theo roster */
    public function roster($taskId): ResponseInterface
    {
        $taskId = (int)$taskId;
        $task   = $this->getTaskRow($taskId);
        if (!$task) return $this->failNotFound('Task not found');

        $db = db_connect();

        /** ===========================
         * Lấy ROSTER như cũ
         * =========================== */
        $roster = $this->readRoster($task) ?: [];

        $total = count($roster);
        $approvedCount = 0;

        foreach ($roster as $r) {
            if (strtolower((string)($r['status'] ?? '')) === 'approved') {
                $approvedCount++;
            }
        }

        $approvedPercent = $total > 0 ? (int) round(($approvedCount / $total) * 100) : 0;
        $progress_legacy = $this->computeRosterProgress($roster, (string)($task['approval_status'] ?? 'pending'));
        $progress        = $approvedPercent;
        $hasRoster       = $total > 0;
        $allApproved     = $hasRoster && ($approvedCount === $total);

        $approved_at = null;
        if ($allApproved) {
            $actedList = array_map(fn($r) => $r['acted_at'] ?? null, $roster);
            $approved_at = $this->safeMaxDate($actedList);
        }

        /** ===========================
         * NEW: Lấy upload_batch mới nhất
         * =========================== */
        $latestBatchRow = $db->table('documents')
            ->select('upload_batch')
            ->where('source_task_id', $taskId)
            ->orderBy('upload_batch', 'DESC')
            ->limit(1)
            ->get()
            ->getRowArray();

        $latestBatch = $latestBatchRow['upload_batch'] ?? null;

        /** ===========================
         * NEW: Lấy danh sách file của batch mới nhất
         * =========================== */
        $latestFiles = [];
        if ($latestBatch !== null) {
            $latestFiles = $db->table('documents')
                ->select('id, title AS file_name, file_path, doc_type, upload_batch, file_size, comment_id, uploaded_by, created_at')
                ->where('source_task_id', $taskId)
                ->where('upload_batch', $latestBatch)
                ->orderBy('id', 'ASC')
                ->get()
                ->getResultArray();
        }

        /** ===========================
         * Created by info
         * =========================== */
        $createdById   = isset($task['created_by']) ? (int)$task['created_by'] : null;
        $createdByName = null;

        if ($createdById) {
            $row = $db->table('users')->select('name')->where('id', $createdById)->get()->getRowArray();
            $createdByName = $row['name'] ?? null;
        }

        return $this->respond([
            'roster'            => $this->addHumanDatesToRoster($roster),
            'roster_total'      => $total,
            'approved_count'    => $approvedCount,
            'approved_percent'  => $approvedPercent,
            'progress'          => $progress,
            'progress_legacy'   => $progress_legacy,
            'all_approved'      => $allApproved,
            'approved_at'       => $approved_at,
            'approved_at_vi'    => $approved_at ? date('H:i d/m/Y', strtotime($approved_at)) : null,
            'created_by'        => $createdById,
            'created_by_name'   => $createdByName,

            /** ⭐ THÊM 2 TRƯỜNG MỚI ⭐ */
            'latest_upload_batch' => $latestBatch,
            'latest_files'        => $latestFiles,
        ]);
    }


    /** POST /tasks/{id}/roster/merge: body: mentions(json|form) */
    public function merge($taskId): ResponseInterface
    {
        $taskId = (int)$taskId;
        $task   = $this->getTaskRow($taskId);
        if (!$task) return $this->failNotFound('Task not found');

        $json     = $this->getJsonBody() ?? [];
        $rawMent  = $this->request->getPost('mentions') ?? ($json['mentions'] ?? '[]');
        $rawMode  = $this->request->getPost('mode')     ?? ($json['mode'] ?? 'merge');

        $mentions = is_string($rawMent) ? json_decode($rawMent, true) : $rawMent;
        if (!is_array($mentions)) $mentions = [];
        $mode = strtolower((string)$rawMode);
        if (!in_array($mode, ['merge', 'replace'], true)) $mode = 'merge';

        // ✅ Lấy roster cũ
        $oldRoster = $this->readRoster($task);
        $oldMap = [];
        foreach ($oldRoster as $r) $oldMap[(int)$r['user_id']] = $r;

        $newList = [];

        if ($mode === 'replace') {
            foreach ($mentions as $m) {
                $nm = $this->normalizeMention($m);
                if (!$nm) continue;
                $uid = (int)$nm['user_id'];

                if (isset($oldMap[$uid])) {
                    $old = $oldMap[$uid];
                    // giữ status/acted_at/note/added_at
                    if (empty($m['status'])) {
                        $nm['status']   = $old['status']   ?? 'pending';
                        $nm['acted_at'] = $old['acted_at'] ?? null;
                        $nm['note']     = $old['note']     ?? null;
                        $nm['added_at'] = date('Y-m-d H:i:s'); // 👈 thêm
                    }
                    $nm['added_at'] = $old['added_at'] ?? ($old['created_at'] ?? null);
                } else {
                    // người mới
                    if (empty($m['status'])) {
                        $nm['added_at'] = date('Y-m-d H:i:s'); // 👈 thêm
                        $nm['status']   = 'pending';
                        $nm['acted_at'] = null;
                    }
                    $nm['added_at'] = date('Y-m-d H:i:s');
                }
                $newList[] = $nm;
            }
        } else { // MERGE
            $map = $oldMap;
            foreach ($mentions as $m) {
                $nm  = $this->normalizeMention($m);
                if (!$nm) continue;
                $uid = (int)$nm['user_id'];

                if (!isset($map[$uid])) {
                    $nm['added_at'] = date('Y-m-d H:i:s');   // 👈 người mới
                    $map[$uid] = $nm;
                } else {
                    $old = $map[$uid];
                    // cập nhật name/role, giữ các field khác
                    $old['name'] = $nm['name'];
                    $old['role'] = $nm['role'];
                    // chống “trôi” key (giữ old):
                    $map[$uid] = $old + $nm;
                }
            }
            $newList = array_values($map);
        }

        // lưu + respond humanized
        $this->writeRoster($taskId, $newList);
        $progress = $this->computeRosterProgress($newList, (string)($task['approval_status'] ?? 'pending'));
        return $this->respond([
            'message'  => 'OK',
            'roster'   => $this->addHumanDatesToRoster($newList), // 👈
            'progress' => $progress,
        ]);
    }



    private function addHumanDatesToRoster(array $roster): array
    {
        foreach ($roster as &$r) {
            $dt = $r['acted_at'] ?? null;
            if ($dt) {
                $r['acted_at_vi']   = date('H:i d/m/Y', strtotime($dt));
                $r['acted_date_vi'] = date('d/m/Y', strtotime($dt));
                $r['acted_at_iso']  = date('c', strtotime($dt));
            } else {
                $r['acted_at_vi'] = $r['acted_date_vi'] = $r['acted_at_iso'] = null;
            }

            $ad = $r['added_at'] ?? null;
            if ($ad) {
                $r['added_at_vi']   = date('H:i d/m/Y', strtotime($ad));
                $r['added_at_iso']  = date('c', strtotime($ad));
            } else {
                $r['added_at_vi'] = $r['added_at_iso'] = null;
            }
        }
        return $roster;
    }


    /** Lấy thời điểm lớn nhất từ danh sách datetime string an toàn */
    private function safeMaxDate(array $dates): ?string
    {
        $ts = [];
        foreach ($dates as $d) {
            if (!$d) continue;
            $t = strtotime((string)$d);
            if ($t !== false) $ts[] = $t;
        }
        if (empty($ts)) return null;
        return date('Y-m-d H:i:s', max($ts));
    }





    // ========== ADD: helper dùng chung cho approve/reject roster ==========
    /**
     * Thực hiện hành động trên roster cho user hiện tại.
     * $finalStatus: 'approved' | 'rejected'
     */
    private function actOnRoster(int $taskId, string $finalStatus): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        if (!in_array($finalStatus, ['approved', 'rejected'], true)) {
            return $this->failValidationErrors('Trạng thái không hợp lệ');
        }

        $task   = $this->getTaskRow($taskId);
        if (!$task) return $this->failNotFound('Task not found');

        $uid    = (int)$this->getUserId();
        $roster = $this->readRoster($task);

        // Quyền & vị trí trong roster
        [$can, $idx, $reason] = $this->canUserActOnRoster($roster, $uid);
        if (!$can) return $this->failForbidden($reason ?? 'Không thể thực hiện');

        // Cập nhật member
        $payload = $this->getJsonBody();
        $note = $payload['note'] ?? null;
        if (is_array($note)) {
            $note = json_encode($note, JSON_UNESCAPED_UNICODE);
        }
        $roster[$idx]['status']   = $finalStatus;
        $roster[$idx]['acted_at'] = date('Y-m-d H:i:s');
        if ($note !== null && $note !== '') {
            $roster[$idx]['note'] = (string) $note;
        }


        // Lưu roster
        $this->writeRoster($taskId, $roster);

        if ($finalStatus === 'rejected') {
            $taskUpd = [
                'approval_status' => 'rejected',
                'status'          => TaskStatus::TODO,
                'progress'        => $this->computeRosterProgress($roster, 'rejected'),
            ];
        } else {
            $allApproved = !array_filter($roster, fn($r) => ($r['status'] ?? 'pending') !== 'approved');
            $taskUpd['approved_at'] = date('Y-m-d H:i:s'); // thêm cột approved_at vào bảng tasks nếu thấy hữu ích
            $taskUpd = [
                'progress'     => $this->computeRosterProgress($roster, (string)($task['approval_status'] ?? 'pending')),
                'approved_at'  => date('Y-m-d H:i:s'),
            ];
            if ($allApproved) {
                $taskUpd['approval_status'] = 'approved';
                $taskUpd['status']          = TaskStatus::DONE;
                $taskUpd['progress']        = 100;
            }
        }

        $roster = $this->addHumanDatesToRoster($roster);


        if ($taskUpd) {
            db_connect()->table('tasks')->where('id', $taskId)->update($taskUpd);
        }

        return $this->respond([
            'message'     => $finalStatus === 'approved' ? 'Approved' : 'Rejected',
            'roster'      => $roster,
            'task_update' => $taskUpd,
        ]);
    }


    /** POST /tasks/{id}/roster/approve: current user approve/sign */
    // ========== REPLACE: rosterApprove ==========
    public function rosterApprove($taskId): ResponseInterface
    {
        return $this->actOnRoster((int)$taskId, 'approved');
    }

    // ========== REPLACE: rosterReject ==========
    public function rosterReject($taskId): ResponseInterface
    {
        return $this->actOnRoster((int)$taskId, 'rejected');
    }

}
