<?php

namespace App\Controllers;

use CodeIgniter\HTTP\ResponseInterface;
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
        $s = session();
        $userId  = (int) ($s->get('user_id') ?? 0);
        $roleId  = (int) ($s->get('role_id') ?? 0);
        $role    = strtolower((string) ($s->get('role') ?? ''));
        $isAdmin = (bool) ($s->get('is_admin') ?? false) || $roleId === 1 || in_array($role, ['admin','super admin'], true);
        if ($userId <= 0) return $this->failUnauthorized('Chưa đăng nhập.');

        $per    = min(100, max(1, (int) ($this->request->getGet('per_page') ?? 20)));
        $page   = max(1, (int) ($this->request->getGet('page') ?? 1));
        $offset = ($page - 1) * $per;

        $allowed     = ['bidding','contract','bidding_step','contract_step','task'];
        $targetCsv   = (string) ($this->request->getGet('target_types') ?? '');
        $targetTypes = $targetCsv !== '' ? array_values(array_filter(array_map('trim', explode(',', $targetCsv)))) : $allowed;
        $targetTypes = array_values(array_intersect($targetTypes, $allowed));
        if (!$targetTypes) $targetTypes = $allowed;

        $db = db_connect();

        // ===== TOTAL =====
        $totalBuilder = $db->table('approval_instances ai')
            ->join('approval_steps s', 's.approval_instance_id = ai.id AND s.level = ai.current_level + 1', 'inner', false)
            ->where('ai.status', 'pending')
            ->where('s.status', 'pending')
            ->whereIn('ai.target_type', $targetTypes);

        if (!$isAdmin) $totalBuilder->where('s.approver_id', $userId);
        $total = (int) $totalBuilder->countAllResults();

        // ===== ITEMS =====
        $sql = "
      SELECT
        ai.id                AS instance_id,
        ai.target_type,
        ai.target_id,
        ai.submitted_at,
        ai.submitted_by,
        JSON_UNQUOTE(JSON_EXTRACT(ai.meta_json, '$.title')) AS meta_title,
        JSON_UNQUOTE(JSON_EXTRACT(ai.meta_json, '$.url'))   AS meta_url,

        s.id   AS step_id,
        s.level AS level_now,
        (SELECT COUNT(*) FROM approval_steps s2 WHERE s2.approval_instance_id = ai.id) AS total_steps,

        u.name  AS submitted_by_name,

        -- chưa đọc khi CHƯA có record trong approval_reads cho step hiện tại
        CASE WHEN EXISTS (
           SELECT 1 FROM approval_reads r WHERE r.step_id = s.id AND r.user_id = ?
        ) THEN 0 ELSE 1 END AS is_unread
      FROM approval_instances ai
      JOIN approval_steps s
           ON s.approval_instance_id = ai.id AND s.level = ai.current_level + 1
      LEFT JOIN users u ON u.id = ai.submitted_by
      WHERE ai.status = 'pending' AND s.status = 'pending'
        AND ai.target_type IN ?";

        $params = [$userId, $targetTypes];

        if (!$isAdmin) {
            $sql .= " AND s.approver_id = ?";
            $params[] = $userId;
        }

        $sql .= "
      ORDER BY ai.submitted_at DESC
      LIMIT ? OFFSET ?";

        $params[] = $per;
        $params[] = $offset;

        $rows = $db->query($sql, $params)->getResultArray();

        // Build title + url fallback ở PHP cho chắc
        foreach ($rows as &$r) {
            $r['title'] = $r['meta_title'] ?: (strtoupper($r['target_type']) . ' #' . $r['target_id']);
            if (!empty($r['meta_url'])) {
                $r['url'] = $r['meta_url'];
            } else {
                // tuỳ dự án: chỉnh mapping nếu target_id là step_id
                switch ($r['target_type']) {
                    case 'task':
                        $r['url'] = "/tasks/{$r['target_id']}/info"; break;
                    case 'bidding':
                    case 'bidding_step':
                        $r['url'] = "/bidding-tasks/{$r['target_id']}/info"; break;
                    case 'contract':
                    case 'contract_step':
                        $r['url'] = "/contract-tasks/{$r['target_id']}/info"; break;
                    default:
                        $r['url'] = "/{$r['target_type']}/{$r['target_id']}";
                }
            }
            unset($r['meta_title'], $r['meta_url']);
        }

        return $this->respond([
            'data'  => $rows,
            'pager' => ['total' => $total, 'per_page' => $per, 'current_page' => $page],
        ]);
    }

    public function unreadCount(): ResponseInterface
    {
        $uid = (int) (session()->get('user_id') ?? 0);
        if ($uid <= 0) return $this->failUnauthorized('Chưa đăng nhập.');

        $db = db_connect();
        $row = $db->query("
        SELECT COUNT(*) AS cnt
        FROM approval_instances ai
        JOIN approval_steps s
          ON s.approval_instance_id = ai.id AND s.level = ai.current_level + 1
        WHERE ai.status='pending' AND s.status='pending' AND s.approver_id=?
          AND NOT EXISTS (SELECT 1 FROM approval_reads r WHERE r.step_id = s.id AND r.user_id = ?)
    ", [$uid, $uid])->getRowArray();

        return $this->respond(['unread' => (int) ($row['cnt'] ?? 0)]);
    }

    public function markRead(): ResponseInterface
    {
        $uid = (int) (session()->get('user_id') ?? 0);
        if ($uid <= 0) return $this->failUnauthorized('Chưa đăng nhập.');

        $payload = $this->request->getJSON(true) ?? $this->request->getPost();
        $stepIds = array_values(array_unique(array_filter(array_map('intval', (array) ($payload['step_ids'] ?? [])))));
        if (!$stepIds) return $this->failValidationErrors('Thiếu step_ids');

        $db = db_connect();
        foreach ($stepIds as $sid) {
            try {
                $db->table('approval_reads')->insert([
                    'user_id' => $uid,
                    'step_id' => $sid,
                    'read_at' => date('Y-m-d H:i:s'),
                ], false);
            } catch (\Throwable $e) { /* ignore duplicate */ }
        }
        return $this->respond(['ok' => true, 'marked' => count($stepIds)]);
    }



}
