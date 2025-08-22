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
        $model  = new TaskApprovalModel();
        $db     = db_connect();

        $status = $this->request->getGet('status') ?? 'pending';
        $search = $this->request->getGet('search');
        $page   = $this->request->getGet('page') ?? 1;
        $limit  = $this->request->getGet('limit') ?? 10;

        // ✅ Query builder chung
        if ($status === 'pending') {
            $subBuilder = $db->table('task_approvals')
                ->select('MAX(id) AS id')
                ->where('status', 'pending')
                ->groupBy('task_id');

            $subQuery = $subBuilder->getCompiledSelect();

            $builder = $model
                ->select('task_approvals.*, tasks.title, users.name AS assigned_to_name')
                ->join('tasks', 'tasks.id = task_approvals.task_id')
                ->join('users', 'users.id = tasks.assigned_to', 'left')
                ->where("task_approvals.id IN ($subQuery)", null, false)
                ->where('tasks.current_level = task_approvals.level');
        } else {
            $builder = $model
                ->select('task_approvals.*, tasks.title, users.name AS assigned_to_name')
                ->join('tasks', 'tasks.id = task_approvals.task_id')
                ->join('users', 'users.id = tasks.assigned_to', 'left')
                ->where('task_approvals.status !=', 'pending')
                ->where('task_approvals.approved_by', $userId)
                ->orderBy('task_approvals.approved_at', 'DESC');
        }

        // ✅ Áp dụng tìm kiếm theo tiêu đề nhiệm vụ
        if ($search) {
            $builder->like('tasks.title', $search);
        }

        // ✅ Phân trang
        $data = $builder->paginate($limit, 'default', $page);

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

        // Có thể bọc giao dịch để an toàn
        $db = db_connect();
        $db->transStart();

        // 1) Cập nhật bản ghi approval hiện tại → approved
        $model->update($id, [
            'status'       => 'approved',
            'approved_by'  => $userId,
            'approved_at'  => date('Y-m-d H:i:s'),
            'comment'      => $comment
        ]);

        // 2) Ghi log
        $db->table('task_approval_logs')->insert([
            'task_id'     => $approval['task_id'],
            'level'       => $approval['level'],
            'status'      => 'approved',
            'approved_by' => $userId,
            'approved_at' => date('Y-m-d H:i:s'),
            'comment'     => $comment
        ]);

        // 3) Lấy task & tính cấp tiếp theo
        $task = $taskModel->find($approval['task_id']);
        if (!$task) {
            $db->transRollback();
            return $this->failNotFound('Task not found');
        }

        $currentLevel  = (int) $approval['level'];
        $approvalSteps = (int) ($task['approval_steps'] ?? 0);

        if ($approvalSteps <= 0 || $currentLevel >= $approvalSteps) {
            // ✅ DUYỆT XONG CẤP CUỐI → set approved + DONE + progress = 100
            $taskModel->update($task['id'], [
                'approval_status' => 'approved',
                'status'          => TaskStatus::DONE,
                'progress'        => 100,              // <-- thêm dòng này
                'current_level'   => $approvalSteps,   // chuẩn hoá cấp hiện tại
            ]);
        } else {
            // ⏭️ Chưa xong, tạo cấp kế tiếp
            $model->insert([
                'task_id'     => $task['id'],
                'level'       => $currentLevel + 1,
                'status'      => 'pending'
            ]);

            $taskModel->update($task['id'], [
                'current_level' => $currentLevel + 1
            ]);
        }

        $db->transComplete();
        if ($db->transStatus() === false) {
            return $this->fail('Không thể cập nhật duyệt');
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
