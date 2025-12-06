<?php

if (!function_exists('currentUser')) {
    function currentUser(): array
    {
        $session = session();

        return [
            'id'         => $session->get('user_id'),
            'email'      => $session->get('user_email'),
            'name'       => $session->get('user_name'),
            'role_id'    => $session->get('role_id'),
            'role_code'  => $session->get('role_code'),
            'is_admin'   => (bool)$session->get('is_admin'),
        ];
    }
}

if (!function_exists('requireAdmin')) {
    function requireAdmin(): ?array
    {
        $user = currentUser();

        // ❌ Chưa đăng nhập
        if (empty($user['id'])) {
            return [
                'status'  => 'unauthorized',
                'message' => 'Không xác định người dùng'
            ];
        }

        // ❌ Không phải admin/super admin
        if (!in_array($user['role_code'], ['admin', 'super_admin'], true)) {
            return [
                'status'  => 'forbidden',
                'message' => 'Bạn không có quyền thực hiện thao tác này'
            ];
        }

        // ✔ Hợp lệ
        return null;
    }
}
