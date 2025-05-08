<?php

namespace App\Models;

use CodeIgniter\Model;

class LoyaltyGiftModel extends Model
{
    protected $table = 'loyalty_gifts';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'name', 'image', 'type', 'value', 'description', 'status',
        'user_id', 'created_at', 'updated_at'
    ];
    protected $useTimestamps = true;
    protected $returnType = 'array';
}
