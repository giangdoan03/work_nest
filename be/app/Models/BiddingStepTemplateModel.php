<?php

namespace App\Models;

use CodeIgniter\Model;

class BiddingStepTemplateModel extends Model
{
    protected $table = 'bidding_step_templates';
    protected $primaryKey = 'id';
    protected $allowedFields = ['step_number', 'title', 'department', 'department_ids', 'step_code'];
    protected $useTimestamps = true;
}
