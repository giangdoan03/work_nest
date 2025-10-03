<?php

namespace App\Models;

use CodeIgniter\Model;

class TaskFileModel extends Model
{
    protected $table = 'task_files';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'task_id','title','file_name','file_path',
        'file_type','file_size','mime_type','file_ext',
        'wp_media_id','source',
        'uploaded_by','comment_id',
        'link_url','is_link',
        'department_id','visibility','tags',
        'status','approved_by','approved_at','review_note'
    ];
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
}
