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
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/project-overview' }"
                @click="navigateTo('/project-overview')"
                title="Tổng quan"
            >
                <BarChartOutlined />
                <span class="menu-text">Tổng quan</span>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/my-tasks' }"
                @click="navigateTo('/my-tasks')"
                title="Nhiệm vụ của tôi"
            >
                <ScheduleOutlined />
                <span class="menu-text">Nhiệm vụ của tôi</span>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/task-approvals' }"
                @click="navigateTo('/task-approvals')"
                title="Duyệt nhiệm vụ"
            >
                <CheckCircleOutlined />
                <span class="menu-text">Duyệt nhiệm vụ</span>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/quan-ly-khach-hang' }"
                @click="navigateTo('/quan-ly-khach-hang')"
                title="Quản lý khách hàng"
            >
                <TeamOutlined />
                <span class="menu-text">Quản lý khách hàng</span>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/bid-list' }"
                @click="navigateTo('/bid-list')"
                title="Gói thầu"
            >
                <FileSearchOutlined />
                <span class="menu-text">Gói thầu</span>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/contracts-tasks' }"
                @click="navigateTo('/contracts-tasks')"
                title="Hợp đồng"
            >
                <FileTextOutlined />
                <span class="menu-text">Hợp đồng</span>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/internal-tasks' }"
                @click="navigateTo('/internal-tasks')"
                title="Công việc"
            >
                <ToolOutlined />
                <span class="menu-text">Công việc</span>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/list-phong-ban' }"
                @click="navigateTo('/list-phong-ban')"
                title="Danh sách phòng ban"
            >
                <ApartmentOutlined />
                <span class="menu-text">Danh sách phòng ban</span>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/user-management' }"
                @click="navigateTo('/user-management')"
                title="Quản lý người dùng"
            >
                <TeamOutlined />
                <span class="menu-text">Quản lý người dùng</span>
            </div>
            
            <!-- Submenu Documents -->
            <div class="submenu">
                <div 
                    class="submenu-header"
                    :class="{ active: isDocumentsActive }"
                    @click="toggleSubmenu('documents')"
                    title="Tài liệu"
                >
                    <FileTextOutlined />
                    <span class="menu-text">Tài liệu</span>
                    <span class="submenu-arrow" :class="{ expanded: submenus.documents }">▼</span>
                </div>
                
                <div class="submenu-items" v-show="submenus.documents">
                    <div 
                        class="submenu-item"
                        :class="{ active: currentRoute === '/documents-my' }"
                        @click="navigateTo('/documents-my')"
                        title="Tài liệu của tôi"
                    >
                        <FileOutlined />
                        <span class="menu-text">Tài liệu của tôi</span>
                    </div>
                    
                    <div 
                        class="submenu-item"
                        :class="{ active: currentRoute === '/documents-department' }"
                        @click="navigateTo('/documents-department')"
                        title="Theo phòng ban"
                    >
                        <ApartmentOutlined />
                        <span class="menu-text">Theo phòng ban</span>
                    </div>
                    
                    <div 
                        class="submenu-item"
                        :class="{ active: currentRoute === '/documents-permission' }"
                        @click="navigateTo('/documents-permission')"
                        title="Phân quyền tài liệu"
                    >
                        <LockOutlined />
                        <span class="menu-text">Phân quyền tài liệu</span>
                    </div>
                    
                    <div 
                        class="submenu-item"
                        :class="{ active: currentRoute === '/documents-settings' }"
                        @click="navigateTo('/documents-settings')"
                        title="Cấu hình tài liệu"
                    >
                        <SettingOutlined />
                        <span class="menu-text">Cấu hình tài liệu</span>
                    </div>
                </div>
            </div>
            
            <!-- Submenu Settings -->
            <div class="submenu">
                <div 
                    class="submenu-header"
                    :class="{ active: isSettingsActive }"
                    @click="toggleSubmenu('settings')"
                    title="Cấu hình chung"
                >
                    <SettingOutlined />
                    <span class="menu-text">Cấu hình chung</span>
                    <span class="submenu-arrow" :class="{ expanded: submenus.settings }">▼</span>
                </div>
                
                <div class="submenu-items" v-show="submenus.settings">
                    <div 
                        class="submenu-item"
                        :class="{ active: currentRoute === '/cau-hinh-dau-thau' }"
                        @click="navigateTo('/cau-hinh-dau-thau')"
                        title="Đấu thầu"
                    >
                        <FileDoneOutlined />
                        <span class="menu-text">Đấu thầu</span>
                    </div>
                    
                    <div 
                        class="submenu-item"
                        :class="{ active: currentRoute === '/cau-hinh-hop-dong' }"
                        @click="navigateTo('/cau-hinh-hop-dong')"
                        title="Hợp đồng"
                    >
                        <ProfileOutlined />
                        <span class="menu-text">Hợp đồng</span>
                    </div>
                </div>
            </div>
            
            <div 
                class="menu-item"
                :class="{ active: currentRoute === '/permission' }"
                @click="navigateTo('/permission')"
                title="Phân quyền"
            >
                <TeamOutlined />
                <span class="menu-text">Phân quyền</span>
            </div>
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

const props = defineProps({
    user: {
        type: Object,
        required: true
    }
})

const emit = defineEmits(['logout'])

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const { user: currentUser } = storeToRefs(userStore)

// Current route
const currentRoute = computed(() => route.path)

// Submenu state
const submenus = ref({
    documents: false,
    settings: false
})

// Check if submenu should be active
const isDocumentsActive = computed(() => {
    return ['/documents-my', '/documents-department', '/documents-permission', '/documents-settings'].includes(currentRoute.value)
})

const isSettingsActive = computed(() => {
    return ['/cau-hinh-dau-thau', '/cau-hinh-hop-dong'].includes(currentRoute.value)
})

// Navigation function
const navigateTo = (path) => {
    router.push(path)
}

// Toggle submenu
const toggleSubmenu = (submenuKey) => {
    submenus.value[submenuKey] = !submenus.value[submenuKey]
}

// Auto-open submenu when route matches
watch(currentRoute, (newRoute) => {
    if (isDocumentsActive.value) {
        submenus.value.documents = true
    }
    if (isSettingsActive.value) {
        submenus.value.settings = true
    }
}, { immediate: true })
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
    transition: transform 0.2s ease;
}

.submenu-arrow.expanded {
    transform: translateY(-50%) rotate(180deg);
}

/* Submenu items */
.submenu-items {
    background: #001529;
}

.submenu-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 6px 4px;
    height: 40px;
    min-height: 40px;
    margin: 0;
    cursor: pointer;
    transition: background-color 0.2s ease;
    padding-left: 16px;
}

.submenu-item:hover {
    background-color: #1890ff;
}

.submenu-item.active {
    background-color: #1890ff;
}

.submenu-item .anticon {
    display: block;
    font-size: 14px;
    margin-bottom: 2px;
    color: #ffffff;
}

.submenu-item .menu-text {
    font-size: 9px;
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
</style>
