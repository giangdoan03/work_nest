<?php

namespace App\Controllers;

use App\Models\TaskModel;
use App\Models\TaskExtensionModel;
use CodeIgniter\RESTful\ResourceController;

class MyTaskController extends ResourceController
{
    protected $modelName = TaskModel::class;
    protected $format    = 'json';

    /**
     * @throws \Exception
     */
    public function index()
    {
        $session = session();

        if (!$session->get('logged_in')) {
            return $this->failUnauthorized('Bạn chưa đăng nhập');
        }

        $userId = $session->get('user_id');

        $filters = $this->request->getGet();
        $timeframe = $filters['timeframe'] ?? 'all';

        $builder = $this->model->builder()
            ->where('assigned_to', $userId);

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

        $extensionModel = new TaskExtensionModel();

        foreach ($tasks as &$task) {
            // Đếm số lần gia hạn
            $count = $extensionModel
                ->where('task_id', $task->id)
                ->countAllResults();
            $task->extension_count = $count;

            // Tính số ngày còn lại hoặc quá hạn
            $diff = $this->calculateDeadlineDiff($task->end_date ?? null);
            $task->days_remaining = $diff['days_remaining'];
            $task->days_overdue   = $diff['days_overdue'];
        }

        return $this->respond([
            'data'  => $tasks,
            'total' => count($tasks),
        ]);
    }

    /**
     * @throws \Exception
     */
    private function calculateDeadlineDiff(?string $endDate): array
    {
        if (!$endDate) {
            return [
                'days_remaining' => null,
                'days_overdue'   => null,
            ];
        }

        $now = new \DateTimeImmutable();
        $end = new \DateTimeImmutable($endDate);
        $diff = $now->diff($end);
        $days = (int)$diff->format('%r%a'); // ngày có dấu +/-

        return [
            'days_remaining' => max($days, 0),
            'days_overdue'   => $days < 0 ? abs($days) : 0,
        ];
    }


}
