<?php

namespace App\Controllers;

use App\Models\UserModel;
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
            roles.name AS role_name,
            roles.code AS role_code,
            roles.description AS role_description
        ')
            ->join('roles', 'roles.id = users.role_id', 'left');

        if ($departmentId) {
            $builder = $builder->where('users.department_id', $departmentId);
        }

        $users = $builder->findAll();

        // Xóa password
        $users = array_map(function ($u) {
            unset($u['password']);
            return $u;
        }, $users);

        return $this->respond($users);
    }

    public function show($id = null): ResponseInterface
    {
        $user = $this->model
            ->select('
            users.*,
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
            'phone'             => 'required|regex_match[/^(0|\+84)[0-9]{9,10}$/]',
            'password'          => 'required|min_length[6]',
            'confirm_password'  => 'required|matches[password]',
            'role_id'           => 'required|integer',  // ✔ thêm rule role_id
        ];

        if (!$this->validate($rules)) {
            return $this->failValidationErrors($validation->getErrors());
        }

        unset($data['confirm_password']);
        $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);

        // ❌ bỏ dòng này
        // $data['role'] = 'customer';

        // ✔ giữ nguyên role_id FE gửi lên
        $id = $this->model->insert($data);

        return $this->respondCreated(['id' => $id]);
    }


    /**
     * @throws ReflectionException
     */
    public function update($id = null): ResponseInterface
    {
        $data = $this->request->getJSON(true);
        $user = $this->model->find($id);
        if (!$user) {
            return $this->failNotFound('User not found');
        }

        if (!empty($data['password'])) {
            $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        } else {
            unset($data['password']);
        }

        $this->model->update($id, $data);
        return $this->respond(['status' => 'success', 'message' => 'User updated']);
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

            // Lấy user từ database
            $userModel = new UserModel();
            $user = $userModel
                ->select('
                users.*,
                roles.name AS role_name,
                roles.code AS role_code,
                departments.name AS department_name
            ')
                ->join('roles', 'roles.id = users.role_id', 'left')
                ->join('departments', 'departments.id = users.department_id', 'left')
                ->find($userId);

            if ($user) {
                unset($user['password']);

                // Lưu vào session (tùy chọn)
                $session->set('role_name', $user['role_name']);
                $session->set('role_code', $user['role_code']);
                $session->set('department_name', $user['department_name']);

                return $this->response->setJSON([
                    'status' => 'success',
                    'user'   => $user
                ]);
            }

            // Trường hợp user_id trong session không tồn tại trong DB
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
