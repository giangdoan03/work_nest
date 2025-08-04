<?php

namespace App\Controllers;

use App\Models\DepartmentModel;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;

class DepartmentController extends ResourceController
{
    protected $modelName = DepartmentModel::class;
    protected $format    = 'json';

    public function index(): ResponseInterface
    {
        $departmentId = $this->request->getGet('department_id');
        $query = $this->model;

        if ($departmentId) {
            $query = $query->where('department_id', $departmentId);
        }

        $users = $query->findAll();

        // Optional: xóa mật khẩu
        $users = array_map(function ($user) {
            unset($user['password']);
            return $user;
        }, $users);

        return $this->respond($users);
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
