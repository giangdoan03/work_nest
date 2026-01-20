<?php

namespace App\Models;

use CodeIgniter\Model;

class WorkflowLogModel extends Model
{
    protected $table      = 'workflow_logs';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'submission_id',
        'workflow_step_id',
        'action',
        'comment',
        'actor_id',
        'created_at',
    ];

    // ❌ TẮT CI4 TIMESTAMP
    protected $useTimestamps = false;

    protected $returnType = 'array';
}

