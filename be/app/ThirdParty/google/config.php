<?php

require_once ROOTPATH . 'vendor/autoload.php';

/**
 * @throws \Google\Exception
 */
function getClient(): Google_Client
{
    $client = new Google_Client();

    $client->setAuthConfig(APPPATH . 'ThirdParty/google/client_secret_1017504240479-khuf6h4dedtdf2s0n7q8lac979th42jq.apps.googleusercontent.com.json');
    $client->setRedirectUri('http://localhost/work_nest/be/public/oauth_callback.php');

    $client->setScopes([
        Google_Service_Drive::DRIVE,
        Google_Service_Docs::DOCUMENTS,
        Google_Service_Sheets::SPREADSHEETS
    ]);

    $client->setAccessType('offline');
    $client->setIncludeGrantedScopes(true);

    $tokenFile = APPPATH . 'ThirdParty/google/token.json';

    if (file_exists($tokenFile)) {
        $client->setAccessToken(json_decode(file_get_contents($tokenFile), true));

        if ($client->isAccessTokenExpired() && $client->getRefreshToken()) {
            $client->fetchAccessTokenWithRefreshToken($client->getRefreshToken());
            file_put_contents($tokenFile, json_encode($client->getAccessToken()));
        }
    }

    return $client;
}
