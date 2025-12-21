<?php
/**
 * @var string $requesterName
 * @var int|string $stepNumber
 * @var string $stepTitle
 * @var string $managerName
 * @var string $reason
 * @var string $detailUrl
 */
?>

<p>Xin chào <strong><?= esc($requesterName) ?></strong>,</p>

<p>
    Yêu cầu <strong>bỏ qua bước <?= esc($stepNumber) ?> - <?= esc($stepTitle) ?></strong>
    của bạn đã bị <strong style="color:red;">từ chối</strong>.
</p>

<p>
    <strong>Lý do:</strong><br>
    <?= nl2br(esc($reason)) ?>
</p>

<p>
    Người phản hồi: <strong><?= esc($managerName) ?></strong>
</p>

<p>
    👉 <a href="<?= esc($detailUrl) ?>">Xem chi tiết hợp đồng</a>
</p>

<hr>

<p style="font-size:12px;color:#666;">
    Email này được gửi tự động từ hệ thống WorkNest.
</p>
