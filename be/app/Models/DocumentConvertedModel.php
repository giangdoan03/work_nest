<?php

namespace App\Models;

use CodeIgniter\Model;

class DocumentConvertedModel extends Model
{
    protected $table = 'documents_converted';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'wp_id',
        'file_url',
        'mime_type',
        'title',
        'size',
        'doc_type',
        'drive_id',
        'task_file_id',
        'uploaded_by',
        'uploader_name',
        'wp_created_at'
    ];
}
