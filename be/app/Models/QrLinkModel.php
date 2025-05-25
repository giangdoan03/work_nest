<?php

namespace App\Models;

use CodeIgniter\Model;

class QrLinkModel extends Model
{
    protected $table = 'qr_links'; // Tên bảng phải đúng
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'qr_id', 'short_code', 'created_at', 'updated_at'
    ];
}
