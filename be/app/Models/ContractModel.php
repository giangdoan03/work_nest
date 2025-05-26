<?php

// app/Models/ContractModel.php
namespace App\Models;

use CodeIgniter\Model;

class ContractModel extends Model
{
    protected $table = 'contracts';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'title', 'content', 'status', 'department_id', 'assigned_to',
        'start_date', 'end_date', 'created_at', 'updated_at'
    ];
    protected $useTimestamps = true;
}
