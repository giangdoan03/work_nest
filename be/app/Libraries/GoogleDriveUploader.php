<?php

namespace App\Libraries;

use Google_Client;
use Google_Service_Drive;
use Google_Service_Docs;
use Google_Service_Sheets;
use Exception;

class GoogleDriveUploader
{
    private Google_Client $client;
    private Google_Service_Drive $drive;
    private Google_Service_Docs $docs;
    private Google_Service_Sheets $sheets;

    private string $folderId;

    /**
     * @throws \Google\Exception
     * @throws Exception
     */
    public function __construct()
    {
        // Load Google Client giống y code bạn gửi
        require_once APPPATH . "ThirdParty/google/config.php";

        $client = getClient();   // LẤY CLIENT CÓ TOKEN TỪ SESSION

        if (!$client->getAccessToken()) {
            throw new Exception("Google OAuth session expired. User must login again.");
        }

        $this->client = $client;

        $this->drive  = new Google_Service_Drive($client);
        $this->docs   = new Google_Service_Docs($client);
        $this->sheets = new Google_Service_Sheets($client);

        // folder chính bạn upload
        $this->folderId = "18z1HuZZgqiCIuVGnAEl-PJOFOGtayGmF";
    }


    /**
     * @throws \Google\Service\Exception
     */
    public function uploadFile(string $tempPath, string $originalName): array
    {
        $ext = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
        $mime = mime_content_type($tempPath);

        // 1) Upload file gốc
        $uploaded = $this->drive->files->create(
            new \Google_Service_Drive_DriveFile([
                'name'    => $originalName,
                'parents' => [$this->folderId]
            ]),
            [
                'data' => file_get_contents($tempPath),
                'mimeType' => $mime,
                'uploadType' => 'multipart'
            ]
        );

        $originalId = $uploaded->id;

        // Nếu không phải office → trả về ngay
        $office = ['doc','docx','xls','xlsx','ppt','pptx'];
        if (!in_array($ext, $office)) {
            return $this->returnFile($uploaded->id, $uploaded->name, "original");
        }

        // 2) Convert sang Docs/Sheets/Slides
        $googleMime = match ($ext) {
            'doc','docx' => "application/vnd.google-apps.document",
            'xls','xlsx' => "application/vnd.google-apps.spreadsheet",
            'ppt','pptx' => "application/vnd.google-apps.presentation",
            default => null
        };

        $converted = $this->drive->files->copy(
            $originalId,
            new \Google_Service_Drive_DriveFile([
                'name'    => "CONVERTED_" . $originalName,
                'parents' => [$this->folderId],
                'mimeType' => $googleMime
            ])
        );

        $convertedId = $converted->id;

        // 3) Export PDF (retry nếu Google chưa convert xong)
        $pdfData = $this->exportPdfWithRetry($convertedId);

        // 4) Upload PDF lên Drive
        $pdfFile = $this->drive->files->create(
            new \Google_Service_Drive_DriveFile([
                'name'    => "PDF_" . pathinfo($originalName, PATHINFO_FILENAME) . ".pdf",
                'parents' => [$this->folderId]
            ]),
            [
                'data' => $pdfData,
                'mimeType' => "application/pdf",
                'uploadType' => 'multipart'
            ]
        );

        return $this->returnFile($pdfFile->id, $pdfFile->name, "pdf");
    }




    private function exportPdfWithRetry(string $fileId): string
    {
        // Giống hệt code bạn gửi
        $maxWait = 12;
        $i = 0;

        while ($i < $maxWait) {
            try {
                $res = $this->drive->files->export(
                    $fileId,
                    "application/pdf",
                    ['alt' => 'media']
                );
                return $res->getBody()->getContents();
            } catch (Exception $e) {
                if (str_contains($e->getMessage(), 'FAILED_PRECONDITION')) {
                    sleep(1);
                    $i++;
                    continue;
                }
                throw $e;
            }
        }

        throw new Exception("Không thể export PDF: Google chưa xử lý xong.");
    }




    private function returnFile(string $fileId, string $fileName, string $type): array
    {
        return [
            'file_name' => $fileName,
            'url'       => "https://drive.google.com/file/d/{$fileId}/view",
            'itemId'    => $fileId,
            'driveId'   => null,
            'type'      => $type,
        ];
    }

    /**
     * Tạo link xem-only giống SharePoint createViewOnlyLink()
     */
    public function createViewOnlyLink(string $driveId, string $fileId, string $scope = 'anonymous'): ?string
    {
        // Google Drive không dùng driveId, chỉ cần fileId
        try {
            // Set permission anyone can view
            $this->drive->permissions->create($fileId, new \Google_Service_Drive_Permission([
                'type' => 'anyone',       // anonymous
                'role' => 'reader'        // view only
            ]));

            // Trả URL view-only
            return "https://drive.google.com/file/d/{$fileId}/view?usp=sharing";

        } catch (\Exception $e) {
            log_message('error', "Create view link error: " . $e->getMessage());
            return null;
        }
    }

}
