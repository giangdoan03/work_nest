<template>
    <div class="sidebar" :class="{ collapsed }">
        <!-- Logo -->
        <div class="logo-container">
            <router-link to="/" class="logo">
                <img
                    :src="collapsed ? '/logoMark.png' : '/TTID_logo.png'"
                    class="logo-img"
                    :alt="collapsed ? 'WN' : 'Work Nest'"
                />
            </router-link>
        </div>

        <!-- Menu -->
        <nav class="menu">
            <!-- 1. Tổng quan -->
            <a-tooltip placement="right" title="Tổng quan" v-if="collapsed">
                <div class="menu-item" :class="{ active: isOverviewActive }" @click="navigateTo('/project-overview')">
                    <BarChartOutlined />
                    <div class="menu-text-collapsed">Tổng quan</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isOverviewActive }" @click="navigateTo('/project-overview')">
                <BarChartOutlined />
                <span class="menu-text">Tổng quan</span>
            </div>

            <!-- 2. Gói thầu -->
            <a-tooltip placement="right" title="Gói thầu" v-if="collapsed">
                <div class="menu-item" :class="{ active: isBiddingActive }" @click="navigateTo('/bid-list')">
                    <FileSearchOutlined />
                    <div class="menu-text-collapsed">Gói thầu</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isBiddingActive }" @click="navigateTo('/bid-list')">
                <FileSearchOutlined />
                <span class="menu-text">Gói thầu</span>
            </div>

            <!-- 3. Hợp đồng -->
            <a-tooltip placement="right" title="Hợp đồng" v-if="collapsed">
                <div class="menu-item" :class="{ active: isContractActive }" @click="navigateTo('/contracts-tasks')">
                    <FileTextOutlined />
                    <div class="menu-text-collapsed">Hợp đồng</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isContractActive }" @click="navigateTo('/contracts-tasks')">
                <FileTextOutlined />
                <span class="menu-text">Hợp đồng</span>
            </div>

            <!-- 4. Việc không quy trình -->
            <a-tooltip placement="right" title="Việc không quy trình" v-if="collapsed">
                <div class="menu-item" :class="{ active: isTaskActive }" @click="navigateTo('/tasks')">
                    <UnorderedListOutlined />
                    <div class="menu-text-collapsed">Việc không quy trình</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isTaskActive }" @click="navigateTo('/tasks')">
                <UnorderedListOutlined />
                <span class="menu-text">Việc không quy trình</span>
            </div>

            <!-- 5. Công việc cá nhân -->
            <a-tooltip placement="right" title="Công việc cá nhân" v-if="collapsed">
                <div class="menu-item" :class="{ active: currentRoute === '/my-tasks' }" @click="navigateTo('/my-tasks')">
                    <UserOutlined />
                    <div class="menu-text-collapsed">Công việc cá nhân</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: currentRoute === '/my-tasks' }" @click="navigateTo('/my-tasks')">
                <UserOutlined />
                <span class="menu-text">Công việc cá nhân</span>
            </div>

            <!-- 6. Duyệt nhiệm vụ -->
            <a-tooltip placement="right" title="Duyệt nhiệm vụ" v-if="collapsed">
                <div class="menu-item" :class="{ active: currentRoute === '/task-approvals' }" @click="navigateTo('/task-approvals')">
                    <CheckCircleOutlined />
                    <div class="menu-text-collapsed">Duyệt nhiệm vụ</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: currentRoute === '/task-approvals' }" @click="navigateTo('/task-approvals')">
                <CheckCircleOutlined />
                <span class="menu-text">Duyệt nhiệm vụ</span>
            </div>

            <!-- 7. Quản lý dữ liệu công việc (Việc quy trình) -->
            <a-tooltip placement="right" title="Việc quy trình" v-if="collapsed">
                <div class="menu-item" :class="{ active: isInternalTaskActive }" @click="navigateTo('/internal-tasks')">
                    <ProjectOutlined />
                    <div class="menu-text-collapsed">Việc quy trình</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isInternalTaskActive }" @click="navigateTo('/internal-tasks')">
                <ProjectOutlined />
                <span class="menu-text">Việc quy trình</span>
            </div>

            <!-- 8. Tài liệu (submenu) -->
            <div class="submenu">
                <div v-if="!collapsed">
                    <a-dropdown placement="rightTop" :trigger="['hover']" :getPopupContainer="p => p.parentNode">
                        <div class="submenu-header" :class="{ active: isDocumentsActive }">
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
                <div v-else>
                    <a-dropdown placement="rightTop" :trigger="['hover']" :getPopupContainer="p => p.parentNode">
                        <div class="submenu-header" :class="{ active: isDocumentsActive }">
                            <FileTextOutlined />
                            <span class="menu-text-collapsed">Tài liệu</span>
                            <span class="submenu-arrow-collapsed">▼</span>
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
            </div>

            <!-- 9. Danh sách khách hàng -->
            <a-tooltip placement="right" title="Khách hàng" v-if="collapsed">
                <div class="menu-item" :class="{ active: isCustomerActive }" @click="navigateTo('/customers')">
                    <TeamOutlined />
                    <div class="menu-text-collapsed">Khách hàng</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isCustomerActive }" @click="navigateTo('/customers')">
                <TeamOutlined />
                <span class="menu-text">Khách hàng</span>
            </div>

            <!-- 10. Danh sách phòng/ban -->
            <a-tooltip placement="right" title="Phòng ban" v-if="collapsed">
                <div class="menu-item" :class="{ active: currentRoute === '/departments' }" @click="navigateTo('/departments')">
                    <ApartmentOutlined />
                    <div class="menu-text-collapsed">Phòng ban</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: currentRoute === '/departments' }" @click="navigateTo('/departments')">
                <ApartmentOutlined />
                <span class="menu-text">Phòng ban</span>
            </div>

            <!-- 11. Quản lý người dùng -->
            <a-tooltip placement="right" title="Quản lý người dùng" v-if="collapsed">
                <div class="menu-item" :class="{ active: currentRoute === '/user-management' }" @click="navigateTo('/user-management')">
                    <TeamOutlined />
                    <div class="menu-text-collapsed">Quản lý người dùng</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: currentRoute === '/user-management' }" @click="navigateTo('/user-management')">
                <TeamOutlined />
                <span class="menu-text">Quản lý người dùng</span>
            </div>

            <!-- 12. Cấu hình chung (submenu) -->
            <div class="submenu">
                <div v-if="!collapsed">
                    <a-dropdown placement="rightTop" :trigger="['hover']" :getPopupContainer="p => p.parentNode">
                        <div class="submenu-header" :class="{ active: isSettingsActive }">
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
                <div v-else>
                    <a-dropdown placement="rightTop" :trigger="['hover']" :getPopupContainer="p => p.parentNode">
                        <div class="submenu-header" :class="{ active: isSettingsActive }">
                            <SettingOutlined />
                            <span class="menu-text-collapsed">Cấu hình chung</span>
                            <span class="submenu-arrow-collapsed">▼</span>
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
            </div>

            <!-- 13. Phân quyền -->
            <a-tooltip placement="right" title="Phân quyền" v-if="collapsed">
                <div class="menu-item" :class="{ active: currentRoute === '/permissions' }" @click="navigateTo('/permissions')">
                    <TeamOutlined />
                    <div class="menu-text-collapsed">Phân quyền</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: currentRoute === '/permissions' }" @click="navigateTo('/permissions')">
                <TeamOutlined />
                <span class="menu-text">Phân quyền</span>
            </div>
        </nav>
    </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import {
    BarChartOutlined,
    FileSearchOutlined,
    FileTextOutlined,
    UnorderedListOutlined,
    UserOutlined,
    CheckCircleOutlined,
    ProjectOutlined,
    FileOutlined,
    ApartmentOutlined,
    LockOutlined,
    SettingOutlined,
    FileDoneOutlined,
    ProfileOutlined,
    TeamOutlined,
} from '@ant-design/icons-vue'

const props = defineProps({
    collapsed: { type: Boolean, default: false },
})

const route = useRoute()
const router = useRouter()

// === Route helpers ===
const currentRoute = computed(() => route.path)
const currentRouteId = computed(() => route.params.id)

// === Active states ===
const isOverviewActive = computed(() => currentRoute.value === '/project-overview')
const isBiddingActive = computed(() =>
    ['/bid-list', `/bid-detail/${currentRouteId.value}`].includes(currentRoute.value)
)
const isContractActive = computed(() =>
    ['/contracts-tasks', `/contracts/${currentRouteId.value}`].includes(currentRoute.value)
)
const isTaskActive = computed(() => currentRoute.value.startsWith('/tasks'))
const isInternalTaskActive = computed(() =>
    ['/internal-tasks', `/internal-tasks/${currentRouteId.value}/info`].includes(currentRoute.value)
)
const isCustomerActive = computed(() =>
    ['/customers', `/customers/${currentRouteId.value}`].includes(currentRoute.value)
)
const isDocumentsActive = computed(() =>
    ['/documents/my', '/documents/shared', '/documents/department', '/documents/permission', '/documents/settings']
        .includes(currentRoute.value)
)
const isSettingsActive = computed(() =>
    ['/settings/bidding', '/settings/contract'].includes(currentRoute.value)
)

// === Submenu selected keys (Documents/Settings) ===
const pathToKeyMap = {
    // Documents
    '/documents/my': 'documents-my',
    '/documents/shared': 'documents-shared',
    '/documents/department': 'documents-department',
    '/documents/permission': 'documents-permission',
    '/documents/settings': 'documents-settings',
    // Settings
    '/settings/bidding': 'settings-bidding',
    '/settings/contract': 'settings-contract',
}

const mapPathToKey = (path) => {
    if (pathToKeyMap[path]) return pathToKeyMap[path]
    const hit = Object.entries(pathToKeyMap).find(([p]) => path.startsWith(p + '/'))
    return hit ? hit[1] : undefined
}

const documentKeys = new Set([
    'documents-my',
    'documents-shared',
    'documents-department',
    'documents-permission',
    'documents-settings',
])
const settingKeys = new Set(['settings-bidding', 'settings-contract'])

const documentsSelectedKeys = computed(() => {
    const k = mapPathToKey(currentRoute.value)
    return k && documentKeys.has(k) ? [k] : []
})
const settingsSelectedKeys = computed(() => {
    const k = mapPathToKey(currentRoute.value)
    return k && settingKeys.has(k) ? [k] : []
})

// === Navigation ===
const navigateTo = (path) => router.push(path)
</script>




<style scoped>
.sidebar {
    width: 200px;
    min-width: 200px;
    max-width: 200px;
    background: #001529;
    height: 100vh;
    display: flex;
    flex-direction: column;
    overflow-y: auto;
    overflow-x: hidden;
    flex-shrink: 0;
    transition: all 0.2s ease;
}

.sidebar.collapsed {
    width: 60px;
    min-width: 60px;
    max-width: 60px;
}

/* Logo styling */
.logo-container {
    padding: 16px 8px;
    text-align: center;
    border-bottom: 1px solid #303030;
    flex-shrink: 0;
    position: relative;
}

.sidebar.collapsed .logo-container {
    padding: 16px 4px;
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
    font-size: 14px;
    font-weight: 600;
    line-height: 1;
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.logo-text-collapsed {
    color: #ffffff;
    font-size: 12px;
    font-weight: 600;
    line-height: 1;
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.logo-toggle {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    cursor: pointer;
    color: #ffffff;
    font-size: 12px;
    padding: 4px;
    border-radius: 2px;
    transition: all 0.2s ease;
}

.logo-toggle:hover {
    background-color: #1890ff;
}

.sidebar.collapsed .logo-toggle {
    right: 4px;
    font-size: 10px;
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
    flex-direction: row;
    align-items: center;
    justify-content: flex-start;
    text-align: left;
    padding: 12px 16px;
    height: 48px;
    min-height: 48px;
    margin: 0;
    cursor: pointer;
    transition: all 0.2s ease;
    position: relative;
}

.sidebar.collapsed .menu-item {
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 8px 4px;
    height: 60px;
    min-height: 60px;
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
    margin-right: 12px;
    color: #ffffff;
    flex-shrink: 0;
}

.sidebar.collapsed .menu-item .anticon {
    margin-right: 0;
    margin-bottom: 4px;
}

/* Text styling */
.menu-text {
    color: #ffffff;
    font-size: 12px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-align: left;
    flex: 1;
    transition: all 0.2s ease;
}

.sidebar.collapsed .menu-text {
    display: none;
}

.menu-text-collapsed {
    color: #ffffff;
    font-size: 10px;
    line-height: 1.2;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-align: center;
    max-width: 52px;
    margin-top: 4px;
}

/* Submenu styling */
.submenu {
    margin: 0;
}

.submenu-header {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-start;
    text-align: left;
    padding: 12px 16px;
    height: 48px;
    min-height: 48px;
    margin: 0;
    cursor: pointer;
    transition: all 0.2s ease;
    position: relative;
}

.sidebar.collapsed .submenu-header {
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 8px 4px;
    height: 60px;
    min-height: 60px;
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
    margin-right: 12px;
    color: #ffffff;
    flex-shrink: 0;
}

.sidebar.collapsed .submenu-header .anticon {
    margin-right: 0;
    margin-bottom: 4px;
}

.submenu-arrow {
    position: absolute;
    right: 16px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 10px;
    color: #ffffff;
    transition: all 0.2s ease;
}
.submenu-arrow-collapsed {
    position: absolute;
    right: 6px;
    top: 40%;
    transform: translateY(-50%);
    font-size: 10px;
    color: #ffffff;
    transition: all 0.2s ease;
}

.sidebar.collapsed .submenu-arrow {
    display: none;
}

.submenu-arrow-collapsed {
    position: absolute;
    right: 4px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 8px;
    color: #ffffff;
    transition: all 0.2s ease;
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
:deep(.ant-dropdown-menu-item-selected)  {
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
.logo-container {
    padding: 12px 16px;
}
.logo {
    display: flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
}
.logo-img {
    height: 28px;   /* chỉnh theo kích thước bạn muốn */
    width: auto;
    display: block;
}
.logo-text {
    font-weight: 600;
    font-size: 16px;
    color: #1f1f1f;
}
</style>
