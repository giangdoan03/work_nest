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
        'action',     // approved | rejected | returned
        'comment',
        'actor_id',
    ];

    protected $useTimestamps = true;
    protected $returnType    = 'array';
}
