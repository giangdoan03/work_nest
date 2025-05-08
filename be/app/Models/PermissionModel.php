<?php
// File: app/Models/PermissionModel.php

namespace App\Models;

use CodeIgniter\Model;

class PermissionModel extends Model
{
    protected $table = 'permissions';
    protected $allowedFields = ['key_name', 'description'];

    public function groupedPermissions(): array
    {
        $permissions = $this->findAll();
        $grouped = [];

        foreach ($permissions as $p) {
            list($module, $action) = explode('.', $p['key_name']);
            $grouped[$module][$action] = $p['id'];
        }

        return $grouped;
    }
}
