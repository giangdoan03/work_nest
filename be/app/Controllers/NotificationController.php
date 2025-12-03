<?php

namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;

use App\Services\MailService;
use App\Models\UserModel;
use App\Models\TaskModel;
use App\Models\DocumentModel;
use App\Models\DocumentApprovalModel;

class NotificationController extends ResourceController
{
    protected MailService $mail;
    protected UserModel $userModel;
    protected TaskModel $taskModel;
    protected DocumentModel $docModel;
    protected DocumentApprovalModel $apvModel;

    public function __construct()
    {
        $this->mail       = new MailService();
        $this->userModel  = new UserModel();
        $this->taskModel  = new TaskModel();
        $this->docModel   = new DocumentModel();
        $this->apvModel   = new DocumentApprovalModel();
    }

    /* ========================================================
     * 1) USER ĐƯỢC JOIN VÀO TASK
     * ======================================================== */
    public function taskJoin(): ResponseInterface
    {
        $req = $this->request->getJSON(true);
        $userId = $req['user_id'] ?? null;
        $taskId = $req['task_id'] ?? null;
        $inviter = $req['inviter_name'] ?? 'Hệ thống';

        if (!$userId || !$taskId) {
            return $this->failValidationErrors("Thiếu user_id hoặc task_id");
        }

        $user = $this->userModel->find($userId);
        $task = $this->taskModel->find($taskId);

        if (!$user || !$task) {
            return $this->failNotFound("Không tìm thấy user hoặc task");
        }

        $this->mail->sendUserJoinedTask(
            $user['email'],
            $task['title'],
            $inviter
        );

        return $this->respond(['message' => 'Đã gửi email join task']);
    }

    /* ========================================================
     * 2) TÀI LIỆU GỬI DUYỆT
     * ======================================================== */
    public function sendApproval(): ResponseInterface
    {
        $req = $this->request->getJSON(true);

        $approverId = $req['approver_id'] ?? null;
        $docId      = $req['document_id'] ?? null;
        $sender     = $req['sender_name'] ?? 'Hệ thống';

        if (!$approverId || !$docId) {
            return $this->failValidationErrors("Thiếu approver_id hoặc document_id");
        }

        $approver = $this->userModel->find($approverId);
        $doc = $this->docModel->find($docId);

        if (!$approver || !$doc) {
            return $this->failNotFound("Không tìm thấy user hoặc tài liệu");
        }

        $this->mail->sendDocumentForApproval(
            $approver['email'],
            $doc['title'],
            $sender
        );

        return $this->respond(['message' => 'Đã gửi email duyệt tài liệu']);
    }

    /* ========================================================
     * 3) NGƯỜI DÙNG KÝ XONG
     * ======================================================== */
    public function signed(): ResponseInterface
    {
        $req = $this->request->getJSON(true);

        $docId      = $req['document_id'] ?? null;
        $signerName = $req['signer_name'] ?? "Người dùng";

        if (!$docId) {
            return $this->failValidationErrors("Thiếu document_id");
        }

        $doc = $this->docModel->find($docId);
        if (!$doc) {
            return $this->failNotFound("Không tìm thấy tài liệu");
        }

        // Lấy danh sách user trong task
        $taskUsers = $this->userModel
            ->select('users.email')
            ->join('task_roster', 'task_roster.user_id = users.id')
            ->where('task_roster.task_id', $doc['source_task_id'])
            ->findAll();

        foreach ($taskUsers as $u) {
            $this->mail->sendDocumentSigned(
                $u['email'],
                $doc['title'],
                $signerName
            );
        }

        return $this->respond(['message' => 'Đã gửi email ký tài liệu']);
    }

    /* ========================================================
     * 4) TỪ CHỐI DUYỆT
     * ======================================================== */
    public function rejected(): ResponseInterface
    {
        $req = $this->request->getJSON(true);

        $docId  = $req['document_id'] ?? null;
        $userId = $req['user_id'] ?? null;
        $reason = $req['reason'] ?? "Không rõ lý do";

        if (!$docId || !$userId) {
            return $this->failValidationErrors("Thiếu document_id hoặc user_id");
        }

        $doc  = $this->docModel->find($docId);
        $user = $this->userModel->find($userId);

        if (!$doc || !$user) {
            return $this->failNotFound("Không tìm thấy tài liệu hoặc user");
        }

        // Chủ tài liệu (người upload)
        $creator = $this->userModel->find($doc['uploaded_by']);

        if ($creator) {
            $this->mail->sendDocumentRejected(
                $creator['email'],
                $doc['title'],
                $user['name'],
                $reason
            );
        }

        return $this->respond(['message' => 'Đã gửi email từ chối']);
    }

    /* ========================================================
     * 5) CRONJOB—NHẮC DEADLINE
     * ======================================================== */
    public function deadlineCheck(): ResponseInterface
    {
        $tasks = $this->taskModel
            ->where('deadline IS NOT NULL')
            ->where('deadline <=', date('Y-m-d', strtotime('+1 day')))
            ->findAll();

        foreach ($tasks as $t) {
            $assignee = $this->userModel->find($t['assigned_to']);
            if (!$assignee) continue;

            $this->mail->sendDeadlineReminder(
                $assignee['email'],
                $t['title'],
                $t['deadline']
            );
        }

        return $this->respond(['message' => 'Cronjob: Đã gửi mail nhắc deadline']);
    }
}
