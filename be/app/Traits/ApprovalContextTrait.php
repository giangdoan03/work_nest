<?php
namespace App\Traits;

use App\Models\DocumentApprovalModel;
use App\Models\DocumentApprovalStepModel;
use App\Models\DocumentModel;
use CodeIgniter\HTTP\ResponseInterface;

trait ApprovalContextTrait
{
    use AuthTrait;
    protected function getApprovalContext(): array|ResponseInterface
    {
        $userId = $this->requireLogin();
        if ($userId instanceof ResponseInterface) {
            return $userId; // chưa login
        }

        return [
            'userId' => $userId,
            'apvM'   => new DocumentApprovalModel(),
            'stepM'  => new DocumentApprovalStepModel(),
            'docM'   => new DocumentModel(),
        ];
    }
}
