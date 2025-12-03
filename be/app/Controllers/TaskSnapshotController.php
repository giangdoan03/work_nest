<?php

namespace App\Controllers;

use App\Services\TaskSnapshotService;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class TaskSnapshotController extends ResourceController
{
    protected TaskSnapshotService $snapshotService;

    public function __construct()
    {
        $this->snapshotService = new TaskSnapshotService();
    }

    /**
     * GET /api/tasks/{id}/snapshot
     *
     * @param int|null $taskId
     * @return ResponseInterface
     */
    public function show($taskId = null): ResponseInterface
    {
        $taskId = (int) $taskId;

        if ($taskId <= 0) {
            return $this->failValidationErrors([
                'task_id' => 'task_id không hợp lệ.'
            ]);
        }

        $snap = $this->snapshotService->getSnapshot($taskId);

        return $this->respond([
            'task_id'  => $taskId,
            'snapshot' => $snap,
        ]);
    }

}
