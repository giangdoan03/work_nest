<?php

namespace App\Controllers;

use App\Models\StoreModel;
use App\Models\ProductModel;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class StoreController extends ResourceController
{
    use AuthTrait;

    protected $modelName = StoreModel::class;
    protected $format    = 'json';

    public function index()
    {
        $userId = $this->getUserId();
        $perPage = $this->request->getGet('per_page') ?? 10;
        $page = $this->request->getGet('page') ?? 1;
        $search = $this->request->getGet('search');

        $builder = $this->model->where('user_id', $userId);

        if ($search) {
            $builder = $builder->like('name', $search);
        }

        $data = $builder->paginate($perPage, 'default', $page);
        $pager = $this->model->pager;

        return $this->respond([
            'data' => $data,
            'pager' => [
                'total' => $pager->getTotal(),
                'per_page' => $perPage,
                'current_page' => $page,
            ]
        ]);
    }

    public function show($id = null)
    {
        $userId = $this->getUserId();
        $store = $this->model->where('user_id', $userId)->find($id);

        if (!$store) {
            return $this->failNotFound('Không tìm thấy cửa hàng');
        }

        $store['products'] = [];

        if (!empty($store['product_ids'])) {
            $productIds = json_decode($store['product_ids'], true);
            if (is_array($productIds) && count($productIds)) {
                $productModel = new ProductModel();

                $products = $productModel
                    ->select('id, name, price, avatar')
                    ->whereIn('id', $productIds)
                    ->findAll();

                $productMap = array_column($products, null, 'id');
                $store['products'] = array_values(array_filter(array_map(
                    fn($id) => $productMap[$id] ?? null,
                    $productIds
                )));
            }
        }

        return $this->respond($store);
    }

    public function create()
    {
        $data = $this->request->getJSON(true);
        $userId = $this->getUserId();

        if (!isset($data['name'])) {
            return $this->failValidationErrors('Thiếu name');
        }

        $data['user_id'] = $userId;
        $data['product_ids'] = $this->prepareProductIds($data['product_ids'] ?? null);

        // 👇 Encode display_settings nếu có
        if (!empty($data['display_settings']) && is_array($data['display_settings'])) {
            $data['display_settings'] = json_encode($data['display_settings']);
        }

        $this->model->insert($data);
        $data['id'] = $this->model->getInsertID();

        return $this->respondCreated($data);
    }


    public function update($id = null)
    {
        $userId = $this->getUserId();
        $data = $this->request->getJSON(true);

        $existing = $this->model->where('user_id', $userId)->find($id);
        if (!$existing) {
            return $this->failNotFound('Không tìm thấy cửa hàng');
        }

        $data['product_ids'] = $this->prepareProductIds($data['product_ids'] ?? null);

        // 👇 Encode display_settings nếu có
        if (!empty($data['display_settings']) && is_array($data['display_settings'])) {
            $data['display_settings'] = json_encode($data['display_settings']);
        }

        $this->model->update($id, $data);

        return $this->respond([
            'id' => $id,
            'message' => 'Đã cập nhật'
        ]);
    }


    public function delete($id = null)
    {
        $userId = $this->getUserId();
        $existing = $this->model->where('user_id', $userId)->find($id);

        if (!$existing) {
            return $this->failNotFound('Không tìm thấy cửa hàng');
        }

        $this->model->delete($id);

        return $this->respondDeleted([
            'id' => $id,
            'message' => 'Đã xoá'
        ]);
    }

    private function prepareProductIds($productIds)
    {
        if (is_array($productIds)) {
            return json_encode($productIds);
        }

        if (is_string($productIds)) {
            $decoded = json_decode($productIds, true);
            return is_array($decoded) ? json_encode($decoded) : null;
        }

        return null;
    }
}
