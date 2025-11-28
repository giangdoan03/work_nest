<?php

namespace App\Libraries;

use Google\Client as Google_Client;
use Google\Exception;
use Google\Service\Drive as Google_Service_Drive;
use Google\Service\Drive\DriveFile as Google_Service_Drive_DriveFile;

class GoogleDriveService
{
    private Google_Client $client;
    private Google_Service_Drive $drive;

    /**
     * @throws Exception
     */
    public function __construct()
    {
        $secretFile = APPPATH . "ThirdParty/google/client_secret_1017504240479-khuf6h4dedtdf2s0n7q8lac979th42jq.apps.googleusercontent.com.json";
        $tokenPath  = APPPATH . "ThirdParty/google/token.json";

        if (!file_exists($secretFile)) {
            throw new Exception("Không tìm thấy file client_secret.json");
        }
        if (!file_exists($tokenPath)) {
            throw new Exception("Không tìm thấy token.json trong ThirdParty/google/");
        }

        // 1. Init Client
        $this->client = new Google_Client();
        $this->client->setAuthConfig($secretFile);
        $this->client->setAccessType("offline");
        $this->client->addScope(Google_Service_Drive::DRIVE);

        // 2. Load token
        $token = json_decode(file_get_contents($tokenPath), true);
        if (!$token) {
            throw new Exception("token.json bị rỗng hoặc lỗi.");
        }

        $this->client->setAccessToken($token);

        // 3. Refresh token nếu hết hạn
        if ($this->client->isAccessTokenExpired()) {
            $newToken = $this->client->fetchAccessTokenWithRefreshToken(
                $this->client->getRefreshToken()
            );

            file_put_contents(
                $tokenPath,
                json_encode($this->client->getAccessToken(), JSON_PRETTY_PRINT)
            );
        }

        // 4. Khởi tạo Google Drive API
        $this->drive = new Google_Service_Drive($this->client);
    }

    /** ------------------------------------------------------------------
     *  PUBLIC GETTERS
     * ------------------------------------------------------------------ */
    public function getClient(): Google_Client
    {
        return $this->client;
    }

    public function getDrive(): Google_Service_Drive
    {
        return $this->drive;
    }

    /** ------------------------------------------------------------------
     * 1) UPLOAD FILE LÊN GOOGLE DRIVE (KHÔNG CONVERT)
     * ------------------------------------------------------------------
     * @throws \Google\Service\Exception
     */
    public function uploadFile(string $path, string $name): array
    {
        $folderId = "18z1HuZZgqiCIuVGnAEl-PJOFOGtayGmF";

        $meta = new Google_Service_Drive_DriveFile([
            'name'    => $name,
            'parents' => [$folderId]
        ]);

        $file = $this->drive->files->create(
            $meta,
            [
                'data'       => file_get_contents($path),
                'uploadType' => 'multipart',
                'fields'     => 'id, webViewLink'
            ]
        );

        return [
            'drive_id' => $file->id,
            'view_url' => $file->webViewLink,
        ];
    }


    /** ------------------------------------------------------------------
     * 2) UPLOAD + AUTO CONVERT WORD / EXCEL → GOOGLE DOCS / SHEETS
     * ------------------------------------------------------------------
     * @throws \Google\Service\Exception|Exception
     */
    public function uploadAndConvert(string $path, string $name): array
    {
        $folderId = "18z1HuZZgqiCIuVGnAEl-PJOFOGtayGmF";

        $ext  = strtolower(pathinfo($name, PATHINFO_EXTENSION));
        $mime = mime_content_type($path);

        // Các loại file Google hỗ trợ convert
        $googleMime = match ($ext) {
            "doc", "docx" => "application/vnd.google-apps.document",
            "xls", "xlsx" => "application/vnd.google-apps.spreadsheet",
            "ppt", "pptx" => "application/vnd.google-apps.presentation",
            default       => null,
        };

        /* ============================================================
         * 1) Nếu file KHÔNG convert được → upload gốc, không convert
         * ============================================================ */
        if (!$googleMime) {

            // 🚫 Chặn PDF nếu bạn muốn
            if ($ext === 'pdf') {
                throw new Exception("Không được upload file PDF.");
            }

            // Upload file gốc lên Drive
            $uploaded = $this->drive->files->create(
                new Google_Service_Drive_DriveFile([
                    'name'    => $name,
                    'parents' => [$folderId]
                ]),
                [
                    'data'       => file_get_contents($path),
                    'mimeType'   => $mime,
                    'uploadType' => 'multipart',
                    'fields'     => 'id'
                ]
            );

            $id = $uploaded->id;

            return [
                'drive_id'   => $id,
                'google_file_id' => $id,
                'view'       => "https://drive.google.com/file/d/{$id}/view",
                'mime'       => $mime,
                'original_id'=> $id,
                'converted'  => false,
            ];
        }

        /* ============================================================
         * 2) NGƯỢC LẠI → convert DOC/XLS/PPT sang Google file
         * ============================================================ */

        // ---- Upload file gốc ----
        $origin = $this->drive->files->create(
            new Google_Service_Drive_DriveFile([
                'name'    => $name,
                'parents' => [$folderId],
            ]),
            [
                'data'       => file_get_contents($path),
                'mimeType'   => $mime,
                'uploadType' => 'multipart',
                'fields'     => 'id'
            ]
        );

        $sourceId = $origin->id;

        // ---- Convert bằng copy() ----
        $converted = $this->drive->files->copy(
            $sourceId,
            new Google_Service_Drive_DriveFile([
                'name'     => "Converted_" . $name,
                'parents'  => [$folderId],
                'mimeType' => $googleMime,
            ])
        );

        $convertedId = $converted->id;

        // ---- URL viewer ----
        $googleUrl = match ($googleMime) {
            "application/vnd.google-apps.document"
            => "https://docs.google.com/document/d/$convertedId/edit",
            "application/vnd.google-apps.spreadsheet"
            => "https://docs.google.com/spreadsheets/d/$convertedId/edit",
            "application/vnd.google-apps.presentation"
            => "https://docs.google.com/presentation/d/$convertedId/edit",
        };

        return [
            'drive_id'        => $convertedId,
            'google_file_id'  => $convertedId,
            'view'            => $googleUrl,
            'mime'            => $googleMime,
            'original_id'     => $sourceId,
            'converted'       => true,
        ];
    }


}
