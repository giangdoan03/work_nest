<?php
namespace App\Models;

use CodeIgniter\Model;

class QrCodeModel extends Model
{
    protected $table = 'qr_codes';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'user_id', 'target_type', 'target_id',
        'qr_name', 'qr_url', 'short_code',
        'campaign', 'is_active', 'expires_at',
        'scan_count', 'last_scanned_at',
        'settings_json', 'note', 'qr_id'
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
}
