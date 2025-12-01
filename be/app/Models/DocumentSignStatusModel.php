<?php

namespace App\Models;

use CodeIgniter\Model;

class DocumentSignStatusModel extends Model
{
    protected $table = 'document_sign_status';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'converted_id',
        'approver_id',      // người được giao ký
        'approver_name',
        'signed_by_id',     // người thực sự ký
        'signed_by_name',
        'order_index',
        'status',
        'version',
        'signed_at',
        'signed_pdf_url',
        'signature_url',
        'task_file_id',
        'created_at'
    ];


    protected $useTimestamps = false;
}
