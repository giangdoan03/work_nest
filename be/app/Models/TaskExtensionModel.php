<?php

namespace App\Models;
use CodeIgniter\Model;

class TaskExtensionModel extends Model
{
    protected $table = 'task_extensions';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'task_id', 'extended_by', 'old_end_date', 'new_end_date', 'reason'
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
}
