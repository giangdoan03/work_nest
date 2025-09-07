<?php

namespace App\Controllers;

use App\Models\BiddingModel;
use App\Models\BiddingStepModel;
use App\Models\BiddingStepTemplateModel;
use App\Models\TaskModel;
use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use DateTimeImmutable;
use DateTimeZone;
use Exception;
use Throwable;

class BiddingStepController extends ResourceController
{
    protected $modelName = BiddingStepModel::class;
    protected $format    = 'json';

    /* =========================
     *          PUBLIC
     * ========================= */

    /**
     * Danh sách bước (tuỳ chọn ?bidding_id=..., ?with_tasks=0/1)
     * - Hành vi mặc định: có tasks.
     * @throws Exception
     */
    public function index(): ResponseInterface
    {
        $biddingId = $this->request->getGet('bidding_id');
        $withTasks = (int)($this->request->getGet('with_tasks') ?? 1) === 1;

        // 1) Lấy steps (có thể lọc theo bidding_id)
        $steps = $this->fetchSteps($biddingId);

        if (!$steps) {
            return $this->respond([]);
        }

        // 2) Tính toán & hợp nhất (tự xử lý with_tasks)
        $steps = $this->enrichSteps($steps, $withTasks);

        return $this->respond($steps);
    }

    public function show($id = null)
    {
        $step = $this->model->find($id);
        return $step ? $this->respond($step) : $this->failNotFound("Không tìm thấy bước.");
    }

    public function create()
    {
        $data = $this->request->getJSON(true);

        $data['status']          = $data['status']          ?? 0;
        $data['current_level']   = $data['current_level']   ?? 0;
        $data['approval_status'] = $data['approval_status'] ?? 'pending';
        $data['approval_steps']  = $data['approval_steps']  ?? null;

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }
        return $this->respondCreated($data);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        if (empty($data)) return $this->failValidationErrors("Không có dữ liệu để cập nhật.");

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond(['message' => 'Cập nhật thành công']);
    }

    public function delete($id = null)
    {
        if (!$this->model->delete($id)) {
            return $this->failNotFound("Không tìm thấy bước để xoá.");
        }
        return $this->respondDeleted(['message' => 'Đã xoá bước.']);
    }

    /**
     * Hoàn thành 1 bước và mở bước kế tiếp
     */
    public function completeStep($id): ResponseInterface
    {
        $db = db_connect();
        $db->transStart();

        // Khoá record để đảm bảo an toàn cạnh tranh
        $current = $this->model->lockForUpdate()->find($id);
        if (!$current) {
            $db->transComplete();
            return $this->failNotFound("Không tìm thấy bước với ID $id.");
        }

        // Kiểm tra còn bước trước chưa hoàn thành
        $unfinishedBefore = $this->model
            ->where('bidding_id', $current['bidding_id'])
            ->where('step_number <', $current['step_number'])
            ->where('status !=', 2)
            ->countAllResults();

        if ($unfinishedBefore > 0) {
            $db->transComplete();
            return $this->fail('Bạn cần hoàn thành tất cả các bước trước đó.');
        }

        // Cập nhật bước hiện tại → hoàn thành
        if (!$this->model->update($id, ['status' => 2, 'updated_at' => date('Y-m-d H:i:s')])) {
            $db->transComplete();
            return $this->failValidationErrors($this->model->errors());
        }

        // Mở bước tiếp theo (nếu có)
        $next = $this->model
            ->where('bidding_id', $current['bidding_id'])
            ->where('step_number >', $current['step_number'])
            ->orderBy('step_number', 'asc')
            ->first();

        if ($next) {
            $this->model->update($next['id'], ['status' => 1]);
        }

        $db->transComplete();

        return $this->respond([
            'message'      => 'Bước đã hoàn thành và bước kế tiếp đã được mở.',
            'step_id'      => $id,
            'next_step_id' => $next['id'] ?? null,
        ]);
    }

    /**
     * Clone các bước từ template cho 1 gói thầu
     */
    public function cloneFromTemplates($biddingId): ResponseInterface
    {
        $templateModel = new BiddingStepTemplateModel();
        $templates = $templateModel->orderBy('step_number')->findAll();
        if (empty($templates)) return $this->failNotFound("Không có bước mẫu để clone.");

        $bidding = (new BiddingModel())->find($biddingId);
        if (!$bidding) return $this->failNotFound("Không tìm thấy gói thầu.");

        // Xoá bước cũ
        $this->model->where('bidding_id', $biddingId)->delete();

        $rows = [];
        foreach ($templates as $tpl) {
            $rows[] = [
                'bidding_id'  => $biddingId,
                'step_number' => $tpl['step_number'],
                'title'       => $tpl['title'],
                'department'  => $tpl['department'] ?? null,
                'status'      => ($tpl['step_number'] == 1 ? 1 : 0),
                'customer_id' => $bidding['customer_id'] ?? null,
            ];
        }

        $this->model->insertBatch($rows);
        return $this->respond(['message' => 'Đã khởi tạo các bước từ mẫu']);
    }

    /**
     * Tasks theo step (đơn giản, giữ lại để tương thích)
     */
    public function tasksByStep($stepId): ResponseInterface
    {
        $tasks = (new TaskModel())
            ->where('linked_type', 'bidding')
            ->where('step_id', $stepId)
            ->findAll();

        return $this->respond(['step_id' => $stepId, 'tasks' => $tasks]);
    }

    /**
     * Lấy các bước theo gói thầu (giống index nhưng bắt buộc có bidding_id)
     * @throws Exception
     */
    public function stepsByBidding(int $biddingId): ResponseInterface
    {
        if ($biddingId <= 0) {
            return $this->failValidationErrors(['bidding_id' => 'Thiếu hoặc không hợp lệ.']);
        }
        $withTasks = (int)($this->request->getGet('with_tasks') ?? 1) === 1;

        $steps = $this->fetchSteps($biddingId);
        if (!$steps) return $this->respond([]);

        $steps = $this->enrichSteps($steps, $withTasks);

        return $this->respond($steps);
    }

    /**
     * Chi tiết 1 bước (kèm tổng hợp)
     * @throws Exception
     */
    public function stepDetail(int $biddingId, int $stepId): ResponseInterface
    {
        if ($biddingId <= 0 || $stepId <= 0) {
            return $this->failValidationErrors(['id' => 'Thiếu hoặc không hợp lệ.']);
        }

        $step = $this->model
            ->asArray()
            ->where('id', $stepId)
            ->where('bidding_id', $biddingId)
            ->first();

        if (!$step) {
            return $this->failNotFound("Không tìm thấy bước #{$stepId} của gói thầu #{$biddingId}.");
        }

        $withTasks = (int)($this->request->getGet('with_tasks') ?? 1) === 1;

        $tz    = new DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new DateTimeImmutable('today', $tz);

        // Lấy tasks (có thể bỏ qua)
        $tasks = $withTasks
            ? $this->fetchTasksByStepIds([$stepId])
            : [];

        // Annotate deadline cho task
        if ($tasks) $this->annotateTaskDeadline($tasks, $today, $tz);

        // Gom assignees & map user
        $assigneeIds = $this->collectAssigneeIds($tasks, $step['assigned_to'] ?? null);
        $userById    = $assigneeIds ? $this->mapUsersById($assigneeIds) : [];

        // Gộp tính toán vào step
        $this->applyAggregateToStep($step, $tasks, $userById, $today, $tz, $withTasks);

        return $this->respond($step);
    }

    /* =========================
     *        PRIVATE HELPERS
     * ========================= */

    /**
     * Lấy danh sách steps (tuỳ chọn theo bidding_id)
     */
    private function fetchSteps(?int $biddingId): array
    {
        $builder = $this->model->asArray()->orderBy('step_number', 'asc');
        if (!empty($biddingId)) {
            $builder->where('bidding_id', $biddingId);
        }
        return $builder->findAll() ?: [];
    }

    /**
     * Lấy tất cả task theo danh sách stepIds (linked_type='bidding')
     */
    private function fetchTasksByStepIds(array $stepIds): array
    {
        $stepIds = array_values(array_unique(array_filter(array_map('intval', $stepIds))));
        if (empty($stepIds)) return [];

        return (new TaskModel())
            ->asArray()
            ->where('linked_type', 'bidding')
            ->whereIn('step_id', $stepIds)
            ->findAll() ?: [];
    }

    /**
     * Annotate deadline cho từng task (days_remaining, days_overdue)
     */
    private function annotateTaskDeadline(array &$tasks, DateTimeImmutable $today, DateTimeZone $tz): void
    {
        foreach ($tasks as &$t) {
            [$t['days_remaining'], $t['days_overdue']] = $this->calcRemOv($t['end_date'] ?? null, $today, $tz);
        }
        unset($t);
    }

    /**
     * Gom userIds từ tasks + fallback stepAssignedId
     */
    private function collectAssigneeIds(array $tasks, $stepAssignedId = null): array
    {
        $ids = [];
        foreach ($tasks as $t) {
            if (!empty($t['assigned_to'])) $ids[] = (int)$t['assigned_to'];
        }
        if (!empty($stepAssignedId)) $ids[] = (int)$stepAssignedId;

        return array_values(array_unique(array_filter($ids)));
    }

    /**
     * Load users theo ids → map id => ['id','name']
     */
    private function mapUsersById(array $ids): array
    {
        if (empty($ids)) return [];
        $users = (new UserModel())
            ->asArray()
            ->select('id, name')
            ->whereIn('id', $ids)
            ->findAll();

        $map = [];
        foreach ($users as $u) {
            $map[(string)$u['id']] = $u;
        }
        return $map;
    }

    /**
     * Group tasks theo step_id
     */
    private function groupTasksByStep(array $tasks): array
    {
        $grouped = [];
        foreach ($tasks as $t) {
            $grouped[$t['step_id']][] = $t;
        }
        return $grouped;
    }

    /**
     * Gộp tính toán (progress/deadline/assignees) vào 1 step
     */
    private function applyAggregateToStep(array &$step, array $tasks, array $userById, DateTimeImmutable $today, DateTimeZone $tz, bool $withTasks): void
    {
        $minRem = null; $maxOv = 0; $hasToday = false; $hasAnyTaskDate = false;
        $uids   = [];
        $approvedCount = 0;

        foreach ($tasks as $t) {
            // Deadline từ task
            $hasAnyTaskDate = $hasAnyTaskDate || ($t['days_remaining'] !== null || $t['days_overdue'] !== null);
            if ((int)($t['days_remaining'] ?? -1) === 0 && !empty($t['end_date'])) $hasToday = true;

            if (($t['days_remaining'] ?? null) !== null && (int)$t['days_remaining'] > 0) {
                $minRem = is_null($minRem) ? (int)$t['days_remaining'] : min($minRem, (int)$t['days_remaining']);
            }
            if (($t['days_overdue'] ?? null) !== null && (int)$t['days_overdue'] > 0) {
                $maxOv = max($maxOv, (int)$t['days_overdue']);
            }

            // Assignees
            if (!empty($t['assigned_to'])) $uids[] = (string)(int)$t['assigned_to'];

            // Chỉ tính DONE khi đã được duyệt
            $status   = (string)($t['status'] ?? '');
            $progress = (int)($t['progress'] ?? 0);
            $approved = (string)($t['approval_status'] ?? '') === 'approved';
            if (($status === 'done' || $progress >= 100) && $approved) {
                $approvedCount++;
            }
        }

        // Fallback assignee từ step
        if (!empty($step['assigned_to'])) $uids[] = (string)(int)$step['assigned_to'];

        $uids    = array_values(array_unique(array_filter($uids)));
        $details = array_values(array_filter(array_map(fn($id) => $userById[$id] ?? null, $uids)));

        $totalTasks   = count($tasks);
        $statusOnStep = (int)($step['status'] ?? 0);

        // Progress
        if ($totalTasks > 0) {
            $stepProgress = (int) round($approvedCount * 100 / max(1, $totalTasks));
            $isCompleted  = ($approvedCount === $totalTasks) ? 1 : 0;
        } else {
            $stepProgress = ($statusOnStep === 2) ? 100 : 0;
            $isCompleted  = ($statusOnStep === 2) ? 1   : 0;
        }

        // Deadline ưu tiên aggregate từ task, fallback end_date của step
        if ($hasAnyTaskDate) {
            $daysRemaining = $hasToday ? 0 : $minRem;
            $daysOverdue   = $maxOv;
        } else {
            [$daysRemaining, $daysOverdue] = $this->calcRemOv($step['end_date'] ?? null, $today, $tz);
        }

        // Output gộp
        $step['tasks']             = $withTasks ? $tasks : [];
        $step['task_count']        = $totalTasks;
        $step['task_done_count']   = $approvedCount;
        $step['step_progress']     = $stepProgress;
        $step['is_step_completed'] = $isCompleted;

        $step['days_remaining']    = $daysRemaining;
        $step['days_overdue']      = $daysOverdue;

        $step['assignees']         = $uids;
        $step['assignees_detail']  = $details;
        $step['assignees_count']   = count($uids);
        $step['assignees_names']   = implode(', ', array_column($details, 'name'));
    }

    /**
     * Enrich danh sách steps (dùng chung cho index & stepsByBidding)
     * @throws Exception
     */
    private function enrichSteps(array $steps, bool $withTasks): array
    {
        $tz    = new DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new DateTimeImmutable('today', $tz);

        $stepIds = array_column($steps, 'id');

        // Lấy tasks 1 lần cho toàn bộ steps
        $tasks = $withTasks ? $this->fetchTasksByStepIds($stepIds) : [];
        if ($tasks) $this->annotateTaskDeadline($tasks, $today, $tz);

        // Gom chung assignee ids từ tasks + step.assigned_to
        $assigneeIds = $this->collectAssigneeIds($tasks);
        foreach ($steps as $s) {
            if (!empty($s['assigned_to'])) $assigneeIds[] = (int)$s['assigned_to'];
        }
        $assigneeIds = array_values(array_unique(array_filter($assigneeIds)));

        $userById = $assigneeIds ? $this->mapUsersById($assigneeIds) : [];
        $byStep   = $this->groupTasksByStep($tasks);

        // Bơm aggregate vào từng step
        foreach ($steps as &$s) {
            $tArr = $withTasks ? ($byStep[$s['id']] ?? []) : [];
            $this->applyAggregateToStep($s, $tArr, $userById, $today, $tz, $withTasks);
        }
        unset($s);

        return $steps;
    }

    /**
     * Tính days_remaining / days_overdue từ end_date
     */
    private function calcRemOv(?string $endDate, DateTimeImmutable $today, DateTimeZone $tz): array
    {
        if (!$endDate) return [null, null];

        $due = DateTimeImmutable::createFromFormat('Y-m-d', $endDate, $tz);
        if ($due === false) {
            try { $due = new DateTimeImmutable($endDate, $tz); }
            catch (Throwable) { return [null, null]; }
        }

        $diff = (int)$today->diff($due)->format('%r%a');
        return [ max(0, $diff), max(0, -$diff) ];
    }
}
