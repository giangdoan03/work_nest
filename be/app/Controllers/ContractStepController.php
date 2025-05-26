<?php

// app/Controllers/ContractStepController.php
namespace App\Controllers;

use App\Models\ContractStepModel;
use App\Models\ContractModel;
use CodeIgniter\RESTful\ResourceController;
use App\Models\StepTemplateModel;

class ContractStepController extends ResourceController
{
    protected $modelName = ContractStepModel::class;
    protected $format    = 'json';

    public function index($contractId = null)
    {
        return $this->respond($this->model
            ->where('contract_id', $contractId)
            ->orderBy('step_no', 'ASC')
            ->findAll());
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
        if (!$this->model->find($id)) {
            return $this->failNotFound('Step not found');
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
    public function addStepsFromTemplates($contractId = null)
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
        $maxStepNo = $this->model
                ->where('contract_id', $contractId)
                ->selectMax('step_no')
                ->first()['step_no'] ?? 0;

        $currentStepNo = (int) $maxStepNo;
        $insertedIds = [];

        foreach ($templates as $template) {
            $currentStepNo++;

            $stepData = [
                'contract_id' => $contractId,
                'name'        => $template['name'],
                'step_no'     => $currentStepNo,
                'status'      => 'pending'
            ];

            $id = $this->model->insert($stepData);
            $insertedIds[] = $id;
        }

        return $this->respond([
            'status'    => 'success',
            'message'   => 'Đã thêm bước từ thư viện',
            'step_ids'  => $insertedIds
        ]);
    }


    public function reorder($contractId = null)
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

    public function resequence($contractId = null)
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

}
