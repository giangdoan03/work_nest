<?php

namespace App\Models;
use CodeIgniter\Model;

class DocumentModel extends Model
{
    protected $table = 'documents';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'title',
        'file_path',
        'department_id',
        'uploaded_by',
        'approval_status',
        'source_task_id',
        'comment_id',
        'upload_batch',
        'signed_pdf_url',
        'signed_by',
        'signed_at',
        'drive_id',
        'google_file_id',
        'file_size'
    ];

    protected $useTimestamps = true;
}
