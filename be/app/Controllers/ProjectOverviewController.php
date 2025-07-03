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

        // 1. Lấy danh sách tổng hợp theo khách hàng
        $builder = $db->table('customers c')
            ->select("
                c.id AS customer_id,
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
                END)) AS progress
            ")
            ->join('biddings b', 'b.customer_id = c.id', 'left')
            ->join('contracts ct', 'ct.id_customer = c.id', 'left')
            ->join('tasks t', "t.linked_type IN ('contract', 'bidding') AND (t.linked_id = ct.id OR t.linked_id = b.id)", 'left')
            ->join('users u', 'u.id = t.assigned_to', 'left')
            ->groupBy('c.id');

        // 2. Thêm lọc thời gian nếu có
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

        // 3. Lấy tất cả task đang chạy theo customer
        $taskQuery = $db->query("
    SELECT
        c.id AS customer_id,
        t.id AS task_id,
        t.title AS task_title,
        t.status AS task_status,
        t.linked_type,
        t.linked_id
    FROM tasks t
    LEFT JOIN customers c 
        ON (t.linked_type = 'bidding' AND EXISTS (SELECT 1 FROM biddings b WHERE b.id = t.linked_id AND b.customer_id = c.id))
        OR (t.linked_type = 'contract' AND EXISTS (SELECT 1 FROM contracts ct WHERE ct.id = t.linked_id AND ct.id_customer = c.id))
    WHERE t.status IS NOT NULL
");


        $rawTasks = $taskQuery->getResultArray();

        // 4. Gom nhóm task theo customer_id
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
                'linked_id' => $task['linked_id'], // ← Quan trọng
                'status' => $task['task_status']
            ];
        }

        // 5. Parse kết quả và gán task
        foreach ($results as &$item) {
            $cid = $item['customer_id'];
            $item['biddings']   = json_decode($item['biddings'] ?? '[]', true);
            $item['contracts']  = json_decode($item['contracts'] ?? '[]', true);
            $item['assignees']  = json_decode($item['assignees'] ?? '[]', true);
            $item['tasks']      = $tasksByCustomer[$cid] ?? [];

            // Gán task vào từng gói thầu
            foreach ($item['biddings'] as &$bid) {
                $bid['tasks'] = array_values(array_filter($item['tasks'], function ($t) use ($bid) {
                    return $t['linked_type'] === 'bidding' && $t['linked_id'] == $bid['id'];
                }));
            }

            // Gán task vào từng hợp đồng
            foreach ($item['contracts'] as &$contract) {
                $contract['tasks'] = array_values(array_filter($item['tasks'], function ($t) use ($contract) {
                    return $t['linked_type'] === 'contract' && $t['linked_id'] == $contract['id'];
                }));
            }
        }

        return $this->respond([
            'data' => $results,
            'total' => count($results)
        ]);
    }
}
