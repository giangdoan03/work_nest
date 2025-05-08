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
        $permModel = new PermissionModel();
        $rolePermModel = new RolePermissionModel();

        $allPermissions = $permModel->findAll();
        $granted = $rolePermModel->getPermissionsByRole($roleId); // trả về mảng permission_id

        $result = [];

        foreach ($allPermissions as $perm) {
            [$module, $action] = explode('.', $perm['key_name']);
            if (!isset($result[$module])) {
                $result[$module] = [
                    'view' => false,
                    'create' => false,
                    'update' => false,
                    'delete' => false
                ];
            }

            if (in_array($perm['id'], array_column($granted, 'permission_id'))) {
                $result[$module][$action] = true;
            }
        }

        return $this->respond(['data' => $result]);
    }

    public function save()
    {
        $input = $this->request->getJSON(true); // nhận dữ liệu JSON
        $roleId = $input['role_id'] ?? null;
        $permissions = $input['permissions'] ?? [];

        $rolePermModel = new \App\Models\RolePermissionModel();

        if (! $roleId || ! is_array($permissions)) {
            return $this->response->setStatusCode(400)->setJSON(['message' => 'Thiếu dữ liệu']);
        }

        // Xoá toàn bộ quyền cũ
        $rolePermModel->where('role_id', $roleId)->delete();

        // Lưu mới
        $insertData = [];
        $permModel = new \App\Models\PermissionModel();

        foreach ($permissions as $module => $actions) {
            foreach ($actions as $action => $allowed) {
                if ($allowed) {
                    $keyName = $module . '.' . $action;
                    $perm = $permModel->where('key_name', $keyName)->first();
                    if ($perm) {
                        $insertData[] = [
                            'role_id' => $roleId,
                            'permission_id' => $perm['id'],
                        ];
                    }
                }
            }
        }

        if (!empty($insertData)) {
            $rolePermModel->insertBatch($insertData);
        }

        return $this->response->setJSON(['message' => 'Lưu quyền thành công']);
    }


}
