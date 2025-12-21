<?php

namespace App\Controllers;

use CodeIgniter\Controller;
use Config\Services;

class TestMailController extends Controller
{
    public function index(): string
    {
        $email = Services::email();

        $email->setTo('doangiang665@gmail.com'); // 👈 đổi email của bạn
        $email->setSubject('Test Gmail SMTP');
        $email->setMessage('<h3>SMTP Gmail OK 🎉</h3><p>Nếu thấy mail này là cấu hình đúng.</p>');

        if ($email->send()) {
            return '✅ MAIL SENT OK';
        }

        // Nếu lỗi → in chi tiết
        return '<pre>' . $email->printDebugger(['headers', 'subject', 'body']) . '</pre>';
    }
}
