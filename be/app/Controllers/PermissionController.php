<?php


namespace App\Controllers;

use App\Models\PermissionModel;
use App\Models\RolePermissionModel;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;

class PermissionController extends ResourceController
{
    protected $format = 'json';

    public function matrix(): ResponseInterface
    {
        $roleId = $this->request->getGet('role_id');

        $rolePermModel = new RolePermissionModel();
        $permModel = new PermissionModel();

        // Lấy danh sách toàn bộ permissions
        $allPerms = $permModel->findAll();

        // Tạo mảng mặc định
        $result = [];
        foreach ($allPerms as $perm) {
            [$module, $action] = explode('.', $perm['key_name']);

            if (!isset($result[$module])) {
                $result[$module] = [
                    'view' => false,
                    'create' => false,
                    'update' => false,
                    'delete' => false
                ];
            }

            // Gán false ban đầu
            if (in_array($action, ['view', 'create', 'update', 'delete'])) {
                $result[$module][$action] = false;
            }
        }

        // Lấy quyền đã cấp
        $granted = $rolePermModel->where('role_id', $roleId)->findAll();

        // Gán lại true cho các quyền đã có
        foreach ($granted as $perm) {
            $module = $perm['module'];
            $action = $perm['action'];
            if (isset($result[$module][$action])) {
                $result[$module][$action] = true;
            }
        }

        return $this->respond(['data' => $result]);
    }




    /**
     * @throws \ReflectionException
     */
    public function save()
    {
        $input = $this->request->getJSON(true);
        $roleId = $input['role_id'] ?? null;
        $permissions = $input['permissions'] ?? [];

        $rolePermModel = new RolePermissionModel();

        if (!$roleId || !is_array($permissions)) {
            return $this->response->setStatusCode(400)->setJSON(['message' => 'Thiếu dữ liệu']);
        }

        // Danh sách quyền hiện tại trong DB
        $existing = $rolePermModel->where('role_id', $roleId)->findAll();

        $existingMap = [];
        foreach ($existing as $item) {
            $existingMap[$item['module'] . '.' . $item['action']] = $item['id'];
        }

        $toInsert = [];
        $toDelete = [];

        foreach ($permissions as $module => $actions) {
            foreach ($actions as $action => $checked) {
                $key = $module . '.' . $action;

                if ($checked && !isset($existingMap[$key])) {
                    // Mới => cần thêm
                    $toInsert[] = [
                        'role_id' => $roleId,
                        'module' => $module,
                        'action' => $action,
                    ];
                }

                if (!$checked && isset($existingMap[$key])) {
                    // Trước có, giờ bỏ => cần xoá
                    $toDelete[] = $existingMap[$key];
                }
            }
        }

        if (!empty($toInsert)) {
            $rolePermModel->insertBatch($toInsert);
        }

        if (!empty($toDelete)) {
            $rolePermModel->whereIn('id', $toDelete)->delete();
        }

        return $this->response->setJSON(['message' => 'Lưu quyền thành công']);
    }




}
