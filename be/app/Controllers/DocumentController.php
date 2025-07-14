<?php

namespace App\Controllers;

use App\Models\DocumentSettingModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Models\DocumentModel;
use App\Models\DocumentPermissionModel;
use App\Helpers\UploadHelper;
use stdClass;

class DocumentController extends ResourceController
{
    protected $modelName = DocumentModel::class;
    protected $format = 'json';

    public function index()
    {
        $filters = $this->request->getGet();
        $query = $this->model;

        $userId = session()->get('user_id');
        $deptId = session()->get('department_id');

        if (!$userId) {
            return $this->failUnauthorized('Chưa đăng nhập.');
        }

        // Áp dụng filter
        if (!empty($filters['department_id'])) {
            $query->where('documents.department_id', $filters['department_id']);
        }

        if (!empty($filters['tags'])) {
            $query->like('tags', $filters['tags']);
        }

        if (!empty($filters['created_from']) && !empty($filters['created_to'])) {
            $query->where('created_at >=', $filters['created_from'])
                ->where('created_at <=', $filters['created_to']);
        }

        // Tài liệu user có thể truy cập
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
            ->findAll();
        $sharedIds = array_column($sharedDocIds, 'document_id');

        $query->groupStart()
            ->where('documents.uploaded_by', $userId)
            ->orGroupStart()
            ->where('documents.visibility', 'department')
            ->where('documents.department_id', $deptId)
            ->groupEnd();

        if (!empty($sharedIds)) {
            $query->orGroupStart()
                ->where('documents.visibility', 'custom')
                ->whereIn('documents.id', $sharedIds)
                ->groupEnd();
        }

        $query->groupEnd();



        // Join thêm tên phòng ban và người tạo
        $query->select('documents.*, departments.name as department_name, users.name as uploader_name')
            ->join('departments', 'departments.id = documents.department_id', 'left')
            ->join('users', 'users.id = documents.uploaded_by', 'left');

        $documents = $query->findAll();
        $docIds = array_column($documents, 'id');

        // Lấy quyền chia sẻ
        return $this->getSharingPermissions($permissionModel, $docIds, $documents);
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

        $docs = $this->model
            ->whereIn('id', $ids)
            ->where('visibility', 'custom')
            ->findAll();

        return $this->respond($docs);
    }


    /**
     * @throws \ReflectionException
     */
    public function upload(): ResponseInterface
    {
        $userId = session()->get('user_id');
        if (!$userId) {
            return $this->failUnauthorized('Chưa đăng nhập');
        }

        $data = $this->request->getJSON(true);
        if (!$data || !is_array($data)) {
            return $this->failValidationErrors('Dữ liệu JSON không hợp lệ');
        }

        // Lấy dữ liệu đầu vào
        $title         = $data['title'] ?? '';
        $fileUrl       = $data['file_url'] ?? '';
        $departmentId  = $data['department_id'] ?? '';
        $visibility    = $data['visibility'] ?? 'private';

        // Chuẩn hoá visibility
        $validVisibilities = ['private', 'public', 'department', 'custom'];
        if (!in_array($visibility, $validVisibilities)) {
            $visibility = 'private';
        }

        // Kiểm tra dữ liệu bắt buộc
        if (!$title || !$fileUrl || !$departmentId) {
            return $this->failValidationErrors('Vui lòng nhập đầy đủ thông tin.');
        }

        // Chuẩn bị dữ liệu insert
        $insertData = [
            'title'         => $title,
            'file_path'     => $fileUrl,
            'file_type'     => 'link',
            'file_size'     => 0,
            'department_id' => $departmentId,
            'visibility'    => $visibility,
            'uploaded_by'   => $userId
        ];

        // Tạo mới tài liệu
        $docId = $this->model->insert($insertData);

        // Nếu là custom thì lưu quyền chia sẻ
        if ($visibility === 'custom') {
            $permissionModel = new DocumentPermissionModel();
            $this->extracted($data, $docId, $permissionModel);
        }

        return $this->respondCreated([
            'id'  => $docId,
            'url' => $fileUrl
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

    /**
     * @throws \ReflectionException
     */
    public function update($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Tài liệu không tồn tại.');
        }

        $data = $this->request->getJSON(true);
        if (empty($data)) {
            $data = $this->request->getPost(); // fallback nếu dùng FormData
        }

        // Lấy visibility và đảm bảo hợp lệ
        $visibility = $data['visibility'] ?? 'private';
        $validVisibilities = ['private', 'public', 'department', 'custom'];
        if (!in_array($visibility, $validVisibilities)) {
            $visibility = 'private';
        }

        $documentData = [
            'title'         => $data['title'] ?? '',
            'file_path'     => $data['file_url'] ?? '',
            'department_id' => $data['department_id'] ?? '',
            'visibility'    => $visibility,
        ];

        $this->model->update($id, $documentData);

        // Xử lý lại quyền: xoá cũ, thêm mới nếu là custom
        $permissionModel = new DocumentPermissionModel();
        $permissionModel->where('document_id', $id)->delete();

        if ($visibility === 'custom') {
            $this->extracted($data, $id, $permissionModel);
        }

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

        // Nếu có tài liệu visibility = custom thì lấy thêm quyền chia sẻ
        $docIds = array_column($documents, 'id');
        $permissionModel = new DocumentPermissionModel();
        return $this->getSharingPermissions($permissionModel, $docIds, $documents);
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


    /**
     * @throws \ReflectionException
     */
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

    /**
     * @param array|stdClass $data
     * @param $docId
     * @param DocumentPermissionModel $permissionModel
     * @return void
     */
    public function extracted(array|stdClass $data, $docId, DocumentPermissionModel $permissionModel): void
    {
        $sharedUsers = $data['shared_users'] ?? [];
        $sharedDepartments = $data['shared_departments'] ?? [];

        // Nếu là string JSON thì decode
        if (is_string($sharedUsers)) {
            $sharedUsers = json_decode($sharedUsers, true);
        }
        if (is_string($sharedDepartments)) {
            $sharedDepartments = json_decode($sharedDepartments, true);
        }

        $permissions = [];

        foreach ($sharedUsers as $uid) {
            $permissions[] = [
                'document_id' => $docId,
                'shared_with_type' => 'user',
                'shared_with_id' => $uid,
                'permission_type' => 'view'
            ];
        }

        foreach ($sharedDepartments as $deptId) {
            $permissions[] = [
                'document_id' => $docId,
                'shared_with_type' => 'department',
                'shared_with_id' => $deptId,
                'permission_type' => 'view'
            ];
        }

        if (!empty($permissions)) {
            try {
                $success = $permissionModel->insertBatch($permissions);
                if (!$success) {
                    log_message('error', '⚠️ insertBatch failed: ' . json_encode($permissionModel->errors()));
                }
            } catch (\Exception $e) {
                log_message('error', '❌ Exception in extracted(): ' . $e->getMessage());
            }
        }
    }

    /**
     * @param DocumentPermissionModel $permissionModel
     * @param array $docIds
     * @param $documents
     * @return ResponseInterface
     */
    public function getSharingPermissions(DocumentPermissionModel $permissionModel, array $docIds, $documents): ResponseInterface
    {
        $permissions = $permissionModel
            ->whereIn('document_id', $docIds)
            ->findAll();

        // Gom nhóm theo document
        $sharedMap = [];
        foreach ($permissions as $p) {
            $docId = $p['document_id'];
            if (!isset($sharedMap[$docId])) {
                $sharedMap[$docId] = [
                    'shared_users' => [],
                    'shared_departments' => []
                ];
            }

            if ($p['shared_with_type'] === 'user') {
                $sharedMap[$docId]['shared_users'][] = (int)$p['shared_with_id'];
            } elseif ($p['shared_with_type'] === 'department') {
                $sharedMap[$docId]['shared_departments'][] = (int)$p['shared_with_id'];
            }
        }

        // Gắn permissions vào document
        foreach ($documents as &$doc) {
            $docId = $doc['id'];
            if ($doc['visibility'] === 'custom' && isset($sharedMap[$docId])) {
                $doc['shared_users'] = $sharedMap[$docId]['shared_users'];
                $doc['shared_departments'] = $sharedMap[$docId]['shared_departments'];
            } else {
                $doc['shared_users'] = [];
                $doc['shared_departments'] = [];
            }
        }

        return $this->respond(['data' => $documents]);
    }


}
