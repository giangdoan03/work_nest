<?php

namespace App\Models;

use CodeIgniter\Model;

class WorkflowDocumentModel extends Model
{
    protected $table      = 'workflow_documents';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'submission_id',
        'document_type',
        'document_id',
        'title',
        'created_at',
        'updated_at',
    ];


    protected $useTimestamps = true;
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    protected $returnType = 'array';
}
