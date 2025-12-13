<?php

namespace App\Controllers;

use App\Models\ContractStepTemplateModel;
use CodeIgniter\RESTful\ResourceController;

class ContractStepTemplateController extends ResourceController
{
    protected $modelName = ContractStepTemplateModel::class;
    protected $format    = 'json';

    public function index()
    {
        $page    = (int) ($this->request->getGet('page') ?? 1);
        $perPage = (int) ($this->request->getGet('per_page') ?? 10);

        $data = $this->model
            ->orderBy('step_number', 'ASC')
            ->paginate($perPage, 'default', $page);

        $pager = $this->model->pager;

        return $this->respond([
            'data' => $data,
            'pagination' => [
                'page'     => $pager->getCurrentPage('default'),
                'per_page' => $pager->getPerPage('default'),
                'total'    => $pager->getTotal('default'),
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
            return $this->failNotFound('Không tìm thấy bước mẫu hợp đồng');
        }

        $this->model->update($id, $data);
        return $this->respond(['status' => 'success', 'message' => 'Đã cập nhật']);
    }

    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Không tìm thấy bước mẫu hợp đồng');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['status' => 'success', 'message' => 'Đã xoá']);
    }
}
