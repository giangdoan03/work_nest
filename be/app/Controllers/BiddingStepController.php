<?php

namespace App\Controllers;

use App\Models\BiddingModel;
use App\Models\BiddingStepModel;
use App\Models\BiddingStepTemplateModel;
use App\Models\TaskModel;
use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class BiddingStepController extends ResourceController
{
    protected $modelName = BiddingStepModel::class;
    protected $format    = 'json';

    public function index(): ResponseInterface
    {
        $biddingId = $this->request->getGet('bidding_id');

        $builder = $this->model->orderBy('step_number');
        if (!empty($biddingId)) {
            $builder = $builder->where('bidding_id', $biddingId);
        }

        $steps   = $builder->findAll();
        $stepIds = array_column($steps, 'id');

        $taskModel = new TaskModel();
        $allTasks  = [];

        if (!empty($stepIds)) {
            // Trả về mảng để thêm field dễ
            $allTasks = $taskModel
                ->asArray()
                ->where('linked_type', 'bidding')
                ->whereIn('step_id', $stepIds)
                ->findAll();
        }

        // === TÍNH days_remaining / days_overdue CHO TỪNG TASK ===
        $tz    = new \DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new \DateTimeImmutable('today', $tz);

        $allTasks = array_map(function(array $task) use ($today, $tz) {
            $task['days_remaining'] = null;
            $task['days_overdue']   = null;

            $endRaw = $task['end_date'] ?? null;
            if ($endRaw) {
                $due = \DateTimeImmutable::createFromFormat('Y-m-d', $endRaw, $tz);
                if ($due === false) {
                    try { $due = new \DateTimeImmutable($endRaw, $tz); }
                    catch (\Throwable $e) { $due = null; }
                }
                if ($due) {
                    $diff = (int)$today->diff($due)->format('%r%a'); // dương: còn; âm: quá
                    $task['days_remaining'] = max(0,  $diff);
                    $task['days_overdue']   = max(0, -$diff);
                }
            }
            return $task;
        }, $allTasks);

        // === LẤY TẬP HỢP TẤT CẢ assigned_to ĐỂ MAP USER 1 LẦN ===
        $allAssigneeIds = array_values(array_unique(array_filter(array_map(
            fn($t) => $t['assigned_to'] ?? null,
            $allTasks
        ))));

        $userById = [];
        if (!empty($allAssigneeIds)) {
            $users = (new UserModel())
                ->asArray()
                ->select('id,name') // thêm cột khác nếu muốn
                ->whereIn('id', $allAssigneeIds)
                ->findAll();

            foreach ($users as $u) {
                // key theo chuỗi để an toàn khi task trả về id dạng string
                $userById[(string)$u['id']] = $u;
            }
        }

        // === NHÓM TASK THEO step_id ===
        $tasksGrouped = [];
        foreach ($allTasks as $t) {
            $tasksGrouped[$t['step_id']][] = $t;
        }

        // === GÁN VỀ STEP + TỔNG HỢP DAYS + ASSIGNEES ===
        foreach ($steps as &$step) {
            $tasks = $tasksGrouped[$step['id']] ?? [];

            // Tổng hợp days ở mức step (như trước)
            $minRemaining = null;
            $maxOverdue   = 0;
            $hasToday     = false;
            $hasAnyDate   = false;

            // Tổng hợp assignees
            $assigneeIds = [];

            foreach ($tasks as $t) {
                // days
                if ($t['days_remaining'] !== null || $t['days_overdue'] !== null) {
                    $hasAnyDate = true;
                }
                if (isset($t['days_remaining']) && $t['days_remaining'] === 0 && !empty($t['end_date'])) {
                    $hasToday = true;
                }
                if (!empty($t['days_remaining']) && $t['days_remaining'] > 0) {
                    $minRemaining = is_null($minRemaining) ? $t['days_remaining'] : min($minRemaining, $t['days_remaining']);
                }
                if (!empty($t['days_overdue']) && $t['days_overdue'] > 0) {
                    $maxOverdue = max($maxOverdue, $t['days_overdue']);
                }

                // assignees
                if (!empty($t['assigned_to'])) {
                    $assigneeIds[] = (string)$t['assigned_to'];
                }
            }

            $assigneeIds = array_values(array_unique($assigneeIds));
            $assigneesDetail = array_values(array_filter(array_map(
                fn($id) => $userById[$id] ?? null,
                $assigneeIds
            )));

            // Gán về step
            $step['tasks']           = $tasks;
            $step['task_count']      = count($tasks);
            $step['task_done_count'] = count(array_filter($tasks, fn($t) => ($t['status'] ?? null) === 'done'));

            if ($hasAnyDate) {
                $step['days_remaining'] = $hasToday ? 0 : $minRemaining;     // 0 nếu có task hạn hôm nay
                $step['days_overdue']   = ($maxOverdue > 0) ? $maxOverdue : 0;
            } else {
                $step['days_remaining'] = null;
                $step['days_overdue']   = null;
            }

            // 👇 Các field mới bạn cần
            $step['assignees']         = $assigneeIds;      // mảng ID
            $step['assignees_detail']  = $assigneesDetail;  // [{id,name,...}]
            $step['assignees_count']   = count($assigneeIds);
            // (tuỳ chọn) chuỗi tên để hiển thị nhanh
            $step['assignees_names']   = implode(', ', array_column($assigneesDetail, 'name'));
        }
        unset($step);

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
        $data['status'] = 0; // Mặc định là 'chưa bắt đầu'
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
        // Tìm bước hiện tại
        $current = $this->model->find($id);
        if (!$current) {
            return $this->failNotFound("Không tìm thấy bước với ID $id.");
        }

        // 🔒 Kiểm tra các bước trước đã hoàn thành chưa
        $unfinishedBefore = $this->model
            ->where('bidding_id', $current['bidding_id'])
            ->where('step_number <', $current['step_number'])
            ->where('status !=', 2) // 2 = hoàn thành
            ->countAllResults();

        if ($unfinishedBefore > 0) {
            return $this->fail('Bạn cần hoàn thành tất cả các bước trước đó.');
        }

        // ✅ Cập nhật bước hiện tại thành hoàn thành
        $updateData = [
            'status' => 2,
            'updated_at' => date('Y-m-d H:i:s'), // đảm bảo cập nhật thời gian
        ];

        if (!$this->model->update($id, $updateData)) {
            return $this->failValidationErrors($this->model->errors());
        }

        // ✅ Mở bước tiếp theo (nếu có)
        $next = $this->model
            ->where('bidding_id', $current['bidding_id'])
            ->where('step_number >', $current['step_number'])
            ->orderBy('step_number', 'asc')
            ->first();

        if ($next) {
            $this->model->update($next['id'], ['status' => 1]);
        }

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




}
