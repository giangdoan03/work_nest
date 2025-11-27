<?php
require_once __DIR__ . '/../vendor/autoload.php';

session_start();

// Load config
require_once __DIR__ . '/../app/ThirdParty/google/config.php';

$client = getClient();

// Google trả về code
if (!isset($_GET['code'])) {
    exit("Missing Google OAuth code");
}

$token = $client->fetchAccessTokenWithAuthCode($_GET['code']);

if (isset($token['error'])) {
    exit("Google OAuth error: " . $token['error_description']);
}

// Lưu token.json
file_put_contents(
    __DIR__ . '/../app/ThirdParty/google/token.json',
    json_encode($token)
);

// OK
echo "<h2>Google connected successfully!</h2>";
echo "<p>Token saved. You can close this tab.</p>";
