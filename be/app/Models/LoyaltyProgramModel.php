<?php

namespace App\Models;

use CodeIgniter\Model;

class LoyaltyProgramModel extends Model
{
    protected $table = 'loyalty_programs';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'user_id',
        'name',
        'description',
        'banner',
        'images',
        'video',
        'status',
        'social_links',
        'display_settings',
        'start_time',
        'end_time',
        'created_at',
        'updated_at'
    ];

    protected $useTimestamps = true;
    protected $useSoftDeletes = false;
    protected $returnType = 'array';
}
