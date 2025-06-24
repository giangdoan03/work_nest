<?php

namespace App\Controllers;

use App\Models\TaskModel;
use CodeIgniter\RESTful\ResourceController;

class MyTaskController extends ResourceController
{
    protected $modelName = TaskModel::class;
    protected $format    = 'json';

    public function index()
    {
        $session = session();

        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        $userId = $session->get('user_id');

        $filters = $this->request->getGet();
        $timeframe = $filters['timeframe'] ?? 'all';

        // 🔁 Dùng cột assigned_to trong bảng tasks
        $builder = $this->model->builder()
            ->where('assigned_to', $userId);

        // 👉 Lọc theo thời gian
        switch ($timeframe) {
            case 'day':
                $builder->where('DATE(start_date)', date('Y-m-d'));
                break;
            case 'week':
                $builder->where('YEARWEEK(start_date, 1)', date('oW'));
                break;
            case 'month':
                $builder->where('MONTH(start_date)', date('n'))
                    ->where('YEAR(start_date)', date('Y'));
                break;
            case 'year':
                $builder->where('YEAR(start_date)', date('Y'));
                break;
        }

        $tasks = $builder->get()->getResult();

        return $this->respond([
            'data' => $tasks,
            'total' => count($tasks),
        ]);
    }
}
