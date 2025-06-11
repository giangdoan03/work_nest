<template>
    <a-layout-sider
        :collapsed="collapsed"
        :trigger="null"
        collapsible
        collapsedWidth="0"
        width="250"
        breakpoint="lg"
        @breakpoint="handleBreakpoint"
        @collapse="handleCollapse"
        style="background-color: #000000;"
    >
        <div class="logo"/>
        <a-menu
            :selectedKeys="selectedKeys"
            :openKeys="openKeys"
            theme="dark"
            mode="inline"
            @openChange="val => openKeys = val"
            @select="handleSelect"
        >
            <a-menu-item key="dashboard">
                <PieChartOutlined/>
                <span>Tổng quan</span>
            </a-menu-item>
            <a-menu-item key="quan-ly-khach-hang">
                <TeamOutlined/>
                <span>Quản lý khách hàng</span>
            </a-menu-item>
            <a-menu-item key="list-phong-ban">
                <ApartmentOutlined />
                <span>Danh sách phòng ban</span>
            </a-menu-item>
            <a-menu-item key="user-management">
                <TeamOutlined />
                <span>Quản lý người dùng</span>
            </a-menu-item>
            <a-menu-item key="bid-tasks">
                <FileSearchOutlined />
                <span>Gói thầu</span>
            </a-menu-item>

            <a-menu-item key="contracts-tasks">
                <FileTextOutlined />
                <span>Hợp đồng</span>
            </a-menu-item>

            <a-menu-item key="internal-tasks">
                <ToolOutlined />
                <span>Nhiệm vụ nội bộ</span>
            </a-menu-item>

            <a-menu-item key="cau-hinh">
                <SettingOutlined/>
                <span>Cấu hình</span>
            </a-menu-item>
            <a-menu-item key="permission">
                <TeamOutlined/>
                <span>Phân quyền</span>
            </a-menu-item>

        </a-menu>
    </a-layout-sider>
</template>

<script setup>
import {
    PieChartOutlined, TeamOutlined, SettingOutlined, ApartmentOutlined, FileSearchOutlined, FileTextOutlined, ToolOutlined
} from '@ant-design/icons-vue'

import {useRouter, useRoute} from 'vue-router'
import {ref, watch, onMounted} from 'vue'

const router = useRouter()
const route = useRoute()

const props = defineProps({
    collapsed: Boolean
})

const emit = defineEmits(['update:collapsed'])

const selectedKeys = ref([])
const openKeys = ref([])

const pathToKeyMap = {
    // '/dashboard': 'dashboard',
    // '/persons': 'ca-nhan',
    '/loyalty/programs': 'chuong-trinh',
    '/loyalty/gifts': 'qua-tang',
    '/loyalty/voucher-management': 'goi-voucher',
    '/loyalty/history': 'lich-su-nguoi-choi',
    '/custom-pages': 'trang-tu-thiet-ke',
    // '/scan-history': 'lich-su-quet',
    '/checkin-history': 'lich-su-checkin', 
    '/customers': 'quan-ly-khach-hang',
    '/settings': 'cau-hinh',
    '/purchase-history': 'lich-su-mua-goi',
    '/permissions': 'permission',
    '/departments': 'list-phong-ban',
    '/user-management': 'user-management',
    '/internal-tasks': 'internal-tasks',
    '/contracts-tasks': 'contracts-tasks',
    '/bid-tasks': 'bid-tasks',
}

const keyToParentMap = {
    // Chương trình loyalty
    'chuong-trinh': 'chuong-trinh-loyalty',
    'qua-tang': 'chuong-trinh-loyalty',
    'goi-voucher': 'chuong-trinh-loyalty',
    'lich-su-nguoi-choi': 'chuong-trinh-loyalty',

    // Các menu khác
    'trang-tu-thiet-ke': 'dashboard',
    'lich-su-quet': 'dashboard',
    // 'lich-su-checkin': 'dashboard',
    'quan-ly-khach-hang': 'dashboard',
    'cau-hinh': 'dashboard',
    'lich-su-mua-goi': 'dashboard',
    'permission': 'permission',
    'list-phong-ban': 'list-phong-ban',
    'user-management': 'user-management',
    'internal-tasks': 'internal-tasks',
    'contracts-tasks': 'contracts-tasks',
    'bid-tasks': 'bid-tasks',
}


const updateSelectedAndOpenKeys = () => {
    const currentPath = route.path

    // Tìm path phù hợp nhất bằng startsWith
    const matchedEntry = Object.entries(pathToKeyMap).find(([path]) =>
        currentPath.startsWith(path)
    )

    const matchedKey = matchedEntry?.[1] || ''
    selectedKeys.value = [matchedKey]

    const parentKey = keyToParentMap[matchedKey]
    openKeys.value = parentKey ? [parentKey] : []
}


onMounted(updateSelectedAndOpenKeys)
watch(() => route.path, updateSelectedAndOpenKeys)

const handleSelect = ({key}) => {
    // Gán selected ngay lập tức để tránh nháy
    selectedKeys.value = [key]

    const path = Object.entries(pathToKeyMap).find(([path, menuKey]) => menuKey === key)?.[0]
    if (path) router.push(path)
}

const handleBreakpoint = (broken) => {
    emit('update:collapsed', broken)
}

const handleCollapse = (collapsed) => {
    emit('update:collapsed', collapsed)
}
</script>
<style>
    .ant-menu-dark {
        background-color: #000000 !important;
    }

    .ant-menu-sub.ant-menu-inline {
        background: #000000 !important;
    }
</style>
<style scoped>
    .logo {
        height: 32px;
        background: rgba(255, 255, 255, 0.3);
        margin: 16px;
    }
</style>
