<?php

namespace App\Controllers;

use App\Libraries\GoogleDriveService;
use CodeIgniter\HTTP\DownloadResponse;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;
use Google\Service\Exception;
use Google\Client;
use Google_Service_Drive;
use Google_Service_Docs;
use Google_Service_Docs_BatchUpdateDocumentRequest;
use Google_Service_Sheets;
use Google_Service_Sheets_BatchUpdateSpreadsheetRequest;
use Google_Service_Sheets_ValueRange;

class TaskSignController extends ResourceController
{
    protected $format = 'json';

    /* =====================================================
     *  🔥 1. API: Ký auto theo user trong session
     * =====================================================*/
    public function sign(): ResponseInterface
    {
        $body = $this->request->getJSON(true);
        $taskId = (int)($body['task_id'] ?? 0);

        if (!$taskId) {
            return $this->fail("Missing task_id");
        }

        $userId = session()->get('user_id');
        if (!$userId) {
            return $this->failUnauthorized("Not logged in");
        }

        return $this->signInternal($taskId, $userId);
    }

    /* =====================================================
     *  🔥 2. API: Ký theo taskId (user = session)
     * =====================================================*/
    public function signByTask($taskId): ResponseInterface
    {
        $userId = session()->get('user_id');
        if (!$userId) return $this->failUnauthorized("Not logged in");

        return $this->signInternal((int)$taskId, $userId);
    }

    /* =====================================================
     *  🔥 3. API: Ký thay user
     * =====================================================*/
    public function signForUser($taskId, $userId): ResponseInterface
    {
        // Chỉ admin mới được ký thay người khác
        $role = (int)session()->get('role_id');
        if (!in_array($role, [1, 2])) {
            return $this->failForbidden("Bạn không có quyền ký thay người khác");
        }

        return $this->signInternal((int)$taskId, (int)$userId);
    }

    /* =====================================================
     *  🔥 CORE: Hàm xử lý ký chính
     * =====================================================*/
    private function signInternal(int $taskId, int $userId): ResponseInterface
    {
        $db = db_connect();

        // 1) Lấy user
        $user = $db->table('users')->where('id', $userId)->get()->getRowArray();
        if (!$user) return $this->failNotFound("User not found");

        $marker = trim($user['preferred_marker'] ?? '');
        if ($marker === '') return $this->fail("User has no preferred_marker");

        $signatureUrl = trim($user['signature_url'] ?? '');
        if (!$signatureUrl) return $this->fail("User has no signature_url");

        // 2) Lấy batch mới nhất
        $batchRow = $db->table('documents')
            ->select('upload_batch')
            ->where('source_task_id', $taskId)
            ->orderBy('upload_batch', 'DESC')
            ->limit(1)->get()->getRowArray();

        $batch = $batchRow['upload_batch'] ?? null;
        if (!$batch) return $this->fail("No upload_batch found for task");

        // 3) Lấy danh sách file của batch
        $files = $db->table('documents')
            ->where('source_task_id', $taskId)
            ->where('upload_batch', $batch)
            ->get()->getResultArray();

        if (!$files) return $this->fail("No documents found");

        $results = [];

        foreach ($files as $f) {
            $fileId = $f['google_file_id'] ?? null;
            if (!$fileId) {
                $results[] = ['file' => $f['title'], 'status' => 'skip_no_google_id'];
                continue;
            }

            try {
                $this->replaceSignature($fileId, $marker, $signatureUrl);

                // Lưu log ký
                $db->table('task_sign_logs')->insert([
                    'task_id' => $taskId,
                    'user_id' => $userId,
                    'file_id' => $f['id'],
                    'google_file_id' => $fileId,
                    'signed_at' => date('Y-m-d H:i:s')
                ]);

                $results[] = ['file' => $f['title'], 'status' => 'signed'];

            } catch (\Throwable $e) {
                $results[] = [
                    'file' => $f['title'],
                    'status' => 'error',
                    'error' => $e->getMessage()
                ];
            }
        }

        return $this->respond([
            'message' => "Signed by {$user['name']}",
            'results' => $results
        ]);
    }

    /* =====================================================
     *  🔥 4. Logic ký Google Docs / Sheets
     * =====================================================*/
    /**
     * @throws Exception
     * @throws \Exception
     */
    private function replaceSignature(string $fileId, string $marker, string $imageUrl): void
    {
        $client = (new GoogleDriveService())->getClient();

        $drive = new Google_Service_Drive($client);
        $docs  = new Google_Service_Docs($client);
        $sheets = new Google_Service_Sheets($client);

        $meta = $drive->files->get($fileId, ['fields' => 'mimeType']);
        $mime = $meta->mimeType;

        if ($mime === "application/vnd.google-apps.document") {
            $this->signDocs($docs, $fileId, $marker, $imageUrl);
            return;
        }

        if ($mime === "application/vnd.google-apps.spreadsheet") {
            $this->signSheets($client, $fileId, $marker, $imageUrl);
            return;
        }

        throw new \Exception("Unsupported file type: $mime");
    }


    /* =====================================================
     *  🔥 4.1 Ký Google Docs
     * =====================================================*/
    /**
     * @throws Exception|\Exception
     */
    private function signDocs($docs, string $fileId, string $marker, string $imageUrl): void
    {
        // 1) Lấy toàn bộ document
        $document = $docs->documents->get($fileId);
        $content = $document->getBody()->getContent();

        $locations = [];

        // 2) Tìm vị trí marker chính xác trong toàn bộ cấu trúc Docs
        foreach ($content as $struct) {

            if (!isset($struct['paragraph']['elements'])) continue;

            foreach ($struct['paragraph']['elements'] as $el) {

                if (!isset($el['textRun']['content'])) continue;

                $text = $el['textRun']['content'];
                $startIndex = $el['startIndex'];

                $pos = strpos($text, $marker);
                if ($pos !== false) {
                    $locations[] = [
                        'start' => $startIndex + $pos,
                        'end' => $startIndex + $pos + strlen($marker)
                    ];
                }
            }
        }

        if (!$locations) {
            throw new \Exception("Marker '$marker' not found in Docs");
        }

        $requests = [];

        foreach ($locations as $loc) {

            // 3) Xoá marker
            $requests[] = [
                "deleteContentRange" => [
                    "range" => [
                        "startIndex" => $loc['start'],
                        "endIndex" => $loc['end']
                    ]
                ]
            ];

            // 4) Chèn ảnh vào vị trí đúng của marker
            $requests[] = [
                "insertInlineImage" => [
                    "uri" => $imageUrl,
                    "location" => [
                        "index" => $loc['start']
                    ],
                    "objectSize" => [
                        "height" => ["magnitude" => 120, "unit" => "PT"],
                        "width" => ["magnitude" => 260, "unit" => "PT"],
                    ]
                ]
            ];
        }

        // 5) Gửi tất cả requests
        $docs->documents->batchUpdate(
            $fileId,
            new Google_Service_Docs_BatchUpdateDocumentRequest(["requests" => $requests])
        );
    }


    /* =====================================================
 * 🔥 Xóa toàn bộ công thức IMAGE / IMPORT* để tránh popup
 * =====================================================*/
    /**
     * @throws Exception
     */
    private function sanitizeSheet(Google_Service_Sheets $sheets, string $fileId, int $sheetId): void
    {
        $requests = [
            [
                "findReplace" => [
                    "find" => "=IMAGE(",
                    "replacement" => "",
                    "matchCase" => false,
                    "searchByRegex" => false,
                    "sheetId" => $sheetId
                ]
            ],
            [
                "findReplace" => [
                    "find" => "=IMPORT",
                    "replacement" => "",
                    "matchCase" => false,
                    "searchByRegex" => false,
                    "sheetId" => $sheetId
                ]
            ]
        ];

        $sheets->spreadsheets->batchUpdate(
            $fileId,
            new Google_Service_Sheets_BatchUpdateSpreadsheetRequest([
                "requests" => $requests
            ])
        );
    }



    /* =====================================================
     *  🔥 4.2 Ký Google Sheets
     * =====================================================*/
    /**
     * @throws Exception
     */
    /* =====================================================
    *  🔥 4.2 Ký Google Sheets (bản FIX 100%)
    * =====================================================*/
    private function signSheets(Client $client, string $fileId, string $marker, string $imageUrl): void

    {
        $sheets = new Google_Service_Sheets($client);
        $spreadsheet = $sheets->spreadsheets->get($fileId);

        foreach ($spreadsheet->getSheets() as $sheet) {

            $title   = $sheet->properties->title;
            $sheetId = $sheet->properties->sheetId;

            // Xóa công thức gây popup
            $this->sanitizeSheet($sheets, $fileId, $sheetId);

            $rows = $sheets->spreadsheets_values
                ->get($fileId, "'$title'!A1:Z999")
                ->getValues() ?? [];

            foreach ($rows as $r => $row) {
                foreach ($row as $c => $value) {

                    if (trim($value) === trim($marker)) {

                        // Xóa marker
                        $a1 = "'$title'!" . $this->col($c + 1) . ($r + 1);
                        $sheets->spreadsheets_values->update(
                            $fileId,
                            $a1,
                            new Google_Service_Sheets_ValueRange(["values" => [[""]]]),
                            ["valueInputOption" => "RAW"]
                        );

                        // Chèn hình
                        $this->insertImageIntoCell(
                            $sheets,
                            $fileId,
                            $title,
                            $r,
                            $c,
                            $imageUrl
                        );
                    }
                }
            }
        }
    }




    /* =====================================================
     *  🔥 Insert image vào đúng giữa ô
     * =====================================================*/
    /**
     * @throws Exception
     */
    /* =====================================================
     *  🔥 Insert image CHUẨN (giống UI) — KHÔNG popup
     * =====================================================*/
    private function insertImageIntoCell(
        Google_Service_Sheets $sheets,
        string $fileId,
        string $sheetTitle,
        int $row,
        int $col,
        string $imageUrl
    ): void
    {
        $a1 = "{$sheetTitle}!" . $this->col($col + 1) . ($row + 1);

        $formula = '=IMAGE("' . $imageUrl . '")';

        $body = new Google_Service_Sheets_ValueRange([
            "values" => [
                [$formula]
            ]
        ]);

        $sheets->spreadsheets_values->update(
            $fileId,
            $a1,
            $body,
            ["valueInputOption" => "USER_ENTERED"]
        );
    }



    /* =====================================================
     *  🔥 Utils: convert column number → A1
     * =====================================================*/
    private function col(int $n): string
    {
        $s = '';
        while ($n > 0) {
            $m = ($n - 1) % 26;
            $s = chr(65 + $m) . $s;
            $n = intdiv($n - $m, 26);
        }
        return $s;
    }

    /* =====================================================
     *  🔥 5. API: GET status ký của task
     * =====================================================*/
    public function status($taskId): ResponseInterface
    {
        $db = db_connect();
        $count = $db->table('task_sign_logs')->where('task_id', $taskId)->countAllResults();

        return $this->respond([
            'task_id' => $taskId,
            'signed_count' => $count,
            'signed' => $count > 0
        ]);
    }

    /* =====================================================
     *  🔥 6. API: GET lịch sử ký
     * =====================================================*/
    public function logs($taskId): ResponseInterface
    {
        $db = db_connect();
        $rows = $db->table('task_sign_logs l')
            ->select('l.*, u.name as user_name, d.title as file_name')
            ->join('users u', 'u.id = l.user_id')
            ->join('documents d', 'd.id = l.file_id')
            ->where('l.task_id', $taskId)
            ->orderBy('l.signed_at', 'DESC')
            ->get()->getResultArray();

        return $this->respond($rows);
    }

    /* =====================================================
     *  🔥 7. Upload PDF đã ký thủ công
     * =====================================================*/
    public function uploadSigned($taskId): ResponseInterface
    {
        $file = $this->request->getFile('file');
        if (!$file || !$file->isValid()) {
            return $this->fail("Invalid upload");
        }

        $newName = $file->getRandomName();
        $file->move(WRITEPATH . "signed_docs", $newName);

        db_connect()->table('tasks')
            ->where('id', $taskId)
            ->update(['signed_pdf' => $newName]);

        return $this->respond(['message' => 'Uploaded', 'file' => $newName]);
    }

    /* =====================================================
     *  🔥 8. Download PDF đã ký thủ công
     * =====================================================*/
    public function downloadSigned($taskId): ResponseInterface|DownloadResponse|null
    {
        $task = db_connect()->table('tasks')
            ->where('id', $taskId)
            ->get()->getRowArray();

        if (!$task || empty($task['signed_pdf'])) {
            return $this->failNotFound("No signed PDF");
        }

        return $this->response->download(
            WRITEPATH . "signed_docs/" . $task['signed_pdf'],
            null
        );
    }
}
