<?php

namespace App\Models;

use CodeIgniter\Model;

class CustomerModel extends Model
{
    protected $table = 'customers';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'name', 'phone', 'email', 'address', 'city',
        'avatar', 'last_interaction', 'created_at', 'updated_at'
    ];
    protected $useTimestamps = true;
}
