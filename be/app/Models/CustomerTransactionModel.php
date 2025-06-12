<?php

namespace App\Models;
use CodeIgniter\Model;

class CustomerTransactionModel extends Model
{
    protected $table = 'customer_transactions';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'customer_id', 'type', 'content', 'interaction_time', 'created_by'
    ];
    protected $useTimestamps = true;
}
