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
    private string $folderId;

    /**
     * @throws Exception
     */
    public function __construct()
    {
        // ----------------------------
        // Lấy cấu hình từ ENV
        // ----------------------------
        $clientId     = env("google.client_id");
        $clientSecret = env("google.client_secret");
        $redirectUri  = env("google.redirect_uri");
        $this->folderId = env("drive.folder_id");

        if (!$clientId || !$clientSecret || !$redirectUri) {
            throw new Exception("Thiếu cấu hình google.client_* trong .env");
        }

        if (!$this->folderId) {
            throw new Exception("Thiếu cấu hình drive.folder_id trong .env");
        }

        // ----------------------------
        // Build config JSON thay thế file client_secret.json
        // ----------------------------
        $googleConfig = [
            "web" => [
                "client_id" => $clientId,
                "client_secret" => $clientSecret,
                "redirect_uris" => [$redirectUri],
                "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
                "token_uri" => "https://oauth2.googleapis.com/token",
            ]
        ];

        // ----------------------------
        // Init Google Client
        // ----------------------------
        $this->client = new Google_Client();
        $this->client->setAuthConfig($googleConfig);
        $this->client->setAccessType("offline");
        $this->client->addScope(Google_Service_Drive::DRIVE);

        // ----------------------------
        // Load token.json
        // ----------------------------
        $tokenPath = APPPATH . "ThirdParty/google/token.json";

        if (!file_exists($tokenPath)) {
            throw new Exception("Không tìm thấy token.json");
        }

        $token = json_decode(file_get_contents($tokenPath), true);

        if (!$token) {
            throw new Exception("token.json bị rỗng hoặc lỗi.");
        }

        $this->client->setAccessToken($token);

        // ----------------------------
        // Refresh access token
        // ----------------------------
        if ($this->client->isAccessTokenExpired()) {
            $newToken = $this->client->fetchAccessTokenWithRefreshToken(
                $this->client->getRefreshToken()
            );

            file_put_contents(
                $tokenPath,
                json_encode($this->client->getAccessToken(), JSON_PRETTY_PRINT)
            );
        }

        // ----------------------------
        // Init Google Drive Service
        // ----------------------------
        $this->drive = new Google_Service_Drive($this->client);
    }

    public function getClient(): Google_Client
    {
        return $this->client;
    }

    public function getDrive(): Google_Service_Drive
    {
        return $this->drive;
    }

    // ================================================================
    // UPLOAD FILE THƯỜNG
    // ================================================================
    /**
     * @throws \Google\Service\Exception
     */
    public function uploadFile(string $path, string $name): array
    {
        $meta = new Google_Service_Drive_DriveFile([
            'name'    => $name,
            'parents' => [$this->folderId]
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

    // ================================================================
    // UPLOAD + AUTO CONVERT (DOC/XLS/PPT → Google Docs/Sheets/Slides)
    // ================================================================
    /**
     * @throws \Google\Service\Exception
     * @throws Exception
     */
    public function uploadAndConvert(string $path, string $name): array
    {
        $ext  = strtolower(pathinfo($name, PATHINFO_EXTENSION));
        $mime = mime_content_type($path);

        $googleMime = match ($ext) {
            'doc', 'docx' => "application/vnd.google-apps.document",
            'xls', 'xlsx' => "application/vnd.google-apps.spreadsheet",
            'ppt', 'pptx' => "application/vnd.google-apps.presentation",
            default       => null,
        };

        // Không convert → upload nguyên bản
        if (!$googleMime) {
            if ($ext === 'pdf') {
                throw new Exception("Không được upload file PDF.");
            }

            $uploaded = $this->drive->files->create(
                new Google_Service_Drive_DriveFile([
                    'name'    => $name,
                    'parents' => [$this->folderId]
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
                'drive_id'        => $id,
                'google_file_id'  => $id,
                'view'            => "https://drive.google.com/file/d/{$id}/view",
                'mime'            => $mime,
                'original_id'     => $id,
                'converted'       => false,
            ];
        }

        // ----------------------------
        // Upload file gốc
        // ----------------------------
        $origin = $this->drive->files->create(
            new Google_Service_Drive_DriveFile([
                'name'    => $name,
                'parents' => [$this->folderId],
            ]),
            [
                'data'       => file_get_contents($path),
                'mimeType'   => $mime,
                'uploadType' => 'multipart',
                'fields'     => 'id'
            ]
        );

        $sourceId = $origin->id;

        // ----------------------------
        // Convert
        // ----------------------------
        $converted = $this->drive->files->copy(
            $sourceId,
            new Google_Service_Drive_DriveFile([
                'name'     => "Converted_" . $name,
                'parents'  => [$this->folderId],
                'mimeType' => $googleMime,
            ])
        );

        $convertedId = $converted->id;

        $googleUrl = match ($googleMime) {
            "application/vnd.google-apps.document"
            => "https://docs.google.com/document/d/$convertedId/edit",
            "application/vnd.google-apps.spreadsheet"
            => "https://docs.google.com/spreadsheets/d/$convertedId/edit",
            "application/vnd.google-apps.presentation"
            => "https://docs.google.com/presentation/d/$convertedId/edit",
        };

        return [
            'drive_id'       => $convertedId,
            'google_file_id' => $convertedId,
            'view'           => $googleUrl,
            'mime'           => $googleMime,
            'original_id'    => $sourceId,
            'converted'      => true,
        ];
    }
}
