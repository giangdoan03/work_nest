<?php

namespace App\Controllers;

use App\Models\DocumentSettingModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Models\DocumentModel;
use App\Models\DocumentPermissionModel;
use App\Helpers\UploadHelper;

class DocumentController extends ResourceController
{
    protected $modelName = DocumentModel::class;
    protected $format = 'json';

    public function index()
    {
        $filters = $this->request->getGet();
        $query = $this->model;

        if (!empty($filters['department_id'])) {
            $query->where('department_id', $filters['department_id']);
        }

        if (!empty($filters['tags'])) {
            $query->like('tags', $filters['tags']);
        }

        if (!empty($filters['created_from']) && !empty($filters['created_to'])) {
            $query->where('created_at >=', $filters['created_from'])
                ->where('created_at <=', $filters['created_to']);
        }

        $userId = session()->get('user_id');
        if (!$userId) {
            return $this->failUnauthorized('Chưa đăng nhập.');
        }

        $query->where('uploaded_by', $userId);

        return $this->respond($query->findAll());
    }

    public function sharedWithMe(): ResponseInterface
    {
        $userId  = session()->get('user_id');
        $deptId  = session()->get('department_id');

        if (!$userId) {
            return $this->failUnauthorized('Chưa đăng nhập');
        }

        $permissionModel = new DocumentPermissionModel();

        $sharedDocIds = $permissionModel
            ->groupStart()
            ->where('shared_with_type', 'user')
            ->where('shared_with_id', $userId)
            ->groupEnd()
            ->orGroupStart()
            ->where('shared_with_type', 'department')
            ->where('shared_with_id', $deptId)
            ->groupEnd()
            ->select('document_id')
            ->distinct()
            ->findAll();

        $ids = array_column($sharedDocIds, 'document_id');

        if (empty($ids)) {
            return $this->respond([]);
        }

        $docs = $this->model->whereIn('id', $ids)->findAll();

        return $this->respond($docs);
    }

    public function upload(): ResponseInterface
    {
        $uploadResult = UploadHelper::uploadDocumentFile($this->request);

        if (isset($uploadResult['error'])) {
            return $this->failValidationErrors(['file' => $uploadResult['error']]);
        }

        $userId = session()->get('user_id');
        if (!$userId) {
            return $this->failUnauthorized('Chưa đăng nhập');
        }

        $data = [
            'title'         => $this->request->getPost('title'),
            'file_path'     => $uploadResult['file_path'],
            'file_type'     => $uploadResult['file_type'],
            'file_size'     => $uploadResult['file_size'],
            'department_id' => $this->request->getPost('department_id'),
            'visibility'    => $this->request->getPost('visibility'),
            'tags'          => $this->request->getPost('tags'),
            'uploaded_by'   => $userId
        ];

        $id = $this->model->insert($data);

        return $this->respondCreated([
            'id'  => $id,
            'url' => $uploadResult['url']
        ]);
    }

    public function share(): ResponseInterface
    {
        $data = $this->request->getJSON(true);

        if (!isset($data['permissions']) || !is_array($data['permissions'])) {
            return $this->failValidationErrors('Dữ liệu phân quyền không hợp lệ.');
        }

        // Kiểm tra document_id hợp lệ
        $docIds = array_column($data['permissions'], 'document_id');
        $existingDocs = $this->model->whereIn('id', $docIds)->findAll();
        $validDocIds = array_column($existingDocs, 'id');

        $validPermissions = array_filter($data['permissions'], function ($perm) use ($validDocIds) {
            return in_array($perm['document_id'], $validDocIds);
        });

        if (empty($validPermissions)) {
            return $this->failValidationErrors('Không có tài liệu hợp lệ để chia sẻ.');
        }

        $permissionModel = new DocumentPermissionModel();

        try {
            $permissionModel->insertBatch($validPermissions);
        } catch (\Exception $e) {
            return $this->failServerError('Không thể chia sẻ tài liệu: ' . $e->getMessage());
        }

        return $this->respond(['status' => 'shared']);
    }

    public function update($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Tài liệu không tồn tại.');
        }

        $data = $this->request->getJSON(true);
        $this->model->update($id, $data);

        return $this->respond(['status' => 'success']);
    }

    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Tài liệu không tồn tại.');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['status' => 'deleted']);
    }

    public function byDepartment(): ResponseInterface
    {
        $departmentId = $this->request->getGet('department_id'); // optional filter

        $model = new DocumentModel();

        $builder = $model->select('documents.*, departments.name as department_name, users.name as uploader_name')
            ->join('departments', 'departments.id = documents.department_id', 'left')
            ->join('users', 'users.id = documents.uploaded_by', 'left');

        if (!empty($departmentId)) {
            $builder->where('documents.department_id', $departmentId);
        }

        $documents = $builder->findAll();

        return $this->respond(['data' => $documents]);
    }

    public function getPermissions(): ResponseInterface
    {
        $documentId = $this->request->getGet('document_id');
        $model = new DocumentPermissionModel();

        $query = $model->select('document_permissions.*, users.name as user_name')
            ->join('users', 'users.id = document_permissions.shared_with_id AND document_permissions.shared_with_type = "user"', 'left');

        if ($documentId) {
            $query->where('document_permissions.document_id', $documentId);
        }

        $permissions = $query->findAll();
        return $this->respond($permissions);
    }


    public function createPermission(): ResponseInterface
    {
        $data = $this->request->getJSON(true);

        if (!isset($data['document_id'], $data['user_id'], $data['permission'])) {
            return $this->failValidationErrors('Thiếu thông tin phân quyền');
        }

        $model = new DocumentPermissionModel();
        $insertData = [
            'document_id' => $data['document_id'],
            'shared_with_type' => 'user',
            'shared_with_id' => $data['user_id'],
            'permission' => $data['permission'],
        ];

        $model->insert($insertData);

        return $this->respondCreated(['status' => 'created']);
    }

    public function updatePermission($id = null): ResponseInterface
    {
        if (!$id) return $this->failValidationErrors('Thiếu ID');

        $model = new DocumentPermissionModel();
        $permission = $model->find($id);

        if (!$permission) {
            return $this->failNotFound('Không tìm thấy phân quyền');
        }

        $data = $this->request->getJSON(true);

        $updateData = [];

        // ✅ Sửa đúng tên cột
        if (!empty($data['permission_type'])) {
            $updateData['permission_type'] = $data['permission_type'];
        }

        if (empty($updateData)) {
            return $this->failValidationErrors('Không có dữ liệu để cập nhật.');
        }

        $model->update($id, $updateData);

        return $this->respond(['status' => 'updated']);
    }


    public function deletePermission($id = null): ResponseInterface
    {
        if (!$id) return $this->failValidationErrors('Thiếu ID');

        $model = new DocumentPermissionModel();

        if (!$model->find($id)) {
            return $this->failNotFound('Không tìm thấy quyền cần xoá');
        }

        $model->delete($id);
        return $this->respondDeleted(['status' => 'deleted']);
    }

    public function getSettings(): ResponseInterface
    {
        $model = new DocumentSettingModel();
        $settings = $model->findAll();

        $data = [];
        foreach ($settings as $setting) {
            $key = $setting['key'];
            $value = $setting['value'];

            // Giải mã các field JSON
            if (in_array($key, ['upload_roles', 'view_roles'])) {
                $data[$key] = json_decode($value, true);
            } else {
                $data[$key] = is_numeric($value) ? (int) $value : $value;
            }
        }

        return $this->respond($data);
    }

    /**
     * @throws \ReflectionException
     */
    public function updateSetting($id): ResponseInterface
    {
        $data = $this->request->getJSON(true);

        if (empty($data) || !is_array($data)) {
            return $this->failValidationErrors('Dữ liệu cấu hình không hợp lệ');
        }

        $model = new DocumentSettingModel();

        $existing = $model->find($id);
        if ($existing) {
            $model->update($id, $data);
            return $this->respond(['status' => 'updated']);
        }

        return $this->failNotFound('Cấu hình không tồn tại');
    }


    /**
     * @throws \ReflectionException
     */
    public function saveSetting(): ResponseInterface
    {
        $data = $this->request->getJSON(true);
        $model = new DocumentSettingModel();

        if (!is_array($data)) {
            return $this->failValidationErrors('Dữ liệu không hợp lệ');
        }

        foreach ($data as $key => $value) {
            if (!$key) {
                return $this->failValidationErrors('Thiếu key hoặc value.');
            }

            // Convert array to JSON nếu là roles
            $value = in_array($key, ['upload_roles', 'view_roles']) ? json_encode($value) : $value;

            $existing = $model->where('key', $key)->first();
            if ($existing) {
                $model->update($existing['id'], ['value' => $value]);
            } else {
                $model->insert(['key' => $key, 'value' => $value]);
            }
        }

        return $this->respond(['status' => 'saved']);
    }


    public function deleteSetting($id = null): ResponseInterface
    {
        if (!$id || !is_numeric($id)) {
            return $this->failValidationErrors('ID không hợp lệ');
        }

        $model = new DocumentSettingModel();

        $setting = $model->find($id);
        if (!$setting) {
            return $this->failNotFound('Cấu hình không tồn tại');
        }

        $model->delete($id);

        return $this->respondDeleted(['status' => 'deleted', 'id' => $id]);
    }




}
