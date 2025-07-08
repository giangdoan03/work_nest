<?php

namespace App\Enums;

final class TaskStatus
{
    public const TODO             = 'todo';               // Việc cần làm
    public const DOING            = 'doing';              // Đang thực hiện
    public const DONE             = 'done';               // Hoàn thành
    public const OVERDUE          = 'overdue';            // Quá hạn
    public const REQUEST_APPROVAL = 'request_approval';   // Đã gửi duyệt

    /**
     * Danh sách tất cả các trạng thái hợp lệ.
     */
    public static function all(): array
    {
        return [
            self::TODO,
            self::DOING,
            self::DONE,
            self::OVERDUE,
            self::REQUEST_APPROVAL,
        ];
    }

    /**
     * Trả nhãn tiếng Việt cho trạng thái.
     */
    public static function label(string $status): string
    {
        return match ($status) {
            self::TODO             => 'Việc cần làm',
            self::DOING            => 'Đang thực hiện',
            self::DONE             => 'Hoàn thành',
            self::OVERDUE          => 'Quá hạn',
            self::REQUEST_APPROVAL => 'Gửi duyệt',
            default                => 'Không xác định',
        };
    }

    /**
     * Màu sắc trạng thái cho frontend (tuỳ chọn).
     */
    public static function color(string $status): string
    {
        return match ($status) {
            self::TODO             => 'warning',
            self::DOING            => 'processing',
            self::DONE             => 'success',
            self::OVERDUE          => 'error',
            self::REQUEST_APPROVAL => 'blue',
            default                => 'default',
        };
    }
}
