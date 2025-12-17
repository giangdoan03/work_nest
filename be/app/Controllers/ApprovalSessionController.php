<?php

namespace App\Controllers;

use App\Models\ApprovalSessionModel;
use App\Models\ApprovalSessionFileModel;
use App\Models\ApprovalSessionApproverModel;
use App\Libraries\GoogleDriveService;
use App\Models\UserModel;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;
use ReflectionException;
use RuntimeException;
use Throwable;

class ApprovalSessionController extends ResourceController
{
    protected $modelName = ApprovalSessionModel::class;
    protected $format    = 'json';

    /* =====================================================
     * POST /api/approval-sessions
     * -> Tạo phiên duyệt + upload file Google Drive
     * ===================================================== */
    public function create(): ResponseInterface
    {
        $db = db_connect();
        $db->transBegin();

        try {
            /* ================= AUTH ================= */
            $session = session();
            if (!$session->get('logged_in')) {
                return $this->failUnauthorized('Bạn chưa đăng nhập');
            }

            $creatorId = (int)$session->get('user_id');

            /* ================= INPUT ================= */
            $taskId = (int)$this->request->getPost('task_id');
            $approvers = json_decode($this->request->getPost('approvers'), true);

            if ($taskId <= 0) {
                return $this->failValidationErrors('Task không hợp lệ');
            }

            if (!is_array($approvers) || empty($approvers)) {
                return $this->failValidationErrors('Danh sách người duyệt không hợp lệ');
            }

            // chống duplicate
            $approvers = array_values(array_unique($approvers));

            /* ================= CREATE SESSION ================= */
            $sessionId = $this->model->insert([
                'task_id'    => $taskId,
                'created_by' => $creatorId,
                'status'     => 'pending',
                'created_at' => date('Y-m-d H:i:s'),
            ], true);

            /* ================= FILES (GOOGLE DRIVE) ================= */
            $files = $this->request->getFileMultiple('files');
            if (!$files) {
                throw new RuntimeException('Không nhận được file upload');
            }

            $fileModel = new ApprovalSessionFileModel();

            foreach ($files as $file) {
                if (!$file->isValid() || $file->hasMoved()) {
                    continue;
                }

                $ext = strtolower($file->getExtension());
                if (!in_array($ext, ['xls', 'xlsx', 'doc', 'docx'], true)) {
                    throw new RuntimeException('Chỉ cho phép file Excel hoặc Word');
                }

                $originalName = $file->getClientName();
                $tmpName = 'tmp_' . uniqid() . '_' . $originalName;
                $tempPath = WRITEPATH . 'uploads/' . $tmpName;

                $file->move(WRITEPATH . 'uploads', $tmpName);

                try {
                    $google = new GoogleDriveService();
                    $driveInfo = $google->uploadAndConvert($tempPath, $originalName);
                } catch (Throwable $e) {
                    @unlink($tempPath);
                    throw new RuntimeException('Google Drive lỗi: ' . $e->getMessage());
                }

                @unlink($tempPath);

                if (empty($driveInfo['drive_id'])) {
                    throw new RuntimeException('Upload Google Drive thất bại');
                }

                $fileModel->insert([
                    'session_id'     => $sessionId,
                    'file_name'      => $originalName,
                    'file_ext'       => $ext,
                    'file_size'      => $file->getSize(),
                    'file_path'      => $driveInfo['view'],
                    'drive_id'       => $driveInfo['drive_id'],
                    'google_file_id' => $driveInfo['google_file_id'],
                    'created_at'     => date('Y-m-d H:i:s'),
                ]);
            }

            /* ================= APPROVERS ================= */

            $approverModel = new ApprovalSessionApproverModel();
            $db = db_connect();

            foreach ($approvers as $index => $item) {

                if (!is_string($item) || !str_contains($item, '-')) {
                    throw new RuntimeException('Invalid approver: ' . json_encode($item));
                }

                [$uid, $deptId] = explode('-', $item, 2);
                $uid    = (int) $uid;
                $deptId = (int) $deptId;

                /* ================= LẤY POSITION_ID ================= */
                $positionRow = $db->table('department_user')
                    ->select('position_id')
                    ->where('user_id', $uid)
                    ->where('department_id', $deptId)
                    ->get()
                    ->getRowArray();

                if (!$positionRow || empty($positionRow['position_id'])) {
                    throw new RuntimeException(
                        "Không tìm thấy position_id cho user {$uid} tại department {$deptId}"
                    );
                }

                $positionId = (int) $positionRow['position_id'];

                /* ================= INSERT APPROVER ================= */
                $approverModel->insert([
                    'session_id'     => $sessionId,
                    'user_id'        => $uid,
                    'department_id'  => $deptId,
                    'position_id'    => $positionId, // ✅ QUAN TRỌNG
                    'approval_order' => $index + 1,
                    'status'         => 'pending',
                    'created_at'     => date('Y-m-d H:i:s'),
                ]);
            }



            $db->transCommit();

            return $this->respondCreated([
                'success'    => true,
                'session_id' => $sessionId
            ]);

        } catch (Throwable $e) {
            $db->transRollback();

            log_message('error', '[ApprovalSession:create] ' . $e->getMessage());

            return $this->failServerError('Không thể tạo phiên duyệt');
        }
    }

    public function byTask(int $taskId): ResponseInterface
    {
        $db = db_connect();

        /* ================= 1. SESSIONS ================= */
        $sessions = $db->table('approval_sessions')
            ->select('id, created_at')
            ->where('task_id', $taskId)
            ->orderBy('id', 'DESC')
            ->get()
            ->getResultArray();

        if (empty($sessions)) {
            return $this->respond([]);
        }

        $sessionIds = array_column($sessions, 'id');

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

            // 🔑 JOIN QUYẾT ĐỊNH
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

            // 🔑 JOIN QUYẾT ĐỊNH
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
                'id'              => (int) $r['id'],
                'user_id'         => (int) $r['user_id'],
                'department_id'   => (int) $r['department_id'],

                'name'            => $r['user_name'],
                'department_name' => $r['department_name'] ?? '—',
                'position_name'   => $r['position_name'] ?? '—',

                'is_multi_role'   => $r['is_multi_role'] ?? '0',

                'step_order'      => (int) $r['approval_order'],
                'level'           => (int) $r['level'],
                'result'          => $r['status'],
                'reviewed_at'     => $r['approved_at'],
            ];
        }



        /* ================= 4. BUILD RESPONSE ================= */
        $totalSessions = count($sessions);
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
            /* ================= AUTH ================= */
            $session = session();
            if (!$session->get('logged_in')) {
                return $this->failUnauthorized('Bạn chưa đăng nhập');
            }

            $userId = (int)$session->get('user_id');
            $id = (int)$id;

            if ($id <= 0) {
                return $this->failValidationErrors('Session ID không hợp lệ');
            }

            /* ================= CHECK SESSION ================= */
            $sessionRow = $this->model->find($id);
            if (!$sessionRow) {
                return $this->failNotFound('Phiên duyệt không tồn tại');
            }

            // (Tuỳ chọn) chỉ người tạo mới được xoá
            if ((int)$sessionRow['created_by'] !== $userId) {
                return $this->failForbidden('Bạn không có quyền xoá phiên duyệt này');
            }

            /* ================= DELETE FILES ================= */
            $fileModel = new ApprovalSessionFileModel();
            $files = $fileModel
                ->where('session_id', $id)
                ->findAll();

            // 👉 nếu muốn xoá cả Google Drive
//            foreach ($files as $f) {
//                if (!empty($f['google_file_id'])) {
//                    try {
//                        $google = new GoogleDriveService();
//                        $google->deleteFile($f['google_file_id']); // nếu bạn có method này
//                    } catch (Throwable $e) {
//                        log_message('error', '[ApprovalSession] Delete Drive fail: ' . $e->getMessage());
//                    }
//                }
//            }

            $fileModel->where('session_id', $id)->delete();

            /* ================= DELETE APPROVERS ================= */
            $approverModel = new ApprovalSessionApproverModel();
            $approverModel->where('session_id', $id)->delete();

            /* ================= DELETE SESSION ================= */
            $this->model->delete($id);

            $db->transCommit();

            return $this->respond([
                'success' => true,
                'message' => 'Đã xoá phiên duyệt'
            ]);

        } catch (Throwable $e) {
            $db->transRollback();

            log_message('error', '[ApprovalSession][DELETE] ' . $e->getMessage());

            return $this->failServerError('Không thể xoá phiên duyệt');
        }
    }


    /**
     * @throws ReflectionException
     */
    public function approve($sessionId): ResponseInterface
    {
        if (!session()->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $userId    = (int) session()->get('user_id');
        $sessionId = (int) $sessionId;

        $approverModel = new ApprovalSessionApproverModel();

        // 1️⃣ Lấy approver hiện tại + level
        $current = $approverModel
            ->select('a.*, p.level')
            ->from('approval_session_approvers a')
            ->join('positions p', 'p.id = a.position_id')
            ->where('a.session_id', $sessionId)
            ->where('a.user_id', $userId)
            ->where('a.status', 'pending')
            ->first();

        if (!$current) {
            return $this->failForbidden('Không có quyền duyệt');
        }

        $currentLevel = (int) $current['level'];

        // 2️⃣ Duyệt chính mình
        $approverModel->update($current['id'], [
            'status'      => 'approved',
            'approved_at' => date('Y-m-d H:i:s')
        ]);

        // 3️⃣ AUTO APPROVE CẤP THẤP HƠN (RAW SQL)
        $db = db_connect();
        $db->query("
        UPDATE approval_session_approvers a
        JOIN positions p ON p.id = a.position_id
        SET
            a.status = 'approved',
            a.approved_at = ?
        WHERE
            a.session_id = ?
            AND a.status = 'pending'
            AND p.level < ?
    ", [
            date('Y-m-d H:i:s'),
            $sessionId,
            $currentLevel
        ]);

        return $this->respond([
            'success' => true,
            'message' => 'Đã duyệt'
        ]);
    }






    /**
     * @throws ReflectionException
     */
    public function reject($sessionId): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $userId = (int)$session->get('user_id');
        $reason = trim((string)$this->request->getPost('reason'));

        if ($reason === '') {
            return $this->failValidationErrors('Thiếu lý do');
        }

        $approverModel = new ApprovalSessionApproverModel();
        $sessionModel = new ApprovalSessionModel();

        $approver = $approverModel
            ->where('session_id', $sessionId)
            ->where('user_id', $userId)
            ->where('status', 'pending')
            ->first();

        if (!$approver) {
            return $this->failForbidden();
        }

        // ❌ từ chối
        $approverModel->update($approver['id'], [
            'status' => 'rejected',
            'approved_at' => date('Y-m-d H:i:s'),
            'reject_reason' => $reason
        ]);

        // ❌ phiên không hợp lệ
        $sessionModel->update($sessionId, [
            'status' => 'invalid'
        ]);

        return $this->respond([
            'success' => true,
            'message' => 'Đã từ chối'
        ]);
    }


    public function updateApprovalOrder(int $sessionId): ResponseInterface
    {
        if (!session()->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $data = $this->request->getJSON(true);
        $reviewers = $data['reviewers'] ?? [];

        if (empty($reviewers)) {
            return $this->failValidationErrors('Danh sách reviewer rỗng');
        }

        $db = db_connect();
        $db->transBegin();

        try {
            $model = new ApprovalSessionApproverModel();

            foreach ($reviewers as $r) {
                if (!isset($r['id'], $r['approval_order'])) {
                    continue;
                }

                $model->update((int)$r['id'], [
                    'approval_order' => (int)$r['approval_order']
                ]);
            }

            $db->transCommit();

            return $this->respond([
                'success' => true,
                'message' => 'Cập nhật thứ tự duyệt thành công'
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

        $userId = (int) session()->get('user_id');

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

        // ❌ đã có người duyệt → không cho sửa
        $hasProcessed = $approverModel
            ->where('session_id', $sessionId)
            ->whereIn('status', ['approved', 'rejected'])
            ->countAllResults();

        if ($hasProcessed > 0) {
            return $this->failForbidden('Đã có người duyệt, không thể chỉnh sửa');
        }

        // 🔹 INPUT
        $approvers = json_decode(
            $this->request->getPost('approvers') ?? '[]',
            true
        );

        if (empty($approvers)) {
            return $this->failValidationErrors('Danh sách người duyệt rỗng');
        }

        $db = db_connect();
        $db->transBegin();

        try {
            // ❌ xoá toàn bộ approver cũ
            $approverModel->where('session_id', $sessionId)->delete();

            // ✅ insert lại
            foreach ($approvers as $index => $item) {
                if (!str_contains($item, '-')) {
                    continue;
                }

                [$uid, $deptId] = explode('-', $item, 2);

                $approverModel->insert([
                    'session_id'     => $sessionId,
                    'user_id'        => (int)$uid,
                    'department_id'  => (int)$deptId,
                    'approval_order' => $index + 1,
                    'status'         => 'pending',
                    'created_at'     => date('Y-m-d H:i:s'),
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







}
