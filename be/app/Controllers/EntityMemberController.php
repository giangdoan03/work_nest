<?php

namespace App\Controllers;

use App\Models\EntityMemberModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class EntityMemberController extends ResourceController
{
    protected $modelName = EntityMemberModel::class;
    protected $format    = 'json';


    private function ensureCanManageEntity(
        string $entityType,
        int $entityId
    ): ?ResponseInterface
    {
        $user = currentUser(); // helper bạn đang dùng
        if (!$user) {
            return $this->failForbidden('Không xác định người dùng');
        }

        // Admin luôn có quyền
        if (!empty($user['is_admin'])) {
            return null;
        }

        $uid = (int) $user['id'];

        $canManage = false;

        switch ($entityType) {
            case 'bidding':
                $db = db_connect();
                $row = $db->table('biddings')
                    ->select('id')
                    ->where('id', $entityId)
                    ->groupStart()
                    ->where('created_by', $uid)
                    ->orWhere('manager_id', $uid)
                    ->orWhere('assigned_to', $uid)
                    ->groupEnd()
                    ->get()
                    ->getRow();

                $canManage = (bool) $row;
                break;

            default:
                return $this->failForbidden('Entity không hợp lệ');
        }

        if (!$canManage) {
            return $this->failForbidden('Bạn không có quyền thực hiện thao tác này');
        }

        return null;
    }


    /**
     * Check admin permission once
     */
    private function ensureAdmin(): ?ResponseInterface
    {
        if ($err = requireAdmin()) {
            return $this->failForbidden($err['message']);
        }
        return null;
    }

    /**
     * Validate required fields
     */
    private function validatePayload(array $data): array
    {
        $entityType = $data['entity_type'] ?? null;
        $entityId   = $data['entity_id'] ?? null;
        $userId     = $data['user_id'] ?? null;

        if (!$entityType || !$entityId || !$userId) {
            return [false, "Missing parameters"];
        }

        return [true, compact('entityType', 'entityId', 'userId')];
    }

    /**
     * ⭐ CENTRALIZED handler for ADD / REMOVE
     */
    private function handleMemberAction(callable $action): ResponseInterface
    {
        // 1️⃣ Lấy payload
        $data = $this->request->getJSON(true) ?? [];

        // 2️⃣ Validate
        [$ok, $payload] = $this->validatePayload($data);
        if (!$ok) return $this->fail($payload);

        ['entityType' => $type, 'entityId' => $id, 'userId' => $user] = $payload;

        // 3️⃣ CHECK QUYỀN ĐÚNG NGHIỆP VỤ (thay cho ensureAdmin)
        if ($res = $this->ensureCanManageEntity($type, (int)$id)) {
            return $res;
        }

        // 4️⃣ Thực thi action
        $action($type, (int)$id, (int)$user);

        // 5️⃣ Response
        return $this->respond([
            'message' => 'Success',
            'data' => $payload
        ]);
    }


    /**
     * ⭐ Add user to entity
     */
    public function add(): ResponseInterface
    {
        return $this->handleMemberAction(
            fn($type, $id, $user) => $this->model->addMember($type, $id, $user)
        );
    }

    /**
     * ⭐ Remove user from entity
     */
    public function remove(): ResponseInterface
    {
        return $this->handleMemberAction(
            fn($type, $id, $user) => $this->model->removeMember($type, $id, $user)
        );
    }

    /**
     * List users allowed to access the entity
     */
    public function list($entityType, $entityId): ResponseInterface
    {
        return $this->respond(
            $this->model->listMembers($entityType, $entityId)
        );
    }

    /**
     * Check if user has access
     */
    public function canAccess(): ResponseInterface
    {
        $entityType = $this->request->getGet('entity_type');
        $entityId   = $this->request->getGet('entity_id');
        $userId     = $this->request->getGet('user_id');

        return $this->respond([
            "access" => $this->model->exists($entityType, $entityId, $userId)
        ]);
    }
}
