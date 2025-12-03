<?php

namespace App\Models;

use CodeIgniter\Model;
use ReflectionException;

class TaskModel extends Model
{
    protected $table = 'tasks';
    protected $primaryKey = 'id';

    protected $allowedFields = [
        'title', 'description', 'assigned_to', 'assigned_by', 'start_date', 'end_date', 'status', 'collaborated_by',
        'linked_type', 'linked_id', 'step_code', 'created_by', 'proposed_by',
        'priority', 'comments_count', 'parent_id', 'step_id', 'approval_status',
        'approval_steps', 'current_level', 'title', 'updated_at', 'id_department', 'progress', 'overdue_reason',
        'approver_ids', 'needs_approval', 'approval_roster_json', 'latest_upload_batch', 'latest_files_json'
    ];

    protected $useTimestamps = true;

    public function getRoster(int $taskId): array
    {
        return db_connect()->table('task_roster r')
            ->select('r.user_id, u.name, r.role, r.status')
            ->join('users u', 'u.id = r.user_id', 'left')
            ->where('r.task_id', $taskId)
            ->orderBy('r.created_at', 'ASC')
            ->get()->getResultArray();
    }

    /** Thêm/cập nhật người vào roster (không reset status cũ) */
    public function upsertRosterMembers(int $taskId, array $mentions): array
    {
        $db = db_connect();
        $db->transStart();

        // Xoá những người không còn trong danh sách
        $userIds = array_map(fn($m) => (int)$m['user_id'], $mentions);
        if ($userIds) {
            $db->table('task_roster')
                ->where('task_id', $taskId)
                ->whereNotIn('user_id', $userIds)
                ->delete();
        } else {
            $db->table('task_roster')->where('task_id', $taskId)->delete();
        }

        // Upsert từng người
        foreach ($mentions as $m) {
            $data = [
                'task_id' => $taskId,
                'user_id' => (int)$m['user_id'],
                'role' => $m['role'] ?? 'approve',
                'status' => $m['status'] ?? 'processing',
                'name' => $m['name'] ?? null,
                'updated_at' => date('Y-m-d H:i:s'),
                'created_at' => date('Y-m-d H:i:s'),
            ];

            $sql = "
        INSERT INTO task_roster (task_id, user_id, role, status, name, created_at, updated_at)
        VALUES (:task_id:, :user_id:, :role:, :status:, :name:, :created_at:, :updated_at:)
        ON DUPLICATE KEY UPDATE
            role = VALUES(role),
            status = VALUES(status),
            name = VALUES(name),
            updated_at = VALUES(updated_at)
    ";

            $db->query($sql, $data);
        }

        $db->transComplete();
        return $this->getRoster($taskId);
    }

    /** Set trạng thái cho 1 user trong roster
     * @throws ReflectionException
     */
    public function setRosterStatus(int $taskId, int $userId, string $status): array
    {
        $cur = $this->getRoster($taskId);
        foreach ($cur as &$m) {
            if ((int)$m['user_id'] === $userId) {
                $m['status'] = in_array($status, ['approved', 'rejected', 'pending'], true) ? $status : 'pending';
                $m['acted_at'] = date('Y-m-d H:i:s');
            }
        }
        $this->update($taskId, ['approval_roster_json' => json_encode($cur, JSON_UNESCAPED_UNICODE)]);
        return $cur;
    }

    /** Tính % tiến độ phê duyệt */
    public function computeApprovalProgress(array $roster): int
    {
        if (!$roster) return 0;
        $total = count($roster);
        $approved = array_reduce($roster, fn($c, $r) => $c + (int)($r['status'] === 'approved'), 0);
        return (int)round($approved * 100 / $total);
    }


}
