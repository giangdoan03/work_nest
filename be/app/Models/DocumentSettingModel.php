<?php

namespace App\Models;
use CodeIgniter\Model;

class DocumentSettingModel extends Model
{
    protected $table = 'document_settings';
    protected $primaryKey = 'id';
    protected $allowedFields = ['key', 'value'];
    public bool $timestamps = false;
}
