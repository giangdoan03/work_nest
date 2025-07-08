<?php

namespace App\Models;

use CodeIgniter\Model;

class TaskApprovalLogModel extends Model
{
    protected $table            = 'task_approval_logs';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;

    protected $allowedFields = [
        'task_id',
        'level',
        'status',
        'approved_by',
        'approved_at',
        'comment'
    ];

    protected $useTimestamps = false;
}
