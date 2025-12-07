<template>
    <div class="user-guide">
        <h1>📘 Hướng dẫn sử dụng hệ thống</h1>
        <p class="intro">Chọn mô-đun bên dưới để xem hướng dẫn chi tiết.</p>

        <div class="module-grid">
            <div
                v-for="m in modules"
                :key="m.key"
                class="module-card"
                @click="openGuide(m)"
            >
                <component :is="m.icon" class="module-icon" />
                <div class="module-title">{{ m.title }}</div>
            </div>
        </div>

        <!-- MODAL HIỂN THỊ HƯỚNG DẪN -->
        <a-modal
            v-model:open="modalOpen"
            :title="activeModule?.title"
            width="900px"
            :footer="null"
            class="guide-modal"
        >
            <GuideContent :module="activeModule?.key" />
        </a-modal>
    </div>
</template>

<script setup>
import { ref } from "vue"
import GuideContent from "./guide/GuideContent.vue"

// ICONS ANT DESIGN
import {
    FileDoneOutlined,
    ProjectOutlined,
    FileTextOutlined,
    TeamOutlined,
    FolderOpenOutlined,
    SettingOutlined,
    ApartmentOutlined
} from "@ant-design/icons-vue"

const modalOpen = ref(false)
const activeModule = ref(null)

const modules = [
    { key: "overview", title: "Tổng quan hệ thống", icon: FileDoneOutlined },
    { key: "workflow", title: "Công việc không quy trình", icon: ProjectOutlined },
    { key: "bidding", title: "Gói thầu & Hợp đồng", icon: FileTextOutlined },
    { key: "documents", title: "Tài liệu", icon: FolderOpenOutlined },
    { key: "customers", title: "Khách hàng", icon: TeamOutlined },
    { key: "departments", title: "Phòng ban", icon: ApartmentOutlined },
    { key: "settings", title: "Cấu hình hệ thống", icon: SettingOutlined }
]

const openGuide = (module) => {
    activeModule.value = module
    modalOpen.value = true
}
</script>

<style scoped>
.user-guide {
    padding: 32px;
    background: white;
}

.intro {
    font-size: 15px;
    margin-bottom: 24px;
}

.module-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 20px;
    margin-top: 20px;
}

.module-card {
    background: #f9fafb;
    border: 1px solid #eee;
    border-radius: 12px;
    padding: 20px;
    cursor: pointer;
    text-align: center;
    transition: 0.2s;
}

.module-card:hover {
    background: #eef6ff;
    border-color: #91caff;
}

.module-icon {
    font-size: 36px;
    color: #1677ff;
}

.module-title {
    margin-top: 10px;
    font-size: 15px;
    font-weight: 600;
}

</style>
<style>
/* Cố định chiều cao của modal content */
.guide-modal .ant-modal-body {
    max-height: 70vh; /* 70% chiều cao màn hình */
    overflow-y: auto;
    padding-right: 16px; /* chống che chữ khi có scroll */
}

/* Thu nhỏ thanh scroll */
.guide-modal .ant-modal-body::-webkit-scrollbar {
    width: 6px; /* nhỏ gọn */
}

.guide-modal .ant-modal-body::-webkit-scrollbar-track {
    background: #f0f0f0;
    border-radius: 3px;
}

.guide-modal .ant-modal-body::-webkit-scrollbar-thumb {
    background: #c0c0c0;
    border-radius: 3px;
}

.guide-modal .ant-modal-body::-webkit-scrollbar-thumb:hover {
    background: #a0a0a0;
}

</style>
