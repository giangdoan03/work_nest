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
        $db    = db_connect();

        // 🔸 Tạo builder riêng để làm subquery
        $subBuilder = $db->table('task_approvals')
            ->select('MAX(id) AS id')
            ->where('status', 'pending')
            ->groupBy('task_id');

        // 🔸 Lấy mảng ID từ subquery
        $subQuery = $subBuilder->getCompiledSelect();

        // 🔸 Main query dùng mảng ID từ subquery
        $data = $model
            ->select('task_approvals.*, tasks.title')
            ->join('tasks', 'tasks.id = task_approvals.task_id')
            ->where("task_approvals.id IN ($subQuery)", null, false)
            ->where('tasks.current_level = task_approvals.level')
            ->paginate(10);

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


}
