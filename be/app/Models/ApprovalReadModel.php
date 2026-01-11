<?php

namespace App\Models;

use CodeIgniter\Model;

class ApprovalReadModel extends Model
{
    protected $table            = 'approval_reads';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;

    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields = [
        'step_id',
        'user_id',
        'read_at'
    ];

    protected $useTimestamps = false;
}
