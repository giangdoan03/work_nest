<?php

namespace App\Controllers;

use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\Files\File;

class UploadController extends ResourceController
{
    // Giới hạn dung lượng (KB). Có thể đưa vào .env nếu muốn.
    protected int $maxUploadKB = 4096; // 4MB

    /**
     * POST /upload
     * - multipart/form-data
     * - field name: "file"
     */
    public function upload(): ResponseInterface
    {
        // 1) Validate theo chuẩn CI4
        $rules = [
            'file' => [
                'label' => 'File',
                'rules' => [
                    'uploaded[file]',
                    "max_size[file,{$this->maxUploadKB}]",
                    'is_image[file]',
                    'mime_in[file,image/jpg,image/jpeg,image/png,image/gif,image/webp]',
                    'ext_in[file,jpg,jpeg,png,gif,webp]',
                ],
            ],
        ];
        if (! $this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        // 2) Lấy file và kiểm tra hợp lệ
        $file = $this->request->getFile('file');
        if (! $file || ! $file->isValid()) {
            return $this->fail('File không hợp lệ hoặc không tồn tại.');
        }

        // 3) Thư mục đích: public/uploads
        $targetDir = rtrim(FCPATH, '/\\') . DIRECTORY_SEPARATOR . 'uploads';
        if (! is_dir($targetDir) && ! mkdir($targetDir, 0777, true)) {
            return $this->failServerError('Không thể tạo thư mục uploads.');
        }

        // 4) Đặt tên ngẫu nhiên & move (chuẩn CI4)
        $newName = $file->getRandomName();
        try {
            $file->move($targetDir, $newName);
        } catch (\Throwable $e) {
            return $this->failServerError('Upload thất bại: ' . $e->getMessage());
        }

        // ✅ Đọc MIME/size từ file ĐÃ LƯU (không dùng $file nữa)
        $savedPath = $targetDir . DIRECTORY_SEPARATOR . $newName;
        $saved     = new File($savedPath);
        $mime      = $saved->getMimeType();
        $size      = $saved->getSize();

        // 5) URL công khai cùng domain app
        $publicUrl = base_url('uploads/' . $newName);

        return $this->respondCreated([
            'url'  => $publicUrl,
            'name' => $newName,
            'size' => $size,  // bytes
            'mime' => $mime,  // mime detect
        ]);
    }

    /**
     * POST /upload/url
     * - application/json { "url": "https://..." }
     * - Tải ảnh từ URL rồi lưu vào public/uploads
     */
    public function uploadFromUrl(): ResponseInterface
    {
        $json = $this->request->getJSON(true) ?: [];
        $url  = $json['url'] ?? null;

        if (! $url || ! filter_var($url, FILTER_VALIDATE_URL)) {
            return $this->fail('URL không hợp lệ.');
        }

        // 1) Tải bằng curlrequest (service CI4)
        $client = service('curlrequest', [
            'timeout' => 10,
            'verify'  => false, // nếu local/self-signed. Trên prod nên đặt true.
        ]);

        try {
            $resp = $client->get($url);
            if ($resp->getStatusCode() >= 400) {
                return $this->fail('Không thể tải ảnh từ URL.');
            }
            $binary = $resp->getBody();
        } catch (\Throwable $e) {
            return $this->fail('Lỗi tải URL: ' . $e->getMessage());
        }

        // 2) Kiểm tra MIME thực tế (an toàn hơn dựa vào extension)
        $tmpDir = rtrim(WRITEPATH, '/\\') . DIRECTORY_SEPARATOR . 'uploads';
        if (! is_dir($tmpDir) && ! mkdir($tmpDir, 0777, true)) {
            return $this->failServerError('Không thể tạo thư mục tạm.');
        }

        $tmpPath = tempnam($tmpDir, 'urlimg_');
        if ($tmpPath === false) {
            return $this->failServerError('Không thể tạo file tạm.');
        }
        file_put_contents($tmpPath, $binary);

        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime  = finfo_file($finfo, $tmpPath) ?: 'application/octet-stream';
        finfo_close($finfo);

        $allowed = [
            'image/jpeg' => 'jpg',
            'image/png'  => 'png',
            'image/gif'  => 'gif',
            'image/webp' => 'webp',
        ];
        if (! isset($allowed[$mime])) {
            @unlink($tmpPath);
            return $this->fail('Định dạng không được hỗ trợ.');
        }

        // 3) Giới hạn kích thước
        $sizeKB = (int) ceil(filesize($tmpPath) / 1024);
        if ($sizeKB > $this->maxUploadKB) {
            @unlink($tmpPath);
            return $this->failValidationErrors(['file' => 'Kích thước vượt quá giới hạn.']);
        }

        // 4) Move về public/uploads với tên ngẫu nhiên
        $targetDir = rtrim(FCPATH, '/\\') . DIRECTORY_SEPARATOR . 'uploads';
        if (! is_dir($targetDir) && ! mkdir($targetDir, 0777, true)) {
            @unlink($tmpPath);
            return $this->failServerError('Không thể tạo thư mục uploads.');
        }

        $newName = uniqid('', true) . '.' . $allowed[$mime];

        try {
            // Dùng CodeIgniter\Files\File để move “đúng chuẩn”
            $file = new File($tmpPath);
            $file->move($targetDir, $newName, true);
        } catch (\Throwable $e) {
            @unlink($tmpPath);
            return $this->failServerError('Lưu file thất bại: ' . $e->getMessage());
        }

        $publicUrl = base_url('uploads/' . $newName);

        return $this->respondCreated([
            'url'  => $publicUrl,
            'name' => $newName,
            'mime' => $mime,
            'size' => $sizeKB * 1024, // bytes
        ]);
    }
}
