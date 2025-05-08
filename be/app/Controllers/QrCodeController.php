<?php
namespace App\Controllers;

use App\Controllers\BaseController;
use App\Models\{QrCodeModel, QrScanLogModel};
use CodeIgniter\API\ResponseTrait;
use CodeIgniter\HTTP\ResponseInterface;

class QrCodeController extends BaseController
{
    use ResponseTrait;
    protected QrCodeModel $model;

    public function __construct()
    {
        $this->model = new QrCodeModel();
    }

    /**
     * Tạo QR Code mới
     */
    public function create(): ResponseInterface
    {
        $data = $this->request->getJSON(true);

        if (empty($data['short_code'])) {
            $data['short_code'] = bin2hex(random_bytes(4));
        }

        if (empty($data['qr_id'])) {
            do {
                $data['qr_id'] = bin2hex(random_bytes(4));
            } while ($this->model->where('qr_id', $data['qr_id'])->first());
        }

        if (isset($data['settings_json']) && is_array($data['settings_json'])) {
            $data['settings_json'] = json_encode($data['settings_json']);
        }

        if (!$this->model->insert($data)) {
            log_message('error', 'QR Insert Failed: ' . json_encode($data));
            return $this->fail($this->model->errors());
        }

        return $this->respondCreated([
            'id' => $this->model->getInsertID(),
            'qr_id' => $data['qr_id'],
            'short_code' => $data['short_code']
        ]);
    }

    /**
     * Cập nhật QR Code
     */
    public function update(string $qr_id): ResponseInterface
    {
        $data = $this->request->getJSON(true);

        if (isset($data['settings_json']) && is_array($data['settings_json'])) {
            $data['settings_json'] = json_encode($data['settings_json']);
        }

        $qr = $this->model->where('qr_id', $qr_id)->first();
        if (!$qr) {
            return $this->failNotFound('Không tìm thấy mã QR');
        }

        if (!$this->model->update($qr['id'], $data)) {
            return $this->fail($this->model->errors());
        }

        return $this->respondUpdated(['qr_id' => $qr_id]);
    }

    /**
     * Xoá QR Code
     */
    public function delete(string $qr_id): ResponseInterface
    {
        $qr = $this->model->where('qr_id', $qr_id)->first();
        if (!$qr) {
            return $this->failNotFound('Không tìm thấy mã QR');
        }

        if (!$this->model->delete($qr['id'])) {
            return $this->fail('Không xoá được mã QR');
        }

        return $this->respondDeleted(['qr_id' => $qr_id]);
    }

    /**
     * Lấy chi tiết 1 QR Code
     */
    public function show($qr_id): ResponseInterface
    {
        $qr = $this->model->where('qr_id', $qr_id)->first();
        if (!$qr) return $this->failNotFound('Không tìm thấy mã QR');
        $qr['settings_json'] = json_decode($qr['settings_json'], true);
        return $this->respond(['data' => $qr]);
    }

    /**
     * Quét QR và chuyển hướng có tracking
     */
    public function scan($trackingCode): ResponseInterface
    {
        $qrId = $this->request->getGet('code');
        if (!$qrId) {
            return redirect()->to('/not-found');
        }

        $qr = $this->model->where('qr_id', $qrId)->first();
        if (!$qr || !$qr['is_active']) {
            return redirect()->to('/not-found');
        }

        // Redirect về trang hiển thị QR với qr_id
        return redirect()->to(base_url("/" . $qrId));
    }


    /**
     * Danh sách QR Code theo user, filter
     */
    public function list(): ResponseInterface
    {
        $userId = $this->request->getGet('user_id');
        $search = $this->request->getGet('search');
        $type = $this->request->getGet('type');

        $builder = $this->model;

        if ($userId) {
            $builder = $builder->where('user_id', $userId);
        }

        if ($search) {
            $builder = $builder->groupStart()
                ->like('qr_name', $search)
                ->orLike('qr_url', $search)
                ->groupEnd();
        }

        if ($type) {
            $builder = $builder->where('target_type', $type);
        }

        $data = $builder->orderBy('created_at', 'DESC')->findAll();

        foreach ($data as &$item) {
            $item['target_name'] = '';

            if ($item['target_type'] === 'product') {
                $product = model('ProductModel')->find($item['target_id']);
                $item['target_name'] = $product['name'] ?? '';
            } elseif ($item['target_type'] === 'store') {
                $store = model('StoreModel')->find($item['target_id']);
                $item['target_name'] = $store['name'] ?? '';
            } elseif ($item['target_type'] === 'event') {
                $event = model('EventModel')->find($item['target_id']);
                $item['target_name'] = $event['name'] ?? '';
            }
        }

        return $this->respond($data);
    }

    public function detail(string $qr_id): ResponseInterface
    {
        $qr = $this->model->where('qr_id', $qr_id)->first();

        // Nếu không tìm thấy QR, trả về dữ liệu rỗng kèm thông báo
        if (!$qr) {
            return $this->respond([
                'qr' => null,
                'target' => null,
                'message' => 'QR không tồn tại'
            ]);
        }

        $target = null;
        switch ($qr['target_type']) {
            case 'product':
                $target = model('ProductModel')->find($qr['target_id']);
                break;
            case 'store':
                $target = model('StoreModel')->find($qr['target_id']);
                break;
            case 'event':
                $target = model('EventModel')->find($qr['target_id']);
                break;
        }

        return $this->respond([
            'qr' => $qr,
            'target' => $target,
            'message' => 'Thành công'
        ]);
    }

    public function track(): ResponseInterface
    {
        $data = $this->request->getJSON(true);

        $qrId = $data['code'] ?? null;
        $track = $data['track'] ?? null;
        $shortCode = $data['short_code'] ?? null;
        $qrUrl = $data['qr_url'] ?? null;
        $type = $data['type'] ?? null;
        $targetId = $data['target_id'] ?? null;
        $phone = $data['phone_number'] ?? null;
        $scanSource = $data['scan_source'] ?? null;

        if (!$qrId || !$track) {
            return $this->failValidationErrors('Thiếu qr_id hoặc tracking_code');
        }

        // Get IP, User Agent
        $ip = $this->request->getIPAddress();
        $userAgent = (string) $this->request->getUserAgent();
        $referer = $_SERVER['HTTP_REFERER'] ?? null;

        // Detect browser, OS, device
        $browser = $this->detectBrowser($userAgent);
        $os = $this->detectOS($userAgent);
        $device = $this->detectDevice($userAgent);

        if ($ip === '127.0.0.1' || $ip === '::1') {
            $country = $city = $latitude = $longitude = 1;
        } else {
            $geoData = $this->getGeoFromIP($ip);
            $country   = $geoData['country'] ?? null;
            $city      = $geoData['city'] ?? null;
            $latitude  = $geoData['lat'] ?? null;
            $longitude = $geoData['lon'] ?? null;
        }


        // is_unique = true nếu tracking_code là duy nhất cho qr_id
        $existing = model('QrScanLogModel')
            ->where('qr_id', $qrId)
            ->where('tracking_code', $track)
            ->first();

        $isUnique = $existing ? 0 : 1;

        model('QrScanLogModel')->insert([
            'qr_id'         => $qrId,
            'tracking_code' => $track,
            'short_code'    => $shortCode,
            'qr_url'        => $qrUrl,
            'type'          => $type,
            'target_id'     => $targetId,
            'user_agent'    => $userAgent,
            'os'            => $os,
            'browser'       => $browser,
            'device_type'   => $device,
            'ip_address'    => $ip,
            'referer'       => $referer,
            'scan_source'   => $scanSource,
            'is_unique'     => $isUnique,
            'country'       => $country,
            'city'          => $city,
            'latitude'      => $latitude,
            'longitude'     => $longitude,
            'phone_number'  => $phone,
            'created_at'    => date('Y-m-d H:i:s')
        ]);

        return $this->respond(['status' => 'success', 'message' => 'Đã ghi tracking']);
    }


    private function getGeoFromIP(string $ip): array
    {
        try {
            $response = file_get_contents("http://ip-api.com/json/{$ip}?fields=status,country,city,lat,lon");
            $data = json_decode($response, true);

            if ($data && $data['status'] === 'success') {
                return $data;
            }
        } catch (\Throwable $e) {
            log_message('error', 'Geo IP lookup failed: ' . $e->getMessage());
        }

        return [];
    }



    private function detectBrowser(string $userAgent): string
    {
        if (strpos($userAgent, 'Chrome') !== false) return 'Chrome';
        if (strpos($userAgent, 'Firefox') !== false) return 'Firefox';
        if (strpos($userAgent, 'Safari') !== false && strpos($userAgent, 'Chrome') === false) return 'Safari';
        if (strpos($userAgent, 'Edge') !== false) return 'Edge';
        if (strpos($userAgent, 'MSIE') !== false || strpos($userAgent, 'Trident') !== false) return 'Internet Explorer';
        return 'Khác';
    }

    private function detectOS(string $userAgent): string
    {
        if (preg_match('/windows/i', $userAgent)) return 'Windows';
        if (preg_match('/macintosh|mac os x/i', $userAgent)) return 'Mac OS';
        if (preg_match('/linux/i', $userAgent)) return 'Linux';
        if (preg_match('/android/i', $userAgent)) return 'Android';
        if (preg_match('/iphone|ipad|ipod/i', $userAgent)) return 'iOS';
        return 'Khác';
    }

    private function detectDevice(string $userAgent): string
    {
        if (preg_match('/mobile/i', $userAgent)) return 'Mobile';
        if (preg_match('/tablet/i', $userAgent)) return 'Tablet';
        return 'Desktop';
    }

    public function redirectWithTrack($shortCode)
    {
        $link = model('QrLinkModel')->where('short_code', $shortCode)->first();
        if (!$link) {
            return redirect()->to('/404');
        }

        $trackCode = bin2hex(random_bytes(4)); // mã track động

        return redirect()->to("/scan/{$trackCode}?type=scan&code={$shortCode}");
    }

    public function handleScan($trackCode)
    {
        $shortCode = $this->request->getGet('code');
        if (!$shortCode) {
            return redirect()->to('/404');
        }

        $link = model('QrLinkModel')->where('short_code', $shortCode)->first();
        if (!$link) {
            return redirect()->to('/404');
        }

        // Ghi tracking log
        $logModel = new \App\Models\QrScanLogModel();
        $logModel->insert([
            'qr_id'         => $link['qr_id'],
            'tracking_code' => $trackCode,
            'ip_address'    => $this->request->getIPAddress(),
            'user_agent'    => (string) $this->request->getUserAgent(),
            'referer'       => $_SERVER['HTTP_REFERER'] ?? null,
            'browser'       => $this->detectBrowser((string) $this->request->getUserAgent()),
            'os'            => $this->detectOS((string) $this->request->getUserAgent()),
            'device_type'   => $this->detectDevice((string) $this->request->getUserAgent()),
            'created_at'    => date('Y-m-d H:i:s'),
        ]);

        // Lấy dữ liệu QR để hiển thị
        $qr = $this->model->where('qr_id', $link['qr_id'])->first();
        if (!$qr) {
            return redirect()->to('/404');
        }

        return view('qr/scan_detail', ['qr' => $qr]); // có thể thay bằng API JSON nếu dùng Vue
    }








}
