<?php

namespace App\Models;

use CodeIgniter\Model;

class BiddingModel extends Model
{
    protected $table = 'biddings';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'title', 'description', 'customer_id', 'estimated_cost', 'status',
        'start_date', 'end_date', 'created_at', 'updated_at', 'assigned_to'
    ];

    protected $useTimestamps = true;
}
