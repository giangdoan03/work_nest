<?php

namespace App\Controllers;

use App\Models\CustomerTransactionModel;
use CodeIgniter\RESTful\ResourceController;

class CustomerTransactionController extends ResourceController
{
    protected $modelName = CustomerTransactionModel::class;
    protected $format = 'json';

    /**
     * Lấy danh sách tương tác của 1 khách hàng
     */
    public function byCustomer($customerId)
    {
        $data = $this->model
            ->where('customer_id', $customerId)
            ->orderBy('interaction_time', 'desc')
            ->findAll();

        return $this->respond($data);
    }

    /**
     * Tạo mới tương tác với khách hàng
     */
    public function create()
    {
        $data = $this->request->getJSON(true);

        // Validate đầu vào
        if (!$this->validate([
            'customer_id' => 'required|is_natural_no_zero',
            'type' => 'required|string',
            'interaction_time' => 'required|valid_date',
            'content' => 'permit_empty|string'
        ])) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        $this->model->insert($data);
        $data['id'] = $this->model->getInsertID();

        return $this->respondCreated($data);
    }
}
