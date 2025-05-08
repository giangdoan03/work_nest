<?php

namespace App\Controllers;

use App\Models\PersonModel;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class PersonController extends ResourceController
{
    use AuthTrait;

    protected $modelName = PersonModel::class;
    protected $format = 'json';

    public function index()
    {
        $userId = $this->getUserId();
        $data = $this->model->where('user_id', $userId)->findAll();

        // 👉 Giải mã display_settings cho từng item
        foreach ($data as &$item) {
            if (!empty($item['display_settings']) && is_string($item['display_settings'])) {
                $item['display_settings'] = json_decode($item['display_settings'], true);
            }
        }

        return $this->respond($data);
    }


    public function show($id = null)
    {
        $userId = $this->getUserId();
        $data = $this->model->where('user_id', $userId)->find($id);

        if (!$data) {
            return $this->failNotFound('Không tìm thấy cá nhân');
        }

        // 👉 Decode display_settings nếu muốn trả về dạng array
        if (!empty($data['display_settings']) && is_string($data['display_settings'])) {
            $data['display_settings'] = json_decode($data['display_settings'], true);
        }

        return $this->respond($data);
    }


    public function create()
    {
        $data = $this->request->getJSON(true);
        $userId = $this->getUserId();

        if (!isset($data['name'])) {
            return $this->failValidationErrors('Thiếu name');
        }

        $data['user_id'] = $userId;

        // 👉 Encode display_settings nếu có
        if (!empty($data['display_settings'])) {
            $data['display_settings'] = is_array($data['display_settings'])
                ? json_encode($data['display_settings'])
                : $data['display_settings'];
        }

        $id = $this->model->insert($data);

        return $this->respondCreated(['id' => $id]);
    }


    public function update($id = null)
    {
        $userId = $this->getUserId();
        $data = $this->request->getJSON(true);
        $person = $this->model->where('user_id', $userId)->find($id);

        if (!$person) {
            return $this->failNotFound('Không tìm thấy cá nhân');
        }

        // 👉 Encode display_settings nếu có
        if (!empty($data['display_settings'])) {
            $data['display_settings'] = is_array($data['display_settings'])
                ? json_encode($data['display_settings'])
                : $data['display_settings'];
        }

        $this->model->update($id, $data);
        return $this->respond(['id' => $id, 'message' => 'Đã cập nhật thành công']);
    }


    public function delete($id = null)
    {
        $userId = $this->getUserId();
        $person = $this->model->where('user_id', $userId)->find($id);

        if (!$person) {
            return $this->failNotFound('Không tìm thấy cá nhân');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['id' => $id]);
    }
}
