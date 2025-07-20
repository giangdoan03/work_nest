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
        $limit = (int)($filters['limit'] ?? 10);
        $page = (int)($filters['page'] ?? 1);
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
                $countBuilder->where('MONTH(t.end_date)', date('n'))->where('YEAR(t.end_date)', date('Y'));
                break;
            case 'year':
                $countBuilder->where('YEAR(t.end_date)', date('Y'));
                break;
        }

        $totalCount = count($countBuilder->groupBy('c.id')->get()->getResultArray());

        // 2. Truy vấn danh sách khách hàng (BỎ progress)
        $builder = $db->table('customers c')
            ->select("c.id AS customer_id,
                c.name AS customer_name,
                (
                    SELECT CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', b.id, 'title', b.title)), ']')
                    FROM biddings b
                    WHERE b.customer_id = c.id
                        AND EXISTS (
                            SELECT 1 FROM tasks t WHERE t.linked_type = 'bidding' AND t.linked_id = b.id
                        )
                ) AS biddings,
                (
                    SELECT CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', ct.id, 'title', ct.title)), ']')
                    FROM contracts ct
                    WHERE ct.id_customer = c.id
                        AND EXISTS (
                            SELECT 1 FROM tasks t WHERE t.linked_type = 'contract' AND t.linked_id = ct.id
                        )
                ) AS contracts,
                CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', u.id, 'name', u.name)), ']') AS assignees,
                COUNT(t.id) AS task_count,
                ROUND(AVG(CASE 
                    WHEN t.status = 'done' THEN 100
                    WHEN t.status = 'doing' THEN 50
                    WHEN t.status = 'todo' THEN 0
                    ELSE 0
                END)) AS progress") // ✅ GIỮ LẠI CỘT TIẾN ĐỘ

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
                $builder->where('MONTH(t.end_date)', date('n'))->where('YEAR(t.end_date)', date('Y'));
                break;
            case 'year':
                $builder->where('YEAR(t.end_date)', date('Y'));
                break;
        }

        $results = $builder->get()->getResultArray();

        // 3. Lấy tasks chi tiết, kèm tên người đề nghị & thực hiện
        $taskQuery = $db->table('tasks t')
            ->select("
                c.id AS customer_id,
                t.id AS task_id,
                t.title AS task_title,
                t.status AS task_status,
                t.start_date,
                t.end_date,
                t.linked_type,
                t.linked_id,
                t.step_code,
                t.step_id,
                t.priority,
                t.assigned_to,
                t.proposed_by,
                u1.name AS assigned_name,
                u2.name AS proposed_name,
                CASE 
                    WHEN t.linked_type = 'bidding' THEN bs.title
                    WHEN t.linked_type = 'contract' THEN cs.title
                    ELSE NULL
                END AS step_title
            ")
            ->join('users u1', 'u1.id = t.assigned_to', 'left')
            ->join('users u2', 'u2.id = t.proposed_by', 'left')
            ->join('bidding_steps bs', 't.linked_type = "bidding" AND t.step_id = bs.id', 'left')
            ->join('contract_steps cs', 't.linked_type = "contract" AND t.step_id = cs.id', 'left')
            ->join('biddings b', 't.linked_type = "bidding" AND t.linked_id = b.id', 'left')
            ->join('contracts ct', 't.linked_type = "contract" AND t.linked_id = ct.id', 'left')
            ->join('customers c', '
                (t.linked_type = "bidding" AND b.customer_id = c.id)
                OR (t.linked_type = "contract" AND ct.id_customer = c.id)
            ', 'left')
            ->where('t.status IS NOT NULL')
            ->orderBy('t.linked_type')
            ->orderBy('t.linked_id')
            ->orderBy('t.step_code')
            ->get();

        $rawTasks = $taskQuery->getResultArray();

        // 4. Lấy extensions
        $taskIds = array_column($rawTasks, 'task_id');
        $extensionsByTask = [];
        if (!empty($taskIds)) {
            $exts = $db->table('task_extensions')->whereIn('task_id', $taskIds)->get()->getResultArray();
            foreach ($exts as $ext) {
                $extensionsByTask[$ext['task_id']][] = $ext;
            }
        }

        // 5. Gom tasks theo customer
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
                'start_date' => $task['start_date'],
                'end_date' => $task['end_date'],
                'step_code' => $task['step_code'],
                'priority' => $task['priority'],
                'step_id' => $task['step_id'],
                'step_title' => $task['step_title'],
                'assigned_to' => $task['assigned_to'],
                'assigned_name' => $task['assigned_name'],
                'proposed_by' => $task['proposed_by'],
                'proposed_name' => $task['proposed_name'],
                'extensions' => $extensionsByTask[$task['task_id']] ?? []
            ];
        }

        // 6. Gắn vào từng khách hàng
        foreach ($results as &$item) {
            $cid = $item['customer_id'];
            $item['biddings'] = json_decode($item['biddings'] ?? '[]', true);
            $item['contracts'] = json_decode($item['contracts'] ?? '[]', true);
            $item['assignees'] = json_decode($item['assignees'] ?? '[]', true);
            $item['tasks'] = $tasksByCustomer[$cid] ?? [];

            foreach ($item['biddings'] as &$bid) {
                $bid['tasks'] = array_values(array_filter($item['tasks'], fn($t) => $t['linked_type'] === 'bidding' && $t['linked_id'] == $bid['id']));
            }

            foreach ($item['contracts'] as &$contract) {
                $contract['tasks'] = array_values(array_filter($item['tasks'], fn($t) => $t['linked_type'] === 'contract' && $t['linked_id'] == $contract['id']));
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
