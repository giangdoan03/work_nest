<?php

namespace App\Libraries;

use Config\Services;
use Exception;

class SharepointUploader
{
    private string $clientId;
    private string $clientSecret;
    private string $tenantId;

    private string $graph = "https://graph.microsoft.com/v1.0";
    private string $tokenUrl;

    public function __construct()
    {
        $this->clientId     = env('SP_CLIENT_ID');
        $this->clientSecret = env('SP_CLIENT_SECRET');
        $this->tenantId     = env('SP_TENANT_ID');

        $this->tokenUrl     = "https://login.microsoftonline.com/{$this->tenantId}/oauth2/v2.0/token";
    }

    /* ==========================================================
       GET ACCESS TOKEN
    ========================================================== */
    /**
     * @throws Exception
     */
    private function getToken(): string
    {
        $client = Services::curlrequest([
            'http_errors' => false,
            'timeout' => 30,
        ]);

        $response = $client->post($this->tokenUrl, [
            'form_params' => [
                'client_id'     => $this->clientId,
                'client_secret' => $this->clientSecret,
                'scope'         => 'https://graph.microsoft.com/.default',
                'grant_type'    => 'client_credentials',
            ],
        ]);

        $json = json_decode($response->getBody(), true);

        if (!isset($json['access_token'])) {
            throw new Exception("Cannot obtain SharePoint token: " . json_encode($json));
        }

        return $json['access_token'];
    }

    /* ==========================================================
       HTTP WRAPPER for Graph API
    ========================================================== */
    private function graph(string $method, string $url, string $token, $body = null, array $headers = []): array
    {
        $client = Services::curlrequest([
            'http_errors'     => false,
            'timeout'         => 60,
            'allow_redirects' => true,
        ]);

        $opts = [
            'headers' => array_merge([
                'Authorization' => "Bearer {$token}",
            ], $headers),
        ];

        if ($body !== null) {
            $opts['body'] = $body;
        }

        $response = $client->request($method, $url, $opts);

        return [
            'http' => $response->getStatusCode(),
            'body' => $response->getBody(),
            'json' => json_decode($response->getBody(), true),
        ];
    }

    /* ==========================================================
       GET SITE ID (root)
    ========================================================== */
    /**
     * @throws Exception
     */
    private function getSiteId(string $token): string
    {
        $res = $this->graph("GET", "{$this->graph}/sites/root", $token);

        if (empty($res['json']['id'])) {
            throw new Exception("Cannot get siteId: " . json_encode($res));
        }

        return $res['json']['id'];
    }

    /* ==========================================================
       GET DOCUMENT LIBRARY DRIVE ID
    ========================================================== */
    /**
     * @throws Exception
     */
    private function getDocumentsDrive(string $token, string $siteId): string
    {
        $res = $this->graph("GET", "{$this->graph}/sites/{$siteId}/drives", $token);

        if (!isset($res['json']['value'])) {
            throw new Exception("Cannot get drive list: " . json_encode($res));
        }

        foreach ($res['json']['value'] as $d) {
            if (($d['driveType'] ?? '') === 'documentLibrary') {
                return $d['id'];
            }
        }

        throw new Exception("No SharePoint documentLibrary drive found.");
    }

    /* ==========================================================
       CREATE VIEW-ONLY LINK FOR EVERYONE
       (muốn ngoài tổ chức cũng xem được -> scope=anonymous,
        chỉ nội bộ -> scope=organization)
    ========================================================== */
    /**
     * @throws Exception
     */
    public function createViewOnlyLink(string $driveId, string $itemId, string $scope = 'anonymous'): ?string
    {
        $token = $this->getToken();

        // dùng type = 'view' cho link đọc-only.
        // Nếu bạn muốn thử chặn download mạnh hơn, có thể test type='blocksDownload'
        // trên endpoint beta, nhưng ở đây mình dùng v1.0 cho ổn định.
        $body = json_encode([
            'type'  => 'view',
            'scope' => $scope, // 'anonymous' | 'organization' | 'users'
        ]);

        $res = $this->graph(
            'POST',
            "{$this->graph}/drives/{$driveId}/items/{$itemId}/createLink",
            $token,
            $body,
            ['Content-Type' => 'application/json']
        );

        if ($res['http'] >= 300) {
            throw new Exception("createLink failed: " . json_encode($res));
        }

        return $res['json']['link']['webUrl'] ?? null;
    }

    /* ==========================================================
       UPLOAD FILE + (OPTIONAL) AUTO PDF CONVERT
    ========================================================== */
    /**
     * Upload file lên thư viện Documents của site root.
     * Trả về: file_name, url (webUrl gốc của item), driveId, itemId, type
     *
     * @throws Exception
     */
    public function uploadFile(string $tempPath, string $originalName): array
    {
        $ext      = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
        $nameBase = pathinfo($originalName, PATHINFO_FILENAME);
        $stamp    = time();

        $uniqueName = $nameBase . "_" . $stamp . "." . $ext;
        $fileContent = file_get_contents($tempPath);

        $token  = $this->getToken();
        $siteId = $this->getSiteId($token);
        $driveId = $this->getDocumentsDrive($token, $siteId);

        /* ========= UPLOAD ORIGINAL FILE ========= */
        $folder = rawurlencode('Shared Documents');

        $upload = $this->graph(
            "PUT",
            "{$this->graph}/drives/{$driveId}/root:/{$folder}/" . rawurlencode($uniqueName) . ":/content",
            $token,
            $fileContent,
            ['Content-Type' => 'application/octet-stream']
        );

        if ($upload['http'] >= 300 || empty($upload['json']['id'])) {
            throw new Exception("Upload failed: " . json_encode($upload));
        }

        $itemId = $upload['json']['id'];
        $webUrl = $upload['json']['webUrl'] ?? null;

        /* ========= AUTO PDF CONVERT (Word/Excel/PPT) ========= */
        if (in_array($ext, ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'], true)) {

            $pdf = $this->graph(
                "GET",
                "{$this->graph}/drives/{$driveId}/items/{$itemId}/content?format=pdf",
                $token
            );

            if ($pdf['http'] === 200) {
                $pdfName = "{$nameBase}_{$stamp}.pdf";

                $pdfSave = $this->graph(
                    "PUT",
                    "{$this->graph}/drives/{$driveId}/root:/" . rawurlencode($pdfName) . ":/content",
                    $token,
                    $pdf['body'],
                    ['Content-Type' => 'application/pdf']
                );

                if ($pdfSave['http'] < 300 && !empty($pdfSave['json']['id'])) {
                    // Nếu cần dùng file PDF làm bản ký/duyệt thì trả về nó
                    return [
                        'file_name' => $pdfName,
                        'url'       => $pdfSave['json']['webUrl'] ?? null,
                        'driveId'   => $driveId,
                        'itemId'    => $pdfSave['json']['id'],
                        'type'      => 'pdf',
                    ];
                }
            }

            // nếu convert fail, fallback bản gốc
        }

        /* ========= NON-OFFICE / FALLBACK ========= */
        return [
            'file_name' => $uniqueName,
            'url'       => $webUrl,
            'driveId'   => $driveId,
            'itemId'    => $itemId,
            'type'      => 'original',
        ];
    }
}
