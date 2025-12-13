<?php

namespace App\Controllers;

use App\Models\StepTemplateModel;
use CodeIgniter\RESTful\ResourceController;

class StepTemplateController extends ResourceController
{
    protected $modelName = StepTemplateModel::class;
    protected $format    = 'json';

    public function index()
    {
        $page    = max(1, (int) ($this->request->getGet('page') ?? 1));
        $perPage = max(1, (int) ($this->request->getGet('per_page') ?? 10));
        $offset  = ($page - 1) * $perPage;

        // Tổng số bản ghi
        $total = $this->model->countAll();

        // Lấy dữ liệu theo trang
        $data = $this->model
            ->orderBy('step_number', 'ASC')
            ->findAll($perPage, $offset);

        return $this->respond([
            'data' => $data,
            'pagination' => [
                'page'     => $page,
                'per_page' => $perPage,
                'total'    => $total,
            ]
        ]);
    }


    public function create()
    {
        $data = $this->request->getJSON(true);

        if (empty($data['title'])) {
            return $this->failValidationErrors(['title' => 'Tên bước không được để trống']);
        }

        $id = $this->model->insert($data);
        return $this->respondCreated(['id' => $id]);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        if (!$this->model->find($id)) {
            return $this->failNotFound('Không tìm thấy bước mẫu');
        }

        $this->model->update($id, $data);
        return $this->respond(['status' => 'success', 'message' => 'Đã cập nhật']);
    }

    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Không tìm thấy bước mẫu');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['status' => 'success', 'message' => 'Đã xoá']);
    }
}
