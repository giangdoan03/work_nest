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
            <a-menu-item key="project-overview">
                <BarChartOutlined />
                <span>Tổng quan</span>
            </a-menu-item>
            <a-menu-item key="my-tasks">
                <ScheduleOutlined />
                <span>Nhiệm vụ của tôi</span>
            </a-menu-item>
            <a-menu-item key="task-approvals">
                <CheckCircleOutlined />
                <span>Duyệt nhiệm vụ</span>
            </a-menu-item>
            <a-menu-item key="quan-ly-khach-hang">
                <TeamOutlined/>
                <span>Quản lý khách hàng</span>
            </a-menu-item>
            <a-menu-item key="bid-list">
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

            <a-menu-item key="list-phong-ban">
                <ApartmentOutlined />
                <span>Danh sách phòng ban</span>
            </a-menu-item>
            <a-menu-item key="user-management">
                <TeamOutlined />
                <span>Quản lý người dùng</span>
            </a-menu-item>

            <a-sub-menu key="documents">
                <template #title>
                    <span>
                      <FileTextOutlined />
                      <span> Tài liệu</span>
                    </span>
                </template>

                <!-- Bắt buộc - Tất cả người dùng -->
                <a-menu-item key="documents-my">
                    <template #icon><FileOutlined /></template>
                    <span>Tài liệu của tôi</span>
                </a-menu-item>

<!--                <a-menu-item key="documents-shared">-->
<!--                    <template #icon><InboxOutlined /></template>-->
<!--                    <span>Được chia sẻ với tôi</span>-->
<!--                </a-menu-item>-->

                <!-- Tuỳ chọn - Tất cả người dùng -->
                <a-menu-item key="documents-department">
                    <template #icon><ApartmentOutlined /></template>
                    <span>Theo phòng ban</span>
                </a-menu-item>

                <!-- Nên có nếu nhiều người dùng - Quản lý/Admin -->
                <a-menu-item key="documents-permission">
                    <template #icon><LockOutlined /></template>
                    <span>Phân quyền tài liệu</span>
                </a-menu-item>

                <!-- Nên có - Chỉ dành cho Admin -->
                <a-menu-item key="documents-settings">
                    <template #icon><SettingOutlined /></template>
                    <span>Cấu hình tài liệu</span>
                </a-menu-item>
            </a-sub-menu>

            <!-- MENU CHA: CẤU HÌNH CHUNG -->
            <a-sub-menu key="cau-hinh">
                <template #title>
                <span>
                  <SettingOutlined />
                  <span> Cấu hình chung</span>
                </span>
                </template>

                <!-- CON: Cấu hình Đấu thầu -->
                <a-menu-item key="cau-hinh-dau-thau">
                    <template #icon><FileDoneOutlined /></template>
                    <span>Đấu thầu</span>
                </a-menu-item>

                <!-- CON: Cấu hình Hợp đồng -->
                <a-menu-item key="cau-hinh-hop-dong">
                    <template #icon><ProfileOutlined /></template>
                    <span>Hợp đồng</span>
                </a-menu-item>
            </a-sub-menu>

            <a-menu-item key="permission">
                <TeamOutlined/>
                <span>Phân quyền</span>
            </a-menu-item>

        </a-menu>
    </a-layout-sider>
</template>

<script setup>
import {
    PieChartOutlined, TeamOutlined, SettingOutlined, FileSearchOutlined, FileTextOutlined, ToolOutlined,
    FileOutlined,
    InboxOutlined,
    LockOutlined,
    ApartmentOutlined,
    FileDoneOutlined,
    ProfileOutlined,
    ScheduleOutlined,
    BarChartOutlined,
    CheckCircleOutlined
} from '@ant-design/icons-vue'
import { h } from 'vue'

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
    '/dashboard': 'dashboard',
    '/project-overview': 'project-overview',
    '/my-tasks': 'my-tasks',
    '/task-approvals': 'task-approvals',
    '/customers': 'quan-ly-khach-hang',
    '/permissions': 'permission',
    '/departments': 'list-phong-ban',
    '/user-management': 'user-management',
    '/internal-tasks': 'internal-tasks',
    '/contracts-tasks': 'contracts-tasks',
    '/contracts': 'contracts-tasks',
    '/bid-list': 'bid-list',
    '/bid-detail': 'bid-list',

    // Tài liệu (sub menu)
    '/documents/my': 'documents-my',
    '/documents/shared': 'documents-shared',
    '/documents/department': 'documents-department',
    '/documents/permission': 'documents-permission',
    '/documents/settings': 'documents-settings',

    '/settings/bidding': 'cau-hinh-dau-thau',
    '/settings/contract': 'cau-hinh-hop-dong',
    '/settings': 'cau-hinh',
}


const keyToParentMap = {

    // Các menu chính
    'project-overview': 'project-overview',
    'my-tasks': 'my-tasks',
    'task-approvals': 'task-approvals',
    'dashboard': 'dashboard',
    'quan-ly-khach-hang': 'dashboard',
    'cau-hinh': 'dashboard',
    'lich-su-mua-goi': 'dashboard',
    'permission': 'permission',
    'list-phong-ban': 'list-phong-ban',
    'user-management': 'user-management',
    'internal-tasks': 'internal-tasks',
    'contracts-tasks': 'contracts-tasks',
    'bid-list': 'bid-list',
    'bid-detail': 'bid-list',

    // Tài liệu
    'documents-my': 'documents',
    'documents-shared': 'documents',
    'documents-department': 'documents',
    'documents-permission': 'documents',
    'documents-settings': 'documents',

    'cau-hinh-dau-thau': 'cau-hinh',
    'cau-hinh-hop-dong': 'cau-hinh'
}



const updateSelectedAndOpenKeys = () => {
    const currentPath = route.path

    // Tìm path phù hợp nhất
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
