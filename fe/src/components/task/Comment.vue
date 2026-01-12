<template>
    <div class="comment">
        <!-- LIST COMMENT (bubbles) -->
        <div class="list-comment" v-if="listComment" ref="listEl">
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

                        <div class="text">
                            <div class="author" v-if="String(item.user_id) !== String(currentUserId)">
                                {{ getUserById(item.user_id)?.name || 'Không rõ' }}
                            </div>
                            <div class="msg-content" v-html="formatMessage(item.content)"></div>
                        </div>

                        <!-- Attachments trong bubble -->
                        <div v-if="item.files && item.files.length" class="tg-attachments">
                            <a-tooltip
                                v-for="f in item.files"
                                :key="f.id || f.file_path || f.link_url"
                                placement="top"
                            >
                                <template #title>
                                    {{ f.file_name || prettyUrl(hrefOf(f)) }}
                                </template>
                                <div class="tg-att-item">
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

                                    <!-- File name -->
                                    <div class="cm-att__line">
                                        <a class="tg-file-link"
                                           :href="displayHrefOf(f)"
                                           target="_blank"
                                           rel="noopener"
                                        >
                                            {{ f.file_name || prettyUrl(hrefOf(f)) }}
                                        </a>
                                    </div>
                                </div>

                            </a-tooltip>
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
            <a-spin :spinning="uploading" tip="Đang tải lên...">
                <div class="load-more" v-if="currentPage < totalPage && !loadingComment">
                    <a-button size="small" @click="getListComment(currentPage + 1)">Tải thêm</a-button>
                </div>

                <div class="tg-file-strip" v-if="selectedFiles.length">
                    <div
                        v-for="(f, idx) in selectedFiles"
                        :key="idx"
                        class="tg-file-pill"
                    >
                        <PaperClipOutlined/>
                        <span class="name">{{ f.name }}</span>
                        <span class="x" @click.stop.prevent="removeFile(idx)">×</span>
                    </div>
                </div>


                <div class="tg-composer">
                    <!-- Attach -->
                    <a-upload
                        :show-upload-list="false"
                        :multiple="true"
                        :max-count="3"
                        :before-upload="handleBeforeUpload"
                    >
                        <a-button type="text" class="tg-attach-btn" title="Đính kèm">
                            <PaperClipOutlined/>
                        </a-button>
                    </a-upload>

                    <UploadWithUserModal
                        v-model:open="uploadModalOpen"
                        :task-id="Number(route.params.id)"
                        :users="users"
                        :get-department-name="getDepartmentName"
                        mode="create"
                        @confirm="handleApprovalSessionCreated"
                    />

                    <a-textarea
                        v-model:value="inputValue"
                        class="tg-input"
                        :bordered="false"
                        :auto-size="{ minRows: 1, maxRows: 6 }"
                        :placeholder="isEditing ? 'Sửa bình luận… (Enter để lưu, Esc để hủy)' : 'Viết lời nhắn… (Enter để gửi, Shift+Enter để xuống dòng)'"
                        @keydown="onComposerKeydown"
                    />

                    <!-- Nút gửi / lưu -->
                    <a-button
                        class="tg-send-btn"
                        :class="{ 'is-active': canSend }"
                        shape="circle"
                        :disabled="!canSend || uploading"
                        :loading="uploading"
                        @click="onSubmit()"
                    >
                        <template v-if="isEditing">
                            <CheckOutlined/>
                        </template>
                        <template v-else>
                            <SendOutlined/>
                        </template>
                    </a-button>
                </div>

                <!-- Mention pop -->
                <div class="mention-row">
                    <a-modal
                        v-model:open="addMentionOpen"
                        title="Thêm người duyệt"
                        centered
                        :footer="null"
                        width="520px"
                        class="mention-modal"
                        :maskClosable="!rosterAllApproved"
                        :keyboard="!rosterAllApproved"
                    >
                        <div class="mention-body">

                            <!-- Nếu đã duyệt 100% → chỉ hiện thông báo, ẩn mọi input -->
                            <div v-if="rosterAllApproved" class="lock-overlay"
                                 style="padding:14px; text-align:center; font-size:15px; color:#444;">
                                Hồ sơ đã duyệt xong — không thể thêm người duyệt.
                            </div>

                            <!-- Nếu CHƯA duyệt xong → hiển thị giao diện thêm người duyệt -->
                            <template v-else>

                                <!-- Chọn người -->
                                <div class="field">
                                    <label class="field-label">Người duyệt:</label>

                                    <a-select
                                        v-model:value="mentionForm.userId"
                                        show-search
                                        :filterOption="filterUser"
                                        placeholder="Chọn người"
                                        style="width:100%"
                                    >
                                        <a-select-option
                                            v-for="u in sortedUsers"
                                            :key="u.id"
                                            :value="String(u.id)"
                                        >
                                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                                <span>{{ u.name }}</span>

                                                <a-tag
                                                    :color="departmentColors[u.department_id]"
                                                    style="border-radius:6px;"
                                                >
                                                    {{ getDepartmentName(u) }}
                                                </a-tag>
                                            </div>
                                        </a-select-option>
                                    </a-select>
                                </div>

                                <!-- Chọn vai trò nếu user đa nhiệm -->
                                <div v-if="Number(selectedUser?.is_multi_role) === 1">
                                    <a-alert
                                        type="warning"
                                        show-icon
                                        message="Người duyệt kiêm nhiệm"
                                        description="Hãy chọn đúng vai trò để luồng duyệt được phân bổ chính xác."
                                        class="role-alert"
                                    />

                                    <div class="field">
                                        <label class="field-label">Vai trò:</label>

                                        <a-radio-group
                                            v-model:value="mentionForm.role"
                                            class="role-radio-group"
                                        >

                                            <!-- Ban Giám Đốc -->
                                            <a-radio value="vu_thi_thuy_bgd">
                                                Ban Giám đốc
                                                <span class="default-text" style="color:red">(mặc định)</span> –
                                                <a-tooltip title="Phó Giám Đốc">
                                                    <a-tag color="blue">vu_thi_thuy_bgd</a-tag>
                                                </a-tooltip>

                                                <a-button
                                                    class="copy-icon-btn"
                                                    type="text"
                                                    style="padding:0; margin-left:6px;"
                                                    @click="copyTag('vu_thi_thuy_bgd')"
                                                >
                                                    <CopyOutlined/>
                                                </a-button>
                                            </a-radio>

                                            <!-- Kế toán -->
                                            <a-radio value="vu_thi_thuy_kt">
                                                Phòng Kế Toán - Tài Chính –
                                                <a-tooltip title="Trưởng phòng kế toán - tài chính">
                                                    <a-tag color="green">vu_thi_thuy_kt</a-tag>
                                                </a-tooltip>

                                                <a-button
                                                    class="copy-icon-btn"
                                                    type="text"
                                                    style="padding:0; margin-left:6px;"
                                                    @click="copyTag('vu_thi_thuy_kt')"
                                                >
                                                    <CopyOutlined/>
                                                </a-button>
                                            </a-radio>

                                            <!-- Thương mại -->
                                            <a-radio value="vu_thi_thuy_tm">
                                                Phòng Thương Mại –
                                                <a-tooltip title="Trưởng phòng thương mại">
                                                    <a-tag color="orange">vu_thi_thuy_tm</a-tag>
                                                </a-tooltip>

                                                <a-button
                                                    class="copy-icon-btn"
                                                    type="text"
                                                    style="padding:0; margin-left:6px;"
                                                    @click="copyTag('vu_thi_thuy_tm')"
                                                >
                                                    <CopyOutlined/>
                                                </a-button>
                                            </a-radio>

                                        </a-radio-group>
                                    </div>
                                </div>

                                <!-- Nút footer -->
                                <div class="modal-footer">
                                    <a-button @click="addMentionOpen = false">Hủy</a-button>
                                    <a-button type="primary" @click="addMention">Thêm</a-button>
                                </div>

                            </template>
                        </div>
                    </a-modal>
                </div>
            </a-spin>
        </div>

        <!-- Drawer người duyệt -->
        <a-drawer
            v-model:open="openApproverDrawer"
            title="Danh sách người duyệt/ký"
            placement="right"
            width="520"
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
                    <div>
                        Người tạo:
                    </div>
                    <div>
                        <strong>{{ rosterCreatedByName || 'Không rõ' }}</strong>
                        <small v-if="rosterCreatedBy" style="margin-left:8px; color:#6b7280">({{ rosterCreatedBy }})</small>
                    </div>
                </div>

                <!-- tuỳ chọn: nếu bạn có biến progress/all_approved từ API, hiển thị ở đây -->
                <div class="drawer-stats">
                    <span v-if="typeof rosterProgress !== 'undefined'">Tiến độ: {{ rosterProgress }}%</span>
                    <span v-if="typeof rosterAllApproved !== 'undefined' && rosterAllApproved" class="approved-tag">• Đã duyệt xong</span>
                </div>
            </div>

            <!-- NEW: Thông tin lượt upload mới nhất -->
            <div
                v-if="latestBatch && latestFiles && latestFiles.length"
                class="latest-batch-box"
            >
                <div class="lb-header">
                    <div class="lb-title">
                        <strong>Lượt upload #{{ latestBatch }}</strong>
                    </div>
                    <div class="lb-meta">
                        <span class="lb-time">{{ latestBatchMeta?.created_at_vi }}</span>
                    </div>
                </div>

                <div class="lb-file" v-for="f in latestFiles" :key="f.id">
                    <div class="lb-file-icon">
                        <component :is="pickIcon(kindOfCommentFile(f))"/>
                    </div>

                    <div class="lb-file-info">
                        <div class="lb-file-name">
                            <a-tooltip placement="top">
                                <template #title>
                                    {{ f.file_name }}
                                </template>

                                <a
                                    :href="displayHrefOf(f)"
                                    target="_blank"
                                    rel="noopener"
                                    class="lb-file-name-text lb-file-link"
                                >
                                    {{ f.file_name }}
                                </a>
                            </a-tooltip>
                        </div>

                        <div class="lb-file-sub">
                            <span>{{ prettySize(f.file_size) }}</span>
                            <span class="lb-dot">•</span>
                            <span>{{ formatVi(f.created_at) }}</span>
                        </div>
                    </div>
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
                    :item-key="m => `${m.user_id}_${m.department_id}`"
                    handle=".chip-card"
                    ghost-class="chip-ghost"
                    animation="200"
                    :disabled="!canModifyRoster || filterPendingOnly || drawerSearch"
                    @end="handleReorder"
                >
                    <template v-slot:item="{ element: m, index }">
                        <div
                            :key="`${m.user_id}_${m.department_id}_${m.status}`"
                            class="drawer-chip"
                        >
                            <!-- Tooltip hướng dẫn kéo thả; đặt trên chip-card để người dùng thấy khi hover -->
                            <a-tooltip
                                :title="filterPendingOnly || drawerSearch ? 'Tắt bộ lọc hoặc tìm kiếm để sắp xếp lại thứ tự duyệt' : canModifyRoster  ? 'Kéo thả để thay đổi thứ tự duyệt' : 'Chỉ người tạo task mới được sắp xếp thứ tự duyệt'"
                                placement="top"
                            >
                                <div class="chip-card" role="button" tabindex="0" :class="{
                                    'is-approved': m.status === 'approved' && !m.signed,
                                    'is-pending': m.status === 'pending' || m.status === 'processing',
                                    'is-rejected': m.status === 'rejected',
                                    'is-signed': m.signed === true
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
                                        <div class="name-row enhanced-chip-name">
                                            <span class="chip-name">@{{ m.name }}</span>

                                            <!-- TAG PHÒNG BAN — đẹp, nhạt, chuyên nghiệp -->
                                            <a-tag v-if="m.department_id" color="blue">
                                                {{ getDepartmentName(m) }}
                                            </a-tag>
                                            <!-- TAG SIGNATURE CODE — style dạng 'code' -->
                                            <a-tag
                                                v-if="m.signature_code"
                                                color="purple"
                                                class="sig-tag"
                                            >
                                                {{ m.signature_code }}
                                            </a-tag>
                                        </div>


                                        <div class="meta-row">
                                            <span class="dot" :class="statusDotClass(m.status)"></span>
                                            <span class="chip-state">
                                              {{m.status === 'approved' ? 'Đã duyệt' : m.status === 'rejected' ? 'Đã từ chối' : 'Chờ duyệt' }}
                                            </span>
                                            <span class="meta-sep">•</span>
                                            <span class="chip-time">{{ metaTime(m) }}</span>
                                        </div>

                                        <div class="actions-row">
                                            <!-- 1️⃣ Các nút DUYỆT – TỪ CHỐI -->
                                            <template v-if="canActOnChip(m)">
                                                <a-button
                                                    v-if="m.user_id === currentUserId && m.status === 'pending'"
                                                    size="small"
                                                    type="primary"
                                                    :loading="approveLoading[m.user_id]?.[m.department_id]?.approved"
                                                    @click="handleApproveAction(m, 'approved')"
                                                >
                                                    <template #icon><CheckOutlined /></template>
                                                    Đồng ý
                                                </a-button>
                                            </template>
                                            <!-- 4️⃣ Hiển thị “Lượt của ...” -->
                                            <template v-if="!canActOnChip(m) && m.status === 'pending'">
                                                <a-tag color="blue" style="border-radius:12px">
                                                    Lượt của @{{ m.name }}
                                                </a-tag>
                                            </template>

                                            <!-- 5️⃣ Nút X xoá -->
                                            <a-button
                                                v-if="canModifyRoster"
                                                size="small"
                                                type="text"
                                                class="chip-close"
                                                @click="removeMention(m)"
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
import {computed, nextTick, onBeforeUnmount, onMounted, ref, watch} from 'vue'
import _ from "lodash";
import {
    CheckOutlined,
    CopyOutlined,
    FileExcelOutlined,
    FilePdfOutlined,
    FilePptOutlined,
    FileTextOutlined,
    FileWordOutlined,
    LinkOutlined,
    PaperClipOutlined,
    SendOutlined
} from '@ant-design/icons-vue'

import { connectChatChannel, onIncomingComment } from "@/utils/notify-socket";

import {
    createComment,
    getComments,
    mergeTaskRosterAPI,
    updateComment,
} from '@/api/task'
import {
    adoptTaskFileFromPathAPI,
    getPinnedFilesAPI,
    getTaskFilesAPI,
    replaceMarkerInTaskFile,
    uploadTaskFileLinkAPI,
} from '@/api/taskFiles'

import {useRoute} from 'vue-router'
import {useUserStore} from '@/stores/user.js'
import {message} from 'ant-design-vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'
import relativeTime from 'dayjs/plugin/relativeTime'
import BaseAvatar from '@/components/common/BaseAvatar.vue'
import Draggable from 'vuedraggable'
import {addEntityMember} from "@/api/entityMembers.js";
import UploadWithUserModal from '@/components/task/UploadWithUserModal.vue'
import { sendCommentRealtime } from "@/utils/notify-socket";
dayjs.extend(relativeTime)
dayjs.locale('vi')
const store = useUserStore()
const route = useRoute()

const props = defineProps({
    departments: { type: Array, default: () => [] },
    users: { type: Array, default: () => [] },
    roster: { type: Array, default: () => [] }
})
const latestBatch = ref(null)
const latestFiles = ref([])
const latestBatchMeta = ref(null)
const approveLoading = ref({})
const taskId = computed(() => Number(route.params.taskId || route.params.id))
const currentUserId = computed(() => store.currentUser?.id ?? null)
const inputValue = ref('')
const listComment = ref([])
const listUser = ref([])
const selectedFiles = ref([])
const loadingComment = ref(false)
const loadingUpdate = ref(false)
const totalPage = ref(1)
const currentPage = ref(1)
const uploading = ref(false)
/* ===== sticky + scroll helpers ===== */
const listEl = ref(null)
const footerEl = ref(null)
const listPadBottom = ref('96px')
let ro
let t

/* ===== Drawer người duyệt ===== */
const openApproverDrawer = ref(false)
const filterPendingOnly = ref(false)
const mentionsSelected = ref([])
const pinnedFiles = ref([])
const rosterProgress = ref(0)
const rosterAllApproved = ref(false)
const taskFileByPath = ref({})

const dragList = ref([])
const tick = ref(Date.now())
const emit = defineEmits(['approval-session-created'])

/* ===== file kind helpers ===== */
const IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const PDF_EXTS = new Set(['pdf'])
const WORD_EXTS = new Set(['doc', 'docx'])
const EXCEL_EXTS = new Set(['xls', 'xlsx', 'csv'])
const PPT_EXTS = new Set(['ppt', 'pptx'])


const uploadModalOpen = ref(false)

const handleApprovalSessionCreated = (payload) => {
    emit('approval-session-created', payload)
}

const handleReorder = async (evt) => {
    if (!canModifyRoster.value) {
        message.warning('Chỉ người tạo task mới được thay đổi thứ tự người duyệt')
        dragList.value = Array.isArray(finalDrawerMentions.value) ? finalDrawerMentions.value.map(x => ({...x})) : []
        return
    }

    console.log('drag end, new order', dragList.value)
    mentionsSelected.value = dragList.value.map(m => ({...m}))

    try {
        message.success('Đã lưu thứ tự người duyệt')
    } catch (e) {
        console.error('save reorder failed', e)
        message.error('Không lưu được thứ tự')
    }
}

function fromNowVi(dt) {
    tick.value
    const d = dayjs(dt)
    return d.isValid() ? d.fromNow() : ''
}

const getDepartmentName = (m) => {
    const dept = props.departments.find(d => Number(d.id) === Number(m.department_id));
    return dept?.name || '';
};


function formatVi(dt) {
    const d = dayjs(dt)
    return d.isValid() ? d.format('HH:mm DD/MM/YYYY') : ''
}

function measureFooter() {
    const h = footerEl.value?.offsetHeight || 96
    listPadBottom.value = `${h + 8}px`
}

function scrollToBottom() {
    const el = listEl.value
    if (!el) return
    el.scrollTop = el.scrollHeight
}

/* ===== task_files index để map file_path -> task_files.id ===== */
const normalizePath = (u = '') => {
    const s = String(u).split('?')[0]
    return s.replace(/\/+$/, '')
}

const drawerMentions = computed(() => {
    const arr = mentionsSelected.value || []
    return filterPendingOnly.value
        ? arr.filter((m) => m.status === 'pending' || m.status === 'processing')
        : arr
})

const rosterCreatedBy = ref(null)
const rosterCreatedByName = ref(null)
const canModifyRoster = computed(() => {
    if (rosterCreatedBy.value == null) return false
    return String(rosterCreatedBy.value) === String(currentUserId.value)
})

async function ensureTaskFileId(file, {autoPin = false} = {}) {

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
            return Number(created?.id)
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
            return Number(created?.id)
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
const kindOfCommentFile = (f = {}) => detectKind({name: f.file_name, url: hrefOf(f), file_type: f.file_type})

function displayHrefOf(f = {}) {
    return f.file_path || f.link_url || '';
}

/* ===== Roster actions (Drawer) ===== */
async function handleApproveAction(m, status) {

    if (!['approved', 'rejected'].includes(status)) return;

    if (!canActOnChip(m)) {
        message.warning('Bạn không có quyền thực hiện hành động này (chia lượt duyệt)');
        return;
    }

    const uid  = Number(m.user_id);
    const dept = Number(m.department_id);


    try {
        await replaceMarkerInTaskFile(taskId.value, uid, dept);
        message.success("Đã duyệt");
    } catch (e) {
        console.error("handleApproveAction error", e);
        message.error("Xử lý không thành công");
    } finally {

    }
}

async function persistRosterWithPayload(payload) {
    try {
        const mentions = Array.isArray(payload.mentions)
            ? payload.mentions.map(x => ({
                user_id: Number(x.user_id),
                name: x.name,
                role: x.role,
                status: x.status,
                acted_at: x.acted_at || null,
                note: x.note || null,
                department_id: x.department_id ?? null,
                signature_code: x.signature_code ?? null,
            }))
            : [];

        const mode = payload.mode || "merge"; // mặc định merge

        await mergeTaskRosterAPI(taskId.value, mentions, mode);
    } catch (e) {
        console.error("persistRosterWithPayload failed", e);
        throw e;
    }
}


/* users & mentions add/remove */
const getUserById = (id) => listUser.value.find((u) => u.id === id) || {}
const userOptions = computed(() =>
    sortedUsers.value.map(u => ({
        label: u.name,
        value: String(u.id),
    }))
);
const filterUser = (input, option) => (option?.label ?? '').toLowerCase().includes(String(input).toLowerCase())

const selectedUser = computed(() => {
    return listUser.value.find(u => String(u.id) === String(mentionForm.value.userId)) || null;
});

const departmentColors = computed(() => {
    const colors = ["blue", "green", "orange", "purple", "cyan", "magenta", "geekblue", "volcano", "gold", "lime",];

    const map = {};
    let index = 0;

    for (const d of props.departments) {
        map[d.id] = colors[index % colors.length];
        index++;
    }

    return map;
});


const BGD = 6; // ID phòng ban Ban Giám đốc
const sortedUsers = computed(() => {
    return [...props.users].sort((a, b) => {
        // 1) Ban Giám đốc lên đầu
        const aIsBGD = Number(a.department_id) === BGD ? 0 : 1;
        const bIsBGD = Number(b.department_id) === BGD ? 0 : 1;

        if (aIsBGD !== bIsBGD) {
            return aIsBGD - bIsBGD;
        }

        // 2) Nhóm theo phòng ban
        if (Number(a.department_id) !== Number(b.department_id)) {
            return Number(a.department_id) - Number(b.department_id);
        }

        // 3) Sort theo tên trong cùng phòng
        return a.name.localeCompare(b.name, "vi");
    });
});

const multiRoles = {
    vu_thi_thuy_bgd: { department_id: 6, marker_code: "vu_thi_thuy_bgd" },
    vu_thi_thuy_kt:  { department_id: 2, marker_code: "vu_thi_thuy_kt" },
    vu_thi_thuy_tm:  { department_id: 4, marker_code: "vu_thi_thuy_tm" }
};

let addMentionOpen = ref(false)
const mentionForm = ref({
    userId: null,
    role: null
});

const addAccess = async (entityType, entityId, userId) => {
    if (!entityType || !entityId || !userId) return;
    try {
        await addEntityMember({
            entity_type: entityType,
            entity_id: Number(entityId),
            user_id: Number(userId)
        });
        console.log(`✔ Added access: ${entityType}#${entityId} → user ${userId}`);
    } catch (e) {
        console.warn("⚠ Không thể thêm quyền truy cập:", e);
    }
};

const addMention = async () => {
    const uid = mentionForm.value.userId;
    if (!uid) return;
    const user = listUser.value.find(u => String(u.id) === String(uid));
    const displayName = user?.name || `#${uid}`;
    let departmentId = null;
    let signatureCode = null;

    if (Number(user?.is_multi_role) === 1) {

        const roleKey = mentionForm.value.role;         // "bgd" | "kt" | "tm"
        const selected = multiRoles[roleKey];           // LẤY OBJECT TỪ MAP

        if (!selected) {
            message.warning("Vui lòng chọn vai trò/phòng ban duyệt");
            return;
        }

        departmentId = selected.department_id;
        signatureCode = selected.marker_code;

    } else {
        // User 1 vai trò
        departmentId = Number(user?.department_id);
        signatureCode = user?.signature_code ?? null;
    }

    // ======================================================
    // ⭐ CHECK TRÙNG
    // ======================================================
    if (Number(user?.is_multi_role) !== 1) {
        // --- User 1 vai trò → chỉ 1 lần duy nhất ---
        if (mentionsSelected.value.some(m => String(m.user_id) === String(uid))) {
            message.info("Người này đã có trong danh sách");
            insertMention(displayName);
            addMentionOpen.value = false;
            return;
        }
    } else {
        // --- User đa vai trò → cho phép nhiều vai trò ---
        const roleKey = mentionForm.value.role;
        const selected = multiRoles[roleKey];

        // ❗ Nếu FE chưa chọn role (selected = null) → chặn
        if (!selected) {
            message.warning("Vui lòng chọn vai trò/phòng ban duyệt");
            return;
        }

        // Check trùng theo composite key (user_id + department_id)
        const isDup = mentionsSelected.value.some(m =>
            String(m.user_id) === String(uid) &&
            Number(m.department_id) === Number(selected.department_id)
        );

        if (isDup) {
            message.info("Người này đã có trong danh sách với đúng vai trò này");
            insertMention(displayName);
            addMentionOpen.value = false;
            return;
        }

    }


    // ======================================================
    // ⭐ PUSH MENTION
    // ======================================================
    mentionsSelected.value.push({
        user_id: Number(uid),
        name: displayName,
        role: "approve",
        department_id: departmentId,
        signature_code: signatureCode,
        status: "pending",
        added_at: new Date().toISOString().slice(0,19).replace("T"," ")
    });


    insertMention(displayName);
    addMentionOpen.value = false;

    try {
        await persistRoster("merge");
        message.success("Đã thêm người duyệt");

        // ==================================================
        // ⭐ AUTO-GRANT ACCESS
        // ==================================================
        let entityType = null;
        let entityId = null;

        if (route.path.includes("/biddings/")) {
            entityType = "bidding";
            entityId = Number(route.params.bidId || route.params.id);
        } else if (route.path.includes("/contract/")) {
            entityType = "contract";
            entityId = Number(route.params.contractId || route.params.id);
        } else {
            entityType = "internal";
            entityId = Number(taskId.value);
        }

        await addAccess(entityType, entityId, uid);

    } catch (err) {
        console.error("addMention persist failed", err);
        message.error("Không thể thêm người duyệt — thử lại");

        // rollback
        mentionsSelected.value = mentionsSelected.value.filter(
            m => String(m.user_id) !== String(uid)
        );
    }

    await nextTick();
    document.querySelector(".tg-input textarea.ant-input")?.focus?.();
};

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

function removeMention(m) {
    if (!canModifyRoster.value) {
        message.warning('Chỉ người tạo task mới được xóa người duyệt');
        return;
    }

    const uid = Number(m.user_id);
    const dept = Number(m.department_id ?? 0);

    mentionsSelected.value = mentionsSelected.value.filter(item =>
        !(Number(item.user_id) === uid && Number(item.department_id) === dept)
    );

    const payload = {
        mentions: mentionsSelected.value,
        mode: "replace"
    };

    persistRosterWithPayload(payload);
}

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
    dragList.value = Array.isArray(v) ? v.map(x => ({...x})) : []
}, {immediate: true, deep: true})


/* ===== upload handlers (single file) ===== */
async function handleBeforeUpload(file) {
    if (rosterAllApproved.value) {
        message.warning("Hồ sơ đã duyệt xong, không thể upload thêm tài liệu.");
        return false; // CHẶN LUÔN
    }

    if (selectedFiles.value.length >= 3) {
        message.warning("Chỉ được đính kèm tối đa 3 file");
        return false;
    }

    selectedFiles.value.push(file);
    return false;
}


function removeFile(index) {
    selectedFiles.value.splice(index, 1);
}

/* gửi comment */
const canSend = computed(() => {
    return (
        !!inputValue.value.trim() ||
        selectedFiles.value.length > 0 ||
        (mentionsSelected.value?.length > 0)
    );
});

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

const copyTag = async (text) => {
    if (navigator && navigator.clipboard && navigator.clipboard.writeText) {
        try {
            await navigator.clipboard.writeText(text);
            message.success(`Đã copy: ${text}`);
            return;
        } catch (e) {
            console.warn('Clipboard API lỗi, fallback execCommand', e);
        }
    }

    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.setAttribute('readonly', '');
    textarea.style.position = 'absolute';
    textarea.style.left = '-9999px';
    document.body.appendChild(textarea);
    textarea.select();

    try {
        const ok = document.execCommand('copy');
        if (ok) {
            message.success(`Đã copy: ${text}`);
        } else {
            message.error('Copy thất bại (execCommand)');
        }
    } catch (e) {
        console.error(e);
        message.error('Copy thất bại');
    } finally {
        document.body.removeChild(textarea);
    }
};

function extractMentionsFromInput(input = '') {
    const out = []
    if (!input) return out
    const re = /@([^\n\r@]+)/g
    let m
    while ((m = re.exec(input))) {
        const raw = m[1].trim()
        if (!raw) continue
        const cleaned = raw.replace(/[.,;:!?)\]}]+$/, '').trim()
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

import { useTaskUsersStore } from "@/stores/taskUsersStore";
const taskUsers = useTaskUsersStore();

const receiversArray = computed(() => taskUsers.users);

async function createNewComment({ keepMentions = false } = {}) {

    const hasFiles = selectedFiles.value.length > 0;
    if (!canSend.value || (hasFiles && uploading.value)) return;

    if (hasFiles) uploading.value = true;

    try {
        const textMentions = extractMentionsFromInput(inputValue.value);
        const mergedMentions = dedupeMentions([
            ...(mentionsSelected.value || []),
            ...textMentions,
        ]);

        const mentionsPayload = mergedMentions.map(m => ({
            user_id: Number(m.user_id),
            name: m.name,
            role: m.role,
            status: m.status || "pending",
        }));

        const form = new FormData();
        form.append("user_id", store.currentUser.id);
        form.append("content", inputValue.value || "");
        form.append("mentions", JSON.stringify(mentionsPayload));

        // ================================
        // 1️⃣ VALIDATE FILE (nếu có)
        // ================================
        if (hasFiles) {

            if (rosterAllApproved.value) {
                message.warning("Hồ sơ đã duyệt xong — không thể đính kèm file.");
                uploading.value = false;
                return;
            }

            for (const f of selectedFiles.value) {
                const ext = f.name.split(".").pop().toLowerCase();
                if (ext === "pdf") {
                    uploading.value = false;
                    message.error("Không được phép upload file PDF.");
                    return;
                }
            }

            for (const f of selectedFiles.value) {
                form.append("attachments[]", f, f.name);
            }
        }

        // ==================================
        // 2️⃣ THÊM COMMENT TẠM VÀO UI
        // ==================================
        const tempId = "tmp-" + Date.now();

        listComment.value.push({
            id: tempId,
            user_id: store.currentUser.id,
            content: inputValue.value,
            user_name: store.currentUser.name,
            created_at: new Date().toISOString(),
            files: [] // file có thể load lại sau
        });

        await nextTick(() => scrollToBottom());


        // ==================================
        // 3️⃣ GỌI API LƯU COMMENT
        // ==================================
        const res = await createComment(taskId.value, form);

        const created = res?.data?.comment || res.data?.data;

        sendCommentRealtime({
            event: "task:new_comment",
            users: receiversArray.value,
            task_id: taskId.value,
            author_id: store.currentUser.id,
            author_name: store.currentUser.name,
            content: inputValue.value,
            comment_id: created?.id ?? null,
            created_at: new Date().toISOString(),
        });



        inputValue.value = "";
        selectedFiles.value = [];
        mentionsSelected.value = keepMentions ? mergedMentions : [];

        // ==================================
        // 5️⃣ Reload comment để sync DB (optional)
        // ==================================
        await getListComment(1);

        // ==================================
        // 6️⃣ CHỈ báo success nếu có file
        // ==================================
        if (hasFiles) {
            message.success("Đã gửi bình luận");
        }

        return res;

    } catch (err) {
        console.error("createNewComment error", err);

        const msg =
            err?.response?.data?.messages?.attachment ||
            err?.response?.data?.message ||
            err?.response?.data?.errors ||
            "Không gửi được bình luận";

        message.error(typeof msg === "string" ? msg : "Không gửi được bình luận");

        throw err;

    } finally {
        if (hasFiles) uploading.value = false;
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
        const res = await getComments(taskId.value, {page})
        const rawComments = res?.data?.comments ?? []
        const sorted = sortCommentsAsc(Array.isArray(rawComments) ? rawComments : [])

        const el = listEl.value

        if (page === 1) {
            listComment.value = sorted
            await nextTick()
            measureFooter()
            scrollToBottom()
        } else {
            const prevScrollHeight = el ? el.scrollHeight : 0
            listComment.value = [...sorted, ...(listComment.value || [])]

            await nextTick()
            measureFooter()
            if (el) {
                el.scrollTop = (el.scrollTop || 0) + (el.scrollHeight - prevScrollHeight)
            }
        }
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

async function persistRoster(mode = 'merge') {
    try {
        const payload = mentionsSelected.value.map((m) => ({
            user_id: Number(m.user_id),
            name: m.name,
            role: m.role,
            department_id: m.department_id ?? null,   // ⭐ THÊM DÒNG NÀY
            signature_code: m.signature_code ?? null,   // ⭐ THÊM DÒNG NÀY
            status: m.status ?? 'pending',
        }))

        await mergeTaskRosterAPI(taskId.value, payload, mode)
        // await syncRosterFromServer()

    } catch (e) {
        console.error('persistRoster error', e)
        message.error('Không thể lưu danh sách người duyệt/ký')
    }
}

function prettySize(bytes) {
    if (!bytes) return '0 KB'
    const kb = bytes / 1024
    if (kb < 1024) return kb.toFixed(1) + ' KB'
    return (kb / 1024).toFixed(1) + ' MB'
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

function cancelEdit() {
    editingCommentId.value = null
    inputValue.value = ''
}

const normalizePositionCode = (code) => (code || '').toLowerCase()


function canActOnChip(m) {
    if (!m || (m.status || '').toLowerCase() !== 'pending') return false;

    const curUid  = String(currentUserId.value);
    const targetUid = String(m.user_id);

    const rosterArr = mentionsSelected.value || [];

    const curPos = normalizePositionCode(getUserById(currentUserId.value)?.position_code);
    const chipPos = normalizePositionCode(getUserById(m.user_id)?.position_code);

    /* ================================================
       1️⃣ EXECUTIVE — Giám đốc
       Không được ký trước executive phía trên
    ================================================= */
    if (curPos === 'executive') {

        const executives = rosterArr.filter(r =>
            normalizePositionCode(getUserById(r.user_id)?.position_code) === 'executive'
        );

        const iCur  = executives.findIndex(r => String(r.user_id) === curUid);
        const iChip = executives.findIndex(r => String(r.user_id) === targetUid);

        // Nếu tôi & chip đều là executive
        if (iChip >= 0 && iCur >= 0) {

            if (iCur > 0) {
                const previous = executives[iCur - 1];
                if ((previous.status || '').toLowerCase() !== 'approved') return false;
            }

            return iCur === iChip;
        }

        // executive có thể duyệt tất cả cấp dưới
        return true;
    }

    /* ================================================
       2️⃣ SENIOR MANAGER — Phó giám đốc
       Không được vượt executive & không vượt senior_manager đứng trước
    ================================================= */
    if (curPos === 'senior_manager') {

        // Nếu chip là executive → KO ĐƯỢC KÝ
        if (chipPos === 'executive') return false;

        // Lấy danh sách senior_manager theo thứ tự
        const seniors = rosterArr.filter(r =>
            normalizePositionCode(getUserById(r.user_id)?.position_code) === 'senior_manager'
        );

        const iCur  = seniors.findIndex(r => String(r.user_id) === curUid);
        const iChip = seniors.findIndex(r => String(r.user_id) === targetUid);

        if (iChip >= 0 && iCur >= 0) {
            if (iCur > 0) {
                const previous = seniors[iCur - 1];
                if ((previous.status || '').toLowerCase() !== 'approved') return false;
            }

            return iCur === iChip;
        }

        // Phó giám đốc có thể duyệt cấp dưới
        return true;
    }

    /* ================================================
       3️⃣ MANAGER — Trưởng phòng
       Giống admin cũ, không được vượt manager phía trên
    ================================================= */
    if (curPos === 'manager') {

        // Không được ký trước executive hoặc senior_manager
        if (['executive', 'senior_manager'].includes(chipPos)) return false;

        const managers = rosterArr.filter(r =>
            normalizePositionCode(getUserById(r.user_id)?.position_code) === 'manager'
        );

        const iCur  = managers.findIndex(r => String(r.user_id) === curUid);
        const iChip = managers.findIndex(r => String(r.user_id) === targetUid);

        if (iChip >= 0 && iCur >= 0) {
            if (iCur > 0) {
                const previous = managers[iCur - 1];
                if ((previous.status || '').toLowerCase() !== 'approved') return false;
            }

            return iCur === iChip;
        }

        // Manager chỉ được duyệt staff
        return chipPos === 'staff';
    }

    /* ================================================
       4️⃣ STAFF — Nhân viên
       Chỉ ký được chính mình, và phải là pending đầu tiên
    ================================================= */
    const firstPending = rosterArr.find(r => (r.status || '').toLowerCase() === 'pending');

    return firstPending && String(firstPending.user_id) === curUid;
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
    await getListComment(1)
    await loadTaskFiles()
    measureFooter()

    // Kết nối socket theo user hiện tại
    connectChatChannel(store.currentUser.id);

    onIncomingComment((payload) => {
        if (
            payload.event === "task:new_comment" &&
            Number(payload.task_id) === Number(taskId.value) &&
            Number(payload.author_id) !== Number(store.currentUser.id)
        ) {
            listComment.value.push({
                id: payload.comment_id,
                user_id: payload.author_id,
                content: payload.content,
                user_name: payload.author_name,
                created_at: payload.created_at,
                files: []
            });

            nextTick(() => scrollToBottom());
        }
    });


    if ('ResizeObserver' in window) {
        ro = new ResizeObserver(() => measureFooter())
        footerEl.value && ro.observe(footerEl.value)
    }
})
watch(
    () => props.users,
    (val) => {
        listUser.value = Array.isArray(val) ? val : []
    },
    { immediate: true }
)

const localRoster = ref([])

// đồng bộ khi prop thay đổi
watch(
    () => props.roster,
    (v) => {
        localRoster.value = (v || []).map(r => ({
            ...r,
            department_id: r.department_id ?? r.dept_id ?? null,   // ⭐ GẮN ĐÚNG
            signature_code: r.signature_code ?? null,
        }))
    },
    { immediate: true }
)
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
/* List comments */
.list-comment {
    height: 60vh;
    flex: 1 1 auto;
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
    font-size: 40px;
    opacity: 0.9;
}

.tg-file-link {
    font-size: 13px;
    color: #1677ff;

}

.tg-file-link {
    max-width: 240px;
}

.tg-file-link {
    display: inline-block;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    vertical-align: bottom;
}

.cm-att__line {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-top: 6px;
    gap: 8px;
}

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
    padding-left: 0;
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
    margin-bottom: 10px;
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


/* Card: 2 cột avatar | nội dung */
.drawer-chip .chip-card {
    display: grid;
    grid-template-columns: auto 1fr;
    gap: 10px;
    align-items: start;
}

/* Avatar cột trái */
.chip-avatar {
    width: 28px;
    height: 28px;
}

/* Thân: 3 hàng */
.chip-body {
    min-width: 0;
    display: grid;
    grid-template-rows: auto auto auto;
    gap: 6px;
}

/* Dòng 1: tên 1 dòng, ellipsis */
.name-row {
    min-width: 0;
}

.chip-name {
    font-weight: 700;
    color: #111827;
    display: inline-block;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.meta-row {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: #4b5563;
    font-size: 12px;
    min-width: 0;
}

.meta-row .chip-time {
    white-space: nowrap;
}

.meta-sep {
    opacity: .55;
}

.actions-row {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    flex-wrap: wrap;
}


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

