<?php

namespace App\Models;

use CodeIgniter\Model;

class LoyaltyVoucherModel extends Model
{
    protected $table = 'loyalty_vouchers';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'name', 'value', 'quantity', 'issued', 'used', 'max_per_voucher',
        'max_per_user', 'valid_from', 'valid_to', 'duration_after_issued',
        'require_owner', 'is_lucky_draw', 'description', 'image',
        'status', 'user_id', 'created_at', 'updated_at'
    ];
    protected $useTimestamps = true;
    protected $returnType = 'array';
}
