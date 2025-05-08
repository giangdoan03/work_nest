<?php

namespace App\Models;

use CodeIgniter\Model;

class LoyaltyHistoryModel extends Model
{
    protected $table = 'loyalty_histories';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'user_id', 'program_id', 'type', 'description', 'metadata', 'created_at'
    ];
    protected $useTimestamps = false;
    protected $returnType = 'array';
}
