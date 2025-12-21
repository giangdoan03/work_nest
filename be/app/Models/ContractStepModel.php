<?php

// app/Models/ContractStepModel.php
namespace App\Models;

use CodeIgniter\Model;

class ContractStepModel extends Model
{
    protected $table = 'contract_steps';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'contract_id',
        'customer_id',
        'step_number',
        'title',
        'status',
        'assigned_to',
        'start_date',
        'due_date',
        'end_date',
        'completed_at',
        'department',

        // ✅ SKIP WORKFLOW
        'skip_status',
        'skip_reason',
        'skip_requested_by',
        'skip_requested_at',
        'skip_approved_by',
        'skip_approved_at',
    ];

    protected $useTimestamps = true;
}

