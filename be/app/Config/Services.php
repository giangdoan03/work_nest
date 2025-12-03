<?php

namespace Config;

use App\Services\TaskSnapshotObserver;
use App\Services\TaskSnapshotService;
use CodeIgniter\Config\BaseService;

class Services extends BaseService
{
    /**
     * Task Snapshot Service
     */
    public static function taskSnapshot($getShared = true): object
    {
        if ($getShared) {
            return static::getSharedInstance('taskSnapshot');
        }

        return new TaskSnapshotService();
    }

    /**
     * Task Snapshot Observer – dùng để gửi mail khi roster thay đổi
     */
    public static function taskSnapshotObserver($getShared = true): object
    {
        if ($getShared) {
            return static::getSharedInstance('taskSnapshotObserver');
        }

        return new TaskSnapshotObserver();
    }
}
