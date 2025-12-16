<?php

namespace App\Controllers;

use App\Models\ApprovalSessionModel;
use App\Models\ApprovalSessionFileModel;
use App\Models\ApprovalSessionApproverModel;
use App\Libraries\GoogleDriveService;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;
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

            $userId = (int)$session->get('user_id');

            /* ================= INPUT ================= */
            $taskId    = (int)$this->request->getPost('task_id');
            $approvers = json_decode($this->request->getPost('approvers'), true);

            if ($taskId <= 0 || empty($approvers)) {
                return $this->failValidationErrors(
                    'Thiếu task_id hoặc danh sách người duyệt'
                );
            }

            /* ================= CREATE SESSION ================= */
            $sessionId = $this->model->insert([
                'task_id'    => $taskId,
                'created_by' => $userId,
                'status'     => 'pending',
                'created_at' => date('Y-m-d H:i:s'),
            ], true);

            /* ================= FILES (GOOGLE DRIVE) ================= */
            $fileModel = new ApprovalSessionFileModel();
            $files     = $this->request->getFileMultiple('files');

            if ($files) {
                foreach ($files as $file) {
                    if (!$file->isValid() || $file->hasMoved()) {
                        continue;
                    }

                    $ext = strtolower($file->getExtension());
                    if (!in_array($ext, ['xls', 'xlsx', 'doc', 'docx'], true)) {
                        return $this->fail(
                            'Chỉ cho phép file Excel hoặc Word',
                            400
                        );
                    }

                    $originalName = $file->getClientName();

                    /* ===== MOVE FILE TẠM ===== */
                    $tmpName  = 'tmp_' . uniqid() . '_' . $originalName;
                    $tempPath = WRITEPATH . 'uploads/' . $tmpName;
                    $file->move(WRITEPATH . 'uploads', $tmpName);

                    /* ===== UPLOAD GOOGLE DRIVE ===== */
                    try {
                        $google = new GoogleDriveService();
                        $driveInfo = $google->uploadAndConvert(
                            $tempPath,
                            $originalName
                        );
                    } catch (Throwable $e) {
                        @unlink($tempPath);

                        return $this->fail([
                            'message' => 'Google Drive đang gặp sự cố hoặc token đã hết hạn.',
                            'code'    => 'GOOGLE_DRIVE_ERROR'
                        ], 400);
                    }

                    @unlink($tempPath);

                    if (!$driveInfo || empty($driveInfo['drive_id'])) {
                        continue;
                    }

                    /* ===== SAVE DB ===== */
                    $fileModel->insert([
                        'session_id'     => $sessionId,
                        'file_name'      => $originalName,
                        'file_ext'       => $ext,
                        'file_size'      => $file->getSize(),
                        'file_path'      => $driveInfo['view'],           // URL Google Docs
                        'drive_id'       => $driveInfo['drive_id'],
                        'google_file_id' => $driveInfo['google_file_id'],
                        'created_at'     => date('Y-m-d H:i:s'),
                    ]);
                }
            }

            /* ================= APPROVERS ================= */
            $approverModel = new ApprovalSessionApproverModel();

            foreach ($approvers as $index => $item) {
                [$uid, $deptId] = explode('-', $item);

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

            return $this->respondCreated([
                'success'    => true,
                'session_id' => $sessionId
            ]);

        } catch (Throwable $e) {
            $db->transRollback();

            log_message('error', '[ApprovalSession] ' . $e->getMessage());

            return $this->failServerError(
                'Không thể tạo phiên duyệt'
            );
        }
    }

    public function byTask(int $taskId): ResponseInterface
    {
        $db = db_connect();

        /* ================= 1. SESSIONS ================= */
        $sessions = $db->table('approval_sessions s')
            ->select('
            s.id,
            s.task_id,
            s.status,
            s.created_at
        ')
            ->where('s.task_id', $taskId)
            ->orderBy('s.id', 'DESC')
            ->get()
            ->getResultArray();

        if (!$sessions) {
            return $this->respond([]);
        }

        $sessionIds = array_column($sessions, 'id');

        /* ================= 2. FILES ================= */
        $files = $db->table('approval_session_files')
            ->whereIn('session_id', $sessionIds)
            ->get()
            ->getResultArray();

        $filesBySession = [];
        foreach ($files as $f) {
            $filesBySession[$f['session_id']][] = [
                'code' => 'TT-' . $f['id'],
                'name' => $f['file_name'],
                'url'  => $f['file_path'],
            ];
        }

        /* ================= 3. REVIEWERS ================= */
        $reviewers = $db->table('approval_session_approvers a')
            ->select('
            a.*,
            u.name,
            p.name AS title,
            d.name AS department
        ')
            ->join('users u', 'u.id = a.user_id', 'left')
            ->join('positions p', 'p.id = u.position_id', 'left')
            ->join('departments d', 'd.id = a.department_id', 'left')
            ->whereIn('a.session_id', $sessionIds)
            ->orderBy('a.approval_order', 'ASC')
            ->get()
            ->getResultArray();

        $reviewersBySession = [];
        foreach ($reviewers as $r) {
            $reviewersBySession[$r['session_id']][] = [
                'user_id'     => (int)$r['user_id'],
                'step_order'  => (int)$r['approval_order'],
                'name'        => $r['name'],
                'title'       => $r['title'] ?? '—',
                'department'  => $r['department'],
                'result'      => $r['status'], // pending / approved / rejected
                'reviewed_at' => $r['updated_at'] ?? null,
                'is_wrong'    => (bool)($r['is_wrong'] ?? false),
                'is_detector' => (bool)($r['is_detector'] ?? false),
            ];
        }

        /* ================= 4. BUILD RESPONSE ================= */
        $total = count($sessions);
        $result = [];

        foreach ($sessions as $index => $s) {
            $result[] = [
                'session_no' => $total - $index,
                'start'      => date('H:i', strtotime($s['created_at'])),
                'end'        => null,
                'valid'      => $s['status'] !== 'invalid',
                'documents'  => $filesBySession[$s['id']] ?? [],
                'reviewers'  => $reviewersBySession[$s['id']] ?? [],
            ];
        }

        return $this->respond($result);
    }


}
