<?php

namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\Controller;

class Auth extends Controller
{
    public function login()
    {
        $session = session();
        $request = service('request');
    
        $data = $request->getJSON();
        $email = $data->email ?? '';
        $password = $data->password ?? '';
    
        log_message('debug', 'Email received: ' . $email);
        log_message('debug', 'Password received: ' . $password);
    
        $userModel = new \App\Models\UserModel();
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
    

    public function check()
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

    public function logout()
    {
        $session = session();
        $session->destroy();

        return $this->response->setJSON(['status' => 'success', 'message' => 'Logged out']);
    }
}
