<?php
// File: app/Models/RolePermissionModel.php

namespace App\Models;

use CodeIgniter\Model;

class RolePermissionModel extends Model
{
    protected $table = 'role_permissions';
    protected $allowedFields = ['role_id', 'permission_id'];

    public function getPermissionsByRole($roleId): array
    {
        return $this->where('role_id', $roleId)->findAll();
    }

    public function savePermissions($roleId, $permissionIds): void
    {
        $this->where('role_id', $roleId)->delete();

        foreach ($permissionIds as $module => $actions) {
            foreach ($actions as $action => $checked) {
                if ($checked === 'on') {
                    $key = "$module.$action";
                    $permModel = new \App\Models\PermissionModel();
                    $perm = $permModel->where('key_name', $key)->first();
                    if ($perm) {
                        $this->insert([
                            'role_id' => $roleId,
                            'permission_id' => $perm['id']
                        ]);
                    }
                }
            }
        }
    }

    public function hasPermission($roleId, $keyName): bool
    {
        $db = \Config\Database::connect();

        return $db->table('role_permissions')
                ->join('permissions', 'permissions.id = role_permissions.permission_id')
                ->where('role_permissions.role_id', $roleId)
                ->where('permissions.key_name', $keyName)
                ->countAllResults() > 0;
    }
}