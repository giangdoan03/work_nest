<?php

// app/Models/DocumentApprovalLogModel.php
namespace App\Models;

use CodeIgniter\Model;

class DocumentApprovalLogModel extends Model
{
    protected $table      = 'document_approval_logs';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'approval_id',
        'document_id',
        'action',
        'acted_by',
        'acted_at',
        'signer_name',
        'signature_url',
        'signed_pdf_url',
        'comment',
    ];
    protected $useTimestamps = false;
}
