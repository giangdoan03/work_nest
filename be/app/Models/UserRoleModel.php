<?php

namespace App\Models;

use CodeIgniter\Model;

class UserRoleModel extends Model
{
    protected $table = 'user_roles';
    protected $allowedFields = [
        'user_id',
        'department_id',
        'position_id',
        'is_primary',
        'created_at'
    ];
    protected $returnType = 'array';
}
