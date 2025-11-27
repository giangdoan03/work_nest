<?php
require_once __DIR__ . '/../../../vendor/autoload.php';

/**
 * @throws \Google\Exception
 */
function getClient(): Google_Client
{
    $client = new Google_Client();

    // client_secret.json
    $client->setAuthConfig(__DIR__ . '/client_secret_1017504240479-khuf6h4dedtdf2s0n7q8lac979th42jq.apps.googleusercontent.com.json');

    // Redirect cho lần login đầu tiên
    $client->setRedirectUri(base_url('oauth_callback.php'));

    $client->setScopes([
        Google_Service_Drive::DRIVE,
        Google_Service_Docs::DOCUMENTS,
        Google_Service_Sheets::SPREADSHEETS
    ]);

    $client->setAccessType('offline');
    $client->setPrompt('consent');

    // DÙNG TOKEN.JSON – KHÔNG DÙNG SESSION
    $tokenFile = __DIR__ . '/token.json';

    if (file_exists($tokenFile)) {
        $client->setAccessToken(json_decode(file_get_contents($tokenFile), true));
    }

    return $client;
}
