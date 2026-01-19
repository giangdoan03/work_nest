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
        'status', // draft | pending | approved | rejected
    ];

    protected $useTimestamps = true;
    protected $returnType    = 'array';
}
