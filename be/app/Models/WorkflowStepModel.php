<?php

namespace App\Models;

use CodeIgniter\Model;

class WorkflowStepModel extends Model
{
    protected $table      = 'workflow_steps';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'workflow_id',
        'level',
        'order_index',
        'department_id',
        'position_code',
        'name',
    ];

    protected $useTimestamps = true;
    protected $returnType    = 'array';
}
