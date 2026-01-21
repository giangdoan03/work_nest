<?php

namespace App\Models;

use CodeIgniter\Model;

class WorkflowSubmissionModel extends Model
{
    protected $table      = 'workflow_submissions';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'workflow_id',
        'title',
        'description',
        'created_by',
        'department_id',
        'current_step_id',
        'current_level',
        'status',

        'created_at',
        'updated_at',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    protected $returnType = 'array';
}

