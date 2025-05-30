<?php

namespace App\Models;

use CodeIgniter\Model;

class DepartmentModel extends Model
{
    protected $table      = 'departments';
    protected $primaryKey = 'id';
    protected $useTimestamps = true;
    protected $returnType = 'array';

    protected $allowedFields = ['name', 'description'];
}
