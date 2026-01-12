<?php

namespace App\Services;

use App\Models\NotificationModel;
use App\Models\NotificationUserLogModel;
use CodeIgniter\Database\BaseConnection;
use ReflectionException;

class NotificationService
{
    protected NotificationModel $notifyModel;
    protected NotificationUserLogModel $userLogModel;
    protected BaseConnection $db;

    public function __construct()
    {
        $this->notifyModel  = new NotificationModel();
        $this->userLogModel = new NotificationUserLogModel();
        $this->db           = db_connect();
    }

    /** Lấy danh sách thông báo cho user */
    public function listByUser(int $uid, int $limit, int $offset): array
    {
        return $this->db->table('notifications n')
            ->select('
                n.id, n.title, n.message AS content,
                n.type, n.action_type,
                n.task_id, n.bid_id, n.contract_id, n.step_id,
                n.created_at,
                u.name AS submitted_by_name,
                IF(nl.id IS NULL, 1, 0) AS is_unread
            ')

            ->join('users u', 'u.id = n.created_by', 'left')
            ->join('notification_user_logs nl', 'nl.notification_id = n.id AND nl.user_id = '.$uid, 'left')
            ->where('n.user_id', $uid)
            ->orderBy('n.created_at', 'DESC')
            ->limit($limit, $offset)
            ->get()->getResultArray();
    }

    /** Đếm số thông báo chưa đọc */
    public function countUnread(int $uid): int
    {
        return (int)$this->db->table('notifications n')
            ->join('notification_user_logs nl', 'nl.notification_id = n.id AND nl.user_id = '.$uid, 'left')
            ->where('n.user_id', $uid)
            ->where('nl.id IS NULL')
            ->countAllResults();
    }

    /** Đánh dấu đã đọc */
    public function markRead(int $uid, int $id): bool
    {
        return $this->db->table('notification_user_logs')
            ->ignore(true)
            ->insert([
                "user_id"        => $uid,
                "notification_id"=> $id,
                "read_at"        => date("Y-m-d H:i:s"),
            ]);
    }

    /** Tạo thông báo
     * @throws ReflectionException
     */
    public function create(int $userId, array $data): array
    {
        $insert = [
            "user_id"     => $userId,
            "created_by"  => session()->get('user_id') ?? null,
            "title"       => $data["title"],
            "message"     => $data["message"] ?? null,

            "type"        => $data["type"],        // bidding | contract | workflow | non-workflow
            "action_type" => $data["action_type"], // assigned | added_later | approved | rejected

            "bid_id"      => $data["bid_id"] ?? null,
            "contract_id" => $data["contract_id"] ?? null,
            "step_id"     => $data["step_id"] ?? null,
            "task_id"     => $data["task_id"] ?? null,

            "created_at"  => date("Y-m-d H:i:s"),
        ];

        $this->notifyModel->insert($insert);
        $id = $this->notifyModel->getInsertID();

        $notify = array_merge(["id" => $id], $insert);

        $this->emitToSocket($userId, $notify);

        return $notify;
    }

    /** Tổng số notify */
    public function countAll(int $uid): int
    {
        return (int)$this->db->table('notifications')
            ->where('user_id', $uid)
            ->countAllResults();
    }

    /** Emit Socket.IO */
    private function emitToSocket(int $userId, array $payload): void
    {
        $url = "https://notify.bee-soft.net/notify";

        $data = json_encode([
            "user_id" => $userId,
            "payload" => $payload
        ]);

        $ch = curl_init($url);

        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                "Content-Type: application/json"
            ],
            CURLOPT_POSTFIELDS => $data,
            CURLOPT_TIMEOUT => 5,
        ]);

        curl_exec($ch);

        if (curl_errno($ch)) {
            log_message("error", "Socket emit failed: " . curl_error($ch));
        }

        curl_close($ch);
    }
}
