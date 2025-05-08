<?php

namespace App\Controllers;

use App\Models\EventModel;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class EventController extends ResourceController
{
    use AuthTrait;

    protected $modelName = EventModel::class;
    protected $format    = 'json';

    public function index()
    {
        $userId = $this->getUserId();
        $perPage = $this->request->getGet('per_page') ?? 10;
        $page = $this->request->getGet('page') ?? 1;
        $search = $this->request->getGet('search');

        $builder = $this->model->where('user_id', $userId);

        if ($search) {
            $builder->like('name', $search);
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
        $data = $this->model->where('user_id', $userId)->find($id);

        if (!$data) {
            return $this->failNotFound('Không tìm thấy sự kiện');
        }

        // Parse JSON fields safely
        $data['images'] = json_decode($data['images'] ?? '[]', true);
        $data['video'] = json_decode($data['video'] ?? '[]', true);
        $data['ticket_options'] = json_decode($data['ticket_options'] ?? '[]', true);
        $data['social_links'] = json_decode($data['social_links'] ?? '{}', true);
        $data['description'] = json_decode($data['description'] ?? '[]', true);
        $data['display_settings'] = json_decode($data['display_settings'] ?? '[]', true);

        return $this->respond($data);
    }

    public function create()
    {
        $userId = $this->getUserId();
        $data = $this->request->getJSON(true);

        if (!isset($data['name'])) {
            return $this->failValidationErrors('Thiếu name');
        }

        $data['user_id'] = $userId;

        // Convert arrays to JSON safely
        $data['images'] = json_encode($data['images'] ?? []);
        $data['video'] = json_encode($data['video'] ?? []);
        $data['ticket_options'] = json_encode($data['ticket_options'] ?? []);
        $data['social_links'] = json_encode($data['social_links'] ?? []);
        $data['banner'] = $data['banner'] ?? '';
        $data['description'] = json_encode($data['description'] ?? []);
        $data['display_settings'] = json_encode($data['display_settings'] ?? []);

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
            return $this->failNotFound('Không tìm thấy sự kiện');
        }

        // Encode fields if provided, otherwise keep old value
        $data['images'] = array_key_exists('images', $data)
            ? json_encode($data['images'])
            : $existing['images'];

        $data['video'] = array_key_exists('video', $data)
            ? json_encode($data['video'])
            : $existing['video'];

        $data['ticket_options'] = array_key_exists('ticket_options', $data)
            ? json_encode($data['ticket_options'])
            : $existing['ticket_options'];

        $data['description'] = array_key_exists('description', $data)
            ? json_encode($data['description'])
            : $existing['description'];

        $data['social_links'] = array_key_exists('social_links', $data)
            ? json_encode($data['social_links'])
            : $existing['social_links'];

        $data['banner'] = array_key_exists('banner', $data)
            ? $data['banner']
            : $existing['banner'];

        $data['display_settings'] = array_key_exists('display_settings', $data)
            ? json_encode($data['display_settings'])
            : $existing['display_settings'];

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
            return $this->failNotFound('Không tìm thấy sự kiện');
        }

        $this->model->delete($id);

        return $this->respondDeleted([
            'id' => $id,
            'message' => 'Đã xoá'
        ]);
    }
}
