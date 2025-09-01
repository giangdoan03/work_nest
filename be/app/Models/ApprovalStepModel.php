<?php

namespace App\Models;

use CodeIgniter\Model;

class ApprovalStepModel extends Model
{
    protected $table = 'approval_steps';
    protected $primaryKey = 'id';
    protected $useTimestamps = true;

    protected $allowedFields = [
        'approval_instance_id',
        'level', 'approver_id',
        'status', 'commented_at',
        'note', 'acted_by', 'acted_role',
    ];
}
