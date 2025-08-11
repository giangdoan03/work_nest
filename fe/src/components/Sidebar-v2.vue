<template>
    <div class="sidebar">
        <!-- Logo -->
        <div class="logo-container">
            <div class="logo">
                <span class="logo-text">Work Nest</span>
            </div>
        </div>

        <!-- Menu -->
        <nav class="menu">
            <a-tooltip placement="right" title="Tổng quan">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/project-overview' }"
                    @click="navigateTo('/project-overview')"
                >
                    <BarChartOutlined />
                    <span class="menu-text">Tổng quan</span>
                </div>
            </a-tooltip>
            
            <a-tooltip placement="right" title="Nhiệm vụ của tôi">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/my-tasks' }"
                    @click="navigateTo('/my-tasks')"
                >
                    <ScheduleOutlined />
                    <span class="menu-text">Nhiệm vụ của tôi</span>
                </div>
            </a-tooltip>
            
            <a-tooltip placement="right" title="Duyệt nhiệm vụ">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/task-approvals' }"
                    @click="navigateTo('/task-approvals')"
                >
                    <CheckCircleOutlined />
                    <span class="menu-text">Duyệt nhiệm vụ</span>
                </div>
            </a-tooltip>
            
            <a-tooltip placement="right" title="Quản lý khách hàng">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/customers' }"
                    @click="navigateTo('/customers')"
                >
                    <TeamOutlined />
                    <span class="menu-text">Quản lý khách hàng</span>
                </div>
            </a-tooltip>
            
            <a-tooltip placement="right" title="Gói thầu">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/bid-list' }"
                    @click="navigateTo('/bid-list')"
                >
                    <FileSearchOutlined />
                    <span class="menu-text">Gói thầu</span>
                </div>
            </a-tooltip>
            
            <a-tooltip placement="right" title="Hợp đồng">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/contracts-tasks' }"
                    @click="navigateTo('/contracts-tasks')"
                >
                    <FileTextOutlined />
                    <span class="menu-text">Hợp đồng</span>
                </div>
            </a-tooltip>
            
            <a-tooltip placement="right" title="Công việc">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/internal-tasks' }"
                    @click="navigateTo('/internal-tasks')"
                >
                    <ToolOutlined />
                    <span class="menu-text">Công việc</span>
                </div>
            </a-tooltip>
            
            <a-tooltip placement="right" title="Danh sách phòng ban">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/departments' }"
                    @click="navigateTo('/departments')"
                >
                    <ApartmentOutlined />
                    <span class="menu-text">Danh sách phòng ban</span>
                </div>
            </a-tooltip>
            
            <a-tooltip placement="right" title="Quản lý người dùng">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/user-management' }"
                    @click="navigateTo('/user-management')"
                >
                    <TeamOutlined />
                    <span class="menu-text">Quản lý người dùng</span>
                </div>
            </a-tooltip>
            
                        <!-- Submenu Documents -->
            <div class="submenu">
                <a-dropdown 
                    placement="rightTop" 
                    :trigger="['hover']"
                    :getPopupContainer="triggerNode => triggerNode.parentNode"
                >
                    <div 
                        class="submenu-header"
                        :class="{ active: isDocumentsActive }"
                    >
                          <FileTextOutlined />
                        <span class="menu-text">Tài liệu</span>
                        <span class="submenu-arrow">▼</span>
                    </div>
                    
                    <template #overlay>
                        <a-menu :selectedKeys="documentsSelectedKeys">
                            <a-menu-item key="documents-my" @click="navigateTo('/documents/my')">
                                <FileOutlined style="margin-right: 12px;" />
                                <span>Tài liệu của tôi</span>
                            </a-menu-item>
                            <a-menu-item key="documents-department" @click="navigateTo('/documents/department')">
                                <ApartmentOutlined style="margin-right: 12px;" />
                                <span>Theo phòng ban</span>
                            </a-menu-item>
                            <a-menu-item key="documents-permission" @click="navigateTo('/documents/permission')">
                                <LockOutlined style="margin-right: 12px;" />
                                <span>Phân quyền tài liệu</span>
                            </a-menu-item>
                            <a-menu-item key="documents-settings" @click="navigateTo('/documents/settings')">
                                <SettingOutlined style="margin-right: 12px;" />
                                <span>Cấu hình tài liệu</span>
                            </a-menu-item>
                        </a-menu>
                    </template>
                </a-dropdown>
            </div>
            
                        <!-- Submenu Settings -->
            <div class="submenu">
                <a-dropdown 
                    placement="rightTop" 
                    :trigger="['hover']"
                    :getPopupContainer="triggerNode => triggerNode.parentNode"
                >
                    <div 
                        class="submenu-header"
                        :class="{ active: isSettingsActive }"
                    >
                      <SettingOutlined />
                        <span class="menu-text">Cấu hình chung</span>
                        <span class="submenu-arrow">▼</span>
                    </div>
                    
                    <template #overlay>
                        <a-menu :selectedKeys="settingsSelectedKeys">
                            <a-menu-item key="settings-bidding" @click="navigateTo('/settings/bidding')">
                                <FileDoneOutlined style="margin-right: 12px;" />
                                <span>Đấu thầu</span>
                            </a-menu-item>
                            <a-menu-item key="settings-contract" @click="navigateTo('/settings/contract')">
                                <ProfileOutlined style="margin-right: 12px;" />
                                <span>Hợp đồng</span>
                            </a-menu-item>
                        </a-menu>
                    </template>
                </a-dropdown>
            </div>
            
            <a-tooltip placement="right" title="Phân quyền">
                <div 
                    class="menu-item"
                    :class="{ active: currentRoute === '/permissions' }"
                    @click="navigateTo('/permissions')"
                >
                    <TeamOutlined />
                    <span class="menu-text">Phân quyền</span>
                </div>
            </a-tooltip>
        </nav>
    </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { storeToRefs } from 'pinia'
import {
    BarChartOutlined,
    ScheduleOutlined,
    CheckCircleOutlined,
    TeamOutlined,
    FileSearchOutlined,
    FileTextOutlined,
    ToolOutlined,
    ApartmentOutlined,
    FileOutlined,
    LockOutlined,
    SettingOutlined,
    FileDoneOutlined,
    ProfileOutlined
} from '@ant-design/icons-vue'

// const props = defineProps({
//     user: {
//         type: Object,
//         required: true
//     }
// })

const emit = defineEmits(['logout'])

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const { user: currentUser } = storeToRefs(userStore)

// Current route
const currentRoute = computed(() => route.path)

// Check if submenu should be active
const isDocumentsActive = computed(() => {
    return ['/documents/my', '/documents/shared', '/documents/department', '/documents/permission', '/documents/settings'].includes(currentRoute.value)
})

const isSettingsActive = computed(() => {
    return ['/settings/bidding', '/settings/contract', '/settings'].includes(currentRoute.value)
})

// Path to key mapping (same as Sidebar.vue)
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

// Key to parent mapping (same as Sidebar.vue)
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

// Cho phép match cả path con: /documents/my/123
const mapPathToKey = (path) => {
    // ưu tiên match chính xác
    if (pathToKeyMap[path]) return pathToKeyMap[path]
    // sau đó match theo prefix
    const hit = Object.entries(pathToKeyMap).find(([p]) =>
        path.startsWith(p + '/')
    )
    return hit ? hit[1] : undefined
}

// Nhóm key thuộc submenu Documents / Settings
const documentKeys = new Set([
    'documents-my',
    'documents-shared',
    'documents-department',
    'documents-permission',
    'documents-settings',
])
const settingKeys = new Set([
    'cau-hinh-dau-thau',
    'cau-hinh-hop-dong',
    'cau-hinh',
])

// selectedKeys cho menu overlay
const documentsSelectedKeys = computed(() => {
    const k = mapPathToKey(currentRoute.value)
    return k && documentKeys.has(k) ? [k] : []
})

const settingsSelectedKeys = computed(() => {
    const k = mapPathToKey(currentRoute.value)
    return k && settingKeys.has(k) ? [k] : []
})


// Navigation function
const navigateTo = (path) => {
    router.push(path)
}


</script>

<style scoped>
.sidebar {
    width: 60px;
    min-width: 60px;
    max-width: 60px;
    background: #001529;
    height: 100vh;
    display: flex;
    flex-direction: column;
    overflow-y: auto;
    overflow-x: hidden;
    flex-shrink: 0;
}

/* Logo styling */
.logo-container {
    padding: 16px 8px;
    text-align: center;
    border-bottom: 1px solid #303030;
    flex-shrink: 0;
}

.logo {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
}

.logo-image {
    width: 32px;
    height: 32px;
    border-radius: 4px;
}

.logo-text {
    color: #ffffff;
    font-size: 8px;
    font-weight: 600;
    line-height: 1;
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Menu styling */
.menu {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 8px 0;
}

/* Menu items */
.menu-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 8px 4px;
    height: 60px;
    min-height: 60px;
    margin: 0;
    cursor: pointer;
    transition: background-color 0.2s ease;
    position: relative;
}

.menu-item:hover {
    background-color: #1890ff;
}

.menu-item.active {
    background-color: #1890ff;
}

/* Icon styling */
.menu-item .anticon {
    display: block;
    font-size: 16px;
    margin-bottom: 4px;
    color: #ffffff;
}

/* Text styling */
.menu-text {
    color: #ffffff;
    font-size: 10px;
    line-height: 1.2;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-align: center;
    max-width: 52px;
}

/* Submenu styling */
.submenu {
    margin: 0;
}

.submenu-header {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 8px 4px;
    height: 60px;
    min-height: 60px;
    margin: 0;
    cursor: pointer;
    transition: background-color 0.2s ease;
    position: relative;
}

.submenu-header:hover {
    background-color: #1890ff;
}

.submenu-header.active {
    background-color: #1890ff;
}

.submenu-header .anticon {
    display: block;
    font-size: 16px;
    margin-bottom: 4px;
    color: #ffffff;
}

.submenu-arrow {
    position: absolute;
    right: 4px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 8px;
    color: #ffffff;
}

/* Dropdown menu styling */
.ant-dropdown-menu {
    background: #001529 !important;
    border: 1px solid #303030 !important;
    border-radius: 4px !important;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15) !important;
    min-width: 200px !important;
    width: 200px !important;
    max-width: 250px !important;
}

.ant-dropdown-menu-item {
    color: #ffffff !important;
    padding: 12px 16px !important;
    display: flex !important;
    align-items: center !important;
    gap: 16px !important;
    white-space: nowrap !important;
    line-height: 1.5 !important;
    height: 44px !important;
    min-height: 44px !important;
    border-bottom: 1px solid #303030 !important;
    transition: all 0.2s ease !important;
}

.ant-dropdown-menu-item:last-child {
    border-bottom: none !important;
}

:deep(.ant-dropdown-menu-item):hover {
    background-color: #1890ff !important;
    color: #ffffff !important;
    transform: translateX(4px) !important;
    box-shadow: 0 2px 8px rgba(183, 188, 192, 0.3) !important;
}

.ant-dropdown-menu-item .anticon {
    color: #ffffff !important;
    font-size: 16px !important;
    flex-shrink: 0 !important;
    transition: all 0.2s ease !important;
}

.ant-dropdown-menu-item span {
    color: #ffffff !important;
    font-size: 14px !important;
    white-space: nowrap !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
    font-weight: 400 !important;
    transition: all 0.2s ease !important;
}

.ant-dropdown-menu-item:hover ,
.ant-dropdown-menu-item:hover  {
    background-color: #1890ff !important;
    color: #ffffff !important;
}

/* Active state for menu items */
:deep(.ant-dropdown-menu-item) .ant-dropdown-menu-item-selected {
    background-color: #1890ff !important;
    color: #ffffff !important;
}

.ant-dropdown-menu-item.ant-dropdown-menu-item-selected .anticon,
.ant-dropdown-menu-item.ant-dropdown-menu-item-selected span {
    color: #ffffff !important;
}

/* Hover effects for all interactive elements */
.menu-item:hover .anticon,
.menu-item:hover .menu-text,
.submenu-header:hover .anticon,
.submenu-header:hover .menu-text,
.submenu-item:hover .anticon,
.submenu-item:hover .menu-text {
    background-color: #1890ff !important;
    color: #ffffff;
}

.menu-item.active .anticon,
.menu-item.active .menu-text,
.submenu-header.active .anticon,
.submenu-header.active .menu-text,
.submenu-item.active .anticon,
.submenu-item.active .menu-text {
    color: #ffffff;
}

/* Scrollbar styling */
.sidebar::-webkit-scrollbar {
    width: 4px;
}

.sidebar::-webkit-scrollbar-track {
    background: #001529;
}

.sidebar::-webkit-scrollbar-thumb {
    background: #303030;
    border-radius: 2px;
}

.sidebar::-webkit-scrollbar-thumb:hover {
    background: #404040;
}
</style>
