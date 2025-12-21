<?php
/**
 * @var string $managerName
 * @var string $requester
 * @var string|int $stepNumber
 * @var string $stepTitle
 * @var string|null $reason
 * @var string $approveUrl
 */
?>

<p>Xin chào <strong><?= esc($managerName) ?></strong>,</p>

<p>
    Người dùng <strong><?= esc($requester) ?></strong> đã gửi yêu cầu
    <b>bỏ qua bước</b> trong quy trình đấu thầu:
</p>

<ul>
    <li><b>Bước:</b> <?= esc($stepNumber) ?> - <?= esc($stepTitle) ?></li>
    <?php if (!empty($reason)): ?>
        <li><b>Lý do:</b> <?= esc($reason) ?></li>
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

<p>
    Trân trọng,<br>
    <b>WorkNest System</b>
</p>
