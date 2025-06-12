<?php

namespace App\Controllers;

use App\Models\CustomerModel;
use CodeIgniter\RESTful\ResourceController;

class CustomerController extends ResourceController
{
    protected $modelName = CustomerModel::class;
    protected $format = 'json';

    public function index()
    {
        $perPage = (int) ($this->request->getGet('per_page') ?? 10);
        $page = (int) ($this->request->getGet('page') ?? 1);
        $search = $this->request->getGet('search');
        $from = $this->request->getGet('from');
        $to = $this->request->getGet('to');
        $group = $this->request->getGet('group');
        $assigned = $this->request->getGet('assigned_to');

        $builder = $this->model;

        // Tìm kiếm tên, sđt, email
        if ($search) {
            $builder = $builder->groupStart()
                ->like('name', $search)
                ->orLike('phone', $search)
                ->orLike('email', $search)
                ->groupEnd();
        }

        // Lọc theo ngày tạo
        if ($from) {
            $builder = $builder->where('created_at >=', $from);
        }
        if ($to) {
            $builder = $builder->where('created_at <=', $to);
        }

        // Lọc theo nhóm
        if ($group) {
            $builder = $builder->where('customer_group', $group);
        }

        // Lọc theo người phụ trách nếu có
        if ($assigned !== null && $assigned !== '') {
            $builder = $builder->where('assigned_to', $assigned);
        }

        // Nếu KHÔNG truyền assigned_to → không lọc gì thêm → lấy toàn bộ
        // => đoạn session() lọc theo user_id đã được loại bỏ

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
        $data = $this->model->find($id);
        return $data ? $this->respond($data) : $this->failNotFound('Không tìm thấy khách hàng');
    }

    public function create()
    {
        $data = $this->request->getJSON(true);

        if (!$this->validate([
            'name' => 'required',
            'phone' => 'required|min_length[9]'
        ])) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        $this->model->insert($data);
        $data['id'] = $this->model->getInsertID();
        return $this->respondCreated($data);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);

        if (!$this->validate([
            'name' => 'permit_empty|string'
        ])) {
            return $this->failValidationErrors($this->validator->getErrors());
        }


        $this->model->update($id, $data);
        return $this->respond(['id' => $id, 'message' => 'Đã cập nhật']);
    }

    public function delete($id = null)
    {
        $this->model->delete($id);
        return $this->respondDeleted(['id' => $id, 'message' => 'Đã xoá']);
    }

    // Lấy toàn bộ khách hàng (dành cho dropdown hoặc nội bộ)
    public function all()
    {
        return $this->respond($this->model->findAll());
    }
}
