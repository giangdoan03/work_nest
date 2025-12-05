<?php

namespace App\Models;

use CodeIgniter\Model;

class DocDocumentModel extends Model
{
    protected $table = 'doc_documents';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'title',
        'description',
        'file_url',
        'department_id',
        'created_by',
        'created_at'
    ];

    // ⭐ Lấy danh sách tài liệu kèm allowed_users
    public function getAllWithUsers(): array
    {
        $data = $this->select("
                doc_documents.*,
                (
                    SELECT GROUP_CONCAT(user_id)
                    FROM doc_user_access 
                    WHERE document_id = doc_documents.id
                ) AS allowed_users
            ")
            ->findAll();

        foreach ($data as &$doc) {
            $doc['allowed_users'] = $doc['allowed_users']
                ? array_map('intval', explode(',', $doc['allowed_users']))
                : [];
        }

        return $data;
    }

    // ⭐ Lấy chi tiết tài liệu kèm allowed_users
    public function getByIdWithUsers($id): object|array
    {
        $doc = $this->select("
                doc_documents.*,
                (
                    SELECT GROUP_CONCAT(user_id)
                    FROM doc_user_access 
                    WHERE document_id = doc_documents.id
                ) AS allowed_users
            ")
            ->where("doc_documents.id", $id)
            ->first();

        if ($doc) {
            $doc['allowed_users'] = $doc['allowed_users']
                ? array_map('intval', explode(',', $doc['allowed_users']))
                : [];
        }

        return $doc;
    }
}
