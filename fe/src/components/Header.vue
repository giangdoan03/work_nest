<template>
    <div class="header">
        <a-layout-header
            style="background: #fff; padding: 0; display: flex; justify-content: space-between; align-items: center;">
            <!-- Toggle button -->
            <div style="margin-left: 16px;">
                <a-button type="text" @click="$emit('toggle')" style="border: none; box-shadow: none;">
                    <MenuFoldOutlined v-if="!collapsed"/>
                    <MenuUnfoldOutlined v-else/>
                </a-button>
            </div>

            <!-- Breadcrumb -->
            <div style="flex: 1; margin-left: 16px;">
                <a-breadcrumb :key="$route.fullPath" style="margin-left:16px;">
                    <a-breadcrumb-item v-for="(route, index) in breadcrumbs" :key="index">
                        <router-link v-if="route.name !== currentRoute.name" :to="route.to || { name: route.name }">
                            {{ route.meta.breadcrumb }}
                        </router-link>
                        <template v-else>
                          <span style="display:inline-flex;align-items:center;gap:4px;">
                            {{ route.meta.breadcrumb }}
                            <a-button
                                v-if="currentRoute.name === 'tasks'"
                                size="small"
                                @click="onClickCreateTask"
                                style="margin-left:8px"
                            >
                              <template #icon><PlusOutlined/></template>
                            </a-button>
                          </span>
                        </template>
                    </a-breadcrumb-item>
                </a-breadcrumb>
            </div>

            <!-- User Dropdown -->
            <!-- Right actions -->
            <div class="right-actions">
                <a-tooltip title="Đánh dấu">
                    <BookOutlined class="ha-icon" @click="onBookmark"/>
                </a-tooltip>

                <a-tooltip title="Trang chủ">
                    <a-button class="home-chip" shape="circle" @click="goHome">
                        <HomeOutlined />
                    </a-button>
                </a-tooltip>

                <a-tooltip title="Tin nhắn">
                    <a-badge :count="unreadChat" size="small">
                        <MessageOutlined class="ha-icon" @click="openChat"/>
                    </a-badge>
                </a-tooltip>

                <a-tooltip title="Thông báo">
                    <a-badge :count="unreadNotify" size="small">
                        <BellOutlined class="ha-icon" @click="openNotify"/>
                    </a-badge>
                </a-tooltip>

                <!-- Avatar dropdown -->
                <a-dropdown v-if="user" trigger="click" placement="bottomRight" :getPopupContainer="n => n.parentNode">
                    <div @click.prevent class="user-chip">
                        <a-avatar size="large" :src="user.avatarUrl">
                            <template #icon><UserOutlined/></template>
                        </a-avatar>
                    </div>

                    <template #overlay>
                        <div class="user-dropdown">
                            <!-- Header -->
                            <div class="user-header">
                                <a-avatar size="large" :src="user.avatarUrl" />
                                <div class="user-info">
                                    <div class="name">{{ user.name }}</div>
                                    <div class="position">{{ user.position || 'Chức danh' }}</div>
                                    <div class="department">{{ user.department || 'Phòng ban' }}</div>
                                </div>
                            </div>

                            <div class="user-menu">
                                <div class="user-item" @click="redirectToProfile">
                                    <UserOutlined /> Tài khoản
                                </div>
                                <div class="user-item">
                                    <SettingOutlined /> Cài đặt hệ thống
                                </div>
                                <div class="user-item">
                                    <FileTextOutlined /> Thông tin đối soát
                                </div>
                                <div class="user-item">
                                    <QuestionCircleOutlined /> Hướng dẫn sử dụng
                                </div>
                                <div class="user-item">
                                    <BgColorsOutlined /> Màu giao diện
                                    <div class="color-dot"></div>
                                </div>
                                <div class="user-item">
                                    <GlobalOutlined /> Ngôn ngữ <span style="margin-left:auto">VN</span>
                                </div>
                                <div class="user-item" @click="changePwdOpen = true">
                                    <KeyOutlined /> Đổi mật khẩu
                                </div>
                                <div class="user-item danger" @click="handleLogout">
                                    <LogoutOutlined /> Đăng xuất
                                </div>
                            </div>
                        </div>
                    </template>
                </a-dropdown>

            </div>
        </a-layout-header>
        <ChangePasswordModal
            v-model:open="changePwdOpen"
            :user-id="user?.id"
            :user-name="user?.name"
            :user-phone="user?.phone"
        />
    </div>
</template>

<script setup>
import {useRoute, useRouter} from 'vue-router'
import { message } from 'ant-design-vue';
import { ref } from 'vue'
import {computed} from 'vue'
import {storeToRefs} from 'pinia'
import {useUserStore} from '../stores/user'
import {
    MenuUnfoldOutlined,
    MenuFoldOutlined,
    LogoutOutlined,
    DownOutlined,
    UserOutlined,
    PlusOutlined,
    BookOutlined, HomeOutlined, MessageOutlined, BellOutlined,
    SettingOutlined,
    FileTextOutlined,
    QuestionCircleOutlined,
    BgColorsOutlined,
    GlobalOutlined,
    KeyOutlined
} from '@ant-design/icons-vue'

import ChangePasswordModal from '../components/common/ChangePasswordModal.vue'

const changePwdOpen = ref(false)

const props = defineProps({
    collapsed: Boolean,
    user: Object
})


import {useCommonStore} from '@/stores/common'

const common = useCommonStore()

const onClickCreateTask = () => {
    if (currentRoute.name === 'tasks' /* hoặc 'internal-tasks' */) {
        common.triggerCreateTask('internal')
    }
}


const emit = defineEmits(['toggle', 'logout'])

const userStore = useUserStore()
const {user} = storeToRefs(userStore)

const currentRoute = useRoute()
const router = useRouter()

// Header.vue <script setup> — cập nhật breadcrumbs
const breadcrumbs = computed(() => {
    const all = router.getRoutes()
    const p = currentRoute.params

    const buildParams = {
        'bid-list':            () => ({}),
        'biddings-info':       () => ({ id: p.id || p.bidId }),     // id của gói
        'bidding-step-tasks':  () => ({ bidId: p.bidId, stepId: p.stepId }),
        'bidding-task-info':   () => ({ id: p.id }),
        'internal-tasks':      () => ({}),
        'internal-tasks-info': () => ({ id: p.id }),
        'tasks':               () => ({}),
    }

    const trail = []
    let cur = all.find(r => r.name === currentRoute.name)

    while (cur) {
        if (cur.meta?.breadcrumb) {
            trail.unshift({
                name: cur.name,
                meta: cur.meta,
                to: { name: cur.name, params: (buildParams[cur.name]?.() || {}) }
            })
        }
        const parentName = cur.meta?.parent
        cur = parentName ? all.find(r => r.name === parentName) : null
    }

    return trail
})

const unreadChat = ref(1)         // badge "1" như ảnh
const unreadNotify = ref(0)

const goHome = () => router.push('/project-overview')
const openChat = () => router.push('/tasks')          // đổi route chat thật của bạn
const openNotify = () => router.push('/task-approvals')  // đổi route thông báo thật
const onBookmark = () => { /* toggle đánh dấu… */ }

const handleLogout = () => {
    userStore.clearUser()     // 👉 Xoá user + quyền
    router.push('/')          // 👉 Về trang login/home
}
const redirectToProfile = () => {
    router.push({
        name: 'persons-info',
        params: {
            id: user.value.id
        }
    })
}
</script>

<style scoped>
.header {
    width: 100%;
}

.trigger {
    font-size: 18px;
    line-height: 64px;
    padding: 0 24px;
    cursor: pointer;
    transition: color 0.3s;
}

.trigger:hover {
    color: #1890ff;
}
.right-actions{
    margin-right: 16px;
    display:flex; align-items:center; gap:16px;
}

/* Icon xám, hover cam */
.ha-icon{
    font-size:20px; color:#8c8c8c; cursor:pointer; transition:color .2s, transform .2s;
}
.ha-icon:hover{ color:#fa8c16; transform: translateY(-1px); }

/* Nút nhà màu cam (nền nhạt + icon cam) */
.home-chip{
    width:36px; height:36px; padding:0; border:none;
    background:#fff7e6; /* cam nhạt */
    display:flex; align-items:center; justify-content:center;
    box-shadow:none;
}
.home-chip :deep(.anticon){ color:#fa8c16; font-size:18px; }
.home-chip:hover{ background:#ffe7ba; }

/* Avatar */
.user-chip{ display:flex; align-items:center; cursor:pointer; }

.user-dropdown {
    width: 320px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.12);
    overflow: hidden;
}

.user-header {
    display: flex;
    align-items: center;
    padding: 16px;
    border-bottom: 1px solid #f0f0f0;
}

.user-info {
    margin-left: 12px;
    flex: 1;
}

.user-info .name {
    font-weight: 600;
    font-size: 16px;
    color: #fa541c; /* cam */
}

.user-info .position,
.user-info .department {
    font-size: 13px;
    color: #888;
}

.user-menu {
    display: flex;
    flex-direction: column;
}

.user-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 16px;
    cursor: pointer;
    transition: background 0.2s;
    font-size: 14px;
}

.user-item:hover {
    background: #f5f5f5;
}

.user-item.danger {
    color: #ff4d4f;
}

.color-dot {
    width: 16px;
    height: 16px;
    border-radius: 50%;
    background: #fa541c;
    margin-left: auto;
}

</style>
