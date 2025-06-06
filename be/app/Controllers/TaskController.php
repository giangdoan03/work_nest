<?php

namespace App\Controllers;

use App\Models\TaskModel;
use CodeIgniter\RESTful\ResourceController;

class TaskController extends ResourceController
{
    protected $modelName = TaskModel::class;
    protected $format    = 'json';

    // ✅ Danh sách task (lọc nâng cao)
    public function index()
    {
        $db = \Config\Database::connect();
        $builder = $db->table('tasks');

        // Lọc nâng cao
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

        if ($department = $this->request->getGet('department_id')) {
            $builder->join('users', 'users.id = tasks.assigned_to', 'left');
            $builder->where('users.department_id', $department);
        }

        $tasks = $builder->get()->getResultArray();

        return $this->response->setJSON([
            'status' => 'success',
            'data' => $tasks
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
    public function subtasks($parent_id)
    {
        $tasks = $this->model->where('parent_id', $parent_id)->findAll();
        return $this->respond($tasks);
    }

    // ✅ Cập nhật subtask
    public function updateSubtask($id = null)
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
    public function deleteSubtask($id = null)
    {
        $subtask = $this->model->find($id);

        if (!$subtask || !$subtask['parent_id']) {
            return $this->failNotFound('Subtask không tồn tại hoặc không hợp lệ');
        }

        $this->model->delete($id);

        return $this->respondDeleted(['message' => 'Subtask deleted']);
    }

    // ✅ Lấy danh sách task theo bước đấu thầu
    public function byBiddingStep($step_id)
    {
        $tasks = $this->model->where('bidding_step_id', $step_id)->findAll();
        return $this->respond($tasks);
    }
}
