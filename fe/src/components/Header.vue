<template>
    <div class="header">
        <a-layout-header
            style="background:#fff; padding:0; display:flex; justify-content:space-between; align-items:center;"
        >
            <!-- Toggle -->
<!--            <div style="margin-left:16px;">-->
<!--                <a-button type="text" @click="$emit('toggle')" style="border:none; box-shadow:none;">-->
<!--                    <MenuFoldOutlined v-if="!collapsed"/>-->
<!--                    <MenuUnfoldOutlined v-else/>-->
<!--                </a-button>-->
<!--            </div>-->

            <!-- Breadcrumb -->
            <div style="flex:1; margin-left:16px;">
                <a-breadcrumb :key="$route.fullPath" style="margin-left:16px;">
                    <a-breadcrumb-item v-for="(route, index) in breadcrumbs" :key="index">
                        <router-link
                            v-if="route.name !== currentRoute.name"
                            :to="route.to || { name: route.name }"
                        >
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
                        <HomeOutlined/>
                    </a-button>
                </a-tooltip>

                <!-- Inbox -->
                <a-dropdown
                    v-model:open="inboxOpen"
                    placement="bottomRight"
                    :trigger="['click']"
                    @openChange="onInboxOpenChange"
                    :destroyPopupOnHide="true"
                >
                    <a-badge :count="unreadChat" size="small">
                        <MessageOutlined class="ha-icon"/>
                    </a-badge>

                    <template #overlay>
                        <a-card class="inbox-card" :bodyStyle="{ padding:'8px' }" style="width:380px;">
                            <div class="inbox-scroll">
                                <a-spin :spinning="inboxLoading">
                                    <!-- Header -->
                                    <div style="display:flex;justify-content:space-between;padding:8px 8px 4px;">
                                        <span style="font-weight:600;">Tin nhắn gần đây</span>
                                        <div>
                                            <div>
                                                <a-button type="link" size="small" @click.stop="refreshInbox">Làm mới</a-button>
                                            </div>
                                            <div>
                                                <a-button type="link" size="small" @click.stop="markAllInboxRead">Đánh dấu đã đọc tất cả</a-button>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Alert -->
                                    <a-alert
                                        v-if="moreUnread > 0"
                                        type="info"
                                        :message="`Còn ${moreUnread} tin chưa hiển thị — Tải thêm để xem/đánh dấu`"
                                        banner
                                        style="margin:4px 8px 8px;"
                                    />

                                    <!-- Empty -->
                                    <a-empty
                                        v-if="!inboxItems.length && !inboxLoading"
                                        description="Chưa có tin nhắn"
                                    />

                                    <!-- Groups -->
                                    <template v-else>
                                        <div v-if="newInboxItems.length" style="padding:4px 8px; font-weight:600;">
                                            Mới ({{ newInboxItems.length }})
                                        </div>
                                        <a-list v-if="newInboxItems.length" :data-source="newInboxItems" item-layout="horizontal">
                                            <template #renderItem="{ item }">
                                                <a-list-item
                                                    @click="(e) => openComment(item, e)"
                                                    style="cursor:pointer; padding:8px; border-radius:8px;"
                                                    class="bg-[#fff7e6]"
                                                >
                                                    <a-list-item-meta>
                                                        <template #avatar>
                                                            <BaseAvatar
                                                                :src="item.author_avatar"
                                                                :name="item.author_name"
                                                                :size="32"
                                                                shape="circle"
                                                                :preferApiOrigin="true"
                                                            />
                                                        </template>
                                                        <template #title>
                                                            <div style="display:flex;gap:6px;align-items:center;">
                                                                <span style="font-weight:600;">{{ item.author_name || 'Ẩn danh' }}</span>
                                                                <a-tag color="orange">Mới</a-tag>
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

                                        <div v-if="oldInboxItems.length" style="padding:6px 8px 0; font-weight:600; color:#999;">
                                            Trước đó
                                        </div>
                                        <a-list v-if="oldInboxItems.length" :data-source="oldInboxItems" item-layout="horizontal">
                                            <template #renderItem="{ item }">
                                                <a-list-item
                                                    @click="(e) => openComment(item, e)"
                                                    style="cursor:pointer; padding:8px; border-radius:8px;"
                                                >
                                                    <a-list-item-meta>
                                                        <template #avatar>
                                                            <BaseAvatar
                                                                :src="item.author_avatar"
                                                                :name="item.author_name"
                                                                :size="32"
                                                                shape="circle"
                                                                :preferApiOrigin="true"
                                                            />
                                                        </template>
                                                        <template #title>
                                                            <div style="display:flex;gap:6px;align-items:center;">
                                                                <span style="font-weight:600;">{{ item.author_name || 'Ẩn danh' }}</span>
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
                                    </template>

                                    <div v-if="inboxHasMore" style="padding:8px;">
                                        <a-button block @click="loadMoreInbox" :loading="inboxLoading">Tải thêm</a-button>
                                    </div>
                                </a-spin>
                            </div>
                        </a-card>
                    </template>
                </a-dropdown>

                <!-- Notifications -->
                <a-dropdown
                    v-model:open="notifyOpen"
                    placement="bottomRight"
                    :trigger="['click']"
                    @openChange="onNotifyOpenChange"
                >
                    <a-badge :count="unreadNotifyBadge" size="small">
                        <BellOutlined class="ha-icon"/>
                    </a-badge>

                    <template #overlay>
                        <a-card class="notify-card" :bodyStyle="{padding:'8px'}" style="width:380px;">
                            <div class="notify-scroll">
                                <a-spin :spinning="notifyLoading">
                                    <!-- Header -->
                                    <div style="display:flex;justify-content:space-between;">
                                        <span style="font-weight:600;">Thông báo phê duyệt</span>
                                        <div>
                                            <div>
                                                <a-button type="link" size="small" @click.stop="refreshNotify">Làm mới</a-button>
                                            </div>
                                            <div>
                                                <a-button type="link" size="small" @click.stop="markAllNotifyRead">Đánh dấu đã đọc tất cả</a-button>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Alert -->
                                    <a-alert
                                        v-if="moreNotifyUnread > 0"
                                        type="info"
                                        :message="`Còn ${moreNotifyUnread} mục chưa hiển thị — Tải thêm để xem/đánh dấu`"
                                        banner
                                        style="margin:4px 8px 8px;"
                                    />

                                    <!-- Empty -->
                                    <a-empty v-if="!notifyItems.length && !notifyLoading" description="Không có mục chờ duyệt"/>

                                    <!-- Groups -->
                                    <template v-else>
                                        <div v-if="newNotifyItems.length" style="font-weight:600;">Mới ({{ newNotifyItems.length }})</div>
                                        <a-list v-if="newNotifyItems.length" :data-source="newNotifyItems" item-layout="horizontal">
                                            <template #renderItem="{ item }">
                                                <a-list-item
                                                    :key="item.step_id"
                                                    @click="openApproval(item)"
                                                    style="cursor:pointer; padding:8px; border-radius:8px;"
                                                    class="bg-[#fff7e6]"
                                                >
                                                    <a-list-item-meta>
                                                        <template #title>
                                                            <div style="display:flex;gap:6px;align-items:center;">
                                                                <span style="font-weight:600;">{{ item.title }}</span>
                                                                <a-tag color="orange">Mới</a-tag>
                                                            </div>
                                                        </template>
                                                        <template #description>
                                                            <div style="color:#555;">
                                                                <div>Gửi bởi: {{ item.submitted_by_name || '—' }}</div>
                                                                <div style="font-size:12px; color:#999;">{{ formatTime(item.submitted_at) }}</div>
                                                            </div>
                                                        </template>
                                                    </a-list-item-meta>
                                                </a-list-item>
                                            </template>
                                        </a-list>

                                        <div v-if="oldNotifyItems.length" style="padding:6px 8px 0; font-weight:600; color:#999;">Trước đó</div>
                                        <a-list v-if="oldNotifyItems.length" :data-source="oldNotifyItems" item-layout="horizontal">
                                            <template #renderItem="{ item }">
                                                <a-list-item
                                                    :key="item.step_id"
                                                    @click="openApproval(item)"
                                                    style="cursor:pointer; padding:8px; border-radius:8px;"
                                                >
                                                    <a-list-item-meta>
                                                        <template #title>
                                                            <div style="display:flex;gap:6px;align-items:center;">
                                                                <span style="font-weight:600;">{{ item.title }}</span>
                                                            </div>
                                                        </template>
                                                        <template #description>
                                                            <div style="color:#555;">
                                                                <div>Gửi bởi: {{ item.submitted_by_name || '—' }}</div>
                                                                <div style="font-size:12px; color:#999;">{{ formatTime(item.submitted_at) }}</div>
                                                            </div>
                                                        </template>
                                                    </a-list-item-meta>
                                                </a-list-item>
                                            </template>
                                        </a-list>
                                    </template>

                                    <div v-if="notifyHasMore" style="padding:8px;">
                                        <a-button block @click="loadMoreNotify" :loading="notifyLoading">Tải thêm</a-button>
                                    </div>
                                </a-spin>
                            </div>
                        </a-card>
                    </template>
                </a-dropdown>

                <!-- Avatar dropdown -->
                <a-dropdown v-if="user" trigger="click" placement="bottomRight">
                    <div @click.prevent class="user-chip">
                        <BaseAvatar :src="user.avatar" :name="user.name" :size="36" shape="circle" :preferApiOrigin="true"/>
                    </div>

                    <template #overlay>
                        <div class="user-dropdown">
                            <div class="user-header">
                                <BaseAvatar size="large" :src="user.avatar" :name="user.name" :preferApiOrigin="true"/>
                                <div class="user-info">
                                    <div class="name">{{ user.name }}</div>
                                    <div class="position">
                                        <IdcardOutlined style="margin-right:6px;color:#1890ff"/>
                                        {{ user.position || 'Chức danh' }}
                                    </div>
                                    <div class="department">
                                        <TeamOutlined style="margin-right:6px;color:#52c41a"/>
                                        {{ user.department || 'Phòng ban' }}
                                    </div>
                                </div>
                            </div>

                            <div class="user-menu">
                                <div class="user-item" @click="redirectToProfile"><UserOutlined/> Tài khoản</div>
                                <div class="user-item"><SettingOutlined/> Cài đặt hệ thống</div>
                                <div class="user-item"><QuestionCircleOutlined/> Hướng dẫn sử dụng</div>
                                <div class="user-item"><BgColorsOutlined/> Màu giao diện <div class="color-dot"></div></div>
                                <div class="user-item"><GlobalOutlined/> Ngôn ngữ <span style="margin-left:auto">VN</span></div>
                                <div class="user-item" @click="changePwdOpen = true"><KeyOutlined/> Đổi mật khẩu</div>
                                <div class="user-item danger" @click="handleLogout"><LogoutOutlined/> Đăng xuất</div>
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
/* ========= Imports ========= */
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { storeToRefs } from 'pinia'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/vi'

import { getMyRecentCommentsAPI, getMyUnreadCommentsCountAPI, markCommentsReadAPI } from '@/api/task'
import { getApprovalInboxAPI, getApprovalUnreadCountAPI, markApprovalReadAPI } from '@/api/approvals'

import { useUserStore } from '@/stores/user'
import { useCommonStore } from '@/stores/common'

import {
    MenuUnfoldOutlined, MenuFoldOutlined, LogoutOutlined, UserOutlined, PlusOutlined,
    HomeOutlined, MessageOutlined, BellOutlined, SettingOutlined, QuestionCircleOutlined,
    BgColorsOutlined, GlobalOutlined, KeyOutlined, IdcardOutlined, TeamOutlined
} from '@ant-design/icons-vue'

import ChangePasswordModal from '../components/common/ChangePasswordModal.vue'
import BaseAvatar from '../components/common/BaseAvatar.vue'

/* ========= dayjs ========= */
dayjs.extend(relativeTime)
dayjs.locale('vi')

/* ========= Stores / Router ========= */
const common = useCommonStore()
const userStore = useUserStore()
const { user } = storeToRefs(userStore)
const currentRoute = useRoute()
const router = useRouter()

/* ========= Props / Emits ========= */
const emit = defineEmits(['toggle', 'logout'])
const props = defineProps({ collapsed: Boolean, user: Object })

/* ========= State (Inbox) ========= */
const userId = computed(() => userStore.user?.id)
const unreadChat = ref(1)
const inboxItems = ref([])
const inboxPage = ref(1)
const inboxHasMore = ref(false)
const inboxLoading = ref(false)
const inboxOpen = ref(false)
const inboxLastOpenAt = ref(Number(localStorage.getItem('inbox_last_open_at') || 0))

/* ========= State (Notify) ========= */
const notifyOpen = ref(false)
const notifyItems = ref([])
const notifyPage = ref(1)
const notifyHasMore = ref(false)
const notifyLoading = ref(false)
const changePwdOpen = ref(false)

/* ========= Misc ========= */
let poller = null
const LS_NOTIFY_READ_KEY = 'notify_read_steps_v1'

/* ========= Local read mask (Notify) ========= */
const loadClientReadSteps = () => {
    try { return new Set(JSON.parse(localStorage.getItem(LS_NOTIFY_READ_KEY) || '[]')) }
    catch { return new Set() }
}
const saveClientReadSteps = (setObj) => {
    try { localStorage.setItem(LS_NOTIFY_READ_KEY, JSON.stringify(Array.from(setObj))) } catch {}
}
const clientReadSteps = loadClientReadSteps()
const rememberReadStep = (stepId) => { clientReadSteps.add(stepId); saveClientReadSteps(clientReadSteps) }
const rememberReadMany = (ids = []) => { ids.forEach(id => clientReadSteps.add(id)); saveClientReadSteps(clientReadSteps) }

/* ========= Server unread count for approvals ========= */
const unreadNotifyCount = ref(0) // tổng chưa đọc từ server
const fetchNotifyUnreadCount = async () => {
    try {
        const { data } = await getApprovalUnreadCountAPI()
        unreadNotifyCount.value = data?.unread || 0
    } catch {}
}

/* ========= Computed ========= */
const breadcrumbs = computed(() => {
    const all = router.getRoutes()
    const p = currentRoute.params
    const buildParams = {
        'bid-list': () => ({}),
        'biddings-info': () => ({ id: p.id || p.bidId }),
        'bidding-step-tasks': () => ({ bidId: p.bidId, stepId: p.stepId }),
        'bidding-task-info': () => ({ id: p.id }),
        'internal-tasks': () => ({}),
        'internal-tasks-info': () => ({ id: p.id }),
        'tasks': () => ({}),
    }
    const trail = []
    let cur = all.find(r => r.name === currentRoute.name)
    while (cur) {
        if (cur.meta?.breadcrumb) {
            trail.unshift({ name: cur.name, meta: cur.meta, to: { name: cur.name, params: (buildParams[cur.name]?.() || {}) } })
        }
        const parentName = cur.meta?.parent
        cur = parentName ? all.find(r => r.name === parentName) : null
    }
    return trail
})

/* Inbox groups */
const newInboxItems = computed(() => inboxItems.value.filter(i => +i.is_unread === 1))
const oldInboxItems = computed(() => inboxItems.value.filter(i => +i.is_unread !== 1))
const unreadOnPage = computed(() => inboxItems.value.filter(i => +i.is_unread === 1).length)
const moreUnread = computed(() => Math.max(0, unreadChat.value - unreadOnPage.value))

/* Notify groups + badge */
const newNotifyItems = computed(() => notifyItems.value.filter(i => +i.is_unread === 1))
const oldNotifyItems = computed(() => notifyItems.value.filter(i => +i.is_unread !== 1))
const unreadNotifyOnPage = computed(() => notifyItems.value.filter(i => +i.is_unread === 1).length)
const unreadNotifyBadge = computed(() => unreadNotifyCount.value) // badge = tổng server
const moreNotifyUnread = computed(() => Math.max(0, (unreadNotifyCount.value || 0) - unreadNotifyOnPage.value))

/* ========= Utilities ========= */
const formatTime = (ts) => dayjs(ts).fromNow()
const buildTaskDetailPath = (item) => {
    const type = (item.linked_type || '').toLowerCase()
    if (type.includes('bidding')) return `/bidding-tasks/${item.task_id}/info`
    if (type.includes('contract')) return `/contract-tasks/${item.task_id}/info`
    return `/tasks/${item.task_id}/info`
}

/* ========= Navigation / User ========= */
const goHome = () => router.push('/project-overview')
const onClickCreateTask = () => { if (currentRoute.name === 'tasks') common.triggerCreateTask('internal') }
const handleLogout = () => { userStore.clearUser(); router.push('/') }
const redirectToProfile = () => { router.push({ name: 'persons-info', params: { id: user.value.id } }) }

/* ========= Inbox: API & Actions ========= */
const fetchUnread = async () => {
    if (!userId.value) return
    try {
        const { data } = await getMyUnreadCommentsCountAPI(userId.value)
        unreadChat.value = data?.unread || 0
    } catch {}
}
const fetchInbox = async (page = 1) => {
    if (!userId.value) return
    inboxLoading.value = true
    try {
        const { data } = await getMyRecentCommentsAPI({ user_id: userId.value, page, limit: 10 })
        const list = data?.comments || []
        inboxItems.value = page === 1 ? list : [...inboxItems.value, ...list]
        inboxHasMore.value = (data?.pagination?.currentPage || 1) < (data?.pagination?.totalPages || 1)
        inboxPage.value = page
    } finally { inboxLoading.value = false }
}
const refreshInbox = () => fetchInbox(1)
const loadMoreInbox = () => fetchInbox(inboxPage.value + 1)
const markAllInboxRead = async () => {
    if (!userId.value) return
    try {
        const allUnreadIds = []
        let page = 1, hasMore = true
        while (hasMore) {
            const { data } = await getMyRecentCommentsAPI({ user_id: userId.value, page, limit: 50 })
            const list = data?.comments || []
            allUnreadIds.push(...list.filter(i => +i.is_unread === 1).map(i => i.id))
            const cur = data?.pagination?.currentPage || page
            const total = data?.pagination?.totalPages || cur
            hasMore = cur < total
            page++
        }
        if (allUnreadIds.length) {
            await markCommentsReadAPI(userId.value, allUnreadIds)
            unreadChat.value = 0
            inboxItems.value = inboxItems.value.map(i => ({ ...i, is_unread: 0 }))
        }
    } catch (e) {
        console.error(e); message.error('Không thể đánh dấu tất cả đã đọc')
    }
}
const openComment = async (item, e) => {
    e?.stopPropagation()
    inboxOpen.value = false
    const path = buildTaskDetailPath(item)
    await router.push({ path, query: { focus: 'comments', c: item.id } })
    if (+item.is_unread === 1) {
        try {
            await markCommentsReadAPI(userId.value, [item.id])
            item.is_unread = 0
            unreadChat.value = Math.max(0, unreadChat.value - 1)
        } catch (err) { console.error(err) }
    }
}

/* ========= Notify: API & Actions ========= */
const fetchNotify = async (page = 1) => {
    notifyLoading.value = true
    try {
        const { data } = await getApprovalInboxAPI({ per_page: 10, page })
        let list = data?.data || []

        // mask đã đọc theo client
        list = list.map(it => clientReadSteps.has(it.step_id) ? { ...it, is_unread: 0 } : it)

        notifyItems.value = page === 1 ? list : [...notifyItems.value, ...list]

        const pager = data?.pager || {}
        const cur = pager.current_page || page
        const per = pager.per_page || 10
        const total = pager.total || 0
        notifyHasMore.value = cur * per < total
        notifyPage.value = page

        // đồng bộ tổng chưa đọc từ server (không dựa list)
        fetchNotifyUnreadCount()
    } finally { notifyLoading.value = false }
}
const refreshNotify = () => fetchNotify(1)
const loadMoreNotify = () => fetchNotify(notifyPage.value + 1)

const markAllNotifyRead = async () => {
    try {
        const allUnreadSteps = []
        let page = 1, hasMore = true
        while (hasMore) {
            const { data } = await getApprovalInboxAPI({ per_page: 50, page })
            const list = data?.data || []
            allUnreadSteps.push(...list.filter(i => +i.is_unread === 1).map(i => i.step_id))
            const pager = data?.pager || {}
            const cur = pager.current_page || page
            const per = pager.per_page || 50
            const total = pager.total || 0
            hasMore = cur * per < total
            page++
        }
        if (allUnreadSteps.length) {
            await markApprovalReadAPI(allUnreadSteps)
            rememberReadMany(allUnreadSteps)
            notifyItems.value = notifyItems.value.map(i => ({ ...i, is_unread: 0 }))
            unreadNotifyCount.value = 0 // đã quét hết → tổng = 0
            message.success('Đã đánh dấu tất cả thông báo là đã đọc')
        } else {
            message.info('Không còn thông báo chưa đọc')
        }
    } catch (e) {
        console.error(e); message.error('Không thể đánh dấu tất cả thông báo đã đọc')
    }
}
const openApproval = async (item) => {
    if (+item.is_unread === 1) {
        item.is_unread = 0
        const idx = notifyItems.value.findIndex(n => n.step_id === item.step_id)
        if (idx > -1) notifyItems.value.splice(idx, 1, { ...notifyItems.value[idx], is_unread: 0 })
        unreadNotifyCount.value = Math.max(0, unreadNotifyCount.value - 1) // giảm tổng (optimistic)
        rememberReadStep(item.step_id)
        markApprovalReadAPI([item.step_id]).catch(console.error)
    }
    notifyOpen.value = false
    await router.push({ path: item.url, query: { focus: 'approval', ai: item.instance_id } })
}

/* ========= Dropdown handlers ========= */
const onInboxOpenChange = async (open) => {
    inboxOpen.value = open
    if (!open) return
    await refreshInbox()
}
const onNotifyOpenChange = async (open) => {
    notifyOpen.value = open
    if (!open) return
    await Promise.all([ refreshNotify(), fetchNotifyUnreadCount() ])
}

/* ========= Polling ========= */
const startPolling = () => {
    stopPolling()
    poller = setInterval(() => {
        fetchUnread()              // badge comment
        refreshNotify()            // dữ liệu list
        fetchNotifyUnreadCount()   // tổng server cho badge chuông
    }, 30000)
}
const stopPolling = () => { if (poller) clearInterval(poller); poller = null }

/* ========= Watches / Lifecycle ========= */
watch(inboxOpen, (open) => {
    if (!open) {
        const now = Date.now()
        inboxLastOpenAt.value = now
        localStorage.setItem('inbox_last_open_at', String(now))
    }
})

onMounted(async () => {
    await fetchUnread()
    await refreshNotify()
    await fetchNotifyUnreadCount()
    startPolling()
})
onBeforeUnmount(() => stopPolling())
</script>

<style scoped>
.header { width:100%; }

.trigger { font-size:18px; line-height:64px; padding:0 24px; cursor:pointer; transition:color .3s; }
.trigger:hover { color:#1890ff; }

.right-actions{ margin-right:16px; display:flex; align-items:center; gap:16px; }

.ha-icon{ font-size:20px; color:#8c8c8c; cursor:pointer; transition:color .2s, transform .2s; }
.ha-icon:hover{ color:#fa8c16; transform:translateY(-1px); }

.home-chip{
    width:36px; height:36px; padding:0; border:none; background:#fff7e6;
    display:flex; align-items:center; justify-content:center; box-shadow:none;
}
.home-chip :deep(.anticon){ color:#fa8c16; font-size:18px; }
.home-chip:hover{ background:#ffe7ba; }

.user-chip{ display:flex; align-items:center; cursor:pointer; }

.user-dropdown{
    width:320px; background:#fff; border-radius:8px; box-shadow:0 4px 16px rgba(0,0,0,.12); overflow:hidden;
}
.user-header{ display:flex; align-items:center; padding:16px; border-bottom:1px solid #f0f0f0; }
.user-info{ margin-left:12px; flex:1; }
.user-info .name{ font-weight:600; font-size:16px; color:#fa541c; }
.user-info .position, .user-info .department{ font-size:13px; color:#888; }

.user-menu{ display:flex; flex-direction:column; }
.user-item{ display:flex; align-items:center; gap:8px; padding:12px 16px; cursor:pointer; transition:background .2s; font-size:14px; }
.user-item:hover{ background:#f5f5f5; }
.user-item.danger{ color:#ff4d4f; }
.color-dot{ width:16px; height:16px; border-radius:50%; background:#fa541c; margin-left:auto; }

.inbox-card{ width:380px; }
.inbox-scroll{
    max-height:420px; overflow-y:auto; overflow-x:hidden; scrollbar-width:thin; scrollbar-color:#d9d9d9 transparent;
}
:deep(.inbox-scroll::-webkit-scrollbar){ width:6px; }
:deep(.inbox-scroll::-webkit-scrollbar-thumb){ background:#d9d9d9; border-radius:8px; }
:deep(.inbox-scroll::-webkit-scrollbar-thumb:hover){ background:#bfbfbf; }

.notify-scroll{
    max-height:420px; overflow-y:auto; overflow-x:hidden; scrollbar-width:thin; scrollbar-color:#d9d9d9 transparent;
}
:deep(.notify-scroll::-webkit-scrollbar){ width:6px; }
:deep(.notify-scroll::-webkit-scrollbar-thumb){ background:#d9d9d9; border-radius:8px; }
:deep(.notify-scroll::-webkit-scrollbar-thumb:hover){ background:#bfbfbf; }
</style>
