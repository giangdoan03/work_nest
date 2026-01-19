<?php

namespace App\Models;

use CodeIgniter\Model;

class WorkflowDocumentModel extends Model
{
    protected $table      = 'workflow_documents';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'submission_id',
        'document_type', // quotation | contract | appendix | ...
        'document_id',
        'title',
    ];

    protected $useTimestamps = true;
    protected $returnType    = 'array';
}
