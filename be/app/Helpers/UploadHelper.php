<?php

namespace App\Helpers;

class UploadHelper
{
    public static function uploadDocumentFile($request)
    {
        $file = $request->getFile('file');

        if (!$file || !$file->isValid()) {
            return ['error' => 'File không hợp lệ'];
        }

        $absoluteUploadPath = getenv('DOCUMENT_UPLOAD_DIR') ?: 'C:/laragon/www/work_nest/assets/documents/';
        $assetsDomain = getenv('DOCUMENT_ASSETS_DOMAIN') ?: 'http://assets.worknest.local/documents/';
        $relativePath = 'documents/';

        if (!is_dir($absoluteUploadPath)) {
            mkdir($absoluteUploadPath, 0777, true);
        }

        $newName = $file->getRandomName();
        $file->move($absoluteUploadPath, $newName);

        return [
            'file_path' => $relativePath . $newName,
            'file_type' => $file->getClientMimeType(),
            'file_size' => $file->getSize(),
            'url'       => rtrim($assetsDomain, '/') . '/' . $newName
        ];
    }
}
