<?php

namespace App\Controllers;

use App\Models\CommentModel;
use App\Models\TaskCommentModel;
use App\Models\TaskFileModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Libraries\Uploader;
use Config\Services;

// ✅ Dùng thư viện upload đúng cách

class CommentController extends ResourceController
{
    protected $modelName = TaskCommentModel::class;
    protected $format    = 'json';

    // ✅ Danh sách comment theo task
    public function byTask($task_id): ResponseInterface
    {
        $page  = (int) $this->request->getGet('page') ?: 1;
        $limit = 10;

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

        // ✅ Nếu có file upload thì xử lý
        $file = $this->request->getFile('attachment');
        if ($file && $file->isValid() && !$file->hasMoved()) {
            $uploadResult = Uploader::saveFile($file, 'file');

            if ($uploadResult) {
                $data['file_name']   = $uploadResult['file_name'];
                $data['file_path']   = $uploadResult['file_path'];
                $data['uploaded_by'] = $json['user_id'] ?? null;
            }
        }

        // ✅ Lưu comment (bao gồm cả file nếu có)
        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        $comment_id = $this->model->getInsertID();

        return $this->respondCreated([
            'id'        => $comment_id,
            'task_id'   => $task_id,
            'user_id'   => $data['user_id'],
            'content'   => $data['content'],
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
}
