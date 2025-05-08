<?php

namespace App\Controllers;

use App\Models\CategoryModel;
use CodeIgniter\RESTful\ResourceController;

class CategoryController extends ResourceController
{
    protected $format = 'json';

    /**
     * Danh sách danh mục
     */
    public function index()
    {
        $categoryModel = new CategoryModel();

        $categories = $categoryModel->findAll();

        return $this->respond($categories);
    }

    /**
     * Thêm mới danh mục
     */
    public function create()
    {
        $categoryModel = new CategoryModel();

        $data = $this->request->getJSON(true);

        if (empty($data['name'])) {
            return $this->failValidationErrors('Tên danh mục là bắt buộc');
        }

        $id = $categoryModel->insert([
            'name' => $data['name'],
        ]);

        return $this->respondCreated(['id' => $id, 'message' => 'Thêm danh mục thành công']);
    }

    /**
     * Xem chi tiết danh mục
     */
    public function show($id = null)
    {
        $categoryModel = new CategoryModel();

        $category = $categoryModel->find($id);

        if (!$category) {
            return $this->failNotFound('Danh mục không tồn tại');
        }

        return $this->respond($category);
    }

    /**
     * Cập nhật danh mục
     */
    public function update($id = null)
    {
        $categoryModel = new CategoryModel();

        $data = $this->request->getJSON(true);

        if (empty($data['name'])) {
            return $this->failValidationErrors('Tên danh mục là bắt buộc');
        }

        $categoryModel->update($id, ['name' => $data['name']]);

        return $this->respond(['message' => 'Cập nhật danh mục thành công']);
    }

    /**
     * Xoá danh mục
     */
    public function delete($id = null)
    {
        $categoryModel = new CategoryModel();

        $category = $categoryModel->find($id);

        if (!$category) {
            return $this->failNotFound('Danh mục không tồn tại');
        }

        $categoryModel->delete($id);

        return $this->respondDeleted(['message' => 'Đã xoá danh mục thành công']);
    }
}
