<template>
    <div>
        <h2>📌 Hướng dẫn Module Khách hàng</h2>
        <p>
            Module Khách hàng giúp doanh nghiệp quản lý thông tin đối tác, theo dõi tương tác,
            lưu lịch sử giao dịch và quản lý hợp đồng liên quan.
        </p>

        <!-- 1. Danh sách khách hàng -->
        <h3>1. Danh sách khách hàng</h3>
        <p>Trang danh sách cho phép theo dõi toàn bộ khách hàng với đầy đủ thông tin quan trọng.</p>
        <ul>
            <li>Hiển thị danh sách khách hàng theo bảng.</li>
            <li>Cho phép tìm kiếm theo tên, email, SĐT, nhóm khách hàng.</li>
            <li>Lọc theo ngày tạo, người phụ trách.</li>
            <li>Xem chi tiết – chỉnh sửa – xoá một khách hàng.</li>
            <li>Xuất CSV danh sách khách hàng.</li>
        </ul>

        <!-- 2. Tạo khách hàng -->
        <h3>2. Tạo khách hàng mới</h3>
        <p>Màn hình thêm mới gồm 3 tab: <b>Thông tin</b> – <b>Tương tác</b> – <b>Hợp đồng</b>.</p>

        <h4>2.1. Tab Thông tin</h4>
        <ul>
            <li><b>Tên khách hàng</b>: bắt buộc nhập.</li>
            <li><b>Email</b>, <b>Số điện thoại</b>, <b>Địa chỉ</b>: thông tin liên hệ.</li>
            <li><b>Nhóm khách hàng</b>:
                <ul>
                    <li>Đối tác thường</li>
                    <li>VIP</li>
                    <li>Khác (theo cấu hình)</li>
                </ul>
            </li>
            <li><b>Người phụ trách</b>: nhân viên chịu trách nhiệm quản lý khách hàng.</li>
        </ul>

        <h4>2.2. Tab Tương tác</h4>
        <p>Ghi nhận lịch sử trao đổi với khách hàng:</p>
        <ul>
            <li>Thêm ghi chú cuộc gọi, cuộc họp, email.</li>
            <li>Lưu ngày giờ tương tác.</li>
            <li>Quản lý trạng thái quan hệ khách hàng.</li>
        </ul>

        <h4>2.3. Tab Hợp đồng</h4>
        <p>Liên kết khách hàng với các hợp đồng trong hệ thống.</p>
        <ul>
            <li>Liệt kê tất cả hợp đồng liên quan đến khách hàng.</li>
            <li>Xem trạng thái hợp đồng, người phụ trách, thời hạn.</li>
            <li>Hỗ trợ thêm mới hợp đồng liên quan.</li>
        </ul>

        <!-- 3. Chức năng nâng cao -->
        <h3>3. Các chức năng nâng cao</h3>
        <ul>
            <li><b>Nhật ký hoạt động</b>: Theo dõi ai đã sửa, tạo hoặc xoá khách hàng.</li>
        </ul>

        <!-- 4. Quy trình làm việc -->
        <h3>4. Quy trình thao tác chuẩn</h3>
        <ol>
            <li>Vào menu <b>Khách hàng</b>.</li>
            <li>Sử dụng bộ lọc để tìm khách hàng nhanh.</li>
            <li>Nhấn <b>Thêm khách hàng</b> để tạo mới.</li>
            <li>Điền đầy đủ thông tin liên hệ – chọn người phụ trách.</li>
            <li>Bổ sung tương tác, thêm hợp đồng liên quan.</li>
            <li>Xem và quản lý chi tiết trong màn hình chi tiết khách hàng.</li>
        </ol>

    </div>
</template>
