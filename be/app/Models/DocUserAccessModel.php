<?php

namespace App\Models;

use CodeIgniter\Model;

class DocUserAccessModel extends Model
{
    protected $table = 'doc_user_access';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'document_id',
        'user_id',
        'created_at'
    ];

    public function hasAccess($documentId, $userId): bool
    {
        return $this->where('document_id', $documentId)
                ->where('user_id', $userId)
                ->countAllResults() > 0;
    }

    public function getUsersByDocument($documentId): array
    {
        return $this->select('user_id')
            ->where('document_id', $documentId)
            ->findAll();
    }
}
