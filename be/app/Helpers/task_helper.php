<?php

use CodeIgniter\I18n\Time;

/**
 * Tính số ngày còn lại hoặc quá hạn từ end_date
 *
 * @param string|null $endDate
 * @return array ['days_remaining' => int, 'days_overdue' => int]
 * @throws Exception
 */
function calculateDeadlineDiff(?string $endDate): array
{
    if (!empty($endDate)) {
        $end = Time::parse($endDate)->toDateString();
        $now = Time::now()->toDateString();

        $dEnd = new DateTime($end);
        $dNow = new DateTime($now);

        $interval = $dNow->diff($dEnd);
        $days = (int) $interval->days;

        if ($dEnd > $dNow) {
            return ['days_remaining' => $days, 'days_overdue' => 0];
        } elseif ($dEnd < $dNow) {
            return ['days_remaining' => 0, 'days_overdue' => $days];
        } else {
            // hôm nay là hạn cuối
            return ['days_remaining' => 0, 'days_overdue' => 0];
        }
    }

    return ['days_remaining' => 0, 'days_overdue' => 0];
}
