<?php

namespace App\Models;

use CodeIgniter\Model;

class BiddingModel extends Model
{
    protected $table         = 'biddings';
    protected $primaryKey    = 'id';
    protected $useTimestamps = true;          // tự set created_at / updated_at
    protected $returnType    = 'array';

    protected $allowedFields = [
        'title', 'description', 'customer_id', 'estimated_cost', 'status',
        'start_date', 'end_date',
        'assigned_to', 'manager_id',
        'collaborators',      // nếu là JSON, có thể cast thêm bên dưới
        'priority',
        'approval_status',    // pending|approved|rejected
        'approval_steps',     // JSON mảng các step
        'current_level',      // số nguyên (0-based)
    ];

    // 👇 Quan trọng: để CI4 tự serialize/deserialize
    protected array $casts = [
        'approval_steps' => '?json-array', // cho phép null
        'current_level'  => 'integer',

        // các khoá ngoại có thể trống:
        'manager_id'     => '?integer',
        'assigned_to'    => '?integer',
        'customer_id'    => '?integer',

        'status'         => 'integer',
        'priority'       => 'integer',

        // nếu collaborators là JSON và có thể null:
        // 'collaborators'  => '?json-array',
    ];


    // (Khuyến nghị) Chuẩn hoá dữ liệu steps trước khi lưu để tránh 'NULL'/'\'pending\''
    protected $beforeInsert = ['normalizeApprovalSteps'];

    protected function normalizeApprovalSteps(array $data): array
    {
        if (!isset($data['data']['approval_steps'])) return $data;

        $raw = $data['data']['approval_steps'];

        // Nếu backend vẫn gửi chuỗi JSON (legacy), để cast xử lý
        if (is_string($raw)) return $data;

        $steps = [];
        foreach ((array) $raw as $s) {
            $steps[] = [
                'level'        => isset($s['level']) ? (int) $s['level'] : null,
                'approver_id'  => isset($s['approver_id']) ? (int) $s['approver_id'] : null,
                'status'       => $s['status'] ?? 'pending',   // KHÔNG "'pending'"
                'commented_at' => $s['commented_at'] ?? null,  // null thật, KHÔNG "NULL"
                'note'         => $s['note'] ?? null,
                'acted_by'     => $s['acted_by'] ?? null,
                'acted_role'   => $s['acted_role'] ?? null,
            ];
        }

        $data['data']['approval_steps'] = $steps;
        return $data;
    }
}
