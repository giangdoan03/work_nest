<?php

// app/Controllers/ContractStepController.php
namespace App\Controllers;

use App\Models\ContractStepModel;
use App\Models\ContractModel;
use App\Models\ContractStepTemplateModel;
use App\Models\TaskModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Models\StepTemplateModel;

class ContractStepController extends ResourceController
{
    protected $modelName = ContractStepModel::class;
    protected $format    = 'json';

    public function index($contractId = null)
    {
        // Lấy tất cả các bước theo contract_id
        $steps = $this->model
            ->where('contract_id', $contractId)
            ->orderBy('step_number', 'ASC')
            ->findAll();

        $stepIds = array_column($steps, 'id');

        $taskModel = new TaskModel();
        $allTasks = [];

        if (!empty($stepIds)) {
            $allTasks = $taskModel
                ->where('linked_type', 'contract')
                ->whereIn('step_id', $stepIds)
                ->findAll();
        }

        // Nhóm tasks theo step_id
        $tasksGrouped = [];
        foreach ($allTasks as $task) {
            $tasksGrouped[$task['step_id']][] = $task;
        }

        // Gán tasks, task_count, task_done_count cho mỗi bước
        foreach ($steps as &$step) {
            $tasks = $tasksGrouped[$step['id']] ?? [];

            $step['tasks'] = $tasks;
            $step['task_count'] = count($tasks);
            $step['task_done_count'] = count(array_filter($tasks, fn($t) => $t['status'] === 'done'));
        }

        return $this->respond($steps);
    }



    public function create($contractId = null)
    {
        $data = $this->request->getJSON(true);
        $data['contract_id'] = $contractId;

        if (empty($data['name'])) {
            return $this->failValidationErrors(['name' => 'Tên bước không được bỏ trống']);
        }

        $data['status'] = $data['status'] ?? 'pending';
        $id = $this->model->insert($data);
        return $this->respondCreated(['id' => $id]);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        $current = $this->model->find($id);

        if (!$current) {
            return $this->failNotFound('Step not found');
        }

        // Nếu người dùng cố cập nhật thành "Hoàn thành" -> kiểm tra logic
        if (isset($data['status']) && (int)$data['status'] === 2) {
            $unfinishedBefore = $this->model
                ->where('contract_id', $current['contract_id'])
                ->where('step_number <', $current['step_number'])
                ->where('status !=', 2)
                ->countAllResults();

            if ($unfinishedBefore > 0) {
                return $this->fail('Bạn cần hoàn thành tất cả các bước trước.');
            }

            $data['completed_at'] = date('Y-m-d H:i:s');
        }

        // ✅ Tránh update khi không có dữ liệu gì
        if (empty($data)) {
            return $this->failValidationErrors('Không có dữ liệu nào để cập nhật.');
        }

        $this->model->update($id, $data);
        return $this->respond(['status' => 'success', 'message' => 'Step updated']);
    }



    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Step not found');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['status' => 'success', 'message' => 'Step deleted']);
    }
    public function addStepsFromTemplates($contractId = null): ResponseInterface
    {
        $contractModel = new ContractModel();
        if (!$contractModel->find($contractId)) {
            return $this->failNotFound("Không tìm thấy hợp đồng với ID $contractId");
        }

        $templateIds = $this->request->getJSON(true)['template_ids'] ?? [];

        if (empty($templateIds) || !is_array($templateIds)) {
            return $this->failValidationErrors(['template_ids' => 'Danh sách bước mẫu không hợp lệ']);
        }

        // Lấy bước mẫu theo đúng thứ tự người dùng chọn
        $templateModel = new StepTemplateModel();
        $templates = [];
        foreach ($templateIds as $id) {
            $template = $templateModel->find($id);
            if ($template) {
                $templates[] = $template;
            }
        }

        // Lấy step_no lớn nhất hiện tại trong hợp đồng
        $insertedIds = $this->getArr($contractId, $templates);

        return $this->respond([
            'status'    => 'success',
            'message'   => 'Đã thêm bước từ thư viện',
            'step_ids'  => $insertedIds
        ]);
    }


    public function reorder($contractId = null): ResponseInterface
    {
        $contractModel = new ContractModel();
        if (!$contractModel->find($contractId)) {
            return $this->failNotFound("Không tìm thấy hợp đồng với ID $contractId");
        }

        $stepIds = $this->request->getJSON(true)['step_ids'] ?? [];

        if (!is_array($stepIds) || empty($stepIds)) {
            return $this->failValidationErrors(['step_ids' => 'Danh sách bước không hợp lệ']);
        }

        foreach ($stepIds as $index => $stepId) {
            $this->model->update($stepId, ['step_no' => $index + 1]);
        }

        return $this->respond([
            'status' => 'success',
            'message' => 'Đã cập nhật thứ tự bước'
        ]);
    }

    public function resequence($contractId = null): ResponseInterface
    {
        $steps = $this->model
            ->where('contract_id', $contractId)
            ->orderBy('created_at', 'ASC') // có thể đổi sang 'id' nếu muốn
            ->findAll();

        $i = 1;
        foreach ($steps as $step) {
            $this->model->update($step['id'], ['step_no' => $i]);
            $i++;
        }

        return $this->respond([
            'status' => 'success',
            'message' => 'Đã cập nhật lại step_no theo thứ tự',
            'total' => count($steps)
        ]);
    }

    public function cloneFromTemplate($contractId = null): ResponseInterface
    {
        $contractModel = new ContractModel();
        if (!$contractModel->find($contractId)) {
            return $this->failNotFound("Không tìm thấy hợp đồng với ID $contractId");
        }

        $templateModel = new ContractStepTemplateModel();
        $templates = $templateModel->orderBy('step_number')->findAll(); // ✅ Sửa đúng tên cột

        $insertedIds = $this->getArr($contractId, $templates);

        return $this->respond([
            'status'    => 'success',
            'message'   => 'Đã clone các bước từ mẫu',
            'step_ids'  => $insertedIds
        ]);
    }


    /**
     * @param mixed $contractId
     * @param array $templates
     * @return array
     */
    public function getArr(mixed $contractId, array $templates): array
    {
        $max = $this->model
            ->where('contract_id', $contractId)
            ->selectMax('step_number')
            ->first();

        $currentStepNo = isset($max['step_number']) ? (int)$max['step_number'] : 0;
        $insertedIds = [];

        foreach ($templates as $template) {
            $currentStepNo++;

            $stepData = [
                'contract_id'   => $contractId,
                'step_number'   => $template['step_number'] ?? $currentStepNo,
                'title'         => $template['title'] ?? 'Không tên',
                'department'    => $template['department'] ?? null,
                'status'        => '0', // ✔️ để đúng với UI
                'customer_id'   => null,
                'assigned_to'   => null,
                'start_date'    => null,
                'due_date'      => null,
                'completed_at'  => null,
            ];


            $id = $this->model->insert($stepData);
            $insertedIds[] = $id;
        }

        return $insertedIds;
    }

    /**
     * @throws \ReflectionException
     */
    public function complete($id = null): ResponseInterface
    {
        $current = $this->model->find($id);
        if (!$current) {
            return $this->failNotFound("Không tìm thấy bước với ID $id");
        }

        // 🔒 Kiểm tra các bước trước đã hoàn thành chưa
        $unfinishedBefore = $this->model
            ->where('contract_id', $current['contract_id'])
            ->where('step_number <', $current['step_number'])
            ->where('status !=', 2) // 2 = hoàn thành
            ->countAllResults();

        if ($unfinishedBefore > 0) {
            return $this->fail('Bạn cần hoàn thành tất cả các bước trước đó.');
        }

        // ✅ Cập nhật bước hiện tại thành hoàn thành
        $updateData = [
            'status' => 2,
            'completed_at' => date('Y-m-d H:i:s'),
        ];

        if (!$this->model->update($id, $updateData)) {
            return $this->failValidationErrors($this->model->errors());
        }

        // ✅ Mở bước kế tiếp (nếu có)
        $next = $this->model
            ->where('contract_id', $current['contract_id'])
            ->where('step_number >', $current['step_number'])
            ->orderBy('step_number', 'asc')
            ->first();

        if ($next) {
            $this->model->update($next['id'], ['status' => 1]); // 1 = đang xử lý
        }

        return $this->respond([
            'message' => 'Bước đã hoàn thành và bước kế tiếp đã được mở.',
            'step_id' => $id,
            'next_step_id' => $next['id'] ?? null,
        ]);
    }

    public function tasksByStep($stepId): ResponseInterface
    {
        $taskModel = new TaskModel();

        $tasks = $taskModel
            ->where('linked_type', 'contract')
            ->where('step_id', $stepId)
            ->findAll();

        return $this->respond([
            'step_id' => $stepId,
            'tasks' => $tasks
        ]);
    }



}
