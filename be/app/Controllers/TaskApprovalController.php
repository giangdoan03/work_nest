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
    private function writeRoster(int $taskId, array $roster): bool
    {
        $db = db_connect();
        return $db->table('tasks')->where('id', $taskId)->update([
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
        return [
            'user_id'  => $uid,
            'name'     => $name ?: ("#" . $uid),
            'role'     => $role,
            'status'   => 'pending',   // pending | approved | rejected
            'acted_at' => null,
            'note'     => null,
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
        foreach ($roster as $idx => $r) {
            if ((int)$r['user_id'] === $userId) {
                $st = (string)($r['status'] ?? 'pending');
                if ($st !== 'pending') return [false, $idx, 'Bạn đã xử lý rồi'];
                return [true, $idx, null];
            }
        }
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

    /** Duyệt theo task: tìm approval pending đúng cấp rồi gọi approve($approvalId) (giữ nguyên) */
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

    /* ========= NEW: APIs cho ROSTER chip approve/sign ========= */

    /** GET /tasks/{id}/roster: trả roster + progress tính theo roster */
    public function roster($taskId): ResponseInterface
    {
        $taskId = (int)$taskId;
        $task   = $this->getTaskRow($taskId);
        if (!$task) return $this->failNotFound('Task not found');

        $roster   = $this->readRoster($task);
        $progress = $this->computeRosterProgress($roster, (string)($task['approval_status'] ?? 'pending'));

        return $this->respond(['roster' => $roster, 'progress' => $progress]);
    }

    /** POST /tasks/{id}/roster/merge: body: mentions(json|form) */
    public function merge($taskId): ResponseInterface
    {
        $taskId = (int)$taskId;
        $task   = $this->getTaskRow($taskId);
        if (!$task) return $this->failNotFound('Task not found');

        // Lấy mentions từ JSON hoặc form-data
        $raw = $this->request->getPost('mentions') ?? ($this->getJsonBody()['mentions'] ?? '[]');
        $mentions = is_string($raw) ? json_decode($raw, true) : $raw;
        if (!is_array($mentions)) $mentions = [];

        // Normalize & merge (dedup theo user_id, giữ status cũ nếu đã có)
        $roster = $this->readRoster($task);
        $map    = [];
        foreach ($roster as $r) $map[(int)$r['user_id']] = $r;

        foreach ($mentions as $m) {
            $nm = $this->normalizeMention($m);
            if (!$nm) continue;
            $uid = (int)$nm['user_id'];
            if (!isset($map[$uid])) {
                $map[$uid] = $nm; // thêm mới
            } else {
                // nếu đã tồn tại thì chỉ update name/role (không đè status nếu đã approved/rejected)
                $old = $map[$uid];
                $old['name'] = $nm['name'];
                $old['role'] = $nm['role'];
                $map[$uid]   = $old;
            }
        }

        $newRoster = array_values($map);
        $this->writeRoster($taskId, $newRoster);

        $progress = $this->computeRosterProgress($newRoster, (string)($task['approval_status'] ?? 'pending'));
        return $this->respond(['message' => 'OK', 'roster' => $newRoster, 'progress' => $progress]);
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
        $roster[$idx]['status']   = $finalStatus;
        $roster[$idx]['acted_at'] = date('Y-m-d H:i:s');
        if (!empty($payload['note'])) {
            $roster[$idx]['note'] = trim((string)$payload['note']);
        }

        // Lưu roster
        $this->writeRoster($taskId, $roster);

        // Tính & cập nhật trạng thái task
        $taskUpd = [];
        if ($finalStatus === 'rejected') {
            // 1 người từ chối -> task rejected
            $taskUpd = [
                'approval_status' => 'rejected',
                'status'          => \App\Enums\TaskStatus::TODO,
                'progress'        => $this->computeRosterProgress($roster, 'rejected'),
            ];
        } else { // approved
            // nếu tất cả đã approved -> DONE
            $allApproved = !array_filter($roster, fn($r) => ($r['status'] ?? 'pending') !== 'approved');
            $taskUpd = [
                'progress' => $this->computeRosterProgress($roster, (string)($task['approval_status'] ?? 'pending')),
            ];
            if ($allApproved) {
                $taskUpd['approval_status'] = 'approved';
                $taskUpd['status']          = \App\Enums\TaskStatus::DONE;
                $taskUpd['progress']        = 100;
            }
        }
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
