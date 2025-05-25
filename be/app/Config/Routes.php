<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */


$routes->group('api', function ($routes) {
    $routes->post('login', 'Auth::login');
    $routes->get('logout', 'Auth::logout');
    $routes->get('check', 'Auth::check');

    // ➕ CRUD API
    $routes->post('users', 'Auth::create');            // Thêm mới
    $routes->get('users', 'Auth::index');              // Danh sách
    $routes->get('users/(:num)', 'Auth::show/$1');     // Xem chi tiết
    $routes->put('users/(:num)', 'Auth::update/$1');   // Cập nhật
    $routes->delete('users/(:num)', 'Auth::delete/$1');// Xoá

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


    $routes->resource('departments', ['controller' => 'DepartmentController']);

    $routes->post('users/upload-avatar', 'Auth::uploadAvatar');



});
