<?php

namespace App\Controllers;

use App\Models\BiddingStepModel;
use App\Models\ContractStepModel;
use App\Models\TaskModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use Config\Database;

class TaskController extends ResourceController
{
    protected $modelName = TaskModel::class;
    protected $format    = 'json';

    // ✅ Danh sách task (lọc nâng cao)
    public function index()
    {
        $builder = $this->model->builder();

        // --- Lọc nâng cao ---
        if ($assigned = $this->request->getGet('assigned_to')) {
            $builder->where('assigned_to', $assigned);
        }

        if ($created_by = $this->request->getGet('created_by')) {
            $builder->where('created_by', $created_by);
        }

        if ($priority = $this->request->getGet('priority')) {
            $builder->where('priority', $priority);
        }

        if ($status = $this->request->getGet('status')) {
            $builder->where('status', $status);
        }

        if ($end_date = $this->request->getGet('end_date')) {
            $builder->where('end_date <=', $end_date);
        }

        if ($linked_type = $this->request->getGet('linked_type')) {
            $builder->where('linked_type', $linked_type);
        }

        if ($department = $this->request->getGet('department_id')) {
            $builder->join('users', 'users.id = tasks.assigned_to', 'left');
            $builder->where('users.department_id', $department);
        }

        // --- Đếm tổng ---
        $totalBuilder = clone $builder;
        $total = $totalBuilder->countAllResults(false);

        // --- Phân trang ---
        $page     = (int) ($this->request->getGet('page') ?? 1);
        $perPage  = (int) ($this->request->getGet('per_page') ?? 10);
        $offset   = ($page - 1) * $perPage;

        $builder->limit($perPage, $offset);
        $tasks = $builder->get()->getResultArray();

        // --- Lấy step_number từ bảng liên quan ---
        $contractIds = [];
        $biddingIds = [];

        foreach ($tasks as $task) {
            if ($task['linked_type'] === 'contract' && !empty($task['linked_id'])) {
                $contractIds[] = $task['linked_id'];
            } elseif ($task['linked_type'] === 'bidding' && !empty($task['linked_id'])) {
                $biddingIds[] = $task['linked_id'];
            }
        }

        $contractStepMap = [];
        $biddingStepMap = [];

        if (!empty($contractIds)) {
            $contractStepModel = new ContractStepModel();
            $contractSteps = $contractStepModel->whereIn('contract_id', $contractIds)->findAll();
            foreach ($contractSteps as $step) {
                $key = $step['contract_id'] . '|' . str_pad($step['step_number'], 2, '0', STR_PAD_LEFT);
                $contractStepMap[$key] = $step['step_number'];
            }
        }

        if (!empty($biddingIds)) {
            $biddingStepModel = new BiddingStepModel();
            $biddingSteps = $biddingStepModel->whereIn('bidding_id', $biddingIds)->findAll();
            foreach ($biddingSteps as $step) {
                $key = $step['bidding_id'] . '|' . str_pad($step['step_number'], 2, '0', STR_PAD_LEFT);
                $biddingStepMap[$key] = $step['step_number'];
            }
        }

        // Gán step_number vào kết quả
        foreach ($tasks as &$task) {
            if (!isset($task['step_code']) || !isset($task['linked_id'])) {
                $task['step_number'] = null;
                continue;
            }

            $stepNumberCode = substr($task['step_code'], -2); // "contract_step_05" → "05"
            $key = $task['linked_id'] . '|' . $stepNumberCode;

            if ($task['linked_type'] === 'contract') {
                $task['step_number'] = $contractStepMap[$key] ?? null;
            } elseif ($task['linked_type'] === 'bidding') {
                $task['step_number'] = $biddingStepMap[$key] ?? null;
            } else {
                $task['step_number'] = null;
            }
        }

        // --- Trả kết quả ---
        return $this->response->setJSON([
            'status' => 'success',
            'data' => $tasks,
            'pagination' => [
                'total' => $total,
                'page' => $page,
                'per_page' => $perPage,
                'last_page' => ceil($total / $perPage)
            ]
        ]);
    }



    // ✅ Chi tiết 1 task
    public function show($id = null)
    {
        $data = $this->model->find($id);
        return $data ? $this->respond($data) : $this->failNotFound('Task not found');
    }

    // ✅ Tạo task mới
    public function create()
    {
        $data = $this->request->getJSON(true);

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respondCreated([
            'message' => 'Task created',
            'id' => $this->model->insertID()
        ]);
    }

    // ✅ Cập nhật task
    public function update($id = null)
    {
        $data = $this->request->getJSON(true);

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond(['message' => 'Task updated']);
    }

    // ✅ Xoá task
    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Task not found');
        }

        $this->model->delete($id);

        return $this->respondDeleted(['message' => 'Task deleted']);
    }

    // ✅ Danh sách subtask theo task cha
    public function subtasks($parent_id): ResponseInterface
    {
        $tasks = $this->model->where('parent_id', $parent_id)->findAll();
        return $this->respond($tasks);
    }

    // ✅ Cập nhật subtask
    public function updateSubtask($id = null): ResponseInterface
    {
        $subtask = $this->model->find($id);

        if (!$subtask || !$subtask['parent_id']) {
            return $this->failNotFound('Subtask không tồn tại hoặc không hợp lệ');
        }

        $data = $this->request->getJSON(true);

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond(['message' => 'Subtask updated']);
    }

    // ✅ Xoá subtask
    public function deleteSubtask($id = null): ResponseInterface
    {
        $subtask = $this->model->find($id);

        if (!$subtask || !$subtask['parent_id']) {
            return $this->failNotFound('Subtask không tồn tại hoặc không hợp lệ');
        }

        $this->model->delete($id);

        return $this->respondDeleted(['message' => 'Subtask deleted']);
    }

    // ✅ Lấy danh sách task theo bước đấu thầu
    public function byBiddingStep($step_id): ResponseInterface
    {
        $tasks = $this->model->where('bidding_step_id', $step_id)->findAll();
        return $this->respond($tasks);
    }
}
