<?php

namespace App\Controllers;

use App\Models\CommentReadModel;
use App\Models\DocumentApprovalModel;
use App\Models\DocumentApprovalStepModel;
use App\Models\DocumentModel;
use App\Models\TaskCommentModel;
use App\Models\TaskFileModel;
use App\Models\TaskModel;
use App\Models\UserModel;
use CodeIgniter\HTTP\Files\UploadedFile;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Libraries\SharepointUploader;
use Config\Services;
use ReflectionException;
use RuntimeException;
use Throwable;

class CommentController extends ResourceController
{
    protected $modelName = TaskCommentModel::class;
    protected $format    = 'json';

    // ============================
    // COMMENT LIST THEO TASK
    // ============================
    public function byTask($task_id): ResponseInterface
    {
        $page  = (int)($this->request->getGet('page') ?? 1);
        $limit = 5;
        $offset = ($page - 1) * $limit;

        $db = \Config\Database::connect();

        // 1) Subquery: files theo comment
        $sub = $db->table('documents')
            ->select("
            comment_id,
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'file_name', title,
                    'file_path', file_path,
                    'public_url', file_path,
                    'doc_type', doc_type,
                    'upload_batch', upload_batch
                )
            ) AS files_json
        ", false)
            ->where('comment_id IS NOT NULL', null, false)
            ->groupBy('comment_id');

        $subQuery = $sub->getCompiledSelect();

        // 2) Query comments
        $builder = $db->table('task_comments c');
        $builder->select("
        c.*,
        u.name AS user_name,
        COALESCE(f.files_json, '[]') AS files_json
    ", false);

        $builder->join('users u', 'u.id = c.user_id', 'left');
        $builder->join("($subQuery) f", 'f.comment_id = c.id', 'left');

        $builder->where('c.task_id', $task_id);
        $builder->orderBy('c.created_at', 'DESC');
        $builder->limit($limit, $offset);

        $rows = $builder->get()->getResultArray();

        foreach ($rows as &$c) {
            $c['files'] = json_decode($c['files_json'], true) ?: [];
            unset($c['files_json']);
        }

        // 3) Pagination
        $total = $db->table('task_comments')
            ->where('task_id', $task_id)
            ->countAllResults();

        return $this->respond([
            'comments' => $rows,
            'pagination' => [
                'currentPage' => $page,
                'totalPages'  => ceil($total / $limit),
                'totalItems'  => $total,
                'perPage'     => $limit,
            ],
        ]);
    }


    /**
     * Danh sách file theo task + phiên duyệt + chuỗi ký
     */
    public function filesByTask($task_id = null): ResponseInterface
    {
        $task_id = (int)$task_id;
        if ($task_id <= 0) {
            return $this->failValidationErrors('Thiếu task_id.');
        }

        $db = db_connect();

        // 1. Lấy documents thuộc task
        $builderDocs = $db->table('documents d');
        $builderDocs
            ->select(
                'd.id,
                 d.title,
                 d.file_path,
                 d.file_type,
                 d.file_size,
                 d.uploaded_by,
                 d.created_at,
                 d.approval_status,
                 d.approval_sent_by,
                 d.approval_sent_at,
                 u.name AS uploader_name'
            )
            ->join('users u', 'u.id = d.uploaded_by', 'left')
            ->where('d.source_task_id', $task_id)
            ->orderBy('d.created_at', 'DESC');

        $rows = $builderDocs->get()->getResultArray();

        if (empty($rows)) {
            return $this->respond([
                'task_id' => $task_id,
                'files'   => [],
                'count'   => 0,
            ]);
        }

        // Danh sách document_id
        $docIds = array_map(static fn($r) => (int)$r['id'], $rows);

        // 2. Lấy phiên duyệt mới nhất cho từng document (source_type=document)
        $approvalsByDoc = [];
        $approvalIds    = [];

        if (!empty($docIds)) {
            $sub = $db->table('document_approvals')
                ->select('document_id, MAX(id) AS max_id')
                ->where('source_type', 'document')
                ->whereIn('document_id', $docIds)
                ->groupBy('document_id');

            $subSql = $sub->getCompiledSelect();

            $builderApv = $db->table('document_approvals da');
            $builderApv
                ->select('da.*')
                ->join("({$subSql}) x", 'x.max_id = da.id', 'inner', false);

            $approvalRows = $builderApv->get()->getResultArray();

            foreach ($approvalRows as $a) {
                $docId                    = (int)$a['document_id'];
                $approvalsByDoc[$docId]   = $a;
                $approvalIds[]            = (int)$a['id'];
            }
        }

        // 3. Lấy các bước ký cho các approval_id ở trên
        $stepsByApproval = [];

        if (!empty($approvalIds)) {
            $builderSteps = $db->table('document_approval_steps s');
            $builderSteps
                ->select(
                    's.*,
                     u.name AS approver_name,
                     u.signature_url AS approver_signature_url'
                )
                ->join('users u', 'u.id = s.approver_id', 'left')
                ->whereIn('s.approval_id', $approvalIds)
                ->orderBy('s.sequence', 'ASC')
                ->orderBy('s.id', 'ASC');

            $stepRows = $builderSteps->get()->getResultArray();

            foreach ($stepRows as $s) {
                $aid                     = (int)$s['approval_id'];
                $stepsByApproval[$aid][] = $s;
            }
        }

        // 4. Gộp vào response
        $files = [];
        foreach ($rows as $r) {
            $docId     = (int)$r['id'];
            $rawStatus = isset($r['approval_status']) ? trim((string)$r['approval_status']) : '';
            $status    = $rawStatus !== '' ? $rawStatus : 'not_sent';

            $approval = $approvalsByDoc[$docId] ?? null;
            $steps    = $approval
                ? ($stepsByApproval[(int)$approval['id']] ?? [])
                : [];

            $fileName = $r['title'];
            if (!$fileName) {
                $path     = $r['file_path'] ?? '';
                $basename = basename(parse_url($path, PHP_URL_PATH) ?: '');
                $fileName = $basename ?: null;
            }

            $files[] = [
                'id'            => $docId,
                'task_id'       => $task_id,
                'file_name'     => $fileName,
                'file_path'     => $r['file_path'],
                'uploaded_by'   => (int)$r['uploaded_by'],
                'uploader_name' => $r['uploader_name'] ?? null,
                'created_at'    => $r['created_at'],
                'source'        => 'document',

                'status'           => $status,
                'approval_sent_by' => $r['approval_sent_by'] ?? null,
                'approval_sent_at' => $r['approval_sent_at'] ?? null,

                'approval' => $approval,
                'steps'    => $steps,
            ];
        }

        return $this->respond([
            'task_id' => $task_id,
            'files'   => $files,
            'count'   => count($files),
        ]);
    }

    /**
     * Gửi duyệt file trong comment (source_type = comment)
     * @throws ReflectionException
     */
    public function sendApprovalForComment($id = null): ResponseInterface
    {
        $payload   = $this->request->getJSON(true) ?? [];
        $userId    = (int)($payload['user_id'] ?? 0);
        $approvers = array_values(
            array_unique(
                array_filter(
                    array_map('intval', $payload['approver_ids'] ?? [])
                )
            )
        );
        $note = trim((string)($payload['note'] ?? ''));

        if (!$id || !$userId || empty($approvers)) {
            return $this->failValidationErrors('Thiếu comment_id, user_id hoặc approver_ids');
        }

        $cm = $this->model->find((int)$id);
        if (!$cm || empty($cm['file_path'])) {
            return $this->failNotFound('Comment không hợp lệ hoặc không có file.');
        }

        $apvM  = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        $db = $apvM->db;
        $db->transBegin();

        try {
            // 1) Tạo phiên duyệt
            $apvId = $apvM->insert([
                'document_id'        => (int)$id,
                'status'             => 'pending',
                'created_by'         => $userId,
                'current_step_index' => 0,
                'note'               => $note ?: 'Gửi duyệt file trong comment',
                'source_type'        => 'comment',
            ], true);

            // 2) Tạo các bước ký
            $seq   = 1;
            $batch = [];
            foreach ($approvers as $uid) {
                $batch[] = [
                    'approval_id' => $apvId,
                    'approver_id' => $uid,
                    'sequence'    => $seq++,
                    'status'      => 'waiting',
                ];
            }
            if ($batch) {
                $stepM->insertBatch($batch);
            }

            // 3) Kích hoạt bước đầu tiên
            $first = $stepM
                ->where('approval_id', $apvId)
                ->orderBy('sequence', 'ASC')
                ->first();

            if ($first) {
                $stepM->update($first['id'], ['status' => 'active']);
                $apvM->update($apvId, ['current_step_index' => (int)$first['sequence']]);
            }

            // 4) Cập nhật trạng thái comment
            $this->model->update((int)$id, [
                'approval_status'   => 'pending',
                'approval_sent_by'  => $userId,
                'approval_sent_at'  => date('Y-m-d H:i:s'),
            ]);

            $db->transCommit();

            return $this->respond([
                'ok'          => true,
                'message'     => 'Đã gửi duyệt file comment.',
                'approval_id' => (int)$apvId,
            ]);
        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError('Gửi duyệt thất bại: ' . $e->getMessage());
        }
    }

    /** Lấy department_id cho user (ưu tiên session, fallback DB) */
    private function resolveDepartmentId(int $userId): ?int
    {
        $s = session();
        if ($s && $s->has('department_id')) {
            $dept = (int)$s->get('department_id');
            return $dept > 0 ? $dept : null;
        }

        $u    = (new UserModel())->select('department_id')->find($userId);
        $dept = (int)($u['department_id'] ?? 0);

        return $dept > 0 ? $dept : null;
    }

    /**
     * Tạo comment (text + optional file upload lên SharePoint)
     * @throws ReflectionException
     * @throws \Exception
     */
    public function create($task_id = null): ResponseInterface
    {
        $task_id = $task_id ? (int)$task_id : null;
        $userId  = (int)($this->request->getPost('user_id') ?? 0);

        if ($userId <= 0) {
            return $this->failValidationErrors(['user_id' => 'Thiếu user_id.']);
        }

        $content      = trim((string)($this->request->getPost('content') ?? ''));
        $mentionsJson = $this->request->getPost('mentions') ?? null;

        /** @var UploadedFile[] $files */
        $files = $this->request->getFileMultiple('attachments');
        if (!$files) {
            $single = $this->request->getFile('attachment');
            $files = ($single && $single->isValid()) ? [$single] : [];
        }

        $taskCommentModel = new TaskCommentModel();

        // 1) Tạo comment trước
        $commentId = $taskCommentModel->insert([
            'task_id'    => $task_id,
            'user_id'    => $userId,
            'content'    => $content,
            'mentions'   => $mentionsJson,
            'created_at' => date('Y-m-d H:i:s'),
        ], true);

        if (!$commentId) {
            return $this->failServerError("Không tạo được comment.");
        }

        $uploadedFiles = [];

        // Nếu không có file → chỉ text
        if (empty($files)) {
            $created = $taskCommentModel->find($commentId);
            $created['files'] = [];

            $this->mergeMentionsIntoTaskRoster((int)$task_id, $mentionsJson);
            return $this->respondCreated(['comment' => $created]);
        }

        // ⭐ 2) Tính batch upload (đúng chuẩn)
        $db = \Config\Database::connect();
        $lastBatchRow = $db->table('documents')
            ->where('source_task_id', $task_id)
            ->selectMax('upload_batch')
            ->get()
            ->getRow();

        $uploadBatch = (int)($lastBatchRow->upload_batch ?? 0) + 1;

        // 3) Upload files → insert documents
        $docM   = new DocumentModel();
        $deptId = $this->resolveDepartmentId($userId);
        $docType = $this->request->getPost('doc_type') === 'external' ? 'external' : 'internal';

        foreach ($files as $file) {
            if (!$file->isValid() || $file->hasMoved()) continue;

            $sp = new SharepointUploader();
            $upload = $sp->uploadFile($file->getTempName(), $file->getClientName());

            $driveId = $upload['driveId'] ?? null;
            $itemId  = $upload['itemId'] ?? null;

            if (!$driveId || !$itemId) continue;

            $viewOnlyUrl = $sp->createViewOnlyLink($driveId, $itemId, 'anonymous');
            $fileUrl     = $viewOnlyUrl;
            $spName      = $upload['file_name'] ?? $file->getClientName();

            // === Insert document ===
            $docId = $docM->insert([
                'title'         => $spName,
                'file_path'     => $fileUrl,
                'file_type'     => 'sharepoint',
                'doc_type'      => $docType,
                'file_size'     => $file->getSize(),
                'department_id' => $deptId,
                'uploaded_by'   => $userId,
                'visibility'    => 'private',
                'approval_status' => 'waiting',
                'source_task_id'  => $task_id,
                'comment_id'      => $commentId,
                'upload_batch'    => $uploadBatch,
                'created_at'      => date('Y-m-d H:i:s'),
            ], true);

            // === Insert task_files (để FE pinned files xử lý giống nhau) ===
            $taskFileM = new TaskFileModel();
            $taskFileM->insert([
                'task_id'      => $task_id,
                'document_id'  => $docId,
                'comment_id'   => $commentId,
                'file_name'    => $spName,
                'title'        => $spName,
                'file_path'    => $fileUrl,
                'uploaded_by'  => $userId,
                'is_link'      => 0,
                'status'       => 'uploaded',
                'is_pinned'    => 1,
                'pinned_by'    => $userId,
                'pinned_at'    => date('Y-m-d H:i:s'),
                'file_type'    => 'sharepoint',
                'file_size'    => $file->getSize(),
                'upload_batch' => $uploadBatch, // ⭐ batch consistent
                'created_at'   => date('Y-m-d H:i:s'),
            ]);

            $uploadedFiles[] = [
                'file_name'    => $spName,
                'file_path'    => $fileUrl,
                'public_url'   => $fileUrl,
                'doc_type'     => $docType,
                'upload_batch' => $uploadBatch
            ];
        }


        // 4) Trả về comment
        $createdComment = $taskCommentModel->find($commentId);
        $createdComment['files'] = $uploadedFiles;

        $this->mergeMentionsIntoTaskRoster((int)$task_id, $mentionsJson);

        return $this->respondCreated(['comment' => $createdComment]);
    }



    public function update($id = null): ResponseInterface
    {
        $data = [
            'content' => $this->request->getVar('content'),
        ];

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond(['message' => 'Comment updated']);
    }

    public function delete($id = null): ResponseInterface
    {
        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Comment deleted']);
    }

    public function inbox(): ResponseInterface
    {
        $uid = (int)($this->request->getGet('user_id') ?? 0);
        if (!$uid) {
            return $this->fail('Missing user_id', 400);
        }

        $page   = max(1, (int)($this->request->getGet('page') ?? 1));
        $limit  = min(50, (int)($this->request->getGet('limit') ?? 10));
        $offset = ($page - 1) * $limit;

        $db = db_connect();

        try {
            $builder = $db->table('task_comments c');
            $builder
                ->select(
                    'c.id,
                     c.task_id,
                     c.user_id AS author_id,
                     c.content,
                     c.created_at,
                     t.title AS task_title,
                     t.linked_type,
                     u.name  AS author_name,
                     u.avatar AS author_avatar,
                     CASE WHEN cr.id IS NULL THEN 1 ELSE 0 END AS is_unread'
                )
                ->join('tasks t', 't.id = c.task_id', 'inner')
                ->join('users u', 'u.id = c.user_id', 'left')
                ->join(
                    'comment_reads cr',
                    'cr.comment_id = c.id AND cr.user_id = ' . $db->escape($uid),
                    'left',
                    false
                )
                ->groupStart()
                ->where('t.assigned_to', $uid)
                ->orWhere('t.created_by', $uid)
                ->groupEnd()
                ->orderBy('c.created_at', 'DESC')
                ->limit($limit, $offset);

            $rows = $builder->get()->getResultArray();

            // Đếm tổng
            $countBuilder = $db->table('task_comments c');
            $countBuilder
                ->select('COUNT(*) AS cnt')
                ->join('tasks t', 't.id = c.task_id', 'inner')
                ->groupStart()
                ->where('t.assigned_to', $uid)
                ->orWhere('t.created_by', $uid)
                ->groupEnd();

            $totalRow = $countBuilder->get()->getRow();
            $total    = (int)($totalRow->cnt ?? 0);

            return $this->respond([
                'comments'   => $rows,
                'pagination' => [
                    'currentPage' => $page,
                    'totalPages'  => (int)ceil($total / $limit),
                    'totalItems'  => $total,
                    'perPage'     => $limit,
                ],
            ]);
        } catch (Throwable $e) {
            log_message('error', 'Inbox query failed: {msg}', ['msg' => $e->getMessage()]);
            return $this->failServerError('Failed to load inbox');
        }
    }

    /**
     * GET /my/comments/unread-count?user_id=123
     */
    public function unreadCount(): ResponseInterface
    {
        $uid = (int)($this->request->getGet('user_id') ?? 0);
        if (!$uid) {
            return $this->fail('Missing user_id', 400);
        }

        $db = db_connect();

        try {
            $builder = $db->table('task_comments c');
            $builder
                ->select('COUNT(*) AS cnt')
                ->join('tasks t', 't.id = c.task_id', 'inner')
                ->join(
                    'comment_reads cr',
                    'cr.comment_id = c.id AND cr.user_id = ' . $db->escape($uid),
                    'left',
                    false
                )
                ->groupStart()
                ->where('t.assigned_to', $uid)
                ->orWhere('t.created_by', $uid)
                ->groupEnd()
                ->where('cr.id', null); // chưa đọc

            $row = $builder->get()->getRowArray();

            return $this->respond(['unread' => (int)($row['cnt'] ?? 0)]);
        } catch (Throwable $e) {
            log_message('error', 'UnreadCount failed: {msg}', ['msg' => $e->getMessage()]);
            // đừng văng 500 chỉ vì đếm lỗi
            return $this->respond(['unread' => 0]);
        }
    }

    /**
     * POST /comments/mark-read
     * body: { user_id: 123, comment_ids: [1,2,3] }
     */
    public function markReadBatch(): ResponseInterface
    {
        $uid = (int)$this->request->getVar('user_id');
        $ids = (array)($this->request->getVar('comment_ids') ?? []);

        if (!$uid || !$ids) {
            return $this->fail('Missing user_id or comment_ids', 400);
        }

        $readModel = new CommentReadModel();
        $now       = date('Y-m-d H:i:s');

        $rows = array_map(static fn($cid) => [
            'user_id'    => $uid,
            'comment_id' => (int)$cid,
            'read_at'    => $now,
        ], $ids);

        foreach ($rows as $r) {
            try {
                $readModel->insert($r, false);
            } catch (Throwable) {
                // ignore duplicate
            }
        }

        return $this->respond(['ok' => true, 'marked' => count($rows)]);
    }

    /**
     * POST /comments/{id}/read  body: { user_id: 123 }
     */
    public function markRead($id = null): ResponseInterface
    {
        $uid = (int)$this->request->getVar('user_id');
        if (!$uid || !$id) {
            return $this->fail('Missing user_id or id', 400);
        }

        $readModel = new CommentReadModel();

        try {
            $readModel->insert([
                'user_id'    => $uid,
                'comment_id' => (int)$id,
                'read_at'    => date('Y-m-d H:i:s'),
            ], false);
        } catch (Throwable) {
            // ignore duplicate
        }

        return $this->respond(['ok' => true]);
    }

    protected function mergeMentionsIntoTaskRoster(int $taskId, ?string $mentionsJson): void
    {
        if (!$mentionsJson) {
            return;
        }

        $arr = json_decode($mentionsJson, true);
        if (!is_array($arr) || empty($arr)) {
            return;
        }

        $norm = [];
        foreach ($arr as $m) {
            if (empty($m['user_id'])) {
                continue;
            }

            $norm[] = [
                'user_id' => (int)$m['user_id'],
                'name'    => $m['name'] ?? ('#' . $m['user_id']),
                'role'    => in_array($m['role'] ?? 'approve', ['approve', 'sign'], true)
                    ? $m['role']
                    : 'approve',
            ];
        }

        if (!$norm) {
            return;
        }

        $taskModel = new TaskModel();
        $taskModel->upsertRosterMembers($taskId, $norm);
    }
}
