<?php

namespace App\Models;

use CodeIgniter\Model;

class ApprovalSessionFileModel extends Model
{
    protected $table = 'approval_session_files';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'session_id',
        'file_path',
        'file_name',
        'file_ext'
    ];

    protected $useTimestamps = false;
    protected $returnType = 'array';
}
