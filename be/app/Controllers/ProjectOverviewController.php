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
            ->join('tasks t', 't.linked_type IN ("contract", "bidding") AND (t.linked_id = ct.id OR t.linked_id = b.id)', 'left')
            ->join('users u', 'u.id = t.assigned_to', 'left')
            ->groupBy('c.id');

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

        // Parse JSON fields
        foreach ($results as &$item) {
            $item['biddings'] = json_decode($item['biddings'] ?? '[]');
            $item['contracts'] = json_decode($item['contracts'] ?? '[]');
            $item['assignees'] = json_decode($item['assignees'] ?? '[]');
        }

        return $this->respond([
            'data' => $results,
            'total' => count($results)
        ]);
    }
}
