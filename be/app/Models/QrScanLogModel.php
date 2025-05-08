<?php
namespace App\Models;

use CodeIgniter\Model;

class QrScanLogModel extends Model
{
    protected $table = 'qr_scan_logs';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'qr_id',
        'tracking_code',
        'short_code',
        'qr_url',
        'type',
        'target_id',
        'user_agent',
        'os',
        'device_type',
        'browser',
        'ip_address',
        'referer',
        'scan_source',
        'is_unique',
        'country',
        'city',
        'latitude',
        'longitude',
        'phone_number',
        'created_at'
    ];
    protected $useTimestamps = false;
    public $timestamps = false;
}
