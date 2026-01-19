<?php

namespace App\Controllers;

use App\Services\WorkflowService;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use Exception;
use ReflectionException;

class WorkflowController extends ResourceController
{
    protected $format = 'json';

    protected WorkflowService $service;

    public function __construct()
    {
        helper('auth');
        $this->service = new WorkflowService();
    }

    /**
     * =======================
     * BOARD – dữ liệu kanban
     * =======================
     */
    public function board(): ResponseInterface
    {
        $params = [
            'department_id' => $this->request->getGet('department_id'),
            'position_code' => $this->request->getGet('position_code'),
            'level'         => $this->request->getGet('level'),
        ];

        return $this->respond([
            'data' => $this->service->getBoardData($params),
        ]);
    }

    /**
     * =======================
     * SUBMIT
     * =======================
     */
    public function submit(): ResponseInterface
    {
        $user = currentUser();
        if (empty($user['id'])) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        $payload = $this->request->getPost();
        $files   = $this->request->getFiles();

        if (empty($payload['title']) || empty($payload['department_id'])) {
            return $this->failValidationErrors('Thiếu dữ liệu bắt buộc');
        }

        try {
            $id = $this->service->submit($payload, (int)$files, $user);

            return $this->respondCreated([
                'id'      => $id,
                'message' => 'Đã gửi trình duyệt',
            ]);
        } catch (Exception $e) {
            return $this->failServerError($e->getMessage());
        }
    }

    /**
     * =======================
     * APPROVE
     * =======================
     * @throws ReflectionException
     */
    public function approve($id = null): ResponseInterface
    {
        $user = currentUser();
        if (empty($user['id'])) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        if (!$id) {
            return $this->failValidationErrors('Thiếu submission_id');
        }

        $comment = $this->request->getPost('comment');

        $this->service->approve((int)$id, (int)$user, $comment);

        return $this->respond([
            'id'      => $id,
            'message' => 'Đã duyệt',
        ]);
    }

    /**
     * =======================
     * REJECT
     * =======================
     * @throws ReflectionException
     */
    public function reject($id = null): ResponseInterface
    {
        $user = currentUser();
        if (empty($user['id'])) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        if (!$id) {
            return $this->failValidationErrors('Thiếu submission_id');
        }

        $comment = $this->request->getPost('comment');
        if (!$comment) {
            return $this->failValidationErrors('Cần lý do từ chối');
        }

        $this->service->reject((int)$id, (int)$user, $comment);

        return $this->respond([
            'id'      => $id,
            'message' => 'Đã từ chối',
        ]);
    }

    /**
     * =======================
     * RETURN TO PREVIOUS STEP
     * =======================
     * @throws ReflectionException
     */
    public function return($id = null): ResponseInterface
    {
        $user = currentUser();
        if (empty($user['id'])) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        if (!$id) {
            return $this->failValidationErrors('Thiếu submission_id');
        }

        $comment = $this->request->getPost('comment');

        $this->service->returnToPreviousStep((int)$id, (int)$user, $comment);

        return $this->respond([
            'id'      => $id,
            'message' => 'Đã trả về bước trước',
        ]);
    }
}
