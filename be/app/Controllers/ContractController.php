<?php

namespace App\Controllers;

use App\Models\ContractModel;
use CodeIgniter\RESTful\ResourceController;
use App\Models\ContractStepModel;
use App\Models\UserModel;
use App\Models\BiddingModel;

class ContractController extends ResourceController
{
    protected $modelName = ContractModel::class;
    protected $format    = 'json';

    public function index()
    {
        $filters = $this->request->getGet();
        $builder = $this->model;

        if (!empty($filters['status'])) {
            $builder->where('status', $filters['status']);
        }

        if (!empty($filters['department_id'])) {
            $builder->where('department_id', $filters['department_id']);
        }

        if (!empty($filters['created_from']) && !empty($filters['created_to'])) {
            $builder->where('created_at >=', $filters['created_from'])
                ->where('created_at <=', $filters['created_to']);
        }

        return $this->respond($builder->findAll());
    }

    public function show($id = null)
    {
        $contract = $this->model->find($id);

        if (!$contract) {
            return $this->failNotFound('Contract not found');
        }

        return $this->respond($contract);
    }

    public function create()
    {
        $data = $this->request->getJSON(true);

        if (empty($data['title'])) {
            return $this->failValidationErrors(['title' => 'Title is required']);
        }

        // Nếu tạo từ gói thầu, kiểm tra trạng thái gói thầu
        if (!empty($data['bidding_id'])) {
            $biddingModel = new BiddingModel();
            $bidding = $biddingModel->find($data['bidding_id']);

            if (!$bidding) {
                return $this->failNotFound('Gói thầu không tồn tại');
            }

            if ($bidding['status'] !== 'awarded') {
                return $this->failValidationErrors(['bidding_id' => 'Gói thầu chưa được trúng']);
            }

            $data['customer_id'] = $bidding['customer_id'];
            $data['title'] = $data['title'] ?? $bidding['title'];
        }

        $id = $this->model->insert($data);

        if (!$id) {
            return $this->failServerError('Không thể tạo hợp đồng');
        }

        return $this->respondCreated(['status' => 'success', 'id' => $id]);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);

        if (!$this->model->find($id)) {
            return $this->failNotFound('Contract not found');
        }

        $this->model->update($id, $data);

        return $this->respond(['status' => 'success', 'message' => 'Contract updated']);
    }

    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Contract not found');
        }

        $this->model->delete($id);

        return $this->respondDeleted(['status' => 'success', 'message' => 'Contract deleted']);
    }

    public function stepCount($id = null)
    {
        $contract = $this->model->find($id);
        if (!$contract) {
            return $this->failNotFound("Không tìm thấy hợp đồng");
        }

        $stepModel = new ContractStepModel();
        $count = $stepModel->where('contract_id', $id)->countAllResults();

        return $this->respond([
            'contract_id' => $id,
            'step_count'  => $count
        ]);
    }

    public function stepDetails($id = null)
    {
        $contract = $this->model->find($id);
        if (!$contract) {
            return $this->failNotFound("Không tìm thấy hợp đồng");
        }

        $stepModel = new ContractStepModel();
        $steps = $stepModel
            ->where('contract_id', $id)
            ->orderBy('step_no', 'ASC')
            ->findAll();

        $userModel = new     UserModel();
        $stepList = [];

        foreach ($steps as $step) {
            $assignedUser = $step['assigned_to'] ? $userModel->find($step['assigned_to']) : null;

            $stepList[] = [
                'id'            => (int) $step['id'],
                'step_no'       => (int) $step['step_no'],
                'name'          => $step['name'],
                'status'        => $step['status'],
                'assigned_to'   => $assignedUser['name'] ?? null,
                'file_count'    => 0,
                'comment_count' => 0
            ];
        }

        return $this->respond($stepList);
    }

    public function byCustomer($customerId)
    {
        $contracts = $this->model->where('id_customer', $customerId)->findAll();
        return $this->respond($contracts);
    }
}
