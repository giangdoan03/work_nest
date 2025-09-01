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

    /**
     * @throws Exception
     */
    public function index(): ResponseInterface
    {
        $biddingId = $this->request->getGet('bidding_id');

        // 1) Steps
        $steps = $this->model
            ->orderBy('step_number')
            ->when($biddingId, fn($b) => $b->where('bidding_id', $biddingId))
            ->findAll();
        $stepIds = array_column($steps, 'id');

        // 2) Tasks theo stepIds
        $tasks = (!empty($stepIds))
            ? (new TaskModel())
                ->asArray()
                ->where('linked_type', 'bidding')
                ->whereIn('step_id', $stepIds)
                ->findAll()
            : [];

        // 3) Đánh dấu ngày cho task
        $tz    = new DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new DateTimeImmutable('today', $tz);

        foreach ($tasks as &$t) {
            [$t['days_remaining'], $t['days_overdue']] = $this->calcRemOv($t['end_date'] ?? null, $today, $tz);
        }
        unset($t);

        // 4) Gom userIds từ tasks + từ step.assigned_to
        $assigneeIds = [];
        foreach ($tasks as $t) {
            if (!empty($t['assigned_to'])) $assigneeIds[] = (int)$t['assigned_to'];
        }
        foreach ($steps as $s) {
            if (!empty($s['assigned_to'])) $assigneeIds[] = (int)$s['assigned_to'];
        }
        $assigneeIds = array_values(array_unique(array_filter($assigneeIds)));

        $userById = [];
        if (!empty($assigneeIds)) {
            $users = (new UserModel())
                ->asArray()
                ->select('id, name')
                ->whereIn('id', $assigneeIds)
                ->findAll();
            foreach ($users as $u) {
                $userById[(string)$u['id']] = $u;
            }
        }

        // 5) Nhóm task theo step
        $grouped = [];
        foreach ($tasks as $t) {
            $grouped[$t['step_id']][] = $t;
        }

        // 6) Tổng hợp vào step (có fallback theo dữ liệu step)
        foreach ($steps as &$s) {
            $tArr = $grouped[$s['id']] ?? [];

            $minRem = null; $maxOv = 0; $hasToday = false; $hasAnyTaskDate = false;
            $uids   = [];
            $approvedCount = 0;

            foreach ($tArr as $t) {
                // --- deadline aggregate từ task ---
                if ($t['days_remaining'] !== null || $t['days_overdue'] !== null) $hasAnyTaskDate = true;
                if ((int)($t['days_remaining'] ?? -1) === 0 && !empty($t['end_date'])) $hasToday = true;
                if (($t['days_remaining'] ?? null) !== null && (int)$t['days_remaining'] > 0) {
                    $minRem = is_null($minRem) ? (int)$t['days_remaining'] : min($minRem, (int)$t['days_remaining']);
                }
                if (($t['days_overdue'] ?? null) !== null && (int)$t['days_overdue'] > 0) {
                    $maxOv  = max($maxOv, (int)$t['days_overdue']);
                }

                // --- assignees từ task ---
                if (!empty($t['assigned_to'])) $uids[] = (string)(int)$t['assigned_to'];

                // --- chỉ tính "đã hoàn thành" khi đã DUYỆT ---
                $status   = (string)($t['status'] ?? '');
                $progress = (int)($t['progress'] ?? 0);
                $approved = (string)($t['approval_status'] ?? '') === 'approved';
                if (($status === 'done' || $progress >= 100) && $approved) {
                    $approvedCount++;
                }
            }

            // 👉 Fallback: thêm người phụ trách ở cấp step nếu có
            if (!empty($s['assigned_to'])) {
                $uids[] = (string)(int)$s['assigned_to'];
            }

            $uids    = array_values(array_unique(array_filter($uids)));
            $details = array_values(array_filter(array_map(fn($id) => $userById[$id] ?? null, $uids)));

            $totalTasks = count($tArr);

            // 👉 Progress: nếu không có task, dùng trạng thái step
            if ($totalTasks > 0) {
                $stepProgress = (int) round($approvedCount * 100 / $totalTasks);
                $isCompleted  = ($approvedCount === $totalTasks) ? 1 : 0;
            } else {
                $stepProgress = ((int)($s['status'] ?? 0) === 2) ? 100 : 0;
                $isCompleted  = ((int)($s['status'] ?? 0) === 2) ? 1   : 0;
            }

            // 👉 Deadline: nếu không có ngày ở task thì fallback ngày của step
            $daysRemaining = null; $daysOverdue = null;
            if ($hasAnyTaskDate) {
                $daysRemaining = $hasToday ? 0 : $minRem;
                $daysOverdue   = $maxOv;
            } else {
                // dùng end_date của step
                [$daysRemaining, $daysOverdue] = $this->calcRemOv($s['end_date'] ?? null, $today, $tz);
            }

            // Gán output
            $s['tasks']             = $tArr;
            $s['task_count']        = $totalTasks;
            $s['task_done_count']   = $approvedCount;
            $s['step_progress']     = $stepProgress;
            $s['is_step_completed'] = $isCompleted;

            $s['days_remaining']    = $daysRemaining;
            $s['days_overdue']      = $daysOverdue;

            $s['assignees']         = $uids;
            $s['assignees_detail']  = $details;
            $s['assignees_count']   = count($uids);
            $s['assignees_names']   = implode(', ', array_column($details, 'name'));
        }
        unset($s);

        return $this->respond($steps);
    }



    /**
     * Tính days_remaining và days_overdue từ end_date
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
        return [
            max(0, $diff),   // days_remaining
            max(0, -$diff),  // days_overdue
        ];
    }


    public function show($id = null)
    {
        $step = $this->model->find($id);
        return $step ? $this->respond($step) : $this->failNotFound("Không tìm thấy bước.");
    }

    public function create()
    {
        $data = $this->request->getJSON(true);
        $data['status']          = $data['status'] ?? 0;
        $data['current_level']   = $data['current_level'] ?? 0;
        $data['approval_status'] = $data['approval_status'] ?? 'pending';
        $data['approval_steps']  = $data['approval_steps'] ?? null; // hoặc [] nếu đã cast JSON

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }
        return $this->respondCreated($data);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);

        if (empty($data)) {
            return $this->failValidationErrors("Không có dữ liệu để cập nhật.");
        }

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

    public function completeStep($id): ResponseInterface
    {
        $db = db_connect();
        $db->transStart();

        $current = $this->model->lockForUpdate()->find($id);
        if (!$current) {
            $db->transComplete();
            return $this->failNotFound("Không tìm thấy bước với ID $id.");
        }

        $unfinishedBefore = $this->model
            ->where('bidding_id', $current['bidding_id'])
            ->where('step_number <', $current['step_number'])
            ->where('status !=', 2)
            ->countAllResults();

        if ($unfinishedBefore > 0) {
            $db->transComplete();
            return $this->fail('Bạn cần hoàn thành tất cả các bước trước đó.');
        }

        if (!$this->model->update($id, ['status' => 2, 'updated_at' => date('Y-m-d H:i:s')])) {
            $db->transComplete();
            return $this->failValidationErrors($this->model->errors());
        }

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
            'message' => 'Bước đã hoàn thành và bước kế tiếp đã được mở.',
            'step_id' => $id,
            'next_step_id' => $next['id'] ?? null,
        ]);
    }


    public function cloneFromTemplates($biddingId): ResponseInterface
    {
        $templateModel = new BiddingStepTemplateModel();
        $steps = $templateModel->orderBy('step_number')->findAll();

        if (empty($steps)) {
            return $this->failNotFound("Không có bước mẫu để clone.");
        }

        $biddingModel = new BiddingModel();
        $bidding = $biddingModel->find($biddingId);

        if (!$bidding) {
            return $this->failNotFound("Không tìm thấy gói thầu.");
        }

        // ❗️XÓA CÁC BƯỚC CŨ trước khi clone
        $this->model->where('bidding_id', $biddingId)->delete();

        $newSteps = [];
        foreach ($steps as $index => $step) {
            $newSteps[] = [
                'bidding_id'   => $biddingId,
                'step_number'  => $step['step_number'],
                'title'        => $step['title'],
                'department'   => $step['department'] ?? null,
                'status'       => $step['step_number'] == 1 ? 1 : 0,
                'customer_id'  => $bidding['customer_id'] ?? null,
            ];
        }

        $this->model->insertBatch($newSteps);

        return $this->respond(['message' => 'Đã khởi tạo các bước từ mẫu']);
    }

    public function tasksByStep($stepId): ResponseInterface
    {
        $taskModel = new TaskModel();

        $tasks = $taskModel
            ->where('linked_type', 'bidding')
            ->where('step_id', $stepId)
            ->findAll();

        return $this->respond([
            'step_id' => $stepId,
            'tasks' => $tasks
        ]);
    }

    public function stepsByBidding(int $biddingId): ResponseInterface
    {
        if ($biddingId <= 0) {
            return $this->failValidationErrors(['bidding_id' => 'Thiếu hoặc không hợp lệ.']);
        }

        // allow skip tasks to reduce payload: ?with_tasks=0
        $withTasks = (int)($this->request->getGet('with_tasks') ?? 1) === 1;

        // 1) Lấy steps
        $steps = $this->model
            ->asArray()
            ->where('bidding_id', $biddingId)
            ->orderBy('step_number', 'asc')
            ->findAll();

        if (!$steps) {
            return $this->respond([]); // không có bước nào
        }

        $stepIds = array_column($steps, 'id');

        // 2) Lấy tasks theo step (tuỳ chọn)
        $tasks = [];
        if ($withTasks && !empty($stepIds)) {
            $tasks = (new TaskModel())
                ->asArray()
                ->where('linked_type', 'bidding')
                ->whereIn('step_id', $stepIds)
                ->findAll();
        }

        // 3) Đánh dấu ngày cho task
        $tz    = new \DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new \DateTimeImmutable('today', $tz);
        foreach ($tasks as &$t) {
            [$t['days_remaining'], $t['days_overdue']] = $this->calcRemOv($t['end_date'] ?? null, $today, $tz);
        }
        unset($t);

        // 4) Gom userIds từ TASKS + từ STEP.assigned_to
        $assigneeIds = [];
        foreach ($tasks as $t) {
            if (!empty($t['assigned_to'])) $assigneeIds[] = (int)$t['assigned_to'];
        }
        foreach ($steps as $s) {
            if (!empty($s['assigned_to'])) $assigneeIds[] = (int)$s['assigned_to'];
        }
        $assigneeIds = array_values(array_unique(array_filter($assigneeIds)));

        // 5) Map user id -> name
        $userById = [];
        if ($assigneeIds) {
            $users = (new \App\Models\UserModel())
                ->asArray()
                ->select('id, name')
                ->whereIn('id', $assigneeIds)
                ->findAll();
            foreach ($users as $u) {
                $userById[(string)$u['id']] = $u;
            }
        }

        // 6) Nhóm task theo step
        $byStep = [];
        foreach ($tasks as $t) {
            $byStep[$t['step_id']][] = $t;
        }

        // 7) Tổng hợp vào step (có fallback theo dữ liệu step)
        foreach ($steps as &$s) {
            $tArr = $withTasks ? ($byStep[$s['id']] ?? []) : [];

            $minRem = null; $maxOv = 0; $hasToday = false; $hasAnyTaskDate = false;
            $uids   = [];
            $approvedCount = 0;

            foreach ($tArr as $t) {
                // --- deadline aggregate từ task ---
                if ($t['days_remaining'] !== null || $t['days_overdue'] !== null) $hasAnyTaskDate = true;
                if ((int)($t['days_remaining'] ?? -1) === 0 && !empty($t['end_date'])) $hasToday = true;
                if (($t['days_remaining'] ?? null) !== null && (int)$t['days_remaining'] > 0) {
                    $minRem = is_null($minRem) ? (int)$t['days_remaining'] : min($minRem, (int)$t['days_remaining']);
                }
                if (($t['days_overdue'] ?? null) !== null && (int)$t['days_overdue'] > 0) {
                    $maxOv  = max($maxOv, (int)$t['days_overdue']);
                }

                // --- assignees từ task ---
                if (!empty($t['assigned_to'])) $uids[] = (string)(int)$t['assigned_to'];

                // --- chỉ tính "đã hoàn thành" khi đã DUYỆT ---
                $status   = (string)($t['status'] ?? '');
                $progress = (int)($t['progress'] ?? 0);
                $approved = (string)($t['approval_status'] ?? '') === 'approved';
                if (($status === 'done' || $progress >= 100) && $approved) {
                    $approvedCount++;
                }
            }

            // Fallback: thêm người phụ trách ở cấp step nếu có
            if (!empty($s['assigned_to'])) {
                $uids[] = (string)(int)$s['assigned_to'];
            }

            $uids    = array_values(array_unique(array_filter($uids)));
            $details = array_values(array_filter(array_map(fn($id) => $userById[$id] ?? null, $uids)));

            $totalTasks = count($tArr);

            // Progress: nếu không có task, dùng trạng thái step (2=hoàn thành)
            if ($totalTasks > 0) {
                $stepProgress = (int) round($approvedCount * 100 / $totalTasks);
                $isCompleted  = ($approvedCount === $totalTasks) ? 1 : 0;
            } else {
                $stepProgress = ((int)($s['status'] ?? 0) === 2) ? 100 : 0;
                $isCompleted  = ((int)($s['status'] ?? 0) === 2) ? 1   : 0;
            }

            // Deadline: nếu không có ngày ở task thì fallback ngày của step
            $daysRemaining = null; $daysOverdue = null;
            if ($hasAnyTaskDate) {
                $daysRemaining = $hasToday ? 0 : $minRem;
                $daysOverdue   = $maxOv;
            } else {
                [$daysRemaining, $daysOverdue] = $this->calcRemOv($s['end_date'] ?? null, $today, $tz);
            }

            // Output
            $s['tasks']             = $withTasks ? $tArr : []; // nếu with_tasks=0 trả mảng rỗng cho nhẹ
            $s['task_count']        = $totalTasks;
            $s['task_done_count']   = $approvedCount;
            $s['step_progress']     = $stepProgress;
            $s['is_step_completed'] = $isCompleted;

            $s['days_remaining']    = $daysRemaining;
            $s['days_overdue']      = $daysOverdue;

            $s['assignees']         = $uids;
            $s['assignees_detail']  = $details;
            $s['assignees_count']   = count($uids);
            $s['assignees_names']   = implode(', ', array_column($details, 'name'));
        }
        unset($s);

        return $this->respond($steps);
    }

    public function stepDetail(int $biddingId, int $stepId): ResponseInterface
    {
        // 0) Validate
        if ($biddingId <= 0 || $stepId <= 0) {
            return $this->failValidationErrors(['id' => 'Thiếu hoặc không hợp lệ.']);
        }

        // 1) Lấy step và đảm bảo step thuộc về gói thầu
        $step = $this->model
            ->asArray()
            ->where('id', $stepId)
            ->where('bidding_id', $biddingId)
            ->first();

        if (!$step) {
            return $this->failNotFound("Không tìm thấy bước #{$stepId} của gói thầu #{$biddingId}.");
        }

        // allow skip tasks to reduce payload: ?with_tasks=0
        $withTasks = (int)($this->request->getGet('with_tasks') ?? 1) === 1;

        // 2) Lấy tasks của step
        $tasks = [];
        if ($withTasks) {
            $tasks = (new \App\Models\TaskModel())
                ->asArray()
                ->where('linked_type', 'bidding')
                ->where('step_id', $stepId)
                ->findAll();
        }

        // 3) Tính days_remaining / days_overdue cho task
        $tz    = new \DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new \DateTimeImmutable('today', $tz);

        foreach ($tasks as &$t) {
            [$t['days_remaining'], $t['days_overdue']] = $this->calcRemOv($t['end_date'] ?? null, $today, $tz);
        }
        unset($t);

        // 4) Gom assignees từ task + fallback step.assigned_to
        $assigneeIds = [];
        foreach ($tasks as $t) {
            if (!empty($t['assigned_to'])) $assigneeIds[] = (int)$t['assigned_to'];
        }
        if (!empty($step['assigned_to'])) {
            $assigneeIds[] = (int)$step['assigned_to'];
        }
        $assigneeIds = array_values(array_unique(array_filter($assigneeIds)));

        $userById = [];
        if ($assigneeIds) {
            $users = (new \App\Models\UserModel())
                ->asArray()
                ->select('id, name')
                ->whereIn('id', $assigneeIds)
                ->findAll();
            foreach ($users as $u) {
                $userById[(string)$u['id']] = $u;
            }
        }

        // 5) Tổng hợp progress & deadline ở cấp bước
        $minRem = null; $maxOv = 0; $hasToday = false; $hasAnyTaskDate = false;
        $uids = [];
        $approvedCount = 0;

        foreach ($tasks as $t) {
            if ($t['days_remaining'] !== null || $t['days_overdue'] !== null) $hasAnyTaskDate = true;
            if ((int)($t['days_remaining'] ?? -1) === 0 && !empty($t['end_date'])) $hasToday = true;
            if (($t['days_remaining'] ?? null) !== null && (int)$t['days_remaining'] > 0) {
                $minRem = is_null($minRem) ? (int)$t['days_remaining'] : min($minRem, (int)$t['days_remaining']);
            }
            if (($t['days_overdue'] ?? null) !== null && (int)$t['days_overdue'] > 0) {
                $maxOv = max($maxOv, (int)$t['days_overdue']);
            }

            if (!empty($t['assigned_to'])) $uids[] = (string)(int)$t['assigned_to'];

            // Chỉ tính DONE khi đã được duyệt
            $status   = (string)($t['status'] ?? '');
            $progress = (int)($t['progress'] ?? 0);
            $approved = (string)($t['approval_status'] ?? '') === 'approved';
            if (($status === 'done' || $progress >= 100) && $approved) {
                $approvedCount++;
            }
        }

        if (!empty($step['assigned_to'])) {
            $uids[] = (string)(int)$step['assigned_to'];
        }
        $uids    = array_values(array_unique(array_filter($uids)));
        $details = array_values(array_filter(array_map(fn($id) => $userById[$id] ?? null, $uids)));

        $totalTasks = count($tasks);

        // Progress: nếu không có task → dùng trạng thái step (2 = hoàn thành)
        if ($totalTasks > 0) {
            $stepProgress = (int) round($approvedCount * 100 / $totalTasks);
            $isCompleted  = ($approvedCount === $totalTasks) ? 1 : 0;
        } else {
            $stepProgress = ((int)($step['status'] ?? 0) === 2) ? 100 : 0;
            $isCompleted  = ((int)($step['status'] ?? 0) === 2) ? 1   : 0;
        }

        // Deadline: ưu tiên aggregate từ task, nếu không có thì fallback end_date của step
        $daysRemaining = null; $daysOverdue = null;
        if ($hasAnyTaskDate) {
            $daysRemaining = $hasToday ? 0 : $minRem;
            $daysOverdue   = $maxOv;
        } else {
            [$daysRemaining, $daysOverdue] = $this->calcRemOv($step['end_date'] ?? null, $today, $tz);
        }

        // 6) Gộp output
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

        return $this->respond($step);
    }




}
