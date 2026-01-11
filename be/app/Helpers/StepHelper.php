<?php

function enrichStepList(array $steps, array $tasks): array
{
    // gom tasks theo step_id
    $grouped = [];
    foreach ($tasks as $t) {
        $grouped[$t['step_id']][] = $t;
    }

    // gom assignees
    $uids = [];
    foreach ($tasks as $t) {
        if (!empty($t['assigned_to'])) {
            $uids[(string)$t['assigned_to']] = true;
        }
    }

    // load thông tin user
    $userById = [];
    if ($uids) {
        $ids = array_keys($uids);
        $userModel = new \App\Models\UserModel();
        foreach ($userModel->whereIn('id', $ids)->findAll() as $u) {
            $userById[(string)$u['id']] = $u;
        }
    }

    // enrich từng step
    foreach ($steps as &$s) {
        $list = $grouped[$s['id']] ?? [];

        $total    = count($list);
        $approved = 0;
        $remMin   = null;
        $overMax  = 0;

        $uidsStep = [];

        foreach ($list as $tsk) {
            if ($tsk['approval_status'] === 'approved' || $tsk['progress'] >= 100) {
                $approved++;
            }
            if (!empty($tsk['assigned_to'])) {
                $uidsStep[] = (string)$tsk['assigned_to'];
            }
            $rem = $tsk['days_remaining'];
            $ov  = $tsk['days_overdue'];

            if ($rem !== null && $rem > 0) {
                $remMin = ($remMin === null) ? $rem : min($remMin, $rem);
            }
            if ($ov !== null && $ov > 0) {
                $overMax = max($overMax, $ov);
            }
        }

        // map dữ liệu trả về
        $uidsStep = array_values(array_unique($uidsStep));
        $s['task_count']        = $total;
        $s['task_done_count']   = $approved;
        $s['step_progress']     = $total ? round($approved * 100 / $total) : 0;
        $s['days_remaining']    = $remMin;
        $s['days_overdue']      = $overMax;
        $s['assignees']         = $uidsStep;
        $s['assignees_detail']  = array_values(array_filter(array_map(
            fn($id) => $userById[$id] ?? null,
            $uidsStep
        )));
        $s['assignees_count']   = count($uidsStep);
    }

    return $steps;
}
