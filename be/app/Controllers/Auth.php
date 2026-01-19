<?php

namespace App\Controllers;

use App\Models\UserModel;
use App\Models\UserRoleModel;
use App\Models\UserSignatureModel;
use CodeIgniter\Controller;
use CodeIgniter\Files\File;
use CodeIgniter\HTTP\ResponseInterface;
use Config\Services;
use CodeIgniter\API\ResponseTrait;
use ReflectionException;

class Auth extends Controller
{

    use ResponseTrait;

    protected UserModel $model;

    public function __construct()
    {
        $this->model = new UserModel();
    }

    private function filterUser(array $user): array
    {
        unset($user['password']);
        return $user;
    }

    public function index(): ResponseInterface
    {
        $departmentId = $this->request->getGet('department_id');

        /** ================== LIST USERS + ROLE CHÍNH ================== */
        $builder = $this->model
            ->select('
            users.*,
            ur.department_id,
            ur.position_id,
            d.name AS department_name,
            p.name AS position_name,
            p.level AS position_level
        ')
            ->join(
                'user_roles ur',
                'ur.user_id = users.id AND ur.is_primary = 1',
                'left'
            )
            ->join('departments d', 'd.id = ur.department_id', 'left')
            ->join('positions p', 'p.id = ur.position_id', 'left');

        if ($departmentId) {
            $builder->where('ur.department_id', $departmentId);
        }

        $users = $builder->findAll();

        if (empty($users)) {
            return $this->respond([]);
        }

        /** ================== MAP USERS ================== */
        $userIds = array_column($users, 'id');

        /** ================== LOAD MULTI ROLES (1 QUERY) ================== */
        $userRoleModel = new UserRoleModel();
        $multiRoles = $userRoleModel
            ->whereIn('user_id', $userIds)
            ->where('is_primary', 0)
            ->findAll();

        /** ================== GROUP BY user_id ================== */
        $multiRoleMap = [];
        foreach ($multiRoles as $r) {
            $multiRoleMap[$r['user_id']][] = $r;
        }

        /** ================== MERGE DATA ================== */
        foreach ($users as &$u) {
            unset($u['password']);
            $u['multi_roles'] = $multiRoleMap[$u['id']] ?? [];
        }

        return $this->respond($users);
    }



    public function show($id = null): ResponseInterface
    {
        $user = $this->model
            ->select('
            users.*,
            ur.department_id,
            ur.position_id,
            d.name AS department_name,
            p.name AS position_name,
            p.level AS position_level
        ')
            ->join(
                'user_roles ur',
                'ur.user_id = users.id AND ur.is_primary = 1',
                'left'
            )
            ->join('departments d', 'd.id = ur.department_id', 'left')
            ->join('positions p', 'p.id = ur.position_id', 'left')
            ->find($id);

        if (!$user) {
            return $this->failNotFound('User not found');
        }

        unset($user['password']);

        $userRoleModel = new UserRoleModel();

        $user['multi_roles'] = $userRoleModel
            ->where('user_id', $id)
            ->where('is_primary', 0)
            ->findAll();

        return $this->respond($user);
    }


    /**
     * @throws ReflectionException
     */
    public function create(): ResponseInterface
    {
        $data = $this->request->getJSON(true);
        $validation = Services::validation();

        $rules = [
            'name'              => 'required',
            'email'             => 'required|valid_email|is_unique[users.email]',
            'phone'             => 'required',
            'password'          => 'required|min_length[6]',
            'confirm_password'  => 'required|matches[password]',
            'department_id'     => 'required|integer',
            'position_id'       => 'required|integer',
        ];

        if (!$this->validate($rules)) {
            return $this->failValidationErrors($validation->getErrors());
        }

        unset($data['confirm_password']);
        $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);

        /** ================== CREATE USER ================== */
        $userId = $this->model->insert($data);
        if (!$userId) {
            return $this->fail('Cannot create user');
        }

        /** ================== USER ROLES ================== */
        $userRoleModel = new UserRoleModel();

        // 1️⃣ ROLE CHÍNH
        $userRoleModel->insert([
            'user_id'       => $userId,
            'department_id' => $data['department_id'],
            'position_id'   => $data['position_id'],
            'is_primary'    => 1,
        ]);

        // 2️⃣ ROLE KIÊM NHIỆM
        foreach ($data['multi_roles'] ?? [] as $mr) {
            if (
                empty($mr['department_id']) ||
                empty($mr['position_id'])
            ) {
                continue;
            }

            $userRoleModel->insert([
                'user_id'       => $userId,
                'department_id' => $mr['department_id'],
                'position_id'   => $mr['position_id'],
                'is_primary'    => 0,
            ]);
        }

        return $this->respondCreated(['id' => $userId]);
    }


    /**
     * @throws ReflectionException
     */
    public function update($id = null): ResponseInterface
    {
        $data = $this->request->getJSON(true) ?? [];

        $user = $this->model->find($id);
        if (!$user) {
            return $this->failNotFound('User not found');
        }

        $userRoleModel = new UserRoleModel();

        /* ================== PASSWORD ================== */
        if (!empty($data['password'])) {
            $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        } else {
            unset($data['password']);
        }
        unset($data['confirm_password']);

        /* ================== UPDATE USER ================== */
        $this->model->update($id, $data);

        /* =====================================================
         * ROLE LOGIC – user_roles
         * ===================================================== */

        $isMulti = (int)($data['is_multi_role'] ?? 0);

        // FE bắt buộc gửi department_id + position_id cho role chính
        $primaryDept = $data['department_id'] ?? null;
        $primaryPos  = $data['position_id'] ?? null;

        if (!$primaryDept || !$primaryPos) {
            return $this->failValidationErrors('Thiếu department_id hoặc position_id');
        }

        /* 1️⃣ Reset toàn bộ role về non-primary */
        $userRoleModel
            ->where('user_id', $id)
            ->set(['is_primary' => 0])
            ->update();

        /* 2️⃣ Upsert ROLE CHÍNH */
        $existingPrimary = $userRoleModel
            ->where([
                'user_id'       => $id,
                'department_id' => $primaryDept,
                'position_id'   => $primaryPos,
            ])
            ->first();

        if ($existingPrimary) {
            $userRoleModel->update($existingPrimary['id'], [
                'is_primary' => 1
            ]);
            $keepIds[] = $existingPrimary['id'];
        } else {
            $keepIds[] = $userRoleModel->insert([
                'user_id'       => $id,
                'department_id' => $primaryDept,
                'position_id'   => $primaryPos,
                'is_primary'    => 1,
            ]);
        }

        /* 3️⃣ MULTI ROLES */
        $multiRoles = $data['multi_roles'] ?? [];

        if ($isMulti === 1 && is_array($multiRoles)) {
            foreach ($multiRoles as $mr) {
                if (empty($mr['department_id']) || empty($mr['position_id'])) {
                    continue;
                }

                // bỏ trùng với role chính
                if (
                    (int)$mr['department_id'] === (int)$primaryDept &&
                    (int)$mr['position_id'] === (int)$primaryPos
                ) {
                    continue;
                }

                $exist = $userRoleModel
                    ->where([
                        'user_id'       => $id,
                        'department_id' => $mr['department_id'],
                        'position_id'   => $mr['position_id'],
                    ])
                    ->first();

                if ($exist) {
                    $keepIds[] = $exist['id'];
                } else {
                    $keepIds[] = $userRoleModel->insert([
                        'user_id'       => $id,
                        'department_id' => $mr['department_id'],
                        'position_id'   => $mr['position_id'],
                        'is_primary'    => 0,
                    ]);
                }
            }
        }

        /* 4️⃣ Xoá role KHÔNG còn trong payload */
        if (!empty($keepIds)) {
            $userRoleModel
                ->where('user_id', $id)
                ->whereNotIn('id', $keepIds)
                ->delete();
        }

        return $this->respond([
            'status' => 'success'
        ]);
    }




    public function delete($id = null): ResponseInterface
    {
        $user = $this->model->find($id);
        if (!$user) {
            return $this->failNotFound('User not found');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['status' => 'success', 'message' => 'User deleted']);
    }

    public function login(): ResponseInterface
    {
        $session = session();
        $req = service('request');

        $data = $req->getJSON(true) ?? [];
        $email = $data['email'] ?? '';
        $password = $data['password'] ?? '';

        // Lấy thông tin user + role_code từ bảng roles
        $user = (new UserModel())
            ->select("users.*, roles.name AS role_name, roles.code AS role_code")
            ->join("roles", "roles.id = users.role_id", "left")
            ->where("users.email", $email)
            ->first();

        if ($user && password_verify($password, $user['password'])) {
            $session->regenerate();

            // kiểm tra quyền admin
            $roleCode = strtolower($user['role_code'] ?? '');
            $isAdmin = in_array($roleCode, ['admin', 'super_admin']);

            // Lưu session
            $session->set([
                'user_id'    => (int)$user['id'],
                'user_email' => $user['email'],
                'logged_in'  => true,
                'user_name'  => $user['name'],
                'role_id'    => $user['role_id'],
                'role_code'  => $roleCode,
                'is_admin'   => $isAdmin,
            ]);

            unset($user['password']);

            return $this->response->setJSON([
                'status'  => 'success',
                'message' => 'Login successful',
                'user'    => $user, // FE sẽ nhận role_code đúng
            ]);
        }

        return $this->response->setJSON([
            'status'  => 'error',
            'message' => 'Invalid credentials'
        ]);
    }




    /**
     * @throws ReflectionException
     */
    public function uploadAvatar(): ResponseInterface
    {
        $userId = (int) $this->request->getPost('user_id');
        if (! $userId) return $this->failValidationErrors(['user_id' => 'Thiếu user_id']);

        $user = $this->model->find($userId);
        if (! $user) return $this->failNotFound('User not found');

        // 1) Validate file
        $rules = [
            'file' => [
                'label' => 'Avatar',
                'rules' => [
                    'uploaded[file]',
                    'max_size[file,4096]',
                    'is_image[file]',
                    'mime_in[file,image/jpg,image/jpeg,image/png,image/gif,image/webp]',
                    'ext_in[file,jpg,jpeg,png,gif,webp]',
                ],
            ],
        ];
        if (! $this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        $file = $this->request->getFile('file');
        if (! $file || ! $file->isValid()) return $this->fail('File không hợp lệ');

        // 2) Đường dẫn (yêu cầu có sẵn public/uploads)
        $publicPath = rtrim(FCPATH, '/\\');                // ...\be\public
        $uploadsDir = $publicPath . DIRECTORY_SEPARATOR . 'uploads';
        if (! is_dir($uploadsDir)) {
            return $this->failServerError('Thiếu thư mục: ' . $uploadsDir . ' (hãy tạo tay)');
        }

        $avatarDir = $uploadsDir . DIRECTORY_SEPARATOR . 'avatars';
        if (! is_dir($avatarDir) && ! @mkdir($avatarDir, 0777, true)) {
            return $this->failServerError('Không thể tạo thư mục: ' . $avatarDir);
        }
        if (! is_writable($avatarDir)) {
            return $this->failServerError('Thư mục không có quyền ghi: ' . $avatarDir);
        }

        // 3) Lưu file
        $newName = $file->getRandomName();
        if (! $file->move($avatarDir, $newName)) {
            return $this->failServerError('Upload thất bại.');
        }

        // 4) Đọc MIME/size từ file ĐÃ LƯU (tránh đụng tmp)
        $savedPath = $avatarDir . DIRECTORY_SEPARATOR . $newName;
        $saved     = new File($savedPath);
        $mime      = $saved->getMimeType();
        $size      = $saved->getSize();

        // 5) Cập nhật DB & xoá avatar cũ (nếu cùng thư mục)
        $relativePath = 'uploads/avatars/' . $newName;

        if (! empty($user['avatar']) && str_starts_with((string)$user['avatar'], 'uploads/avatars/')) {
            $oldAbs = $publicPath . DIRECTORY_SEPARATOR . str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $user['avatar']);
            if (is_file($oldAbs)) @unlink($oldAbs);
        }

        $this->model->update($userId, ['avatar' => $relativePath]);

        // 6) Trả kết quả
        return $this->respondCreated([
            'status'       => 'success',
            'avatar_url'   => base_url($relativePath), // dùng để hiển thị
            'avatar_path'  => $relativePath,           // dùng để lưu DB nếu muốn lưu relative
            'name'         => $newName,
            'mime'         => $mime,
            'size'         => $size,
        ]);
    }




    public function check(): ResponseInterface
    {
        $session = session();

        if ($session->get('logged_in')) {
            $userId = $session->get('user_id');

            $userModel = new UserModel();

            $user = $userModel
                ->select('
                users.*,
                roles.name AS role_name,
                roles.code AS role_code,
                departments.name AS department_name,
                positions.name AS position_name,
                positions.code AS position_code,
                positions.level AS position_level
            ')
                ->join('roles', 'roles.id = users.role_id', 'left')
                ->join('departments', 'departments.id = users.department_id', 'left')
                ->join('positions', 'positions.id = users.position_id', 'left')   // 🔥 thêm JOIN này
                ->find($userId);

            if ($user) {
                unset($user['password']);

                // Lưu session nếu bạn muốn
                $session->set('role_name', $user['role_name']);
                $session->set('role_code', $user['role_code']);
                $session->set('department_name', $user['department_name']);
                $session->set('position_name', $user['position_name']);
                $session->set('position_code', $user['position_code']);

                return $this->response->setJSON([
                    'status' => 'success',
                    'user'   => $user
                ]);
            }

            return $this->response->setJSON([
                'status'  => 'error',
                'message' => 'User not found'
            ]);
        }

        return $this->response->setJSON([
            'status'  => 'error',
            'message' => 'Not logged in'
        ]);
    }




    public function logout(): ResponseInterface
    {
        $session = session();
        $session->destroy();

        return $this->response->setJSON(['status' => 'success', 'message' => 'Logged out']);
    }

}
