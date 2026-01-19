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
        'approver_ids', 'needs_approval', 'approval_roster_json', 'latest_upload_batch', 'latest_files_json',
        'workflow_id', 'workflow_step_id', 'workflow_step_id'
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

            $uid = (int)$m['user_id'];

            // Kiểm tra tồn tại
            $exists = $db->table('task_roster')
                ->where('task_id', $taskId)
                ->where('user_id', $uid)
                ->get()
                ->getRowArray();

            $data = [
                'role'       => $m['role'] ?? 'approve',
                'status'     => $m['status'] ?? 'processing',
                'name'       => $m['name'] ?? null,
                'updated_at' => date('Y-m-d H:i:s'),
            ];

            if ($exists) {
                // UPDATE
                $db->table('task_roster')
                    ->where('task_id', $taskId)
                    ->where('user_id', $uid)
                    ->update($data);
            } else {
                // INSERT
                $db->table('task_roster')->insert(array_merge($data, [
                    'task_id'    => $taskId,
                    'user_id'    => $uid,
                    'created_at' => date('Y-m-d H:i:s'),
                ]));
            }
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
