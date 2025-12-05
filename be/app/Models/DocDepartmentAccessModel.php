<?php

namespace App\Models;

use CodeIgniter\Model;

class DocDepartmentAccessModel extends Model
{
    protected $table = 'document_department_permissions';
    protected $primaryKey = 'id';
    protected $allowedFields = ['document_id', 'department_id'];

    public function departmentHasAccess($docId, $deptId): bool
    {
        if (!$docId || !$deptId) return false;

        return $this->where([
                'document_id' => $docId,
                'department_id' => $deptId
            ])->countAllResults() > 0;
    }

    public function getByDocuments(array $docIds): array
    {
        if (empty($docIds)) {
            return []; // ⛔ tránh IN ()
        }

        return $this->whereIn('document_id', $docIds)->findAll();
    }
}
