<?php

namespace App\Controllers;

use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class UploadController extends ResourceController
{
    public function upload(): ResponseInterface
    {
        // Giới hạn chỉ upload từ domain api.giang.test
        $allowedOrigins = [
            'http://worknest.local',   // Frontend đang chạy local
            'http://api.worknest.local'     // API chính
        ];

        $origin = $_SERVER['HTTP_ORIGIN'] ?? null;

        if ($origin && !in_array($origin, $allowedOrigins)) {
            return $this->failForbidden('Không được phép upload từ domain này.');
        }

        $file = $this->request->getFile('file');

        if (!$file || !$file->isValid()) {
            return $this->fail('Không tìm thấy file hoặc file không hợp lệ.');
        }

        // ✅ Lấy upload dir từ .env, fallback mặc định nếu chưa khai báo
        $customUploadDir = getenv('UPLOAD_DIR') ?: 'C:/laragon/www/work_nest/assets/image/';
        if (!is_dir($customUploadDir)) {
            mkdir($customUploadDir, 0777, true);
        }

        $newName = $file->getRandomName();
        $file->move($customUploadDir, $newName);

        // ✅ Lấy domain ảnh public từ .env
        $assetsDomain = getenv('ASSETS_DOMAIN') ?: 'http://assets.worknest.local/image/';
        $publicUrl = rtrim($assetsDomain, '/') . '/' . $newName;

        return $this->respond([
            'url' => $publicUrl
        ]);
    }

    public function uploadFromUrl(): ResponseInterface
    {
        $url = $this->request->getJSON()->url ?? null;

        if (!$url || !filter_var($url, FILTER_VALIDATE_URL)) {
            return $this->fail('URL không hợp lệ.');
        }

        // Lấy nội dung file từ URL
        try {
            $imageContents = file_get_contents($url);
        } catch (\Exception $e) {
            return $this->fail('Không thể tải ảnh từ URL.');
        }

        // Tạo tên file ngẫu nhiên
        $pathInfo = pathinfo($url);
        $extension = isset($pathInfo['extension']) ? strtolower($pathInfo['extension']) : 'jpg';
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

        if (!in_array($extension, $allowedExtensions)) {
            return $this->fail('Định dạng file không được hỗ trợ.');
        }

        $filename = uniqid() . '.' . $extension;

        // Lưu file
        $uploadDir = getenv('UPLOAD_DIR') ?: 'C:/laragon/www/work_nest/assets/image/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        file_put_contents($uploadDir . $filename, $imageContents);

        // Trả về URL công khai
        $publicUrl = rtrim(getenv('ASSETS_DOMAIN') ?: 'http://assets.giang.test/image/', '/') . '/' . $filename;

        return $this->respond([
            'url' => $publicUrl
        ]);
    }

}
