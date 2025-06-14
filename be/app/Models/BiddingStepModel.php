<?php

namespace App\Models;

use CodeIgniter\Model;

class BiddingStepModel extends Model
{
    protected $table = 'bidding_steps';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'step_number', 'title', 'department', 'status', 'customer_id'
    ];
    protected $useTimestamps = true;
}
