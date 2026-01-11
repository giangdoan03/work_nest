<?php

namespace App\Models;

use CodeIgniter\Model;

class NotificationUserLogModel extends Model
{
    protected $table = 'notification_user_logs';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'notification_id',
        'user_id',
        'read_at'
    ];
}
