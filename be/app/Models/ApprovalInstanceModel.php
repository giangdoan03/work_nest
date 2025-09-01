<?php

namespace App\Models;

use CodeIgniter\Model;

class ApprovalInstanceModel extends Model
{
    protected $table = 'approval_instances';
    protected $primaryKey = 'id';
    protected $useTimestamps = true;

    protected $allowedFields = [
        'target_type', 'target_id',
        'version', 'is_active',
        'status', 'current_level',
        'submitted_by', 'submitted_at',
        'finalized_at', 'notes', 'meta_json',
    ];

    // Tự cast JSON & integer
    protected array $casts = [
        'meta_json'     => 'json',
        'current_level' => 'integer',
        'version'       => 'integer',
        'is_active'     => 'integer',
        'target_id'     => 'integer',
    ];
}
