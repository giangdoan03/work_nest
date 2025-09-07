<?php

namespace App\Controllers;

use App\Models\SettingModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class SettingController extends ResourceController
{
    use AuthTrait;

    protected $modelName = SettingModel::class;
    protected $format = 'json';

    /**
     * Danh sách tất cả settings theo user.
     */
    public function index()
    {
        $userId = $this->getUserId();
        $settings = $this->model->where('user_id', $userId)->findAll();

        return $this->respond($settings);
    }

    /**
     * Lấy 1 setting theo ID.
     */
    public function show($id = null)
    {
        $userId = $this->getUserId();
        $setting = $this->model->where('id', $id)->where('user_id', $userId)->first();

        return $setting
            ? $this->respond($setting)
            : $this->failNotFound('Không tìm thấy cài đặt');
    }

    /**
     * Lấy 1 setting theo key (dùng cho mẫu bước/thông tin hệ thống).
     * Ví dụ: GET /settings/key/bidding_steps
     */
    public function key($key = null): ResponseInterface
    {
        $userId = $this->getUserId();
        $setting = $this->model->where('key', $key)->where('user_id', $userId)->first();

        return $setting
            ? $this->respond($setting)
            : $this->failNotFound("Không tìm thấy cài đặt với key '{$key}'");
    }

    /**
     * Tạo mới setting.
     */
    public function create()
    {
        $data = $this->request->getJSON(true);
        $data['user_id'] = $this->getUserId();

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        $data['id'] = $this->model->getInsertID();
        return $this->respondCreated($data);
    }

    /**
     * Cập nhật 1 setting theo ID.
     */
    public function update($id = null)
    {
        $userId = $this->getUserId();
        $existing = $this->model->where('id', $id)->where('user_id', $userId)->first();

        if (!$existing) {
            return $this->failNotFound("Không tìm thấy cài đặt để cập nhật");
        }

        $data = $this->request->getJSON(true);
        $this->model->update($id, $data);

        return $this->respond(['id' => $id, 'message' => 'Đã cập nhật']);
    }

    /**
     * Xoá setting theo ID.
     */
    public function delete($id = null)
    {
        $userId = $this->getUserId();
        $existing = $this->model->where('id', $id)->where('user_id', $userId)->first();

        if (!$existing) {
            return $this->failNotFound("Không tìm thấy cài đặt để xoá");
        }

        $this->model->delete($id);
        return $this->respondDeleted(['id' => $id, 'message' => 'Đã xoá']);
    }
}
