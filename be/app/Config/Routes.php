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

    $routes->get('my-tasks', 'MyTaskController::index');

    // Danh sách hợp đồng của 1 khách hàng
    $routes->get('contracts/by-customer/(:num)', 'CustomerController::contracts/$1');


    // Tổng quan dự án (cho trưởng phòng)
    $routes->get('project-overview', 'ProjectOverviewController::index');  // Tổng hợp theo khách hàng/gói thầu/hợp đồng

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
    $routes->post('contracts/(:num)/clone-from-template', 'ContractStepController::cloneFromTemplate/$1');



    // Contract Step routes
    $routes->get('contracts/(:num)/steps', 'ContractStepController::index/$1');     // Lấy danh sách bước của 1 hợp đồng
    $routes->post('contracts/(:num)/steps', 'ContractStepController::create/$1');   // Tạo bước mới cho hợp đồng
    $routes->post('contracts/(:num)/steps/reorder', 'ContractStepController::reorder/$1');

    $routes->put('contract-steps/(:num)', 'ContractStepController::update/$1');     // Cập nhật bước theo ID
    $routes->delete('contract-steps/(:num)', 'ContractStepController::delete/$1');  // Xoá bước theo ID
    $routes->post('contracts/(:num)/add-steps-from-templates', 'ContractStepController::addStepsFromTemplates/$1');
    $routes->get('contracts/can-complete/(:num)', 'ContractController::canMarkAsComplete/$1');

    $routes->resource('contracts', ['controller' => 'ContractController']);

    // Step template routes
    $routes->get('step-templates', 'StepTemplateController::index');
    $routes->post('step-templates', 'StepTemplateController::create');
    $routes->put('step-templates/(:num)', 'StepTemplateController::update/$1');
    $routes->delete('step-templates/(:num)', 'StepTemplateController::delete/$1');

    $routes->get('tasks/(:num)/approvals', 'TaskApprovalController::history/$1');
    $routes->post('tasks/(:num)/files/link', 'TaskFileController::uploadLink/$1');
    $routes->get('tasks/by-department/(:num)', 'TaskController::byDepartment/$1');

    // 🧩 Comment API cho task — phải đặt TRƯỚC
    $routes->get('tasks/(:num)/comments', 'CommentController::byTask/$1');
    $routes->post('tasks/(:num)/comments', 'CommentController::create/$1');
    $routes->get('tasks/(:num)/subtasks', 'TaskController::subtasks/$1');

    // 📌 Lưu lịch sử gia hạn (nếu cần gọi riêng)
    $routes->post('tasks/(:num)/extend', 'TaskController::extendDeadline/$1');

// 📌 Đếm số lần gia hạn của user hiện tại với task
    $routes->get('tasks/(:num)/extensions/count', 'TaskController::countExtensions/$1');

// 📌 Lấy danh sách các lần đã gia hạn deadline
    $routes->get('tasks/(:num)/extensions', 'TaskController::getExtensions/$1');


    $routes->put('subtasks/(:num)', 'TaskController::updateSubtask/$1');
    $routes->delete('subtasks/(:num)', 'TaskController::deleteSubtask/$1');


    $routes->post('tasks/(:num)/upload-file', 'TaskFileController::upload/$1');
    $routes->get('tasks/(:num)/files', 'TaskFileController::byTask/$1');
    $routes->delete('task-files/(:num)', 'TaskFileController::delete/$1');
    $routes->get('bidding-steps/(:num)/task', 'BiddingStepController::getTaskByBiddingStep/$1');

    $routes->get('bidding-steps/(:num)/tasks', 'TaskController::byBiddingStep/$1');
    $routes->get('contract-steps/(:num)/tasks', 'TaskController::byContractStep/$1');

    $routes->put('bidding-steps/(:num)/complete', 'BiddingStepController::completeStep/$1');
//    $routes->get('bidding-steps/(:num)/tasks', 'BiddingStepController::tasksByStep/$1');
    $routes->resource('bidding-steps', ['controller' => 'BiddingStepController']);

    $routes->put('comments/(:num)', 'CommentController::update/$1');
    $routes->delete('comments/(:num)', 'CommentController::delete/$1');

    // Cuối cùng mới khai báo resource
    $routes->resource('tasks', ['controller' => 'TaskController']);


    $routes->get('customers/(:num)/transactions', 'CustomerTransactionController::byCustomer/$1');
    $routes->post('customers/transactions', 'CustomerTransactionController::create');
    $routes->get('customers/(:num)/contracts', 'ContractController::byCustomer/$1');
    $routes->resource('customers', ['controller' => 'CustomerController']);

    // chức năng gói thầu
    $routes->get('biddings/(:num)/can-complete', 'BiddingController::canMarkAsComplete/$1');
    $routes->post('biddings/(:num)/init-steps', 'BiddingStepController::cloneFromTemplates/$1');
    $routes->resource('biddings', ['controller' => 'BiddingController']);
    $routes->resource('bidding-steps', ['controller' => 'BiddingStepController']);
    $routes->get('biddings/(:num)/steps', 'BiddingStepController::byBidding/$1');
    // 📌 Phê duyệt gói thầu (multi-level)
    $routes->post('biddings/(:num)/send-approval', 'BiddingController::sendForApproval/$1');
    $routes->post('biddings/(:num)/approve', 'BiddingController::approve/$1');
    $routes->post('biddings/(:num)/reject',  'BiddingController::reject/$1');
    $routes->put('biddings/(:num)/approval-steps', 'BiddingController::updateApprovalSteps/$1');


    $routes->get('documents', 'DocumentController::index');
    $routes->post('documents/upload', 'DocumentController::upload');
    $routes->post('documents/share', 'DocumentController::share');
    $routes->get('documents/shared/me', 'DocumentController::sharedWithMe');
    $routes->put('documents/(:num)', 'DocumentController::update/$1');
    $routes->delete('documents/(:num)', 'DocumentController::delete/$1');

    $routes->get('documents/by-department', 'DocumentController::byDepartment');


    $routes->get('document-permissions', 'DocumentController::getPermissions');
    $routes->post('document-permissions', 'DocumentController::createPermission');
    $routes->put('document-permissions/(:num)', 'DocumentController::updatePermission/$1');
    $routes->delete('document-permissions/(:num)', 'DocumentController::deletePermission/$1');

    // ✅ Route cấu hình hệ thống tài liệu
    $routes->get('document-settings', 'DocumentController::getSettings');
    $routes->post('document-settings', 'DocumentController::saveSetting');
    $routes->put('document-settings/(:num)', 'DocumentController::updateSetting/$1');
    $routes->delete('document-settings/(:num)', 'DocumentController::deleteSetting/$1');

    // Settings CRUD
    $routes->get('settings', 'SettingController::index');            // Danh sách setting theo user
    $routes->get('settings/(:num)', 'SettingController::show/$1');   // Chi tiết theo ID
    $routes->get('settings/key/(:segment)', 'SettingController::key/$1');
    $routes->post('settings', 'SettingController::create');          // Tạo mới
    $routes->put('settings/(:num)', 'SettingController::update/$1'); // Cập nhật
    $routes->delete('settings/(:num)', 'SettingController::delete/$1'); // Xoá

    $routes->get('contract-step-templates', 'ContractStepTemplateController::index');
    $routes->post('contract-step-templates', 'ContractStepTemplateController::create');
    $routes->put('contract-step-templates/(:num)', 'ContractStepTemplateController::update/$1');
    $routes->delete('contract-step-templates/(:num)', 'ContractStepTemplateController::delete/$1');
    $routes->put('contract-steps/(:num)/complete', 'ContractStepController::complete/$1');

    // Task Approvals
    $routes->get('task-approvals', 'TaskApprovalController::index'); // ?page, ?limit, ?status=pending|resolved, ?search=
    $routes->post('task-approvals/(:num)/approve', 'TaskApprovalController::approve/$1');
    $routes->post('task-approvals/(:num)/reject',  'TaskApprovalController::reject/$1');

    // ▶️ cần thêm:
    $routes->get('task-approvals/(:num)/can-act',  'TaskApprovalController::canAct/$1');          // check quyền trước khi mở modal
    $routes->get('task-approvals/full-status/(:num)', 'TaskApprovalController::fullApprovalStatus/$1'); // timeline theo cấp
    $routes->get('tasks/(:num)/approvals',         'TaskApprovalController::history/$1');



});
