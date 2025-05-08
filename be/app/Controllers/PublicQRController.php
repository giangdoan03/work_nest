<?php

namespace App\Controllers;

use CodeIgniter\Controller;

class PublicQRController extends Controller
{
    public function show($qrId)
    {
        return view('public_qr_detail', ['qrId' => $qrId]);
    }
}
