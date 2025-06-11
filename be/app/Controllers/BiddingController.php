<?php

namespace App\Controllers;

use App\Models\BiddingModel;
use CodeIgniter\RESTful\ResourceController;

class BiddingController extends ResourceController
{
    protected $modelName = BiddingModel::class;
    protected $format = 'json';

    public function index()
    {
        $filters = $this->request->getGet();
        $builder = $this->model;

        if (!empty($filters['status'])) {
            $builder = $builder->where('status', $filters['status']);
        }

        if (!empty($filters['customer_id'])) {
            $builder = $builder->where('customer_id', $filters['customer_id']);
        }

        if (!empty($filters['from'])) {
            $builder = $builder->where('start_date >=', $filters['from']);
        }

        if (!empty($filters['to'])) {
            $builder = $builder->where('end_date <=', $filters['to']);
        }

        if (!empty($filters['search'])) {
            $builder = $builder->groupStart()
                ->like('title', $filters['search'])
                ->orLike('description', $filters['search'])
                ->groupEnd();
        }

        $perPage = (int) ($filters['per_page'] ?? 10);
        $page = (int) ($filters['page'] ?? 1);

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
        $bidding = $this->model->find($id);
        return $bidding ? $this->respond($bidding) : $this->failNotFound("Không tìm thấy gói thầu.");
    }

    public function create()
    {
        $data = $this->request->getJSON(true);

        if (empty($data['title']) || empty($data['customer_id'])) {
            return $this->failValidationErrors([
                'title' => 'Tiêu đề bắt buộc',
                'customer_id' => 'Khách hàng bắt buộc'
            ]);
        }

        if (!in_array($data['status'], ['pending', 'submitted', 'shortlisted', 'awarded', 'lost', 'cancelled'])) {
            return $this->failValidationErrors(['status' => 'Trạng thái không hợp lệ']);
        }

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        $data['id'] = $this->model->getInsertID();
        return $this->respondCreated($data);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }
        return $this->respond(['message' => 'Cập nhật thành công']);
    }

    public function delete($id = null)
    {
        if (!$this->model->delete($id)) {
            return $this->failNotFound("Không tìm thấy gói thầu để xoá.");
        }
        return $this->respondDeleted(['message' => 'Đã xoá gói thầu.']);
    }
}
