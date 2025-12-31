<?php

namespace App\Models;

use CodeIgniter\Model;

class ApprovalSessionApproverModel extends Model
{
    protected $table = 'approval_session_approvers';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'session_id',
        'user_id',
        'department_id',
        'position_id',
        'position_name',
        'approval_order',
        'status',
        'reject_reason',
        'approved_at'

    ];

    protected $useTimestamps = false;
    protected $returnType = 'array';
}
