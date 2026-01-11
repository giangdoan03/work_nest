<?php

namespace App\Models;

use CodeIgniter\Model;

class NotificationTemplateModel extends Model
{
    protected $table = 'notification_templates';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'event', 'title_template', 'message_template', 'url_template'
    ];
}

