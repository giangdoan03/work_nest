<?php

namespace App\Controllers;

use App\Models\DocumentApprovalModel;
use App\Models\DocumentConvertedModel;
use App\Models\DocumentSettingModel;
use App\Models\DocumentSignStatusModel;
use App\Models\TaskFileModel;
use App\Models\TaskModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Models\DocumentModel;
use App\Models\DocumentPermissionModel;
use App\Helpers\UploadHelper;
use Exception;
use App\Libraries\GoogleDriveService;
use Google\Service\Drive as Google_Service_Drive;
use Google\Service\Drive\DriveFile as Google_Service_Drive_DriveFile;
use ReflectionException;
use stdClass;

use Config\Services;
use CodeIgniter\Files\File;
use CodeIgniter\HTTP\Files\UploadedFile;
use Throwable;


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
     * @throws ReflectionException
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
        } catch (Exception $e) {
            return $this->failServerError('Không thể chia sẻ tài liệu: ' . $e->getMessage());
        }

        return $this->respond(['status' => 'shared']);
    }

    /**
     * @throws ReflectionException
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
        $id = (int) $id;
        if ($id <= 0) {
            return $this->failValidationErrors('document_id không hợp lệ.');
        }

        $userId = (int) (session()->get('user_id') ?? 0);
        $isAdmin = (bool) session()->get('is_admin');

        $doc = $this->model->find($id);
        if (!$doc) {
            return $this->failNotFound('Không tìm thấy tài liệu.');
        }

        // Chỉ người upload hoặc admin mới được xoá
        if (!$isAdmin && (int)$doc['uploaded_by'] !== $userId) {
            return $this->failForbidden('Bạn không có quyền xoá tài liệu này.');
        }

        // Không cho xóa nếu đang có phiên duyệt pending
        $apvM = new DocumentApprovalModel();
        $pending = $apvM
            ->where('document_id', $id)
            ->where('status', 'pending')
            ->first();

        if ($pending) {
            return $this->failValidationErrors('Tài liệu đang trong phiên duyệt pending — không thể xoá.');
        }

        // Xóa file trên disk nếu file_path nằm ở local
        if (!empty($doc['file_path']) && file_exists(FCPATH . $doc['file_path'])) {
            @unlink(FCPATH . $doc['file_path']);
        }

        // Xóa record document
        $this->model->delete($id);

        return $this->respondDeleted([
            'message' => 'Đã xoá tài liệu thành công.',
            'id'      => $id
        ]);
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
     * @throws ReflectionException
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

    /**
     * @throws ReflectionException
     */
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
     * @throws ReflectionException
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
     * @throws ReflectionException
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
            } catch (Exception $e) {
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


    /**
     * GET /api/documents/{id}
     * Lấy chi tiết tài liệu theo ID
     */
    public function show($id = null): ResponseInterface
    {
        if (!$id || !is_numeric($id)) {
            return $this->failValidationErrors('ID không hợp lệ');
        }

        $doc = $this->model
            ->select('documents.*, users.name AS uploaded_by_name, departments.name AS department_name')
            ->join('users', 'users.id = documents.uploaded_by', 'left')
            ->join('departments', 'departments.id = documents.department_id', 'left')
            ->find($id);

        if (!$doc) {
            return $this->failNotFound('Không tìm thấy tài liệu.');
        }

        // Nếu visibility = custom, lấy quyền chia sẻ
        if ($doc['visibility'] === 'custom') {
            $permModel = new DocumentPermissionModel();
            $perms = $permModel->where('document_id', $id)->findAll();
            $doc['shared_users'] = array_column(array_filter($perms, fn($p) => $p['shared_with_type'] === 'user'), 'shared_with_id');
            $doc['shared_departments'] = array_column(array_filter($perms, fn($p) => $p['shared_with_type'] === 'department'), 'shared_with_id');
        }

        return $this->respond(['data' => $doc]);
    }

    /**
     * @throws ReflectionException
     */
    public function signed(): ResponseInterface
    {
        $userId = (int)(session()->get('user_id') ?? 0);
        if (!$userId) {
            return $this->failUnauthorized('Chưa đăng nhập.');
        }

        // Đọc JSON an toàn, fallback POST
        try {
            $data = $this->request->getJSON(true);
        } catch (Throwable) {
            $data = $this->request->getPost();
        }

        $docId      = (int)($data['document_id'] ?? 0);
        $approvalId = (int)($data['approval_id'] ?? 0);
        $signedUrl  = trim((string)($data['signed_url'] ?? ''));

        if ($docId <= 0 && $approvalId > 0) {
            // Nếu không gửi document_id mà gửi approval_id -> tự map
            $apvM = new DocumentApprovalModel();
            $apv  = $apvM->find($approvalId);
            if ($apv && (int)$apv['document_id'] > 0) {
                $docId = (int)$apv['document_id'];
            }
        }

        if ($docId <= 0 || $signedUrl === '') {
            return $this->failValidationErrors('Thiếu document_id hoặc signed_url.');
        }

        $docM = new DocumentModel();
        $doc  = $docM->find($docId);
        if (!$doc) {
            return $this->failNotFound('Không tìm thấy tài liệu.');
        }

        $docM->update($docId, [
            'approval_status' => 'signed',
            'signed_pdf_url'  => $signedUrl,
            'signed_by'       => $userId,
            'signed_at'       => date('Y-m-d H:i:s'),
        ]);

        return $this->respondUpdated([
            'message'     => 'Đã lưu bản PDF đã ký.',
            'document_id' => $docId,
            'signed_url'  => $signedUrl,
        ]);
    }


    /**
     * POST /api/documents/upload-signed
     * form-data:
     *  - file         (blob PDF đã ký)
     *  - approval_id  (id phiên duyệt)
     *
     * Flow:
     *  1) Nhận file + approval_id
     *  2) Upload file lên WordPress (giống uploadToWordPress)
     *  3) Từ approval_id -> lấy document_id
     *  4) Update documents.signed_pdf_url (và optional: approval_status = 'signed')
     * @throws ReflectionException
     */
    public function uploadSignedPdf(): ResponseInterface
    {
        $userId   = (int)(session()->get('user_id') ?? 0);
        $userName = session()->get('user_name') ?? null;

        if (!$userId) {
            return $this->failUnauthorized('Chưa đăng nhập.');
        }

        /** @var UploadedFile|null $file */
        $file = $this->request->getFile('file'); // vẫn lấy nhưng không upload WP nữa

        $convertedId = (int)$this->request->getPost('converted_id');
        $taskFileId  = (int)($this->request->getPost('task_file_id') ?? 0);
        $signatureUrl = $this->request->getPost('signature_url');

        if ($convertedId <= 0) {
            return $this->failValidationErrors('Thiếu converted_id.');
        }

        // Nếu bạn muốn bắt buộc có file upload:
        // if (!$file || !$file->isValid()) {
        //     return $this->failValidationErrors('Thiếu file hoặc file không hợp lệ.');
        // }

        /**
         * Lấy bước ký hiện tại
         */
        $signM = new DocumentSignStatusModel();

        $step = $signM
            ->where('converted_id', $convertedId)
            ->where('approver_id', $userId)
            ->where('status', 'pending')
            ->first();

        if (!$step) {
            return $this->failValidationErrors('Bạn không có bước ký đang chờ hoặc đã ký rồi.');
        }

        /**
         * Tính version mới
         */
        $maxVersionRow = $signM
            ->where('converted_id', $convertedId)
            ->selectMax('version')
            ->first();

        $newVersion = (int)($maxVersionRow['version'] ?? 0) + 1;

        /**
         * Cập nhật trạng thái ký — KHÔNG tạo file, KHÔNG upload WP
         */
        $signM->update($step['id'], [
            'status'          => 'signed',
            'signed_at'       => date('Y-m-d H:i:s'),
            'signature_url'   => $signatureUrl,
            'task_file_id'    => $taskFileId ?: null,
            'signed_by_id'    => $userId,
            'signed_by_name'  => $userName,
            'version'         => $newVersion,  // chỉ lưu version, không dùng cho file
            // signed_pdf_url giữ nguyên, KHÔNG thay đổi!
        ]);

        /**
         * Mở bước tiếp theo
         */
        $next = $signM
            ->where('converted_id', $convertedId)
            ->where('order_index >', $step['order_index'])
            ->orderBy('order_index', 'ASC')
            ->first();

        if ($next) {
            $signM->update($next['id'], ['status' => 'pending']);
        }

        /**
         * Kiểm tra còn bước chưa ký
         */
        $remaining = $signM
            ->where('converted_id', $convertedId)
            ->where('status', 'pending')
            ->first();

        // ========================
        // CẬP NHẬT ROSTER + SNAPSHOT + MAIL (y như MERGE)
        // ========================
        $taskModel = new TaskModel();

        // Lấy task id từ step bảng document_sign_status
        $taskId = (int)$step['task_file_id'];
        $task = $taskModel->find($taskId);

        if ($task) {
            $roster = json_decode($task['approval_roster_json'], true) ?: [];

            foreach ($roster as &$r) {
                if ((int)$r['user_id'] === $userId) {
                    $r['status'] = 'approved';
                    $r['acted_at'] = date('Y-m-d H:i:s');
                }
            }

            // Cập nhật task
            $taskModel->update($taskId, [
                'approval_roster_json' => json_encode($roster, JSON_UNESCAPED_UNICODE),
            ]);

            // Ghi snapshot
            $taskUpdated = $taskModel->find($taskId);
            service('taskSnapshot')->save($taskUpdated);

            // Observer gửi mail
            Services::taskSnapshotObserver()
                ->detectChangesAndNotify($taskId);
        }


        return $this->respond([
            'message'      => 'Đã ký thành công (không upload file).',
            'version'      => $newVersion,
            'converted_id' => $convertedId,
            'step_id'      => $step['id'],
            'completed'    => !$remaining,
        ]);
    }


    /**
     * @throws \Google\Exception
     * @throws \Google\Service\Exception
     */
    public function convertToPdf(): ResponseInterface
    {
        $driveId = $this->request->getGet('drive_id');
        if (!$driveId) {
            return $this->failValidationErrors("Thiếu drive_id");
        }

        // ⭐ Lấy folder PDF từ .env
        $targetFolder = env("drive.folder_id");
        if (!$targetFolder) {
            return $this->fail("Thiếu cấu hình drive.folder_id trong .env");
        }

        try {
            $google = new GoogleDriveService();
            $drive  = $google->getDrive();

            // 1) Lấy metadata file gốc
            $file = $drive->files->get($driveId, ['fields' => 'id,name,mimeType']);
            $mime = $file->mimeType;
            $name = pathinfo($file->name, PATHINFO_FILENAME);

            // Các loại file Google có thể export PDF trực tiếp
            $googleTypes = [
                "application/vnd.google-apps.document",
                "application/vnd.google-apps.spreadsheet",
                "application/vnd.google-apps.presentation",
            ];

            // 2) Nếu KHÔNG phải Google Docs → convert sang Google Docs trước
            if (!in_array($mime, $googleTypes)) {

                // Tải file binary từ Drive
                $resp = $drive->files->get($driveId, ["alt" => "media"]);
                $binary = $resp->getBody()->getContents();

                // Chọn loại Google file phù hợp để convert
                $convertMime = match (true) {
                    str_contains($mime, "word"),
                    str_contains($mime, "doc")        => "application/vnd.google-apps.document",

                    str_contains($mime, "sheet"),
                    str_contains($mime, "excel"),
                    str_contains($mime, "spread")     => "application/vnd.google-apps.spreadsheet",

                    str_contains($mime, "presentation"),
                    str_contains($mime, "powerpoint") => "application/vnd.google-apps.presentation",

                    default => null
                };

                if (!$convertMime) {
                    return $this->failValidationErrors("Không hỗ trợ convert file này sang PDF.");
                }

                // Convert sang Google Docs bằng upload
                $converted = $drive->files->create(
                    new Google_Service_Drive_DriveFile([
                        "name"     => "Converted_" . $name,
                        "mimeType" => $convertMime,
                        "parents"  => [$targetFolder]
                    ]),
                    [
                        "data"       => $binary,
                        "mimeType"   => "application/octet-stream",
                        "uploadType" => "media",
                        "fields"     => "id"
                    ]
                );

                // Thay thế ID file để export PDF
                $driveId = $converted->id;
            }

            // 3) Export Google Docs → PDF
            $pdfResponse = $drive->files->export($driveId, "application/pdf", ["alt" => "media"]);
            $pdfBinary = $pdfResponse->getBody()->getContents();

            // 4) Upload PDF vào folder PDF
            $pdfFile = new Google_Service_Drive_DriveFile([
                "name"    => $name . ".pdf",
                "parents" => [$targetFolder]
            ]);

            $uploaded = $drive->files->create(
                $pdfFile,
                [
                    "data"       => $pdfBinary,
                    "mimeType"   => "application/pdf",
                    "uploadType" => "media",
                    "fields"     => "id, webViewLink"
                ]
            );

            return $this->respond([
                'message' => 'Converted to PDF successfully',
                'pdf_id'  => $uploaded->id,
                'url'     => $uploaded->webViewLink,
                'folder'  => $targetFolder
            ]);

        } catch (Throwable $e) {
            return $this->failServerError($e->getMessage());
        }
    }



    public function listPdfFromDrive(): ResponseInterface
    {
        // ⭐ Lấy folder PDF từ .env
        $folderId = env("drive.folder_id");
        if (!$folderId) {
            return $this->fail("Thiếu cấu hình drive.folder_id trong .env");
        }

        try {
            $google = new GoogleDriveService();
            $drive  = $google->getDrive();

            // Query: chỉ lấy PDF & không bị xóa
            $query = "'{$folderId}' in parents and mimeType='application/pdf' and trashed=false";

            $response = $drive->files->listFiles([
                'q'      => $query,
                'fields' => 'files(id, name, mimeType, size, createdTime)'
            ]);

            $files = $response->files ?? [];

            // Làm sạch output
            $clean = array_map(function ($f) {
                return [
                    "id"          => $f->id,
                    "name"        => $f->name,
                    "mimeType"    => $f->mimeType,
                    "size"        => $f->size,
                    "createdTime" => $f->createdTime,
                    "url"         => "https://drive.google.com/file/d/{$f->id}/view",
                    "download"    => "https://drive.google.com/uc?export=download&id={$f->id}"
                ];
            }, $files);

            return $this->respond([
                "folder" => $folderId,
                "total"  => count($clean),
                "files"  => $clean
            ]);

        } catch (Throwable $e) {
            return $this->failServerError($e->getMessage());
        }
    }


    public function pdfDownload(): ResponseInterface
    {
        $fileId = $this->request->getGet('file_id');
        if (!$fileId) {
            return $this->fail("Missing file_id");
        }

        try {
            $google = new GoogleDriveService();
            $client = $google->getClient();
            $drive = new Google_Service_Drive($client);

            // Lấy file PDF thật
            $response = $drive->files->get($fileId, ['alt' => 'media']);
            $stream = $response->getBody();
            $pdfData = $stream->getContents();

            // Kiểm tra PDF có header hay không
            if (!str_starts_with($pdfData, "%PDF")) {
                return $this->failServerError("Invalid PDF (missing %PDF header)");
            }

            return $this->response
                ->setHeader("Content-Type", "application/pdf")
                ->setHeader("Content-Disposition", "inline; filename=\"file.pdf\"")
                ->setBody($pdfData);

        } catch (Exception $e) {
            return $this->failServerError($e->getMessage());
        }
    }


    public function listConverted(): ResponseInterface
    {
        $taskId = (int) $this->request->getGet('task_id');

        if (!$taskId) {
            return $this->failValidationErrors("Thiếu task_id");
        }

        $db = db_connect();

        $rows = $db->table('documents_converted dc')
            ->select('dc.*')
            ->join(
                'approval_sessions s',
                's.id = dc.approval_session_id',
                'left'
            )
            ->where('s.task_id', $taskId)
            ->orderBy('dc.id', 'DESC')
            ->get()
            ->getResultArray();

        return $this->respond([
            'status' => 'success',
            'files'  => $rows
        ]);
    }




    public function saveConverted(): ResponseInterface
    {
        try {
            $data = $this->request->getJSON(true);

            if (!$data) {
                return $this->failValidationErrors("Invalid JSON payload");
            }

            $model = new DocumentConvertedModel();

            $insertData = [
                'wp_id'        => $data['wp_id']        ?? null,
                'file_url'     => $data['file_url']     ?? null,
                'mime_type'    => $data['mime_type']    ?? null,
                'title'        => $data['title']        ?? null,
                'size'         => $data['size']         ?? null,
                'drive_id'     => $data['drive_id']     ?? null,

                // 🔥 QUAN TRỌNG
                'task_file_id'        => $data['task_file_id'] ?? null,
                'approval_session_id'=> $data['approval_session_id'] ?? null,

                'uploaded_by'  => $data['uploaded_by'] ?? null,
                'uploader_name'=> $data['uploader_name'] ?? null,
                'wp_created_at'=> $data['wp_created_at'] ?? null,
                'doc_type'     => $data['doc_type'] ?? 'internal',
            ];

            if (!$insertData['wp_id'] || !$insertData['file_url']) {
                return $this->failValidationErrors("Missing wp_id or file_url");
            }

            // ❗ Ít nhất phải gắn với task_file hoặc approval_session
            if (!$insertData['task_file_id'] && !$insertData['approval_session_id']) {
                return $this->failValidationErrors(
                    "Missing task_file_id or approval_session_id"
                );
            }

            $id = $model->insert($insertData);

            return $this->respondCreated([
                'id'      => $id,
                'message' => 'Converted PDF saved successfully'
            ]);

        } catch (Throwable $e) {
            log_message('error', '[saveConverted] ' . $e->getMessage());
            return $this->failServerError('Cannot save converted PDF');
        }
    }


    public function deleteConverted($id = null): ResponseInterface
    {
        $id = (int)$id;
        if ($id <= 0) {
            return $this->failValidationErrors("converted_id không hợp lệ");
        }

        $model = new DocumentConvertedModel();

        $file = $model->find($id);
        if (!$file) {
            return $this->failNotFound("Không tìm thấy bản PDF đã convert");
        }

        // Nếu muốn chỉ super_admin được xoá
        $roleCode = session()->get('role_code');
        if ($roleCode !== 'super_admin') {
            return $this->failForbidden("Chỉ super_admin mới được phép xoá PDF convert");
        }

        // Nếu lưu file local → bạn xoá file tại đây, ví dụ:
        // if (!empty($file['local_path']) && file_exists(FCPATH . $file['local_path'])) {
        //     @unlink(FCPATH . $file['local_path']);
        // }

        $model->delete($id);

        return $this->respondDeleted([
            'message' => 'Đã xoá PDF convert',
            'id'      => $id
        ]);
    }

    public function bulkDelete(): ResponseInterface
    {
        $ids = $this->request->getJSON(true)['ids'] ?? [];

        if (empty($ids)) {
            return $this->failValidationErrors("Thiếu danh sách ids.");
        }

        // CHỈ SUPER ADMIN
        if (session()->get('role_code') !== 'super_admin') {
            return $this->failForbidden("Chỉ super_admin mới được xoá tài liệu Office.");
        }

        $docModel      = new DocumentModel();
        $approvalModel = new DocumentApprovalModel();

        foreach ($ids as $id) {
            $id = (int)$id;
            if (!$id) continue;

            $doc = $docModel->find($id);
            if (!$doc) continue;

            // Nếu document đang pending duyệt thì bỏ qua
            $pending = $approvalModel
                ->where('document_id', $id)
                ->where('status', 'pending')
                ->first();

            if ($pending) continue;

            // Xóa file local nếu có
            if (!empty($doc['file_path'])) {
                $path = FCPATH . ltrim($doc['file_path'], '/');
                if (is_file($path)) @unlink($path);
            }

            $docModel->delete($id);
        }

        return $this->respond([
            'message' => "Xoá hàng loạt thành công"
        ]);
    }




}
