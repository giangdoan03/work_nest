<?php

namespace App\Models;

use CodeIgniter\Model;

class StepTemplateModel extends Model
{
    protected $table      = 'bidding_step_templates';
    protected $primaryKey = 'id';

    protected $allowedFields = ['title', 'step_number', 'step_code', 'department','processing_basis', 'processing_detail', 'created_at', 'updated_at'];
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
}
