<?php

namespace App\Controllers;

use App\Enums\TaskStatus;
use App\Models\TaskApprovalLogModel;
use App\Models\TaskApprovalModel;
use App\Models\TaskModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class TaskApprovalController extends ResourceController
{
    protected $format = 'json';

    public function index()
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        $userId = $session->get('user_id');
        $model = new TaskApprovalModel();
        $db = db_connect();

        $status = $this->request->getGet('status') ?? 'pending';

        // ✅ Nếu tab là "pending"
        if ($status === 'pending') {
            $subBuilder = $db->table('task_approvals')
                ->select('MAX(id) AS id')
                ->where('status', 'pending')
                ->groupBy('task_id');

            $subQuery = $subBuilder->getCompiledSelect();

            $data = $model
                ->select('task_approvals.*, tasks.title')
                ->join('tasks', 'tasks.id = task_approvals.task_id')
                ->where("task_approvals.id IN ($subQuery)", null, false)
                ->where('tasks.current_level = task_approvals.level')
                ->paginate(10);
        } else {
            // ✅ Lấy lịch sử các nhiệm vụ đã xử lý (approved / rejected) của user
            $data = $model
                ->select('task_approvals.*, tasks.title')
                ->join('tasks', 'tasks.id = task_approvals.task_id')
                ->where('task_approvals.status !=', 'pending')
                ->where('task_approvals.approved_by', $userId)
                ->orderBy('task_approvals.approved_at', 'DESC')
                ->paginate(10);
        }

        return $this->respond([
            'status' => 'success',
            'data'   => $data,
            'total'  => $model->pager->getTotal()
        ]);
    }




    /**
     * @throws \ReflectionException
     */
    public function approve($id): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        $userId     = $session->get('user_id');
        $model      = new TaskApprovalModel();
        $taskModel  = new TaskModel();
        $approval   = $model->find($id);

        if (!$approval) {
            return $this->failNotFound('Approval not found');
        }

        $comment = $this->request->getBody() ?: null;

        // 🔹 Cập nhật trạng thái đã duyệt
        $model->update($id, [
            'status'       => 'approved',
            'approved_by'  => $userId,
            'approved_at'  => date('Y-m-d H:i:s'),
            'comment'      => $comment
        ]);

        // 🔹 Ghi log
        db_connect()->table('task_approval_logs')->insert([
            'task_id'     => $approval['task_id'],
            'level'       => $approval['level'],
            'status'      => 'approved',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        $task = $taskModel->find($approval['task_id']);
        if (!$task) {
            return $this->failNotFound('Task not found');
        }

        $currentLevel  = (int) $approval['level'];
        $approvalSteps = (int) $task['approval_steps'];

        if ($currentLevel >= $approvalSteps) {
            $taskModel->update($task['id'], [
                'approval_status' => 'approved',
                'status'          => TaskStatus::DONE
            ]);
        } else {
            $model->insert([
                'task_id'     => $task['id'],
                'level'       => $currentLevel + 1,
                'status'      => 'pending'
            ]);

            $taskModel->update($task['id'], [
                'current_level' => $currentLevel + 1
            ]);
        }

        return $this->respond(['message' => 'Approved successfully']);
    }



    /**
     * @throws \ReflectionException
     */
    public function reject($id): ResponseInterface
    {
        $session = session();
        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        $userId     = $session->get('user_id');
        $model      = new TaskApprovalModel();
        $taskModel  = new TaskModel();
        $approval   = $model->find($id);

        if (!$approval) {
            return $this->failNotFound('Approval not found');
        }

        $comment = $this->request->getBody() ?: null;

        // 🔹 Cập nhật trạng thái từ chối
        $model->update($id, [
            'status'       => 'rejected',
            'approved_by'  => $userId,
            'approved_at'  => date('Y-m-d H:i:s'),
            'comment'      => $comment
        ]);

        // 🔹 Ghi log
        db_connect()->table('task_approval_logs')->insert([
            'task_id'     => $approval['task_id'],
            'level'       => $approval['level'],
            'status'      => 'rejected',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        // 🔹 Cập nhật task
        $taskModel->update($approval['task_id'], [
            'approval_status' => 'rejected',
            'status'          => TaskStatus::TODO
        ]);

        return $this->respond(['message' => 'Rejected successfully']);
    }

    public function history($taskId): ResponseInterface
    {
        $logModel = new TaskApprovalLogModel();

        $logs = $logModel
            ->select('task_approval_logs.*, users.name AS approved_by_name')
            ->join('users', 'users.id = task_approval_logs.approved_by', 'left')
            ->where('task_approval_logs.task_id', $taskId)
            ->orderBy('task_approval_logs.level ASC, task_approval_logs.approved_at ASC')
            ->findAll();

        return $this->respond($logs);
    }


    public function fullApprovalStatus($taskId): ResponseInterface
    {
        $db = db_connect();

        // 1. Lấy thông tin nhiệm vụ
        $task = $db->table('tasks')->where('id', $taskId)->get()->getRowArray();
        if (!$task) {
            return $this->failNotFound('Task not found');
        }

        $approvalSteps = (int) $task['approval_steps'];
        $currentLevel  = (int) $task['current_level'];

        // 2. Lấy danh sách log đã duyệt
        $logs = $db->table('task_approval_logs as l')
            ->select('l.level, l.status, l.approved_at, u.name AS approved_by_name, l.comment')
            ->join('users u', 'u.id = l.approved_by', 'left')
            ->where('l.task_id', $taskId)
            ->orderBy('l.level ASC')
            ->get()
            ->getResultArray();

        // 3. Trả ra đầy đủ từng cấp
        $result = [];
        for ($i = 1; $i <= $approvalSteps; $i++) {
            $log = null;
            foreach ($logs as $item) {
                if ((int) $item['level'] === $i) {
                    $log = $item;
                    break;
                }
            }

            if ($log) {
                $result[] = [
                    'level' => $i,
                    'status' => $log['status'],
                    'approved_by_name' => $log['approved_by_name'],
                    'approved_at' => $log['approved_at'],
                    'comment' => $log['comment']
                ];
            } elseif ($i === $currentLevel) {
                $result[] = [
                    'level' => $i,
                    'status' => 'pending',
                    'approved_by_name' => null,
                    'approved_at' => null,
                    'comment' => null
                ];
            } else {
                $result[] = [
                    'level' => $i,
                    'status' => 'waiting',
                    'approved_by_name' => null,
                    'approved_at' => null,
                    'comment' => null
                ];
            }
        }


        return $this->respond($result);
    }



}
