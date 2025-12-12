<?php

namespace App\Controllers;

use App\Models\EntityMemberModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class EntityMemberController extends ResourceController
{
    protected $modelName = EntityMemberModel::class;
    protected $format    = 'json';

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
        if ($res = $this->ensureAdmin()) return $res;

        $data = $this->request->getJSON(true) ?? [];

        [$ok, $payload] = $this->validatePayload($data);
        if (!$ok) return $this->fail($payload);

        ['entityType' => $type, 'entityId' => $id, 'userId' => $user] = $payload;

        // run the injected action
        $action($type, $id, $user);

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
