<?php

// app/Models/ContractModel.php
namespace App\Models;

use CodeIgniter\Model;

class ContractModel extends Model
{
    protected $table = 'contracts';
    protected $primaryKey = 'id';
    protected $returnType = 'array';

    protected $beforeInsert = ['encodeCollaborators'];
    protected $beforeUpdate = ['encodeCollaborators'];

    protected $allowedFields = [
        'title', 'content', 'status',
        'department_id', 'assigned_to',
        'start_date', 'end_date',
        'code', 'bidding_id', 'customer_id', 'description', // ← Thêm đầy đủ các trường cần cập nhật
        'created_at', 'updated_at',
        'department',
        'manager_id',
        'collaborators', // JSON
        'priority',
    ];
    protected $useTimestamps = true;



    protected function encodeCollaborators(array $data): array
    {
        if (array_key_exists('collaborators', $data['data'])) {
            $val = $data['data']['collaborators'];
            if (is_array($val)) {
                $data['data']['collaborators'] = json_encode(array_values($val), JSON_UNESCAPED_UNICODE);
            } elseif ($val === null || $val === '') {
                // chọn 1 trong 2: '[]' hoặc NULL
                $data['data']['collaborators'] = '[]';
            }
        }
        return $data;
    }
}
