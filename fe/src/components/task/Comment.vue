<template>
    <div class="comment">
        <!-- STICKY: người duyệt/ký + file ghim -->
        <div class="mention-chips sticky-mentions" v-if="(pinnedFiles && pinnedFiles.length) || (mentionsSelected && mentionsSelected.length)">
            <!-- Header -->
            <div class="sticky-head">
                <div class="sticky-left">
                    <span class="sticky-title">Tài liệu & người duyệt</span>
                    <span v-if="hiddenPinnedCount>0 || hiddenMentionsCount>0" class="sticky-more">
                        (còn {{ hiddenPinnedCount + hiddenMentionsCount }} mục)
                    </span>
                </div>
                <div class="sticky-actions">
                    <a-tooltip :title="isStickyExpanded ? 'Thu gọn' : 'Hiện tất cả'">
                        <a-button type="text" size="small" @click="toggleSticky()">
                            <template #icon>
                                <template v-if="!isStickyExpanded">
                                    <PlusOutlined/>
                                </template>
                                <template v-else>
                                    <MinusOutlined/>
                                </template>
                            </template>
                            {{ isStickyExpanded ? 'Thu gọn' : 'Hiện tất cả' }}
                        </a-button>
                    </a-tooltip>
                </div>
            </div>

            <!-- Pinned files -->
            <div v-if="visiblePinnedFiles.length" class="pinned-files">
                <div class="pinned-line">
                    <div
                        v-for="f in visiblePinnedFiles"
                        :key="f.id || f.file_path"
                        class="pinned-pill"
                    >
                        <a :href="hrefOf(f)" target="_blank" rel="noopener" class="pill-link">
                            <PaperClipOutlined class="pill-icon" />
                            <span class="pill-text">{{ titleOf(f) }}</span>
                        </a>
                        <a-tooltip title="Bỏ ghim">
                            <button class="pill-x" type="button" @click="togglePin(f)">×</button>
                        </a-tooltip>
                    </div>

                    <!-- +N file -->
                    <a-tag
                        v-if="!isStickyExpanded && hiddenPinnedCount>0"
                        color="blue"
                        class="more-pill more-pill--file"
                        @click="expandSticky"
                    >
                        +{{ hiddenPinnedCount }} file
                    </a-tag>
                </div>
            </div>


            <!-- Approver/sign chips -->
            <a-space wrap style="margin-bottom:8px;">
                <a-popover
                    v-for="m in visibleMentions"
                    :key="`${m.user_id}-${m.status}-${m.acted_at || ''}-${m.added_at || ''}`"
                    trigger="click"
                    placement="top"
                    v-model:open="mentionPopoverOpen[m.user_id]"
                    :getPopupContainer="(t)=>t.parentNode"
                >
                    <template #content>
                        <div class="approve-pop">
                            <div class="pop-head">
                                <div class="role-pill">
                                    <span class="dot" :class="statusDotClass(m.status)"></span>
                                    {{ m.role === 'sign' ? 'Người ký' : 'Người duyệt' }}
                                </div>
                                <div class="pop-time" v-if="metaTime(m)">
                                    {{ metaLabel(m) }}: <b>{{ metaTime(m) }}</b>
                                </div>
                            </div>
                            <div class="actions">
                                <a-button type="primary" size="small" @click="handleApproveAction(m,'approved')">
                                    <template #icon>
                                        <CheckOutlined/>
                                    </template>
                                    Đồng ý
                                </a-button>
                                <a-button danger size="small" @click="handleApproveAction(m,'rejected')">
                                    <template #icon>
                                        <CloseOutlined/>
                                    </template>
                                    Từ chối
                                </a-button>
                            </div>
                        </div>
                    </template>

                    <div class="chip-card" :key="`${m.user_id}-${m.status}-${m.acted_at || ''}-${m.added_at || ''}`"
                        :class="{
              'is-approved': m.status==='approved',
              'is-pending' : m.status==='pending' || m.status==='processing',
              'is-rejected': m.status==='rejected'
            }"
                    >
                        <div class="chip-line">
                            <span class="chip-name">@{{ m.name }}</span>
                            <span class="role-dot" :class="statusDotClass(m.status)"></span>
                            <span class="chip-state">
      {{
                                    m.status === 'approved'
                                        ? 'Đã duyệt'
                                        : m.status === 'rejected'
                                            ? 'Đã từ chối'
                                            : 'Chờ duyệt'
                                }}
    </span>
                            <span class="chip-time">{{ metaTime(m) }}</span>
                            <a-button type="text" size="small" class="chip-close" @click.stop="removeMention(m.user_id)">×</a-button>
                        </div>
                    </div>
                </a-popover>

                <!-- +N người -->
                <a-tag
                    v-if="!isStickyExpanded && hiddenMentionsCount>0"
                    color="processing"
                    class="more-pill"
                    @click="expandSticky"
                >
                    +{{ hiddenMentionsCount }} người
                </a-tag>
            </a-space>
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
                        <div class="actions" v-if="canEditOrDelete(item)">
                            <a-dropdown trigger="click" :getPopupContainer="t => t.parentNode">
                                <a-button type="text" size="small">
                                    <EllipsisOutlined/>
                                </a-button>
                                <template #overlay>
                                    <a-menu>
                                        <a-menu-item @click="showUpdateCommentModal(item)">Sửa</a-menu-item>
                                        <a-menu-item>
                                            <a-popconfirm
                                                title="Bạn chắc chắn muốn xóa comment này?"
                                                ok-text="Xóa"
                                                cancel-text="Hủy"
                                                @confirm="handleDeleteComment(item.id)"
                                                placement="topRight"
                                            >Xóa
                                            </a-popconfirm>
                                        </a-menu-item>
                                    </a-menu>
                                </template>
                            </a-dropdown>
                        </div>

                        <div class="text">
                            <div class="author" v-if="String(item.user_id) !== String(currentUserId)">
                                {{ getUserById(item.user_id)?.name || 'Không rõ' }}
                            </div>
                            {{ item.content }}
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
                                    <a class="tg-file-link"
                                        :href="hrefOf(f)"
                                        target="_blank"
                                        rel="noopener"
                                        :title="f.file_name || prettyUrl(hrefOf(f))"
                                    >
                                        {{ f.file_name || prettyUrl(hrefOf(f)) }}
                                    </a>

                                    <!-- 📌 Pin -->
                                    <a-tooltip :title="isPinned(f) ? 'Bỏ ghim file này' : 'Ghim file lên trên'">
                                        <PushpinOutlined
                                            class="pin-btn"
                                            :style="{ color: isPinned(f) ? '#faad14' : '#999' }"
                                            @click="togglePin(f)"
                                        />
                                    </a-tooltip>
                                </div>
                            </div>
                        </div>

                        <div class="meta">
                            <a-tooltip :title="formatVi(item.created_at)">
                                {{ fromNowVi(item.created_at) }}
                            </a-tooltip>
                        </div>
                    </div>
                </div>

                <!-- Divider mềm giữa các block (nếu muốn) -->
                <!-- <a-divider v-if="index !== listComment.length - 1" /> -->
            </a-spin>
        </div>

        <!-- FOOTER: composer (Telegram-like) -->
        <div class="footer-fixed tg-footer" ref="footerEl">
            <div class="load-more" v-if="currentPage < totalPage && !loadingComment">
                <a-button size="small" @click="getListComment(currentPage + 1)">Tải thêm</a-button>
            </div>

            <div class="tg-composer">
                <!-- Attach (trái) -->
                <a-upload
                    :show-upload-list="false"
                    :multiple="false"
                    :max-count="1"
                    :before-upload="handleBeforeUpload"
                >
                    <a-button type="text" class="tg-attach-btn" :title="'Đính kèm'">
                        <PaperClipOutlined/>
                    </a-button>
                </a-upload>

                <!-- Ô nhập dạng textarea borderless -->
                <a-textarea
                    v-model:value="inputValue"
                    class="tg-input"
                    :bordered="false"
                    :auto-size="{ minRows: 1, maxRows: 6 }"
                    placeholder="Viết lời nhắn… (Enter để gửi, Shift+Enter để xuống dòng, gõ @ để thêm người duyệt)"
                    @keydown="onComposerKeydown"
                    @input="onInputDetectMention"
                />

                <!-- Nút gửi -->
                <a-button
                    class="tg-send-btn"
                    :class="{ 'is-active': canSend }"
                    shape="circle"
                    :disabled="!canSend"
                    @click="createNewComment()"
                    :title="'Gửi'"
                >
                    <SendOutlined/>
                </a-button>
            </div>

            <!-- file chip preview -->
            <div class="tg-file-strip" v-if="selectedFile">
                <div class="tg-file-pill">
                    <PaperClipOutlined/>
                    <span class="name">{{ selectedFile.name }}</span>
                    <span class="x" @click="handleRemoveFile()">×</span>
                </div>
            </div>

            <!-- Mention pop -->
            <div class="mention-row">
                <a-popover
                    trigger="click"
                    v-model:open="mentionPopupOpen"
                    placement="topLeft"
                    :getPopupContainer="(t)=>t.parentNode"
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
                                    style="min-width:220px;"
                                    placeholder="Chọn người"
                                />
                            </div>
                            <div class="row">
                                <span class="lbl">Vai trò:</span>
                                <!-- Giữ đúng logic hiện tại: chỉ 'approve' -->
                                <a-segmented v-model:value="mentionForm.role"
                                             :options="[{ label: 'Duyệt', value: 'approve' }]"/>
                            </div>
                            <div class="row" style="justify-content:flex-end; gap:8px;">
                                <a-button size="small" @click="resetMentionForm">Hủy</a-button>
                                <a-button size="small" type="primary" @click="addMention">Thêm</a-button>
                            </div>
                        </div>
                    </template>

                    <!--                    <a-button size="small" @click="mentionPopupOpen = true">+ Thêm người duyệt</a-button>-->
                </a-popover>
            </div>
        </div>

        <!-- Modal sửa comment -->
        <a-modal
            v-model:open="openModalEditComment"
            title="Chỉnh sửa thông tin bình luận"
            okText="Lưu"
            cancelText="Hủy"
            @ok="handleUpdateComment"
            :confirm-loading="loadingUpdate"
        >
            <a-form layout="vertical">
                <a-form-item label="Nội dung bình luận">
                    <a-input v-model:value="selectedComment.content"/>
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup>
import {ref, computed, nextTick, onMounted, onBeforeUnmount} from 'vue'
import {
    CheckOutlined, CloseOutlined, EllipsisOutlined,
    FileExcelOutlined, FilePdfOutlined, FilePptOutlined, FileTextOutlined, FileWordOutlined,
    LinkOutlined, PaperClipOutlined, PushpinOutlined,
    PlusOutlined, MinusOutlined, SendOutlined
} from '@ant-design/icons-vue'

import {
    approveRosterAPI, createComment, deleteComment, getComments,
    getTaskRosterAPI, mergeTaskRosterAPI, rejectRosterAPI, updateComment
} from '@/api/task'

import {
    adoptTaskFileFromPathAPI, getPinnedFilesAPI, getTaskFilesAPI,
    pinTaskFileAPI, unpinTaskFileAPI, uploadTaskFileLinkAPI
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

/* ===== time helpers (VI) ===== */
const tick = ref(Date.now())
let t

function fromNowVi(dt) {
    tick.value;
    const d = dayjs(dt);
    return d.isValid() ? d.fromNow() : ''
}

function formatVi(dt) {
    const d = dayjs(dt);
    return d.isValid() ? d.format('HH:mm DD/MM/YYYY') : ''
}

/* ===== state ===== */
const store = useUserStore()
const route = useRoute()

const taskId = computed(() => Number(route.params.taskId || route.params.id))
const currentUserId = computed(() => store.currentUser?.id ?? null)
const canEditOrDelete = (item) => String(item.user_id) === String(currentUserId.value) || !!store.currentUser?.is_admin

const inputValue = ref('')
const listComment = ref([])
const listUser = ref([])

const selectedFile = ref(null)

const loadingComment = ref(false)
const loadingUpdate = ref(false)
const openModalEditComment = ref(false)
const selectedComment = ref({})

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

function scrollToBottom() {
    const el = listEl.value
    if (!el) return
    el.scrollTop = el.scrollHeight
}

/* ===== task_files index để map file_path -> task_files.id ===== */
const taskFileByPath = ref({})
const normalizePath = (u = '') => String(u).split('?')[0]

/* ===== sticky expand/collapse ===== */
const isStickyExpanded = ref(false)
const MAX_FILES_COLLAPSED = 1
const MAX_MENTIONS_COLLAPSED = 1
const toggleSticky = () => {
    isStickyExpanded.value = !isStickyExpanded.value
}
const expandSticky = () => {
    isStickyExpanded.value = true
}

const pinnedFiles = ref([])
const visiblePinnedFiles = computed(() => isStickyExpanded.value ? (pinnedFiles.value || []) : (pinnedFiles.value || []).slice(0, MAX_FILES_COLLAPSED))
const hiddenPinnedCount = computed(() => Math.max(0, (pinnedFiles.value?.length || 0) - MAX_FILES_COLLAPSED))

/* ===== mentions ===== */
const mentionsSelected = ref([])
const visibleMentions = computed(() => isStickyExpanded.value ? (mentionsSelected.value || []) : (mentionsSelected.value || []).slice(0, MAX_MENTIONS_COLLAPSED))
const hiddenMentionsCount = computed(() => Math.max(0, (mentionsSelected.value?.length || 0) - MAX_MENTIONS_COLLAPSED))

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

async function ensureTaskFileId(file) {
    const existed = getTaskFileId(file)
    if (existed) return existed

    const path = String(file.file_path ?? file.url ?? '')
    const name = file.file_name || file.name || prettyUrl(path)

    if (/^https?:\/\//i.test(path)) {
        try {
            const {data} = await uploadTaskFileLinkAPI(taskId.value, {
                title: name, url: path, user_id: Number(store.currentUser.id),
            })
            const created = Array.isArray(data) ? data[0] : data?.data || data
            const key = normalizePath(created?.file_path || created?.link_url || path)
            taskFileByPath.value[key] = {...(created || {}), file_path: created?.file_path || created?.link_url || path}
            return Number(created?.id)
        } catch (e) {
            console.error('uploadTaskFileLinkAPI error', e?.response?.data || e)
            message.error('Không tạo được tài liệu từ link để ghim')
            return null
        }
    }

    try {
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
    } catch (e) {
        console.error('adoptTaskFileFromPathAPI error', e?.response?.data || e)
        message.error('Không tạo được tài liệu từ file nội bộ để ghim')
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

async function togglePin(file) {
    const tfId = await ensureTaskFileId(file)
    if (!tfId) return
    try {
        const already = isPinned({...file, task_file_id: tfId})
        if (already) {
            await unpinTaskFileAPI(tfId, {user_id: store.currentUser.id})
        } else {
            if ((pinnedFiles.value?.length || 0) >= 2) {
                message.warning('Chỉ được ghim tối đa 2 file')
                return
            }
            await pinTaskFileAPI(tfId, {user_id: store.currentUser.id})
        }
        await loadPinnedFiles()
        message.success(already ? 'Đã bỏ ghim' : 'Đã ghim')
    } catch (e) {
        console.error('pin/unpin error', e?.response?.data || e)
        message.error('Không thao tác được ghim/bỏ ghim')
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
    const e = extOf(o.name || o.url || '')
    const t = o.file_type || ''
    if (String(t).startsWith('image/')) return 'image'
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

/* ===== Approve popover & roster actions ===== */
const mentionPopoverOpen = ref({})

async function handleApproveAction(m, status) {
    try {
        if (status === 'approved') await approveRosterAPI(taskId.value, {note: null})
        else await rejectRosterAPI(taskId.value, {note: null})
        mentionPopoverOpen.value[m.user_id] = false
        await syncRosterFromServer()
        message.success(
            status === 'approved' ? `${m.name} đã ${m.role === 'sign' ? 'ký' : 'duyệt'}` : `${m.name} đã từ chối`
        )
    } catch (e) {
        console.error(e)
        message.error('Xử lý không thành công')
    }
}

/* users & mentions add/remove */
const getUserById = (id) => listUser.value.find((u) => u.id === id) || {}
const userOptions = computed(() => (listUser.value || []).map((u) => ({value: String(u.id), label: u.name})))
const filterUser = (input, option) => (option?.label ?? '').toLowerCase().includes(String(input).toLowerCase())

const mentionPopupOpen = ref(false)
const mentionForm = ref({userId: null, role: 'approve'})

function resetMentionForm() {
    mentionForm.value.userId = null
    mentionForm.value.role = 'approve'
    mentionPopupOpen.value = false
}

const addMention = async () => {
    const uid = mentionForm.value.userId
    if (!uid) return
    if (mentionsSelected.value.some((m) => String(m.user_id) === String(uid))) {
        message.info('Người này đã có trong danh sách')
        return
    }
    const user = listUser.value.find((u) => String(u.id) === String(uid))
    const displayName = user?.name || `#${uid}`
    const newMention = {user_id: String(uid), name: displayName, role: mentionForm.value.role, status: 'pending'}
    mentionsSelected.value.push(newMention)

    const suffix = inputValue.value && !/\s$/.test(inputValue.value) ? ' ' : ''
    inputValue.value = `${inputValue.value}${suffix}@${displayName} `
    mentionPopupOpen.value = false

    await nextTick()
    await createNewComment({keepMentions: true}) // gửi ngay để “ping”
    await persistRoster() // lưu roster
    resetMentionForm()
}

function removeMention(uid) {
    mentionsSelected.value = mentionsSelected.value.filter((m) => String(m.user_id) !== String(uid))
    void persistRoster('replace')
}

/* meta helpers */
const metaLabel = (m) => (m.status === 'approved' ? 'đã duyệt' : m.status === 'rejected' ? 'đã từ chối' : 'thêm lúc')
const metaTime = (m) => (m.status === 'approved' || m.status === 'rejected')
    ? (m.acted_at_vi || formatVi(m.acted_at))
    : (m.added_at_vi || formatVi(m.added_at))
const fullTimeTooltip = metaTime
const statusDotClass = (status) => (status === 'approved' ? 'ok' : status === 'rejected' ? 'err' : 'proc')

/* input mention detect */
function onInputDetectMention(e) {
    const v = String(e?.target?.value ?? '')
    if (v.endsWith('@')) mentionPopupOpen.value = true
}

/* ===== upload handlers (single file) ===== */
async function handleBeforeUpload(file) {
    selectedFile.value = file
    return false // chặn auto upload
}

function handleRemoveFile() {
    selectedFile.value = null
}

/* ===== CRUD ===== */
function showUpdateCommentModal(item) {
    openModalEditComment.value = true
    selectedComment.value = {...item}
}

async function handleUpdateComment() {
    if (!selectedComment.value?.id) {
        message.error('Thiếu ID bình luận');
        return
    }
    loadingUpdate.value = true
    try {
        await updateComment(selectedComment.value.id, {content: String(selectedComment.value.content ?? '')})
        openModalEditComment.value = false
        await getListComment(currentPage.value)
        message.success('Cập nhật comment thành công')
    } catch (e) {
        message.error('Không thể cập nhật comment')
    } finally {
        loadingUpdate.value = false
    }
}

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
const canSend = computed(() =>
    !!inputValue.value.trim() || !!selectedFile.value || (mentionsSelected.value?.length > 0)
)

// Bỏ dấu / lowercase để so khớp tên
function vnNorm(s = '') {
    return String(s)
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .trim()
}

// Tạo map tên chuẩn -> user
const userNameMap = computed(() => {
    const map = new Map()
    for (const u of (listUser.value || [])) {
        const key = vnNorm(u.name || '')
        if (key) map.set(key, u)
    }
    return map
})

// Rút @mentions từ nội dung nhập
function extractMentionsFromInput(input = '') {
    const out = []
    if (!input) return out
    // Bắt mọi cụm sau ký tự @ tới khi gặp xuống dòng hoặc ký tự @ kế tiếp
    const re = /@([^\n\r@]+)/g
    let m
    while ((m = re.exec(input))) {
        const raw = m[1].trim()
        if (!raw) continue
        // bỏ ký tự lặt vặt cuối câu
        const cleaned = raw.replace(/[.,;:!?)\]\}]+$/, '').trim()
        const key = vnNorm(cleaned)
        const u = userNameMap.value.get(key)
        if (u) {
            out.push({user_id: String(u.id), name: u.name, role: 'approve', status: 'pending'})
        }
    }
    return out
}

// Dedup theo user_id
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

async function createNewComment({keepMentions = false} = {}) {
    if (!canSend.value) return
    try {
        // lấy mentions từ text + từ popover, rồi dedupe
        const textMentions = extractMentionsFromInput(inputValue.value)
        const mergedMentions = dedupeMentions([...(mentionsSelected.value || []), ...textMentions])
        const hadMentions = mergedMentions.length > 0

        const form = new FormData()
        form.append('user_id', String(store.currentUser.id))
        form.append('content', inputValue.value.trim())

        const mentions = mergedMentions.map((m) => ({
            user_id: Number(m.user_id), name: m.name, role: m.role, status: m.status || 'processing',
        }))
        form.append('mentions', JSON.stringify(mentions))

        if (selectedFile.value) {
            const raw = selectedFile.value
            form.append('attachment', raw, raw.name || 'file')
        }

        await createComment(taskId.value, form)


        inputValue.value = ''
        selectedFile.value = null
        // hiển thị chip ngay lập tức (không cần F5)
        mentionsSelected.value = keepMentions ? mergedMentions : []

        await getListComment(1)
        if (hadMentions) await persistRoster()  // ghi roster rồi sync
        await syncRosterFromServer()

        await nextTick()
        scrollToBottom()
    } catch (e) {
        console.error(e)
        message.error('Không gửi được bình luận')
    }
}


/* ===== list (paging) ===== */
async function getListComment(page = 1) {
    loadingComment.value = true
    try {
        const res = await getComments(taskId.value, {page})
        const comments = res?.data?.comments ?? []
        if (page === 1) {
            listComment.value = comments
            await nextTick()
            measureFooter()
            scrollToBottom()
        } else {
            const el = listEl.value
            const prevScrollBottom = el ? el.scrollHeight - el.scrollTop : 0
            listComment.value = [...listComment.value, ...comments]
            await nextTick()
            measureFooter()
            if (el) el.scrollTop = el.scrollHeight - prevScrollBottom
        }
        totalPage.value = Number(res?.data?.pagination?.totalPages ?? 1)
        currentPage.value = page
    } catch (e) {
        console.error(e)
    } finally {
        loadingComment.value = false
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
        const payload = mentionsSelected.value.map((m) => ({user_id: Number(m.user_id), name: m.name, role: m.role}))
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
            const filesArr = Array.isArray(filesRes.data) ? filesRes.data : Array.isArray(filesRes.data?.data) ? filesRes.data.data : []
            arr = filesArr.filter((x) => Number(x.is_pinned) === 1)
        }
        pinnedFiles.value = (arr || []).map((x) => ({
            ...x, file_path: x.file_path || x.link_url || '', title: x.title || x.file_name || '',
        }))
    } catch (e) {
        console.error('loadPinnedFiles error', e)
        pinnedFiles.value = []
    }
}

async function syncRosterFromServer() {
    try {
        const {data} = await getTaskRosterAPI(taskId.value)
        const roster = data?.roster || data || []
        mentionsSelected.value = roster.map((r) => ({
            user_id: String(r.user_id),
            name: r.name,
            role: r.role,
            status: r.status || 'processing',
            acted_at: r.acted_at || null,
            acted_at_vi: r.acted_at_vi || null,
            added_at: r.added_at || null,
            added_at_vi: r.added_at_vi || null,
        }))
    } catch { /* silent */
    }
}

/* ===== composer behavior: Enter/Shift+Enter ===== */
function onComposerKeydown(e) {
    if (e.key !== 'Enter') return
    if (e.shiftKey) return
    e.preventDefault()
    if (canSend.value) void createNewComment()
}

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
/* ===== Reset nhỏ & token màu ===== */
:where(.comment) {
    --bg-surface: #fff;
    --bg-subtle : #f0f4f7;
    --bd-soft   : #e6ebf1;
    --txt-main  : #24292f;
    --txt-muted : #6b7a8c;
    --txt-faint : #8aa0b4;
    --blue-1: #eef6ff; --blue-2: #cfe3ff; --blue-3: #2a86ff;
    --green-1:#f6ffed; --green-2:#b7eb8f;
    --red-1  :#fff2f0; --red-2  :#ffccc7;
}

/* ===== Layout tổng ===== */
.comment{display:flex;flex-direction:column;height:100%;min-height:0}

/* ===== Sticky header (mentions + pinned) ===== */
.sticky-mentions{position:sticky;top:0;z-index:9;background:var(--bg-surface);border-bottom:1px solid #eef1f3}
.sticky-head{display:flex;justify-content:space-between;align-items:center;padding:6px 8px}
.sticky-title{font-weight:600;color:#222}
.sticky-more{color:#888;margin-left:6px;font-size:12px}
.sticky-actions .ant-btn{padding:0 6px}

/* ===== List comments (scroll) ===== */
.list-comment{
    flex:1 1 auto;min-height:0;overflow:auto;padding:8px 10px 0;
    scrollbar-width:thin;scrollbar-color:rgba(0,0,0,.35) transparent;
}
.list-comment::-webkit-scrollbar{width:6px}
.list-comment::-webkit-scrollbar-thumb{background:rgba(0,0,0,.28);border-radius:8px}

/* ===== Telegram-like bubbles ===== */
.tg-row{display:flex;gap:8px;margin:8px 0}
.tg-row.me{justify-content:flex-end}
.tg-row .avatar{align-self:flex-end}

.bubble{
    max-width:72%;position:relative;padding:8px 10px 6px;
    background:var(--bg-surface);border:1px solid #e6ebf0;border-radius:12px 12px 12px 4px;
    box-shadow:0 1px 0 rgba(0,0,0,.03)
}
.bubble.me{background:#eaf2ff;border-color:#cfe0ff;border-radius:12px 12px 4px 12px}
.bubble .actions{position:absolute;right:4px;top:4px}
.bubble .actions :deep(.ant-btn){padding:0 6px}
.bubble .author{font-size:12px;color:var(--txt-muted);margin-bottom:2px}
.bubble .text{white-space:pre-wrap;line-height:1.38;color:var(--txt-main)}
.bubble .meta{font-size:11px;color:var(--txt-faint);margin-top:6px;text-align:right}
.pinned-pill {
    background: #fff6cc;
    border-color: #ffd666;
}
.pinned-pill:hover {
    background: #fff6cc;
    border-color: #ffd666;
}
/* ===== Attachments trong bubble ===== */
.tg-attachments{margin-top:6px;display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:8px}
.tg-att-item{background:#fff;border:1px solid var(--bd-soft);border-radius:10px;padding:6px}
.cm-att__thumb{width:100%;object-fit:cover;border-radius:6px}
.cm-att__icon{height:64px;display:flex;align-items:center;justify-content:center;background:#fafafa;border-radius:6px}
.cm-att__icon-i{font-size:22px;opacity:.9}
.tg-file-link{font-size:13px;color:#1677ff}
.cm-att__line{display:flex;align-items:center;justify-content:space-between;margin-top:6px;gap:8px}
.pin-btn{font-size:16px;cursor:pointer;transition:color .2s}
.pin-btn:hover{color:#faad14}

/* ===== Footer composer ===== */
.footer-fixed{position:sticky;bottom:0;z-index:5;background:var(--bg-surface);border-top:1px solid #f0f0f0;padding-top:10px;box-shadow:0 -4px 10px rgba(0,0,0,.03)}
.load-more{text-align:center;margin-bottom:8px}
.tg-footer{background:var(--bg-subtle);padding:8px 12px}
.tg-composer{
    position:relative;display:flex;align-items:center;gap:8px;
    background:#fff;border:1px solid #dfe6eb;border-radius:24px;padding:6px 44px;box-shadow:0 1px 0 rgba(0,0,0,.03)
}
.tg-input{flex:1}
.tg-input .ant-input{padding:6px 0 !important}
.tg-input textarea.ant-input{box-shadow:none !important;resize:none;background:transparent}
.tg-attach-btn,.tg-send-btn{position:absolute;top:50%;transform:translateY(-50%)}
.tg-attach-btn{left:6px;color:#6b7a8c}
.tg-send-btn{right:6px;width:32px;height:32px;border:none;background:#d7e3ff;color:#6b7a8c}
.tg-send-btn.is-active{background:var(--blue-3);color:#fff}

/* file chip dưới composer */
.tg-file-strip{display:flex;gap:6px;padding:6px 4px 0;flex-wrap:wrap}
.tg-file-pill{display:inline-flex;align-items:center;gap:6px;background:#fff;border:1px solid #e2e8ef;border-radius:16px;padding:4px 8px;font-size:12px}
.tg-file-pill .x{cursor:pointer;margin-left:4px;opacity:.7}

/* ===== Mentions pop ===== */
.mention-row{margin-top:8px;display:flex;gap:8px;align-items:flex-start;flex-wrap:wrap}
.mention-pop{display:grid;gap:8px;min-width:320px}
.mention-pop .row{display:flex;align-items:center;gap:8px}
.mention-pop .lbl{width:64px;color:#666}

/* ===== Chips (approver) + trạng thái trên 1 dòng ===== */
.chip-card{
    display:flex;align-items:center;gap:8px;border:1px solid var(--bd-soft);
    border-radius:20px;background:var(--green-1);padding:4px 10px;font-size:13px;line-height:1.4;transition:box-shadow .15s,transform .05s
}
.chip-card:hover{box-shadow:0 2px 8px rgba(0,0,0,.06)}
.chip-card.is-approved{background:var(--green-1);border-color:var(--green-2)}
.chip-card.is-pending {background:#e6f4ff;border-color:#91caff}
.chip-card.is-rejected{background:var(--red-1);border-color:var(--red-2)}

.chip-line{display:flex;align-items:center;flex-wrap:wrap;gap:6px}
.chip-name{font-weight:600;color:#2b2f36}
.state-text{font-weight:600}
.chip-time{color:#777;font-size:12px}

.role-dot,.dot{display:inline-block;width:8px;height:8px;border-radius:50%;transform:translateY(1px)}
.role-dot.ok,.dot.ok{background:#52c41a}
.role-dot.proc,.dot.proc{background:#1677ff}
.role-dot.err,.dot.err{background:#ff4d4f}

.chip-close{font-size:14px;color:#9aa4b2;line-height:1;padding:0 4px;cursor:pointer;background:transparent}
.chip-close:hover{color:#111827}

/* ===== Pinned files → pill giống chip ===== */
.pinned-files{border-radius:12px;margin:8px 0;padding:0}
.pinned-pill{
    margin-right: 5px;
    display:inline-flex;align-items:center;gap:8px;max-width:320px;padding:6px 10px;border:1px solid var(--bd-soft);
    background:#fff6cc;border-radius:999px;box-shadow:0 1px 0 rgba(0,0,0,.03);transition:box-shadow .16s,transform .04s,border-color .16s
}
.pinned-pill:hover{box-shadow:0 2px 8px rgba(0,0,0,.06);border-color:#cfd8e3}
.pill-link{display:inline-flex;align-items:center;gap:8px;text-decoration:none;color:#1f75ff;min-width:0}
.pill-icon{font-size:14px;opacity:.9}
.pill-text{display:inline-block;max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;vertical-align:bottom}
.pill-x{border:0;background:transparent;color:#9aa4b2;font-size:14px;line-height:1;padding:0 4px;cursor:pointer;border-radius:6px}
.pill-x:hover{color:#ff4d4f;background:#fff1f0}
.more-pill{border-radius:999px !important;padding:2px 8px !important;border:1px solid var(--blue-2);background:var(--blue-1);color:var(--blue-3)}
.more-pill.more-pill--file{border-radius:999px !important;padding:2px 8px !important;border:1px solid var(--blue-2);background:var(--blue-1);color:var(--blue-3)}

/* ===== Responsive ===== */
@media (max-width:768px){
    .bubble{max-width:88%}
    .chip-card{max-width:100%}
    .pill-text{max-width:140px}
}

</style>
