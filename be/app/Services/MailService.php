<?php

namespace App\Services;

use CodeIgniter\Email\Email;
use CodeIgniter\I18n\Time;
use Config\Services;
use App\Models\UserModel;
use App\Models\TaskModel;
use Throwable;

class MailService
{
    protected Email $email;
    protected UserModel $userModel;
    protected TaskModel $taskModel;

    public function __construct()
    {
        helper('email');

        $this->email = Services::email();
        $this->userModel = new UserModel();
        $this->taskModel = new TaskModel();

        $this->email->initialize([
            'protocol'    => 'smtp',
            'SMTPHost'    => getenv('email.SMTPHost'),
            'SMTPUser'    => getenv('email.SMTPUser'),
            'SMTPPass'    => getenv('email.SMTPPass'),
            'SMTPPort'    => (int) getenv('email.SMTPPort'),  // Must be int !!!
            'smtp_crypto' => getenv('email.SMTPCrypto'),       // use correct CI4 key
            'mailType'    => getenv('email.mailType'),
            'charset'     => getenv('email.charset'),
            'newline'     => "\r\n",
        ]);

        $this->email->setFrom(
            getenv('email.fromEmail'),
            getenv('email.fromName')
        );
    }


    /* ============================================================
     * CORE SEND
     * ============================================================*/
    public function send(string $to, string $subject, string $html): bool
    {
        log_message('error', '[MAIL DEBUG] sending to=' . $to . ' subject=' . $subject);

        try {
            $this->email->clear(true);
            $this->email->setTo($to);
            $this->email->setSubject($subject);
            $this->email->setMessage($html);

            if (!$this->email->send()) {
                log_message('error', '[MAIL FAILED] ' . $this->email->printDebugger());
                return false;
            }

            log_message('error', '[MAIL OK] sent to=' . $to);
            return true;

        } catch (Throwable $e) {
            log_message('error', '[MAIL EXCEPTION] ' . $e->getMessage());
            return false;
        }
    }



    /* ============================================================
     * 1) Mail: Người mới được thêm vào danh sách duyệt
     * ============================================================*/
    public function sendNewApproverAdded(int $taskId, int $userId): void
    {
        $user = $this->userModel->find($userId);
        if (!$user || !$user['email']) return;

        $task = $this->taskModel->find($taskId);
        if (!$task) return;

        $subject = "Bạn được thêm vào danh sách duyệt nhiệm vụ: {$task['title']}";

        $html = "
            <h3>Bạn được thêm vào danh sách duyệt</h3>
            <p>Nhiệm vụ: <b>{$task['title']}</b></p>
            <p>Vui lòng truy cập hệ thống để xem chi tiết.</p>
        ";

        $this->send($user['email'], $subject, $html);
    }


    /* ============================================================
     * 2) Mail: Đến lượt duyệt
     * ============================================================*/
    public function sendNextTurn(int $taskId, int $nextUserId): void
    {
        $u = $this->userModel->find($nextUserId);
        if (!$u || !$u['email']) return;

        $task = $this->taskModel->find($taskId);

        $subject = "Đến lượt bạn duyệt nhiệm vụ: {$task['title']}";

        $html = "
            <h3>Đến lượt bạn duyệt</h3>
            <p>Nhiệm vụ: <b>{$task['title']}</b></p>
            <p>Vui lòng vào hệ thống để thực hiện duyệt.</p>
        ";

        $this->send($u['email'], $subject, $html);
    }


    /* ============================================================
     * 3) Mail: Người approved
     * ============================================================*/
    public function sendApproved(int $taskId, int $userId): void
    {
        $u = $this->userModel->find($userId);
        if (!$u || !$u['email']) return;

        $task = $this->taskModel->find($taskId);

        $subject = "Bạn đã duyệt nhiệm vụ: {$task['title']}";

        $html = "
            <h3>Bạn đã phê duyệt</h3>
            <p>Nhiệm vụ: <b>{$task['title']}</b></p>
        ";

        $this->send($u['email'], $subject, $html);
    }


    /* ============================================================
     * 4) Mail: Người reject
     * ============================================================*/
    public function sendRejected(int $taskId, int $rejectorId, int $creatorId): void
    {
        $task = $this->taskModel->find($taskId);
        if (!$task) return;

        $creator = $this->userModel->find($creatorId);
        $rejector = $this->userModel->find($rejectorId);

        if (!$creator || !$creator['email']) return;

        $subject = "Nhiệm vụ bị từ chối: {$task['title']}";

        $html = "
            <h3>Nhiệm vụ bị từ chối</h3>
            <p><b>{$rejector['name']}</b> đã từ chối nhiệm vụ <b>{$task['title']}</b>.</p>
        ";

        $this->send($creator['email'], $subject, $html);
    }


    /* ============================================================
     * 5) Mail: Tất cả đã duyệt
     * ============================================================*/
    public function sendAllApproved(int $taskId, int $creatorId): void
    {
        $creator = $this->userModel->find($creatorId);
        if (!$creator || !$creator['email']) return;

        $task = $this->taskModel->find($taskId);

        $subject = "Tất cả đã duyệt xong: {$task['title']}";

        $html = "
            <h3>Nhiệm vụ đã hoàn tất phê duyệt</h3>
            <p>Tất cả người duyệt đã hoàn thành việc duyệt cho nhiệm vụ <b>{$task['title']}</b>.</p>
        ";

        $this->send($creator['email'], $subject, $html);
    }

    public function sendGeneric(string $to, string $subject, string $message): bool
    {
        $html = "
        <h3>{$subject}</h3>
        <p>{$message}</p>
        <hr>
        <p>Email tự động, vui lòng không trả lời.</p>
    ";

        return $this->send($to, $subject, $html);
    }
}
