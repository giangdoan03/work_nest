<?php

namespace App\Models;

use CodeIgniter\Model;

class UserModel extends Model
{
    protected $table      = 'users';
    protected $primaryKey = 'id';

    protected $allowedFields = ['name', 'email', 'phone', 'password', 'role', 'avatar', 'role_id', 'department_id',  'signature_url','approval_marker', 'preferred_marker', 'is_multi_role'];

    protected $useTimestamps = true;
    protected $returnType    = 'array';
}
