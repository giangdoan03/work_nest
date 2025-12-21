<?php

namespace App\Libraries;

use App\Models\ContractModel;
use App\Models\UserModel;
use App\Models\BiddingModel;
use CodeIgniter\Email\Email;
use Config\Services;

class MailService
{
    protected Email $email;

    public function __construct()
    {
        $this->email = Services::email();

        // ✅ BẮT BUỘC: set FROM
        $this->email->setFrom(
            config('Email')->fromEmail,
            config('Email')->fromName
        );
    }

    /**
     * Reset email state trước mỗi lần gửi
     */
    private function resetEmail(): void
    {
        $this->email->clear(true);
        $this->email->setFrom(
            config('Email')->fromEmail,
            config('Email')->fromName
        );
    }

    /**
     * Send mail + log nếu fail
     */
    private function send(): bool
    {
        if (!$this->email->send()) {
            log_message(
                'error',
                '[MAIL ERROR] ' . print_r($this->email->printDebugger(['headers']), true)
            );
            return false;
        }
        return true;
    }

    /* =====================================================
     * ====================== BIDDING ======================
     * ===================================================== */

    /**
     * 📧 Xin bỏ qua bước (gửi cho manager)
     */
    public function sendSkipStepMail(array $step): bool
    {
        $this->resetEmail();

        $userModel    = new UserModel();
        $biddingModel = new BiddingModel();

        $requester = $userModel->find($step['skip_requested_by'] ?? null);
        if (!$requester) return false;

        $bidding = $biddingModel->find($step['bidding_id'] ?? null);
        if (!$bidding || empty($bidding['manager_id'])) return false;

        $manager = $userModel->find($bidding['manager_id']);
        if (!$manager || empty($manager['email'])) return false;

        $approveUrl = sprintf(
            '%s/bid-detail/%d?approveSkipStep=%d',
            rtrim(env('APP_FRONTEND_URL'), '/'),
            $bidding['id'],
            $step['id']
        );

        $this->email->setTo($manager['email']);
        $this->email->setSubject('[WorkNest] Yêu cầu bỏ qua bước đấu thầu');
        $this->email->setMessage(
            view('emails/skip_step', [
                'managerName' => $manager['name'],
                'requester'   => $requester['name'],
                'stepTitle'   => $step['title'],
                'stepNumber'  => $step['step_number'],
                'reason'      => $step['skip_reason'],
                'approveUrl'  => $approveUrl,
            ])
        );

        return $this->send();
    }

    /**
     * 📧 TỪ CHỐI bỏ qua bước
     */
    public function sendRejectSkipStepMail(array $step, string $reason): bool
    {
        $this->resetEmail();

        $userModel    = new UserModel();
        $biddingModel = new BiddingModel();

        $requester = $userModel->find($step['skip_requested_by'] ?? null);
        if (!$requester || empty($requester['email'])) return false;

        $bidding = $biddingModel->find($step['bidding_id'] ?? null);
        if (!$bidding) return false;

        $manager = !empty($step['skip_approved_by'])
            ? $userModel->find($step['skip_approved_by'])
            : null;

        $detailUrl = sprintf(
            '%s/bid-detail/%d',
            rtrim(env('APP_FRONTEND_URL'), '/'),
            $bidding['id']
        );

        $this->email->setTo($requester['email']);
        $this->email->setSubject('[WorkNest] Yêu cầu bỏ qua bước đã bị từ chối');
        $this->email->setMessage(
            view('emails/reject_skip_step', [
                'requesterName' => $requester['name'],
                'stepTitle'     => $step['title'],
                'stepNumber'    => $step['step_number'],
                'reason'        => $reason,
                'managerName'   => $manager['name'] ?? 'Người quản lý',
                'detailUrl'     => $detailUrl,
            ])
        );

        return $this->send();
    }

    /**
     * 📧 DUYỆT bỏ qua bước
     */
    public function sendApproveSkipStepMail(array $step): bool
    {
        $this->resetEmail();

        $userModel    = new UserModel();
        $biddingModel = new BiddingModel();

        $requester = $userModel->find($step['skip_requested_by'] ?? null);
        if (!$requester || empty($requester['email'])) return false;

        $bidding = $biddingModel->find($step['bidding_id'] ?? null);
        if (!$bidding) return false;

        $manager = !empty($step['skip_approved_by'])
            ? $userModel->find($step['skip_approved_by'])
            : null;

        $detailUrl = sprintf(
            '%s/bid-detail/%d',
            rtrim(env('APP_FRONTEND_URL'), '/'),
            $bidding['id']
        );

        $this->email->setTo($requester['email']);
        $this->email->setSubject('[WorkNest] Yêu cầu bỏ qua bước đã được chấp thuận');
        $this->email->setMessage(
            view('emails/approve_skip_step', [
                'requesterName' => $requester['name'],
                'stepTitle'     => $step['title'],
                'stepNumber'    => $step['step_number'],
                'managerName'   => $manager['name'] ?? 'Người quản lý',
                'detailUrl'     => $detailUrl,
            ])
        );

        return $this->send();
    }

    /* =====================================================
     * ====================== CONTRACT =====================
     * ===================================================== */

    public function sendSkipContractStepMail(array $step): bool
    {
        $this->resetEmail();

        $userModel     = new UserModel();
        $contractModel = new ContractModel();

        $requester = $userModel->find($step['skip_requested_by'] ?? null);
        if (!$requester) return false;

        $contract = $contractModel->find($step['contract_id'] ?? null);
        if (!$contract || empty($contract['manager_id'])) return false;

        $manager = $userModel->find($contract['manager_id']);
        if (!$manager || empty($manager['email'])) return false;

        $approveUrl = sprintf(
            '%s/contract-detail/%d?approveSkipStep=%d',
            rtrim(env('APP_FRONTEND_URL'), '/'),
            $contract['id'],
            $step['id']
        );

        $this->email->setTo($manager['email']);
        $this->email->setSubject('[WorkNest] Yêu cầu bỏ qua bước hợp đồng');
        $this->email->setMessage(
            view('emails/contract_skip_step', [
                'managerName' => $manager['name'],
                'requester'   => $requester['name'],
                'stepTitle'   => $step['title'],
                'stepNumber'  => $step['step_number'],
                'reason'      => $step['skip_reason'],
                'approveUrl'  => $approveUrl,
            ])
        );

        return $this->send();
    }

    public function sendRejectSkipContractStepMail(array $step, string $reason): bool
    {
        $this->resetEmail();

        $userModel     = new UserModel();
        $contractModel = new ContractModel();

        $requester = $userModel->find($step['skip_requested_by'] ?? null);
        if (!$requester || empty($requester['email'])) return false;

        $contract = $contractModel->find($step['contract_id'] ?? null);
        if (!$contract) return false;

        $manager = !empty($step['skip_approved_by'])
            ? $userModel->find($step['skip_approved_by'])
            : null;

        $detailUrl = sprintf(
            '%s/contract-detail/%d',
            rtrim(env('APP_FRONTEND_URL'), '/'),
            $contract['id']
        );

        $this->email->setTo($requester['email']);
        $this->email->setSubject('[WorkNest] Yêu cầu bỏ qua bước hợp đồng đã bị từ chối');
        $this->email->setMessage(
            view('emails/contract_reject_skip_step', [
                'requesterName' => $requester['name'],
                'stepTitle'     => $step['title'],
                'stepNumber'    => $step['step_number'],
                'reason'        => $reason,
                'managerName'   => $manager['name'] ?? 'Người quản lý',
                'detailUrl'     => $detailUrl,
            ])
        );

        return $this->send();
    }

    public function sendApproveSkipContractStepMail(array $step): bool
    {
        $this->resetEmail();

        $userModel     = new UserModel();
        $contractModel = new ContractModel();

        $requester = $userModel->find($step['skip_requested_by'] ?? null);
        if (!$requester || empty($requester['email'])) return false;

        $contract = $contractModel->find($step['contract_id'] ?? null);
        if (!$contract) return false;

        $manager = !empty($step['skip_approved_by'])
            ? $userModel->find($step['skip_approved_by'])
            : null;

        $detailUrl = sprintf(
            '%s/contract-detail/%d',
            rtrim(env('APP_FRONTEND_URL'), '/'),
            $contract['id']
        );

        $this->email->setTo($requester['email']);
        $this->email->setSubject('[WorkNest] Yêu cầu bỏ qua bước hợp đồng đã được chấp thuận');
        $this->email->setMessage(
            view('emails/contract_approve_skip_step', [
                'requesterName' => $requester['name'],
                'stepTitle'     => $step['title'],
                'stepNumber'    => $step['step_number'],
                'managerName'   => $manager['name'] ?? 'Người quản lý',
                'detailUrl'     => $detailUrl,
            ])
        );

        return $this->send();
    }
}
