<?php

// app/Models/ContractStepModel.php
namespace App\Models;

use CodeIgniter\Model;

class ContractStepModel extends Model
{
    protected $table = 'contract_steps';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'contract_id', 'customer_id', 'step_number', 'title', 'status',
        'assigned_to', 'start_date', 'due_date', 'completed_at', 'department'
    ];
    protected $useTimestamps = true;
}
