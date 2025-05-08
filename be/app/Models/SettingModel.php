<?php

namespace App\Models;

use CodeIgniter\Model;

class SettingModel extends Model
{
    protected $table = 'settings';
    protected $primaryKey = 'id';
    protected $allowedFields = ['user_id', 'key', 'value', 'created_at', 'updated_at'];
    protected $useTimestamps = true;
}
