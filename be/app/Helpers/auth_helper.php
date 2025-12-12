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
            'position_code'  => $session->get('position_code'),
            'is_admin'   => (bool)$session->get('is_admin'),
        ];
    }
}

if (!function_exists('requireAdmin')) {
    function requireAdmin(): ?array
    {
        $user = currentUser();

        if (empty($user['id'])) {
            return [
                'status'  => 'unauthorized',
                'message' => 'Không xác định người dùng'
            ];
        }

        // nếu không phải admin/super admin thì kiểm tra level
        $allowed = ['admin', 'staff', 'executive', 'senior_manager', 'manager'];

        if (!in_array($user['position_code'], $allowed, true)) {
            return [
                'status'  => 'forbidden',
                'message' => 'Bạn không có quyền thực hiện thao tác này'
            ];
        }

        return null;
    }
}

