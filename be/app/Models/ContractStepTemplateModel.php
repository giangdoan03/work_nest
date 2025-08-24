<?php

namespace App\Models;

use CodeIgniter\Model;

class ContractStepTemplateModel extends Model
{
    protected $table = 'contract_step_templates';
    protected $primaryKey = 'id';
    protected $allowedFields = ['step_number', 'step_code', 'title', 'department'];
    protected $useTimestamps = true;
}
