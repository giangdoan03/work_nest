<?php

// app/Controllers/ContractStepController.php
namespace App\Controllers;

use App\Libraries\MailService;
use App\Models\ContractStepModel;
use App\Models\ContractModel;
use App\Models\ContractStepTemplateModel;
use App\Models\TaskModel;
use App\Models\UserModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Models\StepTemplateModel;
use Config\Database;
use DateTimeImmutable;
use DateTimeZone;
use Exception;
use ReflectionException;
use Throwable;

class ContractStepController extends ResourceController
{
    protected $modelName = ContractStepModel::class;
    protected $format    = 'json';

    /**
     * @throws Exception
     */
    public function index($contractId = null): ResponseInterface
    {
        // 1) Lấy steps
        $steps = $this->model
            ->where('contract_id', $contractId)
            ->orderBy('step_number', 'ASC')
            ->findAll();

        if (!$steps) {
            return $this->respond([]);
        }

        $stepIds = array_column($steps, 'id');

        // 2) Lấy tasks của các step
        $taskModel = new TaskModel();
        $tasks = $stepIds
            ? $taskModel->asArray()
                ->where('linked_type', 'contract')
                ->whereIn('step_id', $stepIds)
                ->findAll()
            : [];

        // 3) Tính days_remaining / days_overdue
        $tz    = new DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new DateTimeImmutable('today', $tz);

        foreach ($tasks as &$t) {
            // ĐỔI 'end_date' thành 'due_date' nếu DB bạn dùng due_date
            [$t['days_remaining'], $t['days_overdue']] = $this->calcRemOv($t['end_date'] ?? null, $today, $tz);
        }
        unset($t);

        // 4) Gom theo step_id + gom userIds
        $grouped = [];
        $assigneeIds = [];
        foreach ($tasks as $t) {
            $grouped[$t['step_id']][] = $t;
            if (!empty($t['assigned_to'])) {
                $assigneeIds[(string)$t['assigned_to']] = true;
            }
        }

        // 5) Lấy user detail 1 lần
        $userById = [];
        if ($assigneeIds) {
            $ids = array_keys($assigneeIds);
            $users = (new UserModel())
                ->select('id, name')
                ->whereIn('id', $ids)
                ->findAll();
            foreach ($users as $u) {
                $userById[(string)$u['id']] = $u;
            }
        }

        // 6) Map aggregate vào step (y hệt bidding)
        foreach ($steps as &$s) {
            $tArr = $grouped[$s['id']] ?? [];

            $minRem = null; $maxOv = 0; $hasToday = false; $hasAny = false;
            $uids   = [];   $approvedCount = 0;

            foreach ($tArr as $t) {
                // deadline aggregate
                $r = $t['days_remaining'] ?? null;
                $o = $t['days_overdue']   ?? null;
                if ($r !== null || $o !== null) $hasAny = true;
                if ((int)($r ?? -1) === 0 && !empty($t['end_date'])) $hasToday = true;
                if ($r !== null && (int)$r > 0) $minRem = is_null($minRem) ? (int)$r : min($minRem, (int)$r);
                if ($o !== null && (int)$o > 0) $maxOv  = max($maxOv, (int)$o);

                // assignees aggregate
                if (!empty($t['assigned_to'])) $uids[] = (string)$t['assigned_to'];

                // chỉ tính DONE khi approved
                $status   = (string)($t['status'] ?? '');
                $progress = (int)($t['progress'] ?? 0);
                $approved = (string)($t['approval_status'] ?? '') === 'approved';
                if (($status === 'done' || $progress >= 100) && $approved) {
                    $approvedCount++;
                }
            }

            $uids    = array_values(array_unique($uids));
            $details = array_values(array_filter(array_map(fn($id) => $userById[$id] ?? null, $uids)));

            $totalTasks   = count($tArr);
            $stepProgress = $totalTasks ? (int) round($approvedCount * 100 / $totalTasks) : 0;

            $s['tasks']             = $tArr; // muốn nhẹ response thì bỏ dòng này
            $s['task_count']        = $totalTasks;
            $s['task_done_count']   = $approvedCount;
            $s['step_progress']     = $stepProgress;
            $s['is_step_completed'] = ($totalTasks > 0 && $approvedCount === $totalTasks) ? 1 : 0;
            $s['days_remaining']    = $hasAny ? ($hasToday ? 0 : $minRem) : null;
            $s['days_overdue']      = $hasAny ? $maxOv : null;
            $s['assignees']         = $uids;
            $s['assignees_detail']  = $details;
            $s['assignees_count']   = count($uids);
            $s['assignees_names']   = implode(', ', array_column($details, 'name'));
        }
        unset($s);

        return $this->respond($steps);
    }

    // helper như bên bidding
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




    public function create($contractId = null)
    {
        $data = $this->request->getJSON(true);
        $data['contract_id'] = $contractId;

        if (empty($data['name'])) {
            return $this->failValidationErrors(['name' => 'Tên bước không được bỏ trống']);
        }

        $data['status'] = $data['status'] ?? 'pending';
        $id = $this->model->insert($data);
        return $this->respondCreated(['id' => $id]);
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        $current = $this->model->find($id);

        if (!$current) {
            return $this->failNotFound('Step not found');
        }

        // Nếu người dùng cố cập nhật thành "Hoàn thành" -> kiểm tra logic
        if (isset($data['status']) && (int)$data['status'] === 2) {
            $unfinishedBefore = $this->model
                ->where('contract_id', $current['contract_id'])
                ->where('step_number <', $current['step_number'])
                ->where('status !=', 2)
                ->countAllResults();

            if ($unfinishedBefore > 0) {
                return $this->fail('Bạn cần hoàn thành tất cả các bước trước.');
            }

            $data['completed_at'] = date('Y-m-d H:i:s');
        }

        // ✅ Tránh update khi không có dữ liệu gì
        if (empty($data)) {
            return $this->failValidationErrors('Không có dữ liệu nào để cập nhật.');
        }

        $this->model->update($id, $data);
        return $this->respond(['status' => 'success', 'message' => 'Step updated']);
    }



    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Step not found');
        }

        $this->model->delete($id);
        return $this->respondDeleted(['status' => 'success', 'message' => 'Step deleted']);
    }
    public function addStepsFromTemplates($contractId = null): ResponseInterface
    {
        $contractModel = new ContractModel();
        if (!$contractModel->find($contractId)) {
            return $this->failNotFound("Không tìm thấy hợp đồng với ID $contractId");
        }

        $templateIds = $this->request->getJSON(true)['template_ids'] ?? [];

        if (empty($templateIds) || !is_array($templateIds)) {
            return $this->failValidationErrors(['template_ids' => 'Danh sách bước mẫu không hợp lệ']);
        }

        // Lấy bước mẫu theo đúng thứ tự người dùng chọn
        $templateModel = new StepTemplateModel();
        $templates = [];
        foreach ($templateIds as $id) {
            $template = $templateModel->find($id);
            if ($template) {
                $templates[] = $template;
            }
        }

        // Lấy step_no lớn nhất hiện tại trong hợp đồng
        $insertedIds = $this->getArr($contractId, $templates);

        return $this->respond([
            'status'    => 'success',
            'message'   => 'Đã thêm bước từ thư viện',
            'step_ids'  => $insertedIds
        ]);
    }


    public function reorder($contractId = null): ResponseInterface
    {
        $stepIds = $this->request->getJSON(true)['step_ids'] ?? [];
        if (!is_array($stepIds) || empty($stepIds)) {
            return $this->failValidationErrors(['step_ids' => 'Danh sách bước không hợp lệ']);
        }
        foreach ($stepIds as $index => $stepId) {
            $this->model->update($stepId, ['step_number' => $index + 1]);
        }
        return $this->respond(['status' => 'success', 'message' => 'Đã cập nhật thứ tự bước']);
    }

    public function resequence($contractId = null): ResponseInterface
    {
        $steps = $this->model
            ->where('contract_id', $contractId)
            ->orderBy('created_at', 'ASC')
            ->findAll();

        $i = 1;
        foreach ($steps as $step) {
            $this->model->update($step['id'], ['step_number' => $i++]);
        }

        return $this->respond([
            'status' => 'success',
            'message' => 'Đã cập nhật lại step_number theo thứ tự',
            'total' => count($steps)
        ]);
    }

    public function cloneFromTemplate($contractId = null): ResponseInterface
    {
        $contract = (new ContractModel())->find($contractId);
        if (!$contract) {
            return $this->failNotFound("Không tìm thấy hợp đồng với ID $contractId");
        }

        $db = Database::connect();
        $db->transStart();

        $templateModel = new ContractStepTemplateModel();
        $templates = $templateModel->orderBy('step_number')->findAll();

        // Xoá cũ (nếu cần)
        $this->model->where('contract_id', $contractId)->delete();

        // Insert mới, reindex 1..n
        $rows = [];
        $num = 1;
        foreach ($templates as $t) {
            $rows[] = [
                'contract_id' => $contractId,
                'step_number' => $num,
                'title'       => $t['title'] ?? 'Không tên',
                'department'  => $t['department'] ?? null,
                'status'      => ($num === 1) ? 1 : 0, // mở bước đầu
                'customer_id' => $contract['customer_id'] ?? null,
            ];
            $num++;
        }
        if ($rows) {
            $this->model->insertBatch($rows);
        }

        $db->transComplete();

        if ($db->transStatus() === false) {
            return $this->fail('Không thể clone các bước từ mẫu.');
        }

        return $this->respond([
            'status'  => 'success',
            'message' => 'Đã clone các bước từ mẫu',
        ]);
    }



    /**
     * @param mixed $contractId
     * @param array $templates
     * @return array
     */
    public function getArr(mixed $contractId, array $templates): array
    {
        $max = $this->model
            ->where('contract_id', $contractId)
            ->selectMax('step_number')
            ->first();

        $currentStepNo = isset($max['step_number']) ? (int)$max['step_number'] : 0;
        $insertedIds = [];

        foreach ($templates as $template) {
            $currentStepNo++;

            $stepData = [
                'contract_id'   => $contractId,
                'step_number'   => $template['step_number'] ?? $currentStepNo,
                'title'         => $template['title'] ?? 'Không tên',
                'department'    => $template['department'] ?? null,
                'status'        => '0', // ✔️ để đúng với UI
                'customer_id'   => null,
                'assigned_to'   => null,
                'start_date'    => null,
                'due_date'      => null,
                'completed_at'  => null,
            ];


            $id = $this->model->insert($stepData);
            $insertedIds[] = $id;
        }

        return $insertedIds;
    }

    /**
     * @throws ReflectionException
     */
    public function complete($id = null): ResponseInterface
    {
        $db = Database::connect();
        $db->transStart();

        $current = $this->model->find($id);
        if (!$current) {
            $db->transComplete();
            return $this->failNotFound("Không tìm thấy bước với ID $id");
        }

        // kiểm tra bước trước
        $unfinishedBefore = $this->model
            ->where('contract_id', $current['contract_id'])
            ->where('step_number <', $current['step_number'])
            ->where('status !=', 2)
            ->countAllResults();

        if ($unfinishedBefore > 0) {
            $db->transComplete();
            return $this->fail('Bạn cần hoàn thành tất cả các bước trước đó.');
        }

        // cập nhật bước hiện tại
        $ok1 = $this->model->update($id, [
            'status'       => 2,
            'completed_at' => date('Y-m-d H:i:s'),
        ]);

        // mở bước tiếp theo
        $next = $this->model
            ->where('contract_id', $current['contract_id'])
            ->where('step_number >', $current['step_number'])
            ->orderBy('step_number', 'asc')
            ->first();

        $ok2 = true;
        if ($next) {
            $ok2 = $this->model->update($next['id'], ['status' => 1]);
        }

        $db->transComplete();

        if ($db->transStatus() === false || !$ok1 || !$ok2) {
            return $this->fail('Không thể hoàn thành bước do lỗi giao dịch.');
        }

        return $this->respond([
            'message'      => 'Bước đã hoàn thành và bước kế tiếp đã được mở.',
            'step_id'      => $id,
            'next_step_id' => $next['id'] ?? null,
        ]);
    }



    public function tasksByStep($stepId): ResponseInterface
    {
        $taskModel = new TaskModel();

        $tasks = $taskModel
            ->where('linked_type', 'contract')
            ->where('step_id', $stepId)
            ->findAll();

        return $this->respond([
            'step_id' => $stepId,
            'tasks' => $tasks
        ]);
    }

    private function openNextContractStep(array $currentStep): void
    {
        $next = $this->model
            ->where('contract_id', $currentStep['contract_id'])
            ->where('step_number >', $currentStep['step_number'])
            ->orderBy('step_number', 'asc')
            ->first();

        if ($next && (int)$next['status'] === 0) {
            $this->model->update($next['id'], [
                'status' => 1 // mở bước
            ]);
        }
    }


    public function requestSkip(int $id): ResponseInterface
    {
        if (!session()->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $userId = (int) session()->get('user_id');
        $reason = trim((string)$this->request->getPost('reason'));

        $step = $this->model->find($id);
        if (!$step) return $this->failNotFound();

        if ($step['skip_status'] === 'pending') {
            return $this->fail('Bước này đã gửi yêu cầu bỏ qua');
        }

        $this->model->update($id, [
            'skip_status'       => 'pending',
            'skip_reason'       => $reason,
            'skip_requested_by' => $userId,
            'skip_requested_at' => date('Y-m-d H:i:s'),
        ]);

        $step = $this->model->find($id);

        // 📧 mail xin skip (dùng chung MailService)
        (new MailService())->sendSkipContractStepMail($step);

        return $this->respond([
            'message' => 'Đã gửi yêu cầu bỏ qua, chờ người giao việc xác nhận'
        ]);
    }


    public function approveSkip(int $id): ResponseInterface
    {
        if (!session()->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $userId = (int) session()->get('user_id');

        $step = $this->model->find($id);
        if (!$step || $step['skip_status'] !== 'pending') {
            return $this->fail('Yêu cầu không hợp lệ');
        }

        // 🔒 LẤY MANAGER TỪ CONTRACT
        $contract = db_connect()
            ->table('contracts')
            ->select('manager_id')
            ->where('id', $step['contract_id'])
            ->get()
            ->getRowArray();

        if (!$contract || (int)$contract['manager_id'] !== $userId) {
            return $this->failForbidden('Bạn không có quyền duyệt bỏ qua bước này');
        }

        // ✅ duyệt skip
        $this->model->update($id, [
            'skip_status'       => 'approved',
            'status'            => 2,
            'skip_approved_by'  => $userId,
            'skip_approved_at'  => date('Y-m-d H:i:s'),
        ]);

        $step = $this->model->find($id);

        // 📧 mail thông báo đã duyệt
        (new MailService())->sendApproveSkipContractStepMail($step);

        // ▶️ mở bước tiếp theo
        $this->openNextContractStep($step);

        return $this->respond([
            'message' => 'Đã duyệt bỏ qua bước'
        ]);
    }


    public function rejectSkip(int $id): ResponseInterface
    {
        if (!session()->get('logged_in')) {
            return $this->failUnauthorized();
        }

        $userId = (int) session()->get('user_id');

        $payload = $this->request->getJSON(true);
        $reason  = trim((string)($payload['reason'] ?? ''));

        if ($reason === '') {
            return $this->fail('Vui lòng nhập lý do từ chối');
        }

        $step = $this->model->find($id);
        if (!$step || $step['skip_status'] !== 'pending') {
            return $this->fail('Yêu cầu không hợp lệ');
        }

        $contract = db_connect()
            ->table('contracts')
            ->select('manager_id')
            ->where('id', $step['contract_id'])
            ->get()
            ->getRowArray();

        if ((int)$contract['manager_id'] !== $userId) {
            return $this->failForbidden('Bạn không có quyền từ chối');
        }

        $this->model->update($id, [
            'skip_status'      => 'rejected',
            'skip_approved_by' => $userId,
            'skip_approved_at' => date('Y-m-d H:i:s'),
        ]);

        $step = $this->model->find($id);

        (new MailService())->sendRejectSkipContractStepMail($step, $reason);

        return $this->respond([
            'message' => 'Đã từ chối yêu cầu bỏ qua bước'
        ]);
    }





}
