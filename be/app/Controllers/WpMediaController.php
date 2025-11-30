<?php

namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;
use Config\Services;
use Throwable;

class WpMediaController extends ResourceController
{
    protected $format = 'json';

    /** Build a Guzzle-like client via CI Services with Basic Auth headers */
    private function wpClient(): array
    {
        $user = (string) env('WP_USER', '');
        $pass = (string) env('WP_APP_PASSWORD', '');
        if ($user === '' || $pass === '') {
            return [null, 'Thiếu cấu hình WP_USER / WP_APP_PASSWORD.'];
        }

        $client = Services::curlrequest([
            'timeout'     => 60,
            'http_errors' => false,
            'headers'     => [
                'Authorization' => 'Basic ' . base64_encode($user . ':' . $pass),
                'Accept'        => 'application/json',
            ],
        ]);

        return [$client, null];
    }

    private function mediaEndpoint(): string
    {
        $endpoint = (string) env('WP_MEDIA_ENDPOINT', '');
        return rtrim($endpoint, '/');
    }

    private function maxUploadKB(): int
    {
        $kb = (int) env('WP_MAX_UPLOAD_KB', 16384); // 16MB default
        return $kb > 0 ? $kb : 16384;
    }

    /** Upload binary bytes to WordPress /media, return [array $json, string|null $err] */
    private function postToWordPress($client, string $endpoint, string $filename, string $mime, string $binary): array
    {
        $resp = $client->post($endpoint, [
            'headers' => [
                'Content-Type'        => $mime ?: 'application/octet-stream',
                'Content-Disposition' => 'attachment; filename="' . basename($filename) . '"',
            ],
            'body' => $binary,
        ]);

        $code = $resp->getStatusCode();
        $body = (string) $resp->getBody();

        if ($code !== 201) {
            return [null, $body ?: ('WordPress trả mã ' . $code)];
        }

        $json = json_decode($body, true);
        if (!is_array($json)) {
            return [null, 'Phản hồi WordPress không hợp lệ.'];
        }

        return [$json, null];
    }

    /** PATCH /wp/v2/media/{id} to update meta */
    private function patchWpMedia($client, string $endpoint, int $id, array $payload): array
    {
        $url = rtrim($endpoint, '/media') . '/media/' . $id;
        $resp = $client->post($url, [
            'headers' => ['Content-Type' => 'application/json'],
            'body'    => json_encode($payload, JSON_UNESCAPED_UNICODE),
        ]);

        $code = $resp->getStatusCode();
        $body = (string) $resp->getBody();

        if ($code !== 200) {
            return [null, $body ?: ('WordPress trả mã ' . $code)];
        }

        $json = json_decode($body, true);
        if (!is_array($json)) {
            return [null, 'Phản hồi WordPress không hợp lệ.'];
        }

        return [$json, null];
    }

    /** DELETE /wp/v2/media/{id} */
    private function deleteWpMedia($client, string $endpoint, int $id): ?string
    {
        $url = rtrim($endpoint, '/media') . '/media/' . $id . '?force=true';
        $resp = $client->delete($url);

        $code = $resp->getStatusCode();
        if ($code !== 200) {
            return (string) $resp->getBody() ?: ('WordPress trả mã ' . $code);
        }
        return null;
    }

    /** ========= POST /api/wp-media  (form-data: file) ========= */
    public function create(): ResponseInterface
    {
        $endpoint = $this->mediaEndpoint();
        if ($endpoint === '') return $this->failServerError('Thiếu WP_MEDIA_ENDPOINT.');

        [$client, $err] = $this->wpClient();
        if ($err) return $this->failServerError($err);

        // Validate simple file (generic; let WP validate deep)
        $rules = [
            'file' => [
                'label' => 'File',
                'rules' => [
                    'uploaded[file]',
                    'max_size[file,' . $this->maxUploadKB() . ']',
                ],
            ],
        ];
        if (!$this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        $file = $this->request->getFile('file');
        if (!$file || !$file->isValid()) {
            return $this->fail('File không hợp lệ.');
        }

        $filename = $file->getClientName();
        $mime     = $file->getMimeType() ?: 'application/octet-stream';

        try {
            $binary = file_get_contents($file->getTempName());
        } catch (Throwable $e) {
            return $this->failServerError('Không thể đọc file tạm.');
        }

        [$json, $e] = $this->postToWordPress($client, $endpoint, $filename, $mime, $binary);
        if ($e) return $this->failServerError($e);

        return $this->respondCreated([
            'id'         => $json['id'] ?? null,
            'source_url' => $json['source_url'] ?? ($json['guid']['rendered'] ?? null),
            'mime_type'  => $json['mime_type'] ?? null,
            'title'      => $json['title']['rendered'] ?? null,
            'raw'        => $json,
        ]);
    }

    /** ========= POST /api/wp-media/url  (JSON: {url, filename?, title?, alt_text?, caption?}) ========= */
    public function uploadUrl(): ResponseInterface
    {
        $endpoint = $this->mediaEndpoint();
        if ($endpoint === '') return $this->failServerError('Thiếu WP_MEDIA_ENDPOINT.');

        [$client, $err] = $this->wpClient();
        if ($err) return $this->failServerError($err);

        $json = $this->request->getJSON(true) ?: [];
        $url  = $json['url'] ?? null;
        if (!$url || !filter_var($url, FILTER_VALIDATE_URL)) {
            return $this->failValidationErrors('URL không hợp lệ.');
        }

        try {
            $binary = file_get_contents($url);
        } catch (Throwable) {
            return $this->fail('Không thể tải URL nguồn.');
        }

        // detect mime via finfo
        $tmp = tempnam(sys_get_temp_dir(), 'wp_');
        file_put_contents($tmp, $binary);
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime  = finfo_file($finfo, $tmp) ?: 'application/octet-stream';
        finfo_close($finfo);

        $sizeKB = (int) ceil(filesize($tmp) / 1024);
        @unlink($tmp);
        if ($sizeKB > $this->maxUploadKB()) {
            return $this->failValidationErrors('Kích thước vượt giới hạn.');
        }

        $filename = $json['filename'] ?? basename(parse_url($url, PHP_URL_PATH)) ?: ('remote_' . time());
        [$media, $e] = $this->postToWordPress($client, $endpoint, $filename, $mime, $binary);
        if ($e) return $this->failServerError($e);

        // optional: set meta (title/alt/caption)
        $meta = array_filter([
            'title'    => $json['title'] ?? null,
            'alt_text' => $json['alt_text'] ?? null,
            'caption'  => $json['caption'] ?? null,
        ], fn($v) => $v !== null);

        if (!empty($meta) && isset($media['id'])) {
            [$upd, $e2] = $this->patchWpMedia($client, $endpoint, (int) $media['id'], $meta);
            if ($e2) {
                // non-fatal; still return uploaded
            } else {
                $media = $upd;
            }
        }

        return $this->respondCreated([
            'id'         => $media['id'] ?? null,
            'source_url' => $media['source_url'] ?? ($media['guid']['rendered'] ?? null),
            'mime_type'  => $media['mime_type'] ?? null,
            'title'      => $media['title']['rendered'] ?? null,
            'raw'        => $media,
        ]);
    }

    /** ========= PATCH /api/wp-media/{id}  (JSON: {title?, alt_text?, caption?}) ========= */
    public function update($id = null)
    {
        $endpoint = $this->mediaEndpoint();
        if ($endpoint === '') return $this->failServerError('Thiếu WP_MEDIA_ENDPOINT.');

        [$client, $err] = $this->wpClient();
        if ($err) return $this->failServerError($err);

        $payload = $this->request->getJSON(true) ?: [];
        $payload = array_filter([
            'title'    => $payload['title'] ?? null,
            'alt_text' => $payload['alt_text'] ?? null,
            'caption'  => $payload['caption'] ?? null,
        ], fn($v) => $v !== null);

        if (empty($payload)) return $this->failValidationErrors('Không có gì để cập nhật.');

        [$json, $e] = $this->patchWpMedia($client, $endpoint, (int) $id, $payload);
        if ($e) return $this->failServerError($e);

        return $this->respond(['status' => 'updated', 'raw' => $json]);
    }

    /** ========= DELETE /api/wp-media/{id} ========= */
    public function delete($id = null)
    {
        $endpoint = $this->mediaEndpoint();
        if ($endpoint === '') return $this->failServerError('Thiếu WP_MEDIA_ENDPOINT.');

        [$client, $err] = $this->wpClient();
        if ($err) return $this->failServerError($err);

        $e = $this->deleteWpMedia($client, $endpoint, (int) $id);
        if ($e) return $this->failServerError($e);

        return $this->respondDeleted(['status' => 'deleted', 'id' => (int) $id]);
    }
}
