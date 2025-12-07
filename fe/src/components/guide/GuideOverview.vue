<template>
    <div>
        <h2>📌 Tổng quan hệ thống</h2>
        <p>
            Màn hình Tổng quan giúp người dùng nắm bắt nhanh tình hình công việc, hoạt động của phòng ban,
            gói thầu – hợp đồng và trạng thái xử lý trong toàn hệ thống.
        </p>

        <!-- SIDEBAR -->
        <h3>1. Thanh Sidebar</h3>
        <ul>
            <li>Chứa các mô-đun chính: Gói thầu, Hợp đồng, Công việc, Việc không quy trình, Tài liệu…</li>
            <li>Có thể thu gọn/mở rộng để tối ưu không gian làm việc.</li>
            <li>Tự động làm nổi (active) mô-đun đang thao tác.</li>
        </ul>

        <!-- QUICK MENU -->
        <h3>2. Menu truy cập nhanh (Quick Menu)</h3>
        <ul>
            <li>Cho phép mở nhanh một mô-đun bất kỳ.</li>
            <li>Hiển thị icon đại diện: Gói thầu, Công việc, Khách hàng, Hợp đồng, Lịch biểu…</li>
            <li>Hữu ích khi người dùng cần chuyển phân hệ liên tục.</li>
        </ul>

        <!-- HEADER -->
        <h3>3. Thanh Header</h3>
        <ul>
            <li>Hiển thị breadcrumb xác định vị trí hiện tại trong hệ thống.</li>
            <li>Hiển thị thông báo, tin nhắn và avatar người dùng.</li>
            <li>Cho phép truy cập nhanh trang cá nhân hoặc đăng xuất.</li>
        </ul>

        <!-- PERMISSION SYSTEM -->
        <h3>4. Hệ thống phân quyền</h3>
        <ul>
            <li>Hệ thống có phân quyền theo vai trò: super admin, admin, trưởng phòng, nhân viên.</li>
            <li>Mỗi vai trò sẽ có quyền truy cập khác nhau theo từng mô-đun.</li>
            <li>Dữ liệu được bảo vệ để tránh người không liên quan xem được thông tin nhạy cảm.</li>
        </ul>

        <!-- NEW SECTION: WORK BY DEPARTMENT -->
        <h3>5. Xem công việc theo phòng ban</h3>
        <p>
            Màn hình tổng quan cho phép lựa chọn một phòng ban cụ thể để xem thống kê và danh sách công việc của phòng đó.
        </p>
        <ul>
            <li>Danh sách phòng ban nằm phía trên cùng: Phòng Kinh Doanh, Phòng Tài Chính, Phòng Hành Chính Nhân Sự…</li>
            <li>Click vào tên phòng ban để chuyển dữ liệu tương ứng.</li>
            <li>Báo cáo hiển thị gồm:
                <ul>
                    <li>Số công việc hôm nay</li>
                    <li>Công việc theo tuần/tháng</li>
                    <li>Công việc gấp cần xử lý</li>
                    <li>Công việc đã hoàn thành</li>
                    <li>Công việc quá hạn</li>
                </ul>
            </li>
            <li>Biểu đồ trực quan thể hiện tỷ lệ hoàn thành và công việc theo người thực hiện.</li>
            <li>Bảng danh sách bên dưới hiển thị đầy đủ công việc của phòng ban đã chọn.</li>
        </ul>

        <!-- NEW SECTION: BIDDING & CONTRACT OVERVIEW -->
        <h3>6. Tổng quan gói thầu – hợp đồng</h3>
        <p>
            Cho phép xem toàn bộ tiến độ, bước quy trình và các task đang chạy của từng gói thầu/hợp đồng
            trong doanh nghiệp.
        </p>
        <ul>
            <li>Bộ lọc theo từng phòng ban hoặc theo loại: Gói thầu, Hợp đồng.</li>
            <li>Danh sách thể hiện:
                <ul>
                    <li>Khách hàng</li>
                    <li>Loại (gói thầu/hợp đồng)</li>
                    <li>Tên gói thầu hoặc hợp đồng</li>
                    <li>Bước quy trình hiện tại</li>
                    <li>Task đang chạy</li>
                    <li>Người đề nghị – Người thực hiện</li>
                    <li>Ngày bắt đầu – kết thúc</li>
                    <li>Tiến độ %</li>
                    <li>Ưu tiên</li>
                    <li>Trạng thái</li>
                    <li>Ngày hạn / ngày quá hạn</li>
                </ul>
            </li>
            <li>Màu sắc trực quan giúp nhận biết nhanh:
                <ul>
                    <li>🟩 Hoàn thành</li>
                    <li>🟦 Đang triển khai</li>
                    <li>🟥 Quá hạn</li>
                    <li>🟧 Đang chờ duyệt</li>
                </ul>
            </li>
            <li>Cho phép click vào từng task để mở chi tiết.</li>
        </ul>

        <!-- SUMMARY -->
        <h3>7. Tổng quan số liệu</h3>
        <ul>
            <li>Báo cáo nhanh số lượng công việc theo trạng thái.</li>
            <li>Biểu đồ phân bổ task theo người thực hiện.</li>
            <li>Danh sách công việc sắp hết hạn trong 1–3 ngày.</li>
        </ul>
    </div>
</template>
