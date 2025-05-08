<?php

namespace App\Controllers;

use App\Models\BusinessModel;
use App\Models\BusinessExtraInfoModel;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class BusinessController extends ResourceController
{
    use AuthTrait;

    protected $modelName = BusinessModel::class;
    protected $format    = 'json';

    public function index()
    {
        $userId = $this->getUserId();

        $perPage = $this->request->getGet('per_page') ?? 10;
        $page = $this->request->getGet('page') ?? 1;
        $search = $this->request->getGet('search');

        $builder = $this->model->where('user_id', $userId);

        if (!empty($search)) {
            $builder->groupStart()
                ->like('name', $search)
                ->groupEnd();
        }

        $data = $builder->paginate($perPage, 'default', $page);

        // 👉 Decode display_settings nếu cần
        $data = array_map(function ($item) {
            if (!empty($item['display_settings']) && is_string($item['display_settings'])) {
                $item['display_settings'] = json_decode($item['display_settings'], true);
            }
            return $item;
        }, $data);

        return $this->respond([
            'data' => $data,
            'pager' => $this->model->pager->getDetails(),
        ]);
    }


    public function show($id = null)
    {
        $userId = $this->getUserId();

        $model = new BusinessModel();
        $extraInfoModel = new BusinessExtraInfoModel();

        $business = $model->find($id);
        if (!$business) {
            return $this->failNotFound('Không tìm thấy doanh nghiệp');
        }

        if ($business['user_id'] != $userId) {
            return $this->failForbidden('Bạn không có quyền xem doanh nghiệp này');
        }

        $business = $this->formatBusinessItem($business);

        $business['extra_info'] = $extraInfoModel->where('business_id', $id)->findAll();

        return $this->respond($business);
    }

    public function create()
    {
        $userId = $this->getUserId();

        $model = new BusinessModel();
        $extraInfoModel = new BusinessExtraInfoModel();

        $data = $this->request->getJSON(true);

        $businessData = $this->cleanBusinessData($data);
        $businessData['user_id'] = $userId;

        // 👉 Encode display_settings nếu có
        if (!empty($data['display_settings'])) {
            $businessData['display_settings'] = is_array($data['display_settings'])
                ? json_encode($data['display_settings'])
                : $data['display_settings'];
        }

        $businessId = $model->insert($businessData);

        $this->saveExtraInfo($businessId, $data['extra_info'] ?? []);

        return $this->respondCreated(['id' => $businessId]);
    }


    public function update($id = null)
    {
        $userId = $this->getUserId();

        $model = new BusinessModel();
        $extraInfoModel = new BusinessExtraInfoModel();

        $data = $this->request->getJSON(true);

        $business = $model->find($id);
        if (!$business) {
            return $this->failNotFound('Doanh nghiệp không tồn tại');
        }
        if ($business['user_id'] != $userId) {
            return $this->failForbidden('Bạn không có quyền sửa doanh nghiệp này');
        }

        $businessData = $this->cleanBusinessData($data);

        // 👉 Encode display_settings nếu có
        if (!empty($data['display_settings'])) {
            $businessData['display_settings'] = is_array($data['display_settings'])
                ? json_encode($data['display_settings'])
                : $data['display_settings'];
        }

        $model->update($id, $businessData);

        $extraInfoModel->where('business_id', $id)->delete();
        $this->saveExtraInfo($id, $data['extra_info'] ?? []);

        return $this->respond(['message' => 'Cập nhật doanh nghiệp thành công']);
    }

    public function delete($id = null)
    {
        $userId = $this->getUserId();

        $model = new BusinessModel();
        $extraInfoModel = new BusinessExtraInfoModel();

        $business = $model->find($id);
        if (!$business) {
            return $this->failNotFound('Doanh nghiệp không tồn tại');
        }
        if ($business['user_id'] != $userId) {
            return $this->failForbidden('Bạn không có quyền xoá doanh nghiệp này');
        }

        $model->delete($id);
        $extraInfoModel->where('business_id', $id)->delete();

        return $this->respondDeleted(['message' => 'Đã xoá doanh nghiệp']);
    }

    private function cleanBusinessData($data)
    {
        return [
            'name' => $data['name'] ?? null,
            'tax_code' => $data['tax_code'] ?? null,
            'country' => $data['country'] ?? null,
            'city' => $data['city'] ?? null,
            'district' => $data['district'] ?? null,
            'ward' => $data['ward'] ?? null,
            'address' => $data['address'] ?? null,
            'phone' => $data['phone'] ?? null,
            'email' => $data['email'] ?? null,
            'website' => $data['website'] ?? null,
            'description' => $data['description'] ?? null,
            'career' => $data['career'] ?? null,
            'facebook_link' => $data['facebook_link'] ?? null,
            'other_links' => $this->encodeJson($data['other_links'] ?? []),
            'logo' => $this->encodeJson($data['logo'] ?? []),
            'cover_image' => $this->encodeJson($data['cover_image'] ?? []),
            'library_images' => $this->encodeJson($data['library_images'] ?? []),
            'video_intro' => $this->encodeJson($data['video_intro'] ?? []),
            'certificate_file' => $this->encodeJson($data['certificate_file'] ?? []),
            'lat' => $data['lat'] ?? null,
            'lng' => $data['lng'] ?? null,
            'extra_info' => $this->encodeJson($data['extra_info'] ?? []),
            'status' => !empty($data['status']) ? 1 : 0,
        ];
    }

    private function encodeJson($value)
    {
        if (is_string($value)) {
            $decoded = json_decode($value, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $value = $decoded;
            }
        }
        return json_encode(is_array($value) ? $value : []);
    }

    private function formatBusinessItem($item)
    {
        foreach (['logo', 'cover_image', 'library_images', 'video_intro', 'certificate_file', 'other_links', 'extra_info'] as $field) {
            $item[$field] = json_decode($item[$field] ?? '[]', true) ?? [];
        }
        return $item;
    }

    private function saveExtraInfo($businessId, $extraInfos)
    {
        $extraInfoModel = new BusinessExtraInfoModel();

        if (!is_array($extraInfos)) {
            $extraInfos = json_decode($extraInfos, true) ?? [];
        }

        foreach ($extraInfos as $info) {
            $extraInfoModel->insert([
                'business_id' => $businessId,
                'title' => $info['title'] ?? '',
                'description' => $info['description'] ?? '',
                'image' => $info['image'] ?? null,
            ]);
        }
    }
}