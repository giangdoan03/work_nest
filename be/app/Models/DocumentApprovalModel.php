<?php

namespace App\Models;

use CodeIgniter\Model;

class DocumentApprovalModel extends Model
{
    protected $table      = 'document_approvals';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'document_id', 'status', 'created_by',
        'current_step_index', 'note', 'finished_at',
        'created_at', 'updated_at',
        'source_type',
        'signed_pdf_url'
    ];
    protected $useTimestamps = true;
    protected $returnType = 'array';
}
