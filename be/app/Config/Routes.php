<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */


$routes->group('api', function ($routes) {

    $routes->group("documents", function($routes){

        // LIST & CRUD
        $routes->get("/", "DocLibraryController::index");
        $routes->get("by-department", "DocLibraryController::listByDepartment");
        $routes->get("my", "DocLibraryController::listMyDocuments");
        $routes->get("shared-with-me", "DocLibraryController::listShared");

        $routes->get("(:num)", "DocLibraryController::show/$1");
        $routes->post("/", "DocLibraryController::create");
        $routes->put("(:num)", "DocLibraryController::update/$1");
        $routes->delete("(:num)", "DocLibraryController::delete/$1");


        // ACCESS CONTROL
        $routes->post("user-access/add", "DocLibraryController::addUserAccess");
        $routes->post("user-access/remove", "DocLibraryController::removeUserAccess");
        $routes->get("can-access", "DocLibraryController::checkAccess");
    });

    // ⭐ Google OAuth
    $routes->get('google/url', 'GoogleAuth::getUrl');
    $routes->get('google-auth', 'GoogleAuth::redirect');
    $routes->get('google-callback', 'GoogleAuth::callback');
    $routes->get('documents/convert/pdf', 'DocumentController::convertToPdf');
    // ⭐ Replace marker trong Google Docs/Sheets khi user approve
    $routes->post('marker/replace', 'TaskApprovalController::checkAndReplaceMarker');
    $routes->get('documents/drive-pdf-list', 'DocumentController::listPdfFromDrive');
    $routes->post('documents/converted', 'DocumentController::saveConverted');
    $routes->get('documents/converted', 'DocumentController::listConverted');
    $routes->delete('documents/converted/(:num)', 'DocumentController::deleteConverted/$1');
    $routes->post('documents/converted/bulk-delete', 'DocumentController::bulkDelete');

    $routes->post('login', 'Auth::login');
    $routes->get('logout', 'Auth::logout');
    $routes->get('check', 'Auth::check');

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

    $routes->post('users/upload-avatar', 'Auth::uploadAvatar');

    $routes->get('tasks/(:num)/roster',          'TaskApprovalController::roster/$1');
    $routes->post('tasks/(:num)/roster/merge',   'TaskApprovalController::merge/$1');
    $routes->post('tasks/(:num)/roster/approve', 'TaskApprovalController::rosterApprove/$1');
    $routes->post('tasks/(:num)/roster/reject',  'TaskApprovalController::rosterReject/$1');

    // Task Signing
    $routes->post('tasks/sign',                     'TaskSignController::sign');              // auto detect user in session
    $routes->post('tasks/(:num)/sign',              'TaskSignController::signByTask/$1');     // sign by taskId
    $routes->post('tasks/(:num)/sign/user/(:num)',  'TaskSignController::signForUser/$1/$2'); // sign for specific user (FE needs this)
    $routes->get('tasks/(:num)/sign-status',        'TaskSignController::status/$1');
    $routes->get('tasks/(:num)/sign-history',       'TaskSignController::logs/$1');
    $routes->post('tasks/(:num)/sign/upload',       'TaskSignController::uploadSigned/$1');
    $routes->get('tasks/(:num)/sign/download',      'TaskSignController::downloadSigned/$1');

    $routes->get('tasks/(:num)/pinned-files',    'TaskFileController::pinnedByTask/$1');
    $routes->post('task-files/(:num)/pin',       'TaskFileController::pin/$1');
    $routes->post('task-files/(:num)/unpin',     'TaskFileController::unpin/$1');
    $routes->post('tasks/(:num)/files/adopt', 'TaskFileController::adoptFromPath/$1');

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
    $routes->get('tasks/(:num)/comment-files', 'CommentController::filesByTask/$1');
    $routes->post('comments/(:num)/send-approval', 'CommentController::sendApprovalForComment/$1');
    $routes->get('tasks/(:num)/subtasks', 'TaskController::subtasks/$1');
    $routes->post('tasks/(:num)/extend', 'TaskController::extendDeadline/$1');
    $routes->get('tasks/(:num)/extensions/count', 'TaskController::countExtensions/$1');
    $routes->get('tasks/(:num)/extensions', 'TaskController::getExtensions/$1');
    $routes->post('documents/bulk-delete', 'DocumentController::bulkDelete');

    $routes->put('subtasks/(:num)', 'TaskController::updateSubtask/$1');
    $routes->delete('subtasks/(:num)', 'TaskController::deleteSubtask/$1');

    $routes->post('tasks/(:num)/upload-file', 'TaskFileController::upload/$1');
    $routes->get('tasks/(:num)/files', 'TaskFileController::byTask/$1');
    $routes->delete('task-files/(:num)', 'TaskFileController::delete/$1');
    $routes->get('bidding-steps/(:num)/task', 'BiddingStepController::getTaskByBiddingStep/$1');

    // --- Task files: actions trên từng tài liệu ---
    $routes->post('task-files/(:num)/update-meta',  'TaskFileController::updateMeta/$1');
    $routes->post('task-files/(:num)/replace-file', 'TaskFileController::replaceFile/$1');
    $routes->post('task-files/(:num)/approve',      'TaskFileController::approve/$1');
    $routes->post('task-files/(:num)/reject',       'TaskFileController::reject/$1');
    $routes->get('task-files/(:num)/download',      'TaskFileController::download/$1');
    $routes->delete('task-files/(:num)',            'TaskFileController::delete/$1');

    $routes->get('bidding-steps/(:num)/tasks', 'TaskController::byBiddingStep/$1');
    $routes->get('contract-steps/(:num)/tasks', 'TaskController::byContractStep/$1');

    $routes->put('bidding-steps/(:num)/complete', 'BiddingStepController::completeStep/$1');
    $routes->resource('bidding-steps', ['controller' => 'BiddingStepController']);
    $routes->get('biddings/(:num)/steps', 'BiddingStepController::stepsByBidding/$1');
    $routes->get('biddings/(:num)/steps/(:num)', 'BiddingStepController::stepDetail/$1/$2');

    $routes->put('comments/(:num)', 'CommentController::update/$1');
    $routes->delete('comments/(:num)', 'CommentController::delete/$1');

    // Cuối cùng mới khai báo resource
    $routes->resource('tasks', ['controller' => 'TaskController']);

    $routes->get('customers/(:num)/transactions', 'CustomerTransactionController::byCustomer/$1');
    $routes->post('customers/transactions', 'CustomerTransactionController::create');
    $routes->get('customers/(:num)/contracts', 'ContractController::byCustomer/$1');
    $routes->resource('customers', ['controller' => 'CustomerController']);

    // 📌 Phê duyệt gói thầu (multi-level)
    $routes->post('biddings/(:num)/send-approval', 'BiddingController::sendForApproval/$1');
    $routes->post('biddings/(:num)/approve', 'BiddingController::approve/$1');
    $routes->post('biddings/(:num)/reject',  'BiddingController::reject/$1');
    $routes->put('biddings/(:num)/approval-steps', 'BiddingController::updateApprovalSteps/$1');

    // chức năng gói thầu
    $routes->get('biddings/(:num)/can-complete', 'BiddingController::canMarkAsComplete/$1');
    $routes->post('biddings/(:num)/init-steps', 'BiddingStepController::cloneFromTemplates/$1');
    $routes->resource('biddings', ['controller' => 'BiddingController']);
    $routes->resource('bidding-steps', ['controller' => 'BiddingStepController']);
    $routes->get('biddings/(:num)/steps', 'BiddingStepController::byBidding/$1');

    // ✅ Route cấu hình hệ thống tài liệu
    $routes->get('document-settings', 'DocumentController::getSettings');
    $routes->post('document-settings', 'DocumentController::saveSetting');
    $routes->put('document-settings/(:num)', 'DocumentController::updateSetting/$1');
    $routes->delete('document-settings/(:num)', 'DocumentController::deleteSetting/$1');
    $routes->delete('documents/(:num)', 'DocumentController::delete/$1');

    // Settings CRUD
    $routes->get('settings', 'SettingController::index');
    $routes->get('settings/(:num)', 'SettingController::show/$1');
    $routes->get('settings/key/(:segment)', 'SettingController::key/$1');
    $routes->post('settings', 'SettingController::create');
    $routes->put('settings/(:num)', 'SettingController::update/$1');
    $routes->delete('settings/(:num)', 'SettingController::delete/$1');

    $routes->get('contract-step-templates', 'ContractStepTemplateController::index');
    $routes->post('contract-step-templates', 'ContractStepTemplateController::create');
    $routes->put('contract-step-templates/(:num)', 'ContractStepTemplateController::update/$1');
    $routes->delete('contract-step-templates/(:num)', 'ContractStepTemplateController::delete/$1');
    $routes->put('contract-steps/(:num)/complete', 'ContractStepController::complete/$1');

    // Task Approvals
    $routes->get('task-approvals', 'TaskApprovalController::index');
    $routes->post('task-approvals/(:num)/approve', 'TaskApprovalController::approve/$1');
    $routes->post('task-approvals/(:num)/reject',  'TaskApprovalController::reject/$1');

    $routes->get('task-approvals/(:num)/can-act',  'TaskApprovalController::canAct/$1');
    $routes->get('task-approvals/full-status/(:num)', 'TaskApprovalController::fullApprovalStatus/$1');
    $routes->get('tasks/(:num)/approvals',         'TaskApprovalController::history/$1');

    // ✅ Approval (multi-entity) routes
    $routes->group('approvals', static function ($routes) {
        // Lấy trạng thái theo đối tượng (not_sent nếu chưa gửi): ?target_type=&target_id=
        $routes->get('inbox', 'ApprovalInboxController::index');
        $routes->get('/', 'ApprovalController::index');
        $routes->get('list', 'ApprovalController::list');

        // Xem 1 phiên duyệt + các cấp
        $routes->get('(:num)', 'ApprovalController::show/$1');

        // Gửi duyệt (khởi tạo/khởi động phiên active)
        $routes->post('send', 'ApprovalController::send');

        // Duyệt / Từ chối cấp hiện tại
        $routes->post('(:num)/approve', 'ApprovalController::approve/$1');
        $routes->post('(:num)/reject',  'ApprovalController::reject/$1');

        // Cập nhật lại tuyến duyệt (reset steps, giữ phiên)
        $routes->put('(:num)/steps',   'ApprovalController::updateSteps/$1');
        $routes->patch('(:num)/steps', 'ApprovalController::updateSteps/$1');
    });

    $routes->get('my/comments', 'CommentController::inbox');                       // danh sách bình luận liên quan tới tôi
    $routes->get('my/comments/unread-count', 'CommentController::unreadCount');    // đếm chưa đọc
    $routes->post('comments/mark-read', 'CommentController::markReadBatch');       // đánh dấu nhiều cái đã đọc
    $routes->post('comments/(:num)/read', 'CommentController::markRead/$1');       // đánh dấu 1 cái

    // app/Config/Routes.php
    $routes->get('my/approvals', 'ApprovalInboxController::index');            // danh sách
    $routes->get('my/approvals/unread-count', 'ApprovalInboxController::unreadCount');
    $routes->post('approvals/mark-read', 'ApprovalInboxController::markRead');

    $routes->post('documents/upload-file', 'DocumentController::uploadFile');   // multipart
    $routes->post('documents/upload-url',  'DocumentController::uploadFromUrl'); // JSON {url:...}

    $routes->post('documents/upload-to-wp',        'DocumentController::uploadToWordPress');
    $routes->post('documents/upload-remote-to-wp', 'DocumentController::uploadRemoteToWordPress');
    $routes->post('documents/upload',              'DocumentController::upload'); // lưu link vào DB
    $routes->post('documents/upload-link', 'DocumentController::uploadLink'); // ⬅️ mới
    $routes->post('documents/upload-signed',       'DocumentController::uploadSignedPdf');

    // ✅ Route gửi duyệt task
    $routes->post('tasks/(:num)/approvals/send', 'TaskController::sendApproval/$1');

    $routes->get('approval/active-by-target', 'ApprovalController::activeByTarget');
    // Lấy phiên duyệt active theo target (FE đang gọi cái này)
    $routes->get('active-by-target', 'ApprovalController::activeByTarget');

    // Duyệt / Từ chối trực tiếp theo task_id
    $routes->post('tasks/(:num)/approve', 'TaskApprovalController::approveByTask/$1');
    $routes->post('tasks/(:num)/reject',  'TaskApprovalController::rejectByTask/$1');
    $routes->get('documents/(:num)', 'DocumentController::show/$1');
    $routes->get('approvals/active-by-target', 'ApprovalController::activeByTarget');
    $routes->post('documents/signed', 'DocumentController::signed');

    $routes->group('document-sign', function($routes) {

        // Gửi tài liệu đi cho nhiều người ký (tạo các bước)
        $routes->post('send', 'DocumentSignController::send');

        // Danh sách tài liệu người dùng cần ký
        $routes->get('inbox', 'DocumentSignController::inbox');

        // Ký (approve)
        $routes->post('sign', 'DocumentSignController::sign');

        // Từ chối
        $routes->post('reject', 'DocumentSignController::reject');

        // Detail chuỗi ký của một tài liệu
        $routes->get('detail/(:num)', 'DocumentSignController::detail/$1');

        $routes->delete('delete/(:num)', 'DocumentSignController::delete/$1');

    });


    // ✅ WordPress Media Proxy
    $routes->post('wp-media',          'WpMediaController::create');
    $routes->post('wp-media/url',      'WpMediaController::uploadUrl');
    $routes->patch('wp-media/(:num)',  'WpMediaController::update/$1');
    $routes->delete('wp-media/(:num)', 'WpMediaController::delete/$1');

    $routes->post('task-files/upload-signed', 'TaskFileController::uploadSignedPdf');
    $routes->get('file-signatures/(:num)/download', 'TaskFileController::downloadSigned/$1');
    $routes->post('documents/approve', 'TaskFileController::approveOnly');

    // ⭐ ENTITY MEMBER ROUTES
    $routes->post('entity-members/add', 'EntityMemberController::add');
    $routes->post('entity-members/remove', 'EntityMemberController::remove');
    $routes->get('entity-members/list/(:segment)/(:num)', 'EntityMemberController::list/$1/$2');
    $routes->get('entity-members/can-access', 'EntityMemberController::canAccess');

    // CRUD department
    $routes->get('departments', 'DepartmentController::index');
    $routes->get('departments/(:num)', 'DepartmentController::show/$1');
    $routes->post('departments', 'DepartmentController::create');
    $routes->put('departments/(:num)', 'DepartmentController::update/$1');
    $routes->delete('departments/(:num)', 'DepartmentController::delete/$1');

    // CUSTOM routes phải đặt dưới
    $routes->get('departments/(:num)/users', 'DepartmentController::users/$1');
    $routes->post('departments/(:num)/users', 'DepartmentController::addUsers/$1');
    $routes->delete('departments/(:num)/users/(:num)', 'DepartmentController::removeUser/$1/$2');

});
