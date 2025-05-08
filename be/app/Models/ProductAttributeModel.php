<?php

namespace App\Models;

use CodeIgniter\Model;

class ProductAttributeModel extends Model
{
    protected $table = 'product_attributes';
    protected $primaryKey = 'id';
    protected $allowedFields = ['product_id', 'name', 'value', 'created_at', 'updated_at'];
    protected $useTimestamps = true;
}
