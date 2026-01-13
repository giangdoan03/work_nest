<template>
    <div class="header">
        <a-layout-header class="hdr">
            <!-- Toggle -->
            <div style="margin-left:16px;">
                <a-button type="text" @click="$emit('toggle')" style="border:none; box-shadow:none;">
                    <MenuFoldOutlined v-if="!collapsed"/>
                    <MenuUnfoldOutlined v-else/>
                </a-button>
            </div>

            <!-- Breadcrumb -->
            <div class="hdr__crumb">
                <a-breadcrumb :key="$route.fullPath" class="crumb">
                    <a-breadcrumb-item v-for="(route, index) in breadcrumbs" :key="index">
                        <router-link v-if="route.name !== currentRoute.name && route.to" :to="route.to" class="crumb__link">
                            {{ route.meta.breadcrumb }}
                        </router-link>

                        <template v-else>
                            <span class="crumb__current">{{ route.meta.breadcrumb }}
                                <a-button v-if="showCrumbCreateBtn" size="small" class="crumb__add" @click="onClickCreateTask">
                                    <template #icon><PlusOutlined/></template>
                                </a-button>
                            </span>
                        </template>
                    </a-breadcrumb-item>
                </a-breadcrumb>
            </div>

            <!-- Right actions -->
            <div class="hdr__actions">
                <!-- Home -->
                <a-tooltip title="Trang chủ">
                    <a-button
                        class="home-chip"
                        shape="circle"
                        @click="goHome"
                        aria-label="Về trang tổng quan"
                    >
                        <HomeOutlined/>
                    </a-button>
                </a-tooltip>

                <!-- Inbox (bình luận) -->
                <a-dropdown
                    v-model:open="inboxOpen"
                    placement="bottomRight"
                    :trigger="['click']"
                    @openChange="onInboxOpenChange"
                    :destroyPopupOnHide="true"
                >
                    <a-badge :count="commentStore.unread" size="small">
                        <MessageOutlined class="ha-icon" aria-label="Hộp thư bình luận"/>
                    </a-badge>
                    <template #overlay>
                        <a-card class="inbox-card" :bodyStyle="{ padding:'8px' }" style="width:380px;">
                            <div class="scroll">
                                <a-spin :spinning="inboxLoading">
                                    <!-- Header -->
                                    <div class="panel-head">
                                        <span class="panel-title">Tin nhắn gần đây</span>
                                        <div class="panel-tools">
                                            <a-button type="link" size="small" @click.stop="refreshInbox">Làm mới</a-button>
                                            <a-button type="link" size="small" @click.stop="markAllInboxRead">Đánh dấu đã đọc tất cả</a-button>
                                        </div>
                                    </div>

                                    <!-- Alert -->
                                    <a-alert
                                        v-if="moreUnread > 0"
                                        type="info"
                                        :message="`Còn ${moreUnread} tin chưa hiển thị — Tải thêm để xem/đánh dấu`"
                                        banner
                                        class="panel-alert"
                                    />

                                    <!-- Empty -->
                                    <a-empty v-if="!inboxItems.length && !inboxLoading" description="Chưa có tin nhắn"/>
                                    <!-- Groups -->
                                    <template v-else>
                                        <div v-if="newInboxItems.length" class="group-title">
                                            Mới ({{ newInboxItems.length }})
                                        </div>
                                        <a-list v-if="newInboxItems.length" :data-source="newInboxItems" item-layout="horizontal">
                                            <template #renderItem="{ item }">
                                                <a-list-item
                                                    @click="(e) => openComment(item, e)"
                                                    class="list-item list-item--new"
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
                                                            <div class="item-title">
                                                                <span class="fw-600">{{item.author_name || 'Ẩn danh'}}</span>
                                                                <a-tag color="orange">Mới</a-tag>
                                                            </div>
                                                        </template>
                                                        <template #description>
                                                            <div class="item-desc">
                                                                <div class="ellipsis-1">{{ item.content }}</div>
                                                                <div class="meta-sub">
                                                                    {{ item.task_title }} • {{ formatTime(item.created_at) }}
                                                                </div>
                                                            </div>
                                                        </template>
                                                    </a-list-item-meta>
                                                </a-list-item>
                                            </template>
                                        </a-list>

                                        <div v-if="oldInboxItems.length" class="group-title group-title--muted">
                                            Trước đó
                                        </div>
                                        <a-list
                                            v-if="oldInboxItems.length"
                                            :data-source="oldInboxItems"
                                            item-layout="horizontal"
                                        >
                                            <template #renderItem="{ item }">
                                                <a-list-item
                                                    @click="(e) => openComment(item, e)"
                                                    class="list-item"
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
                                                            <div class="item-title">
                                                                <span class="fw-600">{{item.author_name || 'Ẩn danh' }}</span>
                                                            </div>
                                                        </template>
                                                        <template #description>
                                                            <div class="item-desc">
                                                                <div class="ellipsis-1">{{ item.content }}</div>
                                                                <div class="meta-sub">
                                                                    {{ item.task_title }} • {{ formatTime(item.created_at) }}
                                                                </div>
                                                            </div>
                                                        </template>
                                                    </a-list-item-meta>
                                                </a-list-item>
                                            </template>
                                        </a-list>
                                    </template>

                                    <div v-if="inboxHasMore" class="panel-more">
                                        <a-button block @click="loadMoreInbox" :loading="inboxLoading">Tải thêm</a-button>
                                    </div>
                                </a-spin>
                            </div>
                        </a-card>
                    </template>
                </a-dropdown>

                <!-- Notifications (phê duyệt) -->
                <a-dropdown
                    v-model:open="notifyOpen"
                    placement="bottomRight"
                    :trigger="['click']"
                    @openChange="onNotifyOpenChange"
                >
                    <a-badge :count="notifyStore.unread" size="small">
                        <BellOutlined class="ha-icon" />
                    </a-badge>

                    <template #overlay>
                        <a-card class="notify-card" :bodyStyle="{padding:'8px'}" style="width:380px;">
                            <div class="scroll">
                                <a-spin :spinning="notifyLoading">
                                    <div class="panel-head">
                                        <span class="panel-title">Thông báo phê duyệt</span>
                                        <div class="panel-tools">
                                            <a-button type="link" size="small" @click.stop="refreshNotify">Làm mới</a-button>
                                            <a-button type="link" size="small" @click.stop="markAllNotifyRead">Đánh dấu đã đọc tất cả</a-button>
                                        </div>
                                    </div>

                                    <a-alert
                                        v-if="moreNotifyUnread > 0"
                                        type="info"
                                        :message="`Còn ${moreNotifyUnread} mục chưa hiển thị — Tải thêm để xem/đánh dấu`"
                                        banner
                                        class="panel-alert"
                                    />

                                    <a-empty v-if="!notifyItems.length && !notifyLoading" description="Không có mục chờ duyệt"/>

                                    <template v-else>
                                        <div v-if="newNotifyItems.length" class="group-title">
                                            Mới ({{ newNotifyItems.length }})
                                        </div>
                                        <a-list
                                            v-if="newNotifyItems.length"
                                            :data-source="newNotifyItems"
                                            item-layout="horizontal"
                                        >
                                            <template #renderItem="{ item }">
                                                <a-list-item
                                                    :key="item.step_id"
                                                    @click="openApproval(item)"
                                                    class="list-item list-item--new"
                                                >
                                                    <a-list-item-meta>
                                                        <template #title>
                                                            <div class="item-title">
                                                                <span class="fw-600">{{ item.title }}</span>
                                                                <a-tag color="orange">Mới</a-tag>
                                                            </div>
                                                        </template>
                                                        <template #description>
                                                            <div class="item-desc">
                                                                <div class="title_auth">Gửi bởi: {{ item.submitted_by_name || '—' }}</div>
                                                                <div class="meta-sub">{{ formatTime(item.created_at) }}</div>
                                                            </div>
                                                        </template>
                                                    </a-list-item-meta>
                                                </a-list-item>
                                            </template>
                                        </a-list>

                                        <div v-if="oldNotifyItems.length" class="group-title group-title--muted">
                                            Trước đó
                                        </div>
                                        <a-list
                                            v-if="oldNotifyItems.length"
                                            :data-source="oldNotifyItems"
                                            item-layout="horizontal"
                                        >
                                            <template #renderItem="{ item }">
                                                <a-list-item
                                                    :key="item.step_id"
                                                    @click="openApproval(item)"
                                                    class="list-item"
                                                >
                                                    <a-list-item-meta>
                                                        <template #title>
                                                            <div class="item-title">
                                                                <span class="fw-600">{{ item.title }}</span>
                                                            </div>
                                                        </template>
                                                        <template #description>
                                                            <div class="item-desc">
                                                                <div>Gửi bởi: {{ item.submitted_by_name || 'Hệ thống' }}</div>
                                                                <div class="meta-sub">{{ formatTime(item.created_at) }}</div>

                                                            </div>
                                                        </template>
                                                    </a-list-item-meta>
                                                </a-list-item>
                                            </template>
                                        </a-list>
                                    </template>

                                    <div v-if="notifyHasMore" class="panel-more">
                                        <a-button block @click="loadMoreNotify" :loading="notifyLoading">Tải thêm</a-button>
                                    </div>
                                </a-spin>
                            </div>
                        </a-card>
                    </template>
                </a-dropdown>

                <!-- Avatar dropdown -->
                <a-dropdown v-if="user" trigger="click" placement="bottomRight">
                    <div @click.prevent class="user-chip" aria-label="Tài khoản">
                        <BaseAvatar
                            :src="user.avatar"
                            :name="user.name"
                            :size="36"
                            shape="circle"
                            :preferApiOrigin="true"
                        />
                    </div>

                    <template #overlay>
                        <div class="user-dropdown">
                            <div class="user-header">
                                <BaseAvatar
                                    size="large"
                                    :src="user.avatar"
                                    :name="user.name"
                                    :preferApiOrigin="true"
                                />
                                <div class="user-info">
                                    <div class="name">{{ user.name }}</div>
                                    <div class="position">
                                        <IdcardOutlined class="i-blue"/>
                                        {{ user.position || 'Chức danh' }}
                                    </div>
                                    <div class="department">
                                        <TeamOutlined class="i-green"/>
                                        {{ user.department || 'Phòng ban' }}
                                    </div>
                                </div>
                            </div>

                            <div class="user-menu">
                                <div class="user-item" @click="redirectToProfile">
                                    <UserOutlined/>
                                    Tài khoản
                                </div>
                                <div class="user-item">
                                    <SettingOutlined/>
                                    Cài đặt hệ thống
                                </div>
                                <div class="user-item">
                                    <QuestionCircleOutlined/>
                                    Hướng dẫn sử dụng
                                </div>
                                <div class="user-item">
                                    <BgColorsOutlined/>
                                    Màu giao diện
                                    <div class="color-dot"></div>
                                </div>
                                <div class="user-item">
                                    <GlobalOutlined/>
                                    Ngôn ngữ <span class="ml-auto">VN</span>
                                </div>
                                <div class="user-item" @click="changePwdOpen = true">
                                    <KeyOutlined/>
                                    Đổi mật khẩu
                                </div>
                                <div class="user-item danger" @click="handleLogout">
                                    <LogoutOutlined/>
                                    Đăng xuất
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
/* ---------------------------------------------
| Imports
--------------------------------------------- */
import { useRoute, useRouter } from "vue-router";
import { message } from "ant-design-vue";
import { computed, onMounted, ref, watch } from "vue";
import { storeToRefs } from "pinia";
import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import localizedFormat from "dayjs/plugin/localizedFormat";
import "dayjs/locale/vi";

import { buildNotifyUrl } from "@/utils/build-notify-url";
import { buildParamsMap } from "@/utils/breadcrumb-params";

import {
    getNotificationAPI,
    markNotificationReadAPI
} from "@/api/notifications";

import {
    getMyRecentCommentsAPI,
    getMyUnreadCommentsCountAPI,
    markCommentsReadAPI
} from "@/api/task";

import { useUserStore } from "@/stores/user";
import { useCommonStore } from "@/stores/common";
import { useNotifyStore } from "@/stores/notifyStore";
import { useCommentNotifyStore } from "@/stores/commentNotify";

import {
    BellOutlined, BgColorsOutlined, GlobalOutlined, HomeOutlined, IdcardOutlined,
    KeyOutlined, LogoutOutlined, MenuFoldOutlined, MenuUnfoldOutlined,
    MessageOutlined, PlusOutlined, QuestionCircleOutlined,
    SettingOutlined, TeamOutlined, UserOutlined
} from "@ant-design/icons-vue";

import ChangePasswordModal from "../components/common/ChangePasswordModal.vue";
import BaseAvatar from "../components/common/BaseAvatar.vue";

import {
    connectChatChannel,
    connectNotifyChannel,
    onIncomingComment,
    onNotifyEvent
} from "@/utils/notify-socket.js";

/* ---------------------------------------------
| DayJS Setup
--------------------------------------------- */
dayjs.extend(relativeTime);
dayjs.extend(localizedFormat);
dayjs.locale("vi");

/* ---------------------------------------------
| Stores & Router
--------------------------------------------- */
const userStore = useUserStore();
const notifyStore = useNotifyStore();
const commentStore = useCommentNotifyStore();

const { user } = storeToRefs(userStore);

const router = useRouter();
const currentRoute = useRoute();
const common = useCommonStore();

/* ---------------------------------------------
| Props & Emits
--------------------------------------------- */
defineProps({ collapsed: Boolean });
defineEmits(["toggle", "logout"]);

/* ---------------------------------------------
| Computed
--------------------------------------------- */
const userId = computed(() => userStore.user?.id);

const isNonWorkflow = computed(() =>
    currentRoute.path.startsWith("/non-workflow")
);

const showCrumbCreateBtn = computed(
    () => currentRoute.path === "/non-workflow"
);

/* ---------------------------------------------
| Inbox State
--------------------------------------------- */
const inboxItems = ref([]);
const inboxOpen = ref(false);
const unreadChat = ref(0);
const inboxPage = ref(1);
const inboxHasMore = ref(false);
const inboxLoading = ref(false);

const newInboxItems = computed(() =>
    inboxItems.value.filter(i => +i.is_unread === 1)
);
const oldInboxItems = computed(() =>
    inboxItems.value.filter(i => +i.is_unread !== 1)
);
const unreadOnPage = computed(() => newInboxItems.value.length);
const moreUnread = computed(
    () => Math.max(0, unreadChat.value - unreadOnPage.value)
);

/* ---------------------------------------------
| Notify State
--------------------------------------------- */
const notifyOpen = ref(false);
const notifyLoading = ref(false);
const notifyPage = ref(1);
const notifyHasMore = ref(false);
const changePwdOpen = ref(false);

const notifyItems = computed(() => notifyStore.items);
const newNotifyItems = computed(() =>
    notifyStore.items.filter(i => i.is_unread)
);
const oldNotifyItems = computed(() =>
    notifyStore.items.filter(i => !i.is_unread)
);
const moreNotifyUnread = computed(() =>
    Math.max(0, notifyStore.unread - newNotifyItems.value.length)
);

/* ---------------------------------------------
| Helper Functions
--------------------------------------------- */
const formatTime = ts => dayjs(ts).fromNow();

const buildTaskDetailPath = item => {
    const type = (item.linked_type || "").toLowerCase();
    if (type.includes("bidding")) return `/bidding-tasks/${item.task_id}/info`;
    if (type.includes("contract")) return `/contract-tasks/${item.task_id}/info`;
    if (type.includes("non-workflow"))
        return `/non-workflow/tasks/${item.task_id}/info`;
    return `/tasks/${item.task_id}/info`;
};

/* ---------------------------------------------
| Breadcrumb Generator
--------------------------------------------- */
const breadcrumbs = computed(() => {
    const allRoutes = router.getRoutes();
    const params = currentRoute.params;
    const buildParams = buildParamsMap(params);

    const cleanParams = obj =>
        Object.fromEntries(
            Object.entries(obj).filter(([, v]) => v !== undefined && v !== null)
        );

    const requiredParamsOf = route =>
        route?.path?.match(/:([A-Za-z0-9_]+)/g)?.map(s => s.slice(1)) || [];

    const trail = [];
    let cursor = allRoutes.find(r => r.name === currentRoute.name);

    while (cursor) {
        if (cursor.meta?.breadcrumb) {
            const paramMap = cleanParams(buildParams[cursor.name]?.() || {});
            const required = requiredParamsOf(cursor);

            trail.unshift({
                name: cursor.name,
                meta: cursor.meta,
                to: required.every(k => paramMap[k] != null)
                    ? { name: cursor.name, params: paramMap }
                    : null
            });
        }
        cursor = cursor.meta?.parent
            ? allRoutes.find(r => r.name === cursor.meta.parent)
            : null;
    }
    return trail;
});

/* ---------------------------------------------
| Inbox: API & Actions
--------------------------------------------- */
const fetchUnread = async () => {
    const { data } = await getMyUnreadCommentsCountAPI(userId.value);
    commentStore.unread = data.unread ?? 0;
};

const fetchInbox = async (page = 1) => {
    if (!userId.value) return;
    inboxLoading.value = true;

    try {
        const { data } = await getMyRecentCommentsAPI({
            user_id: userId.value,
            page,
            limit: 10
        });

        const list = data?.comments || [];
        inboxItems.value = page === 1 ? list : [...inboxItems.value, ...list];

        commentStore.unread = list.filter(i => +i.is_unread === 1).length;

        const cur = data?.pagination?.currentPage || page;
        const total = data?.pagination?.totalPages || cur;
        inboxHasMore.value = cur < total;
        inboxPage.value = page;
    } finally {
        inboxLoading.value = false;
    }
};

const refreshInbox = () => fetchInbox(1);
const loadMoreInbox = () => fetchInbox(inboxPage.value + 1);

const markAllInboxRead = async () => {
    if (!userId.value) return;

    try {
        const unreadIds = [];
        let page = 1;
        let hasMore = true;

        while (hasMore) {
            const { data } = await getMyRecentCommentsAPI({
                user_id: userId.value,
                page,
                limit: 50
            });

            const list = data?.comments || [];
            unreadIds.push(
                ...list.filter(i => +i.is_unread === 1).map(i => i.id)
            );

            const cur = data?.pagination?.currentPage || page;
            const total = data?.pagination?.totalPages || cur;
            hasMore = cur < total;
            page++;
        }

        if (unreadIds.length) {
            await markCommentsReadAPI(userId.value, unreadIds);
            unreadChat.value = 0;
            inboxItems.value = inboxItems.value.map(i => ({
                ...i,
                is_unread: 0
            }));
            message.success("Đã đánh dấu tất cả tin nhắn là đã đọc");
        } else {
            message.info("Không còn tin nhắn chưa đọc");
        }
    } catch (err) {
        console.error(err);
        message.error("Không thể đánh dấu tất cả đã đọc");
    }
};

const openComment = async (item, e) => {
    e?.stopPropagation?.();
    inboxOpen.value = false;

    await router.push({
        path: buildTaskDetailPath(item),
        query: { focus: "comments", c: item.id }
    });

    if (+item.is_unread === 1) {
        try {
            await markCommentsReadAPI(userId.value, [item.id]);
            item.is_unread = 0;
            unreadChat.value = Math.max(0, unreadChat.value - 1);
        } catch (err) {
            console.error(err);
        }
    }
};

/* ---------------------------------------------
| Notify: API & Actions
--------------------------------------------- */
const fetchNotify = async (page = 1) => {
    notifyLoading.value = true;

    const { data } = await getNotificationAPI(userId.value, page);

    const list = (data?.data || []).map(n => ({
        ...n,
        is_unread: !!Number(n.is_unread)
    }));

    if (page === 1) {
        notifyStore.setList(list);
    } else {
        notifyStore.items = [...notifyStore.items, ...list];
    }

    notifyStore.unread = notifyStore.items.filter(i => i.is_unread).length;
    notifyPage.value = page;
    notifyHasMore.value = data?.pager?.hasMore || false;

    notifyLoading.value = false;
};

const refreshNotify = () => fetchNotify(1);
const loadMoreNotify = () => fetchNotify(notifyPage.value + 1);

const markAllNotifyRead = async () => {
    const unreadItems = notifyStore.items.filter(i => i.is_unread);

    for (const item of unreadItems) {
        await markNotificationReadAPI(item.id);
        item.is_unread = false;
    }

    notifyStore.unread = 0;
    message.success("Đã đánh dấu tất cả đã đọc");
};

const openApproval = async item => {
    notifyOpen.value = false;

    if (item.is_unread) {
        try {
            await markNotificationReadAPI(item.id);
            notifyStore.markRead(item.id);
        } catch (err) {
            console.error("❌ Mark read failed:", err);
        }
    }

    const url = buildNotifyUrl(item);

    try {
        await router.push(url || "/task-approvals");
    } catch (err) {
        console.error("❌ Router error:", err);
    }
};

/* ---------------------------------------------
| Dropdown handlers
--------------------------------------------- */
const onInboxOpenChange = async open => {
    inboxOpen.value = open;
    if (open) {
        await fetchUnread();
        await refreshInbox();
    }
};

const onNotifyOpenChange = async open => {
    notifyOpen.value = open;
    if (open) await fetchNotify(1);
};

/* ---------------------------------------------
| Realtime Connections
--------------------------------------------- */
let unRegisterNotify = null;

watch(
    () => userStore.user?.id,
    async id => {
        if (!id) return;

        /* Notify realtime */
        connectNotifyChannel(id);

        if (unRegisterNotify) unRegisterNotify();
        unRegisterNotify = onNotifyEvent(data =>
            notifyStore.addRealtime(data)
        );

        /* Comment realtime */
        connectChatChannel(id);

        onIncomingComment(payload => {
            const senderId = payload.user_id || payload.author_id;
            if (senderId === userStore.user.id) return;

            commentStore.unread++;

            if (inboxOpen.value) refreshInbox();
        });

        /* Initial sync */
        await fetchNotify(1);
        await fetchUnread();
        await fetchInbox(1);
    },
    { immediate: true }
);

/* ---------------------------------------------
| Auto refresh notify list every 60s
--------------------------------------------- */
onMounted(() => {
    setInterval(() => {
        notifyStore.items = [...notifyStore.items];
    }, 60000);
});

/* ---------------------------------------------
| Misc Actions
--------------------------------------------- */
const goHome = () => router.push("/project-overview");

const redirectToProfile = () =>
    router.push({ name: "persons-info", params: { id: user.value.id } });

const onClickCreateTask = () => {
    if (isNonWorkflow.value) common.triggerCreateTask("non-workflow");
    else if (currentRoute.name === "tasks")
        common.triggerCreateTask("internal");
};

const handleLogout = () => {
    userStore.clearUser();
    router.push("/");
};
</script>


<style scoped>
.header {
    width: 100%;
}

.hdr {
    background: #fff;
    padding: 0 8px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #f0f0f0;
}

/* Breadcrumb */
.hdr__crumb { flex: 1; padding-left: 16px; }
.crumb { margin-left: 16px; }
.crumb__link { color: #4a5568; }
.crumb__link:hover { color: #1a202c; }
.crumb__current { display: inline-flex; align-items: center; gap: 6px; }
.crumb__add { margin-left: 4px; }

/* Right actions */
.hdr__actions { margin-right: 16px; display: flex; align-items: center; gap: 16px; }
.ha-icon { font-size: 20px; color: #8c8c8c; cursor: pointer; transition: color .2s, transform .2s; }
.ha-icon:hover { color: #fa8c16; transform: translateY(-1px); }

/* Home chip */
.home-chip {
    width: 36px; height: 36px; padding: 0; border: none; background: #fff7e6;
    display: flex; align-items: center; justify-content: center; box-shadow: none;
}
.home-chip :deep(.anticon) { color: #fa8c16; font-size: 18px; }
.home-chip:hover { background: #ffe7ba; }

/* User */
.user-chip { display: flex; align-items: center; cursor: pointer; }
.user-dropdown { width: 320px; background: #fff; border-radius: 8px; box-shadow: 0 4px 16px rgba(0,0,0,.12); overflow: hidden; }
.user-header { display: flex; align-items: center; padding: 16px; border-bottom: 1px solid #f0f0f0; }
.user-info { margin-left: 12px; flex: 1; }
.user-info .name { font-weight: 600; font-size: 16px; color: #fa541c; }
.user-info .position, .user-info .department { font-size: 13px; color: #888; display: flex; align-items: center; gap: 6px; }
.i-blue { color: #1890ff; }
.i-green { color: #52c41a; }
.user-menu { display: flex; flex-direction: column; }
.user-item { display: flex; align-items: center; gap: 8px; padding: 12px 16px; cursor: pointer; transition: background .2s; font-size: 14px; }
.user-item:hover { background: #f5f5f5; }
.user-item.danger { color: #ff4d4f; }
.color-dot { width: 16px; height: 16px; border-radius: 50%; background: #fa541c; margin-left: auto; }
.ml-auto { margin-left: auto; }

/* Cards common */
.scroll { max-height: 420px; overflow-y: auto; overflow-x: hidden; scrollbar-width: thin; scrollbar-color: #d9d9d9 transparent; }
:deep(.scroll::-webkit-scrollbar) { width: 6px; }
:deep(.scroll::-webkit-scrollbar-thumb) { background: #d9d9d9; border-radius: 8px; }
:deep(.scroll::-webkit-scrollbar-thumb:hover) { background: #bfbfbf; }

.panel-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 8px; padding: 8px 8px 4px; }
.panel-title { font-weight: 600; }
.panel-tools { display: flex; gap: 4px; flex-direction: column; align-items: flex-end; }
.panel-alert { margin: 4px 8px 8px; }
.panel-more { padding: 8px; }

/* Groups & Items */
.group-title { padding: 4px 8px; font-weight: 600; }
.group-title--muted { color: #999; }
.list-item { cursor: pointer; padding: 8px; border-radius: 8px; transition: background .15s ease; }
.list-item:hover { background: #fafafa; }
.list-item--new { background: #fff7e6; }
.list-item--new:hover { background: #ffe7ba; }
.item-title { display: flex; gap: 6px; align-items: center; }
.item-desc { color: #555; }
.meta-sub { font-size: 12px; color: #999; margin-top: 2px; }

/* Utils */
.fw-600 { font-weight: 600; }
.ellipsis-1 { white-space: nowrap; text-overflow: ellipsis; overflow: hidden; }
.ant-list-item {
    padding-left: 10px !important;
    padding-right: 10px !important;
    margin-bottom: 10px;
}
</style>
