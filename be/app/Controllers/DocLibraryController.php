<?php

namespace App\Controllers;

use App\Models\DocDocumentModel;
use App\Models\DocUserAccessModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use ReflectionException;

class DocLibraryController extends ResourceController
{
    protected $format = 'json';

    // ============================================================
    //  LIST DOCUMENTS (WITH allowed_users)
    // ============================================================

    public function index()
    {
        $model = new DocDocumentModel();

        $departmentId = $this->request->getGet('department_id');
        $search       = $this->request->getGet('search');
        $userId       = $this->request->getGet('user_id'); // ⭐ Lấy user hiện tại

        $builder = $model->select("
        doc_documents.*,
        departments.name AS department_name,
        (
            SELECT GROUP_CONCAT(user_id)
            FROM doc_user_access 
            WHERE document_id = doc_documents.id
        ) AS allowed_users
    ")->join("departments", "departments.id = doc_documents.department_id", "left");


        // 🔥 LỌC THEO USER ĐƯỢC TRUY CẬP
        if (!empty($userId)) {
            $builder->where("
            doc_documents.created_by = $userId
            OR doc_documents.id IN (
                SELECT document_id FROM doc_user_access WHERE user_id = $userId
            )
        ");
        }

        // Lọc phòng ban
        if (!empty($departmentId)) {
            $builder->where("doc_documents.department_id", $departmentId);
        }

        // Lọc tiêu đề
        if (!empty($search)) {
            $builder->like("doc_documents.title", $search);
        }

        $docs = $builder->findAll();

        foreach ($docs as &$doc) {
            $doc['allowed_users'] = $doc['allowed_users']
                ? array_map('intval', explode(',', $doc['allowed_users']))
                : [];
        }

        return $this->respond($docs);
    }




    // ============================================================
    //  DETAIL DOCUMENT
    // ============================================================

    public function show($id = null)
    {
        $model = new DocDocumentModel();

        $doc = $model->select("
            doc_documents.*,
            departments.name AS department_name,
            (
                SELECT GROUP_CONCAT(user_id)
                FROM doc_user_access 
                WHERE document_id = doc_documents.id
            ) AS allowed_users
        ")
            ->join("departments", "departments.id = doc_documents.department_id", "left")
            ->where("doc_documents.id", $id)
            ->first();

        if (!$doc) return $this->failNotFound("Document not found");

        $doc['allowed_users'] = $doc['allowed_users']
            ? array_map('intval', explode(',', $doc['allowed_users']))
            : [];

        return $this->respond($doc);
    }


    // ============================================================
    //  CREATE / UPDATE / DELETE
    // ============================================================

    /**
     * @throws ReflectionException
     */
    public function create()
    {
        $data = $this->request->getJSON(true) ?? [];

        if (empty($data["title"]) || empty($data["file_url"]) || empty($data["created_by"])) {
            return $this->fail("Missing required fields: title, file_url, created_by");
        }

        $model = new DocDocumentModel();
        $id = $model->insert($data);

        // ⭐ Người tạo tài liệu tự động có quyền xem
        (new DocUserAccessModel())->insert([
            "document_id" => $id,
            "user_id" => $data["created_by"]
        ]);

        return $this->respondCreated([
            "id" => $id,
            "message" => "Document created successfully"
        ]);
    }

    /**
     * @throws ReflectionException
     */
    public function update($id = null)
    {
        if (!$id) return $this->fail("Missing document ID");

        $data = $this->request->getJSON(true) ?? [];
        $model = new DocDocumentModel();

        if (!$model->find($id)) return $this->failNotFound("Document not found");

        $model->update($id, $data);

        return $this->respond(["message" => "Document updated"]);
    }

    public function delete($id = null)
    {
        if (!$id) return $this->fail("Missing document ID");

        $model = new DocDocumentModel();
        if (!$model->find($id)) return $this->failNotFound("Document not found");

        // Xóa toàn bộ quyền user
        (new DocUserAccessModel())->where("document_id", $id)->delete();

        $model->delete($id);

        return $this->respondDeleted(["message" => "Document deleted"]);
    }

    // ============================================================
    //  SHARE DOCUMENT (USER ACCESS)
    // ============================================================

    /**
     * @throws ReflectionException
     */
    public function addUserAccess(): ResponseInterface
    {
        // Kiểm tra quyền
        if ($err = requireAdmin()) {
            return $this->failForbidden($err['message']);
        }

        $data = $this->request->getJSON(true) ?? [];

        if (empty($data["document_id"]) || empty($data["user_id"])) {
            return $this->fail("Missing parameters");
        }

        $model = new DocUserAccessModel();

        if (!$model->hasAccess($data["document_id"], $data["user_id"])) {
            $model->insert($data);
        }

        return $this->respond(["message" => "User access granted"]);
    }



    public function removeUserAccess(): ResponseInterface
    {
        if ($err = requireAdmin()) {
            return $this->failForbidden($err['message']);
        }

        $data = $this->request->getJSON(true) ?? [];

        if (empty($data["document_id"]) || empty($data["user_id"])) {
            return $this->fail("Missing parameters");
        }

        (new DocUserAccessModel())
            ->where("document_id", $data["document_id"])
            ->where("user_id", $data["user_id"])
            ->delete();

        return $this->respond(["message" => "User access removed"]);
    }



    // ============================================================
    //  CHECK ACCESS — ONLY ALLOWED USERS (NO DEPARTMENT)
    // ============================================================

    public function checkAccess(): ResponseInterface
    {
        $docId  = $this->request->getGet("document_id");
        $userId = $this->request->getGet("user_id"); // ⭐ FE gửi lên

        if (!$docId || !$userId) {
            return $this->fail("Missing parameters: document_id, user_id");
        }

        $userAccess = new DocUserAccessModel();

        if ($userAccess->hasAccess($docId, $userId)) {
            return $this->respond(["access" => true]);
        }

        return $this->respond(["access" => false]);
    }


    // ============================================================
    //  LIST BY DEPARTMENT
    // ============================================================

    public function listByDepartment(): ResponseInterface
    {
        $departmentId = $this->request->getGet("department_id");
        $model = new DocDocumentModel();

        $docs = $departmentId
            ? $model->where('department_id', $departmentId)->findAll()
            : $model->findAll();

        return $this->respond($docs);
    }
}
