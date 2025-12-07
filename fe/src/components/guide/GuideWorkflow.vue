<template>
    <div>
        <h2>📌 Hướng dẫn Quy trình & Công việc</h2>
        <p>
            Module Công việc giúp quản lý toàn bộ nhiệm vụ trong doanh nghiệp, bao gồm công việc theo quy trình
            (workflow) và công việc không theo quy trình. Hệ thống hỗ trợ theo dõi tiến độ, phân công người thực hiện,
            phê duyệt và quản lý công việc cha – con một cách trực quan.
        </p>

        <!-- 1. Tạo công việc -->
        <h3>1. Tạo công việc mới</h3>
        <ul>
            <li>Nhấn nút <b>“Thêm công việc”</b>.</li>
            <li>Nhập đầy đủ thông tin: tiêu đề, mô tả, thời gian bắt đầu – kết thúc, hạn xử lý.</li>
            <li>Chọn <b>Người phụ trách</b> và <b>Người phối hợp</b> (nếu có).</li>
            <li>Có thể tạo công việc cha → thêm công việc con để phân rã nhiệm vụ.</li>
        </ul>

        <!-- 2. Công việc theo quy trình -->
        <h3>2. Công việc theo quy trình (Workflow)</h3>
        <ul>
            <li>Được tạo dựa trên các bước xử lý đã được cấu hình cố định của doanh nghiệp.</li>
            <li>Mỗi bước yêu cầu người xử lý hoàn thành trước khi chuyển sang bước tiếp theo.</li>
            <li>Hệ thống hỗ trợ phê duyệt theo cấp nếu bước đó yêu cầu duyệt.</li>
            <li>Phù hợp cho các nghiệp vụ chuẩn hóa: xử lý hợp đồng, triển khai dự án, quy trình nội bộ…</li>
        </ul>

        <!-- 3. Công việc không theo quy trình -->
        <h3>3. Công việc không theo quy trình (Task tự do)</h3>
        <p>
            Đây là những công việc <b>không thuộc bất kỳ gói thầu hay hợp đồng nào</b>,
            thường là các nhiệm vụ nội bộ của từng phòng ban.
        </p>
        <ul>
            <li>Dùng cho các công việc phát sinh, công việc hằng ngày hoặc nhiệm vụ đơn giản.</li>
            <li>Không bị ràng buộc bởi workflow chuẩn; người tạo có thể tự do cấu hình các thông tin công việc.</li>
            <li>Vẫn hỗ trợ đầy đủ các chức năng:
                <ul>
                    <li>Tạo công việc cha – công việc con</li>
                    <li>Gán người phụ trách, người phối hợp</li>
                    <li>Thời gian bắt đầu – kết thúc</li>
                    <li>Mô tả chi tiết</li>
                    <li>Độ ưu tiên</li>
                    <li>Đính kèm tài liệu</li>
                </ul>
            </li>
            <li>Phù hợp cho công việc văn phòng, yêu cầu đột xuất, nhiệm vụ nội bộ giữa các phòng ban.</li>
        </ul>

        <!-- 4. Theo dõi tiến độ -->
        <h3>4. Theo dõi tiến độ</h3>
        <ul>
            <li>Hệ thống hiển thị phần trăm hoàn thành dựa trên số lượng công việc con hoặc trạng thái từng bước.</li>
            <li>Màu sắc trực quan:
                <ul>
                    <li><span style="color:#52c41a">🟢 Đúng hạn</span></li>
                    <li><span style="color:#faad14">🟡 Sắp tới hạn</span></li>
                    <li><span style="color:#ff4d4f">🔴 Quá hạn</span></li>
                </ul>
            </li>
            <li>Cho phép mở modal để xem chi tiết từng phần công việc.</li>
        </ul>

        <!-- 5. Phê duyệt -->
        <h3>5. Phê duyệt công việc</h3>
        <p>
            Một số công việc hoặc bước xử lý có thể yêu cầu phê duyệt trước khi chuyển sang bước tiếp theo.
        </p>
        <ul>
            <li>Cho phép chọn nhiều cấp duyệt theo thứ tự.</li>
            <li>Hệ thống tự động chuyển lượt duyệt từ cấp 1 → cấp 2 → cấp 3…</li>
            <li>Lưu lại lịch sử phê duyệt đầy đủ.</li>
        </ul>
    </div>
</template>
