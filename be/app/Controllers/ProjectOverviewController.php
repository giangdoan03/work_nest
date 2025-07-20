<?php

namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;
use Config\Database;

class ProjectOverviewController extends ResourceController
{
    protected $format = 'json';

    public function index()
    {
        $db = Database::connect();
        $filters = $this->request->getGet();

        $timeframe = $filters['timeframe'] ?? 'all';
        $limit = (int) ($filters['limit'] ?? 10);
        $page = (int) ($filters['page'] ?? 1);
        $offset = ($page - 1) * $limit;

        // 1. Đếm tổng số khách hàng
        $countBuilder = $db->table('customers c')
            ->select('c.id')
            ->join('biddings b', 'b.customer_id = c.id', 'left')
            ->join('contracts ct', 'ct.id_customer = c.id', 'left')
            ->join('tasks t', "t.linked_type IN ('contract', 'bidding') AND (t.linked_id = ct.id OR t.linked_id = b.id)", 'left');

        switch ($timeframe) {
            case 'day':
                $countBuilder->where('DATE(t.end_date)', date('Y-m-d'));
                break;
            case 'week':
                $countBuilder->where('YEARWEEK(t.end_date, 1)', date('oW'));
                break;
            case 'month':
                $countBuilder->where('MONTH(t.end_date)', date('n'))
                    ->where('YEAR(t.end_date)', date('Y'));
                break;
            case 'year':
                $countBuilder->where('YEAR(t.end_date)', date('Y'));
                break;
        }

        $totalCount = count($countBuilder->groupBy('c.id')->get()->getResultArray());

        // 2. Truy vấn danh sách khách hàng
        $builder = $db->table('customers c')
            ->select("c.id AS customer_id,
                      c.name AS customer_name,
                      CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', b.id, 'title', b.title)), ']') AS biddings,
                      CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', ct.id, 'title', ct.title)), ']') AS contracts,
                      CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', u.id, 'name', u.name)), ']') AS assignees,
                      COUNT(t.id) AS task_count,
                      ROUND(AVG(CASE 
                          WHEN t.status = 'done' THEN 100
                          WHEN t.status = 'doing' THEN 50
                          WHEN t.status = 'todo' THEN 0
                          ELSE 0
                      END)) AS progress")
            ->join('biddings b', 'b.customer_id = c.id', 'left')
            ->join('contracts ct', 'ct.id_customer = c.id', 'left')
            ->join('tasks t', "t.linked_type IN ('contract', 'bidding') AND (t.linked_id = ct.id OR t.linked_id = b.id)", 'left')
            ->join('users u', 'u.id = t.assigned_to', 'left')
            ->groupBy('c.id')
            ->limit($limit, $offset);

        switch ($timeframe) {
            case 'day':
                $builder->where('DATE(t.end_date)', date('Y-m-d'));
                break;
            case 'week':
                $builder->where('YEARWEEK(t.end_date, 1)', date('oW'));
                break;
            case 'month':
                $builder->where('MONTH(t.end_date)', date('n'))
                    ->where('YEAR(t.end_date)', date('Y'));
                break;
            case 'year':
                $builder->where('YEAR(t.end_date)', date('Y'));
                break;
        }

        $results = $builder->get()->getResultArray();

        // 3. Lấy task có thông tin step
        $taskQuery = $db->query("
    SELECT
        c.id AS customer_id,
        t.id AS task_id,
        t.title AS task_title,
        t.status AS task_status,
        t.linked_type,
        t.linked_id,
        t.step_code,
        t.step_id,
        CASE 
            WHEN t.linked_type = 'bidding' THEN bs.title
            WHEN t.linked_type = 'contract' THEN cs.title
            ELSE NULL
        END AS step_title,
        u.id AS user_id,
        u.name AS user_name,
        t.assigned_to
    FROM tasks t
    LEFT JOIN customers c 
        ON (t.linked_type = 'bidding' AND EXISTS (SELECT 1 FROM biddings b WHERE b.id = t.linked_id AND b.customer_id = c.id))
        OR (t.linked_type = 'contract' AND EXISTS (SELECT 1 FROM contracts ct WHERE ct.id = t.linked_id AND ct.id_customer = c.id))
    LEFT JOIN users u ON u.id = t.assigned_to
    LEFT JOIN bidding_steps bs ON t.linked_type = 'bidding' AND t.step_id = bs.id
    LEFT JOIN contract_steps cs ON t.linked_type = 'contract' AND t.step_id = cs.id
    WHERE t.status IS NOT NULL
    ORDER BY t.linked_type, t.linked_id, t.step_code
");


        $rawTasks = $taskQuery->getResultArray();

        $tasksByCustomer = [];
        foreach ($rawTasks as $task) {
            $cid = $task['customer_id'];
            if (!isset($tasksByCustomer[$cid])) {
                $tasksByCustomer[$cid] = [];
            }

            $tasksByCustomer[$cid][] = [
                'id' => $task['task_id'],
                'title' => $task['task_title'],
                'linked_type' => $task['linked_type'],
                'linked_id' => $task['linked_id'],
                'status' => $task['task_status'],
                'step_code' => $task['step_code'],
                'step_id' => $task['step_id'],
                'step_title' => $task['step_title'], // ✅ thêm dòng này
                'assignees' => $task['user_id'] ? [[
                    'id' => $task['user_id'],
                    'name' => $task['user_name']
                ]] : [],
                'assigned_to' => $task['assigned_to'],
            ];

        }

        foreach ($results as &$item) {
            $cid = $item['customer_id'];
            $item['biddings'] = json_decode($item['biddings'] ?? '[]', true);
            $item['contracts'] = json_decode($item['contracts'] ?? '[]', true);
            $item['assignees'] = json_decode($item['assignees'] ?? '[]', true);
            $item['tasks'] = $tasksByCustomer[$cid] ?? [];

            foreach ($item['biddings'] as &$bid) {
                $bid['tasks'] = array_values(array_filter($item['tasks'], function ($t) use ($bid) {
                    return $t['linked_type'] === 'bidding' && $t['linked_id'] == $bid['id'];
                }));
            }

            foreach ($item['contracts'] as &$contract) {
                $contract['tasks'] = array_values(array_filter($item['tasks'], function ($t) use ($contract) {
                    return $t['linked_type'] === 'contract' && $t['linked_id'] == $contract['id'];
                }));
            }
        }

        return $this->respond([
            'data' => $results,
            'total' => $totalCount,
            'page' => $page,
            'limit' => $limit
        ]);
    }
}
