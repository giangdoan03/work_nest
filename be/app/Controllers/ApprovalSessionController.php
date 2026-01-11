<?php

namespace App\Controllers;

use App\Services\NotificationService;
use App\Models\ApprovalSessionModel;
use App\Models\ApprovalSessionFileModel;
use App\Models\ApprovalSessionApproverModel;
use App\Libraries\GoogleDriveService;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;
use ReflectionException;
use RuntimeException;
use Throwable;

class ApprovalSessionController extends ResourceController
{
    protected $modelName = ApprovalSessionModel::class;
    protected $format    = 'json';

    protected NotificationService $notify;

    public function __construct()
    {
        $this->notify = new NotificationService();
    }

    /* =========================================================================
     * TẠO PHIÊN DUYỆT
     * ========================================================================= */
    public function create(): ResponseInterface
    {
        $db = db_connect();
        $db->transBegin();

        try {
            $session = session();
            if (!$session->get('logged_in')) {
                return $this->failUnauthorized('Bạn chưa đăng nhập');
            }

            $creatorId = (int)$session->get('user_id');
            $taskId    = (int)$this->request->getPost('task_id');
            $approvers = json_decode((string)$this->request->getPost('approvers'), true);

            if ($taskId <= 0) throw new RuntimeException('Task không hợp lệ');
            if (!is_array($approvers) || empty($approvers)) throw new RuntimeException('Danh sách người duyệt không hợp lệ');

            $approvers = array_values(array_unique($approvers));

            /* ==== Lấy thông tin Task để build Notify ==== */
            $taskRow = $db->table('tasks')->where('id', $taskId)->get()->getRowArray();
            if (!$taskRow) {
                throw new RuntimeException("Không tìm thấy Task #$taskId");
            }

            // SỬA ĐÚNG Ở ĐÂY
            $taskId     = (int)$taskRow['id'];
            $taskType   = $taskRow['linked_type'] ?? 'workflow';
            $bidId      = $taskRow['linked_id'] ?? null;
            $contractId = $taskRow['linked_id'] ?? null;
            $stepId     = $taskRow['step_id'] ?? null;


            /* ==== Tạo session duyệt ==== */
            $sessionId = $this->model->insert([
                'task_id'    => $taskId,
                'created_by' => $creatorId,
                'status'     => 'pending',
                'created_at' => date('Y-m-d H:i:s'),
            ], true);

            if (!$sessionId) {
                throw new RuntimeException('Không thể tạo phiên duyệt');
            }

            /* ==== Upload Files (KHÔNG BẮT BUỘC) ==== */
            $files = $this->request->getFileMultiple('files');

            if (!empty($files)) {
                $fileModel = new ApprovalSessionFileModel();
                $google    = new GoogleDriveService();

                foreach ($files as $file) {
                    if (!$file->isValid() || $file->hasMoved()) {
                        continue;
                    }

                    $ext = strtolower($file->getExtension());
                    if (!in_array($ext, ['doc','docx','xls','xlsx'], true)) {
                        throw new RuntimeException('Chỉ chấp nhận Word hoặc Excel');
                    }

                    $originalName = $file->getClientName();
                    $tmpName = uniqid('upload_', true) . '_' . $originalName;
                    $tmpPath = WRITEPATH . 'uploads/' . $tmpName;

                    $file->move(WRITEPATH . 'uploads', $tmpName);

                    try {
                        $driveInfo = $google->uploadAndConvert($tmpPath, $originalName);
                    } finally {
                        @unlink($tmpPath);
                    }

                    if (empty($driveInfo['google_file_id'])) {
                        throw new RuntimeException('Upload Google Drive thất bại');
                    }

                    $fileModel->insert([
                        'session_id'     => $sessionId,
                        'file_name'      => $originalName,
                        'file_ext'       => $ext,
                        'file_path'      => $driveInfo['view'] ?? null,
                        'drive_id'       => $driveInfo['drive_id'] ?? null,
                        'google_file_id' => $driveInfo['google_file_id'],
                    ]);
                }
            }

            /* ==== Insert Approvers ==== */
            $approverModel = new ApprovalSessionApproverModel();
            $uniqueUsers   = [];

            foreach ($approvers as $index => $item) {

                if (!str_contains($item, '-')) {
                    throw new RuntimeException("Approver không hợp lệ: $item");
                }

                [$uid, $deptId] = explode('-', $item);
                $uid = (int)$uid;
                $deptId = (int)$deptId;

                if ($uid <= 0) continue;

                $pos = $db->table('department_user')
                    ->select('position_id')
                    ->where('user_id', $uid)
                    ->where('department_id', $deptId)
                    ->get()->getRowArray();

                if (empty($pos['position_id'])) {
                    throw new RuntimeException("Không tìm thấy position cho user $uid");
                }

                $approverModel->insert([
                    'session_id'     => $sessionId,
                    'user_id'        => $uid,
                    'department_id'  => $deptId,
                    'position_id'    => (int)$pos['position_id'],
                    'approval_order' => $index + 1,
                    'status'         => 'pending'
                ]);

                $uniqueUsers[$uid] = true;
            }

            /* ==== Notify tất cả approvers ==== */
            foreach (array_keys($uniqueUsers) as $uid) {
                $this->notify->create($uid, [
                    "title"       => "Bạn được chỉ định duyệt tài liệu",
                    "message"     => "Bạn được thêm vào phiên duyệt cho Task #$taskId",
                    "type"        => $taskType,
                    "action_type" => "assigned",
                    "task_id"     => $taskId,
                    "step_id"     => $stepId,
                    "bid_id"      => $bidId,
                    "contract_id" => $contractId,
                    "session_id"  => $sessionId,
                ]);
            }

            $db->transCommit();

            return $this->respondCreated([
                'success'    => true,
                'session_id' => $sessionId
            ]);

        } catch (Throwable $e) {

            $db->transRollback();
            log_message('error', '[ApprovalSession::create] ' . $e->getMessage());

            return $this->failServerError(
                ENVIRONMENT === 'development' ? $e->getMessage() : 'Không thể tạo phiên duyệt'
            );
        }
    }




    public function byTask(int $taskId): ResponseInterface
    {
        $db = db_connect();

        /* ================= 1. SESSIONS ================= */
        $sessions = $db->table('approval_sessions')
            ->select('id, created_at, created_by')
            ->where('task_id', $taskId)
            ->orderBy('id', 'DESC')
            ->get()
            ->getResultArray();

        if (empty($sessions)) {
            return $this->respond([]);
        }

        $totalSessions = count($sessions);
        $sessionIds    = array_column($sessions, 'id');

        /* ================= 2. FILES ================= */
        $filesBySession = [];
        $files = $db->table('approval_session_files')
            ->select('id, session_id, file_name, file_path')
            ->whereIn('session_id', $sessionIds)
            ->get()
            ->getResultArray();

        foreach ($files as $f) {
            $filesBySession[$f['session_id']][] = [
                'code' => 'TT-' . $f['id'],
                'name' => $f['file_name'],
                'url'  => $f['file_path'],
            ];
        }

        /* ================= 3. REVIEWERS ================= */
        $reviewersBySession = [];
        $reviewers = $db->table('approval_session_approvers a')
            ->select('
            a.id,
            a.session_id,
            a.user_id,
            a.department_id,
            a.approval_order,
            a.status,
            a.approved_at,

            u.name AS user_name,
            u.is_multi_role,

            d.name AS department_name,

            p.id   AS position_id,
            p.name AS position_name,
            p.level
        ')
            ->join('users u', 'u.id = a.user_id', 'left')
            ->join(
                'department_user du',
                'du.user_id = a.user_id AND du.department_id = a.department_id',
                'left'
            )
            ->join('positions p', 'p.id = du.position_id', 'left')
            ->join('departments d', 'd.id = a.department_id', 'left')
            ->whereIn('a.session_id', $sessionIds)
            ->orderBy('a.approval_order', 'ASC')
            ->get()
            ->getResultArray();

        foreach ($reviewers as $r) {
            $reviewersBySession[$r['session_id']][] = [
                'id'              => (int)$r['id'],
                'user_id'         => (int)$r['user_id'],
                'department_id'   => (int)$r['department_id'],
                'name'            => $r['user_name'],
                'department_name' => $r['department_name'] ?? '—',
                'position_name'   => $r['position_name'] ?? '—',
                'is_multi_role'   => $r['is_multi_role'] ?? '0',
                'step_order'      => (int)$r['approval_order'],
                'level'           => (int)$r['level'],
                'result'          => $r['status'],
                'reviewed_at'     => $r['approved_at'],
            ];
        }

        /* ================= 4. BUILD RESPONSE ================= */
        $result = [];

        foreach ($sessions as $index => $s) {
            $sessionReviewers = $reviewersBySession[$s['id']] ?? [];

            // ❗ chỉ cần 1 rejected → invalid
            $valid = true;
            foreach ($sessionReviewers as $r) {
                if ($r['result'] === 'rejected') {
                    $valid = false;
                    break;
                }
            }

            $result[] = [
                'session_id' => (int)$s['id'],
                'session_no' => $totalSessions - $index,
                'created_at' => $s['created_at'],
                'created_by' => (int)$s['created_by'],
                'start'      => date('H:i', strtotime($s['created_at'])),
                'end'        => null,
                'valid'      => $valid,
                'documents'  => $filesBySession[$s['id']] ?? [],
                'reviewers'  => $sessionReviewers,
            ];
        }

        return $this->respond($result);
    }



    public function delete($id = null): ResponseInterface
    {
        $db = db_connect();
        $db->transBegin();

        try {
            $session = session();
            if (!$session->get('logged_in')) return $this->failUnauthorized();

            $userId = (int)$session->get('user_id');
            $id = (int)$id;

            $sessionRow = $this->model->find($id);
            if (!$sessionRow) return $this->failNotFound("Phiên không tồn tại");

            if ((int)$sessionRow['created_by'] !== $userId) {
                return $this->failForbidden("Bạn không có quyền xoá");
            }

            /* Xóa dữ liệu */
            (new ApprovalSessionFileModel())->where('session_id',$id)->delete();
            (new ApprovalSessionApproverModel())->where('session_id',$id)->delete();

            $this->model->delete($id);

            /* Notify người tạo */
            $this->notify->create($userId, [
                "title" => "Phiên duyệt đã bị xoá",
                "message" => "Phiên duyệt #$id đã được xoá",
                "type" => "approval_deleted",
                "session_id" => $id
            ]);

            $db->transCommit();

            return $this->respond([
                'success' => true,
                'message' => "Đã xoá phiên duyệt"
            ]);

        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError("Không thể xoá");
        }
    }


    /**
     */
    public function approve($sessionId): ResponseInterface
    {
        if (!session()->get('logged_in')) return $this->failUnauthorized();

        $userId = (int)session()->get('user_id');
        $payload = $this->request->getJSON(true);

        $deptId = (int)($payload['department_id'] ?? 0);
        if ($deptId <= 0) return $this->failValidationErrors("Thiếu department_id");

        $db = db_connect();
        $approverModel = new ApprovalSessionApproverModel();

        $current = $approverModel
            ->select('approval_session_approvers.*, p.level')
            ->join('positions p', 'p.id = approval_session_approvers.position_id', 'left')
            ->where('session_id', $sessionId)
            ->where('user_id', $userId)
            ->where('department_id', $deptId)
            ->where('status', 'pending')
            ->first();

        if (!$current) return $this->failForbidden("Không có quyền duyệt");

        /* Check đúng lượt */
        $notApprovedBefore = $approverModel
            ->where('session_id', $sessionId)
            ->where('approval_order <', $current['approval_order'])
            ->where('status !=', 'approved')
            ->countAllResults();

        if ($notApprovedBefore > 0) {
            return $this->failForbidden("Chưa tới lượt duyệt");
        }

        $db->transBegin();

        try {
            /* Mark approved */
            $approverModel->update($current['id'], [
                'status'      => 'approved',
                'approved_at' => date('Y-m-d H:i:s'),
            ]);

            /* Gửi thông báo cho người tạo */
            $sessionInfo = $db->table('approval_sessions')->where('id', $sessionId)->get()->getRowArray();
            $this->notify->create((int)$sessionInfo['created_by'], [
                "title" => "Phiên duyệt tiến triển",
                "message" => "Người dùng #$userId đã duyệt bước của bạn",
                "type" => "approval_progress",
                "task_id" => $sessionInfo["task_id"],
                "session_id" => $sessionId
            ]);

            /* Tìm người duyệt tiếp theo */
            $nextApprover = $approverModel
                ->where('session_id', $sessionId)
                ->where('approval_order >', $current['approval_order'])
                ->where('status', 'pending')
                ->orderBy('approval_order', 'ASC')
                ->first();

            if ($nextApprover) {
                $this->notify->create((int)$nextApprover['user_id'], [
                    "title" => "Đến lượt bạn duyệt",
                    "message" => "Bạn là người duyệt tiếp theo của phiên duyệt",
                    "type" => "approval_next",
                    "task_id" => $sessionInfo["task_id"],
                    "session_id" => $sessionId
                ]);
            }

            $db->transCommit();

            return $this->respond([
                'success' => true,
                'message' => 'Đã duyệt'
            ]);

        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError("Không thể duyệt");
        }
    }




    /**
     */
    public function reject($sessionId): ResponseInterface
    {
        if (!session()->get('logged_in')) return $this->failUnauthorized();

        $userId = (int)session()->get('user_id');
        $reason = trim((string)$this->request->getPost('reason'));

        if ($reason === '') return $this->failValidationErrors("Thiếu lý do");

        $db = db_connect();
        $approverModel = new ApprovalSessionApproverModel();
        $sessionModel  = new ApprovalSessionModel();

        $approver = $approverModel
            ->where('session_id', $sessionId)
            ->where('user_id', $userId)
            ->where('status', 'pending')
            ->first();

        if (!$approver) return $this->failForbidden('Không có quyền từ chối');

        $db->transBegin();

        try {
            $approverModel->update($approver['id'], [
                'status'        => 'rejected',
                'approved_at'   => date('Y-m-d H:i:s'),
                'reject_reason' => $reason
            ]);

            $sessionModel->update($sessionId, [
                'status' => 'invalid'
            ]);

            /* Notify người tạo */
            $sessionInfo = $sessionModel->find($sessionId);
            $this->notify->create((int)$sessionInfo['created_by'], [
                "title" => "Phiên duyệt bị từ chối",
                "message" => "Người dùng #$userId đã từ chối: $reason",
                "type" => "approval_rejected",
                "task_id" => $sessionInfo["task_id"],
                "session_id" => $sessionId
            ]);

            $db->transCommit();

            return $this->respond([
                'success' => true,
                'message' => 'Đã từ chối'
            ]);

        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError("Không thể từ chối");
        }
    }


    public function updateApprovalOrder(int $sessionId): ResponseInterface
    {
        if (!session()->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $userId = (int) session()->get('user_id');
        $payload = $this->request->getJSON(true);
        $reviewers = $payload['reviewers'] ?? [];

        if (empty($reviewers)) {
            return $this->failValidationErrors('Danh sách reviewer rỗng');
        }

        // 🔐 chỉ người tạo phiên
        $sessionRow = $this->model->find($sessionId);
        if (!$sessionRow || (int)$sessionRow['created_by'] !== $userId) {
            return $this->failForbidden('Không có quyền sắp xếp lại');
        }

        $db = db_connect();
        $approverModel = new ApprovalSessionApproverModel();

        $db->transBegin();

        try {
            foreach ($reviewers as $r) {
                if (!isset($r['id'], $r['approval_order'])) {
                    continue;
                }

                // ❗ KHÔNG cho đụng vào người đã duyệt
                $row = $approverModel->find((int)$r['id']);
                if (!$row || $row['status'] !== 'pending') {
                    continue;
                }

                $approverModel->update((int)$r['id'], [
                    'approval_order' => (int)$r['approval_order']
                ]);
            }

            $db->transCommit();

            return $this->respond([
                'success' => true,
                'message' => 'Đã cập nhật thứ tự duyệt'
            ]);

        } catch (Throwable $e) {
            $db->transRollback();
            log_message('error', '[updateApprovalOrder] ' . $e->getMessage());
            return $this->failServerError('Không thể cập nhật thứ tự');
        }
    }



    public function updateApprovalSession(int $sessionId): ResponseInterface
    {
        if (!session()->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $userId = (int)session()->get('user_id');

        /* ==== Lấy phiên duyệt ==== */
        $sessionRow = $this->model->find($sessionId);
        if (!$sessionRow) {
            return $this->failNotFound('Phiên duyệt không tồn tại');
        }

        if ((int)$sessionRow['created_by'] !== $userId) {
            return $this->failForbidden('Không có quyền cập nhật phiên này');
        }

        if ($sessionRow['status'] !== 'pending') {
            return $this->failForbidden('Phiên đã xử lý, không thể cập nhật');
        }

        $approverModel = new ApprovalSessionApproverModel();

        /* ==== Đã có người duyệt ==== */
        $hasProcessed = $approverModel
            ->where('session_id', $sessionId)
            ->whereIn('status', ['approved', 'rejected'])
            ->countAllResults();

        if ($hasProcessed > 0) {
            return $this->failForbidden('Đã có người duyệt, không thể chỉnh sửa');
        }

        /* ==== Lấy danh sách approver mới ==== */
        $approvers = json_decode($this->request->getPost('approvers') ?? '[]', true);
        if (empty($approvers)) {
            return $this->failValidationErrors('Danh sách người duyệt rỗng');
        }

        $db = db_connect();
        $db->transBegin();

        try {

            /* ==== Lấy Task chuẩn ==== */
            $taskRow = $db->table('tasks')->where('id', $sessionRow['task_id'])->get()->getRowArray();

            if (!$taskRow) throw new RuntimeException("Không tìm thấy Task");

            $taskId     = (int)$taskRow['id'];
            $taskType   = $taskRow['linked_type'] ?? 'workflow';
            $bidId      = $taskRow['linked_id'] ?? null;
            $contractId = $taskRow['linked_id'] ?? null;
            $stepId     = $taskRow['step_id'] ?? null;

            /* ==== Danh sách cũ ==== */
            $oldApprovers = $approverModel->where('session_id', $sessionId)->findAll();
            $oldUserIds   = array_column($oldApprovers, 'user_id');

            /* ==== Xoá cũ ==== */
            $approverModel->where('session_id', $sessionId)->delete();

            $newUserMap = [];

            /* ==== Insert mới ==== */
            foreach ($approvers as $index => $item) {

                if (!str_contains($item, '-')) continue;

                [$uid, $deptId] = explode('-', $item);
                $uid    = (int)$uid;
                $deptId = (int)$deptId;

                if ($uid <= 0) continue;

                $pos = $db->table('department_user')
                    ->select('position_id')
                    ->where('user_id', $uid)
                    ->where('department_id', $deptId)
                    ->get()->getRowArray();

                if (empty($pos['position_id'])) {
                    continue;
                }

                $approverModel->insert([
                    'session_id'     => $sessionId,
                    'user_id'        => $uid,
                    'department_id'  => $deptId,
                    'position_id'    => (int)$pos['position_id'],
                    'approval_order' => $index + 1,
                    'status'         => 'pending',
                    'created_at'     => date('Y-m-d H:i:s'),
                ]);

                $newUserMap[$uid] = true;
            }

            $newUserIds = array_keys($newUserMap);

            /* ==== Ai mới được thêm ==== */
            $addedUsers = array_diff($newUserIds, $oldUserIds);

            /* ==== Notify ==== */
            foreach ($addedUsers as $uid) {
                $this->notify->create($uid, [
                    "title"       => "Bạn được chỉ định duyệt tài liệu",
                    "message"     => "Bạn được thêm vào phiên duyệt cho Task #$taskId",
                    "type"        => $taskType,
                    "action_type" => "assigned",
                    "task_id"     => $taskId,
                    "step_id"     => $stepId,
                    "bid_id"      => $bidId,
                    "contract_id" => $contractId,
                    "session_id"  => $sessionId,
                ]);
            }

            $db->transCommit();

            return $this->respond([
                'success' => true,
                'message' => 'Cập nhật người duyệt thành công'
            ]);

        } catch (Throwable $e) {

            $db->transRollback();
            log_message('error', '[updateApprovalSession] ' . $e->getMessage());
            return $this->failServerError('Không thể cập nhật phiên duyệt');
        }
    }



    public function selectableUsers(): ResponseInterface
    {
        if (!session()->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $db = db_connect();

        /* ================= USERS ================= */
        $users = $db->table('users u')
            ->select('
            u.id,
            u.name,
            u.department_id,
            d.name AS department_name,
            u.is_multi_role,
            p.name AS position_name,
            p.level
        ')
            ->join('departments d', 'd.id = u.department_id', 'left')
            ->join('positions p', 'p.id = u.position_id', 'left')
            ->orderBy('u.name', 'ASC')
            ->get()
            ->getResultArray();

        if (!$users) {
            return $this->respond(['users' => []]);
        }

        $userIds = array_column($users, 'id');

        /* ================= MULTI ROLES ================= */
        $roles = $db->table('department_user du')
            ->select('
            du.user_id,
            du.department_id,
            d.name AS department_name
        ')
            ->join('departments d', 'd.id = du.department_id', 'left')
            ->whereIn('du.user_id', $userIds)
            ->get()
            ->getResultArray();

        // group multi roles by user
        $multiRolesByUser = [];
        foreach ($roles as $r) {
            $multiRolesByUser[$r['user_id']][] = [
                'department_id'   => (int)$r['department_id'],
                'department_name' => $r['department_name'],
                'active'          => '1'
            ];
        }

        /* ================= BUILD RESPONSE ================= */
        $result = [];

        foreach ($users as $u) {
            $result[] = [
                'id'               => (int)$u['id'],
                'name'             => $u['name'],
                'department_id'    => (int)$u['department_id'],
                'department_name'  => $u['department_name'],
                'position_name'    => $u['position_name'],
                'level'            => (int)$u['level'],
                'is_multi_role'    => $u['is_multi_role'],
                'multi_roles'      => $multiRolesByUser[$u['id']] ?? []
            ];
        }

        return $this->respond([
            'users' => $result
        ]);
    }


    public function statisticsByTask(int $taskId): ResponseInterface
    {
        $db = db_connect();

        /* ================= 1. SESSIONS ================= */
        $sessions = $db->table('approval_sessions')
            ->select('id')
            ->where('task_id', $taskId)
            ->orderBy('id', 'DESC')
            ->get()
            ->getResultArray();

        if (empty($sessions)) {
            return $this->respond([]);
        }

        $totalSessions = count($sessions);
        $sessionIds    = array_column($sessions, 'id');

        // map session_id → session_no (GIỐNG byTask)
        $sessionNoMap = [];
        foreach ($sessions as $idx => $s) {
            $sessionNoMap[$s['id']] = $totalSessions - $idx;
        }

        /* ================= 2. REVIEWERS ================= */
        $reviewers = $db->table('approval_session_approvers a')
            ->select('
            a.session_id,
            a.user_id,
            a.status,

            u.name AS user_name,

            p.level,
            p.violation_threshold
        ')
            ->join('users u', 'u.id = a.user_id')
            ->join(
                'department_user du',
                'du.user_id = a.user_id AND du.department_id = a.department_id',
                'left'
            )
            ->join('positions p', 'p.id = du.position_id', 'left')
            ->whereIn('a.session_id', $sessionIds)
            ->get()
            ->getResultArray();

        /* ================= 3. GROUP BY SESSION ================= */
        $bySession = [];
        foreach ($reviewers as $r) {
            $bySession[$r['session_id']][] = $r;
        }

        /* ================= 4. STATISTICS ================= */
        $userStats = [];

        foreach ($bySession as $sessionId => $items) {

            // 🔴 session có rejected?
            $hasRejected = false;
            foreach ($items as $r) {
                if ($r['status'] === 'rejected') {
                    $hasRejected = true;
                    break;
                }
            }
            if (!$hasRejected) continue;

            foreach ($items as $r) {
                if ($r['status'] !== 'approved') continue;

                $uid = (int)$r['user_id'];

                if (!isset($userStats[$uid])) {
                    $userStats[$uid] = [
                        'user_id'            => $uid,
                        'user_name'          => $r['user_name'],
                        'level'              => (int)($r['level'] ?? 1),
                        'threshold'          => (int)($r['violation_threshold'] ?? 1),
                        'total_error'        => 0,
                        'overdue_count'      => 0,
                        'violation_sessions' => [],
                    ];
                }

                // tăng lỗi
                $userStats[$uid]['total_error']++;

                // ❗ tránh trùng session
                $exists = array_column(
                    $userStats[$uid]['violation_sessions'],
                    'session_id'
                );

                if (!in_array($sessionId, $exists, true)) {
                    $userStats[$uid]['violation_sessions'][] = [
                        'session_id' => (int)$sessionId,
                        'session_no' => $sessionNoMap[$sessionId] ?? null,
                        'level'      => (int)($r['level'] ?? 1),
                    ];
                }
            }
        }

        /* ================= 5. OVERDUE ================= */
        foreach ($userStats as &$row) {
            $row['overdue_count'] = max(
                0,
                $row['total_error'] - $row['threshold']
            );
        }

        return $this->respond(array_values($userStats));
    }





}
