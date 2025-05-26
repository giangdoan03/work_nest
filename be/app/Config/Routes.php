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

    $routes->resource('categories', ['controller' => 'CategoryController']);
    $routes->resource('persons', ['controller' => 'PersonController']);

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



    $routes->resource('departments', ['controller' => 'DepartmentController']);

    $routes->post('users/upload-avatar', 'Auth::uploadAvatar');

    // Route đặc biệt có hậu tố, phải đặt trước
    $routes->get('contracts/(:num)/step-count', 'ContractController::stepCount/$1');
    $routes->get('contracts/(:num)/steps/details', 'ContractController::stepDetails/$1');
    $routes->post('contracts/(:num)/steps/resequence', 'ContractStepController::resequence/$1');

    $routes->resource('contracts', ['controller' => 'ContractController']);



    // Contract Step routes
    $routes->get('contracts/(:num)/steps', 'ContractStepController::index/$1');     // Lấy danh sách bước của 1 hợp đồng
    $routes->post('contracts/(:num)/steps', 'ContractStepController::create/$1');   // Tạo bước mới cho hợp đồng
    $routes->post('contracts/(:num)/steps/reorder', 'ContractStepController::reorder/$1');

    $routes->put('contract-steps/(:num)', 'ContractStepController::update/$1');     // Cập nhật bước theo ID
    $routes->delete('contract-steps/(:num)', 'ContractStepController::delete/$1');  // Xoá bước theo ID
    $routes->post('contracts/(:num)/add-steps-from-templates', 'ContractStepController::addStepsFromTemplates/$1');


    // Step template routes
    $routes->get('step-templates', 'StepTemplateController::index');
    $routes->post('step-templates', 'StepTemplateController::create');
    $routes->put('step-templates/(:num)', 'StepTemplateController::update/$1');
    $routes->delete('step-templates/(:num)', 'StepTemplateController::delete/$1');



});
