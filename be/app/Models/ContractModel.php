<?php

// app/Models/ContractModel.php
namespace App\Models;

use CodeIgniter\Model;

class ContractModel extends Model
{
    protected $table = 'contracts';
    protected $primaryKey = 'id';
    protected $returnType = 'array';

    protected $allowedFields = [
        'title', 'content', 'status',
        'department_id', 'assigned_to',
        'start_date', 'end_date',
        'code', 'bidding_id', 'id_customer', 'description', // ← Thêm đầy đủ các trường cần cập nhật
        'created_at', 'updated_at',
        'department'
    ];
    protected $useTimestamps = true;
}
