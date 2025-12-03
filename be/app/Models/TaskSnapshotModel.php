<?php

namespace App\Models;

use CodeIgniter\Model;

class TaskSnapshotModel extends Model
{
    protected $table      = 'task_snapshots';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'task_id',
        'snapshot_at',
        'title',
        'description',
        'start_date',
        'end_date',
        'status',
        'priority',
        'approval_status',
        'progress',
        'assigned_to',
        'collaborated_by',
        'assigned_by',
        'proposed_by',
        'created_by',
        'approval_roster_json',
        'latest_upload_batch',
        'latest_files_json',
    ];
}
