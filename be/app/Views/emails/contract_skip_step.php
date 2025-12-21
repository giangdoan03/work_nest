<?php
/**
 * @var string $managerName
 * @var string $requester
 * @var int|string $stepNumber
 * @var string $stepTitle
 * @var string|null $reason
 * @var string $approveUrl
 */
?>

<p>Xin chào <strong><?= esc($managerName) ?></strong>,</p>

<p>
    Người dùng <strong><?= esc($requester) ?></strong> đã gửi yêu cầu
    <strong>bỏ qua bước</strong> trong quy trình hợp đồng:
</p>

<ul>
    <li>
        <strong>Bước:</strong>
        <?= esc($stepNumber) ?> - <?= esc($stepTitle) ?>
    </li>

    <?php if (!empty($reason)): ?>
        <li>
            <strong>Lý do:</strong>
            <?= nl2br(esc($reason)) ?>
        </li>
    <?php endif; ?>
</ul>

<p>
    👉 Vui lòng xác nhận tại link bên dưới:
</p>

<p>
    <a href="<?= esc($approveUrl) ?>">
        <?= esc($approveUrl) ?>
    </a>
</p>

<hr>

<p style="font-size:12px;color:#666;">
    Email này được gửi tự động từ hệ thống WorkNest.
</p>
