<?php

namespace App\Models;

use CodeIgniter\Model;

class TaskCommentModel extends Model
{
    protected $table      = 'task_comments';
    protected $primaryKey = 'id';

    protected $useAutoIncrement = true;
    protected $returnType       = 'array';

    protected $allowedFields = [
        'task_id',
        'user_id',
        'content',
        'comment_id',
        'file_name',
        'file_path',
        'approval_status',
        'approval_sent_by',
        'approval_sent_at',
        'approver_ids','approval_note',
        'created_at',
        'updated_at',
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
}
