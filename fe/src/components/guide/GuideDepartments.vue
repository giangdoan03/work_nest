<template>
    <div class="guide">

        <h2>🏢 Hướng dẫn sử dụng mô-đun Phòng ban</h2>

        <p>
            Mô-đun <b>Phòng ban</b> giúp quản lý danh sách các bộ phận trong doanh nghiệp.
            Tại đây, bạn có thể xem, tạo mới, chỉnh sửa và xem thông tin người dùng thuộc phòng ban.
        </p>

        <!-- 1. Danh sách -->
        <h3>1. Danh sách phòng ban</h3>
        <p>Màn hình danh sách hiển thị các thông tin:</p>
        <ul>
            <li>STT</li>
            <li>Tên phòng ban</li>
            <li>Mô tả chức năng</li>
            <li>Thời gian tạo</li>
            <li>Cập nhật gần nhất</li>
            <li>Hành động (⋮)</li>
        </ul>

        <p>Các chức năng trên danh sách:</p>
        <ul>
            <li>Tìm kiếm phòng ban theo tên/mô tả</li>
            <li>Thay đổi cách hiển thị bằng nút Gọn – Vừa – Rộng</li>
            <li>Phân trang kết quả</li>
            <li>Thêm phòng ban mới</li>
            <li>Xem chi tiết, chỉnh sửa hoặc xoá phòng ban</li>
        </ul>

        <!-- 2. Tạo mới -->
        <h3>2. Tạo phòng ban mới</h3>
        <p>Khi bấm <b>“+ Thêm phòng ban mới”</b>, hệ thống mở popup với 2 tab.</p>

        <b>Thông tin trong tab “Thông tin”:</b>
        <ul>
            <li><b>Tên phòng ban</b> – bắt buộc nhập</li>
            <li><b>Mô tả</b> – mô tả chức năng/ nhiệm vụ của phòng</li>
        </ul>

        <p>Người dùng có thể bấm <b>Hủy</b> hoặc <b>Thêm mới</b>.</p>

        <!-- 3. Người dùng -->
        <h3>3. Người dùng trong phòng ban</h3>
        <p>Trong tab <b>Người dùng</b> của popup chi tiết phòng ban, hệ thống hiển thị:</p>

        <ul>
            <li>STT</li>
            <li>Họ tên nhân viên</li>
            <li>Email</li>
            <li>Số điện thoại</li>
            <li>Vai trò</li>
        </ul>

        <p>
            Tab này cho phép xem danh sách người dùng đang thuộc phòng ban.
        </p>

        <!-- 4. Hành động -->
        <h3>4. Các hành động trên phòng ban</h3>
        <ul>
            <li><b>Xem chi tiết</b> – xem thông tin và danh sách người dùng</li>
            <li><b>Chỉnh sửa</b> – cập nhật tên và mô tả</li>
            <li><b>Xóa</b> – xóa phòng ban khỏi hệ thống</li>
        </ul>

    </div>
</template>
