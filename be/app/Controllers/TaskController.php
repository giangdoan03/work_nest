<?php

namespace App\Controllers;

use App\Models\BiddingStepModel;
use App\Models\BiddingStepTemplateModel;
use App\Models\ContractStepModel;
use App\Models\ContractStepTemplateModel;
use App\Models\TaskApprovalModel;
use App\Models\TaskExtensionModel;
use App\Models\TaskModel;
use App\Enums\TaskStatus;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class TaskController extends ResourceController
{
    protected $modelName = TaskModel::class;
    protected $format    = 'json';

    public function index()
    {
        $builder = $this->model->builder();

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

        if ($department = $this->request->getGet('id_department')) {
            $builder->join('users', 'users.id = tasks.assigned_to', 'left');
            $builder->where('users.department_id', $department);
        }

        $totalBuilder = clone $builder;
        $total = $totalBuilder->countAllResults(false);

        $page     = (int) ($this->request->getGet('page') ?? 1);
        $perPage  = (int) ($this->request->getGet('per_page') ?? 10);
        $offset   = ($page - 1) * $perPage;

        $builder->limit($perPage, $offset);
        $tasks = $builder->get()->getResultArray();

        $contractStepTemplates = (new ContractStepTemplateModel())->findAll();
        $biddingStepTemplates  = (new BiddingStepTemplateModel())->findAll();

        $contractMap = [];
        foreach ($contractStepTemplates as $row) {
            $contractMap[$row['step_number']] = $row['title'];
        }

        $biddingMap = [];
        foreach ($biddingStepTemplates as $row) {
            $biddingMap[$row['step_number']] = $row['title'];
        }

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

    public function show($id = null)
    {
        $task = $this->model->find($id);

        if (!$task) {
            return $this->failNotFound('Task not found');
        }

        // Lấy step name (nếu có)
        $stepCode = (int) ($task['step_code'] ?? 0);
        $task['step_name'] = null;

        if ($task['linked_type'] === 'contract') {
            $contractSteps = (new ContractStepTemplateModel())->findAll();
            foreach ($contractSteps as $step) {
                if ((int)$step['step_number'] === $stepCode) {
                    $task['step_name'] = $step['title'];
                    break;
                }
            }
        } elseif ($task['linked_type'] === 'bidding') {
            $biddingSteps = (new BiddingStepTemplateModel())->findAll();
            foreach ($biddingSteps as $step) {
                if ((int)$step['step_number'] === $stepCode) {
                    $task['step_name'] = $step['title'];
                    break;
                }
            }
        }

        // Lấy danh sách extensions
        $extensions = (new TaskExtensionModel())
            ->where('task_id', $id)
            ->findAll();

        $task['extensions'] = $extensions;

        return $this->respond($task);
    }


    /**
     * @throws \ReflectionException
     */
    public function create()
    {
        $data = $this->request->getJSON(true);

        if (!empty($data['approval_steps']) && (int)$data['approval_steps'] > 0) {
            $data['approval_status'] = 'pending';
            $data['current_level'] = 1;

            if ($data['status'] === TaskStatus::DONE) {
                $data['status'] = TaskStatus::REQUEST_APPROVAL;
            }
        }

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        $taskId = $this->model->insertID();

        if (!empty($data['approval_steps']) && (int)$data['approval_steps'] > 0) {
            (new TaskApprovalModel())->insert([
                'task_id' => $taskId,
                'level' => 1,
                'status' => 'pending',
                'approved_by' => null
            ]);
        }

        return $this->respondCreated([
            'message' => 'Task created',
            'id' => $taskId
        ]);
    }

    /**
     * @throws \ReflectionException
     */
    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        $task = $this->model->find($id);

        if (!$task) {
            return $this->failNotFound('Task not found');
        }

        // ❌ Cấm hoàn thành thủ công nếu chưa được duyệt đủ cấp
        if (($data['status'] ?? null) === TaskStatus::DONE) {
            if ((int)$task['approval_steps'] > 0 && $task['approval_status'] !== 'approved') {
                return $this->fail('Không thể chuyển sang trạng thái Hoàn thành trước khi được duyệt');
            }

            if ((int)$task['approval_steps'] > 0) {
                return $this->fail('Nhiệm vụ có cấp duyệt, không thể hoàn thành thủ công');
            }
        }

        // ✅ Gửi duyệt hoặc gửi lại duyệt
        if (($data['status'] ?? null) === TaskStatus::REQUEST_APPROVAL && (int)$task['approval_steps'] > 0) {
            $approvalModel = new TaskApprovalModel();

            // Xoá các dòng duyệt cũ nếu đã từ chối (rejected)
            $approvalModel
                ->where('task_id', $id)
                ->delete();

            // Tạo dòng duyệt mới từ cấp 1
            $approvalModel->insert([
                'task_id'     => $id,
                'level'       => 1,
                'status'      => 'pending',
                'approved_by' => null,
                'approved_at' => null
            ]);

            // Reset lại trạng thái task
            $data['approval_status'] = 'pending';
            $data['current_level'] = 1;
            $data['status'] = TaskStatus::REQUEST_APPROVAL;
        }

        // ✅ Ghi lại lượt gia hạn nếu thay đổi end_date
        $oldEndDate = $task['end_date'] ?? null;
        $newEndDate = $data['end_date'] ?? null;

        if ($oldEndDate && $newEndDate && $oldEndDate !== $newEndDate) {
            $session = session();
            $userId = $session->get('user_id');

            $extensionModel = new TaskExtensionModel();
            $extensionModel->insert([
                'task_id' => $id,
                'extended_by' => $userId,
                'old_end_date' => $oldEndDate,
                'new_end_date' => $newEndDate,
                'reason' => $data['extend_reason'] ?? null,
            ]);
        }

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond(['message' => 'Task updated']);
    }




    public function extendDeadline($id = null): ResponseInterface
    {
        $task = $this->model->find($id);

        if (!$task) {
            return $this->failNotFound('Task not found');
        }

        $data = $this->request->getJSON(true);
        $newEndDate = $data['new_end_date'] ?? null;
        $reason = $data['reason'] ?? null;
        $userId = user_id(); // Assuming auth helper returns current user ID

        if (!$newEndDate) {
            return $this->failValidationErrors(['new_end_date' => 'New end date is required']);
        }

        $extensionModel = new TaskExtensionModel();
        $extensionModel->insert([
            'task_id' => $id,
            'extended_by' => $userId,
            'old_end_date' => $task['end_date'],
            'new_end_date' => $newEndDate,
            'reason' => $reason
        ]);

        $this->model->update($id, [
            'end_date' => $newEndDate
        ]);

        return $this->respond(['message' => 'Deadline extended successfully']);
    }


    public function countExtensions($id = null): ResponseInterface
    {
        $session = session();
        $userId = $session->get('user_id');
        $extensionModel = new TaskExtensionModel();

        $count = $extensionModel
            ->where('task_id', $id)
            ->where('extended_by', $userId)
            ->countAllResults();

        return $this->respond([
            'task_id' => $id,
            'user_id' => $userId,
            'extension_count' => $count
        ]);
    }

    public function getExtensions($id = null): ResponseInterface
    {
        $extensionModel = new TaskExtensionModel();
        $extensions = $extensionModel
            ->where('task_id', $id)
            ->orderBy('created_at', 'DESC')
            ->findAll();

        return $this->respond([
            'task_id' => $id,
            'extensions' => $extensions
        ]);
    }



    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Task not found');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Task deleted']);
    }

    public function subtasks($parent_id): ResponseInterface
    {
        $tasks = $this->model->where('parent_id', $parent_id)->findAll();
        return $this->respond($tasks);
    }

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

    public function deleteSubtask($id = null): ResponseInterface
    {
        $subtask = $this->model->find($id);

        if (!$subtask || !$subtask['parent_id']) {
            return $this->failNotFound('Subtask không tồn tại hoặc không hợp lệ');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Subtask deleted']);
    }

    public function byBiddingStep($step_id): ResponseInterface
    {
        $tasks = $this->model->where('step_id', $step_id)->findAll();
        return $this->respond($tasks);
    }

    public function byContractStep($step_id): ResponseInterface
    {
        $tasks = $this->model->where('step_id', $step_id)->findAll();
        return $this->respond($tasks);
    }

    public function getTaskByBiddingStep($stepId): ResponseInterface
    {
        $step = (new BiddingStepModel())->find($stepId);

        if (!$step || !$step['task_id']) {
            return $this->failNotFound("Không tìm thấy bước hoặc bước chưa gán task.");
        }

        $task = (new TaskModel())->find($step['task_id']);

        return $task ? $this->respond($task) : $this->failNotFound("Task không tồn tại.");
    }


}
