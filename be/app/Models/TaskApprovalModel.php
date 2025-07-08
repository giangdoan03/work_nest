<?php

namespace App\Models;

use CodeIgniter\Model;

class TaskApprovalModel extends Model
{
    protected $table      = 'task_approvals';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'task_id',
        'level',
        'status',
        'approved_by',
        'approved_at',
        'comment',
    ];

    protected $useTimestamps = false;
}
