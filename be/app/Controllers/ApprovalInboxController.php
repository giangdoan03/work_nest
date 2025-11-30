<?php

namespace App\Controllers;

use CodeIgniter\Database\BaseConnection;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use Throwable;

class ApprovalInboxController extends ResourceController
{
    protected $format = 'json';
    protected BaseConnection $db;

    public function __construct()
    {
        $this->db = db_connect();
    }

    /**
     * GET /approvals/inbox?per_page=&page=&target_types=
     */
    private function makeUrl(string $type, string|int $id, ?int $stepId = null): string
    {
        return match ($type) {
            'task' => "/tasks/$id/info",
            'bidding' => "/biddings/$id/info",
            'bidding_step' => "/biddings/$id/steps/$stepId/tasks",
            'contract' => "/contracts/$id/info",
            'contract_step' => "/contracts/$id/steps/$stepId/tasks",
            'document'      => "/documents/$id",
            default => "/$type/$id",
        };
    }

    private function queryPending(array $targetTypes, int $userId, bool $isAdmin, int $per, int $offset): array
    {
        // -------------------------------
        // 1) TOTAL
        // -------------------------------
        $builder = $this->db->table('approval_instances ai');
        $builder->select('COUNT(*) AS total')
            ->join(
                'approval_steps s',
                's.approval_instance_id = ai.id AND s.level = ai.current_level + 1',
                'inner',
                false
            )
            ->where('ai.status', 'pending')
            ->where('s.status', 'pending')
            ->whereIn('ai.target_type', $targetTypes);

        if (!$isAdmin) {
            $builder->where('s.approver_id', $userId);
        }

        $total = (int) $builder->get()->getRow('total');
        // -------------------------------
        // 2) ITEMS
        // -------------------------------
        $builder2 = $this->db->table('approval_instances ai');

        $builder2->select("
        ai.id AS instance_id,
        ai.target_type,
        ai.target_id,
        ai.submitted_at,
        ai.submitted_by,
        COALESCE(
            JSON_UNQUOTE(JSON_EXTRACT(ai.meta_json, '$.title')),
            CONCAT(UPPER(ai.target_type), ' #', ai.target_id)
        ) AS title,
        COALESCE(
            JSON_UNQUOTE(JSON_EXTRACT(ai.meta_json, '$.url')),
            CASE ai.target_type
                WHEN 'task'          THEN CONCAT('/tasks/', ai.target_id, '/info')
                WHEN 'bidding'       THEN CONCAT('/biddings/', ai.target_id, '/info')
                WHEN 'bidding_step'  THEN CONCAT('/biddings/', ai.target_id, '/steps/', s.id, '/tasks')
                WHEN 'contract'      THEN CONCAT('/contracts/', ai.target_id, '/info')
                WHEN 'contract_step' THEN CONCAT('/contracts/', ai.target_id, '/steps/', s.id, '/tasks')
                WHEN 'document'      THEN CONCAT('/documents/', ai.target_id)
                ELSE CONCAT('/', ai.target_type, '/', ai.target_id)
            END
        ) AS url,
        s.id AS step_id,
        s.level AS level_now,
        (SELECT COUNT(*) FROM approval_steps s2 WHERE s2.approval_instance_id = ai.id) AS total_steps,
        u.name AS submitted_by_name
    ", false);

        $builder2->join(
            'approval_steps s',
            's.approval_instance_id = ai.id AND s.level = ai.current_level + 1',
            'inner',
            false
        );
        $builder2->join('users u', 'u.id = ai.submitted_by', 'left');

        $builder2->where('ai.status', 'pending');
        $builder2->where('s.status', 'pending');
        $builder2->whereIn('ai.target_type', $targetTypes);

        if (!$isAdmin) {
            $builder2->where('s.approver_id', $userId);
        }

        $builder2->orderBy('ai.submitted_at', 'DESC');
        $builder2->limit($per, $offset);

        $rows = $builder2->get()->getResultArray();

        return [$rows, $total];
    }

    private function queryActed(array $targetTypes, int $userId, bool $isAdmin, int $per, int $offset): array
    {
        // ====================================
        // 1) TOTAL
        // ====================================
        $builder = $this->db->table('approval_instances ai');
        $builder->join('approval_steps s', 's.approval_instance_id = ai.id', 'inner', false)
            ->whereIn('ai.target_type', $targetTypes)
            ->whereIn('ai.status', ['approved', 'rejected'])
            ->whereIn('s.status', ['approved', 'rejected']);

        if (!$isAdmin) {
            $builder->where('s.approver_id', $userId);
        }

        $total = (int) $builder->countAllResults();


        // ====================================
        // 2) ITEMS (Query Builder + RAW SQL SELECT)
        // ====================================
        $builder2 = $this->db->table('approval_instances ai');

        $builder2->select("
        ai.id AS instance_id,
        ai.target_type,
        ai.target_id,
        ai.submitted_at,
        ai.submitted_by,

        COALESCE(
            JSON_UNQUOTE(JSON_EXTRACT(ai.meta_json, '$.title')),
            CONCAT(UPPER(ai.target_type), ' #', ai.target_id)
        ) AS title,

        COALESCE(
            JSON_UNQUOTE(JSON_EXTRACT(ai.meta_json, '$.url')),
            CASE ai.target_type
                WHEN 'task'          THEN CONCAT('/tasks/', ai.target_id, '/info')
                WHEN 'bidding'       THEN CONCAT('/biddings/', ai.target_id, '/info')
                WHEN 'bidding_step'  THEN CONCAT('/biddings/', ai.target_id, '/steps/', s.id, '/tasks')
                WHEN 'contract'      THEN CONCAT('/contracts/', ai.target_id, '/info')
                WHEN 'contract_step' THEN CONCAT('/contracts/', ai.target_id, '/steps/', s.id, '/tasks')
                WHEN 'document'      THEN CONCAT('/documents/', ai.target_id)
                ELSE CONCAT('/', ai.target_type, '/', ai.target_id)
            END
        ) AS url,

        s.id AS step_id,
        s.level AS level_now,

        (SELECT COUNT(*) 
         FROM approval_steps s2 
         WHERE s2.approval_instance_id = ai.id
        ) AS total_steps,

        u.name AS submitted_by_name,
        s.status AS step_status,
        s.updated_at AS acted_at
    ", false);

        $builder2->join('approval_steps s', 's.approval_instance_id = ai.id', 'inner', false);
        $builder2->join('users u', 'u.id = ai.submitted_by', 'left');

        $builder2->whereIn('ai.target_type', $targetTypes);
        $builder2->whereIn('ai.status', ['approved', 'rejected']);
        $builder2->whereIn('s.status', ['approved', 'rejected']);

        if (!$isAdmin) {
            $builder2->where('s.approver_id', $userId);
        }

        $builder2->orderBy('s.updated_at', 'DESC');
        $builder2->limit($per, $offset);

        $rows = $builder2->get()->getResultArray();

        return [$rows, $total];
    }


    public function index(): ResponseInterface
    {
        $s = session();
        $userId = (int)($s->get('user_id') ?? 0);
        $roleId = (int)($s->get('role_id') ?? 0);
        $role = strtolower((string)($s->get('role') ?? ''));
        $isAdmin = ($s->get('is_admin') ?? false) || $roleId === 1 || in_array($role, ['admin', 'super admin'], true);

        if ($userId <= 0) {
            return $this->failUnauthorized('Chưa đăng nhập.');
        }

        $per = min(100, max(1, (int)$this->request->getGet('per_page') ?: 20));
        $page = max(1, (int)$this->request->getGet('page') ?: 1);
        $offset = ($page - 1) * $per;

        $allowed = ['bidding', 'contract', 'bidding_step', 'contract_step', 'task', 'document'];
        $targetCsv = trim((string)$this->request->getGet('target_types'));
        $targetTypes = $targetCsv !== ''
            ? array_values(array_intersect(array_map('trim', explode(',', $targetCsv)), $allowed))
            : $allowed;

        $status = (string)$this->request->getGet('status');       // "approved,rejected"
        $acted = (int)$this->request->getGet('acted_by_me');     // 1 nếu tab đã xử lý

        if ($status === 'approved,rejected' && $acted === 1) {
            // Đã xử lý
            [$rows, $total] = $this->queryActed($targetTypes, $userId, $isAdmin, $per, $offset);
        } else {
            // Cần duyệt
            [$rows, $total] = $this->queryPending($targetTypes, $userId, $isAdmin, $per, $offset);
        }

        return $this->respond([
            'data' => $rows,
            'pager' => [
                'total' => $total,
                'per_page' => $per,
                'current_page' => $page,
            ],
        ]);
    }


    /**
     * GET /approvals/unread-count
     */
    public function unreadCount(): ResponseInterface
    {
        $uid = (int)(session()->get('user_id') ?? 0);
        if ($uid <= 0) {
            return $this->failUnauthorized('Chưa đăng nhập.');
        }

        // allowed target types
        $allowed = ['bidding','contract','bidding_step','contract_step','task','document'];
        $targetCsv = trim((string)$this->request->getGet('target_types'));

        $targetTypes = $targetCsv !== ''
            ? array_values(array_intersect(array_map('trim', explode(',', $targetCsv)), $allowed))
            : $allowed;

        // ==============================
        // Query Builder version
        // ==============================

        $builder = $this->db->table('approval_instances ai');

        $builder->select('COUNT(*) AS cnt', false);

        $builder->join(
            'approval_steps s',
            's.approval_instance_id = ai.id AND s.level = ai.current_level + 1',
            'inner',
            false // no escape
        );

        $builder->where('ai.status', 'pending');
        $builder->where('s.status', 'pending');
        $builder->where('s.approver_id', $uid);
        $builder->whereIn('ai.target_type', $targetTypes);

        // NOT EXISTS (SELECT 1 FROM approval_reads r WHERE r.step_id = s.id AND r.user_id = ?)
        $builder->where("NOT EXISTS (
        SELECT 1 FROM approval_reads r 
        WHERE r.step_id = s.id 
          AND r.user_id = {$uid}
    )", null, false);

        $row = $builder->get()->getRowArray();

        return $this->respond([
            'unread' => (int)($row['cnt'] ?? 0)
        ]);
    }


    /**
     * POST /approvals/mark-read
     * { "step_ids": [1,2,3] }
     */
    public function markRead(): ResponseInterface
    {
        $uid = (int)(session()->get('user_id') ?? 0);
        if ($uid <= 0) {
            return $this->failUnauthorized('Chưa đăng nhập.');
        }

        $payload = $this->request->getJSON(true) ?? $this->request->getPost();
        $stepIds = array_values(array_unique(array_filter(array_map('intval', (array)($payload['step_ids'] ?? [])))));

        if (!$stepIds) {
            return $this->failValidationErrors('Thiếu step_ids');
        }

        // Batch insert
        $data = array_map(fn($sid) => [
            'user_id' => $uid,
            'step_id' => $sid,
            'read_at' => date('Y-m-d H:i:s'),
        ], $stepIds);

        try {
            $this->db->table('approval_reads')->ignore(true)->insertBatch($data);
        } catch (Throwable) {
            // ignore duplicates
        }

        return $this->respond(['ok' => true, 'marked' => count($stepIds)]);
    }
}
