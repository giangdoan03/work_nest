<?php

namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\Controller;
use CodeIgniter\HTTP\ResponseInterface;
use Config\Services;
use CodeIgniter\API\ResponseTrait;

class Auth extends Controller
{

    use ResponseTrait;

    protected UserModel $model;

    public function __construct()
    {
        $this->model = new UserModel();
    }

    public function index(): ResponseInterface
    {
        $users = $this->model->findAll();
        return $this->respond($users);
    }

    public function show($id = null): ResponseInterface
    {
        $user = $this->model->find($id);
        if (!$user) {
            return $this->failNotFound('User not found');
        }
        return $this->respond($user);
    }

    /**
     * @throws \ReflectionException
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
        ];

        if (!$this->validate($rules)) {
            return $this->failValidationErrors($validation->getErrors());
        }

        unset($data['confirm_password']);
        $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        $data['role'] = 'customer';

        $id = $this->model->insert($data);
        return $this->respondCreated(['id' => $id]);
    }

    /**
     * @throws \ReflectionException
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
        $request = service('request');
    
        $data = $request->getJSON();
        $email = $data->email ?? '';
        $password = $data->password ?? '';
    
        log_message('debug', 'Email received: ' . $email);
        log_message('debug', 'Password received: ' . $password);
    
        $userModel = new UserModel();
        $user = $userModel->where('email', $email)->first();
        log_message('debug', 'User from DB: ' . print_r($user, true));
    
        if ($user && password_verify($password, $user['password'])) {
            $session->regenerate();
            $session->set([
                'user_id'    => $user['id'],
                'user_email' => $user['email'],
                'logged_in'  => true,
            ]);
    
            return $this->response->setJSON(['status' => 'success', 'message' => 'Login successful']);
        }
    
        return $this->response->setJSON(['status' => 'error', 'message' => 'Invalid credentials']);
    }


    /**
     * @throws \ReflectionException
     */
    public function uploadAvatar(): ResponseInterface
    {
        $file = $this->request->getFile('file');
        $userId = $this->request->getPost('user_id');

        if (!$file->isValid()) {
            return $this->fail('File không hợp lệ');
        }

        $uploadPath = getenv('UPLOAD_PATH_AVATAR');
        $baseUrl    = getenv('AVATAR_BASE_URL');

        $newName = $file->getRandomName();
        $file->move($uploadPath, $newName);

        $relativePath = 'avatars/' . $newName;

        // Lưu vào DB
        $this->model->update($userId, [
            'avatar' => $relativePath
        ]);

        return $this->respond([
            'status' => 'success',
            'avatar_url' => $baseUrl . '/' . $newName
        ]);
    }


    public function check(): ResponseInterface
    {
        $session = session();

        if ($session->get('logged_in')) {
            return $this->response->setJSON([
                'status' => 'success',
                'user'   => [
                    'id'    => $session->get('user_id'),
                    'email' => $session->get('user_email'),
                ],
            ]);
        }

        return $this->response->setJSON(['status' => 'error', 'message' => 'Not logged in']);
    }

    public function logout(): ResponseInterface
    {
        $session = session();
        $session->destroy();

        return $this->response->setJSON(['status' => 'success', 'message' => 'Logged out']);
    }

}
