<?php

namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;

/**
 * Danh sách “cần duyệt” cho user hiện tại
 * GET /approvals/inbox?per_page=&page=
 */
class ApprovalInboxController extends ResourceController
{
    protected $format = 'json';

    // app/Controllers/ApprovalInboxController.php
    public function index()
    {
        $s       = session();
        $userId  = (int) ($s->get('user_id') ?? 0);
        $roleId  = (int) ($s->get('role_id') ?? 0);
        $role    = strtolower((string) ($s->get('role') ?? ''));
        $isAdmin = (bool) ($s->get('is_admin') ?? false) || $roleId === 1 || in_array($role, ['admin','super admin'], true);

//        var_dump($isAdmin);

        if ($userId <= 0) return $this->failUnauthorized('Chưa đăng nhập.');

        $per    = min(100, max(1, (int) ($this->request->getGet('per_page') ?? 20)));
        $page   = max(1, (int) ($this->request->getGet('page') ?? 1));
        $offset = ($page - 1) * $per;

        // đa loại (mặc định 5 loại)
        $allowed     = ['bidding','contract','bidding_step','contract_step','task'];
        $targetCsv   = (string) ($this->request->getGet('target_types') ?? '');
        $targetTypes = $targetCsv !== '' ? array_values(array_filter(array_map('trim', explode(',', $targetCsv)))) : $allowed;
        $targetTypes = array_values(array_intersect($targetTypes, $allowed));
        if (!$targetTypes) $targetTypes = $allowed;

        // scope=all → bỏ lọc theo approver_id (cho debug hoặc cho quản lý)
        $scopeAll = strtolower((string) ($this->request->getGet('scope') ?? '')) === 'all';

        $db = db_connect();

        // ===== TOTAL =====
        $totalBuilder = $db->table('approval_instances ai')
            ->join('approval_steps s', 's.approval_instance_id = ai.id AND s.level = ai.current_level + 1', 'inner', false)
            ->where('ai.status', 'pending')
            ->where('s.status', 'pending')
            ->whereIn('ai.target_type', $targetTypes);

        if (!$isAdmin && !$scopeAll) {
            $totalBuilder->where('s.approver_id', $userId);
        }
        $total = (int) $totalBuilder->countAllResults();

        // ===== ITEMS =====
        $builder = $db->table('approval_instances ai')
            ->select('ai.*, s.id AS step_id, s.level, s.approver_id, s.status AS step_status, s.commented_at')
            ->join('approval_steps s', 's.approval_instance_id = ai.id AND s.level = ai.current_level + 1', 'inner', false)
            ->where('ai.status', 'pending')
            ->where('s.status', 'pending')
            ->whereIn('ai.target_type', $targetTypes);

        if (!$isAdmin && !$scopeAll) {
            $builder->where('s.approver_id', $userId);
        }

        $rows = $builder
            ->orderBy('ai.submitted_at', 'DESC')
            ->limit($per, $offset)
            ->get()->getResultArray();

        return $this->respond([
            'data'  => $rows,
            'pager' => [
                'total'        => $total,
                'per_page'     => $per,
                'current_page' => $page,
            ],
        ]);
    }

}
