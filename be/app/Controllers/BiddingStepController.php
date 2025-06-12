<?php

namespace App\Controllers;

use App\Models\BiddingStepModel;
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
        // Đánh dấu bước hiện tại là hoàn tất
        $this->model->update($id, [
            'status' => 2 // Hoàn thành
        ]);

        // Tìm bước hiện tại
        $current = $this->model->find($id);
        if ($current) {
            $next = $this->model
                ->where('step_number >', $current['step_number'])
                ->orderBy('step_number', 'asc')
                ->first();

            if ($next) {
                $this->model->update($next['id'], ['status' => 1]); // Mở bước tiếp theo
            }
        }

        return $this->respond(['message' => 'Bước đã hoàn tất và bước tiếp theo đã được mở.']);
    }
}
