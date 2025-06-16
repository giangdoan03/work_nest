<?php

namespace App\Controllers;

use App\Models\BiddingStepModel;
use App\Models\BiddingStepTemplateModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class BiddingStepController extends ResourceController
{
    protected $modelName = BiddingStepModel::class;
    protected $format    = 'json';

    public function index()
    {
        return $this->respond($this->model->orderBy('step_number')->findAll());
    }

    public function show($id = null)
    {
        $step = $this->model->find($id);
        return $step ? $this->respond($step) : $this->failNotFound("Không tìm thấy bước.");
    }

    public function create()
    {
        $data = $this->request->getJSON(true);
        $data['status'] = 0; // Mặc định là 'chưa bắt đầu'
        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }
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
            return $this->failNotFound("Không tìm thấy bước để xoá.");
        }
        return $this->respondDeleted(['message' => 'Đã xoá bước.']);
    }

    public function completeStep($id): ResponseInterface
    {
        // Tìm bước hiện tại
        $current = $this->model->find($id);
        if (!$current) {
            return $this->failNotFound("Không tìm thấy bước.");
        }

        // ✅ Gửi đúng dữ liệu khi update
        $updateData = ['status' => 2];
        if (!$this->model->update($id, $updateData)) {
            return $this->failValidationErrors($this->model->errors());
        }

        // Mở bước tiếp theo nếu có
        $next = $this->model
            ->where('bidding_id', $current['bidding_id'])
            ->where('step_number >', $current['step_number'])
            ->orderBy('step_number', 'asc')
            ->first();

        if ($next) {
            $this->model->update($next['id'], ['status' => 1]);
        }

        return $this->respond(['message' => 'Bước đã hoàn tất và bước tiếp theo đã được mở.']);
    }



    public function cloneFromTemplates($biddingId)
    {
        $templateModel = new BiddingStepTemplateModel();
        $steps = $templateModel->orderBy('step_number')->findAll();

        $newSteps = [];
        foreach ($steps as $step) {
            $newSteps[] = [
                'bidding_id' => $biddingId,
                'step_number' => $step['step_number'],
                'title' => $step['title'],
                'department' => $step['department'] ?? null,
                'status' => $step['step_number'] === 1 ? 1 : 0, // mở bước đầu
                'customer_id' => null
            ];
        }

        $this->model->insertBatch($newSteps);
        return $this->respond(['message' => 'Đã khởi tạo các bước từ mẫu']);
    }

}
