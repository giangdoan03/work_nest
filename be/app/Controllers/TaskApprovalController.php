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
     * Helpers
     * ============================ */

    private function getUserId(): ?int
    {
        $session = session();
        return $session->get('user_id');
    }

    /** Đọc payload JSON an toàn (fallback về POST) */
    private function getJsonBody(): array
    {
        $data = $this->request->getJSON(true);
        if (is_array($data)) return $data;
        $post = $this->request->getPost();
        return is_array($post) ? $post : [];
    }

    /** Tính quyền cơ bản: đúng cấp đang chờ + (tuỳ chọn) nằm trong danh sách approver */
    private function computePermission(array $task, array $approval, int $userId): array
    {
        // Phải là bản ghi pending và đúng current_level của task
        if (($approval['status'] ?? '') !== 'pending' || (int)$approval['level'] !== (int)$task['current_level']) {
            return [false, false, 'Không ở cấp đang chờ duyệt'];
        }

        // TODO: Nếu có bảng task_approvers thì kiểm tra thật ở đây
        $isApprover = $this->userIsApproverOfLevel((int)$task['id'], (int)$task['current_level'], $userId);
        if (!$isApprover) {
            return [false, false, 'Bạn không nằm trong danh sách phê duyệt cấp này'];
        }

        return [true, true, null];
    }

    /** Placeholder: hiện cho phép (trả true). Khi có bảng task_approvers hãy thay bằng query thật. */
    private function userIsApproverOfLevel(int $taskId, int $level, int $userId): bool
    {
        return true;
    }

    /** Tiến độ theo cấp (đơn giản): số cấp đã khóa / tổng cấp */
    private function computeProgress(?int $currentLevel, int $total, string $status): int
    {
        if ($total <= 0) return 0;

        // Nếu đã duyệt xong toàn bộ
        if ($status === 'approved') {
            return 100;
        }

        // Nếu bị từ chối => tuỳ nghiệp vụ, có thể 0% hoặc tính đến cấp đã xong
        if ($status === 'rejected') {
            return (int) round((($currentLevel - 1) / $total) * 100);
        }

        // Trạng thái pending (đang ở cấp nào đó)
        $done = max(0, min($currentLevel - 1, $total));
        return (int) round(($done / $total) * 100);
    }



    // ===== Helpers thêm trong class =====
    private function getRoleId(): ?int
    {
        $session = session();
        $rid = $session->get('role_id');
        if (!empty($rid)) {
            return (int) $rid;
        }

        // Fallback: lấy từ DB theo user_id, rồi cache lại vào session
        $uid = $session->get('user_id');
        if (empty($uid)) {
            return null;
        }

        $db  = db_connect();
        $row = $db->table('users')->select('role_id')->where('id', (int)$uid)->get()->getRowArray();
        if ($row && isset($row['role_id'])) {
            $session->set('role_id', (int)$row['role_id']); // cache vào session để lần sau không phải query
            return (int)$row['role_id'];
        }

        return null;
    }

    private function canViewApprovalList(): bool
    {
        $roleId = $this->getRoleId();
        if (in_array((int)$roleId, [1, 2], true)) {
            return true; // 1: super admin, 2: admin
        }

        // Fallback theo tên (nếu bạn set role_name vào session)
        $session   = session();
        $roleName  = strtolower((string)$session->get('role_name') ?: (string)$session->get('role'));
        if (in_array($roleName, ['super admin', 'admin'], true)) {
            return true;
        }

        return false;
    }

    /* ============================
     * API
     * ============================ */

    /** Danh sách duyệt theo tab: pending | resolved */
    // ===== Thay thế toàn bộ hàm index() bằng phiên bản này =====
    public function index()
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        // ✅ Chỉ role 1,2 được xem danh sách duyệt
        if (!$this->canViewApprovalList()) {
            return $this->failForbidden('Bạn không có quyền xem danh sách duyệt');
        }

        $userId = $this->getUserId();
        $model  = new TaskApprovalModel();

        $status = $this->request->getGet('status') ?? 'pending';
        $search = $this->request->getGet('search');
        $page   = (int)($this->request->getGet('page') ?? 1);
        $limit  = (int)($this->request->getGet('limit') ?? 10);

        // Select thêm approval_status để biết đã hoàn tất duyệt chưa
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
            // Tất cả bản ghi đang chờ ở cấp hiện tại
            $builder->where('task_approvals.status', 'pending')
                ->where('tasks.current_level = task_approvals.level');
            // Nếu cần lọc theo approver hiện tại cho user thường, join bảng approvers tại đây.
        } else {
            // Đã duyệt / Từ chối
            $builder->where('task_approvals.status !=', 'pending')
                ->orderBy('task_approvals.approved_at', 'DESC');
        }

        if ($search) {
            $builder->like('tasks.title', $search);
        }

        // Lấy trang dữ liệu
        $rows  = $builder->paginate($limit, 'default', $page);
        $total = $model->pager->getTotal();

        // ===== Tính số cấp đã duyệt thật (batch) để suy ra % =====
        $taskIds = array_values(array_unique(array_map(fn($r) => (int)$r['task_id'], $rows ?: [])));
        $approvedMap = []; // task_id => số cấp đã approved

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

        // Map dữ liệu trả về FE
        $data = array_map(function ($r) use ($approvedMap) {
            $stepsTotal     = (int)($r['approval_steps'] ?? 0);
            $currentLevel   = (int)($r['current_level'] ?? 0);
            $rowStatus      = (string)($r['status'] ?? '');               // pending/approved/rejected (record hiện tại)
            $taskApprStatus = (string)($r['task_approval_status'] ?? ''); // pending/approved/rejected (toàn task)
            $taskId         = (int)$r['task_id'];

            $approvedCount = $approvedMap[$taskId] ?? 0;

            // ✅ TIẾN ĐỘ = số cấp đã duyệt thật / tổng cấp (ép 100% nếu task đã approved)
            $progress = $this->computeProgressByApprovedCount($approvedCount, $stepsTotal, $taskApprStatus);

            // Nút hành động chỉ bật khi đúng cấp đang chờ
            $can = ($rowStatus === 'pending' && (int)$r['level'] === $currentLevel);

            return array_merge($r, [
                'approved_levels'       => $approvedCount,                          // optional cho FE
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


    private function computeProgressByApprovedCount(int $approvedCount, int $total, string $taskApprovalStatus): int
    {
        if ($total <= 0) return 0;
        if ($taskApprovalStatus === 'approved') return 100;

        $approvedCount = max(0, min($approvedCount, $total));
        return (int) round(($approvedCount / $total) * 100);
    }



// đặt trong class TaskApprovalController (phần Helpers)
    private function computeProgressSmart(int $taskId, int $stepsTotal, string $taskApprStatus): int
    {
        if ($stepsTotal <= 0) return 0;

        // Nếu task đã approved → 100%
        if ($taskApprStatus === 'approved') {
            return 100;
        }
        if ($taskApprStatus === 'rejected') {
            return 0; // hoặc để riêng
        }

        // Đếm số cấp đã duyệt từ logs
        $db = db_connect();
        $approvedCount = $db->table('task_approval_logs')
            ->where('task_id', $taskId)
            ->where('status', 'approved')
            ->countAllResults();

        return (int) round(($approvedCount / $stepsTotal) * 100);
    }



    /** Kiểm tra quyền trước khi mở modal duyệt/từ chối */
    public function canAct($id): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

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

    /** Phê duyệt
     * @throws ReflectionException
     */
    public function approve($id): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        $userId    = (int)$this->getUserId();
        $model     = new TaskApprovalModel();
        $taskModel = new TaskModel();

        $approval = $model->find($id);
        if (!$approval) return $this->failNotFound('Approval not found');

        // Idempotency: đã xử lý rồi thì từ chối
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

        // Cập nhật record hiện tại
        $model->update($id, [
            'status'      => 'approved',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        // Ghi log
        $db->table('task_approval_logs')->insert([
            'task_id'     => $approval['task_id'],
            'level'       => $approval['level'],
            'status'      => 'approved',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        // Chuyển cấp / Hoàn tất
        $currentLevel  = (int)$approval['level'];
        $approvalSteps = (int)($task['approval_steps'] ?? 0);

        if ($approvalSteps <= 0 || $currentLevel >= $approvalSteps) {
            // Cấp cuối
            $taskModel->update($task['id'], [
                'approval_status' => 'approved',
                'status'          => TaskStatus::DONE,
                'progress'        => 100,
                'current_level'   => $approvalSteps,
            ]);
        } else {
            // Tạo cấp kế tiếp
            $model->insert([
                'task_id'    => $task['id'],
                'level'      => $currentLevel + 1,
                'status'     => 'pending',
                // 'started_at' => date('Y-m-d H:i:s'), // nếu có cột
            ]);

            // Cập nhật task: tăng current_level + progress theo cấp
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

    /** Từ chối
     * @throws ReflectionException
     */
    public function reject($id): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

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

        // Update record
        $model->update($id, [
            'status'      => 'rejected',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        // Log
        $db->table('task_approval_logs')->insert([
            'task_id'     => $approval['task_id'],
            'level'       => $approval['level'],
            'status'      => 'rejected',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        // Cập nhật task khi bị từ chối (tuỳ nghiệp vụ)
        $taskModel->update($approval['task_id'], [
            'approval_status' => 'rejected',
            'status'          => TaskStatus::TODO
        ]);

        $db->transComplete();
        if (!$db->transStatus()) return $this->fail('Không thể cập nhật từ chối');

        return $this->respond(['message' => 'Rejected successfully']);
    }

    /** Lịch sử đã duyệt (log) */
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

    /** Trạng thái duyệt đầy đủ theo từng cấp (timeline) */
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
                // Có thể thêm: 'approvers' => [], 'rule_type' => 'any_one', 'started_at' => null, 'due_at' => null
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

    public function approveByTask($taskId): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) return $this->failUnauthorized('Bạn chưa đăng nhập');

        $taskId = (int) $taskId;
        $model  = new TaskApprovalModel();

        // Tìm bản ghi approval PENDING đúng cấp hiện tại của task
        $db   = db_connect();
        $row  = $db->table('task_approvals ta')
            ->select('ta.id AS approval_id, ta.level, t.current_level')
            ->join('tasks t', 't.id = ta.task_id', 'inner')
            ->where('ta.task_id', $taskId)
            ->where('ta.status', 'pending')
            ->where('ta.level = t.current_level')   // đảm bảo đúng cấp đang chờ
            ->get()->getRowArray();

        if (!$row) return $this->failNotFound('Không tìm thấy cấp duyệt đang chờ cho task này');

        // Chuyển qua hàm approve($approval_id)
        return $this->approve((int)$row['approval_id']);
    }

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

}
