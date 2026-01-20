<?php

namespace App\Models;

use CodeIgniter\Model;

class WorkflowDefinitionModel extends Model
{
    protected $table      = 'workflow_definitions';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'code',
        'name',
        'description',
        'created_at',
        'updated_at',
    ];

    protected $useTimestamps = true;
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    protected $returnType = 'array';
}
