<?php

namespace App\Controllers;

use App\Models\BiddingModel;
use App\Models\BiddingStepModel;
use App\Models\SettingModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use DateTime;
use DateTimeImmutable;
use DateTimeZone;
use Throwable;

class BiddingController extends ResourceController
{
    protected $modelName = BiddingModel::class;
    protected $format = 'json';

    protected array $validStatuses = [0, 1, 2, 3, 4, 5];

    /**
     * Lấy danh sách gói thầu có lọc + phân trang
     * @throws \Exception
     */
    public function index()
    {
        $filters = $this->request->getGet();

        // --- Phân trang an toàn
        $perPage = max(1, (int)($filters['per_page'] ?? 40));
        $page    = max(1, (int)($filters['page'] ?? 1));

        // === LIST (phân trang)
        $list = $this->model
            ->select('biddings.*, u1.name AS assigned_to_name, u2.name AS manager_name')
            ->join('users AS u1', 'u1.id = biddings.assigned_to', 'left')
            ->join('users AS u2', 'u2.id = biddings.manager_id', 'left');

        $this->applyFilters($list, $filters);
        $list->orderBy('biddings.created_at', 'DESC'); // mới nhất lên đầu

        $data  = $list->paginate($perPage, 'default', $page);
        $pager = $this->model->pager;

        // === days_overdue & days_remaining
        $tz    = new DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new DateTimeImmutable('today', $tz);

        $data = array_map(function ($row) use ($today, $tz) {
            $endDateVal = is_array($row) ? ($row['end_date'] ?? null) : ($row->end_date ?? null);
            if (empty($endDateVal)) {
                if (is_array($row)) { $row['days_overdue']=null; $row['days_remaining']=null; }
                else { $row->days_overdue=null; $row->days_remaining=null; }
                return $row;
            }
            try {
                $end = new DateTimeImmutable($endDateVal, $tz);
                $end = new DateTimeImmutable($end->format('Y-m-d'), $tz);
                $deltaDays     = (int)$today->diff($end)->format('%r%a'); // âm nếu đã quá hạn
                $daysOverdue   = $deltaDays < 0 ? -$deltaDays : 0;
                $daysRemaining = max($deltaDays, 0);

                if (is_array($row)) {
                    $row['days_overdue']   = $daysOverdue;
                    $row['days_remaining'] = $daysRemaining;
                } else {
                    $row->days_overdue   = $daysOverdue;
                    $row->days_remaining = $daysRemaining;
                }
            } catch (Throwable) {
                if (is_array($row)) { $row['days_overdue']=null; $row['days_remaining']=null; }
                else { $row->days_overdue=null; $row->days_remaining=null; }
            }
            return $row;
        }, $data);

        // === SUMMARY (không phân trang)
        $tz       = new DateTimeZone('Asia/Ho_Chi_Minh');
        $todayStr = (new DateTimeImmutable('today', $tz))->format('Y-m-d');

        // Khi tính summary, đừng khóa theo status người dùng đang lọc (nếu có)
        $filtersNoStatus = $filters;
        unset($filtersNoStatus['status']);

        // Đếm theo status (1,2,3)
        $stBuilder = $this->model->builder();
        $this->applyFilters($stBuilder, $filtersNoStatus);
        $rows = $stBuilder
            ->select('biddings.status AS status, COUNT(*) AS cnt', false)
            ->groupBy('biddings.status')
            ->get()->getResultArray();

        $byStatus = [1=>0,2=>0,3=>0];
        foreach ($rows as $r) {
            $s = (int)($r['status'] ?? 0);
            if (isset($byStatus[$s])) $byStatus[$s] = (int)$r['cnt'];
        }

        // Đếm priority trong trạng thái ĐANG CHUẨN BỊ
        $impBuilder = $this->model->builder();
        $this->applyFilters($impBuilder, $filtersNoStatus);
        $important = (int)$impBuilder->where('biddings.priority', 1)->countAllResults();

        $norBuilder = $this->model->builder();
        $this->applyFilters($norBuilder, $filtersNoStatus);
        $normal    = (int)$norBuilder->where('biddings.priority', 0)->countAllResults();

        // Quá hạn động: ĐANG CHUẨN BỊ & end_date < hôm nay
        $ovBuilder = $this->model->builder();
        $this->applyFilters($ovBuilder, $filtersNoStatus);     // vẫn áp các filter khác (khách hàng, ngày…)
        $overdue = (int)$ovBuilder
            ->where('biddings.end_date IS NOT NULL', null, false)
            ->where('DATE(biddings.end_date) <', $todayStr)    // ✅ tính quá hạn cho tất cả trạng thái
            ->countAllResults();

        // Trả về
        return $this->respond([
            'data'  => $data,
            'pager' => [
                'total'        => (int)$pager->getTotal(),
                'per_page'     => (int)$perPage,
                'current_page' => (int)$page,
            ],
            'summary' => [
                'won'       => $byStatus[2],      // Trúng thầu
                'lost'      => $byStatus[3],      // Hủy thầu
                'important' => $important,        // Đang chuẩn bị + priority=1
                'normal'    => $normal,           // Đang chuẩn bị + priority=0
                'overdue'   => $overdue,          // Đang chuẩn bị + quá hạn
                'total'     => (int)$pager->getTotal(),
            ],
        ]);
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
        if (!empty($filters['search'])) {
            $builder->groupStart()
                ->like('biddings.title', $filters['search'])
                ->orLike('biddings.description', $filters['search'])
                ->groupEnd();
        }
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
        $daysOverdue   = null;

        if (!empty($bidding['end_date'])) {
            try {
                $end = new DateTime(date('Y-m-d', strtotime($bidding['end_date'])));
                if ($today <= $end) {
                    $daysRemaining = (int)$today->diff($end)->days; // 0 nếu đến hạn hôm nay
                    $daysOverdue   = 0;
                } else {
                    $daysOverdue   = (int)$end->diff($today)->days;
                    $daysRemaining = 0;
                }
            } catch (Throwable $e) {
                $daysRemaining = null;
                $daysOverdue   = null;
            }
        }

        $bidding['days_remaining'] = $daysRemaining;
        $bidding['days_overdue']   = $daysOverdue;

        return $this->respond($bidding);
    }


    /**
     * Tạo mới gói thầu và sinh bước mặc định từ setting
     * @throws \ReflectionException
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
     * @throws \ReflectionException
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
                'bidding_id'   => $biddingId,
                'step_number'  => $step['step_number'],
                'title'        => $step['title'],
                'department'   => $step['department'] ?? '',
                'status'       => 0,
                'customer_id'  => $customerId
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

        return $this->respond([
            'allow' => $unfinished === 0
        ]);
    }


}
