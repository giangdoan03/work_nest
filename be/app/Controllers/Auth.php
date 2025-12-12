<?php

namespace App\Controllers;

use App\Models\UserModel;
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

        $builder = $this->model
            ->select('
        users.*,
        users.is_multi_role,
        roles.name AS role_name,
        roles.code AS role_code,
        roles.description AS role_description,
        positions.name AS position_name,
        positions.level AS position_level
    ')
            ->join('roles', 'roles.id = users.role_id', 'left')
            ->join('positions', 'positions.id = users.position_id', 'left');


        if ($departmentId) {
            $builder->where('users.department_id', $departmentId);
        }

        $users = $builder->findAll();

        $users = array_map(function ($u) {
            $sigModel = new UserSignatureModel();
            unset($u['password']);
            $u['multi_roles'] = $sigModel->getActiveByUser($u['id']);
            return $u;
        }, $users);

        return $this->respond($users);
    }


    public function show($id = null): ResponseInterface
    {
        $user = $this->model
            ->select('
            users.*,
            users.is_multi_role,
            roles.name AS role_name,
            roles.code AS role_code,
            roles.description AS role_description
        ')
            ->join('roles', 'roles.id = users.role_id', 'left')
            ->find($id);

        if (!$user) {
            return $this->failNotFound('User not found');
        }

        unset($user['password']);

        $sigModel = new UserSignatureModel();
        $user['multi_roles'] = $sigModel->getActiveByUser($id);

        return $this->respond($user);
    }




    /**
     * @throws ReflectionException
     */
    /**
     * @throws ReflectionException
     */
    public function create(): ResponseInterface
    {
        $data = $this->request->getJSON(true);
        $validation = Services::validation();
        $sigModel = new UserSignatureModel();

        $rules = [
            'name'              => 'required',
            'email'             => 'required|valid_email|is_unique[users.email]',
            'phone'             => 'required',
            'password'          => 'required|min_length[6]',
            'confirm_password'  => 'required|matches[password]',
            'role_id'           => 'required|integer',
        ];

        if (!$this->validate($rules)) {
            return $this->failValidationErrors($validation->getErrors());
        }

        unset($data['confirm_password']);
        $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);

        // Tạo user
        $id = $this->model->insert($data);
        if (!$id) {
            return $this->fail("Cannot create user");
        }

        /* ==========================================================
         * XỬ LÝ MULTI ROLE (KIÊM NHIỆM)
         * ========================================================== */

        $isMulti = (int)($data['is_multi_role'] ?? 0);

        if ($isMulti === 1) {
            $sigModel->insert([
                'user_id'          => $id,
                'role_name'        => $data['role_name'] ?? null,
                'department_id'    => $data['department_id'] ?? null,
                'preferred_marker' => $data['preferred_marker'] ?? null,
                'approval_marker'  => $data['approval_marker'] ?? null,
                'signature_url'    => $data['signature_url'] ?? null,
                'approval_order'   => 1,
                'active'           => 1
            ]);
        }

        return $this->respondCreated(['id' => $id]);
    }



    /**
     * @throws ReflectionException
     */
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

        $sigModel = new UserSignatureModel();

        /** ================== PASSWORD ================== */
        if (!empty($data['password'])) {
            $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        } else {
            unset($data['password']);
        }

        /** ================== MULTI ROLE FLAG ================== */
        $oldFlag = (int)($user['is_multi_role'] ?? 0);
        $newFlag = array_key_exists('is_multi_role', $data) ? (int)$data['is_multi_role'] : $oldFlag;

        /** ================== SIGNATURE URL ================== */
        $newSignature = array_key_exists('signature_url', $data) ? $data['signature_url'] : ($user['signature_url'] ?? null);

        /** ================== UPDATE USER (cơ bản) ================== */
        $this->model->update($id, $data);

        /** ===============================================================
         *  MULTI ROLES (danh sách phòng ban + marker)
         * =============================================================== */
        $multiRoles = $data['multi_roles'] ?? [];

        if ($newFlag === 0) {
            // về đơn nhiệm => tắt hết multi role
            $sigModel->where('user_id', $id)->set(['active' => 0])->update();
            return $this->respond(['status' => 'success']);
        }

        $keepIds = [];
        $order   = 1;

        foreach ($multiRoles as $role) {
            $row = [
                'department_id'    => $role['department_id'] ?? null,
                'role_name'        => $role['role_name'] ?? null,
                'preferred_marker' => $role['preferred_marker'] ?? null,
                'approval_marker'  => $role['approval_marker'] ?? null,
                'signature_url'    => $role['signature_url'] ?? $newSignature,
                'approval_order'   => $order,
                'active'           => 1,
            ];

            if (!empty($role['id'])) {
                // update bản ghi cũ
                $sigModel->update($role['id'], $row);
                $keepIds[] = $role['id'];
            } else {
                // insert mới
                $row['user_id'] = $id;
                $newId = $sigModel->insert($row);
                $keepIds[] = $newId;
            }

            $order++;
        }

        // disable những vai trò không còn gửi từ FE
        if (!empty($keepIds)) {
            $sigModel->where('user_id', $id)
                ->whereNotIn('id', $keepIds)
                ->set(['active' => 0])
                ->update();
        }

        return $this->respond(['status' => 'success']);
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
