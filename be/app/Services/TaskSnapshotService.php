<?php

namespace App\Services;

use App\Models\TaskModel;
use App\Models\TaskSnapshotModel;
use CodeIgniter\Database\BaseConnection;
use ReflectionException;

class TaskSnapshotService
{
    protected TaskModel $taskModel;
    protected TaskSnapshotModel $snapModel;
    protected BaseConnection $db;

    public function __construct()
    {
        $this->taskModel = new TaskModel();
        $this->snapModel = new TaskSnapshotModel();
        $this->db        = db_connect();
    }

    /**
     * Snapshot từ taskId
     * @throws ReflectionException
     */
    public function createSnapshot(int $taskId): bool
    {
        $task = $this->taskModel->find($taskId);
        if (!$task) return false;

        return $this->save($task);
    }

    /**
     * Snapshot khi đã có array task (dùng ở merge, approve, reject, upload...)
     * @throws ReflectionException
     */
    public function save(array $task): bool
    {
        $taskId = (int)$task['id'];

        // Lấy batch mới nhất
        $latestBatch = $this->db->table('documents')
            ->select('upload_batch')
            ->where('source_task_id', $taskId)
            ->orderBy('upload_batch', 'DESC')
            ->get()
            ->getRow('upload_batch');

        // Lấy file của batch đó
        $latestFiles = [];
        if ($latestBatch !== null) {
            $latestFiles = $this->db->table('documents')
                ->select('id,title,file_path,google_file_id,file_size')
                ->where('source_task_id', $taskId)
                ->where('upload_batch', $latestBatch)
                ->get()
                ->getResultArray();
        }

        // Ghi snapshot
        return $this->snapModel->insert([
            'task_id'              => $taskId,
            'snapshot_at'          => date('Y-m-d H:i:s'),
            'title'                => $task['title'] ?? null,
            'description'          => $task['description'] ?? null,
            'start_date'           => $task['start_date'] ?? null,
            'end_date'             => $task['end_date'] ?? null,
            'status'               => $task['status'] ?? null,
            'priority'             => $task['priority'] ?? null,
            'approval_status'      => $task['approval_status'] ?? null,
            'progress'             => $task['progress'] ?? null,

            'assigned_to'          => $task['assigned_to'] ?? null,
            'collaborated_by'      => $task['collaborated_by'] ?? null,
            'assigned_by'          => $task['assigned_by'] ?? null,
            'proposed_by'          => $task['proposed_by'] ?? null,
            'created_by'           => $task['created_by'] ?? null,

            'approval_roster_json' => $task['approval_roster_json'] ?? null,

            'latest_upload_batch'  => $latestBatch,
            'latest_files_json'    => json_encode($latestFiles, JSON_UNESCAPED_UNICODE),
        ]);
    }

    /**
     * API dùng để lấy snapshot
     */
    public function getSnapshot(int $taskId): ?array
    {
        return $this->snapModel
            ->where('task_id', $taskId)
            ->orderBy('snapshot_at', 'DESC')
            ->first();
    }
}
