<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use CodeIgniter\HTTP\ResponseInterface;
use Google_Client;

class GoogleAuth extends BaseController
{
    public function redirect(): ResponseInterface
    {
        $client = new Google_Client();
        $client->setClientId(env('google.client_id'));
        $client->setClientSecret(env('google.client_secret'));
        $client->setRedirectUri(env('google.redirect_uri'));
        $client->setAccessType('offline');
        $client->setPrompt('consent');
        $client->setScopes([
            'https://www.googleapis.com/auth/drive',
            'https://www.googleapis.com/auth/documents',
            'https://www.googleapis.com/auth/spreadsheets',
        ]);

        $url = $client->createAuthUrl();

        return $this->response->setJSON([
            'auth_url' => $url
        ]);
    }

    public function callback()
    {
        $code = $this->request->getGet('code');

        if (!$code) {
            return $this->response->setJSON(['error' => 'No code'])->setStatusCode(400);
        }

        $client = new Google_Client();
        $client->setClientId(env('google.client_id'));
        $client->setClientSecret(env('google.client_secret'));
        $client->setRedirectUri(env('google.redirect_uri'));

        $token = $client->fetchAccessTokenWithAuthCode($code);

        // Lưu token vào DB hoặc session
        session()->set('google_token', $token);

        return $this->response->setJSON([
            'message' => 'OK',
            'token'   => $token
        ]);
    }
}
