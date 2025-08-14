<?php

namespace App\Controllers;

use App\Models\ContractModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use App\Models\ContractStepModel;
use App\Models\UserModel;
use App\Models\BiddingModel;
use DateTimeImmutable;
use DateTimeZone;
use Throwable;

class ContractController extends ResourceController
{
    protected $modelName = ContractModel::class;
    protected $format    = 'json';

    /**
     * @throws \Exception
     */
    public function index()
    {
        $filters = $this->request->getGet();
        $builder = $this->model;

        if (!empty($filters['status'])) {
            $builder->where('status', $filters['status']);
        }

        if (!empty($filters['department_id'])) {
            $builder->where('department_id', $filters['department_id']);
        }

        if (!empty($filters['created_from']) && !empty($filters['created_to'])) {
            $builder->where('created_at >=', $filters['created_from'])
                ->where('created_at <=', $filters['created_to']);
        }

        $data = $builder->findAll();

        $tz    = new DateTimeZone('Asia/Ho_Chi_Minh');
        $today = new DateTimeImmutable('today', $tz);

        foreach ($data as &$row) {
            // Đồng bộ các field phụ
            $row['bidding_id']  = $row['bidding_id']  ?? null;
            $row['customer_id'] = $row['id_customer'] ?? null;

            // --- TÍNH days_remaining & days_overdue ---
            // Ưu tiên end_date; nếu bạn dùng due_date thì đổi key dưới đây
            $dueVal = $row['end_date'] ?? ($row['due_date'] ?? null);

            if (empty($dueVal)) {
                $row['days_remaining'] = null;
                $row['days_overdue']   = null;
                continue;
            }

            try {
                $end = new DateTimeImmutable($dueVal, $tz);
                // Chuẩn hoá về ngày để tính theo ngày, không lệch do giờ
                $end = new DateTimeImmutable($end->format('Y-m-d'), $tz);

                // end - today (âm = quá hạn, dương = còn hạn)
                $deltaDays = (int) $today->diff($end)->format('%r%a');

                $row['days_overdue']   = $deltaDays < 0 ? abs($deltaDays) : 0;
                $row['days_remaining'] = max($deltaDays, 0);
            } catch (Throwable) {
                $row['days_remaining'] = null;
                $row['days_overdue']   = null;
            }
        }

        return $this->respond($data);
    }


    public function show($id = null)
    {
        $contract = $this->model->find($id);

        if (!$contract) {
            return $this->failNotFound('Contract not found');
        }

        return $this->respond($contract);
    }

    public function create()
    {
        $data = $this->request->getJSON(true);

        // Bắt buộc nhập tên hợp đồng (có thể ở 'title' hoặc 'name')
        if (empty($data['title']) && empty($data['name'])) {
            return $this->failValidationErrors(['title' => 'Vui lòng nhập tên hợp đồng']);
        }

        // Ưu tiên title từ form
        $data['title'] = $data['title'] ?? $data['name'];

        // Nếu chưa có mã hợp đồng, sinh mã tự động
        if (empty($data['code'])) {
            $data['code'] = $this->generateContractCode();
        }

        // Nếu tạo từ gói thầu → kiểm tra & gán id_customer
        if (!empty($data['bidding_id'])) {
            $biddingModel = new BiddingModel();
            $bidding = $biddingModel->find($data['bidding_id']);

            if (!$bidding) {
                return $this->failNotFound('Gói thầu không tồn tại');
            }

            if ($bidding['status'] !== 'awarded') {
                return $this->failValidationErrors(['bidding_id' => 'Gói thầu chưa được trúng']);
            }

            $data['id_customer'] = $bidding['customer_id'];
            $data['title'] = $data['title'] ?? $bidding['title'];
        }

        // Tiến hành insert
        $id = $this->model->insert($data);

        if (!$id) {
            return $this->failServerError('Không thể tạo hợp đồng');
        }

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

        // ✅ Nếu có bidding_id và chưa có id_customer → tự động gán từ bảng bidding
        if (!empty($data['bidding_id'])) {
            $bidding = (new BiddingModel())->find($data['bidding_id']);
            if ($bidding && empty($data['id_customer'])) {
                $data['id_customer'] = $bidding['customer_id'];
            }
        }

        if (!$this->model->update($id, $data)) {
            return $this->failServerError('Không thể cập nhật hợp đồng');
        }

        return $this->respondUpdated(['status' => 'success']);
    }

    public function delete($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Contract not found');
        }

        $this->model->delete($id);

        return $this->respondDeleted(['status' => 'success', 'message' => 'Contract deleted']);
    }

    public function stepCount($id = null): ResponseInterface
    {
        $contract = $this->model->find($id);
        if (!$contract) {
            return $this->failNotFound("Không tìm thấy hợp đồng");
        }

        $stepModel = new ContractStepModel();
        $count = $stepModel->where('contract_id', $id)->countAllResults();

        return $this->respond([
            'contract_id' => $id,
            'step_count'  => $count
        ]);
    }

    public function stepDetails($id = null): ResponseInterface
    {
        $contract = $this->model->find($id);
        if (!$contract) {
            return $this->failNotFound("Không tìm thấy hợp đồng");
        }

        $stepModel = new ContractStepModel();
        $steps = $stepModel
            ->where('contract_id', $id)
            ->orderBy('step_no', 'ASC')
            ->findAll();

        $userModel = new     UserModel();
        $stepList = [];

        foreach ($steps as $step) {
            $assignedUser = $step['assigned_to'] ? $userModel->find($step['assigned_to']) : null;

            $stepList[] = [
                'id'            => (int) $step['id'],
                'step_no'       => (int) $step['step_no'],
                'name'          => $step['name'],
                'status'        => $step['status'],
                'assigned_to'   => $assignedUser['name'] ?? null,
                'file_count'    => 0,
                'comment_count' => 0
            ];
        }

        return $this->respond($stepList);
    }

    public function byCustomer($customerId): ResponseInterface
    {
        $contracts = $this->model->where('id_customer', $customerId)->findAll();
        return $this->respond($contracts);
    }

    public function canMarkAsComplete($contractId = null): ResponseInterface
    {
        if (!$contractId || !$this->model->find($contractId)) {
            return $this->failNotFound("Hợp đồng không tồn tại");
        }

        $stepModel = new ContractStepModel();
        $unfinished = $stepModel
            ->where('contract_id', $contractId)
            ->where('status !=', 2) // 2 = Hoàn thành
            ->countAllResults();

        return $this->respond([
            'allow' => $unfinished === 0
        ]);
    }

}
