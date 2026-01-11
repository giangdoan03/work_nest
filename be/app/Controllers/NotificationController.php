<?php

namespace App\Controllers;

use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Services\NotificationService;
use ReflectionException;

class NotificationController extends ResourceController
{
    protected NotificationService $notify;

    public function __construct()
    {
        $this->notify = new NotificationService();
    }

    public function index()
    {
        $uid = (int)($this->request->getGet("user_id") ?? 0);

        if ($uid <= 0) {
            return $this->failValidationErrors("Thiếu user_id");
        }

        $page   = max(1, (int)$this->request->getGet("page") ?? 1);
        $limit  = 10;
        $offset = ($page - 1) * $limit;

        $list     = $this->notify->listByUser($uid, $limit, $offset);
        $unread   = $this->notify->countUnread($uid);
        $total    = $this->notify->countAll($uid);

        return $this->respond([
            "data" => $list,
            "pager" => [
                "page"        => $page,
                "per_page"    => $limit,
                "total"       => $total,
                "total_pages" => ceil($total / $limit),
                "unread"      => $unread
            ]
        ]);
    }

    public function markRead(int $id): ResponseInterface
    {
        $uid = (int)(session()->get('user_id') ?? 0);

        if ($uid <= 0) {
            return $this->failUnauthorized("Bạn chưa đăng nhập");
        }

        if ($id <= 0) {
            return $this->failValidationErrors("ID không hợp lệ");
        }

        $this->notify->markRead($uid, $id);

        return $this->respond(["message" => "Đã đánh dấu đã đọc"]);
    }

    /**
     */
    public function send(): ResponseInterface
    {
        $data = $this->request->getJSON(true) ?? $this->request->getPost();

        // Yêu cầu tối thiểu
        if (empty($data['user_id']) || empty($data['title']) || empty($data['type'])) {
            return $this->failValidationErrors("Missing required fields: user_id, title, type");
        }

        // validate cho từng loại linked_type
        switch ($data['type']) {

            case 'bidding':
            case 'contract':
                if (empty($data['linked_id']) || empty($data['step_id']) || empty($data['task_id'])) {
                    return $this->failValidationErrors("Missing required fields: linked_id, step_id, task_id");
                }
                break;

            case 'workflow':
            case 'non-workflow':
                if (empty($data['task_id'])) {
                    return $this->failValidationErrors("Missing required field: task_id");
                }
                break;

            default:
                return $this->failValidationErrors("Unknown type: {$data['type']}");
        }

        // Tạo notify
        $notify = $this->notify->create((int)$data['user_id'], $data);

        return $this->respond([
            "status" => "ok",
            "data"   => $notify
        ]);
    }
}
