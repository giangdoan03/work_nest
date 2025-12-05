<?php

namespace App\Models;

use CodeIgniter\Database\BaseResult;
use CodeIgniter\Model;
use ReflectionException;

class EntityMemberModel extends Model
{
    protected $table      = 'entity_members';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'entity_type',
        'entity_id',
        'user_id',
        'created_at'
    ];

    public function exists($type, $entityId, $userId): bool
    {
        return $this->where([
                'entity_type' => $type,
                'entity_id'   => $entityId,
                'user_id'     => $userId
            ])->countAllResults() > 0;
    }

    /**
     * @throws ReflectionException
     */
    public function addMember($type, $entityId, $userId): bool|int|string
    {
        if (!$this->exists($type, $entityId, $userId)) {
            return $this->insert([
                'entity_type' => $type,
                'entity_id'   => $entityId,
                'user_id'     => $userId
            ]);
        }
        return true;
    }

    public function removeMember($type, $entityId, $userId): bool|BaseResult
    {
        return $this->where([
            'entity_type' => $type,
            'entity_id'   => $entityId,
            'user_id'     => $userId
        ])->delete();
    }

    public function listMembers($type, $entityId): array
    {
        return $this->where([
            'entity_type' => $type,
            'entity_id'   => $entityId
        ])->findAll();
    }
}
