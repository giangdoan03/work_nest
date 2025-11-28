<?php

// Tự định nghĩa ROOTPATH khi chạy ngoài CI4
if (!defined('ROOTPATH')) {
    define('ROOTPATH', dirname(__DIR__) . DIRECTORY_SEPARATOR);
}

// Tự định nghĩa APPPATH
if (!defined('APPPATH')) {
    define('APPPATH', ROOTPATH . 'app' . DIRECTORY_SEPARATOR);
}

require_once ROOTPATH . 'vendor/autoload.php';
require_once APPPATH . 'ThirdParty/google/config.php';

$client = getClient();

if (!isset($_GET['code'])) {
    exit("Missing Google OAuth code");
}

$token = $client->fetchAccessTokenWithAuthCode($_GET['code']);

if (isset($token['error'])) {
    exit("OAuth Error: " . $token['error_description']);
}

// Lưu token
file_put_contents(APPPATH . 'ThirdParty/google/token.json', json_encode($token));

echo "Google Connected Successfully! Token saved.";
