<?php

namespace App\Models;
use CodeIgniter\Model;

class DocumentModel extends Model
{
    protected $table = 'documents';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'title', 'file_path', 'file_type', 'file_size', 'department_id',
        'uploaded_by', 'visibility', 'tags'
    ];
    protected $useTimestamps = true;
}
