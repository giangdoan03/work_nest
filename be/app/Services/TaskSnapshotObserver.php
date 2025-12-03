<?php

namespace App\Services;

use App\Models\TaskSnapshotModel;
use App\Models\TaskModel;
use App\Models\UserModel;

class TaskSnapshotObserver
{
    protected TaskSnapshotModel $snapModel;
    protected TaskModel $taskModel;
    protected UserModel $userModel;
    protected MailService $mailer;

    public function __construct()
    {
        $this->snapModel = new TaskSnapshotModel();
        $this->taskModel = new TaskModel();
        $this->userModel = new UserModel();
        $this->mailer    = new MailService();
    }

    /**
     * Sau khi snapshot được tạo → gọi hàm này
     */
    public function detectChangesAndNotify(int $taskId): void
    {
        $snaps = $this->snapModel
            ->where('task_id', $taskId)
            ->orderBy('id', 'DESC')
            ->findAll(2);

        if (count($snaps) < 2) return;

        $new = $snaps[0];
        $old = $snaps[1];

        $newRoster = json_decode($new['approval_roster_json'], true) ?: [];
        $oldRoster = json_decode($old['approval_roster_json'], true) ?: [];

        $this->compare($taskId, $oldRoster, $newRoster);
    }

    private function compare(int $taskId, array $old, array $new): void
    {
        $oldMap = $this->map($old);
        $newMap = $this->map($new);

        /* ========== 1) Người mới thêm vào ========== */
        foreach ($newMap as $uid => $m) {
            if (!isset($oldMap[$uid])) {
                $this->mailer->sendNewApproverAdded($taskId, $uid);
            }
        }

        /* ========== 2) Người đổi trạng thái ========== */
        foreach ($newMap as $uid => $m) {

            $oldStatus = $oldMap[$uid]['status'] ?? null;
            $newStatus = $m['status'];

            if ($oldStatus !== $newStatus) {

                if ($newStatus === 'approved') {
                    $this->mailer->sendApproved($taskId, $uid);

                    // tìm người pending kế tiếp
                    $next = $this->findNextPending($newMap);
                    if ($next) {
                        $this->mailer->sendNextTurn($taskId, $next);
                    }
                }

                if ($newStatus === 'rejected') {
                    $task = $this->taskModel->find($taskId);
                    $creatorId = $task['created_by'];
                    $this->mailer->sendRejected($taskId, $uid, $creatorId);
                }
            }
        }

        /* ========== 3) Tất cả đã approved ========== */
        $allApproved = !array_filter($newMap, fn($m) => $m['status'] !== 'approved');

        if ($allApproved) {
            $task = $this->taskModel->find($taskId);
            $creatorId = $task['created_by'];
            $this->mailer->sendAllApproved($taskId, $creatorId);
        }
    }

    private function map(array $roster): array
    {
        $out = [];
        foreach ($roster as $m) {
            $out[(int)$m['user_id']] = $m;
        }
        return $out;
    }

    private function findNextPending(array $map): ?int
    {
        foreach ($map as $uid => $m) {
            if ($m['status'] === 'pending') return $uid;
        }
        return null;
    }
}
