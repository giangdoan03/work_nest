<?php

namespace App\Models;

use CodeIgniter\Model;

class DocumentApprovalStepModel extends Model
{
    protected $table      = 'document_approval_steps';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'approval_id', 'approver_id', 'sequence',
        'status', 'acted_by', 'acted_at', 'comment',
        'signature_url', 'signed_at',
        'pos_row', 'pos_index', 'order_index',
        'created_at', 'updated_at'
    ];
    protected $useTimestamps = true;
    protected $returnType    = 'array';
}
