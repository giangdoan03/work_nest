<?php

namespace App\Controllers;

use App\Models\LoyaltyProgramModel;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class LoyaltyProgramController extends ResourceController
{
    use AuthTrait;

    protected $modelName = LoyaltyProgramModel::class;
    protected $format    = 'json';

    public function index()
    {
        $userId = $this->getUserId();
        $perPage = $this->request->getGet('per_page') ?? 10;
        $page = $this->request->getGet('page') ?? 1;
        $search = $this->request->getGet('search');

        $builder = $this->model->where('user_id', $userId);
        if ($search) {
            $builder->like('name', $search);
        }

        $data = $builder->paginate($perPage, 'default', $page);
        $pager = $this->model->pager;

        return $this->respond([
            'data' => $data,
            'pager' => [
                'total' => $pager->getTotal(),
                'per_page' => $perPage,
                'current_page' => $page,
            ]
        ]);
    }

    public function show($id = null)
    {
        $userId = $this->getUserId();
        $data = $this->model->where('user_id', $userId)->find($id);
        if (!$data) return $this->failNotFound('Không tìm thấy chương trình');

        foreach (['images','video','social_links','description','display_settings'] as $field) {
            $data[$field] = json_decode($data[$field] ?? '[]', true);
        }

        return $this->respond($data);
    }

    public function create()
    {
        $userId = $this->getUserId();
        $data = $this->request->getJSON(true);
        $data['user_id'] = $userId;

        foreach (['images','video','social_links','description','display_settings'] as $field) {
            $data[$field] = json_encode($data[$field] ?? []);
        }

        $data['banner'] = $data['banner'] ?? '';

        $this->model->insert($data);
        $data['id'] = $this->model->getInsertID();
        return $this->respondCreated($data);
    }

    public function update($id = null)
    {
        $userId = $this->getUserId();
        $data = $this->request->getJSON(true);
        $existing = $this->model->where('user_id', $userId)->find($id);
        if (!$existing) return $this->failNotFound('Không tìm thấy chương trình');

        foreach (['images','video','social_links','description','display_settings'] as $field) {
            if (array_key_exists($field, $data)) {
                $data[$field] = json_encode($data[$field]);
            }
        }

        if (array_key_exists('banner', $data)) {
            $data['banner'] = $data['banner'];
        }

        $this->model->update($id, $data);
        return $this->respond(['id' => $id, 'message' => 'Đã cập nhật']);
    }

    public function delete($id = null)
    {
        $userId = $this->getUserId();
        $existing = $this->model->where('user_id', $userId)->find($id);
        if (!$existing) return $this->failNotFound('Không tìm thấy chương trình');

        $this->model->delete($id);
        return $this->respondDeleted(['id' => $id, 'message' => 'Đã xoá']);
    }
}
