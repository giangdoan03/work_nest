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

        // 1. Lấy steps
        $steps = $this->model
            ->orderBy('step_number')
            ->when($biddingId, fn($b) => $b->where('bidding_id', $biddingId))
            ->findAll();

        $stepIds = array_column($steps, 'id');

        // 2. Lấy tasks theo stepIds
        $tasks = (!empty($stepIds))
            ? (new TaskModel())
                ->asArray()
                ->where('linked_type', 'bidding')
                ->whereIn('step_id', $stepIds)
                ->findAll()
            : [];

        // 3. Đánh dấu ngày cho mỗi task
        $tz    = new \DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new \DateTimeImmutable('today', $tz);

        foreach ($tasks as &$t) {
            [$t['days_remaining'], $t['days_overdue']] = $this->calcRemOv($t['end_date'] ?? null, $today, $tz);
        }
        unset($t);

        // 4. Map thông tin user 1 lần
        $assigneeIds = array_unique(array_column($tasks, 'assigned_to'));
        $userById = [];
        if ($assigneeIds) {
            $users = (new UserModel())
                ->asArray()
                ->select('id, name')
                ->whereIn('id', $assigneeIds)
                ->findAll();
            foreach ($users as $u) {
                $userById[(string)$u['id']] = $u;
            }
        }

        // 5. Nhóm task theo step
        $grouped = [];
        foreach ($tasks as $t) {
            $grouped[$t['step_id']][] = $t;
        }

        // 6. Tổng hợp vào step
        foreach ($steps as &$s) {
            $tArr = $grouped[$s['id']] ?? [];

            // Tổng ngày
            $minRem = null; $maxOv = 0; $hasToday = false; $hasAny = false;
            $uids   = [];
            foreach ($tArr as $t) {
                if ($t['days_remaining'] !== null || $t['days_overdue'] !== null) $hasAny = true;
                if ($t['days_remaining'] === 0 && !empty($t['end_date']))       $hasToday = true;
                if ($t['days_remaining'] > 0)                                   $minRem = is_null($minRem) ? $t['days_remaining'] : min($minRem, $t['days_remaining']);
                if ($t['days_overdue'] > 0)                                     $maxOv  = max($maxOv, $t['days_overdue']);
                if (!empty($t['assigned_to']))                                  $uids[] = (string) $t['assigned_to'];
            }

            $uids = array_values(array_unique($uids));
            $details = array_values(array_filter(array_map(fn($id) => $userById[$id] ?? null, $uids)));

            $s['tasks']            = $tArr;
            $s['task_count']       = count($tArr);
            $s['task_done_count']  = count(array_filter($tArr, fn($t) => ($t['status'] ?? null) === 'done'));
            $s['days_remaining']   = $hasAny ? ($hasToday ? 0 : $minRem) : null;
            $s['days_overdue']     = $hasAny ? $maxOv : null;
            $s['assignees']        = $uids;
            $s['assignees_detail'] = $details;
            $s['assignees_count']  = count($uids);
            $s['assignees_names']  = implode(', ', array_column($details, 'name'));
        }
        unset($s);

        return $this->respond($steps);
    }


    /**
     * Tính days_remaining và days_overdue từ end_date
     */
    private function calcRemOv(?string $endDate, \DateTimeImmutable $today, \DateTimeZone $tz): array
    {
        if (!$endDate) return [null, null];

        $due = \DateTimeImmutable::createFromFormat('Y-m-d', $endDate, $tz);
        if ($due === false) {
            try { $due = new \DateTimeImmutable($endDate, $tz); }
            catch (\Throwable $e) { return [null, null]; }
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
