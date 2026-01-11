<?php

namespace App\Services;

class TaskUrlBuilder
{
    public static function build(array $d): string
    {
        return match ($d['type']) {
            'bidding' => "/biddings/{$d['bid_id']}/steps/{$d['step_id']}/tasks/{$d['task_id']}/info",

            'contract' => "/contract/{$d['contract_id']}/steps/{$d['step_id']}/tasks/{$d['task_id']}/info",

            'workflow' => "/workflow/tasks/{$d['task_id']}/info",

            'non-workflow' => "/non-workflow/tasks/{$d['task_id']}/info",

            default => "/task-approvals",
        };
    }
}
