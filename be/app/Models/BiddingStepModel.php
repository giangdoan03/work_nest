<?php

namespace App\Models;

use CodeIgniter\Model;

class BiddingStepModel extends Model
{
    protected $table = 'bidding_steps';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'bidding_id', 'step_number', 'title', 'department', 'status', 'customer_id', 'assigned_to', 'task_id', 'start_date', 'end_date'
    ];
    protected $useTimestamps = true;
}
