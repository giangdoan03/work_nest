<?php

namespace App\Controllers;

use App\Models\BiddingStepModel;
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

    public function completeStep($id)
    {
        // Đánh dấu bước hiện tại là hoàn tất
        $this->model->update($id, [
            'is_done' => 1,
            'is_active' => 0
        ]);

        // Tìm bước tiếp theo
        $current = $this->model->find($id);
        if ($current) {
            $next = $this->model
                ->where('step_number >', $current['step_number'])
                ->orderBy('step_number', 'asc')
                ->first();

            if ($next) {
                $this->model->update($next['id'], ['is_active' => 1]);
            }
        }

        return $this->respond(['message' => 'Bước đã hoàn tất và bước tiếp theo đã được mở.']);
    }
}
