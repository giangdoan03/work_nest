<?php

namespace App\Models;
use CodeIgniter\Model;

class CommentModel extends Model
{
    protected $table = 'task_comments';
    protected $primaryKey = 'id';
    protected $allowedFields = ['task_id', 'user_id', 'content', 'created_at', 'updated_at'];
    protected $useTimestamps = true;
}
