<?php

namespace App\Models;

use CodeIgniter\Model;

class DepartmentUserModel extends Model
{
    protected $table = 'department_user';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'department_id',
        'user_id',
        'role_in_department',
        'created_at',
        'updated_at'
    ];

    protected $useTimestamps = true;
}
