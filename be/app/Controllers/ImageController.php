<?php

namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\API\ResponseTrait;
use App\Models\EntityImageModel;

class ImageController extends ResourceController
{
    use ResponseTrait;

    protected $imageModel;
    protected $format = 'json'; // ✅ Bắt buộc để dùng failValidationError()

    public function __construct()
    {
        $this->imageModel = new EntityImageModel();
    }

    public function list($entityType, $entityId)
    {
        $images = $this->imageModel
            ->where('entity_type', $entityType)
            ->where('entity_id', $entityId)
            ->orderBy('id', 'asc')
            ->findAll();

        return $this->respond($images ?: []);
    }

    public function cover($entityType, $entityId): \CodeIgniter\HTTP\ResponseInterface
    {
        $cover = $this->imageModel
            ->where('entity_type', $entityType)
            ->where('entity_id', $entityId)
            ->where('is_cover', 1)
            ->first();

        return $this->respond($cover ?? []);
    }

    /**
     * @throws \ReflectionException
     */
    public function save($entityId)
    {
        $requestData = $this->request->getJSON(true);

        log_message('error', 'saveEntityImages payload: ' . print_r($requestData, true));

        if (!is_array($requestData['images']) || empty($requestData['images'])) {
            return $this->failValidationErrors('Danh sách ảnh không hợp lệ hoặc rỗng');
        }

        $images = $requestData['images'];
        $entityType = $images[0]['entity_type'] ?? null;

        if (!$entityType) {
            return $this->failValidationErrors('Thiếu entity_type');
        }

        // Xoá ảnh cũ
        $this->imageModel
            ->where('entity_type', $entityType)
            ->where('entity_id', $entityId)
            ->delete();

        foreach ($images as &$img) {
            $img['entity_id'] = $entityId;
            $img['entity_type'] = $entityType;
            $img['url'] = (string) ($img['url'] ?? '');
            $img['is_cover'] = (int) ($img['is_cover'] ?? 0);
        }

        $this->imageModel->insertBatch($images);

        return $this->respond(['message' => 'Đã lưu ảnh thành công']);
    }
}
