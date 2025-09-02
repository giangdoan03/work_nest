<?php

namespace App\Controllers;

use App\Models\BiddingModel;
use App\Models\BiddingStepModel;
use App\Models\BiddingStepTemplateModel;
use App\Models\ContractModel;
use App\Models\ContractStepModel;
use App\Models\ContractStepTemplateModel;
use App\Models\TaskApprovalModel;
use App\Models\TaskExtensionModel;
use App\Models\TaskModel;
use App\Enums\TaskStatus;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\I18n\Time;
use DateTime;
use Exception;
use ReflectionException;

helper('task');

class TaskController extends ResourceController
{
    protected $modelName = TaskModel::class;
    protected $format = 'json';

    /**
     * @throws Exception
     */
    public function index()
    {
        $params = $this->request->getGet();

        // ---- Giải nghĩa tham số thông minh ----
        $linkedType = $params['linked_type'] ?? null;                 // 'internal' | 'bidding' | 'contract'
        $scope = $params['scope'] ?? null;                 // 'external' | 'internal'
        $excludeInner = !empty($params['exclude_internal']);              // =1 để bỏ nội bộ
        $linkedTypeIn = $params['linked_type_in'] ?? null;                // mảng hoặc CSV

        // linked_type_in: chấp nhận 'bidding,contract' hoặc linked_type_in[]=bidding&linked_type_in[]=contract
        if ($linkedTypeIn && !is_array($linkedTypeIn)) {
            $linkedTypeIn = array_map('trim', explode(',', $linkedTypeIn));
        }
        $allowedTypes = ['internal', 'bidding', 'contract'];
        if (is_array($linkedTypeIn)) {
            $linkedTypeIn = array_values(array_intersect($linkedTypeIn, $allowedTypes));
            if (empty($linkedTypeIn)) $linkedTypeIn = null;
        }

        // ---- Builder chính (dùng cho dữ liệu + phân trang) ----
        $builder = $this->model->builder();

        // Chỉ join cái cần: nội bộ thì không join gì; external thì join cả 2; nếu lọc 1 loại thì join đúng loại
        $needJoinBidding = false;
        $needJoinContract = false;

        if ($linkedType) {
            $needJoinBidding = ($linkedType === 'bidding');
            $needJoinContract = ($linkedType === 'contract');
        } elseif ($linkedTypeIn) {
            $needJoinBidding = in_array('bidding', $linkedTypeIn, true);
            $needJoinContract = in_array('contract', $linkedTypeIn, true);
        } elseif ($scope === 'internal') {
            // không join gì
        } elseif ($scope === 'external' || $excludeInner) {
            $needJoinBidding = $needJoinContract = true;
        } else {
            // mặc định: có thể hiển thị mọi loại -> join cả 2 để có linked_title
            $needJoinBidding = $needJoinContract = true;
        }

        // ---- SELECT + JOIN ----
        $linkedTitleExpr = 'NULL AS linked_title';
        if ($needJoinBidding && $needJoinContract) {
            $linkedTitleExpr = "
        CASE
            WHEN tasks.linked_type = 'bidding'  THEN b.title
            WHEN tasks.linked_type = 'contract' THEN c.title
            ELSE NULL
        END AS linked_title
            ";
                } elseif ($needJoinBidding) {
                    $linkedTitleExpr = "
                CASE
                    WHEN tasks.linked_type = 'bidding' THEN b.title
                    ELSE NULL
                END AS linked_title
            ";
                } elseif ($needJoinContract) {
                    $linkedTitleExpr = "
                CASE
                    WHEN tasks.linked_type = 'contract' THEN c.title
                    ELSE NULL
                END AS linked_title
            ";
                }

                $builder->select("
            tasks.*,
            tasks.id AS task_id,
            users.id   AS assignee_id,
            users.name AS assignee_name,
            parent.title AS parent_title,
            {$linkedTitleExpr}
        ", false); // false để không escape biểu thức CASE

        $builder->join('users', 'users.id = tasks.assigned_to', 'left');
        $builder->join('tasks parent', 'parent.id = tasks.parent_id', 'left');

        if ($needJoinBidding) {
            $builder->join(
                'biddings b',
                'b.id = tasks.linked_id AND tasks.linked_type = "bidding"',
                'left'
            );
        }
        if ($needJoinContract) {
            $builder->join(
                'contracts c',
                'c.id = tasks.linked_id AND tasks.linked_type = "contract"',
                'left'
            );
        }


        // ---- Áp dụng filter chung (không bao gồm filter theo loại) ----
        $this->applyCommonTaskFilters($builder, $params, true);

        // ---- Filter theo loại (ưu tiên theo thứ tự: linked_type > linked_type_in > scope/exclude) ----
        if ($linkedType) {
            $builder->where('tasks.linked_type', $linkedType);
        } elseif ($linkedTypeIn) {
            $builder->whereIn('tasks.linked_type', $linkedTypeIn);
        } elseif ($scope === 'internal') {
            $builder->where('tasks.linked_type', 'internal');
        } elseif ($scope === 'external' || $excludeInner) {
            $builder->whereIn('tasks.linked_type', ['bidding', 'contract']);
        }

        // ---- Phân trang an toàn ----
        $page = max(1, (int)($params['page'] ?? 1));
        $perPage = (int)($params['per_page'] ?? 10);
        if ($perPage <= 0) $perPage = 10;
        if ($perPage > 200) $perPage = 200;
        $offset = ($page - 1) * $perPage;

        // Tổng với đúng filter hiện tại
        $countBuilder = clone $builder;
        $total = $countBuilder->countAllResults(false);

        // Sắp xếp + limit
        $builder->orderBy('tasks.created_at', 'DESC');
        $builder->limit($perPage, $offset);

        $rows = $builder->get()->getResultArray();

        // ---- Map step_name + assignee + deadline ----
        $contractMap = array_column((new ContractStepTemplateModel())->findAll(), 'title', 'step_number');
        $biddingMap = array_column((new BiddingStepTemplateModel())->findAll(), 'title', 'step_number');

        foreach ($rows as &$task) {
            $stepCode = (int)($task['step_code'] ?? 0);
            $task['step_name'] = $task['linked_type'] === 'contract'
                ? ($contractMap[$stepCode] ?? null)
                : ($task['linked_type'] === 'bidding' ? ($biddingMap[$stepCode] ?? null) : null);

            $task['assignee'] = [
                'id' => $task['assignee_id'] ?? null,
                'name' => $task['assignee_name'] ?? 'Chưa có',
            ];

            $diff = calculateDeadlineDiff($task['end_date']);
            $task['days_remaining'] = $diff['days_remaining'];
            $task['days_overdue'] = $diff['days_overdue'];

            $task['is_subtask'] = !empty($task['parent_id']);

            unset($task['assignee_id'], $task['assignee_name']);
        }

        // ---- (Tuỳ chọn) trả thêm tổng theo loại để FE hiển thị "Tất cả" chính xác ----
        $meta = [];
        if (!empty($params['with_totals'])) {
            $meta['totals'] = [
                'bidding' => $this->countByType($params, 'bidding'),
                'contract' => $this->countByType($params, 'contract'),
                'internal' => $this->countByType($params, 'internal'),
                'external' => $this->countByType($params, ['bidding', 'contract']),
            ];
        }

        return $this->response->setJSON([
            'status' => 'success',
            'data' => $rows,
            'pagination' => [
                'total' => $total,
                'page' => $page,
                'per_page' => $perPage,
                'last_page' => (int)ceil($total / $perPage),
            ],
            'meta' => $meta,
        ]);
    }

    /**
     * Áp dụng các bộ lọc chung (trừ filter theo loại nếu $skipTypeFilter = true)
     */
    private function applyCommonTaskFilters($builder, array $params, bool $skipTypeFilter = false): void
    {
        if (!empty($params['assigned_to'])) {
            $builder->where('tasks.assigned_to', (int)$params['assigned_to']);
        }
        if (!empty($params['created_by'])) {
            $builder->where('tasks.created_by', (int)$params['created_by']);
        }
        if (!empty($params['priority'])) {
            $builder->where('tasks.priority', $params['priority']);
        }
        if (!empty($params['status'])) {
            $builder->where('tasks.status', $params['status']);
        }

        if (!$skipTypeFilter && !empty($params['linked_type'])) {
            $builder->where('tasks.linked_type', $params['linked_type']);
        }

        if (array_key_exists('id_department', $params) && $params['id_department'] !== '') {
            $builder->where('tasks.id_department', (int)$params['id_department']);
        }
        if (!empty($params['title'])) {
            $builder->like('tasks.title', $params['title']);
        }
        if (!empty($params['start_date'])) {
            $builder->where('tasks.start_date >=', $params['start_date']);
        }
        if (!empty($params['end_date'])) {
            $builder->where('tasks.end_date <=', $params['end_date']);
        }
    }

    /**
     * Đếm tổng theo loại (string hoặc mảng loại).
     * Giữ nguyên các filter khác (assigned_to, status, …).
     */
    private function countByType(array $params, $types): int
    {
        $builder = $this->model->builder();
        $this->applyCommonTaskFilters($builder, $params, true);

        if (is_array($types)) {
            $builder->whereIn('tasks.linked_type', $types);
        } else {
            $builder->where('tasks.linked_type', $types);
        }
        return (int)$builder->countAllResults();
    }


    /**
     * @param null $id
     * @return ResponseInterface
     * @throws Exception
     */
    public function show($id = null): ResponseInterface
    {
        if (!$id) {
            return $this->failValidationErrors('Missing task id');
        }

        // Lấy 1 task + tên cha + tên liên kết + assignee
        $db = db_connect();
        $row = $db->table('tasks t')
            ->select("
            t.*,
            parent.title AS parent_title,
            CASE
                WHEN t.linked_type = 'bidding'  THEN b.title
                WHEN t.linked_type = 'contract' THEN c.title
                ELSE NULL
            END AS linked_title,
            u.id   AS assignee_id,
            u.name AS assignee_name
        ")
            ->join('tasks parent', 'parent.id = t.parent_id', 'left')
            ->join('biddings b', "b.id = t.linked_id AND t.linked_type = 'bidding'", 'left')
            ->join('contracts c', "c.id = t.linked_id AND t.linked_type = 'contract'", 'left')
            ->join('users u', 'u.id = t.assigned_to', 'left')
            ->where('t.id', $id)
            ->get()
            ->getRowArray();

        if (!$row) {
            return $this->failNotFound('Task not found');
        }

        // 🔁 Nếu đã duyệt mà progress < 100 → auto 100 (và tùy chọn set status=done)
        $row['progress'] = (int)($row['progress'] ?? 0);
        if (($row['approval_status'] ?? null) === 'approved' && $row['progress'] < 100) {
            $done = class_exists(TaskStatus::class) ? TaskStatus::DONE : 'done';

            // cập nhật DB
            $this->model->update($id, [
                'progress' => 100,
                'status' => $done,
            ]);

            // đồng bộ bản trả về
            $row['progress'] = 100;
            $row['status'] = $done;
        }

        // 🔎 Tính step_name theo linked_type + step_code
        $row['step_name'] = null;
        $stepCode = (int)($row['step_code'] ?? 0);
        if ($stepCode > 0) {
            if ($row['linked_type'] === 'contract') {
                $steps = (new ContractStepTemplateModel())
                    ->select('step_number, title')->findAll();
            } elseif ($row['linked_type'] === 'bidding') {
                $steps = (new BiddingStepTemplateModel())
                    ->select('step_number, title')->findAll();
            } else {
                $steps = [];
            }

            foreach ($steps as $s) {
                if ((int)$s['step_number'] === $stepCode) {
                    $row['step_name'] = $s['title'];
                    break;
                }
            }
        }

        // 🗂️ Extensions (lịch sử gia hạn)
        $row['extensions'] = (new TaskExtensionModel())
            ->where('task_id', $id)
            ->orderBy('updated_at', 'ASC')
            ->findAll();

        // ⏳ days_remaining / days_overdue (dựa vào end_date)
        $diff = calculateDeadlineDiff($row['end_date'] ?? null); // helper của bạn
        $row['days_remaining'] = $diff['days_remaining'] ?? null;
        $row['days_overdue'] = $diff['days_overdue'] ?? null;

        // 👤 Chuẩn hoá assignee object giống FE đang dùng
        $assigneeId = $row['assignee_id'] ?? null;
        $assigneeName = $row['assignee_name'] ?? null;
        $row['assignee'] = ($assigneeId || $assigneeName)
            ? ['id' => (string)$assigneeId, 'name' => $assigneeName]
            : null;
        unset($row['assignee_id'], $row['assignee_name']);

        return $this->respond($row);
    }


    /**
     * @throws ReflectionException
     */
    public function create()
    {
        $data = $this->request->getJSON(true) ?? [];

        // Ép kiểu an toàn
        $ints = ['assigned_to', 'created_by', 'proposed_by', 'parent_id', 'step_id', 'linked_id', 'id_department', 'approval_steps'];
        foreach ($ints as $k) {
            if (array_key_exists($k, $data) && $data[$k] !== null && $data[$k] !== '') {
                $data[$k] = (int)$data[$k];
            } else {
                $data[$k] = ($k === 'approval_steps') ? 0 : (isset($data[$k]) ? null : ($data[$k] ?? null));
            }
        }
        $data['linked_type'] = $data['linked_type'] ?? null;
        $data['status'] = $data['status'] ?? 'todo';

        // Validate linked_type
        $validTypes = ['bidding', 'contract', 'internal'];
        if (empty($data['linked_type']) || !in_array($data['linked_type'], $validTypes, true)) {
            return $this->failValidationErrors(['linked_type' => 'Giá trị không hợp lệ (bidding/contract/internal)']);
        }

        // Nếu là task nội bộ thì không có step
        if ($data['linked_type'] === 'internal') {
            $data['step_id'] = null;
            $data['step_code'] = null;
        } else {
            // Bidding/Contract bắt buộc có step_id
            if (empty($data['step_id'])) {
                return $this->failValidationErrors(['step_id' => 'Thiếu step_id']);
            }
        }

        // Nếu tạo task con: validate parent tồn tại
        if (!empty($data['parent_id'])) {
            $parent = $this->model->select('id, linked_type')->find($data['parent_id']);
            if (!$parent) {
                return $this->failValidationErrors(['parent_id' => 'Task cha không tồn tại']);
            }
            // Option: ép loại con giống loại cha (nếu bạn muốn)
            if (empty($data['linked_type'])) {
                $data['linked_type'] = $parent['linked_type'];
            }
        } else {
            $data['parent_id'] = null; // bảo đảm null chứ không phải "" (tránh insert NULL "ảo")
        }

        // Xử lý cấp duyệt
        if ($data['approval_steps'] > 0) {
            $data['approval_status'] = 'pending';
            $data['current_level'] = 1;

            if (($data['status'] ?? null) === TaskStatus::DONE) {
                $data['status'] = TaskStatus::REQUEST_APPROVAL;
            }
        }

        $db = db_connect();
        $db->transStart();

        if (!$this->model->insert($data)) {
            $db->transRollback();
            return $this->failValidationErrors($this->model->errors());
        }
        $taskId = (int)$this->model->getInsertID();

        if ($data['approval_steps'] > 0) {
            (new TaskApprovalModel())->insert([
                'task_id' => $taskId,
                'level' => 1,
                'status' => 'pending',
                'approved_by' => null,
                'approved_at' => null,
            ]);
        }

        $db->transComplete();

        // Re-fetch task vừa tạo (kèm parent_title & linked_title để FE dùng ngay)
        $row = $db->table('tasks t')
            ->select("
            t.*,
            parent.title AS parent_title,
            IF(t.linked_type='bidding',  b.title,
               IF(t.linked_type='contract', c.title, NULL)
            ) AS linked_title
        ")
            ->join('tasks parent', "parent.id = t.parent_id", 'left')
            ->join('biddings b', "b.id = t.linked_id AND t.linked_type = 'bidding'", 'left')
            ->join('contracts c', "c.id = t.linked_id AND t.linked_type = 'contract'", 'left')
            ->where('t.id', $taskId)
            ->get()->getRowArray();

        return $this->respondCreated([
            'message' => 'Task created',
            'id' => $taskId,
            'data' => $row,
        ]);
    }


    /**
     * @throws ReflectionException
     */
    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        $task = $this->model->find($id);
        $this->createApprovalInstanceForTask($task, [$task['assigned_to']]);

        if (!$task) {
            return $this->failNotFound('Task not found');
        }

        // ❌ Cấm hoàn thành thủ công nếu chưa được duyệt đủ cấp
        if (($data['status'] ?? null) === TaskStatus::DONE) {
            if ((int)$task['approval_steps'] > 0 && $task['approval_status'] !== 'approved') {
                return $this->fail('Không thể chuyển sang trạng thái Hoàn thành trước khi được duyệt');
            }

            if ((int)$task['approval_steps'] > 0) {
                return $this->fail('Nhiệm vụ có cấp duyệt, không thể hoàn thành thủ công');
            }
        }

        // ✅ Gửi duyệt hoặc gửi lại duyệt
        if (($data['status'] ?? null) === TaskStatus::REQUEST_APPROVAL && (int)$task['approval_steps'] > 0) {
            $approvalModel = new TaskApprovalModel();

            // Xoá các dòng duyệt cũ nếu đã từ chối (rejected)
            $approvalModel
                ->where('task_id', $id)
                ->delete();

            // Tạo dòng duyệt mới từ cấp 1
            $approvalModel->insert([
                'task_id' => $id,
                'level' => 1,
                'status' => 'pending',
                'approved_by' => null,
                'approved_at' => null
            ]);

            // Reset lại trạng thái task
            $data['approval_status'] = 'pending';
            $data['current_level'] = 1;
            $data['status'] = TaskStatus::REQUEST_APPROVAL;
        }

        // ✅ Cập nhật progress nếu được gửi từ frontend
        if (isset($data['progress'])) {
            $progress = (int)$data['progress'];

            if ($progress < 0 || $progress > 100) {
                return $this->fail('Tiến độ phải nằm trong khoảng 0 - 100');
            }

            // Nếu có cấp duyệt và chưa approved thì cấm đặt 100%
            if ($progress === 100 && (int)$task['approval_steps'] > 0 && $task['approval_status'] !== 'approved') {
                return $this->fail('Không thể đặt tiến độ 100% trước khi được duyệt');
            }

            $data['progress'] = $progress;
        }


        // ✅ Ghi lại lượt gia hạn nếu thay đổi end_date
        $oldEndDate = $task['end_date'] ?? null;
        $newEndDate = $data['end_date'] ?? null;

        if ($oldEndDate && $newEndDate && $oldEndDate !== $newEndDate) {
            $session = session();
            $userId = $session->get('user_id');

            $extensionModel = new TaskExtensionModel();
            $extensionModel->insert([
                'task_id' => $id,
                'extended_by' => $userId,
                'old_end_date' => $oldEndDate,
                'new_end_date' => $newEndDate,
                'reason' => $data['extend_reason'] ?? null,
            ]);
        }

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond(['message' => 'Task updated']);
    }

    /**
     * @throws ReflectionException
     */
    public function extendDeadline($id = null): ResponseInterface
    {
        $task = $this->model->find($id);

        if (!$task) {
            return $this->failNotFound('Task not found');
        }

        $data = $this->request->getJSON(true);
        $newEndDate = $data['new_end_date'] ?? null;
        $reason = $data['reason'] ?? null;
        $userId = user_id(); // Assuming auth helper returns current user ID

        if (!$newEndDate) {
            return $this->failValidationErrors(['new_end_date' => 'New end date is required']);
        }

        $extensionModel = new TaskExtensionModel();
        $extensionModel->insert([
            'task_id' => $id,
            'extended_by' => $userId,
            'old_end_date' => $task['end_date'],
            'new_end_date' => $newEndDate,
            'reason' => $reason
        ]);

        $this->model->update($id, [
            'end_date' => $newEndDate
        ]);

        return $this->respond(['message' => 'Deadline extended successfully']);
    }


    public function countExtensions($id = null): ResponseInterface
    {
        $session = session();
        $userId = $session->get('user_id');
        $extensionModel = new TaskExtensionModel();

        $count = $extensionModel
            ->where('task_id', $id)
            ->where('extended_by', $userId)
            ->countAllResults();

        return $this->respond([
            'task_id' => $id,
            'user_id' => $userId,
            'extension_count' => $count
        ]);
    }

    public function getExtensions($id = null): ResponseInterface
    {
        $extensionModel = new TaskExtensionModel();
        $extensions = $extensionModel
            ->where('task_id', $id)
            ->orderBy('created_at', 'DESC')
            ->findAll();

        return $this->respond([
            'task_id' => $id,
            'extensions' => $extensions
        ]);
    }


    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Task not found');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Task deleted']);
    }

    public function subtasks($parent_id): ResponseInterface
    {
        $parent_id = (int)$parent_id;

        $builder = $this->model->builder();
        $builder->select("
        tasks.*,
        users.id   AS assignee_id,
        users.name AS assignee_name,
        parent.title AS parent_title,
        IF(tasks.linked_type='bidding',  b.title,
           IF(tasks.linked_type='contract', c.title, NULL)
        ) AS linked_title
    ");
        $builder->join('users', 'users.id = tasks.assigned_to', 'left');
        $builder->join('tasks parent', 'parent.id = tasks.parent_id', 'left');
        $builder->join('biddings b', "b.id = tasks.linked_id AND tasks.linked_type='bidding'", 'left');
        $builder->join('contracts c', "c.id = tasks.linked_id AND tasks.linked_type='contract'", 'left');

        $builder->where('tasks.parent_id', $parent_id);
        $builder->orderBy('tasks.created_at', 'DESC');

        $rows = $builder->get()->getResultArray();

        // Map step_name + days
        $contractMap = array_column((new ContractStepTemplateModel())->findAll(), 'title', 'step_number');
        $biddingMap = array_column((new BiddingStepTemplateModel())->findAll(), 'title', 'step_number');

        foreach ($rows as &$task) {
            $stepCode = (int)($task['step_code'] ?? 0);
            $task['step_name'] = $task['linked_type'] === 'contract'
                ? ($contractMap[$stepCode] ?? null)
                : ($task['linked_type'] === 'bidding' ? ($biddingMap[$stepCode] ?? null) : null);

            $task['assignee'] = [
                'id' => $task['assignee_id'] ?? null,
                'name' => $task['assignee_name'] ?? 'Chưa có',
            ];

            $diff = calculateDeadlineDiff($task['end_date']);
            $task['days_remaining'] = $diff['days_remaining'];
            $task['days_overdue'] = $diff['days_overdue'];

            unset($task['assignee_id'], $task['assignee_name']);
        }

        return $this->respond($rows);
    }

    public function updateSubtask($id = null): ResponseInterface
    {
        $subtask = $this->model->find($id);

        if (!$subtask || !$subtask['parent_id']) {
            return $this->failNotFound('Subtask không tồn tại hoặc không hợp lệ');
        }

        $data = $this->request->getJSON(true);

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond(['message' => 'Subtask updated']);
    }

    public function deleteSubtask($id = null): ResponseInterface
    {
        $subtask = $this->model->find($id);

        if (!$subtask || !$subtask['parent_id']) {
            return $this->failNotFound('Subtask không tồn tại hoặc không hợp lệ');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Subtask deleted']);
    }

    public function byBiddingStep($step_id): ResponseInterface
    {
        $params = $this->request->getGet(); // lấy các query param
        $builder = $this->model->builder();

        $builder->select('tasks.*, users.name as assignee_name');
        $builder->join('users', 'users.id = tasks.assigned_to', 'left');

        $builder->where('step_id', $step_id);

        // Áp dụng các bộ lọc nếu có
        if (!empty($params['assigned_to'])) {
            $builder->where('tasks.assigned_to', $params['assigned_to']);
        }

        if (isset($params['id_department']) && $params['id_department'] !== '') {
            $builder->where('tasks.id_department', (int)$params['id_department']);
        }

        $tasks = $builder->get()->getResultArray();

        return $this->respond($tasks);
    }


    public function byContractStep($step_id): ResponseInterface
    {
        $params = $this->request->getGet(); // lấy query string
        $builder = $this->model->builder();

        $builder->select('tasks.*, users.name as assignee_name, users.id as assignee_id');
        $builder->join('users', 'users.id = tasks.assigned_to', 'left');
        $builder->where('tasks.step_id', $step_id);

        if (!empty($params['assigned_to'])) {
            $builder->where('tasks.assigned_to', $params['assigned_to']);
        }

        if (isset($params['id_department']) && $params['id_department'] !== '') {
            $builder->where('tasks.id_department', (int)$params['id_department']);
        }
        $tasks = $builder->get()->getResultArray();

        // Định dạng giống API chính
        foreach ($tasks as &$task) {
            $task['assignee'] = [
                'id' => $task['assignee_id'] ?? null,
                'name' => $task['assignee_name'] ?? 'Chưa có'
            ];
            unset($task['assignee_id'], $task['assignee_name']);
        }

        return $this->respond($tasks);
    }

    public function getTaskByBiddingStep($stepId): ResponseInterface
    {
        $step = (new BiddingStepModel())->find($stepId);

        if (!$step || !$step['task_id']) {
            return $this->failNotFound("Không tìm thấy bước hoặc bước chưa gán task.");
        }

        $task = (new TaskModel())->find($step['task_id']);

        return $task ? $this->respond($task) : $this->failNotFound("Task không tồn tại.");
    }

    private function createApprovalInstanceForTask(array $task, array $approverIds): void
    {
        $db = db_connect();
        $db->transStart();

        // 1) Tạo bản ghi phiên duyệt
        $aiData = [
            'target_type' => 'task',
            'target_id' => (int)$task['id'],
            'status' => 'pending',
            'current_level' => 0,  // luôn =0 khi mới gửi
            'submitted_by' => (int)(session()->get('user_id') ?? 0),
            'submitted_at' => date('Y-m-d H:i:s'),
            'meta_json' => json_encode([
                'title' => $task['title'],
                'url' => '/internal-tasks/' . $task['id'] . '/info',
                'assignee_name' => $task['assignee']['name'] ?? null,
            ], JSON_UNESCAPED_UNICODE),
        ];
        $db->table('approval_instances')->insert($aiData);
        $aiId = (int)$db->insertID();

        // 2) Thêm các cấp duyệt
        $rows = [];
        foreach (array_values($approverIds) as $i => $uid) {
            $rows[] = [
                'approval_instance_id' => $aiId,
                'level' => $i + 1, // 1-based
                'approver_id' => $uid,
                'status' => 'pending',
            ];
        }
        if ($rows) {
            $db->table('approval_steps')->insertBatch($rows);
        }

        $db->transComplete();
    }


}
