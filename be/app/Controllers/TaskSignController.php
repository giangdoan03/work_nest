<?php

namespace App\Controllers;

use App\Libraries\GoogleDriveService;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\HTTP\ResponseInterface;
use Google_Service_Drive;
use Google_Service_Docs;
use Google_Service_Sheets;
use Google_Service_Docs_BatchUpdateDocumentRequest;
use Google_Service_Sheets_BatchUpdateSpreadsheetRequest;
use Google_Service_Sheets_BatchUpdateValuesRequest;
use Throwable;

class TaskSignController extends ResourceController
{
    protected $format = 'json';

    /** 🔹 Lấy user_id từ session */
    private function getUserId(): ?int
    {
        return session()->get('user_id');
    }

    /** 🔹 Lấy JSON body */
    private function getJsonBody(): array
    {
        $json = $this->request->getJSON(true);
        if (is_array($json)) return $json;

        $post = $this->request->getPost();
        return is_array($post) ? $post : [];
    }

    /** 🔹 Lấy task row */
    private function getTaskRow(int $taskId): ?array
    {
        return db_connect()->table('tasks')->where('id', $taskId)->get()->getRowArray();
    }

    /** 🔹 Lấy roster */
    private function readRoster(array $task): array
    {
        $json = $task['approval_roster_json'] ?? '[]';
        $arr = json_decode($json, true);
        return is_array($arr) ? $arr : [];
    }

    /** 🔹 Ghi roster */
    private function writeRoster(int $taskId, array $roster): void
    {
        db_connect()->table('tasks')->where('id', $taskId)->update([
            'approval_roster_json' => json_encode(array_values($roster), JSON_UNESCAPED_UNICODE)
        ]);
    }


    // =====================================================================
    //  MAIN ACTION: Ký file
    // =====================================================================

    public function sign(): ResponseInterface
    {
        $body = $this->getJsonBody();
        $taskId = (int) ($body['task_id'] ?? 0);
        $userId = (int) ($body['user_id'] ?? $this->getUserId());

        if (!$taskId || !$userId)
            return $this->fail('Missing task_id or user_id');

        $db = db_connect();

        // 1) Lấy Task
        $task = $this->getTaskRow($taskId);
        if (!$task) return $this->failNotFound("Task not found");

        // 2) Lấy roster
        $roster = $this->readRoster($task);

        // 3) Xác minh quyền ký
        $idx = null;
        foreach ($roster as $i => $r) {
            if ((int)$r['user_id'] === $userId) {
                $idx = $i;
                break;
            }
        }
        if ($idx === null) return $this->failForbidden("Bạn không có trong danh sách ký");

        if (($roster[$idx]['status'] ?? '') !== 'approved')
            return $this->failForbidden("Bạn phải duyệt xong trước khi ký");

        // 4) Lấy marker ký (khác approval_marker)
        $user = $db->table('users')->where('id', $userId)->get()->getRowArray();
        if (!$user) return $this->failNotFound("User not found");

        $signMarker = trim($user['sign_marker'] ?? '');
        if ($signMarker === '')
            return $this->fail("User has no sign_marker");

        // 5) Lấy batch upload
        $latestBatchRow = $db->table('documents')
            ->select('upload_batch')
            ->where('source_task_id', $taskId)
            ->orderBy('upload_batch', 'DESC')
            ->limit(1)
            ->get()
            ->getRowArray();

        if (!$latestBatchRow)
            return $this->fail("No upload batch found");

        $latestBatch = $latestBatchRow['upload_batch'];

        // 6) Lấy file
        $files = $db->table('documents')
            ->where('source_task_id', $taskId)
            ->where('upload_batch', $latestBatch)
            ->orderBy('id', 'ASC')
            ->get()
            ->getResultArray();

        if (!$files)
            return $this->failNotFound("No files found");

        // 7) Ký từng file
        $results = [];
        foreach ($files as $file) {
            $fileId = $file['google_file_id'] ?? null;
            if (!$fileId) {
                $results[] = ['file_name' => $file['title'], 'status' => 'skip_no_google_id'];
                continue;
            }

            try {
                $this->applySignature($fileId, $signMarker);
                $results[] = ['file_name' => $file['title'], 'status' => 'signed'];
            } catch (Throwable $e) {
                $results[] = [
                    'file_name' => $file['title'],
                    'status'    => 'error',
                    'error'     => $e->getMessage()
                ];
            }
        }

        // 8) Cập nhật trạng thái ký trong roster
        $roster[$idx]['signed'] = true;
        $roster[$idx]['signed_at'] = date('Y-m-d H:i:s');
        $this->writeRoster($taskId, $roster);

        return $this->respond([
            'message' => "Signed successfully",
            'results' => $results,
            'signed_at' => $roster[$idx]['signed_at']
        ]);
    }


    // =====================================================================
    //  APPLY SIGNATURE (Docs / Sheets)
    // =====================================================================

    private function applySignature(string $fileId, string $marker): void
    {
        $client = (new GoogleDriveService())->getClient();

        $drive  = new Google_Service_Drive($client);
        $docs   = new Google_Service_Docs($client);
        $sheets = new Google_Service_Sheets($client);

        $file = $drive->files->get($fileId, ['fields' => 'mimeType']);
        $mime = $file->mimeType;

        if ($mime === "application/vnd.google-apps.document") {
            $this->signDocs($docs, $fileId, $marker);
            return;
        }

        if ($mime === "application/vnd.google-apps.spreadsheet") {
            $this->signSheets($sheets, $fileId, $marker);
        }
    }


    private function signDocs($docs, $fileId, string $marker): void
    {
        // Replace marker → ✓
        $docs->documents->batchUpdate($fileId, new Google_Service_Docs_BatchUpdateDocumentRequest([
            "requests" => [
                [
                    "replaceAllText" => [
                        "containsText" => [
                            "text" => $marker,
                            "matchCase" => true
                        ],
                        "replaceText" => "✓"
                    ]
                ]
            ]
        ]));

        // Styling ✓ giống controller duyệt (bold + vàng)
        $doc = $docs->documents->get($fileId);
        $content = $doc->getBody()->getContent();

        $locations = [];
        foreach ($content as $el) {
            if (!isset($el['paragraph']['elements'])) continue;
            foreach ($el['paragraph']['elements'] as $e) {
                if (!isset($e['textRun']['content'])) continue;

                $start = $e['startIndex'];
                $text = $e['textRun']['content'];

                $pos = strpos($text, "✓");
                if ($pos !== false) {
                    $locations[] = [
                        'startIndex' => $start + $pos,
                        'endIndex'   => $start + $pos + 1
                    ];
                }
            }
        }

        if (!$locations) return;

        $reqs = [];
        foreach ($locations as $loc) {
            $reqs[] = [
                "updateTextStyle" => [
                    "range" => $loc,
                    "textStyle" => [
                        "bold" => true,
                        "foregroundColor" => [
                            "color" => ["rgbColor" => ["red" => 1, "green" => 0.85, "blue" => 0]]
                        ]
                    ],
                    "fields" => "bold,foregroundColor"
                ]
            ];
        }

        $docs->documents->batchUpdate($fileId, new Google_Service_Docs_BatchUpdateDocumentRequest([
            "requests" => $reqs
        ]));
    }


    private function signSheets($sheets, $fileId, string $marker): void
    {
        $resp = $sheets->spreadsheets->get($fileId);
        $sheetsList = $resp->getSheets();

        foreach ($sheetsList as $sh) {
            $title = $sh->properties->title;
            $range = "'$title'!A1:Z999";

            $values = $sheets->spreadsheets_values->get($fileId, $range)->getValues() ?? [];
            $valueUpdates = [];
            $styleUpdates = [];

            foreach ($values as $r => $row) {
                foreach ($row as $c => $val) {
                    if (trim($val) === trim($marker)) {

                        $col = $this->col($c + 1);
                        $cellA1 = "'$title'!$col" . ($r + 1);

                        // Replace ✓
                        $valueUpdates[] = [
                            "range" => $cellA1,
                            "values" => [["✓"]]
                        ];

                        // Style
                        $styleUpdates[] = [
                            "repeatCell" => [
                                "range" => [
                                    "sheetId" => $sh->properties->sheetId,
                                    "startRowIndex" => $r,
                                    "endRowIndex" => $r + 1,
                                    "startColumnIndex" => $c,
                                    "endColumnIndex" => $c + 1,
                                ],
                                "cell" => [
                                    "userEnteredFormat" => [
                                        "textFormat" => [
                                            "bold" => true,
                                            "foregroundColor" => [
                                                "red" => 1,
                                                "green" => 0.85,
                                                "blue" => 0,
                                            ]
                                        ]
                                    ]
                                ],
                                "fields" => "userEnteredFormat.textFormat"
                            ]
                        ];
                    }
                }
            }

            // Apply: value
            if ($valueUpdates) {
                $sheets->spreadsheets_values->batchUpdate(
                    $fileId,
                    new Google_Service_Sheets_BatchUpdateValuesRequest([
                        "valueInputOption" => "RAW",
                        "data" => $valueUpdates
                    ])
                );
            }

            // Apply: style
            if ($styleUpdates) {
                $sheets->spreadsheets->batchUpdate(
                    $fileId,
                    new Google_Service_Sheets_BatchUpdateSpreadsheetRequest([
                        "requests" => $styleUpdates
                    ])
                );
            }
        }
    }


    // Utility: convert number → A/B/C
    private function col(int $c): string
    {
        $letter = "";
        while ($c > 0) {
            $mod = ($c - 1) % 26;
            $letter = chr(65 + $mod) . $letter;
            $c = intdiv($c - $mod, 26);
        }
        return $letter;
    }
}
