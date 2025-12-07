<template>
    <div class="user-guide">
        <h1>📘 Hướng dẫn sử dụng hệ thống</h1>

        <p>Trang này chứa các tài liệu, video hướng dẫn và mô tả chức năng của hệ thống.</p>

        <section class="guide-section" v-for="item in guides" :key="item.title">
            <h2>{{ item.title }}</h2>
            <p>{{ item.description }}</p>

            <ul>
                <li v-for="c in item.contents" :key="c">{{ c }}</li>
            </ul>
        </section>
    </div>
</template>

<script setup>
const guides = [
    {
        title: "1. Tổng quan hệ thống",
        description: "Giới thiệu kiến trúc và các mô-đun chính.",
        contents: ["Giao diện", "Sidebar", "Cách xem dữ liệu tổng quan"]
    },
    {
        title: "2. Quy trình công việc",
        description: "Hướng dẫn tạo, giao và theo dõi nhiệm vụ.",
        contents: ["Tạo nhiệm vụ", "Theo dõi tiến độ", "Giao việc"]
    },
    {
        title: "3. Quản lý tài liệu",
        description: "Cách tải lên, phân quyền và chia sẻ tài liệu.",
        contents: ["Tải lên tài liệu", "Cấp quyền", "Theo phòng ban"]
    }
]
</script>

<style scoped>
.user-guide {
    padding: 24px;
    background: white;
}
.guide-section {
    margin-top: 18px;
    padding: 12px 0;
    border-bottom: 1px solid #eee;
}
</style>
