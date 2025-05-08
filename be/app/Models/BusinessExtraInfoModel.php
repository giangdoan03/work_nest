<?php

namespace App\Models;

use CodeIgniter\Model;

class BusinessExtraInfoModel extends Model
{
    protected $table = 'business_extra_info';
    protected $primaryKey = 'id';
    protected $useTimestamps = true;
    protected $returnType = 'array';
    protected $allowedFields = [
        'business_id', 'title', 'description', 'image'
    ];
}
