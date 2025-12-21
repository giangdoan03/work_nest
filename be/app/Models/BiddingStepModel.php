<?php

namespace App\Models;

use CodeIgniter\Model;

class BiddingStepModel extends Model
{
    protected $table = 'bidding_steps';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'bidding_id',
        'step_number',
        'title', 'department',
        'status',
        'customer_id',
        'assigned_to',
        'task_id',
        'start_date',
        'end_date',
        'approval_steps',
        'current_level',
        'approval_status',

        // 👇 THÊM ĐẦY ĐỦ CHO SKIP
        'skip_status',
        'skip_reason',
        'skip_requested_by',
        'skip_requested_at',
        'skip_approved_by',
        'skip_approved_at',
    ];
    protected $useTimestamps = true;
}
