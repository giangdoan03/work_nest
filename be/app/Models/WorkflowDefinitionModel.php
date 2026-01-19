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
    ];

    protected $useTimestamps = true;
    protected $returnType    = 'array';
}
