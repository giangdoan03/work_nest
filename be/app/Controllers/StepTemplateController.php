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
        return $this->respond($this->model->orderBy('step_number', 'ASC')->findAll());
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
