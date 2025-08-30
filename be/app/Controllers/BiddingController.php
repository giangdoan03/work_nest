<?php

namespace App\Controllers;

use App\Models\BiddingModel;
use App\Models\BiddingStepModel;
use App\Models\SettingModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\Session\Session;
use DateTime;
use DateTimeImmutable;
use DateTimeZone;
use Exception;
use ReflectionException;
use Throwable;

class BiddingController extends ResourceController
{
    protected $modelName = BiddingModel::class;
    protected $format = 'json';

    protected array $validStatuses = [1, 2, 3, 4]; // 4 = SENT_FOR_APPROVAL

    private const STATUS_PREPARING = 1;
    private const STATUS_WON = 2;
    private const STATUS_CANCELLED = 3;
    private const STATUS_SENT = 4;

    private const AP_PENDING = 'pending';
    private const AP_APPROVED = 'approved';
    private const AP_REJECTED = 'rejected';

    /**
     * Lấy danh sách gói thầu có lọc + phân trang
     * @throws Exception
     */
    public function index()
    {
        $filters = $this->request->getGet();
        $perPage = max(1, (int)($filters['per_page'] ?? 40));
        $page    = max(1, (int)($filters['page'] ?? 1));

        // 🔹 Subquery: đếm số bước theo bidding_id
        $db  = db_connect();
        $sub = $db->table('bidding_steps')
            ->select('bidding_id, COUNT(*) AS steps_total')
            ->groupBy('bidding_id');

        // --- Base query + JOIN subquery steps ---
        $list = $this->model
            ->select(
            // COALESCE để null -> 0
                'biddings.*, u1.name AS assigned_to_name, u2.name AS manager_name, COALESCE(bs.steps_total, 0) AS steps_total',
                false
            )
            ->join('users AS u1', 'u1.id = biddings.assigned_to', 'left')
            ->join('users AS u2', 'u2.id = biddings.manager_id', 'left')
            ->join('(' . $sub->getCompiledSelect() . ') AS bs', 'bs.bidding_id = biddings.id', 'left');

        $this->applyFilters($list, $filters);
        $list->orderBy('biddings.created_at', 'DESC');

        $data  = $list->paginate($perPage, 'default', $page);
        $pager = $this->model->pager;

        // === Deadline fields
        $tz    = new DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new DateTimeImmutable('today', $tz);
        $data  = $this->attachDeadlineInfo($data, $today, $tz);

        // === Progress fields (tuỳ chọn)
        if (filter_var($filters['with_progress'] ?? '0', FILTER_VALIDATE_BOOLEAN)) {
            // Lưu ý: attachProgressInfo sẽ KHÔNG overwrite steps_total nếu đã có từ JOIN
            $data = $this->attachProgressInfo($data);
        }

        // === Summary
        $summary = $this->buildSummary($filters);

        return $this->respond([
            'data'  => $data,
            'pager' => [
                'total'        => (int) $pager->getTotal(),
                'per_page'     => (int) $perPage,
                'current_page' => (int) $page,
            ],
            'summary' => $summary,
        ]);
    }


    // ===== Helpers =====
    private function attachDeadlineInfo(array $rows, DateTimeImmutable $today, DateTimeZone $tz): array
    {
        return array_map(function ($row) use ($today, $tz) {
            $endDateVal = is_array($row) ? ($row['end_date'] ?? null) : ($row->end_date ?? null);
            $daysRemaining = $daysOverdue = null;
            if (!empty($endDateVal)) {
                try {
                    $end = new DateTimeImmutable((new DateTimeImmutable($endDateVal, $tz))->format('Y-m-d'), $tz);
                    $delta = (int)$today->diff($end)->format('%r%a');
                    $daysRemaining = max($delta, 0);
                    $daysOverdue = $delta < 0 ? -$delta : 0;
                } catch (Throwable) {
                }
            }
            if (is_array($row)) {
                $row['days_overdue'] = $daysOverdue;
                $row['days_remaining'] = $daysRemaining;
            } else {
                $row->days_overdue = $daysOverdue;
                $row->days_remaining = $daysRemaining;
            }
            return $row;
        }, $rows);
    }

    private function attachProgressInfo(array $rows): array
    {
        foreach ($rows as &$row) {
            $bidId = (int)(is_array($row) ? $row['id'] : $row->id);
            $prog = $this->computeProgressForBidding($bidId);
            $col = $this->collaboratorsForBidding($bidId);

            $target = is_array($row) ? $row : (array)$row;
            $target['progress'] = $prog;
            $target['progress_percent'] = (int)($prog['bidding_progress'] ?? 0);
            $target['steps_done'] = (int)($prog['steps_completed'] ?? 0);
            $target['steps_total'] = (int)($prog['steps_total'] ?? 0);
            $target['subtasks_done'] = (int)($prog['subtasks_approved'] ?? 0);
            $target['subtasks_total'] = (int)($prog['subtasks_total'] ?? 0);
            $target['collaborators'] = $col['ids'];
            $target['collaborators_detail'] = $col['details'];
            $target['collaborators_count'] = $col['count'];
            $target['collaborators_names'] = $col['names'];

            $row = $target;
        }
        return $rows;
    }

    /**
     * @throws Exception
     */
    private function buildSummary(array $filters): array
    {
        $filtersNoStatus = $filters;
        unset($filtersNoStatus['status']);

        $tz = new DateTimeZone('Asia/Ho_Chi_Minh');
        $todayStr = (new DateTimeImmutable('today', $tz))->format('Y-m-d');

        // Đếm theo status
        $stBuilder = $this->model->builder();
        $this->applyFilters($stBuilder, $filtersNoStatus);
        $rows = $stBuilder
            ->select('biddings.status, COUNT(*) AS cnt')
            ->groupBy('biddings.status')
            ->get()->getResultArray();
        $byStatus = [1 => 0, 2 => 0, 3 => 0];
        foreach ($rows as $r) {
            $s = (int)($r['status'] ?? 0);
            if (isset($byStatus[$s])) $byStatus[$s] = (int)$r['cnt'];
        }

        // Đếm priority
        $prioBuilder = $this->model->builder();
        $this->applyFilters($prioBuilder, $filtersNoStatus);
        $prioCounts = $prioBuilder
            ->select('biddings.priority, COUNT(*) AS cnt')
            ->groupBy('biddings.priority')
            ->get()->getResultArray();
        $important = $normal = 0;
        foreach ($prioCounts as $r) {
            if ((int)$r['priority'] === 1) $important = (int)$r['cnt'];
            if ((int)$r['priority'] === 0) $normal = (int)$r['cnt'];
        }

        // Đếm quá hạn
        $ovBuilder = $this->model->builder();
        $this->applyFilters($ovBuilder, $filtersNoStatus);
        $overdue = (int)$ovBuilder
            ->where('biddings.end_date IS NOT NULL', null, false)
            ->where('DATE(biddings.end_date) <', $todayStr)
            ->countAllResults();

        return [
            'won' => $byStatus[2],
            'lost' => $byStatus[3],
            'important' => $important,
            'normal' => $normal,
            'overdue' => $overdue,
            'total' => $this->model->pager->getTotal(),
        ];
    }


    /**
     * Áp bộ lọc chung cho mọi truy vấn (list/summary).
     * LƯU Ý: dùng prefix 'biddings.' để tránh mơ hồ cột khi join.
     */
    private function applyFilters($builder, array $filters): void
    {
        // status có thể là "0" hợp lệ → dùng isset + !== ''
        if (isset($filters['status']) && $filters['status'] !== '') {
            $builder->where('biddings.status', (int)$filters['status']);
        }
        if (!empty($filters['customer_id'])) {
            $builder->where('biddings.customer_id', $filters['customer_id']);
        }
        if (!empty($filters['from'])) {
            $builder->where('biddings.start_date >=', $filters['from']);
        }
        if (!empty($filters['to'])) {
            $builder->where('biddings.end_date <=', $filters['to']);
        }
        if (isset($filters['priority']) && $filters['priority'] !== '') {
            $builder->where('biddings.priority', (int)$filters['priority']);
        }
        if (!empty($filters['approval_status'])) {
            $builder->where('biddings.approval_status', $filters['approval_status']); // pending/approved/rejected
        }
        if (!empty($filters['search'])) {
            $builder->groupStart()
                ->like('biddings.title', $filters['search'])
                ->orLike('biddings.description', $filters['search'])
                ->groupEnd();
        }
    }

    // BiddingController
    private function computeProgressForBidding(int $biddingId): array
    {
        $db = db_connect();

        // Lấy các step thuộc gói này (KHÔNG select weight)
        $steps = $db->table('bidding_steps')
            ->select('id')
            ->where('bidding_id', $biddingId)
            ->orderBy('step_number', 'asc')
            ->get()->getResultArray();

        if (!$steps) {
            return [
                'bidding_progress' => 0,
                'steps_total' => 0,
                'steps_completed' => 0,
                'subtasks_total' => 0,
                'subtasks_approved' => 0,
                'per_steps' => [],
            ];
        }

        $stepIds = array_column($steps, 'id');

        // Gộp task theo step: tổng & số đã DUYỆT + hoàn tất (progress>=100 hoặc status='done')
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
            ->where('linked_type', 'bidding')
            ->whereIn('step_id', $stepIds)
            ->groupBy('step_id')
            ->get()->getResultArray();

        $byStep = [];
        foreach ($rows as $r) {
            $byStep[(string)$r['step_id']] = [
                'total' => (int)$r['total_tasks'],
                'approved' => (int)$r['approved_tasks'],
            ];
        }

        $perSteps = [];
        $stepsCompleted = 0;
        $subtasksTotal = 0;
        $subtasksApproved = 0;
        $sumPercent = 0;

        foreach ($stepIds as $sid) {
            $sidStr = (string)$sid;
            $agg = $byStep[$sidStr] ?? ['total' => 0, 'approved' => 0];

            $percent = $agg['total'] > 0 ? (int)round($agg['approved'] * 100 / $agg['total']) : 0;
            $completed = ($agg['total'] > 0 && $agg['approved'] === $agg['total']) ? 1 : 0;

            $perSteps[] = [
                'step_id' => (int)$sid,
                'step_progress' => $percent,
                'sub_total' => $agg['total'],
                'sub_done' => $agg['approved'],
                'completed' => $completed,
            ];

            $stepsCompleted += $completed;
            $subtasksTotal += $agg['total'];
            $subtasksApproved += $agg['approved'];
            $sumPercent += $percent;
        }

        $biddingProgress = count($stepIds) > 0 ? (int)round($sumPercent / count($stepIds)) : 0;

        return [
            'bidding_progress' => $biddingProgress,   // %
            'steps_total' => count($stepIds),
            'steps_completed' => $stepsCompleted,
            'subtasks_total' => $subtasksTotal,
            'subtasks_approved' => $subtasksApproved,
            'per_steps' => $perSteps,
        ];
    }


    // BiddingController
    private function collaboratorsForBidding(int $biddingId): array
    {
        $db = db_connect();

        $rows = $db->table('tasks t')
            ->select('t.assigned_to, u.name')
            ->join('users u', 'u.id = t.assigned_to', 'left')
            ->where('t.linked_type', 'bidding')
            ->where('t.linked_id', $biddingId)
            ->where('t.assigned_to IS NOT NULL', null, false)
            ->groupBy('t.assigned_to, u.name')
            ->get()->getResultArray();

        // unique theo user
        $byId = [];
        foreach ($rows as $r) {
            $id = (string)($r['assigned_to'] ?? '');
            if ($id === '') continue;
            $byId[$id] = ['id' => $id, 'name' => $r['name'] ?? ('#' . $id)];
        }

        $details = array_values($byId);
        return [
            'ids' => array_column($details, 'id'),
            'names' => implode(', ', array_column($details, 'name')),
            'details' => $details,
            'count' => count($details),
        ];
    }


    /**
     * Lấy chi tiết 1 gói thầu
     */
    public function show($id = null)
    {
        $bidding = $this->model->find($id);

        if (!$bidding) {
            return $this->failNotFound("Không tìm thấy gói thầu.");
        }

        // Tính days_remaining & days_overdue từ end_date
        $today = new DateTime('today');
        $daysRemaining = null;
        $daysOverdue = null;

        if (!empty($bidding['end_date'])) {
            try {
                $end = new DateTime(date('Y-m-d', strtotime($bidding['end_date'])));
                if ($today <= $end) {
                    $daysRemaining = (int)$today->diff($end)->days; // 0 nếu đến hạn hôm nay
                    $daysOverdue = 0;
                } else {
                    $daysOverdue = (int)$end->diff($today)->days;
                    $daysRemaining = 0;
                }
            } catch (Throwable $e) {
                $daysRemaining = null;
                $daysOverdue = null;
            }
        }

        $bidding['days_remaining'] = $daysRemaining;
        $bidding['days_overdue'] = $daysOverdue;

        $progress = $this->computeProgressForBidding((int)$id);
        $bidding['progress'] = $progress;

        $col = $this->collaboratorsForBidding((int)$id);
        $bidding['collaborators'] = $col['ids'];
        $bidding['collaborators_detail'] = $col['details'];
        $bidding['collaborators_count'] = $col['count'];
        $bidding['collaborators_names'] = $col['names'];

        return $this->respond($bidding);
    }


    /**
     * Tạo mới gói thầu và sinh bước mặc định từ setting
     * @throws ReflectionException
     */
    public function create()
    {
        $data = $this->request->getJSON(true);

        // Validate bắt buộc
        $requiredFields = ['title', 'customer_id', 'status'];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                return $this->failValidationErrors(["{$field}" => "Trường {$field} là bắt buộc."]);
            }
        }

        if (!in_array($data['status'], $this->validStatuses)) {
            return $this->failValidationErrors(['status' => 'Trạng thái không hợp lệ']);
        }

        if (!$this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }

        $data['id'] = $this->model->getInsertID();

        // ✅ Tự động tạo bước mẫu nếu có setting "bidding_steps"
        $this->generateStepsFromTemplate($data['id'], $data['customer_id']);

        return $this->respondCreated($data);
    }

    /**
     * Cập nhật gói thầu
     */
    public function update($id = null)
    {
        $data = $this->request->getJSON(true);

        // Nếu client muốn set WON → bắt buộc approval_status = approved
        if (isset($data['status']) && (int)$data['status'] === self::STATUS_WON) {
            $bid = $this->model->find($id);
            if (!$bid) return $this->failNotFound('Gói thầu không tồn tại.');

            // 1) Kiểm tra phê duyệt
            if (($bid['approval_status'] ?? '') !== self::AP_APPROVED) {
                return $this->failValidationErrors(['approval' => 'Chưa hoàn tất 2 cấp phê duyệt.']);
            }

            // 2) (Giữ điều kiện cũ) kiểm tra các bước/ task đã hoàn thành
            $can = $this->canMarkAsComplete($id);
            $payload = json_decode($can->getBody(), true);
            if (empty($payload['allow'])) {
                return $this->failValidationErrors(['steps' => 'Cần hoàn tất tất cả bước trước khi chuyển "Trúng thầu".']);
            }
        }

        if (!$this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }
        return $this->respond(['message' => 'Cập nhật thành công']);
    }

    /**
     * Xoá gói thầu
     */
    public function delete($id = null)
    {
        if (!$this->model->delete($id)) {
            return $this->failNotFound("Không tìm thấy gói thầu để xoá.");
        }
        return $this->respondDeleted(['message' => 'Đã xoá gói thầu.']);
    }

    /**
     * Tạo các bước mẫu từ setting `bidding_steps`
     * @throws ReflectionException
     */
    protected function generateStepsFromTemplate($biddingId, $customerId): void
    {
        $settingModel = new SettingModel();
        $stepModel = new BiddingStepModel();

        $setting = $settingModel->where('key', 'bidding_steps')->first();
        if (!$setting) return;

        $value = json_decode($setting['value'], true);
        if (!isset($value['steps']) || !is_array($value['steps'])) return;

        foreach ($value['steps'] as $step) {
            $stepModel->insert([
                'bidding_id' => $biddingId,
                'step_number' => $step['step_number'],
                'title' => $step['title'],
                'department' => $step['department'] ?? '',
                'status' => 0,
                'customer_id' => $customerId
            ]);
        }
    }

    public function canMarkAsComplete($biddingId = null): ResponseInterface
    {
        if (!$biddingId || !$this->model->find($biddingId)) {
            return $this->failNotFound("Gói thầu không tồn tại");
        }

        $stepModel = new BiddingStepModel();
        $unfinished = $stepModel
            ->where('bidding_id', $biddingId)
            ->where('status !=', 2) // 2 = Hoàn thành
            ->countAllResults();

        $bid = $this->model->find($biddingId);
        $apOK = (($bid['approval_status'] ?? '') === self::AP_APPROVED);

        return $this->respond([
            'allow' => $unfinished === 0 && $apOK,
            'unfinished_steps' => $unfinished,
            'approval_ok' => $apOK
        ]);
    }


    private function buildApprovalSteps(array $approverIds): array
    {
        // Mỗi phần tử: level (1-based), approver_id, status=pending, commented_at=null
        $steps = [];
        foreach ($approverIds as $i => $uid) {
            $steps[] = [
                'level' => $i + 1,
                'approver_id' => (int)$uid,
                'status' => self::AP_PENDING,
                'commented_at' => null,
                'note' => null,
            ];
        }
        return $steps;
    }

    private function allStepsApproved(array $steps): bool
    {
        foreach ($steps as $s) {
            if (($s['status'] ?? '') !== self::AP_APPROVED) return false;
        }
        return true;
    }

    private function stepApprove(array $steps, int $currentLevel, ?string $note = null): array
    {
        // currentLevel là 0-based trong DB
        if (!isset($steps[$currentLevel])) return $steps;
        $steps[$currentLevel]['status'] = self::AP_APPROVED;
        $steps[$currentLevel]['commented_at'] = date('Y-m-d H:i:s');
        if ($note !== null) $steps[$currentLevel]['note'] = $note;
        return $steps;
    }

    private function stepReject(array $steps, int $currentLevel, ?string $note = null): array
    {
        if (!isset($steps[$currentLevel])) return $steps;
        $steps[$currentLevel]['status'] = self::AP_REJECTED;
        $steps[$currentLevel]['commented_at'] = date('Y-m-d H:i:s');
        if ($note !== null) $steps[$currentLevel]['note'] = $note;
        return $steps;
    }


    public function sendForApproval($id = null): ResponseInterface
    {
        $bidding = $this->model->find($id);
        if (!$bidding) {
            return $this->failNotFound('Gói thầu không tồn tại.');
        }

        // Nhận payload (JSON hoặc form)
        $payload = $this->request->getJSON(true) ?? $this->request->getPost();
        $ids = array_values(array_unique(array_map('intval', (array)($payload['approver_ids'] ?? []))));
        // ≥ 1 cấp duyệt
        if (count($ids) < 1) {
            return $this->failValidationErrors(['approver_ids' => 'Cần tối thiểu 1 cấp duyệt.']);
        }

        // Chặn nếu đã duyệt xong
        $apStatus = (string)($bidding['approval_status'] ?? '');
        if ($apStatus === self::AP_APPROVED) {
            return $this->failValidationErrors(['approval_status' => 'Gói thầu đã duyệt xong, không thể gửi lại.']);
        }

        // Chặn nếu WON/CANCELLED
        $status = (int)($bidding['status'] ?? 0);
        if (in_array($status, [self::STATUS_WON, self::STATUS_CANCELLED], true)) {
            return $this->failValidationErrors(['status' => 'Trạng thái hiện tại không cho phép gửi phê duyệt.']);
        }

        // Build lại bước duyệt theo danh sách mới
        $steps = $this->buildApprovalSteps($ids);

        $update = [
            'approval_steps' => json_encode($steps, JSON_UNESCAPED_UNICODE),
            'current_level' => 0,                    // reset về cấp 1 (0-based)
            'approval_status' => self::AP_PENDING,     // reset trạng thái phê duyệt
            'status' => self::STATUS_SENT,    // 4 = Gửi phê duyệt
        ];

        if (!$this->model->update($id, $update)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond([
            'message' => 'Đã gửi phê duyệt' . ($apStatus === self::AP_REJECTED ? ' lại' : '') . '.',
            'approval_status' => $update['approval_status'],
            'current_level' => $update['current_level'],
            'approval_steps' => $steps,
            'status' => $update['status'],
        ]);
    }


    private function isAdminUser(int $userId, ?Session $session = null): bool
    {
        $session ??= session();

        // 1) Ưu tiên theo session
        $roleSession = strtolower((string)($session->get('role') ?? ''));
        $rolesSession = array_map('strtolower', (array)($session->get('roles') ?? []));
        if ((bool)($session->get('is_admin') ?? false)
            || in_array($roleSession, ['admin', 'super admin'], true)
            || in_array('admin', $rolesSession, true)
            || in_array('super admin', $rolesSession, true)
        ) {
            return true;
        }

        // 2) Fallback đọc từ DB: chỉ SELECT các cột thực sự tồn tại
        if ($userId > 0) {
            $db = db_connect();
            $user = $db->table('users')
                ->select('role_id, role')      // ❌ bỏ role_name
                ->where('id', $userId)
                ->get()->getRowArray();

            if ($user) {
                $rid = (int)($user['role_id'] ?? 0);
                $r = strtolower((string)($user['role'] ?? ''));

                if ($rid === 1 || in_array($r, ['admin', 'super admin'], true)) {
                    return true;
                }

                // (Tuỳ chọn) nếu có bảng roles thì JOIN để lấy tên quyền
                // $roleName = $db->table('roles')->select('name')->where('id', $rid)->get()->getRow('name');
                // if ($roleName && in_array(strtolower($roleName), ['admin','super admin'], true)) return true;
            }
        }

        return false;
    }


    public function approve($id = null): ResponseInterface
    {
        $bidding = $this->model->find($id);
        if (!$bidding) return $this->failNotFound('Gói thầu không tồn tại.');

        if (($bidding['approval_status'] ?? '') !== self::AP_PENDING) {
            return $this->failValidationErrors(['approval_status' => 'Không ở trạng thái chờ duyệt.']);
        }

        $steps = json_decode($bidding['approval_steps'] ?? '[]', true) ?: [];
        $curr = (int)($bidding['current_level'] ?? 0);

        $session = session();
        $userId = (int)($session->get('user_id') ?? 0);
        $isAdmin = $this->isAdminUser($userId, $session);

        // chỉ chặn nếu KHÔNG phải admin
        if (
            !$isAdmin
            && isset($steps[$curr]['approver_id'])
            && $userId > 0
            && (int)$steps[$curr]['approver_id'] !== $userId
        ) {
            return $this->failForbidden('Bạn không phải người duyệt ở cấp hiện tại.');
        }

        $note = $this->request->getPost('note') ?? ($this->request->getJSON(true)['note'] ?? null);
        if (!isset($steps[$curr])) {
            return $this->failValidationErrors(['steps' => 'Thiếu cấu hình cấp duyệt hiện tại.']);
        }

        // đánh dấu duyệt + audit
        $steps[$curr]['status'] = self::AP_APPROVED;
        $steps[$curr]['commented_at'] = date('Y-m-d H:i:s');
        if ($note !== null) $steps[$curr]['note'] = $note;
        $steps[$curr]['acted_by'] = $userId;
        $steps[$curr]['acted_role'] = $isAdmin ? 'admin' : 'approver';

        $nextLevel = $curr + 1;

        // kiểm tra xong hết chưa
        $final = true;
        foreach ($steps as $s) {
            if (($s['status'] ?? '') !== self::AP_APPROVED) {
                $final = false;
                break;
            }
        }

        $update = [
            'approval_steps' => json_encode($steps, JSON_UNESCAPED_UNICODE),
            'current_level' => $final ? $curr : $nextLevel,
            'approval_status' => $final ? self::AP_APPROVED : self::AP_PENDING,
        ];

        $this->model->update($id, $update);

        return $this->respond([
            'message' => $final ? 'Đã phê duyệt hoàn tất.' : 'Đã phê duyệt cấp hiện tại.',
            'approval_status' => $update['approval_status'],
            'current_level' => $update['current_level'],
            'approval_steps' => $steps
        ]);
    }


    public function reject($id = null): ResponseInterface
    {
        $bidding = $this->model->find($id);
        if (!$bidding) return $this->failNotFound('Gói thầu không tồn tại.');

        if (($bidding['approval_status'] ?? '') !== self::AP_PENDING) {
            return $this->failValidationErrors(['approval_status' => 'Không ở trạng thái chờ duyệt.']);
        }

        $steps = json_decode($bidding['approval_steps'] ?? '[]', true) ?: [];
        $curr = (int)($bidding['current_level'] ?? 0);

        $session = session();
        $userId = (int)($session->get('user_id') ?? 0);
        $isAdmin = $this->isAdminUser($userId, $session);

        if (
            !$isAdmin
            && isset($steps[$curr]['approver_id'])
            && $userId > 0
            && (int)$steps[$curr]['approver_id'] !== $userId
        ) {
            return $this->failForbidden('Bạn không phải người duyệt ở cấp hiện tại.');
        }

        $note = $this->request->getPost('note') ?? ($this->request->getJSON(true)['note'] ?? null);
        if (!isset($steps[$curr])) {
            return $this->failValidationErrors(['steps' => 'Thiếu cấu hình cấp duyệt hiện tại.']);
        }

        $steps[$curr]['status'] = self::AP_REJECTED;
        $steps[$curr]['commented_at'] = date('Y-m-d H:i:s');
        if ($note !== null) $steps[$curr]['note'] = $note;
        $steps[$curr]['acted_by'] = $userId;
        $steps[$curr]['acted_role'] = $isAdmin ? 'admin' : 'approver';

        $update = [
            'approval_steps' => json_encode($steps, JSON_UNESCAPED_UNICODE),
            'approval_status' => self::AP_REJECTED,
        ];

        $this->model->update($id, $update);

        return $this->respond([
            'message' => 'Đã từ chối phê duyệt.',
            'approval_status' => self::AP_REJECTED,
            'current_level' => $curr,
            'approval_steps' => $steps
        ]);
    }


    public function updateApprovalSteps($id): ResponseInterface
    {
        $id = (int)$id;
        $bidding = $this->model->find($id);
        if (!$bidding) return $this->failNotFound('Gói thầu không tồn tại.');

        $body = $this->request->getJSON(true) ?? [];
        $ids = [];

        // chấp nhận nhiều dạng payload
        if (isset($body['approver_ids']) && is_array($body['approver_ids'])) {
            $ids = $body['approver_ids'];
        } elseif (isset($body['steps']) && is_array($body['steps'])) {
            $ids = $body['steps'];
        } elseif (array_is_list($body)) { // gửi thẳng [1,2,3]
            $ids = $body;
        }

        // chuẩn hoá + bỏ trùng
        $ids = array_values(array_unique(array_filter(array_map('intval', $ids))));
        if (count($ids) < 2) {
            return $this->failValidationErrors(['approver_ids' => 'Cần tối thiểu 1 cấp duyệt.']);
        }

        if (($bidding['approval_status'] ?? '') === self::AP_APPROVED) {
            return $this->failValidationErrors(['approval_status' => 'Đã duyệt xong, không thể thay đổi.']);
        }

        $steps = $this->buildApprovalSteps($ids);

        $update = [
            'approval_steps' => json_encode($steps, JSON_UNESCAPED_UNICODE),
            'approval_status' => self::AP_PENDING,
            'current_level' => 0,
        ];

        // nếu chưa WON/CANCELLED thì về trạng thái "Gửi phê duyệt"
        $status = (int)($bidding['status'] ?? 0);
        if (!in_array($status, [self::STATUS_WON, self::STATUS_CANCELLED], true)) {
            $update['status'] = self::STATUS_SENT;
        }

        if (!$this->model->update($id, $update)) {
            return $this->failValidationErrors($this->model->errors());
        }

        return $this->respond([
            'message' => 'Cập nhật người duyệt thành công',
            'approval_steps' => $steps,
            'approval_status' => self::AP_PENDING,
            'current_level' => 0,
        ]);
    }

    private function canOverrideApproval(array $bid, int $userId): bool
    {
        $session = session();
        $isAdmin = (bool)($session->get('is_admin') ?? false); // tuỳ bạn lưu flag gì
        if ($isAdmin) return true;
        return (int)($bid['manager_id'] ?? 0) === $userId; // cho manager gói thầu override
    }


}
