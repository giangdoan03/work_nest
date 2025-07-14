<?php

namespace App\Models;
use CodeIgniter\Model;

class DocumentPermissionModel extends Model
{
    protected $table = 'document_permissions';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'document_id', 'shared_with_type', 'shared_with_id', 'permission_type','created_at', 'updated_at'
    ];
    protected $useTimestamps = true;
}