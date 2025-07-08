<?php

namespace App\Controllers;

use App\Models\TaskFileModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Libraries\Uploader;

class TaskFileController extends ResourceController
{
    protected $modelName = TaskFileModel::class;
    protected $format    = 'json';

    // ✅ Upload file cho task (cha hoặc con)
    public function upload($task_id = null): ResponseInterface
    {
        $file = $this->request->getFile('file');
        $user_id = $this->request->getPost('user_id');
        $title    = $this->request->getPost('title');

        if (!$file || !$file->isValid()) {
            return $this->failValidationErrors('File không hợp lệ.');
        }

        $upload = Uploader::saveFile($file, 'file');

        if (!$upload) {
            return $this->fail('Lỗi khi lưu file.');
        }

        $this->model->insert([
            'task_id'     => $task_id,
            'title'       => $title,
            'file_name'   => $upload['file_name'],
            'file_path'   => $upload['file_path'],
            'uploaded_by' => $user_id,
        ]);

        return $this->respondCreated([
            'message' => 'Upload thành công',
            'data'    => $upload
        ]);
    }

    // ✅ Lấy danh sách file theo task
    public function byTask($task_id): ResponseInterface
    {
        $files = $this->model->where('task_id', $task_id)->findAll();
        return $this->respond($files);
    }

    // ✅ Xoá file
    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('File không tồn tại');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Đã xoá file']);
    }

    public function uploadLink($task_id = null): ResponseInterface
    {
        $title = $this->request->getPost('title');
        $url   = $this->request->getPost('url'); // ✅ sửa lại thành 'url'
        $user_id = $this->request->getPost('user_id');

        if (!$title || !$url) {
            return $this->failValidationErrors('Thiếu tiêu đề hoặc link.');
        }

        $this->model->insert([
            'task_id'     => $task_id,
            'file_name'   => $title,
            'link_url'    => $url, // ✅ lưu vào cột link_url
            'uploaded_by' => $user_id,
            'is_link'     => 1
        ]);

        return $this->respondCreated(['message' => 'Đã lưu link tài liệu']);
    }



}
