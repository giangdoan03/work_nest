<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->post('/login', 'Auth::login');
$routes->get('/check', 'Auth::check');
$routes->get('/logout', 'Auth::logout');

$routes->group('api', function ($routes) {
    $routes->resource('products', ['controller' => 'ProductController']);
    $routes->post('products-import', 'ProductController::import');
    $routes->get('products-export-excel', 'ProductController::exportExcel');
    $routes->get('products-export-pdf', 'ProductController::exportPdf');
    $routes->post('products-restore/(:num)', 'ProductController::restore/$1');
    $routes->post('products-export-selected', 'ProductController::exportSelected');
    $routes->post('products/(:num)/toggle-status', 'ProductController::toggleStatus/$1');

    $routes->resource('categories', ['controller' => 'CategoryController']);
    $routes->resource('businesses', ['controller' => 'BusinessController']);
    $routes->resource('persons', ['controller' => 'PersonController']);
    $routes->resource('events', ['controller' => 'EventController']);
    $routes->resource('stores', ['controller' => 'StoreController']);

    $routes->post('upload', 'UploadController::upload');
    $routes->post('upload-from-url', 'UploadController::uploadFromUrl');

    $routes->get('images/(:segment)/(:num)', 'ImageController::list/$1/$2');
    $routes->get('images/cover/(:segment)/(:num)', 'ImageController::cover/$1/$2');
    $routes->post('images/save/(:num)', 'ImageController::save/$1');

    $routes->get('roles', 'RoleController::index');
    $routes->post('roles/create', 'RoleController::create');
    $routes->post('roles/update/(:num)', 'RoleController::update/$1');
    $routes->post('roles/delete/(:num)', 'RoleController::delete/$1');

    $routes->get('permissions', 'PermissionController::index');
    $routes->post('permissions/save', 'PermissionController::save');
    $routes->get('permissions/matrix', 'PermissionController::matrix');

    $routes->resource('loyalty-programs', ['controller' => 'LoyaltyProgramController']);
    $routes->resource('loyalty-gifts', ['controller' => 'LoyaltyGiftController']);
    $routes->resource('loyalty-vouchers', ['controller' => 'LoyaltyVoucherController']);
    $routes->get('loyalty/participation-history', 'LoyaltyHistoryController::participation');
    $routes->get('loyalty/winning-history', 'LoyaltyHistoryController::winning');

    $routes->resource('landing-pages', ['controller' => 'LandingPageController']);
    $routes->resource('scan-history', ['controller' => 'ScanHistoryController']);
    $routes->resource('customer', ['controller' => 'CustomerController']);
    $routes->resource('setting', ['controller' => 'SettingController']);
    $routes->resource('purchase-history', ['controller' => 'PurchaseHistoryController']);

    // ✅ QR Code Routes (Dùng qr_id dạng chữ + số, không dùng ID số)
    $routes->group('qr-codes', function ($routes) {
        $routes->post('', 'QrCodeController::create');
        $routes->get('list', 'QrCodeController::list');
        $routes->get('scan/(:segment)', 'QrCodeController::scan/$1');
        $routes->get('(:alphanum)', 'QrCodeController::show/$1');
        $routes->put('(:alphanum)', 'QrCodeController::update/$1');
        $routes->delete('(:alphanum)', 'QrCodeController::delete/$1');
    });

    // 1. Truy cập QR gốc → sinh tracking_code → redirect
    $routes->get('(:alphanum)', 'QrCodeController::redirectWithTrack/$1');

// 2. Truy cập sau khi redirect → xử lý tracking + hiển thị
    $routes->get('scan/(:alphanum)', 'QrCodeController::handleScan/$1');

// 3. API chi tiết QR (dành cho frontend gọi)
    $routes->get('qr-codes/detail/(:segment)', 'QrCodeController::detail/$1');

// 4. API tracking thủ công (nếu dùng fetch)
    $routes->post('qr-codes/track', 'QrCodeController::track');



});
