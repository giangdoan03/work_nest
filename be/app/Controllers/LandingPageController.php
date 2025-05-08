<?php

namespace App\Controllers;

use App\Models\LandingPageModel;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class LandingPageController extends ResourceController
{
    use AuthTrait;

    protected $modelName = LandingPageModel::class;
    protected $format    = 'json';

    public function index()
    {
        $userId = $this->getUserId();
        $perPage = $this->request->getGet('per_page') ?? 10;
        $page = $this->request->getGet('page') ?? 1;
        $search = $this->request->getGet('search');

        $builder = $this->model->where('user_id', $userId);
        if ($search) {
            $builder->like('title', $search);
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
        return $data ? $this->respond($data) : $this->failNotFound('Không tìm thấy landing page');
    }

    public function create()
    {
        $data = $this->request->getJSON(true);
        $data['user_id'] = $this->getUserId();
        $data['status'] = $data['status'] ?? 'draft';

        $this->model->insert($data);
        $data['id'] = $this->model->getInsertID();

        return $this->respondCreated($data);
    }

    public function update($id = null)
    {
        $userId = $this->getUserId();
        $existing = $this->model->where('user_id', $userId)->find($id);
        if (!$existing) {
            return $this->failNotFound('Landing page không tồn tại');
        }

        $data = $this->request->getJSON(true);
        $this->model->update($id, $data);

        return $this->respond(['id' => $id, 'message' => 'Đã cập nhật']);
    }

    public function delete($id = null)
    {
        $userId = $this->getUserId();
        $existing = $this->model->where('user_id', $userId)->find($id);
        if (!$existing) {
            return $this->failNotFound('Landing page không tồn tại');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['id' => $id, 'message' => 'Đã xoá']);
    }
}
