<template>
    <div>
        <h2>📌 Hướng dẫn Quản lý Tài liệu</h2>
        <p>
            Module Tài liệu cho phép lưu trữ và chia sẻ tài liệu nội bộ thông qua <b>đường dẫn (URL)</b>.
            Tài liệu không được upload lên hệ thống mà được liên kết từ các nền tảng lưu trữ như:
            Google Drive, OneDrive, SharePoint, máy chủ nội bộ…
        </p>

        <!-- 1. Thêm tài liệu -->
        <h3>1. Thêm tài liệu mới</h3>
        <ul>
            <li>Nhấn nút <b>“+ Thêm tài liệu”</b>.</li>
            <li>Nhập thông tin:
                <ul>
                    <li><b>Tiêu đề</b> – tên tài liệu</li>
                    <li><b>Link tài liệu</b> – đường dẫn đến file</li>
                    <li><b>Phòng ban</b> – nơi quản lý hoặc sở hữu tài liệu</li>
                </ul>
            </li>
            <li>Hệ thống không lưu file, chỉ lưu lại đường dẫn do bạn cung cấp.</li>
            <li>Người dùng chỉ cần click vào link để mở tài liệu.</li>
        </ul>

        <!-- 2. Chia sẻ tài liệu -->
        <h3>2. Phân quyền xem tài liệu</h3>
        <p>Mỗi tài liệu có thể được chia sẻ cho nhiều người.</p>

        <ul>
            <li>Mở modal <b>“Chia sẻ tài liệu”</b>.</li>
            <li>Chọn người được phép xem tài liệu.</li>
            <li>Số lượng người đang được chia sẻ sẽ được hiển thị rõ ràng.</li>
            <li>Người được cấp quyền sẽ thấy tài liệu trong mục <b>Tài liệu của tôi</b>.</li>
        </ul>

        <!-- 3. Chi tiết tài liệu -->
        <h3>3. Trang Chi tiết tài liệu</h3>
        <ul>
            <li>Hiển thị các thông tin:
                <ul>
                    <li>Phòng ban quản lý</li>
                    <li>Người tạo</li>
                    <li>Ngày tạo</li>
                    <li>Số người được cấp quyền</li>
                </ul>
            </li>
            <li>Danh sách avatar người được chia sẻ.</li>
            <li>Nút <b>Mở tab mới</b> để mở tài liệu từ đường link.</li>
        </ul>

        <!-- 4. Cập nhật link tài liệu -->
        <h3>4. Cập nhật tài liệu (thay đổi link)</h3>
        <ul>
            <li>Khi tài liệu thay đổi vị trí, bạn có thể mở chức năng <b>Chỉnh sửa</b>.</li>
            <li>Cập nhật đường dẫn mới.</li>
            <li>Không có lưu phiên bản vì hệ thống không quản lý file nội dung.</li>
        </ul>

        <!-- 5. Tài liệu của tôi -->
        <h3>5. Mục “Tài liệu của tôi”</h3>
        <ul>
            <li>Hiển thị danh sách tài liệu mà người dùng có quyền xem.</li>
            <li>Cho phép tìm kiếm theo tiêu đề.</li>
            <li>Hiển thị avatar của những người cũng được chia sẻ cùng tài liệu.</li>
        </ul>

        <!-- 6. Tìm kiếm & bộ lọc -->
        <h3>6. Tìm kiếm & bộ lọc</h3>
        <ul>
            <li>Tìm nhanh theo tên tài liệu.</li>
            <li>Lọc theo phòng ban.</li>
            <li>Lọc theo thời gian tạo tài liệu.</li>
        </ul>

        <!-- 7. Xóa tài liệu -->
        <h3>7. Xóa tài liệu</h3>
        <ul>
            <li>Chỉ người tạo tài liệu hoặc admin mới có quyền xóa.</li>
            <li>Khi xóa, tài liệu sẽ bị loại khỏi danh sách nhưng đường link gốc vẫn tồn tại.</li>
        </ul>
    </div>
</template>
