<?php
// LoyaltyHistoryController

namespace App\Controllers;

use App\Models\LoyaltyHistoryModel;
use CodeIgniter\RESTful\ResourceController;
use App\Traits\AuthTrait;

class LoyaltyHistoryController extends ResourceController
{
    use AuthTrait;

    protected $modelName = LoyaltyHistoryModel::class;
    protected $format    = 'json';

    public function participation()
    {
        $userId = $this->getUserId();
        $data = $this->model
            ->where('user_id', $userId)
            ->where('type', 'participation')
            ->orderBy('created_at', 'desc')
            ->findAll();

        return $this->respond($data);
    }

    public function winning()
    {
        $userId = $this->getUserId();
        $data = $this->model
            ->where('user_id', $userId)
            ->where('type', 'winning')
            ->orderBy('created_at', 'desc')
            ->findAll();

        return $this->respond($data);
    }
}
