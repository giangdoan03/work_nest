<?php

namespace App\Controllers;

use App\Models\CommentModel;
use App\Models\CommentReadModel;
use App\Models\TaskCommentModel;
use App\Models\TaskFileModel;
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
    protected $format    = 'json';

    // cấu hình upload cơ bản
    protected int $maxUploadKB = 8192; // 8MB
    protected array $allowedMimes = [
        // image
        'image/jpeg','image/png','image/gif','image/webp',
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

    private function extToMime(string $ext): ?string {
        $map = [
            'jpg'=>'image/jpeg','jpeg'=>'image/jpeg','png'=>'image/png','gif'=>'image/gif','webp'=>'image/webp',
            'pdf'=>'application/pdf',
            'doc'=>'application/msword',
            'docx'=>'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls'=>'application/vnd.ms-excel',
            'xlsx'=>'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'csv'=>'text/csv',
            'ppt'=>'application/vnd.ms-powerpoint',
            'pptx'=>'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            'zip'=>'application/zip',
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
        $page  = (int) $this->request->getGet('page') ?: 1;
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
            'comments'   => $comments,
            'pagination' => [
                'currentPage' => $pager->getCurrentPage(),
                'totalPages'  => $pager->getPageCount(),
                'totalItems'  => $pager->getTotal(),
                'perPage'     => $limit,
            ]
        ]);
    }




    // ✅ Tạo comment mới (POST /tasks/{task_id}/comments)

    /**
     * @throws ReflectionException
     */

    /** POST /tasks/{task_id}/comments (form-data: user_id, content, attachment?) */
    public function create($task_id = null): ResponseInterface
    {
        $userId  = (int) ($this->request->getPost('user_id') ?? 0);
        $content = trim((string) $this->request->getPost('content', FILTER_UNSAFE_RAW));

        $data = ['task_id' => (int)$task_id, 'user_id' => $userId, 'content' => $content];

        /** @var UploadedFile|null $file */
        $file = $this->request->getFile('attachment');

        if ($file && $file->isValid() && !$file->hasMoved()) {
            // validate size/mime cơ bản
            $sizeKB = (int) ceil(($file->getSize() ?: 0) / 1024);
            if ($sizeKB > $this->maxUploadKB) {
                return $this->failValidationErrors(['attachment' => 'Kích thước vượt giới hạn.']);
            }
            $ctype = $this->guessContentType($file);
            if (!in_array($ctype, $this->allowedMimes, true)) {
                return $this->failValidationErrors(['attachment' => 'Định dạng không được hỗ trợ.']);
            }

            // đẩy binary lên WP
            $endpoint = (string) env('WP_MEDIA_ENDPOINT', '');
            $wpUser   = (string) env('WP_USER', '');
            $wpPass   = (string) env('WP_APP_PASSWORD', '');
            if ($endpoint === '' || $wpUser === '' || $wpPass === '') {
                return $this->failServerError('Thiếu cấu hình WP_MEDIA_ENDPOINT / WP_USER / WP_APP_PASSWORD.');
            }
            $auth   = 'Basic ' . base64_encode($wpUser . ':' . $wpPass);

            $client = Services::curlrequest([
                'timeout'     => 60,
                'http_errors' => false,
                'headers'     => [
                    'Authorization' => $auth,
                    'Accept'        => 'application/json',
                ],
            ]);

            $clientName = $file->getClientName(); // tên gốc để hiển thị
            $resp = $client->post($endpoint, [
                'headers' => [
                    'Content-Type'        => $ctype,
                    'Content-Disposition' => 'attachment; filename="' . basename($clientName) . '"',
                ],
                'body' => file_get_contents($file->getTempName()),
            ]);

            $code = $resp->getStatusCode();
            $body = (string) $resp->getBody();
            if ($code !== 201) {
                // trả về body WP để dễ debug
                return $this->failServerError($body ?: ('WordPress trả mã ' . $code));
            }

            $json  = json_decode($body, true) ?: [];
            $wpUrl = $json['source_url'] ?? ($json['guid']['rendered'] ?? null);
            if (!$wpUrl) return $this->failServerError('Upload thành công nhưng thiếu URL media từ WordPress.');

            // -> lưu vào task_comments
            $data['file_name'] = $clientName;
            $data['file_path'] = $wpUrl;
        }

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respondCreated([
            'id'        => $this->model->getInsertID(),
            'task_id'   => (int)$task_id,
            'user_id'   => $userId,
            'content'   => $content,
            'file_name' => $data['file_name'] ?? null,
            'file_path' => $data['file_path'] ?? null,
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
        $uid = (int) ($this->request->getGet('user_id') ?? 0);
        if (!$uid) return $this->fail('Missing user_id', 400);

        $page   = max(1, (int) ($this->request->getGet('page') ?: 1));
        $limit  = min(50, (int) ($this->request->getGet('limit') ?: 10));
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
            $total = (int) $db->query($countSql, [$uid, $uid])->getRow('cnt');

            return $this->respond([
                'comments' => $rows,
                'pagination' => [
                    'currentPage' => $page,
                    'totalPages'  => (int) ceil($total / $limit),
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
        $uid = (int) ($this->request->getGet('user_id') ?? 0);
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
            return $this->respond(['unread' => (int) ($row['cnt'] ?? 0)]);
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
        $uid = (int) $this->request->getVar('user_id');
        $ids = (array) ($this->request->getVar('comment_ids') ?? []);
        if (!$uid || !$ids) return $this->fail('Missing user_id or comment_ids', 400);

        $readModel = new CommentReadModel();
        $now = date('Y-m-d H:i:s');

        $rows = array_map(fn($cid) => [
            'user_id'    => $uid,
            'comment_id' => (int) $cid,
            'read_at'    => $now
        ], $ids);

        // insert ignore theo cặp unique (user_id, comment_id)
        foreach ($rows as $r) {
            try { $readModel->insert($r, false); } catch (Throwable $e) { /* ignore duplicate */ }
        }

        return $this->respond(['ok' => true, 'marked' => count($rows)]);
    }

    /**
     * POST /comments/{id}/read  body: { user_id: 123 }
     */
    public function markRead($id = null): ResponseInterface
    {
        $uid = (int) $this->request->getVar('user_id');
        if (!$uid || !$id) return $this->fail('Missing user_id or id', 400);

        $readModel = new CommentReadModel();
        try {
            $readModel->insert([
                'user_id' => $uid,
                'comment_id' => (int) $id,
                'read_at' => date('Y-m-d H:i:s')
            ], false);
        } catch (Throwable) { /* ignore duplicate */ }

        return $this->respond(['ok' => true]);
    }


}
