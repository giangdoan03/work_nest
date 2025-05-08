<?php

namespace App\Models;

use CodeIgniter\Model;

class BusinessModel extends Model
{
    protected $table = 'businesses';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'name', 'tax_code', 'country', 'city', 'district', 'ward',
        'address', 'phone', 'email', 'website', 'description', 'career',
        'facebook_link', 'other_links', 'logo', 'cover_image',
        'library_images', 'video_intro', 'certificate_file',
        'lat', 'lng', 'extra_info', 'status',
        'created_at', 'updated_at', 'deleted_at', 'user_id', 'display_settings'
    ];

    protected $useTimestamps = true;
    protected $useSoftDeletes = true;
}
