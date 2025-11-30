<?php

namespace App\Models;

use CodeIgniter\Model;

class DocumentSignStatusModel extends Model
{
    protected $table = 'document_sign_status';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'converted_id',   // ID từ documents_converted
        'user_id',        // người cần ký
        'user_name',
        'order_index',    // thứ tự duyệt
        'status',         // pending | signed
        'signed_at',
        'created_at'
    ];

    protected $useTimestamps = false;
}
