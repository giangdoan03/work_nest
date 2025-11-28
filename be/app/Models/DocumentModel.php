<?php

namespace App\Models;
use CodeIgniter\Model;

class DocumentModel extends Model
{
    protected $table = 'documents';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'title', 'file_path', 'file_type', 'doc_type', 'file_size', 'department_id',
        'uploaded_by', 'visibility', 'tags', 'current_level', 'approval_status', 'source_task_id', 'comment_id', 'upload_batch',
        'signed_pdf_url', 'signed_by', 'signed_at', 'drive_id', 'item_id', 'google_file_id'
    ];
    protected $useTimestamps = true;
}
