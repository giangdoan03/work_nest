<?php
require 'vendor/autoload.php';
session_start();

/**
 * @throws \Google\Exception
 */
function getClient(): Google_Client
{
    $client = new Google_Client();
    $client->setAuthConfig(__DIR__ . '/client_secret_...json');

    $client->setRedirectUri('http://localhost/upload_drive/oauth_callback.php');

    $client->setScopes([
        Google_Service_Drive::DRIVE,
        Google_Service_Docs::DOCUMENTS,
        Google_Service_Sheets::SPREADSHEETS
    ]);

    $client->setAccessType('offline');
    $client->setPrompt('consent');

    if (isset($_SESSION['access_token'])) {
        $client->setAccessToken($_SESSION['access_token']);
    }

    return $client;
}
