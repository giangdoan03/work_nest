<?php

namespace App\Models;

use CodeIgniter\Model;
use ReflectionException;

class UserSignatureModel extends Model
{
    protected $table            = 'user_signatures';
    protected $primaryKey       = 'id';

    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;

    protected $allowedFields    = [
        'user_id',
        'role_name',
        'department_id',
        'preferred_marker',
        'approval_marker',
        'signature_url',
        'approval_order',
        'active',
        'created_at',
        'updated_at'
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    protected $validationRules = [
        'user_id'          => 'required|integer',
        'department_id'    => 'permit_empty|integer',
        'signature_url'    => 'permit_empty|string',
        'preferred_marker' => 'permit_empty|string|max_length[64]',
        'approval_marker'  => 'permit_empty|string|max_length[64]',
        'approval_order'   => 'permit_empty|integer',
        'active'           => 'permit_empty|in_list[0,1]'
    ];

    protected $validationMessages = [];
    protected $skipValidation     = false;

    /**
     * Lấy tất cả chữ ký kiêm nhiệm của user (active = 1) + tên phòng ban
     */
    public function getActiveByUser($userId): array
    {
        return $this->select('user_signatures.*, departments.name AS department_name')
            ->join('departments', 'departments.id = user_signatures.department_id', 'left')
            ->where('user_signatures.user_id', $userId)
            ->where('user_signatures.active', 1)
            ->orderBy('user_signatures.approval_order', 'ASC')
            ->findAll();
    }

    public function getByUserOrder($userId, $order): object|array|null
    {
        return $this->where('user_id', $userId)
            ->where('approval_order', $order)
            ->where('active', 1)
            ->first();
    }

    /**
     * @throws ReflectionException
     */
    public function deactivate($id): bool
    {
        return $this->update($id, ['active' => 0]);
    }

    /**
     * @throws ReflectionException
     */
    public function activate($id): bool
    {
        return $this->update($id, ['active' => 1]);
    }
}
