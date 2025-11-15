<template>
    <div class="comment">
        <!-- STICKY: Tài liệu ghim (trái) + Drawer người duyệt (phải) -->
        <div
            class="mention-chips sticky-mentions"
            v-if="(pinnedFiles && pinnedFiles.length) || (mentionsSelected && mentionsSelected.length)"
        >
            <div class="sticky-head">
                <!-- LEFT: tổng số file ghim + arrow toggle -->
                <div class="sticky-left">
                    <button
                        class="pinned-toggle"
                        :disabled="!hasPinnedOverflow"
                        @click="toggleSticky"
                        :title="hasPinnedOverflow ? (isStickyExpanded ? 'Thu gọn file ghim' : 'Hiện tất cả file ghim') : 'Không có thêm file để mở'"
                        role="button"
                        :aria-expanded="!!isStickyExpanded"
                        aria-controls="pinned-files-region"
                    >
                        <span class="sticky-title">Tài liệu ghim</span>
                        <span class="sticky-count">({{ pinnedTotal }} file)</span>
                        <component :is="isStickyExpanded ? CaretUpOutlined : CaretDownOutlined" class="arrow"/>
                    </button>
                </div>

                <!-- RIGHT: Drawer người duyệt -->
                <div class="sticky-actions">
                    <a-tooltip title="Danh sách người duyệt/ký">
                        <a-badge :count="mentionsSelected?.length || 0" :offset="[-2, 3]">
                            <a-button type="text" size="small" @click="openApproverDrawer = true" class="approver-btn">
                                <TeamOutlined/>
                                <span class="approver-text">Người duyệt</span>
                            </a-button>
                        </a-badge>
                    </a-tooltip>
                </div>
            </div>

            <div id="pinned-files-region"></div>

            <!-- Pinned files -->
            <div v-if="visiblePinnedFiles.length" class="pinned-files">
                <div class="pinned-line">
                    <div
                        v-for="f in visiblePinnedFiles"
                        :key="f.id || f.file_path"
                        class="pinned-pill"
                        :title="titleOf(f)"
                    >
                        <!-- Tooltip giàu nội dung -->
                        <a-tooltip :title="pinTooltip(f)" placement="top">
                            <a
                                :href="displayHrefOf(f)"
                                target="_blank"
                                rel="noopener"
                                class="pill-link"
                            >
                                <PaperClipOutlined class="pill-icon"/>
                                <span class="pill-text">{{ titleOf(f) }}</span>
                            </a>
                        </a-tooltip>

                        <a-tooltip title="Bỏ ghim">
                            <button
                                class="pill-x"
                                type="button"
                                @click.stop.prevent="unpinOnly(f)"
                                :disabled="!canUnpinFile(f)"
                                :title="canUnpinFile(f) ? 'Bỏ ghim' : 'Bạn không có quyền bỏ ghim'"
                            >×</button>
                        </a-tooltip>
                    </div>

                    <!-- +N file (khi đang thu gọn) -->
                    <a-tag
                        v-if="!isStickyExpanded && hasPinnedOverflow"
                        color="blue"
                        class="more-pill more-pill--file"
                        @click.stop="expandSticky"
                    >
                        +{{ hiddenPinnedCount }} file
                    </a-tag>

                    <!-- Thu gọn (khi đang mở) -->
<!--                    <a-tag-->
<!--                        v-if="isStickyExpanded && hasPinnedOverflow"-->
<!--                        color="processing"-->
<!--                        class="more-pill more-pill&#45;&#45;file"-->
<!--                        @click.stop="collapseSticky"-->
<!--                    >-->
<!--                        Thu gọn-->
<!--                    </a-tag>-->
                </div>
            </div>
        </div>

        <!-- LIST COMMENT (bubbles) -->
        <div class="list-comment" v-if="listComment" ref="listEl" :style="{ paddingBottom: listPadBottom }">
            <a-spin :spinning="loadingComment">
                <div
                    class="tg-row"
                    v-for="(item, index) in listComment"
                    :key="item.id || index"
                    :class="{ me: String(item.user_id) === String(currentUserId) }"
                >
                    <div class="avatar" v-if="String(item.user_id) !== String(currentUserId)">
                        <BaseAvatar
                            :src="getUserById(item.user_id)?.avatar"
                            :name="getUserById(item.user_id)?.name || 'Không rõ'"
                            :size="34"
                            shape="circle"
                            :preferApiOrigin="true"
                        />
                    </div>

                    <div class="bubble" :class="{ me: String(item.user_id) === String(currentUserId) }">
                        <!-- actions (sửa/xóa) -->
<!--                        <div class="actions" v-if="canEditOrDelete(item)">-->
<!--                            <a-dropdown trigger="click" :getPopupContainer="(t) => t.parentNode">-->
<!--                                <a-button type="text" size="small">-->
<!--                                    <EllipsisOutlined/>-->
<!--                                </a-button>-->
<!--                                <template #overlay>-->
<!--                                    <a-menu>-->
<!--                                        <a-menu-item @click="startEdit(item)">Sửa</a-menu-item>-->
<!--                                        <a-menu-item>-->
<!--                                            <a-popconfirm-->
<!--                                                title="Bạn chắc chắn muốn xóa comment này?"-->
<!--                                                ok-text="Xóa"-->
<!--                                                cancel-text="Hủy"-->
<!--                                                @confirm="handleDeleteComment(item.id)"-->
<!--                                                placement="topRight"-->
<!--                                            >Xóa-->
<!--                                            </a-popconfirm>-->
<!--                                        </a-menu-item>-->
<!--                                    </a-menu>-->
<!--                                </template>-->
<!--                            </a-dropdown>-->
<!--                        </div>-->

                        <div class="text">
                            <div class="author" v-if="String(item.user_id) !== String(currentUserId)">
                                {{ getUserById(item.user_id)?.name || 'Không rõ' }}
                            </div>

                            <!-- nội dung có thể chứa link -->
                            <div class="msg-content" v-html="formatMessage(item.content)"></div>
                        </div>


                        <!-- Attachments trong bubble -->
                        <div v-if="item.files && item.files.length" class="tg-attachments">
                            <div v-for="f in item.files" :key="f.id || f.file_path || f.link_url" class="tg-att-item">
                                <!-- Image -->
                                <a-image
                                    v-if="kindOfCommentFile(f) === 'image'"
                                    :src="srcWithBustIfImage(f)"
                                    :height="72"
                                    :preview="true"
                                    class="cm-att__thumb"
                                />
                                <!-- Non-image -->
                                <div v-else class="cm-att__icon">
                                    <component :is="pickIcon(kindOfCommentFile(f))" class="cm-att__icon-i"/>
                                </div>

                                <div class="cm-att__line">
                                    <a
                                        class="tg-file-link"
                                        :href="displayHrefOf(f)"
                                        target="_blank"
                                        rel="noopener"
                                        :title="f.file_name || prettyUrl(hrefOf(f))"
                                    >
                                        {{ f.file_name || prettyUrl(hrefOf(f)) }}
                                    </a>

                                    <!-- 📌 Pin -->
<!--                                    <a-tooltip :title="isPinnable(f) ? (isPinned(f) ? 'Bỏ ghim file này' : 'Ghim file lên trên') : 'Chưa upload xong, không thể ghim'">-->
<!--                                        <PushpinOutlined-->
<!--                                            class="pin-btn"-->
<!--                                            :class="{ 'disabled-pin': !isPinnable(f) }"-->
<!--                                            :style="{ color: isPinned(f) ? '#faad14' : '#999' }"-->
<!--                                            @click.stop="isPinnable(f) ? togglePin(f) : null"-->
<!--                                        />-->
<!--                                    </a-tooltip>-->
                                </div>
                            </div>
                        </div>

                        <div class="meta">
                            <a-tooltip :title="formatVi(item.created_at)">{{ fromNowVi(item.created_at) }}</a-tooltip>
                        </div>
                    </div>
                </div>
            </a-spin>
        </div>

        <!-- FOOTER: composer -->
        <div class="footer-fixed tg-footer" ref="footerEl">
            <div class="load-more" v-if="currentPage < totalPage && !loadingComment">
                <a-button size="small" @click="getListComment(currentPage + 1)">Tải thêm</a-button>
            </div>

            <div class="tg-file-strip" v-if="selectedFile">
                <div class="tg-file-pill">
                    <PaperClipOutlined/>
                    <span class="name">{{ selectedFile.name }}</span>
                    <span class="x" @click.stop.prevent="handleRemoveFile()">×</span>
                </div>

                <!-- NEW: chọn loại văn bản -->
                <div class="tg-file-meta">
                    <a-radio-group v-model:value="selectedDocType" size="small">
                        <a-radio-button value="internal">Văn bản nội bộ</a-radio-button>
                        <a-radio-button value="external">Văn bản ban hành</a-radio-button>
                    </a-radio-group>
                </div>
            </div>

            <div class="tg-composer">
                <!-- Attach -->
                <a-upload :show-upload-list="false" :multiple="false" :max-count="1" :before-upload="handleBeforeUpload">
                    <a-button type="text" class="tg-attach-btn" :title="'Đính kèm'">
                        <PaperClipOutlined/>
                    </a-button>
                </a-upload>

                <!-- Ô nhập -->
                <a-textarea
                    v-model:value="inputValue"
                    class="tg-input"
                    :bordered="false"
                    :auto-size="{ minRows: 1, maxRows: 6 }"
                    :placeholder="isEditing ? 'Sửa bình luận… (Enter để lưu, Esc để hủy)' : 'Viết lời nhắn… (Enter để gửi, Shift+Enter để xuống dòng, gõ @ để thêm người duyệt)'"
                    @keydown="onComposerKeydown"
                    @input="onInputDetectMention"
                />

                <!-- Nút gửi / lưu -->
                <a-button
                    class="tg-send-btn"
                    :class="{ 'is-active': canSend }"
                    shape="circle"
                    :disabled="!canSend"
                    @click="onSubmit()"
                    :title="isEditing ? 'Lưu chỉnh sửa' : 'Gửi'"
                >
                    <template v-if="isEditing">
                        <CheckOutlined/>
                    </template>
                    <template v-else>
                        <SendOutlined/>
                    </template>
                </a-button>
            </div>

            <!-- file chip preview -->
<!--            <div class="tg-file-strip" v-if="selectedFile">-->
<!--                <div class="tg-file-pill">-->
<!--                    <PaperClipOutlined/>-->
<!--                    <span class="name">{{ selectedFile.name }}</span>-->
<!--                    <span class="x" @click.stop.prevent="handleRemoveFile()">×</span>-->
<!--                </div>-->

<!--                &lt;!&ndash; NEW: chọn loại văn bản &ndash;&gt;-->
<!--                <div class="tg-file-meta">-->
<!--                    <a-radio-group v-model:value="selectedDocType" size="small">-->
<!--                        <a-radio-button value="internal">Văn bản nội bộ</a-radio-button>-->
<!--                        <a-radio-button value="external">Văn bản ban hành</a-radio-button>-->
<!--                    </a-radio-group>-->
<!--                </div>-->
<!--            </div>-->

            <!-- Mention pop -->
            <div class="mention-row">
                <a-popover
                    trigger="click"
                    :open="addMentionOpen"
                    @update:open="(v) => (addMentionOpen = v)"
                    placement="topLeft"
                    :getPopupContainer="(t) => t.parentNode"
                >
                    <template #content>
                        <div class="mention-pop">
                            <div class="row">
                                <span class="lbl">Người:</span>
                                <a-select
                                    v-model:value="mentionForm.userId"
                                    :options="userOptions"
                                    show-search
                                    :filterOption="filterUser"
                                    style="min-width: 220px"
                                    placeholder="Chọn người"
                                />
                            </div>
                            <div class="row">
                                <span class="lbl">Vai trò:</span>
                                <a-segmented v-model:value="mentionForm.role"
                                             :options="[{ label: 'Duyệt', value: 'approve' }]"/>
                            </div>
                            <div class="row" style="justify-content: flex-end; gap: 8px">
                                <a-button size="small" @click="resetMentionForm">Hủy</a-button>
                                <a-button size="small" type="primary" @click="addMention">Thêm</a-button>
                            </div>
                        </div>
                    </template>
                </a-popover>
            </div>
        </div>

        <!-- Drawer người duyệt -->
        <a-drawer
            v-model:open="openApproverDrawer"
            title="Người duyệt & ký"
            placement="right"
            width="420"
            :get-container="false"
            :style="{ position: 'absolute' }"
            class="approver-drawer"
        >
            <!-- Toolbar (bên phải tiêu đề) -->
            <template #extra>
                <a-switch
                    v-model:checked="filterPendingOnly"
                    checked-children="Chờ"
                    un-checked-children="Tất cả"
                    :title="filterPendingOnly ? 'Chỉ hiện đang chờ' : 'Hiện tất cả'"
                />
            </template>

            <div class="drawer-toolbar">
                <div class="creator-info">
                    Người tạo: <strong>{{ rosterCreatedByName || 'Không rõ' }}</strong>
                    <small v-if="rosterCreatedBy" style="margin-left:8px; color:#6b7280">({{ rosterCreatedBy }})</small>
                </div>

                <!-- tuỳ chọn: nếu bạn có biến progress/all_approved từ API, hiển thị ở đây -->
                <div class="drawer-stats">
                    <span v-if="typeof rosterProgress !== 'undefined'">Tiến độ: {{ rosterProgress }}%</span>
                    <span v-if="typeof rosterAllApproved !== 'undefined' && rosterAllApproved" class="approved-tag">• Đã duyệt xong</span>
                </div>
            </div>

            <!-- Empty state -->
            <div v-if="finalDrawerMentions.length === 0" class="drawer-empty">
                <div class="empty-icon">😶‍🌫️</div>
                <div>Chưa có người duyệt/ký phù hợp.</div>
                <div class="hint">Hãy thêm người hoặc bỏ lọc để xem tất cả.</div>
            </div>

            <!-- Danh sách -->
            <div v-else class="drawer-list">

                <!-- thay bằng Draggable (PascalCase) -->
                <Draggable
                    v-model="dragList"
                    item-key="user_id"
                    handle=".chip-card"
                    ghost-class="chip-ghost"
                    animation="200"
                    :disabled="!canModifyRoster || filterPendingOnly || drawerSearch"
                    @end="handleReorder"
                >
                    <template v-slot:item="{ element: m, index }">
                        <div
                            :key="m.user_id + '-' + (m.status || '') + '-' + (m.acted_at || '') + '-' + (m.added_at || '')"
                            class="drawer-chip"
                        >
                            <!-- Tooltip hướng dẫn kéo thả; đặt trên chip-card để người dùng thấy khi hover -->
                            <a-tooltip
                                :title="filterPendingOnly || drawerSearch
    ? 'Tắt bộ lọc hoặc tìm kiếm để sắp xếp lại thứ tự duyệt'
    : canModifyRoster
      ? 'Kéo thả để thay đổi thứ tự duyệt'
      : 'Chỉ người tạo task mới được sắp xếp thứ tự duyệt'"
                                placement="top"
                            >
                                <div
                                    class="chip-card"
                                    role="button"
                                    tabindex="0"
                                    :class="{
      'is-approved': m.status === 'approved',
      'is-pending': m.status === 'pending' || m.status === 'processing',
      'is-rejected': m.status === 'rejected',
    }"
                                >
                                    <!-- Avatar -->
                                    <div class="chip-avatar" aria-hidden="true">
                                        <BaseAvatar
                                            :src="getUserById(m.user_id)?.avatar"
                                            :name="getUserById(m.user_id)?.name || m.name || 'U'"
                                            :size="28"
                                            shape="circle"
                                            :preferApiOrigin="true"
                                        />
                                    </div>

                                    <!-- Thông tin -->
                                    <div class="chip-body">
                                        <div class="name-row" :title="m.name">
                                            <span class="chip-name">@{{ m.name }}</span>
                                        </div>
                                        <div class="meta-row">
                                            <span class="dot" :class="statusDotClass(m.status)"></span>
                                            <span class="chip-state">
                                              {{ m.status === 'approved' ? 'Đã duyệt' : m.status === 'rejected' ? 'Đã từ chối' : 'Chờ duyệt' }}
                                            </span>
                                            <span class="meta-sep">•</span>
                                            <span class="chip-time">{{ metaTime(m) }}</span>
                                        </div>

                                        <div class="actions-row">
                                            <template v-if="canActOnChip(m)">
                                                <a-button size="small" type="primary" @click="handleApproveAction(m, 'approved')">
                                                    <template #icon><CheckOutlined /></template>Đồng ý
                                                </a-button>
                                                <a-button size="small" danger @click="handleApproveAction(m, 'rejected')">
                                                    <template #icon><CloseOutlined /></template>Từ chối
                                                </a-button>
                                            </template>

                                            <template v-else>
                                                <a-tag
                                                    v-if="m.status === 'pending' || m.status === 'processing'"
                                                    color="blue"
                                                    style="border-radius:12px"
                                                >
                                                    Lượt của @{{ m.name }}
                                                </a-tag>
                                            </template>

                                            <a-button
                                                v-if="canModifyRoster"
                                                size="small"
                                                type="text"
                                                class="chip-close"
                                                @click="removeMention(m.user_id)"
                                            >×</a-button>
                                        </div>
                                    </div>
                                </div>
                            </a-tooltip>
                        </div>
                    </template>

                </Draggable>
            </div>
        </a-drawer>

    </div>
</template>

<script setup>
import {ref, reactive, computed, nextTick, onMounted, onBeforeUnmount, watch, watchEffect } from 'vue'
import {
    CheckOutlined,
    CloseOutlined,
    EllipsisOutlined,
    FileExcelOutlined,
    FilePdfOutlined,
    FilePptOutlined,
    FileTextOutlined,
    FileWordOutlined,
    LinkOutlined,
    PaperClipOutlined,
    PushpinOutlined,
    SendOutlined,
    CaretDownOutlined,
    CaretUpOutlined,
    TeamOutlined,
} from '@ant-design/icons-vue'

import {
    approveRosterAPI,
    createComment,
    deleteComment,
    getComments,
    getTaskRosterAPI,
    mergeTaskRosterAPI,
    rejectRosterAPI,
    updateComment,
} from '@/api/task'

import {
    adoptTaskFileFromPathAPI,
    getPinnedFilesAPI,
    getTaskFilesAPI,
    pinTaskFileAPI,
    unpinTaskFileAPI,
    uploadTaskFileLinkAPI,
} from '@/api/taskFiles'

import {getUsers} from '@/api/user'
import {useRoute} from 'vue-router'
import {useUserStore} from '@/stores/user.js'
import {message} from 'ant-design-vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'
import relativeTime from 'dayjs/plugin/relativeTime'
import BaseAvatar from '@/components/common/BaseAvatar.vue'

dayjs.extend(relativeTime)
dayjs.locale('vi')

import Draggable from 'vuedraggable'
// finalDrawerMentions: mảng các mention
// bạn có thể lắng nghe sự kiện @update để cập nhật lại thứ tự
const handleReorder = async (evt) => {
    if (!canModifyRoster.value) {
        message.warning('Chỉ người tạo task mới được thay đổi thứ tự người duyệt')
        // restore dragList từ mentionsSelected nếu cần
        dragList.value = Array.isArray(finalDrawerMentions.value) ? finalDrawerMentions.value.map(x => ({ ...x })) : []
        return
    }

    // tiếp tục logic hiện có...
    console.log('drag end, new order', dragList.value)
    mentionsSelected.value = dragList.value.map(m => ({ ...m }))

    try {
        await persistRoster('replace')
        message.success('Đã lưu thứ tự người duyệt')
    } catch (e) {
        console.error('save reorder failed', e)
        message.error('Không lưu được thứ tự')
    }
}

// new reactive list for draggable
const dragList = ref([])

/* ===== time helpers (VI) ===== */
const tick = ref(Date.now())
let t

function fromNowVi(dt) {
    tick.value
    const d = dayjs(dt)
    return d.isValid() ? d.fromNow() : ''
}

function formatVi(dt) {
    const d = dayjs(dt)
    return d.isValid() ? d.format('HH:mm DD/MM/YYYY') : ''
}

/* ===== state ===== */
const store = useUserStore()
const route = useRoute()
const selectedDocType = ref('internal') // mặc định 'internal'

const taskId = computed(() => Number(route.params.taskId || route.params.id))
const currentUserId = computed(() => store.currentUser?.id ?? null)
const canEditOrDelete = (item) =>
    String(item.user_id) === String(currentUserId.value) || !!store.currentUser?.is_admin

const inputValue = ref('')
const listComment = ref([])
const listUser = ref([])

const selectedFile = ref(null)

const loadingComment = ref(false)
const loadingUpdate = ref(false)

const totalPage = ref(1)
const currentPage = ref(1)

/* ===== sticky + scroll helpers ===== */
const listEl = ref(null)
const footerEl = ref(null)
const listPadBottom = ref('96px')
let ro

function measureFooter() {
    const h = footerEl.value?.offsetHeight || 96
    listPadBottom.value = `${h + 8}px`
}

const currentUserRole = computed(() => store.currentUser?.role || '')

// cho file object f (có pinned_by)
function canUnpinFile(f) {
    if (!f) return false
    // super admin hoặc chính người đã ghim
    return String(currentUserRole.value) === 'super admin' || Number(f.pinned_by) === Number(currentUserId.value)
}

async function unpinOnly(file) {
    if (!file) return;

    const userId = Number(currentUserId.value);
    const userRole = currentUserRole.value;
    let tfId = getTaskFileId(file);
    const pathKey = normalizePath(file.file_path || file.link_url || '');

    if (!tfId) {
        const byPath = taskFileByPath.value[pathKey];
        tfId = byPath?.id ? Number(byPath.id) : null;
    }

    if (!tfId) {
        message.error('Không tìm thấy ID để bỏ ghim');
        return;
    }

    if (!canUnpinFile(file)) {
        message.warning('Bạn không có quyền bỏ ghim file này');
        return;
    }

    const lockKey = `unpin:${tfId}`
    if (pendingPinOps.has(lockKey)) return
    pendingPinOps.add(lockKey)

    // ===== optimistic remove from UI =====
    const prevPinned = (pinnedFiles.value || []).slice()
    pinnedFiles.value = (pinnedFiles.value || []).filter(p => {
        const pid = Number(p.id || p.task_file_id || 0)
        const sameId = pid && pid === Number(tfId)
        const samePath = normalizePath(p.file_path || p.link_url || '') === pathKey
        return !(sameId || samePath)
    })

    try {
        const res = await unpinTaskFileAPI(tfId, { user_id: userId, user_role: userRole })
        // success: keep optimistic removal, optionally show message from server
        message.success(res?.data?.message || 'Đã bỏ ghim')
        // don't immediately call loadPinnedFiles() — avoid re-adding during backend delay
    } catch (e) {
        console.error('unpin failed', e)
        // rollback: restore previous pinned list (or reload from server)
        pinnedFiles.value = prevPinned
        // if server returned 403/permission -> show nice msg
        const status = e?.response?.status
        if (status === 403) {
            message.warning(e.response?.data?.messages?.error || 'Bạn không có quyền')
        } else {
            message.error('Không thể bỏ ghim — thử lại')
        }
    } finally {
        pendingPinOps.delete(lockKey)
    }
}


function getLocalUser() {
    // ưu tiên store nếu bạn đã có pin/store pattern
    if (store && store.currentUser) return store.currentUser
    try {
        const raw = localStorage.getItem('user')
        if (!raw) return null
        return JSON.parse(raw)?.user ?? JSON.parse(raw)
    } catch (e) {
        return null
    }
}

function scrollToBottom() {
    const el = listEl.value
    if (!el) return
    el.scrollTop = el.scrollHeight
}

/* ===== task_files index để map file_path -> task_files.id ===== */
const taskFileByPath = ref({})
const normalizePath = (u = '') => {
    const s = String(u).split('?')[0]
    return s.replace(/\/+$/, '')
}

/* ===== Drawer người duyệt ===== */
const openApproverDrawer = ref(false)
const filterPendingOnly = ref(false)
const mentionsSelected = ref([])

const drawerMentions = computed(() => {
    const arr = mentionsSelected.value || []
    return filterPendingOnly.value
        ? arr.filter((m) => m.status === 'pending' || m.status === 'processing')
        : arr
})

/* ===== sticky expand/collapse ===== */
const isStickyExpanded = ref(false)
const MAX_FILES_COLLAPSED = 1
const pinnedFiles = ref([])

const hasPinnedOverflow = computed(() => (pinnedFiles.value?.length || 0) > MAX_FILES_COLLAPSED)
const expandSticky = () => {
    isStickyExpanded.value = true
}
const collapseSticky = () => {
    isStickyExpanded.value = false
}
const toggleSticky = () => {
    if (!hasPinnedOverflow.value) return
    isStickyExpanded.value = !isStickyExpanded.value
}
const pinnedTotal = computed(() => pinnedFiles.value?.length || 0)
const visiblePinnedFiles = computed(() =>
    isStickyExpanded.value ? pinnedFiles.value || [] : (pinnedFiles.value || []).slice(0, MAX_FILES_COLLAPSED)
)
const hiddenPinnedCount = computed(() =>
    Math.max(0, (pinnedFiles.value?.length || 0) - MAX_FILES_COLLAPSED)
)

// store id/name người tạo task trả từ API /tasks/{id}/roster
const rosterCreatedBy = ref(null)
const rosterCreatedByName = ref(null)
const canModifyRoster = computed(() => {
    if (rosterCreatedBy.value == null) return false
    return String(rosterCreatedBy.value) === String(currentUserId.value)
})
const rosterProgress = ref(0)
const rosterAllApproved = ref(false)

// role code của current user — lấy từ store.currentUser.role_code hoặc session fallback
const currentRoleCode = computed(() => {
    // nếu store.currentUser có role_code thì dùng luôn
    const r = store?.currentUser?.role_code ?? store?.currentUser?.role
    return r ? String(r) : null
})

// helper: mapping role_code -> rank (số càng lớn = quyền càng cao)
function normalizeRoleCode(c='') {
    return String(c||'').toLowerCase().replace(/\s+/g,'_') // 'super admin' -> 'super_admin'
}
function roleRank(code='') {
    switch (normalizeRoleCode(code)) {
        case 'super_admin': return 3
        case 'admin': return 2
        case 'user': return 1
        default: return 0
    }
}

function applyPartialReorderToFull(filteredNewOrder) {
    const full = mentionsSelected.value.slice()
    // map user_id -> position in filteredNewOrder
    const pos = new Map(filteredNewOrder.map((x,i)=>[String(x.user_id), i]))
    // stable sort full: items in pos keep their new relative order (pos), others keep original relative order
    full.sort((a,b)=>{
        const pa = pos.has(String(a.user_id)) ? pos.get(String(a.user_id)) : Number.MAX_SAFE_INTEGER
        const pb = pos.has(String(b.user_id)) ? pos.get(String(b.user_id)) : Number.MAX_SAFE_INTEGER
        if (pa === pb) return 0
        return pa - pb
    })
    mentionsSelected.value = full
}



/* ===== task file helpers ===== */
function getTaskFileId(f = {}) {
    if (f.task_file_id || f.taskFileId) return Number(f.task_file_id || f.taskFileId)
    if (typeof f.id === 'number' && (f.file_path || f.link_url)) {
        const key = normalizePath(f.file_path || f.link_url)
        if (taskFileByPath.value[key]?.id === f.id) return f.id
    }
    const byPath = taskFileByPath.value[normalizePath(f.file_path || f.link_url || '')]
    return byPath?.id ? Number(byPath.id) : null
}

async function ensureTaskFileId(file, { autoPin = false } = {}) {
    const existed = getTaskFileId(file)
    if (existed) {
        if (autoPin) {
            try { await pinTaskFileAPI(existed, { user_id: store.currentUser.id }); await loadPinnedFiles(); } catch (e) { /* ignore pin error */ }
        }
        return existed
    }

    const path = String(file.file_path ?? file.url ?? '')
    const name = file.file_name || file.name || prettyUrl(path)

    try {
        if (/^https?:\/\//i.test(path)) {
            const {data} = await uploadTaskFileLinkAPI(taskId.value, {
                title: name,
                url: path,
                user_id: Number(store.currentUser.id),
            })
            const created = Array.isArray(data) ? data[0] : data?.data || data
            const key = normalizePath(created?.file_path || created?.link_url || path)
            taskFileByPath.value[key] = {...(created || {}), file_path: created?.file_path || created?.link_url || path}

            const newId = Number(created?.id)
            if (autoPin && newId) {
                try { await pinTaskFileAPI(newId, { user_id: store.currentUser.id }); await loadPinnedFiles(); } catch (e) { /* handle pin error silently */ }
            }
            return newId
        } else {
            const {data} = await adoptTaskFileFromPathAPI(taskId.value, {
                task_id: Number(taskId.value),
                user_id: Number(store.currentUser.id),
                file_path: path,
                file_name: name,
            })
            const created = data?.data || data
            const key = normalizePath(created?.file_path || path)
            taskFileByPath.value[key] = created
            const newId = Number(created?.id)
            if (autoPin && newId) {
                try { await pinTaskFileAPI(newId, { user_id: store.currentUser.id }); await loadPinnedFiles(); } catch (e) { /* ignore */ }
            }
            return newId
        }
    } catch (e) {
        console.error('ensureTaskFileId error', e?.response?.data || e)
        message.error('Không tạo được tài liệu để ghim')
        return null
    }
}


async function loadTaskFiles() {
    try {
        const {data} = await getTaskFilesAPI(taskId.value)
        const files = Array.isArray(data) ? data : data?.data || []
        const idx = {}
        for (const f of files) {
            const key = normalizePath(f.file_path || f.link_url || '')
            if (key) idx[key] = {...f, file_path: f.file_path || f.link_url || ''}
        }
        taskFileByPath.value = idx
    } catch (e) {
        console.error('loadTaskFiles error', e)
        taskFileByPath.value = {}
    }
}

/* pin */
function isPinned(file) {
    const list = Array.isArray(pinnedFiles.value) ? pinnedFiles.value : []
    const tfId = getTaskFileId(file)
    if (tfId) return list.some((p) => Number(p.id) === Number(tfId))
    const path = normalizePath(file.file_path || file.link_url || '')
    return list.some((p) => normalizePath(p.file_path || p.link_url || '') === path)
}

function isPinnedNow(file) {
    if (!file) return false;
    // try by task_file id
    const tfId = getTaskFileId(file);
    if (tfId) {
        return (pinnedFiles.value || []).some(p => Number(p.id) === Number(tfId));
    }
    // fallback: compare normalized path
    const path = normalizePath(hrefOf(file) || file.file_path || file.link_url || '');
    if (!path) return false;
    return (pinnedFiles.value || []).some(p => normalizePath(p.file_path || p.link_url || '') === path);
}

function isPinnedFlag(file) {
    // nếu object server trả về có flag rõ ràng -> dùng luôn
    if (!file) return false;
    if (typeof file.is_pinned !== 'undefined') {
        // backend có thể trả '1' hoặc true
        return Number(file.is_pinned) === 1 || file.is_pinned === true;
    }
    // nếu có explicit pinned_by thì gần như chắc là pinned
    if (typeof file.pinned_by !== 'undefined' && file.pinned_by !== null && file.pinned_by !== '') {
        return true;
    }
    return false;
}

const pendingPinOps = new Set()


async function togglePin(file) {
    if (!file) return;

    let tfId = getTaskFileId(file);
    const pathKey = normalizePath(hrefOf(file) || file.file_path || file.link_url || '');
    const lockKey = tfId ? `id:${tfId}` : `path:${pathKey}`;

    if (pendingPinOps.has(lockKey)) {
        console.warn('togglePin already in progress for', lockKey);
        return;
    }
    pendingPinOps.add(lockKey);

    try {
        // REPLACE previous "already" logic with robust check:
        // 1) If file object has is_pinned / pinned_by -> use that.
        // 2) Else fallback to isPinnedNow(file) (compare pinnedFiles array).
        let already = false;
        if (isPinnedFlag(file)) {
            already = true;
        } else {
            already = isPinnedNow(file);
        }

        console.log('togglePin starting', { lockKey, tfId, pathKey, already, file });

        if (already) {
            // UNPIN branch ...
            // (rest of your existing unpin logic)
        } else {
            // PIN branch ...
            // (rest of your existing pin logic)
        }
    } catch (e) {
        // ...
    } finally {
        pendingPinOps.delete(lockKey);
    }
}

/* ===== file kind helpers ===== */
const IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const PDF_EXTS = new Set(['pdf'])
const WORD_EXTS = new Set(['doc', 'docx'])
const EXCEL_EXTS = new Set(['xls', 'xlsx', 'csv'])
const PPT_EXTS = new Set(['ppt', 'pptx'])

const extOf = (name = '') => {
    const n = String(name).split('?')[0]
    const m = n.lastIndexOf('.')
    return m >= 0 ? n.slice(m + 1).toLowerCase() : ''
}

function detectKind(o = {}) {
    const t = o.file_type || ''
    if (t) {
        if (String(t).startsWith('image/')) return 'image'
        if (t === 'application/pdf') return 'pdf'
    }
    const e = extOf(o.name || o.url || '')
    if (IMAGE_EXTS.has(e)) return 'image'
    if (PDF_EXTS.has(e)) return 'pdf'
    if (WORD_EXTS.has(e)) return 'word'
    if (EXCEL_EXTS.has(e)) return 'excel'
    if (PPT_EXTS.has(e)) return 'ppt'
    if (/^https?:\/\//i.test(o.url || '')) return 'link'
    return 'other'
}

function pickIcon(k) {
    switch (k) {
        case 'pdf':
            return FilePdfOutlined
        case 'word':
            return FileWordOutlined
        case 'excel':
            return FileExcelOutlined
        case 'ppt':
            return FilePptOutlined
        case 'link':
            return LinkOutlined
        default:
            return FileTextOutlined
    }
}

function prettyUrl(u) {
    try {
        const url = new URL(u)
        const path = url.pathname.replace(/^\/+/, '')
        const short = path.length > 30 ? path.slice(0, 30) + '…' : path
        return url.host + (short ? '/' + short : '')
    } catch {
        return u
    }
}

const hrefOf = (f = {}) => f.file_path || f.link_url || ''
const titleOf = (f = {}) => f.file_name || f.title || prettyUrl(hrefOf(f))
const kindOfCommentFile = (f = {}) => detectKind({name: f.file_name, url: hrefOf(f), file_type: f.file_type})

function isOfficeKind(kind) {
    return kind === 'word' || kind === 'excel' || kind === 'ppt'
}

function absUrl(u = '') {
    try {
        const url = new URL(u, window.location.origin)
        return url.toString()
    } catch {
        return u
    }
}

function officeViewerUrl(u = '') {
    const absolute = absUrl(u)
    return `https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(absolute)}`
}

function displayHrefOf(f = {}) {
    const href = hrefOf(f)
    const k = kindOfCommentFile(f)
    return isOfficeKind(k) ? officeViewerUrl(href) : href
}

// format date helper (sử dụng dayjs đã import)
const formatDate = (v) => {
    try {
        return v ? dayjs(v).format('DD/MM/YYYY HH:mm') : 'Không rõ thời gian'
    } catch {
        return 'Không rõ thời gian'
    }
}

// Lấy tên người ghim: ưu tiên trường pinned_by_name, fallback dùng danh sách user
function nameOfPinnedBy(f) {
    if (!f) return 'Không rõ'
    if (f.pinned_by_name) return f.pinned_by_name
    const id = Number(f.pinned_by || 0)
    if (id && getUserById(id)?.name) return getUserById(id).name
    // nếu uploaded_by có tên hữu ích
    if (f.uploaded_by && getUserById(Number(f.uploaded_by))?.name) return getUserById(Number(f.uploaded_by)).name
    return f.pinned_by ? String(f.pinned_by) : 'Không rõ'
}

// xây tooltip — trả chuỗi nhiều dòng (Antd sẽ hiển thị \n như xuống dòng)
const pinTooltip = (f) => {
    if (!f) return ''
    const by = nameOfPinnedBy(f)
    const at = formatDate(f.pinned_at || f.updated_at || f.created_at)
    // nếu muốn hiển thị thêm nguồn:
    const source = f.source ? `Nguồn: ${f.source}` : ''
    return `Ghim bởi: ${by}\nThời gian: ${at}${source ? '\n' + source : ''}`
}




/* ===== Roster actions (Drawer) ===== */
async function handleApproveAction(m, status) {
    // status phải là 'approved' hoặc 'rejected'
    if (!['approved', 'rejected'].includes(status)) return

    // quyền client check
    if (!canActOnChip(m)) {
        message.warning('Bạn không có quyền thực hiện hành động này (chia lượt duyệt)');
        return;
    }

    // note / optional
    const note = null

    try {
        // --- Step A: if this is a simple self-approve & not admin, call rosterApprove API (server will update single entry).
        const myRank = roleRank(currentRoleCode.value)
        const targetUser = getUserById(Number(m.user_id)) || {}
        const targetRoleCode = targetUser.role_code || targetUser.role || (m.role === 'sign' ? 'user' : 'user')
        const targetRank = roleRank(targetRoleCode)

        // build new local roster state (optimistic update)
        const now = new Date().toISOString().slice(0, 19).replace('T', ' ')
        const newRoster = (mentionsSelected.value || []).map(r => ({ ...r }))

        // Find index of target
        const idx = newRoster.findIndex(x => String(x.user_id) === String(m.user_id))
        if (idx === -1) {
            message.error('Không tìm thấy thành viên trong danh sách')
            return
        }

        // If approver is normal user approving themselves -> we can call server rosterApprove endpoint
        // But to support cascade when admin/super_admin approves, we will compute replacement payload and call merge API.

        // Update target
        newRoster[idx].status = status
        newRoster[idx].acted_at = now
        if (!newRoster[idx].note) newRoster[idx].note = null

        // Cascade rules: if approver is admin/super_admin and action is approve -> mark all lower-rank pending as approved
        if (status === 'approved' && myRank >= roleRank('admin')) {
            for (let i = 0; i < newRoster.length; i++) {
                const it = newRoster[i]
                if ((it.status || '').toLowerCase() === 'pending') {
                    const u = getUserById(Number(it.user_id)) || {}
                    const rcode = u.role_code || u.role || (it.role === 'sign' ? 'user' : 'user')
                    const rr = roleRank(rcode)
                    // only change those with rank < = approver's rank but not higher
                    if (rr <= myRank) {
                        // do not change those with rank > myRank (already handled by check)
                        it.status = 'approved'
                        it.acted_at = now
                    }
                }
            }
        }

        // If approver is normal user approving themselves -> no cascade
        // If status === 'rejected', do not cascade

        // Persist full roster (replace) to server
        // Normalize payload for merge API: list of { user_id, name, role, status }
        const payload = newRoster.map(x => ({
            user_id: Number(x.user_id),
            name: x.name,
            role: x.role,
            status: x.status,
            acted_at: x.acted_at || null,
            note: x.note || null,
        }))

        // call mergeTaskRosterAPI(taskId, payload, 'replace') — use your existing wrapper
        // If you don't have this wrapper, use axios.post(`/api/tasks/${taskId.value}/roster/merge`, { mentions: payload, mode: 'replace' })
        await persistRosterWithPayload(payload) // implement wrapper below

        // optimistic update local UI
        mentionsSelected.value = newRoster.map(x => ({ ...x }))
        // refresh server state
        await syncRosterFromServer()
        message.success(status === 'approved' ? 'Đã duyệt' : 'Đã từ chối')
    } catch (e) {
        console.error('handleApproveAction error', e)
        message.error('Xử lý không thành công')
    }
}

// wrapper: persist roster by replace (calls mergeTaskRosterAPI or direct axios)
async function persistRosterWithPayload(payload) {
    try {
        // if you already have mergeTaskRosterAPI defined: mergeTaskRosterAPI(taskId, payload, 'replace')
        await mergeTaskRosterAPI(taskId.value, payload, 'replace')
        // optionally call syncRosterFromServer after
    } catch (e) {
        console.error('persistRosterWithPayload failed', e)
        throw e
    }
}


/* users & mentions add/remove */
const getUserById = (id) => listUser.value.find((u) => u.id === id) || {}
const userOptions = computed(() => (listUser.value || []).map((u) => ({value: String(u.id), label: u.name})))
const filterUser = (input, option) => (option?.label ?? '').toLowerCase().includes(String(input).toLowerCase())

let addMentionOpen = ref(false)
const mentionForm = ref({userId: null, role: 'approve'})

function resetMentionForm() {
    mentionForm.value.userId = null
    mentionForm.value.role = 'approve'
    closeMentionPopover()
}

const addMention = async () => {
    const uid = mentionForm.value.userId
    if (!uid) return
    const user = listUser.value.find((u) => String(u.id) === String(uid))
    const displayName = user?.name || `#${uid}`

    // bảo vệ: nếu đã có thì thông báo
    if (mentionsSelected.value.some((m) => String(m.user_id) === String(uid))) {
        message.info('Người này đã có trong danh sách')
        // vẫn insert mention text vào composer nếu cần
        insertMention(displayName)
        addMentionOpen.value = false
        await nextTick()
        const ta = document.querySelector('.tg-input textarea.ant-input')
        if (ta && typeof ta.focus === 'function') ta.focus()
        return
    }

    // thêm local (optimistic)
    mentionsSelected.value.push({
        user_id: String(uid),
        name: displayName,
        role: mentionForm.value.role,
        status: 'pending',
        added_at: new Date().toISOString().slice(0, 19).replace('T', ' ')
    })

    // cập nhật composer text + đóng pop
    insertMention(displayName)
    addMentionOpen.value = false

    // persist lên server bằng mode 'merge' (thêm vào, không ghi đè toàn bộ)
    try {
        // gọn: persistRoster(mode) đã có trong file — dùng mode 'merge'
        await persistRoster('merge')
        // đồng bộ state từ server để chắc chắn cấu trúc/field đúng
        await syncRosterFromServer()
        message.success('Đã thêm người duyệt')
    } catch (err) {
        console.error('addMention persist failed', err)
        message.error('Không thể thêm người duyệt — thử lại')
        // rollback đơn giản: xóa item vừa push nếu muốn
        mentionsSelected.value = mentionsSelected.value.filter(m => String(m.user_id) !== String(uid))
    }

    // focus composer
    await nextTick()
    const ta = document.querySelector('.tg-input textarea.ant-input')
    if (ta && typeof ta.focus === 'function') ta.focus()
}


function closeMentionPopover() {
    addMentionOpen.value = false
}

function insertMention(displayName) {
    let v = String(inputValue.value || '')
    v = v.replace(/[ \t]+$/u, '')
    if (/@[^@\s]*$/u.test(v)) {
        v = v.replace(/@[^@\s]*$/u, `@${displayName}`)
    } else {
        if (v && !/\s$/u.test(v)) v += ' '
        v += `@${displayName}`
    }
    inputValue.value = `${v} `
}

function removeMention(uid) {
    if (!canModifyRoster.value) {
        message.warning('Chỉ người tạo task mới được xóa người duyệt')
        return
    }
    mentionsSelected.value = mentionsSelected.value.filter((m) => String(m.user_id) !== String(uid))
    void persistRoster('replace')
}

/* meta helpers */
const metaLabel = (m) => (m.status === 'approved' ? 'đã duyệt' : m.status === 'rejected' ? 'đã từ chối' : 'thêm lúc')
const metaTime = (m) =>
    m.status === 'approved' || m.status === 'rejected'
        ? m.acted_at_vi || formatVi(m.acted_at)
        : m.added_at_vi || formatVi(m.added_at)
const statusDotClass = (status) => (status === 'approved' ? 'ok' : status === 'rejected' ? 'err' : 'proc')


// TÌM NHANH TRONG DRAWER
const drawerSearch = ref('')

// Lọc cuối cùng cho UI (áp dụng search sau filterPendingOnly)
const finalDrawerMentions = computed(() => {
    const arr = drawerMentions.value || []
    const q = vnNorm(drawerSearch.value || '')
    if (!q) return arr
    return arr.filter(m => vnNorm(m.name || '').includes(q))
})

// Khi finalDrawerMentions thay đổi (filter/search), cập nhật dragList
watch(finalDrawerMentions, (v) => {
    dragList.value = Array.isArray(v) ? v.map(x => ({ ...x })) : []
}, { immediate: true, deep: true })

// Counters cho toolbar
const pendingCount = computed(() => finalDrawerMentions.value.filter(m => m.status === 'pending' || m.status === 'processing').length)
const approvedCount = computed(() => finalDrawerMentions.value.filter(m => m.status === 'approved').length)
const rejectedCount = computed(() => finalDrawerMentions.value.filter(m => m.status === 'rejected').length)


/* input mention detect */
function onInputDetectMention(e) {
    const v = String(e?.target?.value ?? '')
    if (v.endsWith('@')) addMentionOpen.value = true
}

/* ===== upload handlers (single file) ===== */
async function handleBeforeUpload(file) {
    // file là instance của File/Blob do AntD truyền vào
    console.log('handleBeforeUpload got file:', file);
    selectedFile.value = file; // LƯU lại để append vào FormData khi submit
    // return false để AntD không tự upload và cho phép you control upload manually
    return false;
}


function handleRemoveFile() {
    selectedFile.value = null
}

/* ===== CRUD inline ===== */
async function handleDeleteComment(commentId) {
    try {
        await deleteComment(commentId)
        if (listComment.value.length === 1 && currentPage.value > 1) await getListComment(currentPage.value - 1)
        else await getListComment(currentPage.value)
        message.success('Đã xóa comment thành công')
    } catch (e) {
        message.error('Không thể xóa comment')
    }
}

/* gửi comment */
const canSend = computed(
    () => !!inputValue.value.trim() || !!selectedFile.value || (mentionsSelected.value?.length > 0)
)

function vnNorm(s = '') {
    return (s == null ? '' : String(s)).normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim()
}

const userNameMap = computed(() => {
    const map = new Map()
    for (const u of listUser.value || []) {
        const key = vnNorm(u.name || '')
        if (key) map.set(key, u)
    }
    return map
})

function extractMentionsFromInput(input = '') {
    const out = []
    if (!input) return out
    const re = /@([^\n\r@]+)/g
    let m
    while ((m = re.exec(input))) {
        const raw = m[1].trim()
        if (!raw) continue
        const cleaned = raw.replace(/[.,;:!?)\]\}]+$/, '').trim()
        const key = vnNorm(cleaned)
        const u = userNameMap.value.get(key)
        if (u) out.push({user_id: String(u.id), name: u.name, role: 'approve', status: 'pending'})
    }
    return out
}

function dedupeMentions(arr = []) {
    const seen = new Set()
    const res = []
    for (const m of arr) {
        const id = String(m.user_id)
        if (seen.has(id)) continue
        seen.add(id)
        res.push(m)
    }
    return res
}

// helper debug
function logFormData(fd) {
    for (const entry of fd.entries()) {
        console.log('FormData:', entry[0], entry[1]);
    }
}

async function createNewComment({ keepMentions = false } = {}) {
    if (!canSend.value) return;

    try {
        // --- Ghép mentions từ UI + text ---
        const textMentions = extractMentionsFromInput(inputValue.value);
        const mergedMentions = dedupeMentions([
            ...(mentionsSelected.value || []),
            ...textMentions
        ]);

        const mentionsPayload = mergedMentions.map(m => ({
            user_id: Number(m.user_id),
            name: m.name,
            role: m.role,
            status: m.status || 'pending'
        }));

        // --- Build FormData ---
        const form = new FormData();
        form.append('user_id', String(store.currentUser.id));
        form.append('content', String(inputValue.value || ''));
        form.append('mentions', JSON.stringify(mentionsPayload));
        // Gửi loại văn bản (nếu có attachment)
        form.append('doc_type', String(selectedDocType.value || 'internal'));

        // Nếu có file local được chọn thì append vào form (AntD beforeUpload trả file)
        if (selectedFile.value) {
            form.append('attachment', selectedFile.value, selectedFile.value.name || 'attachment');
            console.log('Appending attachment:', selectedFile.value.name || selectedFile.value);
        }

        // --- Gửi request tạo comment ---
        const res = await createComment(taskId.value, form);

        // --- Nếu server trả lỗi/validation thì ném để catch bắt ---
        // (giữ flow bình thường; response handled below)

        // --- Thử auto-pin attachments nếu server trả thông tin file ---
        // Lưu ý: cấu trúc response khác nhau giữa backend; thử đoán ở vài chỗ phổ biến
        try {
            const data = res?.data || {};
            // Các nơi có thể chứa attachments/files:
            const attachments =
                data?.attachments ||
                data?.files ||
                data?.comment?.attachments ||
                data?.comment?.files ||
                data?.data?.attachments ||
                data?.data?.files ||
                [];

            if (Array.isArray(attachments) && attachments.length) {
                for (const att of attachments) {
                    try {
                        // att có thể chứa id, file_path, link_url, v.v.
                        await ensureTaskFileId(att, { autoPin: true });
                    } catch (e) {
                        console.warn('Auto-pin per attachment failed for', att, e);
                    }
                }
                // refresh pinned files list after attempts
                await loadPinnedFiles();
            } else {
                // Fallback: server có thể trả về single file info (không trong mảng)
                const maybeFile = data?.file || data?.comment?.file || data?.data?.file || null;
                if (maybeFile) {
                    try {
                        await ensureTaskFileId(maybeFile, { autoPin: true });
                        await loadPinnedFiles();
                    } catch (e) {
                        console.warn('Auto-pin fallback failed', e);
                    }
                } else {
                    // Nếu chúng ta vừa gửi một local File (selectedFile) và backend không trả file info,
                    // thì không thể map local->remote để ghim. Để pin tự động hoạt động trong trường hợp này,
                    // backend cần trả thông tin file đã lưu (id/file_path) trong response createComment.
                    if (selectedFile.value) {
                        console.info('No attachment info returned by server to auto-pin the uploaded file.');
                    }
                }
            }
        } catch (e) {
            console.warn('Auto-pin stage failed', e);
        }

        // --- Reset UI state ---
        inputValue.value = '';
        selectedFile.value = null;
        mentionsSelected.value = keepMentions ? mergedMentions : [];

        // --- Refresh UI data ---
        await getListComment(1);
        await syncRosterFromServer();
        await loadPinnedFiles(); // reload pinned list just in case
        await nextTick();
        scrollToBottom();

        message.success('Đã gửi bình luận');

        return res;
    } catch (err) {
        console.error('createNewComment error', err);
        // Try to show useful server messages when có
        if (err?.response?.data) {
            console.error('Server response:', err.response.data);
            const msg =
                err.response.data?.messages?.attachment ||
                err.response.data?.message ||
                err.response.data?.errors ||
                'Không gửi được bình luận';
            message.error(typeof msg === 'string' ? msg : 'Không gửi được bình luận');
        } else {
            message.error('Không gửi được bình luận');
        }
        throw err; // rethrow in case caller wants to handle further
    }
}


// helper: sắp xếp mảng comment theo created_at tăng dần (cũ -> mới)
function sortCommentsAsc(comments = []) {
    return (comments || []).slice().sort((a, b) => {
        const ta = a?.created_at ? new Date(a.created_at).getTime() : 0
        const tb = b?.created_at ? new Date(b.created_at).getTime() : 0
        return ta - tb
    })
}


/* ===== list (paging) ===== */
async function getListComment(page = 1) {
    loadingComment.value = true
    try {
        const res = await getComments(taskId.value, { page })
        // change here depending on API shape:
        const rawComments = res?.data?.comments ?? []
        // ensure comments are sorted oldest -> newest
        const sorted = sortCommentsAsc(Array.isArray(rawComments) ? rawComments : [])

        const el = listEl.value

        if (page === 1) {
            // page 1: replace whole list and scroll to bottom so newest visible
            listComment.value = sorted
            await nextTick()
            measureFooter()
            scrollToBottom()
        } else {
            // page > 1: assume API returned older messages for this page.
            // We want to prepend older messages to the top and keep scroll position stable.
            const prevScrollHeight = el ? el.scrollHeight : 0

            // prepend older items
            listComment.value = [...sorted, ...(listComment.value || [])]

            await nextTick()
            measureFooter()
            if (el) {
                // keep viewport at the same visual message:
                el.scrollTop = (el.scrollTop || 0) + (el.scrollHeight - prevScrollHeight)
            }
        }

        // update paging info (unchanged)
        totalPage.value = Number(res?.data?.pagination?.totalPages ?? 1)
        currentPage.value = page
    } catch (e) {
        console.error(e)
    } finally {
        loadingComment.value = false
    }
}

// Hàm nhận diện link & chèn HTML có thẻ <a>
function formatMessage(content = '') {
    if (!content) return ''
    const text = String(content)
    // regex nhận link: bắt https:// hoặc www.
    const urlRegex = /(https?:\/\/[^\s]+|www\.[^\s]+)/gi
    return text.replace(urlRegex, (url) => {
        const href = url.startsWith('http') ? url : `https://${url}`
        const host = getHost(href)
        return `
      <a href="${href}" target="_blank" rel="noopener noreferrer" class="msg-link">
        <img src="${faviconOf(href)}" alt="" class="msg-link-favicon"/>
        <span class="msg-link-text">${host}</span>
      </a>
    `
    })
}

function getHost(u = '') {
    try {
        const url = new URL(u)
        return url.host.replace(/^www\./, '')
    } catch {
        return u
    }
}

function faviconOf(u = '') {
    try {
        const host = new URL(u).host
        return `https://icons.duckduckgo.com/ip3/${host}.ico`
    } catch {
        return 'https://icons.duckduckgo.com/ip3/example.com.ico'
    }
}

/* ===== users ===== */
async function getUser() {
    try {
        const {data} = await getUsers()
        listUser.value = Array.isArray(data) ? data : data?.data ?? []
    } catch (e) {
        message.error('Không thể tải người dùng')
    }
}

/* ===== roster sync/persist ===== */
async function persistRoster(mode = 'merge') {
    try {
        const payload = mentionsSelected.value.map((m) => ({
            user_id: Number(m.user_id),
            name: m.name,
            role: m.role,
        }))
        await mergeTaskRosterAPI(taskId.value, payload, mode)
        await syncRosterFromServer()
    } catch (e) {
        console.error('persistRoster error', e)
        message.error('Không thể lưu danh sách người duyệt/ký')
    }
}

async function loadPinnedFiles() {
    try {
        const res = await getPinnedFilesAPI(taskId.value)
        let arr = []
        if (Array.isArray(res.data)) arr = res.data
        else if (Array.isArray(res.data?.pinned_files)) arr = res.data.pinned_files
        else if (Array.isArray(res.data?.files)) arr = res.data.files.filter((x) => Number(x.is_pinned) === 1)
        else {
            const filesRes = await getTaskFilesAPI(taskId.value)
            const filesArr = Array.isArray(filesRes.data)
                ? filesRes.data
                : Array.isArray(filesRes.data?.data)
                    ? filesRes.data.data
                    : []
            arr = filesArr.filter((x) => Number(x.is_pinned) === 1)
        }
        pinnedFiles.value = (arr || []).map((x) => ({
            ...x,
            file_path: x.file_path || x.link_url || '',
            title: x.title || x.file_name || '',
        }))
    } catch (e) {
        console.error('loadPinnedFiles error', e)
        pinnedFiles.value = []
    }
}

async function syncRosterFromServer() {
    try {
        const { data } = await getTaskRosterAPI(taskId.value)
        const roster = data?.roster || data || []

        rosterCreatedBy.value = data?.created_by ?? null
        rosterCreatedByName.value = data?.created_by_name ?? null

        // 👉 thêm 2 dòng này
        rosterProgress.value = data?.progress ?? 0
        rosterAllApproved.value = data?.all_approved ?? false

        mentionsSelected.value = (Array.isArray(roster) ? roster : []).map((r) => ({
            user_id: String(r.user_id),
            name: r.name,
            role: r.role,
            status: r.status || 'processing',
            acted_at: r.acted_at || null,
            acted_at_vi: r.acted_at_vi || null,
            added_at: r.added_at || null,
            added_at_vi: r.added_at_vi || null,
        }))
    } catch (e) {
        console.error('syncRosterFromServer failed', e)
    }
}

/* ===== composer behavior: Enter/Shift+Enter + Esc ===== */
function onComposerKeydown(e) {
    if (e.key === 'Escape' && isEditing.value) {
        e.preventDefault()
        cancelEdit()
        return
    }
    if (e.key !== 'Enter') return
    if (e.shiftKey) return
    e.preventDefault()
    if (canSend.value) void onSubmit()
}

/* ===== inline edit state ===== */
const editingCommentId = ref(null)
const isEditing = computed(() => !!editingCommentId.value)

function startEdit(item) {
    editingCommentId.value = item?.id ?? null
    inputValue.value = String(item?.content ?? '')
    nextTick(() => {
        const ta = document.querySelector('.tg-input textarea.ant-input')
        if (ta && typeof ta.focus === 'function') ta.focus()
    })
}

function cancelEdit() {
    editingCommentId.value = null
    inputValue.value = ''
}

function isPinnable(f) {
    const href = hrefOf(f) // file_path or link_url
    // nếu là blob (local preview) thì href sẽ bắt đầu bằng blob: hoặc rỗng -> không pinnable
    if (!href) return false
    if (String(href).startsWith('blob:')) return false
    return true
}



function canActOnChip(m) {
    // 1️⃣ Không có m hoặc không pending thì không thao tác
    if (!m || (m.status || '').toLowerCase() !== 'pending') return false

    const curUid = String(currentUserId.value)
    const targetUid = String(m.user_id)

    // 2️⃣ Lấy lượt đầu tiên đang chờ duyệt
    const rosterArr = Array.isArray(mentionsSelected.value) ? mentionsSelected.value : []
    const firstPending = rosterArr.find(r => (r.status || '').toLowerCase() === 'pending')

    // 3️⃣ Nếu chính chủ (người của chip)
    if (curUid === targetUid) {
        // chỉ được duyệt khi là người đầu tiên đang chờ
        return !!firstPending && String(firstPending.user_id) === targetUid
    }

    // 4️⃣ Nếu không phải chính chủ → chỉ cho admin/super_admin override
    const myRank = roleRank(currentRoleCode.value)
    if (myRank >= roleRank('admin')) {
        // Lấy thông tin người target (nếu có)
        const targetUser = getUserById(Number(m.user_id)) || {}
        const targetRoleCode = targetUser.role_code || targetUser.role || 'user'
        const targetRank = roleRank(targetRoleCode)

        // admin/super_admin không được duyệt người có cấp cao hơn
        if (targetRank > myRank) return false

        // admin/super_admin được phép duyệt người cùng cấp hoặc thấp hơn
        return true
    }

    // 5️⃣ Còn lại (user thường): không được duyệt chéo, chỉ duyệt lượt của mình
    return false
}



async function handleUpdateCommentInline() {
    if (!editingCommentId.value) return
    const newContent = String(inputValue.value || '').trim()
    if (!newContent) {
        message.warning('Nội dung trống')
        return
    }
    loadingUpdate.value = true
    try {
        await updateComment(editingCommentId.value, {content: newContent})
        editingCommentId.value = null
        inputValue.value = ''
        await getListComment(currentPage.value)
        message.success('Đã cập nhật bình luận')
    } catch (e) {
        message.error('Không thể cập nhật bình luận')
    } finally {
        loadingUpdate.value = false
    }
}

async function onSubmit() {
    if (isEditing.value) return handleUpdateCommentInline()
    return createNewComment()
}

/* ===== misc ===== */
function bustUrl(u, ver) {
    if (!u) return u
    const sep = u.includes('?') ? '&' : '?'
    return `${u}${sep}v=${ver || Date.now()}`
}

function srcWithBustIfImage(f) {
    const u = hrefOf(f)
    return kindOfCommentFile(f) === 'image'
        ? bustUrl(u, f.updated_at || f.acted_at || f.added_at || Date.now())
        : u
}

/* ===== lifecycle ===== */
onMounted(async () => {
    t = setInterval(() => (tick.value = Date.now()), 60_000)
    await getUser()
    await getListComment(1)
    await loadTaskFiles()
    await loadPinnedFiles()
    await syncRosterFromServer()
    measureFooter()
    if ('ResizeObserver' in window) {
        ro = new ResizeObserver(() => measureFooter())
        footerEl.value && ro.observe(footerEl.value)
    }
})
onBeforeUnmount(() => {
    clearInterval(t)
    ro?.disconnect?.()
})
</script>

<style scoped>
:where(.comment) {
    --bg-surface: #fff;
    --bg-subtle: #f0f4f7;
    --bd-soft: #e6ebf1;
    --txt-main: #24292f;
    --txt-muted: #6b7a8c;
    --txt-faint: #8aa0b4;
    --blue-1: #eef6ff;
    --blue-2: #cfe3ff;
    --blue-3: #2a86ff;
    --green-1: #f6ffed;
    --green-2: #b7eb8f;
    --red-1: #fff2f0;
    --red-2: #ffccc7;
}

/* Layout tổng */
.comment {
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 0;
}

/* Sticky header */
.sticky-mentions {
    position: sticky;
    top: 0;
    z-index: 9;
    background: var(--bg-surface);
    border-bottom: 1px solid #eef1f3;
    backdrop-filter: saturate(1.2) blur(0px);
}

.sticky-head {
    display: grid;
    grid-template-columns: 1fr auto;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    padding-left: 0;
    border-bottom: 1px solid #eef1f3;
    background: var(--bg-surface);
}

.pinned-toggle {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 10px;
    border: 1px solid transparent;
    border-radius: 8px;
    background: transparent;
    cursor: pointer;
    line-height: 1;
    transition: background-color .15s ease, border-color .15s ease, box-shadow .15s ease, transform .04s ease;
}

.pinned-toggle:hover:not(:disabled) {
    background: #f6f9ff;
    border-color: #e6efff;
}

.pinned-toggle:focus-visible {
    outline: none;
    box-shadow: 0 0 0 3px rgba(45, 140, 240, .2);
}

.pinned-toggle:disabled {
    cursor: default;
    opacity: .6;
}

.sticky-title {
    font-weight: 600;
    color: #1f2937;
}

.sticky-count {
    color: #64748b;
    font-size: 12px;
}

.arrow {
    font-size: 12px;
    opacity: .9;
    transform: translateY(1px);
}

.sticky-actions {
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.approver-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 0 8px !important;
    height: 28px;
    border-radius: 6px;
}

.approver-btn:hover {
    background: #f6f9ff;
}

.approver-text {
    margin-left: 4px;
}

/* List comments */
.list-comment {
    flex: 1 1 auto;
    min-height: 0;
    overflow: auto;
    padding: 8px 10px 0;
    scrollbar-width: thin;
    scrollbar-color: rgba(0, 0, 0, 0.35) transparent;
}

.list-comment::-webkit-scrollbar {
    width: 6px;
}

.list-comment::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.28);
    border-radius: 8px;
}

/* Bubbles */
.tg-row {
    display: flex;
    gap: 8px;
    margin: 8px 0;
}

.tg-row.me {
    justify-content: flex-end;
}

.tg-row .avatar {
    align-self: flex-end;
}

.bubble {
    max-width: 72%;
    position: relative;
    padding: 8px 10px 6px;
    background: var(--bg-surface);
    border: 1px solid #e6ebf0;
    border-radius: 12px 12px 12px 4px;
    box-shadow: 0 1px 0 rgba(0, 0, 0, 0.03);
}

.bubble.me {
    background: #eaf2ff;
    border-color: #cfe0ff;
    border-radius: 12px 12px 4px 12px;
}

.bubble .actions {
    position: absolute;
    right: 4px;
    top: 4px;
}

.bubble .actions :deep(.ant-btn) {
    padding: 0 6px;
}

.bubble .author {
    font-size: 12px;
    color: var(--txt-muted);
    margin-bottom: 2px;
}

.bubble .text {
    white-space: pre-wrap;
    line-height: 1.38;
    color: var(--txt-main);
}

.bubble .meta {
    font-size: 11px;
    color: var(--txt-faint);
    margin-top: 6px;
    text-align: right;
}

/* Attachments */
.tg-attachments {
    margin-top: 6px;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 8px;
}

.tg-att-item {
    background: #fff;
    border: 1px solid var(--bd-soft);
    border-radius: 10px;
    padding: 6px;
}

.cm-att__thumb {
    width: 100%;
    object-fit: cover;
    border-radius: 6px;
}

.cm-att__icon {
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #fafafa;
    border-radius: 6px;
}

.cm-att__icon-i {
    font-size: 22px;
    opacity: 0.9;
}

.tg-file-link {
    font-size: 13px;
    color: #1677ff;
}

.cm-att__line {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-top: 6px;
    gap: 8px;
}

.pin-btn {
    font-size: 16px;
    cursor: pointer;
    transition: color 0.2s;
}

.pin-btn:hover {
    color: #faad14;
}

/* Footer composer */
.footer-fixed {
    position: sticky;
    bottom: 0;
    z-index: 5;
    background: var(--bg-surface);
    border-top: 1px solid #f0f0f0;
    padding-top: 10px;
    box-shadow: 0 -4px 10px rgba(0, 0, 0, 0.03);
}

.load-more {
    text-align: center;
    margin-bottom: 8px;
}

.tg-footer {
    background: var(--bg-subtle);
    padding: 8px 12px;
}

.tg-composer {
    position: relative;
    display: flex;
    align-items: center;
    gap: 8px;
    background: #fff;
    border: 1px solid #dfe6eb;
    border-radius: 24px;
    padding: 6px 44px;
    box-shadow: 0 1px 0 rgba(0, 0, 0, 0.03);
}

.tg-input {
    flex: 1;
}

.tg-input .ant-input {
    padding: 6px 0 !important;
}

.tg-input textarea.ant-input {
    box-shadow: none !important;
    resize: none;
    background: transparent;
}

.tg-attach-btn, .tg-send-btn {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
}

.tg-attach-btn {
    left: 6px;
    color: #6b7a8c;
}

.tg-send-btn {
    right: 6px;
    width: 32px;
    height: 32px;
    border: none;
    background: #d7e3ff;
    color: #6b7a8c;
}

.tg-send-btn.is-active {
    background: var(--blue-3);
    color: #fff;
}

/* file chip dưới composer */
.tg-file-strip {
    display: flex;
    gap: 6px;
    padding: 6px 4px 0;
    flex-wrap: wrap;
}

.tg-file-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #fff;
    border: 1px solid #e2e8ef;
    border-radius: 16px;
    padding: 4px 8px;
    font-size: 12px;
}

.tg-file-pill .x {
    cursor: pointer;
    margin-left: 4px;
    opacity: 0.7;
}

/* Chips (approver) – dùng trong Drawer */

.chip-card {
    position: relative;
}
.chip-card {
    display: flex;
    align-items: center;
    gap: 8px;
    border: 1px solid var(--bd-soft);
    border-radius: 20px;
    background: var(--green-1);
    padding: 4px 10px;
    font-size: 13px;
    line-height: 1.4;
    transition: box-shadow 0.15s, transform 0.05s;
}

.chip-card:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.chip-card.is-approved {
    background: var(--green-1);
    border-color: var(--green-2);
}

.chip-card.is-pending {
    background: #e6f4ff;
    border-color: #91caff;
}

.chip-card.is-rejected {
    background: var(--red-1);
    border-color: var(--red-2);
}

.chip-line {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 6px;
}

.chip-name {
    font-weight: 600;
    color: #2b2f36;
}

.chip-time {
    color: #777;
    font-size: 12px;
}

.role-dot, .dot {
    display: inline-block;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    transform: translateY(1px);
}

.role-dot.ok, .dot.ok {
    background: #52c41a;
}

.role-dot.proc, .dot.proc {
    background: #1677ff;
}

.role-dot.err, .dot.err {
    background: #ff4d4f;
}

/* đưa nút × ra góc phải trên */
.chip-close {
    position: absolute !important;
    top: 6px;
    right: 8px;
    padding: 0 !important;
    width: 20px;
    height: 20px;
    line-height: 18px;
    text-align: center;
    border-radius: 50%;
    font-size: 14px;
    color: #9ca3af;
    transition: all 0.15s ease;
}

.chip-close:hover {
    background: rgba(0, 0, 0, 0.04);
    color: #111827;
}

.chip-close:active {
    background: rgba(0, 0, 0, 0.1);
}

/* điều chỉnh khoảng padding phần nội dung để không bị nút che */
.chip-body {
    padding-right: 28px;
}

/* Pinned files → pill */
.pinned-files {
    border-radius: 12px;
    margin: 8px 0;
    padding: 0;
}

.pinned-pill {
    margin-right: 5px;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    max-width: 320px;
    padding: 6px 10px;
    border: 1px solid var(--bd-soft);
    background: #fff6cc;
    border-radius: 999px;
    box-shadow: 0 1px 0 rgba(0, 0, 0, 0.03);
    transition: box-shadow 0.16s, transform 0.04s, border-color 0.16s;
}

.pinned-pill:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    border-color: #cfd8e3;
}

.pill-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
    color: #1f75ff;
    min-width: 0;
}

.pill-icon {
    font-size: 14px;
    opacity: 0.9;
}

.pill-text {
    display: inline-block;
    max-width: 200px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    vertical-align: bottom;
}

.pill-x {
    border: 0;
    background: transparent;
    color: #9aa4b2;
    font-size: 14px;
    line-height: 1;
    padding: 0 4px;
    cursor: pointer;
    border-radius: 6px;
}

.pill-x:hover {
    color: #ff4d4f;
    background: #fff1f0;
}

.more-pill {
    border-radius: 999px !important;
    padding: 2px 8px !important;
    border: 1px solid var(--blue-2);
    background: var(--blue-1);
    color: var(--blue-3);
    cursor: pointer;
}

/* ==== Drawer người duyệt – skin hiện đại, nhịp độ thoáng ==== */
.approver-drawer :deep(.ant-drawer-body) {
    padding: 12px 12px 16px;
    background: linear-gradient(180deg, #fbfdff 0%, #ffffff 100%);
}

.drawer-toolbar {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: 10px;
    align-items: center;
    margin-bottom: 10px;
}

.drawer-search :deep(.ant-input-affix-wrapper) {
    border-radius: 10px;
}

.drawer-stats {
    display: inline-flex;
    gap: 10px;
    font-size: 12px;
    color: #6b7280;
}

.drawer-stats .stat b {
    color: #111827;
}

.drawer-stats .stat-pending b {
    color: #2563eb;
}

/* proc */
.drawer-stats .stat-ok b {
    color: #16a34a;
}

/* ok */
.drawer-stats .stat-err b {
    color: #dc2626;
}

/* err */

.drawer-legend {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    font-size: 12px;
    color: #6b7280;
    padding: 8px 10px;
    border: 1px dashed #e5e7eb;
    border-radius: 10px;
    background: #fafcff;
    margin-bottom: 10px;
}

.drawer-legend .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    display: inline-block;
    transform: translateY(1px);
}

.drawer-legend .dot.ok {
    background: #52c41a;
}

.drawer-legend .dot.proc {
    background: #1677ff;
}

.drawer-legend .dot.err {
    background: #ff4d4f;
}

.drawer-legend .sep {
    opacity: .6;
}

.drawer-empty {
    text-align: center;
    color: #6b7280;
    padding: 28px 0 18px;
}

.drawer-empty .empty-icon {
    font-size: 28px;
    margin-bottom: 6px;
}

.drawer-empty .hint {
    font-size: 12px;
    opacity: .8;
}

/* Danh sách + thẻ người duyệt */
.drawer-list {
    display: grid;
    gap: 10px;
}

.drawer-chip .chip-card {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: 10px;
    align-items: center;
    padding: 10px 12px;
    border-radius: 14px;
    border: 1px solid var(--bd-soft);
    background: #ffffff;
    box-shadow: 0 1px 2px rgba(16, 24, 40, 0.03),
    0 0 0 1px rgba(16, 24, 40, 0.02) inset;
    transition: box-shadow .16s ease, transform .04s ease, border-color .16s ease, background .16s ease;
}

.drawer-chip .chip-card:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 14px rgba(17, 24, 39, 0.06);
    border-color: #e6efff;
    background: #f9fbff;
}


.chip-ghost {
    opacity: 0.4;
    background: #f0f0f0;
    border-radius: 8px;
    transform: scale(0.98);
}
.drawer-chip {
    cursor: grab;
    margin-bottom: 15px;
}
/* Card: 2 cột avatar | nội dung */
.drawer-chip .chip-card {
    display: grid;
    grid-template-columns: auto 1fr;
    gap: 10px;
    align-items: start;
}

/* Avatar cột trái */
.chip-avatar { width: 28px; height: 28px; }

/* Thân: 3 hàng */
.chip-body {
    min-width: 0;
    display: grid;
    grid-template-rows: auto auto auto;
    gap: 6px;
}

/* Dòng 1: tên 1 dòng, ellipsis */
.name-row { min-width: 0; }
.chip-name {
    font-weight: 700;
    color: #111827;
    display: inline-block;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Dòng 2: trạng thái + thời gian trên một dòng */
.meta-row {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: #4b5563;
    font-size: 12px;
    min-width: 0;
}
.meta-row .chip-time {
    white-space: nowrap; /* tránh xuống hàng giữa giờ & ngày */
}
.meta-sep { opacity: .55; }

/* Dòng 3: actions cùng một dòng, tự wrap khi thiếu chỗ */
.actions-row {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    flex-wrap: wrap;         /* nếu quá hẹp thì các nút tự xuống hàng */
}

/* Giữ màu dot như trước */
.dot.ok   { background: #52c41a; }
.dot.proc { background: #1677ff; }
.dot.err  { background: #ff4d4f; }

/* Nền theo trạng thái (đã có ở bạn), giữ lại */
.drawer-chip .chip-card.is-approved { background: #f6ffed; border-color: #b7eb8f; }
.drawer-chip .chip-card.is-pending  { background: #eef6ff; border-color: #cfe3ff; }
.drawer-chip .chip-card.is-rejected { background: #fff2f0; border-color: #ffccc7; }

/* ===== Mention Popover ===== */
.mention-pop {
    display: flex;
    flex-direction: column;
    gap: 12px;
    min-width: 280px;
    padding: 14px 16px;
    background: #fff;
    border-radius: 10px;
    font-family: "Inter", "Segoe UI", sans-serif;
}

.mention-pop .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
}

.mention-pop .lbl {
    flex-shrink: 0;
    width: 60px;
    font-size: 13px;
    font-weight: 500;
    color: #444;
    text-align: right;
}

/* Select & Segmented alignment */
.mention-pop .ant-select,
.mention-pop .ant-segmented {
    flex: 1;
}

/* Segmented buttons subtle style */
.mention-pop .ant-segmented {
    background: #f6f7fb;
    border-radius: 8px;
}

.mention-pop .ant-segmented-item-selected {
    background: #1677ff !important;
    color: #fff !important;
    font-weight: 500;
}

/* Footer buttons */
.mention-pop .row:last-child {
    margin-top: 6px;
    justify-content: flex-end;
}

.mention-pop .ant-btn {
    border-radius: 6px;
}

.mention-pop .ant-btn-primary {
    box-shadow: 0 2px 0 rgba(0, 0, 0, 0.04);
}

/* Hover states for clarity */
.mention-pop .ant-btn:hover:not(.ant-btn-primary) {
    background: #f5f5f5;
}
.ant-popover-inner {
    border-radius: 12px !important;
    box-shadow: 0 6px 24px rgba(0, 0, 0, 0.08);
    transition: all 0.2s ease-in-out;
}

.msg-content {
    white-space: pre-wrap;
    word-wrap: break-word;
    line-height: 1.5;
    color: var(--txt-main);
}

/* style link đẹp */
.msg-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    text-decoration: none;
    color: #1677ff;
    font-weight: 500;
    background: #f0f6ff;
    border: 1px solid #cfe3ff;
    border-radius: 999px;
    padding: 2px 8px 2px 4px;
    transition: background-color 0.2s, transform 0.05s;
}

.msg-link:hover {
    background: #e6f0ff;
    transform: translateY(-1px);
}

.msg-link-favicon {
    width: 14px;
    height: 14px;
    border-radius: 3px;
}

.msg-link-text {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 140px;
}
.drawer-toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 8px 12px;
    border-bottom: 1px solid #eef1f3;
    margin-bottom: 8px;
}
.creator-info { color: #374151; font-size: 14px; }
.drawer-stats { color: #6b7280; font-size: 13px; font-weight: 500; }
.approved-tag { color: #16a34a; margin-left: 8px; }




/* Responsive */
@media (max-width: 768px) {
    .bubble {
        max-width: 88%;
    }

    .chip-card {
        max-width: 100%;
    }

    .pill-text {
        max-width: 140px;
    }
}
</style>
