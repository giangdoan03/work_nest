<?php

namespace App\Models;

use CodeIgniter\Model;

class StepTemplateModel extends Model
{
    protected $table      = 'bidding_step_templates';
    protected $primaryKey = 'id';

    protected $allowedFields = ['title', 'step_number', 'department', 'created_at', 'updated_at']; // ✅ sửa đúng tên
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
}
