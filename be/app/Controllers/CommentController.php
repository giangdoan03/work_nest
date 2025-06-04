<?php

namespace App\Controllers;

use App\Models\CommentModel;
use App\Models\TaskFileModel;
use CodeIgniter\RESTful\ResourceController;
use App\Libraries\Uploader; // ✅ Dùng thư viện upload đúng cách

class CommentController extends ResourceController
{
    protected $modelName = CommentModel::class;
    protected $format    = 'json';

    // ✅ Danh sách comment theo task
    public function byTask($task_id)
    {
        $comments = $this->model
            ->select('task_comments.*, users.name as user_name')
            ->join('users', 'users.id = task_comments.user_id', 'left')
            ->where('task_id', $task_id)
            ->orderBy('created_at', 'ASC')
            ->findAll();

        return $this->respond($comments);
    }

    // ✅ Tạo comment mới (POST /tasks/{task_id}/comments)
    public function create($task_id = null)
    {
        $json = $this->request->getPost(); // dùng form-data

        $data = [
            'task_id' => $task_id,
            'user_id' => $json['user_id'] ?? null,
            'content' => $json['content'] ?? null,
        ];

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        // ✅ Dùng thư viện Uploader
        $file = $this->request->getFile('attachment');
        $uploadResult = Uploader::saveFile($file, 'file'); // ✅ chỉ rõ 'file'

        if ($uploadResult) {
            $fileModel = new TaskFileModel();
            $fileModel->insert([
                'task_id'     => $task_id,
                'file_name'   => $uploadResult['file_name'],
                'file_path'   => $uploadResult['file_path'],
                'uploaded_by' => $json['user_id'] ?? null,
            ]);
        }

        return $this->respondCreated($data);
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
