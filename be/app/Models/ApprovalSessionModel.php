<?php

namespace App\Models;

use CodeIgniter\Model;

class ApprovalSessionModel extends Model
{
    protected $table = 'approval_sessions';
    protected $primaryKey = 'id';

    protected $allowedFields = [
            'task_id',
            'created_by',
            'status'
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    protected $returnType = 'array';
}
