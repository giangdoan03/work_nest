<?php

namespace App\Controllers;

use App\Models\CommentReadModel;
use App\Models\DocumentApprovalModel;
use App\Models\DocumentApprovalStepModel;
use App\Models\DocumentModel;
use App\Models\TaskCommentModel;
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
    protected $format = 'json';

    // cấu hình upload cơ bản
    protected int $maxUploadKB = 8192; // 8MB
    protected array $allowedMimes = [
        'image/jpeg', 'image/png', 'image/gif', 'image/webp',
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'text/csv',
        'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'application/zip',
        'application/octet-stream',
    ];

    private function extToMime(string $ext): ?string
    {
        $map = [
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'gif' => 'image/gif',
            'webp' => 'image/webp',

            'pdf' => 'application/pdf',
            'doc' => 'application/msword',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls' => 'application/vnd.ms-excel',
            'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'csv' => 'text/csv',
            'ppt' => 'application/vnd.ms-powerpoint',
            'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            'zip' => 'application/zip',
        ];

        return $map[strtolower($ext)] ?? null;
    }

    private function guessContentType(UploadedFile $file): string
    {
        $ctype = $file->getMimeType() ?: 'application/octet-stream';

        if ($ctype === 'application/octet-stream') {
            $ext = $file->getClientExtension() ?: pathinfo($file->getClientName(), PATHINFO_EXTENSION);
            $guess = $this->extToMime($ext);
            if ($guess) {
                $ctype = $guess;
            }
        }

        return $ctype;
    }

    // ✅ Danh sách comment theo task
    public function byTask($task_id): ResponseInterface
    {
        $page = (int)$this->request->getGet('page') ?: 1;
        $limit = 5;

        /** @var TaskCommentModel $model */
        $model = $this->model;

        // Lấy comment có phân trang (mới nhất lên đầu)
        $comments = $model
            ->select('task_comments.*, users.name as user_name')
            ->join('users', 'users.id = task_comments.user_id', 'left')
            ->where('task_comments.task_id', $task_id)
            ->orderBy('task_comments.created_at', 'DESC')
            ->paginate($limit, 'default', $page);

        $pager = $model->pager ?? Services::pager();

        // Gắn mảng files nếu comment có file
        foreach ($comments as &$comment) {
            if (!empty($comment['file_path']) && !empty($comment['file_name'])) {
                $comment['files'] = [[
                    'file_name' => $comment['file_name'],
                    'file_path' => $comment['file_path'],
                ]];
            } else {
                $comment['files'] = [];
            }
        }
        unset($comment);

        return $this->respond([
            'comments' => $comments,
            'pagination' => [
                'currentPage' => $pager->getCurrentPage(),
                'totalPages' => $pager->getPageCount(),
                'totalItems' => $pager->getTotal(),
                'perPage' => $limit,
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
                'files' => [],
                'count' => 0,
            ]);
        }

        // Danh sách document_id
        $docIds = array_map(static fn($r) => (int)$r['id'], $rows);

        // 2. Lấy phiên duyệt mới nhất cho từng document (source_type=document)
        $approvalsByDoc = [];
        $approvalIds = [];

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
                $docId = (int)$a['document_id'];
                $approvalsByDoc[$docId] = $a;
                $approvalIds[] = (int)$a['id'];
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
                $aid = (int)$s['approval_id'];
                $stepsByApproval[$aid][] = $s;
            }
        }

        // 4. Gộp vào response
        $files = [];
        foreach ($rows as $r) {
            $docId = (int)$r['id'];

            $rawStatus = isset($r['approval_status']) ? trim((string)$r['approval_status']) : '';
            $status = $rawStatus !== '' ? $rawStatus : 'not_sent';

            $approval = $approvalsByDoc[$docId] ?? null;
            $steps = $approval
                ? ($stepsByApproval[(int)$approval['id']] ?? [])
                : [];

            $fileName = $r['title'];
            if (!$fileName) {
                $path = $r['file_path'] ?? '';
                $basename = basename(parse_url($path, PHP_URL_PATH) ?: '');
                $fileName = $basename ?: null;
            }

            $files[] = [
                'id' => $docId,
                'task_id' => $task_id,
                'file_name' => $fileName,
                'file_path' => $r['file_path'],
                'uploaded_by' => (int)$r['uploaded_by'],
                'uploader_name' => $r['uploader_name'] ?? null,
                'created_at' => $r['created_at'],
                'source' => 'document',

                'status' => $status,
                'approval_sent_by' => $r['approval_sent_by'] ?? null,
                'approval_sent_at' => $r['approval_sent_at'] ?? null,

                'approval' => $approval,
                'steps' => $steps,
            ];
        }

        return $this->respond([
            'task_id' => $task_id,
            'files' => $files,
            'count' => count($files),
        ]);
    }

    /**
     * Gửi duyệt file trong comment (source_type = comment)
     * @throws ReflectionException
     */
    public function sendApprovalForComment($id = null): ResponseInterface
    {
        $payload = $this->request->getJSON(true) ?? [];
        $userId = (int)($payload['user_id'] ?? 0);
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

        $apvM = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        $db = $apvM->db;
        $db->transBegin();

        try {
            // 1) Tạo phiên duyệt
            $apvId = $apvM->insert([
                'document_id' => (int)$id,
                'status' => 'pending',
                'created_by' => $userId,
                'current_step_index' => 0,
                'note' => $note ?: 'Gửi duyệt file trong comment',
                'source_type' => 'comment',
            ], true);

            // 2) Tạo các bước ký
            $seq = 1;
            $batch = [];
            foreach ($approvers as $uid) {
                $batch[] = [
                    'approval_id' => $apvId,
                    'approver_id' => $uid,
                    'sequence' => $seq++,
                    'status' => 'waiting',
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
                'approval_status' => 'pending',
                'approval_sent_by' => $userId,
                'approval_sent_at' => date('Y-m-d H:i:s'),
            ]);

            $db->transCommit();

            return $this->respond([
                'ok' => true,
                'message' => 'Đã gửi duyệt file comment.',
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

        $u = (new UserModel())->select('department_id')->find($userId);
        $dept = (int)($u['department_id'] ?? 0);

        return $dept > 0 ? $dept : null;
    }

    /**
     * Tạo comment (text + optional file upload lên SharePoint)
     * @throws ReflectionException
     */
    public function create($task_id = null): ResponseInterface
    {
        $task_id = $task_id ? (int)$task_id : null;
        $userId = (int)($this->request->getPost('user_id') ?? 0);

        if ($userId <= 0) {
            return $this->failValidationErrors(['user_id' => 'Thiếu user_id.']);
        }

        $content = trim((string)($this->request->getPost('content') ?? ''));
        $mentionsJson = $this->request->getPost('mentions') ?? null;

        /** @var UploadedFile|null $file */
        $file = $this->request->getFile('attachment') ?: $this->request->getFile('file');

        // Nếu không có file -> comment text-only
        if (!$file || !$file->isValid() || $file->hasMoved()) {
            $commentData = [
                'task_id' => $task_id,
                'user_id' => $userId,
                'content' => $content,
                'created_at' => date('Y-m-d H:i:s'),
            ];

            if ($mentionsJson) {
                $commentData['mentions'] = $mentionsJson;
            }

            $taskCommentModel = new TaskCommentModel();
            $inserted = $taskCommentModel->insert($commentData, true);

            if (!$inserted) {
                return $this->failServerError('Không tạo được comment.');
            }

            $commentId = is_int($inserted) ? $inserted : $taskCommentModel->getInsertID();
            $created = $taskCommentModel->find($commentId);

            $this->mergeMentionsIntoTaskRoster((int)$task_id, $mentionsJson);

            return $this->respondCreated([
                'comment' => $created,
            ]);
        }

        // Nếu có file -> validate size/mime
        $sizeKB = (int)ceil(($file->getSize() ?: 0) / 1024);
        if ($sizeKB > $this->maxUploadKB) {
            return $this->failValidationErrors(['attachment' => 'Kích thước vượt giới hạn.']);
        }

        $ctype = $this->guessContentType($file);
        if (!in_array($ctype, $this->allowedMimes, true)) {
            return $this->failValidationErrors(['attachment' => 'Định dạng không được hỗ trợ.']);
        }

        try {
            $sp = new SharepointUploader();
            $upload = $sp->uploadFile($file->getTempName(), $file->getClientName());

            $driveId = $upload['driveId'];
            $itemId  = $upload['itemId'];

            // ============================
            // GÁN QUYỀN
            // ============================

            // 1) Người upload → chỉ xem
            $userModel = new UserModel();
            $userInfo  = $userModel->find($userId);

            if (!empty($userInfo['email'])) {
                $sp->grantPermission($driveId, $itemId, $userInfo['email'], "read");
            }

            // 2) Admin → được sửa
            $adminEmail = "hieu.le@ttid.vn";  // bạn đổi thành email thật
            $sp->grantPermission($driveId, $itemId, $adminEmail, "write");

            // ============================
            // Tạo link view-only
            // ============================
            $viewOnlyUrl = $sp->createViewOnlyLink($driveId, $itemId, 'organization');

            if (!$viewOnlyUrl) {
                throw new RuntimeException('Không tạo được link chỉ xem.');
            }

            $fileUrl = $viewOnlyUrl;
            $spName = $upload['file_name'];

        } catch (Throwable $e) {
            log_message('error', 'SharePoint upload failed: ' . $e->getMessage());
            return $this->failServerError('Không upload được file lên SharePoint.');
        }



        // Insert vào documents
        $docM = new DocumentModel();
        $deptId = $this->resolveDepartmentId($userId);
        $sizeByte = (int)($file->getSize() ?: 0);

        // đọc doc_type từ request (internal|external)
        $docTypeRaw = (string)($this->request->getPost('doc_type') ?? '');
        $docType = in_array($docTypeRaw, ['internal', 'external'], true) ? $docTypeRaw : 'internal';

        $exist = $docM
            ->where('file_path', $fileUrl)
            ->where('uploaded_by', $userId)
            ->first();

        if ($exist) {
            $docId = (int)$exist['id'];
            $doc = $exist;

            if (($exist['doc_type'] ?? '') !== $docType) {
                $docM->update($docId, ['doc_type' => $docType]);
                $doc = $docM->find($docId);
            }
        } else {
            $docId = $docM->insert([
                'title' => $spName,
                'file_path' => $fileUrl,
                'file_type' => 'sharepoint',
                'doc_type' => $docType,
                'file_size' => $sizeByte,
                'department_id' => $deptId,
                'uploaded_by' => $userId,
                'visibility' => 'private',
                'approval_status' => 'waiting',
                'source_task_id' => $task_id ? (int)$task_id : null,
                'created_at' => date('Y-m-d H:i:s'),
            ], true);

            if (!$docId) {
                $docId = $docM->getInsertID();
            }

            $doc = $docM->find($docId);
        }

        // Tạo comment kèm file
        $taskCommentModel = new TaskCommentModel();
        $commentData = [
            'task_id' => $task_id,
            'user_id' => $userId,
            'content' => $content,
            'file_name' => $spName,
            'file_path' => $fileUrl,
            'created_at' => date('Y-m-d H:i:s'),
        ];
        if ($mentionsJson) {
            $commentData['mentions'] = $mentionsJson;
        }

        $inserted = $taskCommentModel->insert($commentData, true);
        if (!$inserted) {
            log_message('error', 'Insert task_comment failed: ' . json_encode($taskCommentModel->errors()));
            return $this->failServerError('Không tạo được comment kèm file.');
        }

        $commentId = is_int($inserted) ? $inserted : $taskCommentModel->getInsertID();
        $createdComment = $taskCommentModel->find($commentId);

        $this->mergeMentionsIntoTaskRoster((int)$task_id, $mentionsJson);

        $createdComment['files'] = [[
            'file_name' => $doc['title'] ?? $spName,
            'file_path' => $doc['file_path'] ?? $fileUrl,   // link gốc
            'public_url' => $fileUrl,                       // link view only
            'doc_type' => $doc['doc_type'] ?? $docType,
        ]];

        return $this->respondCreated([
            'comment' => $createdComment,
        ]);
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

        $page = max(1, (int)($this->request->getGet('page') ?: 1));
        $limit = min(50, (int)($this->request->getGet('limit') ?: 10));
        $offset = ($page - 1) * $limit;

        $db = db_connect();

        try {
            // Lấy danh sách comment liên quan user
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
            $total = (int)($totalRow->cnt ?? 0);

            return $this->respond([
                'comments' => $rows,
                'pagination' => [
                    'currentPage' => $page,
                    'totalPages' => (int)ceil($total / $limit),
                    'totalItems' => $total,
                    'perPage' => $limit,
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
        $now = date('Y-m-d H:i:s');

        $rows = array_map(static fn($cid) => [
            'user_id' => $uid,
            'comment_id' => (int)$cid,
            'read_at' => $now,
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
                'user_id' => $uid,
                'comment_id' => (int)$id,
                'read_at' => date('Y-m-d H:i:s'),
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
                'name' => $m['name'] ?? ('#' . $m['user_id']),
                'role' => in_array($m['role'] ?? 'approve', ['approve', 'sign'], true)
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
