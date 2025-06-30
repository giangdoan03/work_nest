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

        // --- Load step templates ---
        $contractStepTemplates = [];
        $biddingStepTemplates = [];

        if (!empty($tasks)) {
            $contractTemplateModel = new \App\Models\ContractStepTemplateModel();
            $contractStepTemplates = $contractTemplateModel->findAll();

            $biddingTemplateModel = new \App\Models\BiddingStepTemplateModel();
            $biddingStepTemplates = $biddingTemplateModel->findAll();
        }

        // --- Build map ---
        $contractMap = [];
        foreach ($contractStepTemplates as $row) {
            $contractMap[$row['step_number']] = $row['title'];
        }

        $biddingMap = [];
        foreach ($biddingStepTemplates as $row) {
            $biddingMap[$row['step_number']] = $row['title'];
        }

        // --- Gán step_name ---
        foreach ($tasks as &$task) {
            $stepCode = (int) ($task['step_code'] ?? 0);

            if ($task['linked_type'] === 'contract') {
                $task['step_name'] = $contractMap[$stepCode] ?? null;
            } elseif ($task['linked_type'] === 'bidding') {
                $task['step_name'] = $biddingMap[$stepCode] ?? null;
            } else {
                $task['step_name'] = null;
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
        $tasks = $this->model->where('step_id', $step_id)->findAll();
        return $this->respond($tasks);
    }


    // ✅ Lấy danh sách task theo bước hợp đồng
    public function byContractStep($step_id): ResponseInterface
    {
        $tasks = $this->model->where('step_id', $step_id)->findAll();
        return $this->respond($tasks);
    }

    public function getTaskByBiddingStep($stepId): ResponseInterface
    {
        $stepModel = new \App\Models\BiddingStepModel();
        $step = $stepModel->find($stepId);

        if (!$step || !$step['task_id']) {
            return $this->failNotFound("Không tìm thấy bước hoặc bước chưa gán task.");
        }

        $taskModel = new \App\Models\TaskModel();
        $task = $taskModel->find($step['task_id']);

        return $task ? $this->respond($task) : $this->failNotFound("Task không tồn tại.");
    }
}
