<?php

namespace App\Models;

use CodeIgniter\Model;

class TaskFileModel extends Model
{
    protected $table = 'task_files';
    protected $primaryKey = 'id';
    protected $allowedFields = ['task_id', 'file_name', 'file_path', 'uploaded_by', 'comment_id', 'title', 'link_url', 'is_link'];
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
}
