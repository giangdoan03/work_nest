<?php

namespace App\Libraries;
use App\Models\TaskFileModel;

class Uploader
{
    public static function saveFile($file, string $type = 'default'): ?array
    {
        if (!$file || !$file->isValid()) {
            return null;
        }

        switch ($type) {
            case 'avatar':
                $uploadDir = getenv('UPLOAD_PATH_AVATAR') ?: 'C:/laragon/www/work_nest/assets/avatars/';
                $baseUrl   = getenv('AVATAR_BASE_URL') ?: 'http://assets.worknest.local/avatars/';
                break;

            case 'file':
                $uploadDir = getenv('UPLOAD_PATH_FILES') ?: 'C:/laragon/www/work_nest/assets/files/';
                $baseUrl   = getenv('FILES_BASE_URL') ?: 'http://assets.worknest.local/files/';
                break;

            default:
                $uploadDir = getenv('UPLOAD_DIR') ?: 'C:/laragon/www/work_nest/assets/image/';
                $baseUrl   = getenv('ASSETS_DOMAIN') ?: 'http://assets.worknest.local/image/';
                break;
        }

        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        $newName = $file->getRandomName();
        $file->move($uploadDir, $newName);

        return [
            'file_name' => $file->getClientName(),
            'file_path' => rtrim($baseUrl, '/') . '/' . $newName,
        ];
    }

    /**
     * Upload file và lưu vào bảng task_files
     */
    public static function saveTaskAttachment($file, int $taskId, int $userId): bool
    {
        $result = self::saveFile($file, 'file');
        if (!$result) {
            return false;
        }

        $fileModel = new TaskFileModel();
        return $fileModel->insert([
            'task_id'     => $taskId,
            'file_name'   => $result['file_name'],
            'file_path'   => $result['file_path'],
            'uploaded_by' => $userId,
        ]);
    }


    public static function saveFromUrl(string $url): ?array
    {
        if (!filter_var($url, FILTER_VALIDATE_URL)) {
            return null;
        }

        try {
            $content = file_get_contents($url);
        } catch (\Exception $e) {
            return null;
        }

        $pathInfo = pathinfo($url);
        $extension = strtolower($pathInfo['extension'] ?? 'jpg');
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

        if (!in_array($extension, $allowedExtensions)) {
            return null;
        }

        $filename = uniqid() . '.' . $extension;

        $uploadDir = getenv('UPLOAD_DIR') ?: 'C:/laragon/www/work_nest/image/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        file_put_contents($uploadDir . $filename, $content);

        $publicUrl = rtrim(getenv('ASSETS_DOMAIN') ?: 'http://assets.worknest.local/image/', '/') . '/' . $filename;

        return [
            'file_name' => basename($pathInfo['basename'] ?? $filename),
            'file_path' => $publicUrl,
        ];
    }
}
