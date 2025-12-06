<?php

namespace App\Controllers;

use App\Models\EntityMemberModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class EntityMemberController extends ResourceController
{
    protected $modelName = 'App\Models\EntityMemberModel';
    protected $format    = 'json';

    // ⭐ Add user to entity
    public function add(): ResponseInterface
    {

        if ($err = requireAdmin()) {
            return $this->failForbidden($err['message']);
        }

        $data = $this->request->getJSON(true) ?? [];

        $entityType = $data['entity_type'] ?? null;
        $entityId   = $data['entity_id'] ?? null;
        $userId     = $data['user_id'] ?? null;

        if (!$entityType || !$entityId || !$userId) {
            return $this->fail("Missing parameters");
        }

        $this->model->addMember($entityType, $entityId, $userId);

        return $this->respond([
            "message" => "Member added successfully",
            "data"    => compact('entityType', 'entityId', 'userId')
        ]);
    }


    // ⭐ Remove user from entity
    public function remove(): ResponseInterface
    {

        if ($err = requireAdmin()) {
            return $this->failForbidden($err['message']);
        }

        $data = $this->request->getJSON(true) ?? [];

        $entityType = $data['entity_type'] ?? null;
        $entityId   = $data['entity_id'] ?? null;
        $userId     = $data['user_id'] ?? null;

        if (!$entityType || !$entityId || !$userId) {
            return $this->fail("Missing parameters");
        }

        $this->model->removeMember($entityType, $entityId, $userId);

        return $this->respond(["message" => "Member removed"]);
    }


    // ⭐ List all users allowed to access entity
    public function list($entityType, $entityId): ResponseInterface
    {
        $data = $this->model->listMembers($entityType, $entityId);
        return $this->respond($data);
    }

    // ⭐ Check user access
    public function canAccess(): ResponseInterface
    {
        $entityType = $this->request->getGet('entity_type');
        $entityId   = $this->request->getGet('entity_id');
        $userId     = $this->request->getGet('user_id');

        if ($this->model->exists($entityType, $entityId, $userId)) {
            return $this->respond(["access" => true]);
        }

        return $this->respond(["access" => false]);
    }
}
