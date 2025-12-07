<template>
    <div>
        <h2>📌 Hướng dẫn Gói thầu & Hợp đồng</h2>
        <p>
            Module Gói thầu – Hợp đồng giúp quản lý toàn bộ vòng đời dự án từ lúc tạo, xử lý công việc,
            phê duyệt, quản lý tài liệu đến khi hoàn thành và bàn giao.
        </p>

        <!-- 1. Tạo mới -->
        <h3>1. Tạo gói thầu / hợp đồng mới</h3>
        <ul>
            <li>Nhấn nút <b>“Thêm gói thầu mới”</b>.</li>
            <li>Điền đầy đủ thông tin: <b>Tên – Mô tả – Chi phí dự toán – Ngày bắt đầu/kết thúc</b>.</li>
            <li>Chọn <b>Khách hàng – Người quản lý – Người phụ trách</b>.</li>
            <li>Sau khi lưu, hệ thống tự sinh các <b>bước công việc mẫu</b> theo quy trình chuẩn.</li>
        </ul>

        <!-- 2. Tiến độ -->
        <h3>2. Theo dõi tiến độ</h3>
        <ul>
            <li>Tiến độ hiển thị theo % dựa trên số bước đã hoàn thành.</li>
            <li>Click vào thanh tiến độ để mở modal xem chi tiết từng bước.</li>
            <li>Hệ thống tự tính: <b>Ngày còn lại, ngày quá hạn</b>.</li>
            <li>Màu sắc trạng thái:
                <ul>
                    <li><span style="color:#52c41a">🟩 Hoàn thành</span></li>
                    <li><span style="color:#1890ff">🟦 Đang triển khai</span></li>
                    <li><span style="color:#fa8c16">🟧 Chờ duyệt</span></li>
                    <li><span style="color:#ff4d4f">🟥 Quá hạn</span></li>
                </ul>
            </li>
        </ul>

        <!-- 3. Phân quyền -->
        <h3>3. Phân quyền truy cập</h3>
        <ul>
            <li>Nhấn icon <b>👤 người dùng</b> để cấp quyền xem hoặc chỉnh sửa.</li>
            <li>Phân quyền phù hợp theo vai trò:
                <b>Super Admin – Admin – Trưởng phòng – Nhân viên</b>.
            </li>
            <li>Mỗi thành viên chỉ xem được gói thầu/hợp đồng họ có quyền.</li>
        </ul>

        <!-- 4. Phê duyệt -->
        <h3>4. Phê duyệt gói thầu / hợp đồng</h3>
        <ul>
            <li>Chọn danh sách người duyệt theo <b>nhiều cấp</b>.</li>
            <li>Khi cấp trước duyệt xong → tự động chuyển cấp tiếp theo.</li>
            <li>Lưu lại <b>lịch sử phê duyệt</b> để kiểm tra về sau.</li>
            <li>Nếu bị từ chối, người tạo có thể gửi lại quy trình duyệt.</li>
        </ul>

        <!-- 5. Danh sách trạng thái -->
        <h3>5. Danh sách nhanh theo trạng thái</h3>
        <p>Hệ thống phân loại tự động giúp theo dõi tổng quan:</p>
        <ul>
            <li>Trúng thầu / Không trúng</li>
            <li>Quan trọng</li>
            <li>Bình thường</li>
            <li>Quá hạn</li>
        </ul>

        <!-- 6. Tài liệu -->
        <h3>6. Quản lý tài liệu (Word/Excel/PDF)</h3>

        <h4>6.1 Quy định upload tài liệu</h4>
        <ul>
            <li>Chỉ được upload các file gốc dạng: <b>Word (.doc, .docx)</b>, <b>Excel (.xls, .xlsx)</b>.</li>
            <li>Các định dạng khác như PDF, ảnh, ZIP… <b>không được chấp nhận trong bước duyệt</b>.</li>
            <li>Việc này nhằm đảm bảo tài liệu luôn theo đúng <b>mẫu chuẩn của doanh nghiệp</b>.</li>
        </ul>

        <h4>6.2 Lưu lịch sử upload</h4>
        <ul>
            <li>Mỗi lần upload lại một tài liệu, hệ thống sẽ ghi nhận:</li>
            <ul>
                <li>Thời gian upload</li>
                <li>Người upload</li>
                <li>Số lần upload (lần 1, lần 2, lần 3…)</li>
            </ul>
            <li>Giúp truy vết ai chỉnh sửa tài liệu và khi nào.</li>
        </ul>

        <h4>6.3 Quy trình duyệt – chuyển PDF – trình ký</h4>
        <p>Sau khi tài liệu đã được phê duyệt:</p>
        <ul>
            <li>Tài liệu Word/Excel sẽ được yêu cầu <b>chuyển sang PDF</b>.</li>
            <li>Tài liệu PDF dùng để <b>trình ký – đóng dấu</b>.</li>
            <li>Hệ thống có popup lựa chọn:
                <ul>
                    <li><b>Nội bộ</b> – dành cho xử lý trong công ty.</li>
                    <li><b>Phát hành</b> – để trình ký chính thức.</li>
                </ul>
            </li>
            <li>Tất cả file PDF sau khi chuyển đổi được lưu vào tab:
                <b>“Tài liệu PDF”</b>.
            </li>
        </ul>

        <h4>6.4 Hồ sơ trình ký</h4>
        <ul>
            <li>Chỉ file PDF sau duyệt mới được phép trình ký.</li>
            <li>Hệ thống đảm bảo trình tự: <b>Upload → Duyệt → Chuyển PDF → Trình ký</b>.</li>
            <li>Bản trình ký luôn theo đúng mẫu chuẩn của doanh nghiệp.</li>
        </ul>

        <!-- 7. Chi tiết gói thầu -->
        <h3>7. Chi tiết gói thầu / hợp đồng</h3>
        <p>Trang chi tiết thể hiện toàn bộ thông tin chính:</p>
        <ul>
            <li>Thông tin chung: tên, giá trị, khách hàng, người phụ trách…</li>
            <li>Tiến trình xử lý (theo từng bước)</li>
            <li>Danh sách người thực hiện</li>
            <li>Tài liệu liên quan</li>
            <li>Lịch sử phê duyệt</li>
        </ul>
    </div>
</template>

