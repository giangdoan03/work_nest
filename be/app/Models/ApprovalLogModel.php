<?php

namespace App\Models;

use CodeIgniter\Model;

class ApprovalLogModel extends Model
{
    protected $table = 'approval_logs';
    protected $primaryKey = 'id';
    public $useTimestamps = false; // chỉ có created_at tự set trong controller

    protected $allowedFields = [
        'approval_instance_id',
        'actor_id',
        'action',
        'data_json',
        'created_at',
    ];

    protected array $casts = [
        'data_json' => 'json',
    ];
}
