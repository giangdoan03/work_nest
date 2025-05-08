<?php

namespace App\Models;

use CodeIgniter\Model;

class EventModel extends Model
{
    protected $table = 'events';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'user_id',
        'name',
        'banner',
        'location',
        'event_mode',
        'is_enabled',
        'start_time',
        'end_time',
        'description',
        'country',
        'city',
        'district',
        'contact_first_name',
        'contact_last_name',
        'contact_phone',
        'contact_email',
        'ticket_options',
        'social_links',
        'images',
        'video',
        'format_type',
        'display_settings'
    ];

    protected $useTimestamps = true;
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';
}
