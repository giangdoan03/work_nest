<?php

namespace App\Models;

use CodeIgniter\Model;

class ScanHistoryModel extends Model
{
    protected $table      = 'scan_histories';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'user_id', 'object_type', 'object_id', 'scanned_at', 'ip_address', 'device'
    ];
    protected $useTimestamps = true;
}
