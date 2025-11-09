<?php

namespace App\Traits;

use App\Models\DocumentApprovalModel;
use App\Models\DocumentApprovalStepModel;
use App\Models\DocumentModel;
use CodeIgniter\HTTP\ResponseInterface;

trait AuthTrait
{
    protected function getUserId(): ?int
    {
        return (int) (session()->get('user_id') ?? 0);
    }

    protected function requireLogin(): ResponseInterface|int
    {
        $userId = $this->getUserId();
        if (!$userId) {
            // Giúp controller trả lỗi ngay nếu chưa login
            return $this->failUnauthorized('Chưa đăng nhập.');
        }
        return $userId;
    }
}
