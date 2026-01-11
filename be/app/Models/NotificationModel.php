<?php

namespace App\Models;

use CodeIgniter\Model;

class NotificationModel extends Model
{
    protected $table      = 'notifications';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'user_id',
        'created_by',
        'type',          // bidding / contract / workflow / non-workflow
        'action_type',
        'title',
        'message',
        'task_id',
        'bid_id',
        'contract_id',
        'step_id',
        'data_json',
        'is_read',
        'created_at'
    ];

}
