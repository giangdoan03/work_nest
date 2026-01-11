<template>
    <div class="sidebar" :class="{ collapsed }">
        <div
            class="menu-top-icon"
            :class="{ active: isOverviewActive }"
            @click="openTopDrawer"
            @keydown.enter.prevent="openTopDrawer"
            @keydown.space.prevent="openTopDrawer"
            role="button"
            tabindex="0"
            aria-label="Mở menu nhanh"
        >
            <img
                v-if="collapsed"
                src="/logo_cv.png"
                class="menu-top-logo"
                alt="TTID"
            />

            <span v-else class="menu-text">
                <img
                    src="/logo_ex.png"
                    class="menu-top-logo"
                    alt="TTID"
                />
            </span>

        </div>

        <!-- Menu -->
        <nav class="menu">
            <!-- 1. Tổng quan -->
            <a-tooltip placement="right" title="Tổng quan" v-if="collapsed">
                <div class="menu-item" :class="{ active: isOverviewActive }" @click="navigateTo('/project-overview')">
                    <BarChartOutlined/>
                    <div class="menu-text-collapsed">Tổng quan</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isOverviewActive }"
                 @click="navigateTo('/project-overview')">
                <BarChartOutlined/>
                <span class="menu-text">Tổng quan</span>
            </div>

            <!-- 2. Gói thầu -->
            <a-tooltip placement="right" title="Gói thầu" v-if="collapsed">
                <div class="menu-item" :class="{ active: isBiddingActive }" @click="navigateTo('/bid-list')">
                    <FileSearchOutlined/>
                    <div class="menu-text-collapsed">Gói thầu</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isBiddingActive }" @click="navigateTo('/bid-list')">
                <FileSearchOutlined/>
                <span class="menu-text">Gói thầu</span>
            </div>

            <!-- 3. Hợp đồng -->
            <a-tooltip placement="right" title="Hợp đồng" v-if="collapsed">
                <div class="menu-item" :class="{ active: isContractActive }" @click="navigateTo('/contract-list')">
                    <FileTextOutlined/>
                    <div class="menu-text-collapsed">Hợp đồng</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isContractActive }" @click="navigateTo('/contract-list')">
                <FileTextOutlined/>
                <span class="menu-text">Hợp đồng</span>
            </div>

            <!-- 7. Quản lý dữ liệu công việc (Việc quy trình) -->
            <a-tooltip placement="right" title="Việc quy trình" v-if="collapsed">
                <div class="menu-item" :class="{ active: isInternalTaskActive }" @click="navigateTo('/workflow')">
                    <ProjectOutlined/>
                    <div class="menu-text-collapsed">Việc quy trình</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isInternalTaskActive }"
                 @click="navigateTo('/workflow')">
                <ProjectOutlined/>
                <span class="menu-text">Việc quy trình</span>
            </div>


            <!-- 4. Việc không quy trình -->
            <a-tooltip placement="right" title="Việc không quy trình" v-if="collapsed">
                <div class="menu-item" :class="{ active: isTaskActive }" @click="navigateTo('/non-workflow')">
                    <UnorderedListOutlined/>
                    <div class="menu-text-collapsed">Việc không quy trình</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: isTaskActive }" @click="navigateTo('/non-workflow')">
                <UnorderedListOutlined/>
                <span class="menu-text">Việc không quy trình</span>
            </div>

            <!-- 5. Công việc cá nhân -->
            <a-tooltip placement="right" title="Công việc cá nhân" v-if="collapsed">
                <div class="menu-item" :class="{ active: currentRoute === '/my-tasks' }"
                     @click="navigateTo('/my-tasks')">
                    <UserOutlined/>
                    <div class="menu-text-collapsed">Công việc cá nhân</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: currentRoute === '/my-tasks' }"
                 @click="navigateTo('/my-tasks')">
                <UserOutlined/>
                <span class="menu-text">Công việc cá nhân</span>
            </div>

            <!-- 6. Duyệt công văn -->
            <a-tooltip placement="right" title="Duyệt công văn" v-if="collapsed">
                <div class="menu-item" :class="{ active: currentRoute === '/task-approvals' }"
                     @click="navigateTo('/task-approvals')">
                    <CheckCircleOutlined/>
                    <div class="menu-text-collapsed">Duyệt công văn</div>
                </div>
            </a-tooltip>
            <div v-else class="menu-item" :class="{ active: currentRoute === '/task-approvals' }"
                 @click="navigateTo('/task-approvals')">
                <CheckCircleOutlined/>
                <span class="menu-text">Duyệt công văn</span>
            </div>

            <!-- 8. Tài liệu (submenu) -->
            <div class="submenu">
                <div v-if="!collapsed">
                    <a-dropdown placement="rightTop" :trigger="['hover']" :getPopupContainer="p => p.parentNode">
                        <div class="submenu-header" :class="{ active: isDocumentsActive }">
                            <FileTextOutlined/>
                            <span class="menu-text">Tài liệu</span>
                            <span class="submenu-arrow">▼</span>
                        </div>

                        <template #overlay>
                            <a-menu :selectedKeys="documentsSelectedKeys">
                                <a-menu-item key="documents-department" @click="navigateTo('/documents')">
                                    <ApartmentOutlined style="margin-right: 12px;"/>
                                    <span>Theo phòng ban</span>
                                </a-menu-item>

                                <a-menu-item key="documents-my" @click="navigateTo('/my-documents')">
                                    <FileOutlined style="margin-right: 12px;"/>
                                    <span>Tài liệu của tôi</span>
                                </a-menu-item>


                            </a-menu>
                        </template>
                    </a-dropdown>
                </div>

                <!-- collapsed -->
                <div v-else>
                    <a-dropdown placement="rightTop" :trigger="['hover']" :getPopupContainer="p => p.parentNode">
                        <div class="submenu-header" :class="{ active: isDocumentsActive }">
                            <FileTextOutlined/>
                            <span class="menu-text-collapsed">Tài liệu</span>
                            <span class="submenu-arrow-collapsed">▼</span>
                        </div>

                        <template #overlay>
                            <a-menu :selectedKeys="documentsSelectedKeys">
                                <a-menu-item key="documents-department" @click="navigateTo('/documents')">
                                    <ApartmentOutlined style="margin-right: 12px;"/>
                                    <span>Theo phòng ban</span>
                                </a-menu-item>

                                <a-menu-item key="documents-my" @click="navigateTo('/my-documents')">
                                    <FileOutlined style="margin-right: 12px;"/>
                                    <span>Tài liệu của tôi</span>
                                </a-menu-item>

                            </a-menu>
                        </template>
                    </a-dropdown>
                </div>
            </div>
            <!-- 9. Hướng dẫn sử dụng -->
            <a-tooltip placement="right" title="Hướng dẫn sử dụng" v-if="collapsed">
                <div class="menu-item"
                     :class="{ active: currentRoute === '/user-guide' }"
                     @click="navigateTo('/user-guide')">
                    <BookOutlined/>
                    <div class="menu-text-collapsed">Hướng dẫn</div>
                </div>
            </a-tooltip>

            <div v-else class="menu-item"
                 :class="{ active: currentRoute === '/user-guide' }"
                 @click="navigateTo('/user-guide')">
                <BookOutlined/>
                <span class="menu-text">Hướng dẫn sử dụng</span>
            </div>

        </nav>

        <a-drawer
            v-model:open="topDrawerOpen"
            placement="left"
            width="460"
            :closable="false"
            :bodyStyle="{ padding: 0, background: 'var(--qm-bg)' }"
            :class="'menu-extend'"
        >
            <!-- Header đẹp hơn -->
            <template #title>
                <div class="qm-header">
                    <div class="qm-brand">
                        <img :src="'/TTID_logo.png'" alt="Menu logo" class="qm-logo"/>
                    </div>
                </div>
            </template>

            <!-- Nội dung -->
            <div class="qm-content">
                <section
                    v-for="group in quickGroups"
                    :key="group.key"
                    class="qm-section"
                >
                    <div class="qm-section-head">
                        <h4 class="qm-section-title">{{ group.title }}</h4>
                        <span class="qm-divider" aria-hidden="true"></span>
                    </div>

                    <div class="qm-grid">
                        <button
                            v-for="item in group.items"
                            :key="item.path"
                            class="qm-card"
                            type="button"
                            @click="navAndClose(item.path)"
                        >
                                  <span class="qm-icon-box" :class="item.color">
                                    <component :is="item.icon"/>
                                    <i class="shine" aria-hidden="true"></i>
                                  </span>
                            <span class="qm-card-title">{{ item.label }}</span>
                        </button>
                    </div>
                </section>
            </div>
        </a-drawer>


    </div>
</template>

<script setup>
import {ref, computed} from 'vue'
import {useRoute, useRouter} from 'vue-router'

const navigateTo = (path) => router.push(path)
import {
    BarChartOutlined,
    FileSearchOutlined,
    FileTextOutlined,
    UnorderedListOutlined,
    UserOutlined,
    ProjectOutlined,
    FileOutlined,
    ApartmentOutlined,
    LockOutlined,
    SettingOutlined,
    FileDoneOutlined,
    ProfileOutlined,
    TeamOutlined,
    GlobalOutlined,
    CheckCircleOutlined,
    WalletOutlined,
    AppstoreOutlined,
    BookOutlined,
    ApiOutlined,
    CalendarOutlined,
} from '@ant-design/icons-vue'

const props = defineProps({
    collapsed: {type: Boolean, default: false},
})

const route = useRoute()
const router = useRouter()

// === Helpers ===
const currentPath = computed(() => route.path)
const currentRouteId = computed(() => route.params.id)
const currentRoute = currentPath // alias cho template cũ

/** Kiểm tra theo meta.section trên các route */
const isSection = (section) => route.matched.some(r => r.meta?.section === section)

/** Fallback regex cho các path cũ chưa set meta.section */
const isBiddingLikePath = (p) => (
    p === '/bid-list' ||
    p.startsWith('/bid-detail/') ||
    p.startsWith('/biddings/') ||
    /^\/bidding-tasks\/\d+\/info$/.test(p) ||
    /^\/biddings\/\d+\/steps\/\d+\/tasks\/?$/.test(p)
)

// ✅ Giống isBiddingLikePath nhưng cho Contract
const isContractLikePath = (p) => (
    p === '/contract-list' ||                                   // danh sách nhiệm vụ theo hợp đồng
    /^\/contracts\/\d+\/?$/.test(p) ||                            // chi tiết hợp đồng: /contracts/66
    /^\/contract\/\d+\/steps\/\d+\/tasks\/?$/.test(p) ||          // danh sách task trong step: /contract/66/steps/363/tasks
    /^\/contract\/\d+\/steps\/\d+\/tasks\/\d+\/info\/?$/.test(p)  // trang info task: /contract/66/steps/363/tasks/249/info
)

// ✅ Non-workflow (việc không quy trình)
const isNonWorkflowLikePath = (p) => (
    /^\/non-workflow\/?$/.test(p) ||                                  // /non-workflow
    /^\/non-workflow\/tasks\/\d+(?:\/info)?\/?$/.test(p)               // /non-workflow/tasks/293/info (hoặc /tasks/293)
)

// ✅ Workflow (việc có quy trình) — gom cả /workflow và mọi nhánh con
const isWorkflowLikePath = (p) => (
    /^\/workflow(?:\/.*)?$/.test(p)                                    // /workflow, /workflow/...
)


const isInternalTasksLikePath = (p) => p.startsWith('/workflow')

const isOverviewLikePath = (p) => (
    p === '/project-overview' ||
    /^\/department-task\/\d+\/info$/.test(p)   // match /department-task/27/info
)

// === Active states (đặt ở top-level) ===
const isOverviewActive = computed(() => isOverviewLikePath(route.path))

const isBiddingActive = computed(() => isSection('bidding') || isBiddingLikePath(currentPath.value))

const isContractActive = computed(() => isSection('contract') || isContractLikePath(currentPath.value))

const isTaskActive = computed(() =>
    isSection('non-workflow') || isNonWorkflowLikePath(currentPath.value)
)

const isInternalTaskActive = computed(() =>
    isSection('workflow') || isWorkflowLikePath(currentPath.value)
)
const isCustomerActive = computed(() =>
    ['/customers', `/customers/${currentRouteId.value}`].includes(currentPath.value)
)
const isDocumentsActive = computed(() =>
    ['/documents', '/my-documents'].includes(currentPath.value)
)
const isSettingsActive = computed(() =>
    ['/settings/bidding', '/settings/contract'].includes(currentPath.value)
)

const isUserGuideActive = computed(() => currentPath.value === '/user-guide')

// === Submenu selected keys (Documents/Settings) ===
const pathToKeyMap = {
    '/documents': 'documents-department',
    '/my-documents': 'documents-my',
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
    const k = mapPathToKey(currentPath.value)
    return k && documentKeys.has(k) ? [k] : []
})
const settingsSelectedKeys = computed(() => {
    const k = mapPathToKey(currentPath.value)
    return k && settingKeys.has(k) ? [k] : []
})

// === Drawer top icon ===
const topDrawerOpen = ref(false)
const openTopDrawer = () => {
    topDrawerOpen.value = true
}
const navAndClose = (path) => {
    topDrawerOpen.value = false
    router.push(path)
}
const quickGroups = [
    {
        key: 'work',
        title: 'Công việc',
        items: [
            {path: '/project-overview', icon: GlobalOutlined, color: 'blue', label: 'Tổng quan'},
            // { path: '/tasks',            icon: CheckCircleOutlined, color: 'green',  label: 'Công việc' },
            {path: '/bid-list', icon: WalletOutlined, color: 'orange', label: 'Gói thầu'},
            {path: '/contracts-tasks', icon: FileDoneOutlined, color: 'purple', label: 'Hợp đồng'},
            {path: '/workflow', icon: AppstoreOutlined, color: 'purple', label: 'Việc quy trình'},
            {path: '/non-workflow', icon: UnorderedListOutlined, color: 'sky', label: 'Việc không quy trình'},
            {path: '/my-documents', icon: BookOutlined, color: 'red', label: 'Tài liệu'}
        ],
    },
    {
        key: 'settings',
        title: 'Cài đặt',
        items: [
            {path: '/departments', icon: ApartmentOutlined, color: 'blue', label: 'Phòng ban'},
            {path: '/user-management', icon: TeamOutlined, color: 'green', label: 'Quản lý người dùng'},
            {path: '/settings/bidding', icon: FileDoneOutlined, color: 'orange', label: 'Cấu hình đấu thầu'},
            {path: '/settings/contract', icon: ProfileOutlined, color: 'purple', label: 'Cấu hình hợp đồng'},
        ],
    },
    {
        key: 'extensions',
        title: 'Mở rộng',
        items: [
            {path: '/customers', icon: TeamOutlined, color: 'sky', label: 'Khách hàng'},
            {path: '/calendar', icon: CalendarOutlined, color: 'pink', label: 'Lịch biểu'},
            {path: '/reports', icon: FileTextOutlined, color: 'orange', label: 'Văn bản'},
            {path: '/user-guide', icon: BookOutlined, color: 'purple', label: 'Hướng dẫn'},
        ],
    },
]


</script>


<style scoped>
.sidebar {
    width: 200px;
    min-width: 200px;
    max-width: 200px;
    background: #003b6d;
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

.ant-dropdown-menu-item:hover,
.ant-dropdown-menu-item:hover {
    background-color: #1890ff !important;
    color: #ffffff !important;
}

/* Active state for menu items */
:deep(.ant-dropdown-menu-item-selected) {
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
    height: 28px; /* chỉnh theo kích thước bạn muốn */
    width: auto;
    display: block;
}

.logo-text {
    font-weight: 600;
    font-size: 16px;
    color: #1f1f1f;
}

.menu-top-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 60px;
    font-size: 22px;
    color: #ffffff;
    cursor: pointer;
    transition: all 0.3s;
    padding-left: 16px;
}

.menu-top-icon:hover {
    color: #1890ff;
    background: rgba(24, 144, 255, 0.1);
}

.menu-top-icon:hover .menu-text {
    color: #1890ff;
}

.menu-top-icon.active {
    color: #1890ff; /* màu active giống ảnh bạn gửi */
}

.menu-top-icon.active .menu-text {
    color: #1890ff; /* màu active giống ảnh bạn gửi */
}

.menu-top-icon .menu-text {
    margin-left: 8px;
    font-size: 14px;
    color: #fff;
}

.sidebar.collapsed .menu-top-icon {
    padding-left: 0; /* ✅ về 0 như bạn muốn */
    padding-right: 0; /* cho cân giữa */
    justify-content: center; /* icon ra giữa */
}

/* giữ như trước, chỉ bổ sung collapsed padding-left = 0 */
.sidebar.collapsed .menu-top-icon {
    padding-left: 0;
    padding-right: 0;
    justify-content: center;
}


/* Tăng size ô & icon trong Menu nhanh */
.quick-menu .icon-box {
    width: 60px; /* trước 60 */
    height: 60px; /* trước 60 */
    border-radius: 14px; /* hơi bầu hơn */
    display: flex;
    align-items: center;
    justify-content: center;
    /* dùng CSS variables để dễ tuỳ biến */
    --icon-size: 25px; /* trước 28 */
    --icon-color: inherit;
}

/* Đảm bảo icon nhận size & màu (vì style scoped) */
.quick-menu .icon-box :deep(.anticon) {
    font-size: var(--icon-size);
    color: var(--icon-color);
}

/* Hiệu ứng hover nhẹ */
.quick-menu .quick-item:hover .icon-box {
    transform: translateY(-2px) scale(1.03);
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
    transition: transform .2s, box-shadow .2s;
}


.quick-item span {
    font-size: 15px;
    color: #333;
    text-align: center;
}

.menu-top-icon .menu-text {
    font-size: 12px;
}


.quick-item span {
    font-size: 15px;
    color: #333;
    text-align: center;
}


/* ================= Quick Menu – Pro look ================= */
:root {
    --qm-bg: #f7f8fa;
    --qm-card-bg: #fff;
    --qm-border: rgba(15, 23, 42, .06);
    --qm-shadow: 0 6px 18px rgba(15, 23, 42, .06);
    --qm-shadow-lg: 0 10px 28px rgba(15, 23, 42, .08);
    --qm-radius: 16px;
}

:deep(.ant-drawer-header) {
    padding: 14px 16px;
    border-bottom: 1px solid var(--qm-border) !important;
    background: #fff;
}

.qm-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.qm-brand {
    display: flex;
    align-items: center;
    gap: 12px;
}

.qm-logo {
    height: 60px;
    width: auto;
    display: block;
}

.qm-brand-text .title {
    font-weight: 700;
    letter-spacing: .2px;
    font-size: 16px;
    line-height: 1.1;
    color: #111827;
}

.qm-brand-text .sub {
    font-size: 12px;
    color: #6b7280;
    margin-top: 2px;
}

/* Content wrapper */
.qm-content {
    padding: 14px 16px 20px;
    background: var(--qm-bg);
}

/* Section */
.qm-section {
    background: var(--qm-card-bg);
    border: 1px solid var(--qm-border);
    border-radius: var(--qm-radius);
    padding: 14px 14px 16px;
    margin-bottom: 14px;
    box-shadow: var(--qm-shadow);
}

.qm-section-head {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
}

.qm-section-title {
    margin: 0;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: .08em;
    color: #64748b;
    text-transform: uppercase;
}

.qm-divider {
    height: 1px;
    background: var(--qm-border);
    flex: 1;
    border-radius: 999px;
}

/* Grid */
.qm-grid {
    display: grid;
    gap: 16px;
    grid-template-columns: repeat(4, minmax(0, 1fr));
}

@media (max-width: 520px) {
    .qm-grid {
        grid-template-columns: repeat(3, 1fr);
    }
}

@media (max-width: 420px) {
    .qm-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}

/* Card */
.qm-card {
    appearance: none;
    border: 1px solid var(--qm-border);
    background: #fff;
    border-radius: 14px;
    padding: 14px 10px 12px;
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
    cursor: pointer;
    text-align: center;
    box-shadow: 0 0 0 rgba(0, 0, 0, 0);
}

.qm-card:focus-visible {
    outline: none;
    box-shadow: 0 0 0 3px rgba(24, 144, 255, .18);
}

.qm-card:hover {
    transform: translateY(-3px);
    border-color: rgba(24, 144, 255, .25);
    box-shadow: var(--qm-shadow-lg);
}

/* Icon box (reuse màu pastel bạn đã có) */
.qm-icon-box {
    --icon-size: 26px;
    width: 58px;
    height: 58px;
    border-radius: 14px;
    display: grid;
    place-items: center;
    position: relative;
    box-shadow: inset 0 0 0 1px rgba(255, 255, 255, .7), 0 8px 20px rgba(0, 0, 0, .04);
    overflow: hidden;
}

.qm-icon-box :deep(.anticon) {
    font-size: var(--icon-size);
    color: var(--fg, #111);
}

/* Pastel palettes (khớp class color hiện có) */
/* xanh dương */
.qm-icon-box.blue {
    --fg: #155eef; /* đậm hơn #1677ff */
    background: linear-gradient(180deg, #dcebff, #cfe2ff);
    border: 1px solid rgba(21, 94, 239, .28);
}

/* xanh lá */
.qm-icon-box.green {
    --fg: #16a34a;
    background: linear-gradient(180deg, #def7ea, #d6f3e3);
    border: 1px solid rgba(22, 163, 74, .28);
}

/* cam */
.qm-icon-box.orange {
    --fg: #d97706;
    background: linear-gradient(180deg, #ffe9cc, #ffe0b8);
    border: 1px solid rgba(217, 119, 6, .28);
}

/* tím */
.qm-icon-box.purple {
    --fg: #7c3aed;
    background: linear-gradient(180deg, #efe6ff, #e6dbff);
    border: 1px solid rgba(124, 58, 237, .28);
}

/* đỏ */
.qm-icon-box.red {
    --fg: #dc2626;
    background: linear-gradient(180deg, #ffe0e0, #ffd6d6);
    border: 1px solid rgba(220, 38, 38, .28);
}

/* sky/azure */
.qm-icon-box.sky {
    --fg: #1273ff;
    background: linear-gradient(180deg, #dff1ff, #d4ecff);
    border: 1px solid rgba(18, 115, 255, .28);
}

/* hồng */
.qm-icon-box.pink {
    --fg: #db2777;
    background: linear-gradient(180deg, #ffe1f0, #ffd6ea);
    border: 1px solid rgba(219, 39, 119, .28);
}

/* giữ màu icon theo --fg */
.qm-icon-box.purple :deep(.anticon),
.qm-icon-box.blue :deep(.anticon),
.qm-icon-box.green :deep(.anticon),
.qm-icon-box.orange :deep(.anticon),
.qm-icon-box.red :deep(.anticon),
.qm-icon-box.sky :deep(.anticon),
.qm-icon-box.pink :deep(.anticon) {
    color: var(--fg);
}

/* nhấn mạnh thêm khi hover */
.qm-card:hover .qm-icon-box {
    filter: saturate(1.12) contrast(1.06);
    box-shadow: inset 0 0 0 1px rgba(255, 255, 255, .75), 0 10px 24px rgba(0, 0, 0, .06);
}

/* Light shine */
.qm-icon-box .shine {
    position: absolute;
    inset: 0;
    pointer-events: none;
    background: radial-gradient(120px 60px at -20% -20%, rgba(255, 255, 255, .65), transparent 60%),
    radial-gradient(140px 80px at 120% 120%, rgba(255, 255, 255, .35), transparent 55%);
    mix-blend-mode: screen;
}

/* Card title */
.qm-card-title {
    font-size: 13px;
    line-height: 1.2;
    color: #111827;
    text-wrap: balance;
}

/* Logo trong menu-top-icon */
.menu-top-logo {
    display: block;
    height: 35px; /* chiều cao mặc định khi expanded */
    width: auto;
    transition: transform .2s ease, opacity .2s ease;
}

/* Khi sidebar collapsed, tăng size nhẹ cho icon mark cho cân */
.sidebar.collapsed .menu-top-logo {
    height: 40px; /* mark thường nhỏ hơn chữ, tăng chút cho cân */
}

/* Hover effect đồng bộ */
.menu-top-icon:hover .menu-top-logo {
    transform: translateY(-1px);
    opacity: 0.95;
}


</style>
<style>
    .menu-extend .ant-drawer-header {
        padding: 5px 24px;
    }
</style>
