<?php

namespace App\Models;

use CodeIgniter\Model;

class UserModel extends Model
{
    protected $table      = 'users';
    protected $primaryKey = 'id';

    protected $allowedFields = ['name', 'email', 'phone', 'password', 'role', 'avatar', 'role_id', 'department_id'];

    protected $useTimestamps = true;
    protected $returnType    = 'array'; // ✅ Bắt buộc dùng nếu dùng password_verify()
}
