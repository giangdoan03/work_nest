<?php

namespace App\Controllers;

use App\Models\BiddingModel;
use App\Models\BiddingStepModel;
use App\Models\SettingModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class BiddingController extends ResourceController
{
    protected $modelName = BiddingModel::class;
    protected $format = 'json';

    protected array $validStatuses = [0, 1, 2, 3, 4, 5];

    /**
     * Lấy danh sách gói thầu có lọc + phân trang
     */
    public function index()
    {
        $filters = $this->request->getGet();
        $builder = $this->model;

        if (isset($filters['status']) && $filters['status'] !== '') {
            $builder = $builder->where('status', (int) $filters['status']);
        }

        if (!empty($filters['customer_id'])) {
            $builder = $builder->where('customer_id', $filters['customer_id']);
        }

        if (!empty($filters['from'])) {
            $builder = $builder->where('start_date >=', $filters['from']);
        }

        if (!empty($filters['to'])) {
            $builder = $builder->where('end_date <=', $filters['to']);
        }

        if (!empty($filters['search'])) {
            $builder = $builder->groupStart()
                ->like('title', $filters['search'])
                ->orLike('description', $filters['search'])
                ->groupEnd();
        }

        $perPage = (int) ($filters['per_page'] ?? 10);
        $page = (int) ($filters['page'] ?? 1);

        $data = $builder->paginate($perPage, 'default', $page);
        $pager = $this->model->pager;

        return $this->respond([
            'data' => $data,
            'pager' => [
                'total' => $pager->getTotal(),
                'per_page' => $perPage,
                'current_page' => $page,
            ]
        ]);
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
        $today = new \DateTime('today');
        $daysRemaining = null;
        $daysOverdue   = null;

        if (!empty($bidding['end_date'])) {
            try {
                $end = new \DateTime(date('Y-m-d', strtotime($bidding['end_date'])));
                if ($today <= $end) {
                    $daysRemaining = (int)$today->diff($end)->days; // 0 nếu đến hạn hôm nay
                    $daysOverdue   = 0;
                } else {
                    $daysOverdue   = (int)$end->diff($today)->days;
                    $daysRemaining = 0;
                }
            } catch (\Throwable $e) {
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
