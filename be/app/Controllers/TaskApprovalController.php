<?php

namespace App\Controllers;

use App\Enums\TaskStatus;
use App\Libraries\GoogleDriveService;
use App\Models\TaskApprovalLogModel;
use App\Models\TaskApprovalModel;
use App\Models\TaskModel;
use App\Services\TaskSnapshotObserver;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use Config\Services;
use Google\Client;
use Google\Service\Exception;
use Google_Service_Docs;
use Google_Service_Docs_BatchUpdateDocumentRequest;
use Google_Service_Drive;
use Google_Service_Sheets;
use Google_Service_Sheets_BatchUpdateSpreadsheetRequest;
use Google_Service_Sheets_BatchUpdateValuesRequest;
use ReflectionException;
use Throwable;

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
        if ($uid <= 0) return null;

        $name = trim((string)($m['name'] ?? ''));
        $role = strtolower((string)($m['role'] ?? 'approve'));

        if (!in_array($role, ['approve', 'sign'], true)) {
            $role = 'approve';
        }

        // ---------------------------
        // Status
        // ---------------------------
        $status = 'pending';
        $in = strtolower((string)($m['status'] ?? ''));
        if (in_array($in, ['pending','approved','rejected'], true)) {
            $status = $in;
        }

        // acted_at nếu approved/rejected
        $actedAt = null;
        if (in_array($status, ['approved','rejected'], true)) {
            $actedAt = $m['acted_at'] ?? date('Y-m-d H:i:s');
        }

        // ---------------------------
        // ⭐ DEPARTMENT_ID
        // ---------------------------
        $departmentId = null;
        if (isset($m['department_id']) && is_numeric($m['department_id'])) {
            $departmentId = (int)$m['department_id'];
        }

        // ---------------------------
        // ⭐ SIGNATURE_CODE (mới)
        // ---------------------------
        $signatureCode = null;
        if (!empty($m['signature_code'])) {
            $signatureCode = trim((string)$m['signature_code']);
        }

        return [
            'user_id'         => $uid,
            'name'            => $name ?: "#$uid",
            'role'            => $role,
            'department_id'   => $departmentId,
            'signature_code'  => $signatureCode,
            'status'          => $status,
            'acted_at'        => $actedAt,
            'note'            => $m['note'] ?? null,
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
    private function canUserActOnRoster(array $roster, int $uid): array
    {
        $db = db_connect();

        // ==============================
        // LẤY ROLE ĐÚNG CÁCH
        // ==============================
        $me = $db->table('users u')
            ->select('r.code AS role_code')
            ->join('roles r', 'r.id = u.role_id', 'left')
            ->where('u.id', $uid)
            ->get()
            ->getRowArray();

        $myRole = strtolower($me['role_code'] ?? 'user');


        // ==============================
        // SUPER ADMIN → duyệt bất kỳ ai
        // ==============================
        if ($myRole === 'super_admin') {
            foreach ($roster as $i => $r) {
                if (($r['status'] ?? '') === 'pending') {
                    return [true, $i, null];
                }
            }
            return [false, null, 'Không ai đang chờ duyệt'];
        }


        // ==============================
        // ADMIN → duyệt tất cả trừ super_admin
        // ==============================
        if ($myRole === 'admin') {

            foreach ($roster as $i => $r) {
                if (($r['status'] ?? '') !== 'pending') continue;

                // Lấy role đúng của user đang xét
                $u2 = $db->table('users u')
                    ->select('r.code AS role_code')
                    ->join('roles r', 'r.id = u.role_id', 'left')
                    ->where('u.id', $r['user_id'])
                    ->get()
                    ->getRowArray();

                $targetRole = strtolower($u2['role_code'] ?? 'user');

                if ($targetRole !== 'super_admin') {
                    return [true, $i, null];
                }
            }

            return [false, null, 'Không còn ai để duyệt'];
        }


        // ==============================
        // USER → chỉ duyệt chính họ
        // ==============================
        foreach ($roster as $i => $r) {
            if ($r['user_id'] == $uid && ($r['status'] ?? '') === 'pending') {
                return [true, $i, null];
            }
        }
        return [false, null, 'Chưa đến lượt bạn'];
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
         * Lấy ROSTER
         * =========================== */
        $roster = $this->readRoster($task) ?: [];

        $total = count($roster);
        $approvedCount = 0;

        foreach ($roster as $r) {
            if (strtolower((string)($r['status'] ?? '')) === 'approved') {
                $approvedCount++;
            }
        }

        $approvedPercent = $total > 0 ? (int)round(($approvedCount / $total) * 100) : 0;
        $allApproved = ($total > 0 && $approvedCount === $total);

        $approved_at = $allApproved
            ? $this->safeMaxDate(array_column($roster, 'acted_at'))
            : null;

        /** ===========================
         * Lấy upload_batch mới nhất
         * =========================== */
        $latestBatch = $db->table('documents')
            ->select('upload_batch')
            ->where('source_task_id', $taskId)
            ->orderBy('upload_batch', 'DESC')
            ->get()
            ->getRowArray()['upload_batch'] ?? null;

        /** ===========================
         * Lấy FILE của batch mới nhất
         * =========================== */
        $latestFiles = [];

        if ($latestBatch !== null) {
            $latestFiles = $db->table('documents')
                ->select("
                id,
                title AS file_name,
                file_path,
                upload_batch,
                comment_id,
                uploaded_by,
                created_at,
                google_file_id,
                drive_id,
                file_size
            ")
                ->where('source_task_id', $taskId)
                ->where('upload_batch', $latestBatch)
                ->orderBy('id', 'ASC')
                ->get()
                ->getResultArray();
        }

        /** ===========================
         * Info người tạo
         * =========================== */
        $createdById = (int)($task['created_by'] ?? 0);
        $createdByName = null;

        if ($createdById) {
            $createdByName = $db->table('users')
                ->select('name')
                ->where('id', $createdById)
                ->get()
                ->getRowArray()['name'] ?? null;
        }

        /** ===========================
         * TRẢ VỀ FE
         * =========================== */
        return $this->respond([
            'roster'            => $this->addHumanDatesToRoster($roster),
            'roster_total'      => $total,
            'approved_count'    => $approvedCount,
            'approved_percent'  => $approvedPercent,
            'progress'          => $approvedPercent,
            'progress_legacy'   => $this->computeRosterProgress($roster, (string)$task['approval_status']),
            'all_approved'      => $allApproved,
            'approved_at'       => $approved_at,
            'approved_at_vi'    => $approved_at ? date('H:i d/m/Y', strtotime($approved_at)) : null,
            'created_by'        => $createdById,
            'created_by_name'   => $createdByName,
            'latest_upload_batch' => $latestBatch,
            'latest_files'        => $latestFiles, // ⭐ NEVER LOST AGAIN
        ]);
    }



    /** POST /tasks/{id}/roster/merge: body: mentions(json|form) */
    public function merge($taskId): ResponseInterface
    {
        $taskId = (int)$taskId;
        $task   = $this->getTaskRow($taskId);
        if (!$task) return $this->failNotFound('Task not found');

        $json     = $this->getJsonBody() ?? [];
        $rawMent  = $json['mentions'] ?? '[]';
        $mode     = strtolower($json['mode'] ?? 'merge');

        $mentions = is_string($rawMent) ? json_decode($rawMent, true) : $rawMent;
        if (!is_array($mentions)) $mentions = [];

        if (!in_array($mode, ['merge', 'replace'], true)) {
            $mode = 'merge';
        }

        /** Roster cũ */
        $oldRoster = $this->readRoster($task);
        $oldMap = [];

        foreach ($oldRoster as $r) {
            $key = (int)$r['user_id'] . '_' . (int)($r['department_id'] ?? 0);
            $oldMap[$key] = $r;
        }

        $newMap = ($mode === 'merge') ? $oldMap : [];

        /** Xử lý từng mention */
        foreach ($mentions as $m) {

            $nm = $this->normalizeMention($m);
            if (!$nm) continue;

            $key = (int)$nm['user_id'] . '_' . (int)($nm['department_id'] ?? 0);

            if (!isset($newMap[$key])) {
                /** Thêm mới */
                $nm['added_at'] = date('Y-m-d H:i:s');
                $nm['acted_at'] = $nm['acted_at'] ?? null;
                $nm['note']     = $nm['note'] ?? null;
                $newMap[$key] = $nm;
            } else {
                /** Cập nhật record cũ */
                $old = $newMap[$key];

                $nm['added_at'] = $old['added_at'] ?? date('Y-m-d H:i:s');
                $nm['acted_at'] = $m['acted_at'] ?? $old['acted_at'] ?? null;
                $nm['note']     = $old['note'] ?? $nm['note'];
                $newMap[$key]   = array_merge($old, $nm);
            }
        }

        /** Final roster */
        $newList = array_values($newMap);

        /** SAVE */
        $this->writeRoster($taskId, $newList);

        /** SAVE SNAPSHOT */
        $taskUpdated = $this->getTaskRow($taskId);
        $taskUpdated['approval_roster_json'] = json_encode($newList, JSON_UNESCAPED_UNICODE);
        service('taskSnapshot')->save($taskUpdated);

        /** Notify */
        Services::taskSnapshotObserver()->detectChangesAndNotify($taskId);

        /** Trả về FE */
        return $this->respond([
            'message'  => 'OK',
            'roster'   => $this->addHumanDatesToRoster($newList),
            'progress' => $this->computeRosterProgress($newList, (string)$task['approval_status']),
        ]);
    }



    private function addHumanDatesToRoster($arr) {
        return array_map(function($r) {
            $r['acted_at_vi'] = $r['acted_at']
                ? date('H:i d/m/Y', strtotime($r['acted_at']))
                : null;

            $r['added_at_vi'] = $r['added_at']
                ? date('H:i d/m/Y', strtotime($r['added_at']))
                : null;

            unset($r['acted_at_iso'], $r['acted_date_vi']); // xoá các field dư
            return $r;
        }, $arr);
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

        $task = $this->getTaskRow($taskId);
        if (!$task) return $this->failNotFound('Task not found');

        $uid     = (int)$this->getUserId();
        $db      = db_connect();
        $roster  = $this->readRoster($task);

        // ==========================
        // CHECK QUYỀN
        // ==========================
        [$can, $idx, $reason] = $this->canUserActOnRoster($roster, $uid);
        if (!$can) return $this->failForbidden($reason ?? 'Không thể thực hiện');

        // ==========================
        // LẤY ROLE_CODE ĐÚNG CÁCH
        // ==========================
        $roleRow = $db->table('users u')
            ->select('r.code AS role_code')
            ->join('roles r', 'r.id = u.role_id', 'left')
            ->where('u.id', $uid)
            ->get()
            ->getRowArray();

        $role = strtolower($roleRow['role_code'] ?? 'user');


        // ==========================
        // UPDATE USER HIỆN TẠI
        // ==========================
        $payload = $this->getJsonBody();
        $note = $payload['note'] ?? null;
        if (is_array($note)) {
            $note = json_encode($note, JSON_UNESCAPED_UNICODE);
        }

        $roster[$idx]['status']   = $finalStatus;
        $roster[$idx]['acted_at'] = date('Y-m-d H:i:s');
        if ($note !== null) $roster[$idx]['note'] = $note;



        // ==========================
        // AUTO-APPROVE LOGIC
        // super_admin → duyệt tất cả
        // admin → duyệt toàn user
        // ==========================
        if ($finalStatus === 'approved') {

            // SUPER ADMIN → duyệt tất cả
            if ($role === 'super_admin') {

                foreach ($roster as $i => $r) {
                    if (($roster[$i]['status'] ?? '') !== 'approved') {
                        $roster[$i]['status']   = 'approved';
                        $roster[$i]['acted_at'] = date('Y-m-d H:i:s');
                    }
                }
            }

            // ADMIN → duyệt toàn USER
            if ($role === 'admin') {

                foreach ($roster as $i => $r) {
                    $uid2 = (int)($r['user_id'] ?? 0);
                    if ($uid2 === $uid) continue;

                    // Lấy role_code đúng của user
                    $u2 = $db->table('users u')
                        ->select('r.code AS role_code')
                        ->join('roles r', 'r.id = u.role_id', 'left')
                        ->where('u.id', $uid2)
                        ->get()
                        ->getRowArray();

                    $role2 = strtolower($u2['role_code'] ?? 'user');

                    if ($role2 === 'user') {
                        if (($roster[$i]['status'] ?? '') !== 'approved') {
                            $roster[$i]['status']   = 'approved';
                            $roster[$i]['acted_at'] = date('Y-m-d H:i:s');
                        }
                    }
                }
            }
        }



        // ==========================
        // SAVE ROSTER
        // ==========================
        $this->writeRoster($taskId, $roster);

        // SAVE SNAPSHOT
        $taskUpdated = $this->getTaskRow($taskId);
        $taskUpdated['approval_roster_json'] = json_encode($roster, JSON_UNESCAPED_UNICODE);
        service('taskSnapshot')->save($taskUpdated);

        // OBSERVER NOTIFY
        service('taskSnapshotObserver')->detectChangesAndNotify($taskId);


        // ==========================
        // CẬP NHẬT TASK STATUS
        // ==========================
        if ($finalStatus === 'rejected') {

            $taskUpd = [
                'approval_status' => 'rejected',
                'status'          => TaskStatus::TODO,
                'progress'        => $this->computeRosterProgress($roster, 'rejected'),
            ];

        } else {

            $allApproved = !array_filter($roster, fn($r) => ($r['status'] ?? '') !== 'approved');

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

        $db->table('tasks')->where('id', $taskId)->update($taskUpd);

        return $this->respond([
            'message'     => $finalStatus === 'approved' ? 'Approved' : 'Rejected',
            'roster'      => $this->addHumanDatesToRoster($roster),
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


    private function extractDriveId(string $value): ?string
    {
        $value = trim($value);
        if ($value === '') return null;

        // Nếu là pure ID (không chứa dấu /)
        if (!str_contains($value, '/')) {
            return $value;
        }

        // Dạng: https://drive.google.com/file/d/ID/view
        if (preg_match('/\/d\/([^\/]+)/', $value, $m)) {
            return $m[1];
        }

        // Dạng: ...?id=ID
        if (preg_match('/id=([A-Za-z0-9_\-]+)/', $value, $m)) {
            return $m[1];
        }

        return null;
    }



    /**
     */
    public function checkAndReplaceMarker(): ResponseInterface
    {
        $body = $this->getJsonBody();
        $taskId = (int)($body['task_id'] ?? 0);
        $userId = (int)($body['user_id'] ?? 0);
        $departmentId = (int)($body['department_id'] ?? 0);

        if (!$taskId || !$userId)
            return $this->fail('Missing task_id or user_id');

        $db = db_connect();

        // 1) Lấy user + vị trí (executive, senior_manager, manager, staff)
        $user = $db->table('users u')
            ->select('u.*, p.code AS position_code, p.level AS position_level')
            ->join('positions p', 'p.id = u.position_id', 'left')
            ->where('u.id', $userId)
            ->get()
            ->getRowArray();

        if (!$user) return $this->failNotFound("User not found");

        $isMultiRole = (int)($user['is_multi_role'] ?? 0);

        // --------------- XÁC ĐỊNH MARKER ---------------
        if ($isMultiRole === 1) {
            if (!$departmentId)
                return $this->fail("Missing department_id for multi-role user");

            $sig = $db->table('user_signatures')
                ->where('user_id', $userId)
                ->where('department_id', $departmentId)
                ->where('active', 1)
                ->get()->getRowArray();

            if (!$sig) return $this->failNotFound("No signature found for this department");

            $marker = trim($sig['approval_marker'] ?? '');
        } else {
            $marker = trim($user['approval_marker'] ?? '');
        }

        if ($marker === '')
            return $this->respond(['message' => 'No marker']);

        // --------------- TÌM BATCH MỚI NHẤT ---------------
        $latestBatchRow = $db->table('documents')
            ->select('upload_batch')
            ->where('source_task_id', $taskId)
            ->orderBy('upload_batch', 'DESC')
            ->limit(1)
            ->get()->getRowArray();

        $latestBatch = $latestBatchRow['upload_batch'] ?? null;
        if (!$latestBatch)
            return $this->fail('No upload_batch found');

        // --------------- LẤY FILE CỦA BATCH ---------------
        $files = $db->table('documents')
            ->where('source_task_id', $taskId)
            ->where('upload_batch', $latestBatch)
            ->orderBy('id', 'ASC')
            ->get()->getResultArray();

        if (empty($files))
            return $this->failNotFound('No document found in latest batch');

        // --------------- THAY MARKER TRONG FILE ---------------
        $results = [];

        foreach ($files as $file) {
            $fileId = $file['google_file_id'] ?? null;

            if (!$fileId) {
                $results[] = [
                    'file_name' => $file['title'],
                    'status'    => 'skip_no_google_id'
                ];
                continue;
            }

            try {
                $this->googleReplaceMarker($fileId, $marker);
                $results[] = [
                    'file_name'      => $file['title'],
                    'google_file_id' => $fileId,
                    'status'         => 'replaced'
                ];
            } catch (Throwable $e) {
                $results[] = [
                    'file_name'      => $file['title'],
                    'google_file_id' => $fileId,
                    'status'         => 'error',
                    'error'          => $e->getMessage()
                ];
            }
        }

        // ======================================
        // AUTO-APPROVE LOGIC THEO CẤP ĐỘ MỚI
        // executive        → duyệt tất cả
        // senior_manager   → duyệt manager + staff
        // manager          → duyệt staff
        // staff            → chỉ duyệt chính họ
        // ======================================

        $role = strtolower($user['position_code'] ?? 'staff');
        $myLevel = (int)($user['position_level'] ?? 1);

        $task   = $this->getTaskRow($taskId);
        $roster = $this->readRoster($task);

        foreach ($roster as &$r) {

            // Lấy vị trí người trong roster
            $u2 = $db->table('users u')
                ->select('p.code AS position_code, p.level AS position_level')
                ->join('positions p', 'p.id = u.position_id', 'left')
                ->where('u.id', $r['user_id'])
                ->get()->getRowArray();

            $targetLevel = (int)($u2['position_level'] ?? 1);

            // ================================
            // QUY TẮC AUTO-APPROVE THEO LEVEL
            // ================================
            if ($myLevel > $targetLevel) {
                // cấp cao auto duyệt cấp thấp
                $r['status']   = 'approved';
                $r['acted_at'] = date('Y-m-d H:i:s');
            }

            // STAFF (level=1) → chỉ duyệt chính họ
            if ($myLevel === 1 && $r['user_id'] == $userId) {
                $r['status']   = 'approved';
                $r['acted_at'] = date('Y-m-d H:i:s');
            }
        }

        // --------------- SAVE ROSTER ---------------
        $this->writeRoster($taskId, $roster);

        // --------------- UPDATE TASK STATUS ---------------
        $allApproved = !array_filter($roster, fn($r) => ($r['status'] ?? '') !== 'approved');

        if ($allApproved) {
            $db->table('tasks')->where('id', $taskId)->update([
                'approval_status' => 'approved',
                'status'          => TaskStatus::DONE,
                'progress'        => 100,
                'approved_at'     => date('Y-m-d H:i:s'),
            ]);
        } else {
            $db->table('tasks')->where('id', $taskId)->update([
                'progress' => $this->computeRosterProgress($roster, ($task['approval_status'] ?? 'pending'))
            ]);
        }

        return $this->respond([
            'message'       => "Marker '$marker' replaced for batch $latestBatch",
            'results'       => $results,
            'auto_approved' => $role,
            'roster'        => $roster
        ]);
    }







    private function googleClient(): Client
    {
        $g = new GoogleDriveService();
        return $g->getClient();
    }
    /**
     * @throws Exception
     */
    private function googleReplaceMarker(string $fileId, string $marker): void
    {
        $client = (new GoogleDriveService())->getClient();

        $drive  = new Google_Service_Drive($client);
        $docs   = new Google_Service_Docs($client);
        $sheets = new Google_Service_Sheets($client);

        $file = $drive->files->get($fileId, ['fields' => 'mimeType']);
        $mime = $file->mimeType;

        if ($mime === "application/vnd.google-apps.document") {
            $this->replaceInDocs($docs, $fileId, $marker);
            return;
        }

        if ($mime === "application/vnd.google-apps.spreadsheet") {
            $this->replaceInSheets($sheets, $fileId, $marker);
        }

    }


    private function replaceInDocs($docs, $fileId, $marker): void
    {
        // 1) Replace marker -> "✓"
        $docs->documents->batchUpdate($fileId, new Google_Service_Docs_BatchUpdateDocumentRequest([
            "requests" => [
                [
                    "replaceAllText" => [
                        "containsText" => [
                            "text" => $marker,
                            "matchCase" => true
                        ],
                        "replaceText" => "✓"
                    ]
                ]
            ]
        ]));

        // 2) Lấy lại document để tìm vị trí
        $document = $docs->documents->get($fileId);
        $locations = $this->findTextLocations($document);

        if (!$locations) return;

        // 3) Update style đúng vị trí dấu ✓
        $requests = [];
        foreach ($locations as $loc) {
            $requests[] = [
                "updateTextStyle" => [
                    "range" => [
                        "startIndex" => $loc['startIndex'],
                        "endIndex"   => $loc['endIndex']
                    ],
                    "textStyle" => [
                        "bold" => true,
                        "foregroundColor" => [
                            "color" => ["rgbColor" => ["red" => 1, "green" => 0.85, "blue" => 0]]
                        ]
                    ],
                    "fields" => "bold,foregroundColor"
                ]
            ];
        }

        $docs->documents->batchUpdate(
            $fileId,
            new Google_Service_Docs_BatchUpdateDocumentRequest(["requests" => $requests])
        );
    }


    private function findTextLocations($document): array
    {
        $locations = [];
        $content = $document->getBody()->getContent();

        foreach ($content as $element) {
            if (!isset($element['paragraph']['elements'])) continue;

            foreach ($element['paragraph']['elements'] as $e) {
                if (!isset($e['textRun']['content'])) continue;

                $text = $e['textRun']['content'];
                $startIndex = $e['startIndex'];

                $offset = strpos($text, "✓");
                if ($offset !== false) {
                    $locations[] = [
                        'startIndex' => $startIndex + $offset,
                        'endIndex'   => $startIndex + $offset + strlen("✓")
                    ];
                }
            }
        }
        return $locations;
    }


    private function col(int $c): string {
        $letter = "";
        while ($c > 0) {
            $mod = ($c - 1) % 26;
            $letter = chr(65 + $mod) . $letter;
            $c = intdiv($c - $mod, 26);
        }
        return $letter;
    }

    private function replaceInSheets($sheets, $fileId, $marker): void
    {
        $resp = $sheets->spreadsheets->get($fileId);
        $sheetsList = $resp->getSheets();

        foreach ($sheetsList as $sh) {
            $title = $sh->properties->title;

            $range = "'$title'!A1:Z999";
            $values = $sheets->spreadsheets_values->get($fileId, $range)->getValues() ?? [];

            $valueUpdates = [];   // update ✓
            $styleUpdates = [];   // apply bold + color

            foreach ($values as $r => $row) {
                foreach ($row as $c => $val) {
                    if (trim($val) === trim($marker)) {

                        // A1 notation
                        $cell = $this->col($c + 1) . ($r + 1);
                        $a1 = "'$title'!$cell";

                        // update ✓
                        $valueUpdates[] = [
                            "range" => $a1,
                            "values" => [["✓"]]
                        ];

                        // style cho ô đó
                        $styleUpdates[] = [
                            "repeatCell" => [
                                "range" => [
                                    "sheetId" => $sh->properties->sheetId,
                                    "startRowIndex" => $r,
                                    "endRowIndex" => $r + 1,
                                    "startColumnIndex" => $c,
                                    "endColumnIndex" => $c + 1,
                                ],
                                "cell" => [
                                    "userEnteredFormat" => [
                                        "textFormat" => [
                                            "bold" => true,
                                            "foregroundColor" => [
                                                "red" => 1,
                                                "green" => 0.85,
                                                "blue" => 0,
                                            ]
                                        ]
                                    ]
                                ],
                                "fields" => "userEnteredFormat.textFormat"
                            ]
                        ];
                    }
                }
            }

            // 1️⃣ Update value (✓)
            if ($valueUpdates) {
                $sheets->spreadsheets_values->batchUpdate(
                    $fileId,
                    new Google_Service_Sheets_BatchUpdateValuesRequest([
                        "valueInputOption" => "RAW",
                        "data" => $valueUpdates,
                    ])
                );
            }

            // 2️⃣ Update style
            if ($styleUpdates) {
                $sheets->spreadsheets->batchUpdate(
                    $fileId,
                    new Google_Service_Sheets_BatchUpdateSpreadsheetRequest([
                        "requests" => $styleUpdates
                    ])
                );
            }
        }
    }


}
