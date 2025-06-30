<?php

namespace App\Models;
use CodeIgniter\Model;

class TaskModel extends Model
{
    protected $table = 'tasks';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'title', 'description', 'assigned_to', 'start_date', 'end_date', 'status',
        'linked_type', 'linked_id', 'step_code', 'created_by',
        'priority', 'comments_count', 'parent_id', 'step_id'
    ];

    protected $useTimestamps = true;
}
