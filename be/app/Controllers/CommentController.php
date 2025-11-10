<?php

namespace App\Controllers;

use App\Models\CommentModel;
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
use App\Libraries\Uploader;
use Config\Services;
use ReflectionException;
use Throwable;

// ✅ Dùng thư viện upload đúng cách

class CommentController extends ResourceController
{
    protected $modelName = TaskCommentModel::class;
    protected $format = 'json';

    // cấu hình upload cơ bản
    protected int $maxUploadKB = 8192; // 8MB
    protected array $allowedMimes = [
        // image
        'image/jpeg', 'image/png', 'image/gif', 'image/webp',
        // pdf, office
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'text/csv',
        'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        // fallback thỉnh thoảng gặp
        'application/zip',
        'application/octet-stream',
    ];

    private function extToMime(string $ext): ?string
    {
        $map = [
            'jpg' => 'image/jpeg', 'jpeg' => 'image/jpeg', 'png' => 'image/png', 'gif' => 'image/gif', 'webp' => 'image/webp',
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
            if ($guess) $ctype = $guess;
        }
        return $ctype;
    }

    // ✅ Danh sách comment theo task
    public function byTask($task_id): ResponseInterface
    {
        $page = (int)$this->request->getGet('page') ?: 1;
        $limit = 5;

        // Lấy comment có phân trang (mới nhất lên đầu)
        $comments = $this->model
            ->select('task_comments.*, users.name as user_name')
            ->join('users', 'users.id = task_comments.user_id', 'left')
            ->where('task_comments.task_id', $task_id)
            ->orderBy('task_comments.created_at', 'DESC')
            ->paginate($limit, 'default', $page);

        $pager = Services::pager();

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

        return $this->respond([
            'comments' => $comments,
            'pagination' => [
                'currentPage' => $pager->getCurrentPage(),
                'totalPages' => $pager->getPageCount(),
                'totalItems' => $pager->getTotal(),
                'perPage' => $limit,
            ]
        ]);
    }


    public function filesByTask($task_id = null): ResponseInterface
    {
        $task_id = (int)$task_id;
        if ($task_id <= 0) {
            return $this->failValidationErrors('Thiếu task_id.');
        }

        $db = db_connect();

        // 1. Lấy danh sách document thuộc task
        $sql = "
        SELECT
            d.id,
            d.title,
            d.file_path,
            d.file_type,
            d.file_size,
            d.uploaded_by,
            u.name AS uploader_name,
            d.created_at,
            d.approval_status,
            d.approval_sent_by,
            d.approval_sent_at
        FROM documents d
        LEFT JOIN users u ON u.id = d.uploaded_by
        WHERE d.source_task_id = ?
          AND d.tags = 'task_upload'
        ORDER BY d.created_at DESC
    ";

        $rows = $db->query($sql, [$task_id])->getResultArray();

        if (!$rows) {
            return $this->respond([
                'task_id' => $task_id,
                'files'   => [],
                'count'   => 0,
            ]);
        }

        // Danh sách document_id
        $docIds = array_map(static fn($r) => (int)$r['id'], $rows);

        // 2. Lấy phiên duyệt hiện tại (mới nhất) cho từng document
        $inIds = implode(',', $docIds);

        $approvalRows = $db->query("
        SELECT da.*
        FROM document_approvals da
        JOIN (
            SELECT document_id, MAX(id) AS max_id
            FROM document_approvals
            WHERE source_type = 'document'
              AND document_id IN ($inIds)
            GROUP BY document_id
        ) x ON x.max_id = da.id
    ")->getResultArray();

        $approvalsByDoc   = [];
        $approvalIds      = [];

        foreach ($approvalRows as $a) {
            $docId = (int)$a['document_id'];
            $approvalsByDoc[$docId] = $a;              // đã là bản mới nhất
            $approvalIds[] = (int)$a['id'];
        }

        // 3. Lấy các bước ký cho các approval_id ở trên
        $stepsByApproval = [];

        if ($approvalIds) {
            $inApproval = implode(',', $approvalIds);

            $stepRows = $db->query("
            SELECT
                s.*,
                u.name          AS approver_name,
                u.signature_url AS approver_signature_url
            FROM document_approval_steps s
            LEFT JOIN users u ON u.id = s.approver_id
            WHERE s.approval_id IN ($inApproval)
            ORDER BY s.sequence ASC, s.id ASC
        ")->getResultArray();

            foreach ($stepRows as $s) {
                $aid = (int)$s['approval_id'];
                $stepsByApproval[$aid][] = $s;
            }
        }

        // 4. Gộp vào response cho từng file
        $files = [];
        foreach ($rows as $r) {
            $docId = (int)$r['id'];

            // chuẩn hóa status
            $rawStatus = isset($r['approval_status']) ? trim((string)$r['approval_status']) : '';
            $status    = $rawStatus !== '' ? $rawStatus : 'not_sent';

            $approval  = $approvalsByDoc[$docId] ?? null;
            $steps     = $approval
                ? ($stepsByApproval[(int)$approval['id']] ?? [])
                : [];

            $files[] = [
                'id'               => $docId,
                'task_id'          => $task_id,
                'file_name'        => $r['title']
                    ?: basename(parse_url($r['file_path'] ?? '', PHP_URL_PATH) ?: ''),
                'file_path'        => $r['file_path'],
                'uploaded_by'      => (int)$r['uploaded_by'],
                'uploader_name'    => $r['uploader_name'] ?? null,
                'created_at'       => $r['created_at'],
                'source'           => 'document',

                // trạng thái tổng thể
                'status'           => $status,
                'approval_sent_by' => $r['approval_sent_by'] ?? null,
                'approval_sent_at' => $r['approval_sent_at'] ?? null,

                // ⭐ thêm để FE hiển thị chuỗi ký:
                'approval'         => $approval,                    // phiên duyệt hiện tại (nếu có)
                'steps'            => $steps,                       // các bước ký (approver_name, status,...)
            ];
        }

        return $this->respond([
            'task_id' => $task_id,
            'files'   => $files,
            'count'   => count($files),
        ]);
    }


    /**
     * @throws ReflectionException
     */
    public function sendApprovalForComment($id = null): ResponseInterface
    {
        $payload = $this->request->getJSON(true) ?? [];
        $userId = (int)($payload['user_id'] ?? 0);
        $approvers = array_values(array_unique(array_filter(array_map('intval', $payload['approver_ids'] ?? []))));
        $note = trim((string)($payload['note'] ?? ''));

        if (!$id || !$userId || empty($approvers))
            return $this->failValidationErrors('Thiếu comment_id, user_id hoặc approver_ids');

        $cm = $this->model->find((int)$id);
        if (!$cm || empty($cm['file_path']))
            return $this->failNotFound('Comment không hợp lệ hoặc không có file.');

        $apvM = new DocumentApprovalModel();
        $stepM = new DocumentApprovalStepModel();

        $db = $apvM->db;
        $db->transBegin();
        try {
            // 1) Tạo phiên (document_id bạn có thể dùng chính comment_id)
            $apvId = $apvM->insert([
                'document_id' => (int)$id,
                'status' => 'pending',
                'created_by' => $userId,
                'current_step_index' => 0,
                'note' => $note ?: 'Gửi duyệt file trong comment',
                'source_type' => 'comment'
            ], true);

            // 2) Tạo các bước
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
            $stepM->insertBatch($batch);

            // 3) Kích hoạt step đầu tiên
            $first = $stepM->where('approval_id', $apvId)->orderBy('sequence', 'ASC')->first();
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
     * @throws ReflectionException
     */
    public function create($task_id = null): ResponseInterface
    {
        $task_id = $task_id ? (int)$task_id : null;
        $userId  = (int)($this->request->getPost('user_id') ?? 0);
        if ($userId <= 0) {
            return $this->failValidationErrors(['user_id' => 'Thiếu user_id.']);
        }

        $content = trim((string)($this->request->getPost('content') ?? ''));
        $mentionsJson = $this->request->getPost('mentions') ?? null;

        /** @var UploadedFile|null $file */
        $file = $this->request->getFile('attachment') ?: $this->request->getFile('file');

        // Nếu không có file -> tạo comment plain
        if (!$file || !$file->isValid() || $file->hasMoved()) {
            // Create text-only comment
            $commentData = [
                'task_id'   => $task_id,
                'user_id'   => $userId,
                'content'   => $content,
                'created_at'=> date('Y-m-d H:i:s'),
            ];

            // nếu muốn lưu mentions raw
            if ($mentionsJson) $commentData['mentions'] = $mentionsJson;

            $taskCommentModel = new TaskCommentModel();
            $inserted = $taskCommentModel->insert($commentData, true);
            if (!$inserted) {
                return $this->failServerError('Không tạo được comment.');
            }

            $commentId = is_int($inserted) ? $inserted : $taskCommentModel->getInsertID();
            $created = $taskCommentModel->find($commentId);

            // merge mentions into roster if provided
            $this->mergeMentionsIntoTaskRoster((int)$task_id, $mentionsJson);

            return $this->respondCreated([
                'comment' => $created
            ]);
        }

        // === Nếu file có, validate size/mime như trước ===
        $sizeKB = (int)ceil(($file->getSize() ?: 0) / 1024);
        if ($sizeKB > $this->maxUploadKB) {
            return $this->failValidationErrors(['attachment' => 'Kích thước vượt giới hạn.']);
        }
        $ctype = $this->guessContentType($file);
        if (!in_array($ctype, $this->allowedMimes, true)) {
            return $this->failValidationErrors(['attachment' => 'Định dạng không được hỗ trợ.']);
        }

        // WP config
        $endpoint = (string) env('WP_MEDIA_ENDPOINT', '');
        $wpUser   = (string) env('WP_USER', '');
        $wpPass   = (string) env('WP_APP_PASSWORD', '');
        if ($endpoint === '' || $wpUser === '' || $wpPass === '') {
            return $this->failServerError('Thiếu cấu hình WP_MEDIA_ENDPOINT / WP_USER / WP_APP_PASSWORD.');
        }

        // Upload binary lên WordPress
        $auth = 'Basic ' . base64_encode($wpUser . ':' . $wpPass);
        $client = Services::curlrequest([
            'timeout'     => 60,
            'http_errors' => false,
            'headers'     => [
                'Authorization' => $auth,
                'Accept'        => 'application/json',
            ],
        ]);

        $clientName = $file->getClientName();
        $resp = $client->post($endpoint, [
            'headers' => [
                'Content-Type'        => $ctype,
                'Content-Disposition' => 'attachment; filename="' . basename($clientName) . '"',
            ],
            'body' => file_get_contents($file->getTempName()),
        ]);

        $code = $resp->getStatusCode();
        $body = (string)$resp->getBody();
        if ($code !== 201) {
            // debug log
            log_message('error', 'WP upload failed: ' . $body);
            return $this->failServerError($body ?: ('WordPress trả mã ' . $code));
        }

        $json  = json_decode($body, true) ?: [];
        $wpUrl = $json['source_url'] ?? ($json['guid']['rendered'] ?? null);
        if (!$wpUrl) {
            return $this->failServerError('Upload thành công nhưng thiếu URL media từ WordPress.');
        }

        // Insert into documents
        $docM     = new DocumentModel();
        $deptId   = $this->resolveDepartmentId($userId);
        $sizeByte = (int)($file->getSize() ?: 0);

        $exist = $docM->where('file_path', $wpUrl)
            ->where('uploaded_by', $userId)
            ->first();

        if ($exist) {
            $docId = (int)$exist['id'];
            $doc = $exist;
        } else {
            $docId = $docM->insert([
                'title'           => $clientName,
                'file_path'       => $wpUrl,
                'file_type'       => 'wp_media',
                'file_size'       => $sizeByte,
                'department_id'   => $deptId,
                'uploaded_by'     => $userId,
                'visibility'      => 'private',
                'tags'            => 'task_upload',
                'approval_status' => 'waiting',
                'source_task_id'  => $task_id ? (int)$task_id : null,
                'created_at'      => date('Y-m-d H:i:s'),
            ], true);

            if (!$docId) $docId = $docM->getInsertID();
            $doc = $docM->find($docId);
        }

        // Tạo comment kèm file info (ghi vào task_comments.file_name, file_path)
        $taskCommentModel = new TaskCommentModel();
        $commentData = [
            'task_id'   => $task_id,
            'user_id'   => $userId,
            'content'   => $content,
            'file_name' => $clientName,
            'file_path' => $wpUrl,
            'created_at'=> date('Y-m-d H:i:s'),
        ];
        if ($mentionsJson) $commentData['mentions'] = $mentionsJson;

        $inserted = $taskCommentModel->insert($commentData, true);
        if (!$inserted) {
            // Nếu fail ở đây, log để debug
            log_message('error', 'Insert task_comment failed: ' . json_encode($taskCommentModel->errors()));
            return $this->failServerError('Không tạo được comment kèm file.');
        }
        $commentId = is_int($inserted) ? $inserted : $taskCommentModel->getInsertID();
        $createdComment = $taskCommentModel->find($commentId);

        // merge mentions into roster
        $this->mergeMentionsIntoTaskRoster((int)$task_id, $mentionsJson);

        // trả về comment kèm file thông tin (FE sẽ dùng files[] để hiển thị)
        $createdComment['files'] = [[
            'file_name' => $doc['title'] ?? $clientName,
            'file_path' => $doc['file_path'] ?? $wpUrl,
        ]];

        return $this->respondCreated([
            'comment' => $createdComment
        ]);
    }



    // ✅ Cập nhật comment
    public function update($id = null)
    {
        $data = [
            'content' => $this->request->getVar('content')
        ];

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond(['message' => 'Comment updated']);
    }

    // ✅ Xoá comment
    public function delete($id = null)
    {
        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Comment deleted']);
    }

    public function inbox(): ResponseInterface
    {
        $uid = (int)($this->request->getGet('user_id') ?? 0);
        if (!$uid) return $this->fail('Missing user_id', 400);

        $page = max(1, (int)($this->request->getGet('page') ?: 1));
        $limit = min(50, (int)($this->request->getGet('limit') ?: 10));
        $offset = ($page - 1) * $limit;

        $db = db_connect();

        try {
            // ⚠️ Nếu bạn đã có cột proposed_by, thêm `OR t.proposed_by = ?` + bind thêm $uid
            $sql = "
            SELECT
              c.id,
              c.task_id,
              c.user_id AS author_id,
              c.content,
              c.created_at,
              t.title AS task_title,
              t.linked_type,
              u.name  AS author_name,
              u.avatar AS author_avatar,
              CASE WHEN EXISTS (
                  SELECT 1 FROM comment_reads cr
                  WHERE cr.comment_id = c.id AND cr.user_id = ?
              ) THEN 0 ELSE 1 END AS is_unread
            FROM task_comments c
            INNER JOIN tasks t ON t.id = c.task_id
            LEFT JOIN users u   ON u.id = c.user_id
            WHERE (t.assigned_to = ? OR t.created_by = ?)
            ORDER BY c.created_at DESC
            LIMIT ? OFFSET ?";

            $rows = $db->query($sql, [$uid, $uid, $uid, $limit, $offset])->getResultArray();

            $countSql = "
            SELECT COUNT(*) AS cnt
            FROM task_comments c
            INNER JOIN tasks t ON t.id = c.task_id
            WHERE (t.assigned_to = ? OR t.created_by = ?)";
            $total = (int)$db->query($countSql, [$uid, $uid])->getRow('cnt');

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
        if (!$uid) return $this->fail('Missing user_id', 400);

        $db = db_connect();
        try {
            $sql = "
          SELECT COUNT(*) AS cnt
          FROM task_comments c
          INNER JOIN tasks t ON t.id = c.task_id
          WHERE (t.assigned_to = ? OR t.created_by = ?)
            AND NOT EXISTS (
              SELECT 1 FROM comment_reads cr
              WHERE cr.comment_id = c.id AND cr.user_id = ?
            )";
            $row = $db->query($sql, [$uid, $uid, $uid])->getRowArray();
            return $this->respond(['unread' => (int)($row['cnt'] ?? 0)]);
        } catch (Throwable $e) {
            log_message('error', 'UnreadCount failed: {msg}', ['msg' => $e->getMessage()]);
            return $this->respond(['unread' => 0]); // đừng văng 500 chỉ vì đếm lỗi
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
        if (!$uid || !$ids) return $this->fail('Missing user_id or comment_ids', 400);

        $readModel = new CommentReadModel();
        $now = date('Y-m-d H:i:s');

        $rows = array_map(fn($cid) => [
            'user_id' => $uid,
            'comment_id' => (int)$cid,
            'read_at' => $now
        ], $ids);

        // insert ignore theo cặp unique (user_id, comment_id)
        foreach ($rows as $r) {
            try {
                $readModel->insert($r, false);
            } catch (Throwable $e) { /* ignore duplicate */
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
        if (!$uid || !$id) return $this->fail('Missing user_id or id', 400);

        $readModel = new CommentReadModel();
        try {
            $readModel->insert([
                'user_id' => $uid,
                'comment_id' => (int)$id,
                'read_at' => date('Y-m-d H:i:s')
            ], false);
        } catch (Throwable) { /* ignore duplicate */
        }

        return $this->respond(['ok' => true]);
    }

    protected function mergeMentionsIntoTaskRoster(int $taskId, ?string $mentionsJson): void
    {
        if (!$mentionsJson) return;
        $arr = json_decode($mentionsJson, true);
        if (!is_array($arr) || empty($arr)) return;

        $norm = [];
        foreach ($arr as $m) {
            if (empty($m['user_id'])) continue;
            $norm[] = [
                'user_id' => (int)$m['user_id'],
                'name' => $m['name'] ?? ('#' . $m['user_id']),
                'role' => in_array($m['role'] ?? 'approve', ['approve', 'sign'], true) ? $m['role'] : 'approve',
            ];
        }
        if (!$norm) return;

        $taskModel = new TaskModel();
        $taskModel->upsertRosterMembers($taskId, $norm);
    }


}
