<?php

namespace App\Controllers;

use App\Models\SettingModel;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class SettingController extends ResourceController
{
    use AuthTrait;

    protected $modelName = SettingModel::class;
    protected $format = 'json';

    public function index()
    {
        $userId = $this->getUserId();
        $settings = $this->model->where('user_id', $userId)->findAll();

        return $this->respond($settings);
    }

    public function show($id = null)
    {
        $setting = $this->model->find($id);
        return $setting ? $this->respond($setting) : $this->failNotFound('Không tìm thấy cài đặt');
    }

    public function create()
    {
        $data = $this->request->getJSON(true);
        $data['user_id'] = $this->getUserId();

        $this->model->insert($data);
        $data['id'] = $this->model->getInsertID();

        return $this->respondCreated($data);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        $this->model->update($id, $data);

        return $this->respond(['id' => $id, 'message' => 'Đã cập nhật']);
    }

    public function delete($id = null)
    {
        $this->model->delete($id);
        return $this->respondDeleted(['id' => $id, 'message' => 'Đã xoá']);
    }
}
