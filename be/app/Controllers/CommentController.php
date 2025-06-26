<?php

namespace App\Controllers;

use App\Models\CommentModel;
use App\Models\TaskFileModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Libraries\Uploader;
use Config\Services;

// ✅ Dùng thư viện upload đúng cách

class CommentController extends ResourceController
{
    protected $modelName = CommentModel::class;
    protected $format    = 'json';

    // ✅ Danh sách comment theo task
    public function byTask($task_id): ResponseInterface
    {
        $page  = (int) $this->request->getGet('page') ?: 1;
        $limit = 10;

        // Lấy comment có phân trang
        $comments = $this->model
            ->select('task_comments.*, users.name as user_name')
            ->join('users', 'users.id = task_comments.user_id', 'left')
            ->where('task_comments.task_id', $task_id)
            ->orderBy('task_comments.created_at', 'ASC')
            ->paginate($limit, 'default', $page);

        $pager = Services::pager();

        // Gắn file cho từng comment
        $fileModel = new TaskFileModel();
        foreach ($comments as &$comment) {
            $comment['files'] = $fileModel
                ->where('comment_id', $comment['id'])
                ->findAll();
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
     * @throws \ReflectionException
     */
    public function create($task_id = null)
    {
        $json = $this->request->getPost(); // dùng form-data

        $data = [
            'task_id' => $task_id,
            'user_id' => $json['user_id'] ?? null,
            'content' => $json['content'] ?? null,
        ];

        // Lưu comment
        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        $comment_id = $this->model->getInsertID();

        // ✅ Chỉ cho phép 1 file duy nhất (từ field 'attachment')
        $file = $this->request->getFile('attachment');
        if (is_array($file)) {
            return $this->failValidationErrors('Chỉ được phép upload 1 file.');
        }

        if ($file && $file->isValid() && !$file->hasMoved()) {
            $uploadResult = Uploader::saveFile($file, 'file');

            if ($uploadResult) {
                $fileModel = new TaskFileModel();
                $fileModel->insert([
                    'task_id'     => $task_id,
                    'comment_id'  => $comment_id,
                    'file_name'   => $uploadResult['file_name'],
                    'file_path'   => $uploadResult['file_path'],
                    'uploaded_by' => $json['user_id'] ?? null,
                ]);
            }
        }

        return $this->respondCreated([
            'id'        => $comment_id,
            'task_id'   => $task_id,
            'user_id'   => $json['user_id'] ?? null,
            'content'   => $json['content'] ?? null
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
}
