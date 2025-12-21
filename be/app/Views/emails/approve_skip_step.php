<?php
/**
 * @var string $requesterName
 * @var string|int $stepNumber
 * @var string $stepTitle
 * @var string $managerName
 * @var string $detailUrl
 */
?>

<p>Xin chào <strong><?= esc($requesterName) ?></strong>,</p>

<p>
    Yêu cầu <strong>
        bỏ qua bước <?= esc($stepNumber) ?> - <?= esc($stepTitle) ?>
    </strong>
    của bạn đã được <strong><?= esc($managerName) ?></strong> chấp thuận.
</p>

<p>
    Bước này đã được đánh dấu là <strong>hoàn thành</strong>
    và hệ thống đã tự động mở bước tiếp theo.
</p>

<p>
    👉 <a href="<?= esc($detailUrl) ?>">Xem chi tiết gói thầu</a>
</p>

<hr>

<p style="font-size:12px;color:#666;">
    Email này được gửi tự động từ hệ thống WorkNest.
</p>
