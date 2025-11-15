<?php
namespace App\Models;

use CodeIgniter\Model;

class FileSignatureModel extends Model
{
    protected $table      = 'file_signatures';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'task_file_id','approval_id','signed_file_name','signed_file_path','signed_file_size','signed_mime',
        'signed_by','signed_at','status','note','created_at','updated_at', 'document_id',
    ];
    protected $useTimestamps = false;
}
