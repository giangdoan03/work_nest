<?php
/**
 * @var string $requesterName
 * @var string|int $stepNumber
 * @var string $stepTitle
 * @var string $reason
 * @var string $managerName
 * @var string $detailUrl
 */
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Từ chối bỏ qua bước</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6">
<p>Xin chào <strong><?= esc($requesterName) ?></strong>,</p>

<p>
    Yêu cầu <strong>bỏ qua bước <?= esc($stepNumber) ?>: <?= esc($stepTitle) ?></strong>
    của bạn đã bị <strong style="color:red">từ chối</strong>.
</p>

<p>
    <strong>Lý do:</strong><br>
    <?= nl2br(esc($reason)) ?>
</p>

<p>
    Người phản hồi: <strong><?= esc($managerName) ?></strong>
</p>

<p>
    👉 <a href="<?= esc($detailUrl) ?>">Xem chi tiết gói thầu</a>
</p>

<hr>
<p style="font-size:12px;color:#888">
    Email này được gửi tự động từ hệ thống WorkNest.
</p>
</body>
</html>
