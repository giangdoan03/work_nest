<?php

namespace App\Models;

use CodeIgniter\Model;

class LandingPageModel extends Model
{
    protected $table = 'landing_pages';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'user_id', 'title', 'content', 'status', 'access_count',
    ];
    protected $useTimestamps = true;
}
