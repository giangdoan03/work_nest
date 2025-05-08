<?php

namespace App\Models;

use CodeIgniter\Model;

class PersonModel extends Model
{
    protected $table = 'persons';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'user_id',
        'name',
        'first_name',
        'last_name',
        'avatar',
        'phone',
        'email',
        'job_title',
        'bio',
        'website',
        'country',
        'address',
        'social_links',
        'display_settings',
        'video_url',
        'created_at',
        'updated_at'
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
}
