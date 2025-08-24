<?php

namespace App\Controllers;

use App\Models\ContractModel;
use App\Models\ContractStepModel;
use App\Models\SettingModel;
use App\Models\UserModel;
use App\Models\BiddingModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use DateTimeImmutable;
use DateTimeZone;
use ReflectionException;
use Throwable;

class ContractController extends ResourceController
{
    protected $modelName = ContractModel::class;
    protected $format    = 'json';

    /** điều chỉnh theo business của bạn nếu khác */
    protected array $validStatuses = [1, 2, 3]; // 1=Đang thực hiện, 2=Hoàn tất, 3=Huỷ (ví dụ)

    /**
     * Danh sách hợp đồng: lọc + phân trang + summary (+with_progress)
     * @throws \Exception
     */
    public function index()
    {
        $filters = $this->request->getGet();

        // --- Phân trang an toàn
        $perPage = max(1, (int)($filters['per_page'] ?? 10));
        $page    = max(1, (int)($filters['page'] ?? 1));

        // --- Sort (mặc định: newest first)
        $sort = $filters['sort'] ?? 'created_at';
        $dir  = strtolower($filters['dir'] ?? 'desc');
        $allowedSorts = ['created_at','updated_at','start_date','end_date','status','priority','code','title','id'];
        if (!in_array($sort, $allowedSorts, true)) $sort = 'created_at';
        $dir = $dir === 'asc' ? 'ASC' : 'DESC';

        // --- Base query: join user + tính sẵn days bằng SQL
        // Lưu ý: DATEDIFF(a,b) = a - b (đơn vị ngày)
        // days_overdue   = IF(end_date < today, DATEDIFF(CURDATE(), end_date), 0)
        // days_remaining = IF(end_date >= today, DATEDIFF(end_date, CURDATE()), 0)
        $list = $this->model
            ->select("
            contracts.*,
            u1.name AS assigned_to_name,
            u2.name AS manager_name,
            COALESCE(contracts.customer_id, contracts.customer_id) AS customer_id,
            CASE
              WHEN contracts.end_date IS NULL THEN NULL
              WHEN DATE(contracts.end_date) < CURDATE() THEN DATEDIFF(CURDATE(), DATE(contracts.end_date))
              ELSE 0
            END AS days_overdue,
            CASE
              WHEN contracts.end_date IS NULL THEN NULL
              WHEN DATE(contracts.end_date) >= CURDATE() THEN DATEDIFF(DATE(contracts.end_date), CURDATE())
              ELSE 0
            END AS days_remaining
        ", false)
            ->join('users AS u1', 'u1.id = contracts.assigned_to', 'left')
            ->join('users AS u2', 'u2.id = contracts.manager_id', 'left');

        $this->applyFilters($list, $filters);
        $list->orderBy('contracts.' . $sort, $dir);

        // --- Lấy data + pager
        $data  = $list->paginate($perPage, 'default', $page);
        $pager = $this->model->pager;

        // --- with_progress=1 → batch progress + collaborators
        $withProgress = filter_var($filters['with_progress'] ?? '0', FILTER_VALIDATE_BOOLEAN);
        if ($withProgress && !empty($data)) {
            $ids = array_map(fn($r) => (int)$r['id'], $data);

            $progMap = $this->computeProgressForContracts($ids);      // [contract_id => progress...]
            $colMap  = $this->collaboratorsForContracts($ids);        // [contract_id => {ids,names,details,count}]

            foreach ($data as &$row) {
                $cid = (int)$row['id'];

                if (isset($progMap[$cid])) {
                    $p = $progMap[$cid];
                    $row['progress']         = $p;
                    $row['progress_percent'] = (int)($p['contract_progress'] ?? 0);
                    $row['steps_done']       = (int)($p['steps_completed'] ?? 0);
                    $row['steps_total']      = (int)($p['steps_total'] ?? 0);
                    $row['subtasks_done']    = (int)($p['subtasks_approved'] ?? 0);
                    $row['subtasks_total']   = (int)($p['subtasks_total'] ?? 0);
                } else {
                    $row['progress']         = [
                        'contract_progress' => 0,
                        'steps_total'       => 0,
                        'steps_completed'   => 0,
                        'subtasks_total'    => 0,
                        'subtasks_approved' => 0,
                        'per_steps'         => [],
                    ];
                    $row['progress_percent'] = 0;
                    $row['steps_done'] = $row['steps_total'] = 0;
                    $row['subtasks_done'] = $row['subtasks_total'] = 0;
                }

                if (isset($colMap[$cid])) {
                    $row['collaborators']        = $colMap[$cid]['ids'];
                    $row['collaborators_detail'] = $colMap[$cid]['details'];
                    $row['collaborators_count']  = $colMap[$cid]['count'];
                    $row['collaborators_names']  = $colMap[$cid]['names'];
                } else {
                    $row['collaborators'] = [];
                    $row['collaborators_detail'] = [];
                    $row['collaborators_count'] = 0;
                    $row['collaborators_names'] = '';
                }
            }
            unset($row);
        }

        // --- SUMMARY (không khoá theo status đang lọc)
        $filtersNoStatus = $filters;
        unset($filtersNoStatus['status']);

        // Đếm theo status
        $stBuilder = $this->model->builder();
        $this->applyFilters($stBuilder, $filtersNoStatus);
        $rows = $stBuilder
            ->select('contracts.status AS status, COUNT(*) AS cnt', false)
            ->groupBy('contracts.status')
            ->get()->getResultArray();

        $byStatus = [1=>0,2=>0,3=>0];
        foreach ($rows as $r) {
            $s = (int)($r['status'] ?? 0);
            if (isset($byStatus[$s])) $byStatus[$s] = (int)$r['cnt'];
        }

        // Priority bucket
        $impBuilder = $this->model->builder();
        $this->applyFilters($impBuilder, $filtersNoStatus);
        $important = (int)$impBuilder->where('contracts.priority', 1)->countAllResults();

        $norBuilder = $this->model->builder();
        $this->applyFilters($norBuilder, $filtersNoStatus);
        $normal    = (int)$norBuilder->where('contracts.priority', 0)->countAllResults();

        // Overdue: end_date < today
        $ovBuilder = $this->model->builder();
        $this->applyFilters($ovBuilder, $filtersNoStatus);
        $overdue = (int)$ovBuilder
            ->where('contracts.end_date IS NOT NULL', null, false)
            ->where('DATE(contracts.end_date) <', date('Y-m-d'))
            ->countAllResults();

        return $this->respond([
            'data'  => $data,
            'pager' => [
                'total'        => (int)$pager->getTotal(),
                'per_page'     => (int)$perPage,
                'current_page' => (int)$page,
            ],
            'summary' => [
                'status_1'  => $byStatus[1],
                'status_2'  => $byStatus[2],
                'status_3'  => $byStatus[3],
                'important' => $important,
                'normal'    => $normal,
                'overdue'   => $overdue,
                'total'     => (int)$pager->getTotal(),
            ],
        ]);
    }

    /** Tính progress hàng loạt, tránh N+1 */
    private function computeProgressForContracts(array $contractIds): array
    {
        if (empty($contractIds)) return [];

        $db = db_connect();

        // 1) Lấy step của các contract
        $stepRows = $db->table('contract_steps')
            ->select('id, contract_id, step_number')
            ->whereIn('contract_id', $contractIds)
            ->orderBy('step_number', 'asc')
            ->get()->getResultArray();

        if (!$stepRows) return [];

        $byContract = [];      // contract_id => [step_ids ordered]
        $allStepIds = [];
        foreach ($stepRows as $r) {
            $cid = (int)$r['contract_id'];
            $sid = (int)$r['id'];
            $byContract[$cid][] = $sid;
            $allStepIds[] = $sid;
        }

        // 2) Tổng hợp task theo step
        $taskAgg = $db->table('tasks')
            ->select("
            step_id,
            COUNT(*) AS total_tasks,
            SUM(CASE
                WHEN approval_status='approved'
                 AND ((progress+0) >= 100 OR status='done')
                THEN 1 ELSE 0 END
            ) AS approved_tasks
        ")
            ->where('linked_type', 'contract')
            ->whereIn('step_id', $allStepIds)
            ->groupBy('step_id')
            ->get()->getResultArray();

        $byStep = [];
        foreach ($taskAgg as $r) {
            $byStep[(int)$r['step_id']] = [
                'total'    => (int)$r['total_tasks'],
                'approved' => (int)$r['approved_tasks'],
            ];
        }

        // 3) Ghép theo contract
        $out = [];
        foreach ($byContract as $cid => $stepIds) {
            $perSteps = [];
            $stepsCompleted   = 0;
            $subtasksTotal    = 0;
            $subtasksApproved = 0;
            $sumPercent       = 0;

            foreach ($stepIds as $sid) {
                $agg = $byStep[$sid] ?? ['total'=>0, 'approved'=>0];
                $percent   = $agg['total'] > 0 ? (int) round($agg['approved'] * 100 / $agg['total']) : 0;
                $completed = ($agg['total'] > 0 && $agg['approved'] === $agg['total']) ? 1 : 0;

                $perSteps[] = [
                    'step_id'       => $sid,
                    'step_progress' => $percent,
                    'sub_total'     => $agg['total'],
                    'sub_done'      => $agg['approved'],
                    'completed'     => $completed,
                ];

                $stepsCompleted   += $completed;
                $subtasksTotal    += $agg['total'];
                $subtasksApproved += $agg['approved'];
                $sumPercent       += $percent;
            }

            $contractProgress = count($stepIds) > 0 ? (int) round($sumPercent / count($stepIds)) : 0;

            $out[$cid] = [
                'contract_progress' => $contractProgress,
                'steps_total'       => count($stepIds),
                'steps_completed'   => $stepsCompleted,
                'subtasks_total'    => $subtasksTotal,
                'subtasks_approved' => $subtasksApproved,
                'per_steps'         => $perSteps,
            ];
        }

        return $out;
    }

    private function collaboratorsForContracts(array $contractIds): array
    {
        if (empty($contractIds)) return [];

        $db = db_connect();
        $rows = $db->table('tasks t')
            ->select('t.linked_id AS contract_id, t.assigned_to, u.name')
            ->join('users u', 'u.id = t.assigned_to', 'left')
            ->where('t.linked_type', 'contract')
            ->whereIn('t.linked_id', $contractIds)
            ->where('t.assigned_to IS NOT NULL', null, false)
            ->get()->getResultArray();

        $map = []; // contract_id => { ids, names, details, count }
        foreach ($rows as $r) {
            $cid = (int)$r['contract_id'];
            $id  = (string)($r['assigned_to'] ?? '');
            if ($id === '') continue;

            if (!isset($map[$cid])) $map[$cid] = ['_byId'=>[]];

            $map[$cid]['_byId'][$id] = [
                'id'   => $id,
                'name' => $r['name'] ?? ('#'.$id),
            ];
        }

        foreach ($map as $cid => &$v) {
            $details = array_values($v['_byId']);
            $map[$cid] = [
                'ids'     => array_column($details, 'id'),
                'names'   => implode(', ', array_column($details, 'name')),
                'details' => $details,
                'count'   => count($details),
            ];
        }
        unset($v);

        return $map;
    }




    /** Áp các filter thống nhất (prefix 'contracts.' để tránh mơ hồ) */
    private function applyFilters($builder, array $filters): void
    {
        if (isset($filters['status']) && $filters['status'] !== '') {
            $builder->where('contracts.status', (int)$filters['status']);
        }
        if (!empty($filters['customer_id'])) {
            $builder->groupStart()
                ->where('contracts.customer_id', $filters['customer_id'])
                ->orWhere('contracts.customer_id', $filters['customer_id']) // fallback nếu schema cũ
                ->groupEnd();
        }
        if (!empty($filters['from'])) {
            $builder->where('contracts.start_date >=', $filters['from']);
        }
        if (!empty($filters['to'])) {
            $builder->where('contracts.end_date <=', $filters['to']);
        }
        if (isset($filters['priority']) && $filters['priority'] !== '') {
            $builder->where('contracts.priority', (int)$filters['priority']);
        }
        if (!empty($filters['department_id'])) {
            $builder->where('contracts.department_id', $filters['department_id']);
        }
        if (!empty($filters['search'])) {
            $builder->groupStart()
                ->like('contracts.title', $filters['search'])
                ->orLike('contracts.description', $filters['search'] ?? '')
                ->orLike('contracts.code', $filters['search'] ?? '')
                ->groupEnd();
        }
    }

    /** Tính tiến độ hợp đồng qua các step và task con */
    private function computeProgressForContract(int $contractId): array
    {
        $db = db_connect();

        // Lấy danh sách step thuộc hợp đồng
        $steps = $db->table('contract_steps')
            ->select('id')
            ->where('contract_id', $contractId)
            ->orderBy('step_number', 'asc') // Nếu bạn dùng 'step_no', đổi lại tại đây
            ->get()->getResultArray();

        if (!$steps) {
            return [
                'contract_progress' => 0,
                'steps_total'       => 0,
                'steps_completed'   => 0,
                'subtasks_total'    => 0,
                'subtasks_approved' => 0,
                'per_steps'         => [],
            ];
        }

        $stepIds = array_column($steps, 'id');

        // Tổng hợp task theo step
        $rows = $db->table('tasks')
            ->select("
                step_id,
                COUNT(*) AS total_tasks,
                SUM(CASE
                    WHEN approval_status='approved'
                     AND ((progress+0) >= 100 OR status='done')
                    THEN 1 ELSE 0 END
                ) AS approved_tasks
            ")
            ->where('linked_type', 'contract')
            ->whereIn('step_id', $stepIds)
            ->groupBy('step_id')
            ->get()->getResultArray();

        $byStep = [];
        foreach ($rows as $r) {
            $byStep[(string)$r['step_id']] = [
                'total'    => (int)$r['total_tasks'],
                'approved' => (int)$r['approved_tasks'],
            ];
        }

        $perSteps = [];
        $stepsCompleted   = 0;
        $subtasksTotal    = 0;
        $subtasksApproved = 0;
        $sumPercent       = 0;

        foreach ($stepIds as $sid) {
            $agg = $byStep[(string)$sid] ?? ['total'=>0, 'approved'=>0];

            $percent   = $agg['total'] > 0 ? (int) round($agg['approved'] * 100 / $agg['total']) : 0;
            $completed = ($agg['total'] > 0 && $agg['approved'] === $agg['total']) ? 1 : 0;

            $perSteps[] = [
                'step_id'       => (int)$sid,
                'step_progress' => $percent,
                'sub_total'     => $agg['total'],
                'sub_done'      => $agg['approved'],
                'completed'     => $completed,
            ];

            $stepsCompleted   += $completed;
            $subtasksTotal    += $agg['total'];
            $subtasksApproved += $agg['approved'];
            $sumPercent       += $percent;
        }

        $contractProgress = count($stepIds) > 0 ? (int) round($sumPercent / count($stepIds)) : 0;

        return [
            'contract_progress' => $contractProgress,
            'steps_total'       => count($stepIds),
            'steps_completed'   => $stepsCompleted,
            'subtasks_total'    => $subtasksTotal,
            'subtasks_approved' => $subtasksApproved,
            'per_steps'         => $perSteps,
        ];
    }

    /** Lấy cộng tác viên từ tasks của hợp đồng */
    private function collaboratorsForContract(int $contractId): array
    {
        $db = db_connect();

        $rows = $db->table('tasks t')
            ->select('t.assigned_to, u.name')
            ->join('users u', 'u.id = t.assigned_to', 'left')
            ->where('t.linked_type', 'contract')
            ->where('t.linked_id', $contractId)
            ->where('t.assigned_to IS NOT NULL', null, false)
            ->groupBy('t.assigned_to, u.name')
            ->get()->getResultArray();

        $byId = [];
        foreach ($rows as $r) {
            $id = (string)($r['assigned_to'] ?? '');
            if ($id === '') continue;
            $byId[$id] = ['id' => $id, 'name' => $r['name'] ?? ('#'.$id)];
        }

        $details = array_values($byId);
        return [
            'ids'     => array_column($details, 'id'),
            'names'   => implode(', ', array_column($details, 'name')),
            'details' => $details,
            'count'   => count($details),
        ];
    }

    /** Chi tiết hợp đồng + tính thêm days + progress + collaborators */
    public function show($id = null)
    {
        $contract = $this->model->find($id);
        if (!$contract) {
            return $this->failNotFound('Không tìm thấy hợp đồng');
        }

        // Phụ trợ đồng bộ key cho FE
        $contract['customer_id'] = $contract['customer_id'] ?? ($contract['customer_id'] ?? null);

        // days remaining/overdue
        $tz    = new DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new DateTimeImmutable('today', $tz);

        $dueVal = $contract['end_date'] ?? ($contract['due_date'] ?? null);
        $contract['days_remaining'] = null;
        $contract['days_overdue']   = null;

        if (!empty($dueVal)) {
            try {
                $end = new DateTimeImmutable($dueVal, $tz);
                $end = new DateTimeImmutable($end->format('Y-m-d'), $tz);
                $delta = (int)$today->diff($end)->format('%r%a');

                $contract['days_overdue']   = $delta < 0 ? -$delta : 0;
                $contract['days_remaining'] = max($delta, 0);
            } catch (Throwable $e) {
                $contract['days_remaining'] = null;
                $contract['days_overdue']   = null;
            }
        }

        // progress + collaborators
        $progress = $this->computeProgressForContract((int)$id);
        $contract['progress'] = $progress;

        $col = $this->collaboratorsForContract((int)$id);
        $contract['collaborators']        = $col['ids'];
        $contract['collaborators_detail'] = $col['details'];
        $contract['collaborators_count']  = $col['count'];
        $contract['collaborators_names']  = $col['names'];

        return $this->respond($contract);
    }

    /** Tạo mới hợp đồng + sinh step mặc định từ settings.contract_steps */
    public function create()
    {
        $data = $this->request->getJSON(true);

        if (empty($data['title']) && empty($data['name'])) {
            return $this->failValidationErrors(['title' => 'Vui lòng nhập tên hợp đồng']);
        }
        $data['title'] = $data['title'] ?? $data['name'];

        if (empty($data['status'])) {
            $data['status'] = 1; // mặc định
        }
        if (!in_array((int)$data['status'], $this->validStatuses, true)) {
            return $this->failValidationErrors(['status' => 'Trạng thái không hợp lệ']);
        }

        if (empty($data['code'])) {
            $data['code'] = $this->generateContractCode();
        }

        // nếu tạo từ bidding → auto gán customer_id
        if (!empty($data['bidding_id'])) {
            $bidding = (new BiddingModel())->find($data['bidding_id']);
            if (!$bidding) {
                return $this->failNotFound('Gói thầu không tồn tại');
            }
            // nếu business yêu cầu chỉ tạo HĐ khi trúng thầu thì kiểm tra ở đây
            $data['customer_id'] = $data['customer_id'] ?? ($bidding['customer_id'] ?? null);
            $data['title']       = $data['title'] ?? $bidding['title'];
        }

        $id = $this->model->insert($data);
        if (!$id) {
            return $this->failServerError('Không thể tạo hợp đồng');
        }

        // Sinh step mẫu từ setting
        $this->generateStepsFromTemplate((int)$id, ($data['customer_id'] ?? $data['customer_id'] ?? null));

        return $this->respondCreated([
            'status' => 'success',
            'id'     => $id,
            'code'   => $data['code'],
            'title'  => $data['title']
        ]);
    }

    private function generateContractCode(): string
    {
        $prefix = 'HD-' . date('Y');
        $last = $this->model
            ->like('code', $prefix, 'after')
            ->orderBy('id', 'DESC')
            ->first();

        $lastNumber = 0;
        if ($last && isset($last['code'])) {
            $parts = explode('-', $last['code']);
            $lastNumber = (int) end($parts);
        }

        $nextNumber = str_pad($lastNumber + 1, 4, '0', STR_PAD_LEFT);
        return "{$prefix}-{$nextNumber}";
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        if (!$id || !$this->model->find($id)) {
            return $this->failNotFound('Hợp đồng không tồn tại');
        }

        if (!empty($data['bidding_id'])) {
            $bidding = (new BiddingModel())->find($data['bidding_id']);
            if ($bidding && empty($data['customer_id'])) {
                $data['customer_id'] = $bidding['customer_id'];
            }
        }

        if (isset($data['status']) && !in_array((int)$data['status'], $this->validStatuses, true)) {
            return $this->failValidationErrors(['status' => 'Trạng thái không hợp lệ']);
        }

        if (!$this->model->update($id, $data)) {
            return $this->failServerError('Không thể cập nhật hợp đồng');
        }

        return $this->respondUpdated(['status' => 'success']);
    }

    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Không tìm thấy hợp đồng');
        }
        $this->model->delete($id);
        return $this->respondDeleted(['status' => 'success', 'message' => 'Đã xoá hợp đồng']);
    }

    /** Đếm số step của hợp đồng (giữ lại để FE dùng nhanh) */
    public function stepCount($id = null): ResponseInterface
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound("Không tìm thấy hợp đồng");
        }
        $stepModel = new ContractStepModel();
        $count = $stepModel->where('contract_id', $id)->countAllResults();
        return $this->respond(['contract_id' => (int)$id, 'step_count' => (int)$count]);
    }

    /** Trả danh sách step (giữ cấu trúc cũ, có thể nâng cấp thêm file/comment count sau) */
    public function stepDetails($id = null): ResponseInterface
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound("Không tìm thấy hợp đồng");
        }

        $stepModel = new ContractStepModel();
        $steps = $stepModel
            ->where('contract_id', $id)
            ->orderBy('step_number', 'ASC') // nếu dùng step_no đổi lại
            ->findAll();

        $userModel = new UserModel();
        $list = [];
        foreach ($steps as $s) {
            $u = !empty($s['assigned_to']) ? $userModel->find($s['assigned_to']) : null;
            $list[] = [
                'id'            => (int)$s['id'],
                'step_number'   => (int)($s['step_number'] ?? ($s['step_no'] ?? 0)),
                'title'         => $s['title'] ?? ($s['name'] ?? ''),
                'status'        => $s['status'],
                'assigned_to'   => $u['name'] ?? null,
                'file_count'    => 0,
                'comment_count' => 0,
            ];
        }
        return $this->respond($list);
    }

    /** Tạo từ template steps trong settings ('contract_steps') */
    protected function generateStepsFromTemplate(int $contractId, $customerId = null): void
    {
        $settingModel = new SettingModel();
        $stepModel    = new ContractStepModel();

        $setting = $settingModel->where('key', 'contract_steps')->first();
        if (!$setting) return;

        $value = json_decode($setting['value'], true);
        if (!isset($value['steps']) || !is_array($value['steps'])) return;

        foreach ($value['steps'] as $step) {
            $stepModel->insert([
                'contract_id'  => $contractId,
                'step_number'  => $step['step_number'] ?? ($step['step_no'] ?? null),
                'title'        => $step['title'] ?? ($step['name'] ?? ''),
                'department'   => $step['department'] ?? '',
                'status'       => 0,
                'customer_id'  => $customerId
            ]);
        }
    }

    /** Cho phép mark complete nếu không còn step chưa hoàn thành */
    public function canMarkAsComplete($contractId = null): ResponseInterface
    {
        if (!$contractId || !$this->model->find($contractId)) {
            return $this->failNotFound("Hợp đồng không tồn tại");
        }

        $stepModel = new ContractStepModel();
        $unfinished = $stepModel
            ->where('contract_id', $contractId)
            ->where('status !=', 2) // 2 = hoàn thành
            ->countAllResults();

        return $this->respond(['allow' => $unfinished === 0]);
    }
}
