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

            <!-- Right actions -->
            <div class="right-actions">

                <a-tooltip title="Trang chủ">
                    <a-button class="home-chip" shape="circle" @click="goHome">
                        <HomeOutlined />
                    </a-button>
                </a-tooltip>

<!--                <a-tooltip title="Tin nhắn">-->
<!--                    <a-badge :count="unreadChat" size="small">-->
<!--                        <MessageOutlined class="ha-icon" @click="openChat"/>-->
<!--                    </a-badge>-->
<!--                </a-tooltip>-->

                <a-dropdown
                    v-model:open="inboxOpen"
                    placement="bottomRight"
                    :trigger="['click']"
                    :getPopupContainer="triggerNode => triggerNode.parentNode"
                    @openChange="onInboxOpenChange"
                >
                    <a-badge :count="unreadChat" size="small">
                        <MessageOutlined class="ha-icon" />
                    </a-badge>

                    <template #overlay>
                        <a-card :bodyStyle="{ padding: '8px' }" style="width: 380px; max-height: 420px; overflow: auto;">
                            <a-spin :spinning="inboxLoading">
                                <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 8px 4px;">
                                    <span style="font-weight:600;">Tin nhắn gần đây</span>
                                    <a-button type="link" size="small" @click.stop="refreshInbox">Làm mới</a-button>
                                </div>

                                <a-empty v-if="!inboxItems.length && !inboxLoading" description="Chưa có tin nhắn" />
                                <a-list v-else :data-source="inboxItems" item-layout="horizontal">
                                    <template #renderItem="{ item }">
                                        <a-list-item
                                            @click="(e) => openComment(item, e)"
                                            style="cursor:pointer; padding:8px; border-radius:8px;"
                                            :class="{ 'bg-[#fff7e6]': item.is_unread == 1 }"
                                        >
                                            <a-list-item-meta>
                                                <template #avatar>
                                                    <a-avatar :src="item.author_avatar">
                                                        <template #icon><UserOutlined /></template>
                                                    </a-avatar>
                                                </template>
                                                <template #title>
                                                    <div style="display:flex;gap:6px;align-items:center;">
                                                        <span style="font-weight:600;">{{ item.author_name || 'Ẩn danh' }}</span>
                                                        <a-tag v-if="item.is_unread == 1" color="orange">Mới</a-tag>
                                                    </div>
                                                </template>
                                                <template #description>
                                                    <div style="color:#555">
                                                        <div style="white-space:nowrap; text-overflow:ellipsis; overflow:hidden;">
                                                            {{ item.content }}
                                                        </div>
                                                        <div style="font-size:12px; color:#999; margin-top:2px;">
                                                            {{ item.task_title }} • {{ formatTime(item.created_at) }}
                                                        </div>
                                                    </div>
                                                </template>
                                            </a-list-item-meta>
                                        </a-list-item>
                                    </template>
                                </a-list>

                                <div v-if="inboxHasMore" style="padding:8px;">
                                    <a-button block @click="loadMoreInbox" :loading="inboxLoading">Tải thêm</a-button>
                                </div>
                            </a-spin>
                        </a-card>
                    </template>
                </a-dropdown>


                <a-tooltip title="Thông báo">
                    <a-badge :count="unreadNotify" size="small">
                        <BellOutlined class="ha-icon" @click="openNotify"/>
                    </a-badge>
                </a-tooltip>

                <!-- Avatar dropdown -->
                <a-dropdown v-if="user" trigger="click" placement="bottomRight">
                    <div @click.prevent class="user-chip">
                        <BaseAvatar :src="user.avatar"
                        :name="user.name"
                        :size="36"
                        shape="circle"
                        :preferApiOrigin="true"
                        />
                    </div>

                    <template #overlay>
                        <div class="user-dropdown">
                            <!-- Header -->
                            <div class="user-header">
                                <!-- dùng BaseAvatar thay cho a-avatar -->
                                <BaseAvatar
                                    size="large"
                                    :src="user.avatar"
                                :name="user.name"
                                :preferApiOrigin="true"
                                />
                                <div class="user-info">
                                    <div class="name">{{ user.name }}</div>
                                    <div class="position">
                                        <IdcardOutlined style="margin-right:6px;color:#1890ff" />
                                        {{ user.position || 'Chức danh' }}
                                    </div>
                                    <div class="department">
                                        <TeamOutlined style="margin-right:6px;color:#52c41a" />
                                        {{ user.department || 'Phòng ban' }}
                                    </div>
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
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import {storeToRefs} from 'pinia'

import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/vi'
dayjs.extend(relativeTime)
dayjs.locale('vi')

import { getMyRecentCommentsAPI, getMyUnreadCommentsCountAPI, markCommentsReadAPI } from '@/api/task'
import { useUserStore } from '@/stores/user'

const userId = computed(() => userStore.user?.id)

const inboxItems = ref([])
const inboxPage = ref(1)
const inboxHasMore = ref(false)
const inboxLoading = ref(false)
let poller = null


import {
    MenuUnfoldOutlined,
    MenuFoldOutlined,
    LogoutOutlined,
    UserOutlined,
    PlusOutlined,
    HomeOutlined, MessageOutlined, BellOutlined,
    SettingOutlined,
    QuestionCircleOutlined,
    BgColorsOutlined,
    GlobalOutlined,
    KeyOutlined,
    IdcardOutlined, TeamOutlined
} from '@ant-design/icons-vue'

import ChangePasswordModal from '../components/common/ChangePasswordModal.vue'
import BaseAvatar from '../components/common/BaseAvatar.vue' // đường dẫn tới file bạn lưu

const changePwdOpen = ref(false)

const props = defineProps({
    collapsed: Boolean,
    user: Object
})

const inboxOpen = ref(false)
const onInboxOpenChange = async (open) => {
    inboxOpen.value = open
    if (!open) return
    try {
        await refreshInbox()
        const unreadIds = inboxItems.value.filter(i => i.is_unread == 1).map(i => i.id)
        if (unreadIds.length) {
            await markCommentsReadAPI(userId.value, unreadIds)
            inboxItems.value = inboxItems.value.map(i => ({ ...i, is_unread: 0 }))
            await fetchUnread()
        }
    } catch (e) {
        console.error(e)
        message.warning('Không tải được hộp thư bình luận')
    }
}


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
const unreadNotify = ref(3)

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

const formatTime = (ts) => dayjs(ts).fromNow()

const fetchUnread = async () => {
    if (!userId.value) return
    try {
        const { data } = await getMyUnreadCommentsCountAPI(userId.value)
        unreadChat.value = data.unread || 0
    } catch (e) { /* ignore */ }
}

const fetchInbox = async (page = 1) => {
    if (!userId.value) return
    inboxLoading.value = true
    try {
        const { data } = await getMyRecentCommentsAPI({ user_id: userId.value, page, limit: 10 })
        const list = data.comments || []
        inboxItems.value = page === 1 ? list : [...inboxItems.value, ...list]
        inboxHasMore.value = (data.pagination?.currentPage || 1) < (data.pagination?.totalPages || 1)
        inboxPage.value = page
    } finally {
        inboxLoading.value = false
    }
}

const refreshInbox = () => fetchInbox(1)
const loadMoreInbox = () => fetchInbox(inboxPage.value + 1)

/** Khi dropdown mở: load và đánh dấu đã đọc những item đang hiển thị */
const onInboxVisible = async (visible) => {
    if (visible) {
        await fetchInbox(1)
        // Đánh dấu đã đọc các comment đang thấy
        const unreadIds = inboxItems.value.filter(i => i.is_unread == 1).map(i => i.id)
        if (unreadIds.length) {
            await markCommentsReadAPI(userId.value, unreadIds)
            // cập nhật UI ngay
            inboxItems.value = inboxItems.value.map(i => ({ ...i, is_unread: 0 }))
            await fetchUnread()
        }
    }
}

const buildTaskDetailPath = (item) => {
    const type = (item.linked_type || '').toLowerCase()
    if (type.includes('bidding'))   return `/bidding-tasks/${item.task_id}/info`
    if (type.includes('contract'))  return `/contract-tasks/${item.task_id}/info`
    // mặc định: việc nội bộ
    return `/tasks/${item.task_id}/info`
}

const openComment = async (item, e) => {
    e?.stopPropagation()
    // đóng dropdown ngay để UX mượt
    inboxOpen.value = false

    // điều hướng sang màn chi tiết task + focus tab bình luận (nếu bạn handle query)
    const path = buildTaskDetailPath(item)
    await router.push({path, query: {focus: 'comments', c: item.id}})

    // đánh dấu đã đọc (nếu chưa)
    if (item.is_unread == 1) {
        try {
            await markCommentsReadAPI(userId.value, [item.id])
            item.is_unread = 0
            await fetchUnread()
        } catch (err) {
            console.error(err)
        }
    }
}

const startPolling = () => {
    stopPolling()
    poller = setInterval(fetchUnread, 30000) // 30s
}
const stopPolling = () => { if (poller) clearInterval(poller); poller = null }

onMounted(() => {
    fetchUnread()
    startPolling()
})

onBeforeUnmount(() => stopPolling())

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
