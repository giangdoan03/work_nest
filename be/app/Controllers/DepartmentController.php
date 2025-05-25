<?php

namespace App\Controllers;

use App\Models\DepartmentModel;
use CodeIgniter\RESTful\ResourceController;

class DepartmentController extends ResourceController
{
    protected $modelName = DepartmentModel::class;
    protected $format    = 'json';

    public function index()
    {
        return $this->respond($this->model->findAll());
    }

    public function show($id = null)
    {
        $data = $this->model->find($id);
        return $data ? $this->respond($data) : $this->failNotFound('Department not found');
    }

    public function create()
    {
        $data = $this->request->getJSON(true);
        if (!$this->validate(['name' => 'required'])) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        $id = $this->model->insert($data);
        return $this->respondCreated(['id' => $id]);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        if (!$this->model->find($id)) {
            return $this->failNotFound('Department not found');
        }

        $this->model->update($id, $data);
        return $this->respond(['status' => 'success', 'message' => 'Department updated']);
    }

    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Department not found');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['status' => 'success', 'message' => 'Department deleted']);
    }
}
