<template>
    <div class="comment">
        <!-- STICKY: người duyệt/ký + file ghim -->
        <div class="mention-chips sticky-mentions" v-if="(pinnedFiles && pinnedFiles.length) || (mentionsSelected && mentionsSelected.length)">
            <!-- Header: summary + toggles -->
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
                                    <PlusOutlined />
                                </template>
                                <template v-else>
                                    <MinusOutlined />
                                </template>
                            </template>
                            {{ isStickyExpanded ? 'Thu gọn' : 'Hiện tất cả' }}
                        </a-button>
                    </a-tooltip>
                </div>
            </div>

            <!-- Pinned files -->
            <div v-if="visiblePinnedFiles.length" class="pinned-files" style="padding:8px">
                <a-space wrap style="margin-bottom:0">
                    <div v-for="f in visiblePinnedFiles" :key="f.id || f.file_path" class="pinned-item">
                        <a :href="hrefOf(f)" target="_blank" rel="noopener" class="pinned-link">
                            <PaperClipOutlined style="margin-right:4px"/>
                            {{ titleOf(f) }}
                        </a>
                        <a-tooltip title="Bỏ ghim">
                            <CloseOutlined class="unpin" @click="togglePin(f)"/>
                        </a-tooltip>
                    </div>

                    <!-- “+N file” indicator when collapsed -->
                    <a-tag v-if="!isStickyExpanded && hiddenPinnedCount>0" color="blue" class="more-pill"
                           @click="expandSticky">
                        +{{ hiddenPinnedCount }} file
                    </a-tag>
                </a-space>
            </div>

            <!-- Approver/sign chips -->
            <a-space wrap style="margin-bottom:8px;">
                <a-popover
                    v-for="m in visibleMentions"
                    :key="m.user_id"
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

                    <div
                        class="chip-card"
                        :class="{
          'is-approved': m.status==='approved',
          'is-pending': m.status==='pending' || m.status==='processing',
          'is-rejected': m.status==='rejected'
        }"
                    >
                        <div class="chip-top">
                            <div class="chip-title" :title="m.name">
                                @{{ m.name }}
                                <span class="role-dot" :class="statusDotClass(m.status)"></span>
                                <span class="state-text">
              {{
                                        m.status === 'approved' ? (m.role === 'sign' ? 'Đã ký' : 'Đã duyệt')
                                            : m.status === 'rejected' ? 'Đã từ chối'
                                                : (m.role === 'sign' ? 'Chờ ký' : 'Chờ duyệt')
                                    }}
            </span>
                            </div>
                            <a-tooltip title="Bỏ khỏi danh sách">
                                <a-button type="text" size="small" class="chip-close"
                                          @click.stop="removeMention(m.user_id)">×
                                </a-button>
                            </a-tooltip>
                        </div>

                        <a-tooltip :title="fullTimeTooltip(m)" v-if="metaTime(m)">
                            <div class="chip-meta">
                                {{ metaLabel(m) }} · {{ metaTime(m) }}
                            </div>
                        </a-tooltip>
                    </div>
                </a-popover>

                <!-- “+N người” indicator when collapsed -->
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


        <!-- LIST COMMENT -->
        <div class="list-comment" v-if="listComment" ref="listEl" :style="{ paddingBottom: listPadBottom }">
            <a-spin :spinning="loadingComment">
                <div class="comment-content" v-for="(item, index) in listComment" :key="item.id || index">
                    <a-row :gutter="[12,12]">
                        <a-col>
                            <BaseAvatar
                                :src="getUserById(item.user_id)?.avatar"
                                :name="getUserById(item.user_id)?.name || 'Không rõ'"
                                :size="40"
                                shape="circle"
                                :preferApiOrigin="true"
                            />
                        </a-col>

                        <a-col flex="1" style="margin-top:6px;">
                            <a-typography-text style="color:#5c5c5c;">
                                {{ getUserById(item.user_id)?.name || 'Không rõ' }}
                            </a-typography-text>

                            <div class="content">
                                {{ item.content }}
                            </div>

                            <!-- File đính kèm (nhỏ gọn) -->
                            <div v-if="item.files && item.files.length" class="cm-att">
                                <div v-for="f in item.files" :key="f.id || f.file_path" class="cm-att__card">
                                    <!-- ẢNH -->
                                    <a-image
                                        v-if="kindOfCommentFile(f) === 'image'"
                                        :src="f.file_path"
                                        :height="56"
                                        :preview="true"
                                        class="cm-att__thumb"
                                    />
                                    <!-- FILE KHÁC -->
                                    <div v-else class="cm-att__icon">
                                        <component :is="pickIcon(kindOfCommentFile(f))" class="cm-att__icon-i"/>
                                    </div>

                                    <a
                                        class="cm-att__title"
                                        :href="f.file_path"
                                        target="_blank"
                                        rel="noopener"
                                        :title="f.file_name || prettyUrl(f.file_path)"
                                    >
                                        {{ f.file_name || prettyUrl(f.file_path || f.link_url) }}
                                    </a>

                                    <!-- 📌 Nút Ghim -->
                                    <a-tooltip :title="isPinned(f) ? 'Bỏ ghim file này' : 'Ghim file lên trên'">
                                        <PushpinOutlined
                                            class="pin-btn"
                                            :style="{ color: isPinned(f) ? '#faad14' : '#aaa', cursor: 'pointer' }"
                                            @click="togglePin(f)"
                                        />
                                    </a-tooltip>
                                </div>
                            </div>
                        </a-col>

                        <a-col>
                            <a-dropdown trigger="click" :getPopupContainer="t => t.parentNode">
                                <EllipsisOutlined/>
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
                        </a-col>
                    </a-row>

                    <div class="content-time">
                        <a-typography-text type="secondary">
                            <a-tooltip :title="formatVi(item.created_at)">
                                {{ fromNowVi(item.created_at) }}
                            </a-tooltip>
                        </a-typography-text>
                    </div>

                    <a-divider v-if="index !== listComment.length - 1" style="height:1px; background-color:#e0e2e3; margin:5px 0 5px;"/>
                </div>
            </a-spin>
        </div>

        <!-- FOOTER: composer -->
        <div class="footer-fixed" ref="footerEl">
            <div class="load-more" v-if="currentPage < totalPage && !loadingComment">
                <a-button size="small" @click="getListComment(currentPage + 1)">Tải thêm</a-button>
            </div>

            <div class="composer">
                <a-input
                    v-model:value="inputValue"
                    placeholder="Viết lời nhắn tại đây (gõ @ để thêm người duyệt/ký)"
                    @keydown.enter.exact.prevent="createNewComment"
                    @input="onInputDetectMention"
                />

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
                                    <a-segmented
                                        v-model:value="mentionForm.role"
                                        :options="[{ label: 'Duyệt', value: 'approve' }, { label: 'Ký', value: 'sign' }]"
                                    />
                                </div>
                                <div class="row" style="justify-content:flex-end; gap:8px;">
                                    <a-button size="small" @click="resetMentionForm">Hủy</a-button>
                                    <a-button size="small" type="primary" @click="addMention">Thêm</a-button>
                                </div>
                            </div>
                        </template>
                        <!--  <a-button size="small" @click="mentionPopupOpen = true">+ Thêm người duyệt/ký</a-button>-->
                    </a-popover>
                </div>

                <div class="list-file" v-if="selectedFile">
                    <div class="file">
                        <a-button size="large" style="margin-right:12px;">
                            <template #icon>
                                <FileTextOutlined/>
                            </template>
                        </a-button>
                        <a-typography-text>{{ selectedFile.name }}</a-typography-text>
                        <div class="close-file" @click="selectedFile=null">x</div>
                    </div>
                </div>

                <div class="composer-actions">
                    <a-button
                        type="primary"
                        style="margin-right:12px; width:80px;"
                        :disabled="!inputValue.trim() && !selectedFile && !(mentionsSelected?.length)"
                        @click="createNewComment"
                    >Gửi
                    </a-button>

                    <a-upload
                        :file-list="listFile"
                        :show-upload-list="false"
                        :maxCount="1"
                        :multiple="true"
                        :on-remove="() => handleRemoveFile()"
                        :before-upload="(file) => handleBeforeUpload('attachment', file)"
                        :customRequest="({ file }) => handleBeforeUpload('attachment', file)"
                    >
                        <a-button>
                            <template #icon>
                                <PaperClipOutlined/>
                            </template>
                        </a-button>
                    </a-upload>
                </div>
            </div>
        </div>

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
import {computed, nextTick, onBeforeUnmount, onMounted, ref} from 'vue'
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
    PlusOutlined,
    MinusOutlined
} from '@ant-design/icons-vue'
import {
    approveRosterAPI,
    createComment,
    deleteComment,
    getComments,
    getTaskRosterAPI,
    mergeTaskRosterAPI,
    rejectRosterAPI,
    updateComment
} from '@/api/task'

import {
    adoptTaskFileFromPathAPI,
    getPinnedFilesAPI,
    getTaskFilesAPI,
    pinTaskFileAPI,
    unpinTaskFileAPI,
    uploadTaskFileLinkAPI
} from '@/api/taskFiles'

import {getUsers} from '@/api/user'
import {useRoute} from 'vue-router'
import {useUserStore} from '@/stores/user.js'
import {message} from 'ant-design-vue'

import dayjs from 'dayjs'
import 'dayjs/locale/vi'
import relativeTime from 'dayjs/plugin/relativeTime'
import BaseAvatar from "@/components/common/BaseAvatar.vue"

dayjs.extend(relativeTime)
dayjs.locale('vi')

/* ===== time helpers (VI) ===== */
const tick = ref(Date.now());
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

// ✅ LẤY taskId CHUẨN TỪ URL
const taskId = computed(() => Number(route.params.taskId || route.params.id))

const inputValue = ref('')
const listComment = ref([])
const listUser = ref([])

const selectedFile = ref()
const listFile = ref([])

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
    const h = footerEl.value?.offsetHeight || 96;
    listPadBottom.value = h + 8 + 'px'
}

function scrollToBottom() {
    const el = listEl.value;
    if (!el) return;
    el.scrollTop = el.scrollHeight
}

/* ===== task_files index để map file_path -> task_files.id ===== */
const taskFileByPath = ref({}) // { normalized_path: TaskFileRow }

function normalizePath(u = '') {
    return String(u).split('?')[0]
}


// collapse/expand state
const isStickyExpanded = ref(false)
const MAX_FILES_COLLAPSED = 1
const MAX_MENTIONS_COLLAPSED = 1

function toggleSticky() {
    isStickyExpanded.value = !isStickyExpanded.value
}

function expandSticky() {
    isStickyExpanded.value = true
}

// visible/hidden pinned files
const visiblePinnedFiles = computed(() => {
    const list = pinnedFiles.value || []
    return isStickyExpanded.value ? list : list.slice(0, MAX_FILES_COLLAPSED)
})
const hiddenPinnedCount = computed(() => {
    const list = pinnedFiles.value || []
    return Math.max(0, list.length - MAX_FILES_COLLAPSED)
})

// visible/hidden mentions
const visibleMentions = computed(() => {
    const list = mentionsSelected.value || []
    return isStickyExpanded.value ? list : list.slice(0, MAX_MENTIONS_COLLAPSED)
})
const hiddenMentionsCount = computed(() => {
    const list = mentionsSelected.value || []
    return Math.max(0, list.length - MAX_MENTIONS_COLLAPSED)
})


async function ensureTaskFileId(file) {
    // 1) đã có id?
    const existed = getTaskFileId(file)
    if (existed) return existed

    const path = String(file.file_path || '')
    const name = file.file_name || prettyUrl(path)

    // 2) link http(s) → tạo record link
    if (/^https?:\/\//i.test(path)) {
        try {
            const {data} = await uploadTaskFileLinkAPI(taskId.value, {
                title: name,
                url: path,
                user_id: Number(store.currentUser.id),
            })
            const created = Array.isArray(data) ? data[0] : (data?.data || data)
            // đồng bộ index
            const key = normalizePath(created?.file_path || created?.link_url || path)
            taskFileByPath.value[key] = {
                ...(created || {}),
                file_path: created?.file_path || created?.link_url || path,
            }
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
        const files = Array.isArray(data) ? data : (data?.data || [])
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


function getTaskFileId(f = {}) {
    if (f.task_file_id || f.taskFileId) return Number(f.task_file_id || f.taskFileId)
    if (typeof f.id === 'number' && (f.file_path || f.link_url)) {
        const key = normalizePath(f.file_path || f.link_url)
        if (taskFileByPath.value[key]?.id === f.id) return f.id
    }
    const byPath = taskFileByPath.value[normalizePath(f.file_path || f.link_url || '')]
    if (byPath?.id) return Number(byPath.id)
    return null
}

/* ===== Pinned files (max 2) ===== */
const pinnedFiles = ref([]) // [{ id: task_file_id, file_path, file_name }]
function isPinned(file) {
    const list = Array.isArray(pinnedFiles.value) ? pinnedFiles.value : []
    const tfId = getTaskFileId(file)
    if (tfId) return list.some(p => Number(p.id) === Number(tfId))
    const path = normalizePath(file.file_path || file.link_url || '')
    return list.some(p => normalizePath(p.file_path || p.link_url || '') === path)
}

async function togglePin(file) {
    const tfId = await ensureTaskFileId(file)
    if (!tfId) return

    try {
        const already = isPinned({...file, task_file_id: tfId})

        if (already) {
            await unpinTaskFileAPI(tfId, {user_id: store.currentUser.id})
        } else {
            // chặn 2 chiếc ở UI trước khi gọi
            if ((pinnedFiles.value?.length || 0) >= 2) {
                message.warning('Chỉ được ghim tối đa 2 file');
                return
            }
            await pinTaskFileAPI(tfId, {user_id: store.currentUser.id})
        }

        // ✅ chỉ lấy theo server, không tự set state cục bộ
        await loadPinnedFiles()
        message.success(already ? 'Đã bỏ ghim' : 'Đã ghim')
    } catch (e) {
        console.error('pin/unpin error', e?.response?.data || e)
        message.error('Không thao tác được ghim/bỏ ghim')
    }
}


/* ===== detect file type helpers ===== */
const IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const PDF_EXTS = new Set(['pdf']);
const WORD_EXTS = new Set(['doc', 'docx'])
const EXCEL_EXTS = new Set(['xls', 'xlsx', 'csv']);
const PPT_EXTS = new Set(['ppt', 'pptx'])

function extOf(name = '') {
    const n = String(name).split('?')[0];
    const m = n.lastIndexOf('.');
    return m >= 0 ? n.slice(m + 1).toLowerCase() : ''
}

function detectKind(o = {}) {
    const e = extOf(o.name || o.url || '');
    const t = o.file_type || '';
    if (String(t).indexOf('image/') === 0) return 'image'
    if (IMAGE_EXTS.has(e)) return 'image';
    if (PDF_EXTS.has(e)) return 'pdf';
    if (WORD_EXTS.has(e)) return 'word'
    if (EXCEL_EXTS.has(e)) return 'excel';
    if (PPT_EXTS.has(e)) return 'ppt';
    if (/^https?:\/\//i.test(o.url || '')) return 'link';
    return 'other'
}

function pickIcon(k) {
    switch (k) {
        case 'pdf':
            return FilePdfOutlined;
        case 'word':
            return FileWordOutlined;
        case 'excel':
            return FileExcelOutlined;
        case 'ppt':
            return FilePptOutlined;
        case 'link':
            return LinkOutlined;
        default:
            return FileTextOutlined
    }
}

function prettyUrl(u) {
    try {
        const url = new URL(u);
        const path = url.pathname.replace(/^\/+/, '');
        const short = path.length > 30 ? path.slice(0, 30) + '…' : path;
        return url.host + (short ? '/' + short : '')
    } catch {
        return u
    }
}

function kindOfCommentFile(f = {}) {
    return detectKind({name: f.file_name, url: f.file_path, file_type: f.file_type})
}

/* ===== Approve popover control & actions ===== */
const mentionPopoverOpen = ref({})

async function handleApproveAction(m, status) {
    try {
        if (status === 'approved') {
            await approveRosterAPI(taskId.value, {note: null})
        } else {
            await rejectRosterAPI(taskId.value, {note: null})
        }
        mentionPopoverOpen.value[m.user_id] = false
        await syncRosterFromServer()   // ✅ chỉ đồng bộ từ server
        message.success(status === 'approved'
            ? `${m.name} đã ${m.role === 'sign' ? 'ký' : 'duyệt'}`
            : `${m.name} đã từ chối`);
    } catch (e) {
        console.error(e);
        message.error('Xử lý không thành công');
    }
}


/* ===== users & mentions ===== */
const getUserById = (id) => listUser.value.find(u => u.id === id) || {}
const userOptions = computed(() => (listUser.value || []).map(u => ({value: String(u.id), label: u.name})))
const filterUser = (input, option) => (option?.label ?? '').toLowerCase().includes(String(input).toLowerCase())

const mentionPopupOpen = ref(false)
const mentionsSelected = ref([]) // [{ user_id, name, role, status }]
const mentionForm = ref({userId: null, role: 'approve'})

function resetMentionForm() {
    mentionForm.value.userId = null;
    mentionForm.value.role = 'approve';
    mentionPopupOpen.value = false
}

const addMention = async () => {
    const uid = mentionForm.value.userId;
    if (!uid) return
    if (mentionsSelected.value.some(m => String(m.user_id) === String(uid))) {
        message.info('Người này đã có trong danh sách');
        return
    }
    const user = listUser.value.find(u => String(u.id) === String(uid))
    const displayName = user?.name || `#${uid}`
    const newMention = {user_id: String(uid), name: displayName, role: mentionForm.value.role, status: 'pending'}

    mentionsSelected.value.push(newMention)

    const suffix = inputValue.value && !/\s$/.test(inputValue.value) ? ' ' : ''
    inputValue.value = `${inputValue.value}${suffix}@${displayName} `
    mentionPopupOpen.value = false

    await nextTick()
    await createNewComment({keepMentions: true}) // gửi comment nhưng giữ mentions
    await persistRoster() // lưu roster lên BE
    resetMentionForm()
}

function removeMention(uid) {
    mentionsSelected.value = mentionsSelected.value.filter(m => String(m.user_id) !== String(uid))
    persistRoster('replace') // ghi đè roster còn lại, nhưng không gửi status => BE giữ nguyên status cũ
}

// Label meta và thời gian ngắn gọn
function metaLabel(m) {
    if (m.status === 'approved') return 'đã duyệt';
    if (m.status === 'rejected') return 'đã từ chối';
    return 'thêm lúc';
}

function metaTime(m) {
    if (m.status === 'approved' || m.status === 'rejected') {
        return m.acted_at_vi || formatVi(m.acted_at);
    }
    return m.added_at_vi || formatVi(m.added_at);
}

function fullTimeTooltip(m) {
    if (m.status === 'approved' || m.status === 'rejected') {
        return m.acted_at_vi || formatVi(m.acted_at);
    }
    return m.added_at_vi || formatVi(m.added_at);
}

function statusDotClass(status) {
    return status === 'approved' ? 'ok' : status === 'rejected' ? 'err' : 'proc';
}


function hrefOf(f = {}) {
    return f.file_path || f.link_url || ''
}

function titleOf(f = {}) {
    return f.file_name || f.title || prettyUrl(f.file_path || f.link_url || '')
}

function onInputDetectMention(e) {
    const v = String(e?.target?.value ?? '');
    if (v.endsWith('@')) mentionPopupOpen.value = true
}

/* ===== upload handlers ===== */
async function handleBeforeUpload(_field, file) {
    selectedFile.value = file;
    return false
}

function handleRemoveFile() {
    selectedFile.value = null
}

/* ===== CRUD ===== */
function showUpdateCommentModal(item) {
    openModalEditComment.value = true;
    selectedComment.value = {...item}
}

async function handleUpdateComment() {
    if (!selectedComment.value?.id) {
        message.error('Thiếu ID bình luận');
        return
    }
    loadingUpdate.value = true
    try {
        await updateComment(selectedComment.value.id, {content: selectedComment.value.content})
        openModalEditComment.value = false
        await getListComment(currentPage.value)
        message.success('Cập nhật comment thành công')
    } catch {
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
    } catch {
        message.error('Không thể xóa comment')
    }
}

// Gửi comment
const createNewComment = async ({keepMentions = false} = {}) => {
    if (!inputValue.value.trim() && !selectedFile.value && !(mentionsSelected.value?.length)) return
    try {
        const form = new FormData()
        form.append('user_id', store.currentUser.id)
        form.append('content', inputValue.value ? inputValue.value.trim() : '')
        form.append('mentions', JSON.stringify((mentionsSelected.value || []).map(m => ({
            user_id: Number(m.user_id), name: m.name, role: m.role, status: m.status || 'processing'
        }))))
        if (selectedFile.value) form.append('attachment', selectedFile.value)

        await createComment(taskId.value, form)

        inputValue.value = ''
        selectedFile.value = null
        if (!keepMentions) mentionsSelected.value = []

        await getListComment(1)
        await nextTick();
        scrollToBottom()
    } catch (e) {
        console.error(e);
        message.error('Không gửi được bình luận')
    }
}

/* ===== load list (paging) ===== */
async function getListComment(page = 1) {
    loadingComment.value = true
    try {
        const res = await getComments(taskId.value, {page})
        if (page === 1) {
            listComment.value = res.data.comments
            await nextTick();
            measureFooter();
            scrollToBottom()
        } else {
            const el = listEl.value;
            const prevScrollBottom = el ? (el.scrollHeight - el.scrollTop) : 0
            listComment.value = [...listComment.value, ...res.data.comments]
            await nextTick();
            measureFooter();
            if (el) el.scrollTop = el.scrollHeight - prevScrollBottom
        }
        totalPage.value = res.data.pagination.totalPages
        currentPage.value = page
    } catch (e) {
        console.error(e)
    } finally {
        loadingComment.value = false
    }
}

/* ===== load users ===== */
async function getUser() {
    try {
        const {data} = await getUsers();
        listUser.value = data
    } catch {
        message.error('Không thể tải người dùng')
    }
}

/* ===== roster ===== */
// FE
async function persistRoster(mode = 'merge') {
    try {
        const mentions = mentionsSelected.value.map(m => ({
            user_id: Number(m.user_id),
            name: m.name,
            role: m.role,
            // KHÔNG gửi status ở đây
        }));
        await mergeTaskRosterAPI(taskId.value, mentions, mode);
        await syncRosterFromServer();
    } catch (e) {
        console.error('persistRoster error', e);
        message.error('Không thể lưu danh sách người duyệt/ký');
    }
}


/* ===== pinned files load ===== */
async function loadPinnedFiles() {
    try {
        const res = await getPinnedFilesAPI(taskId.value)
        console.log('🔎 URL hit:', res?.config?.url)
        console.log('📦 res.data =', res.data)

        let arr = []

        if (Array.isArray(res.data)) {
            arr = res.data
        } else if (Array.isArray(res.data?.pinned_files)) {
            arr = res.data.pinned_files
        } else if (Array.isArray(res.data?.files)) {
            arr = res.data.files.filter(x => Number(x.is_pinned) === 1)
        } else {
            console.warn('⚠️ /pinned-files trả kiểu lạ → fallback /tasks/:id/files')
            const filesRes = await getTaskFilesAPI(taskId.value)
            const filesArr = Array.isArray(filesRes.data)
                ? filesRes.data
                : (Array.isArray(filesRes.data?.data) ? filesRes.data.data : [])
            arr = filesArr.filter(x => Number(x.is_pinned) === 1)
        }

        pinnedFiles.value = (arr || []).map(x => ({
            ...x,
            file_path: x.file_path || x.link_url || '',
            title: x.title || x.file_name || '',
        }))

        console.log('✅ pinnedFiles =', pinnedFiles.value)
    } catch (e) {
        console.error('❌ loadPinnedFiles error', e)
        pinnedFiles.value = []
    }
}


/* ===== roster sync ===== */
const syncRosterFromServer = async () => {
    try {
        const {data} = await getTaskRosterAPI(taskId.value)
        const roster = data?.roster || data || []
        mentionsSelected.value = roster.map(r => ({
            user_id: String(r.user_id),
            name: r.name,
            role: r.role,
            status: r.status || 'processing',
            acted_at: r.acted_at || null,
            acted_at_vi: r.acted_at_vi || null,
            added_at: r.added_at || null,          // 👈
            added_at_vi: r.added_at_vi || null,    // 👈
        }))
    } catch { /* no-op */
    }
}


/* ===== lifecycle ===== */
onMounted(async () => {
    t = setInterval(() => (tick.value = Date.now()), 60_000)
    await getUser()
    await getListComment()
    await loadTaskFiles()     // cần để map file_path -> task_files.id
    await loadPinnedFiles()
    await syncRosterFromServer()
    measureFooter()
    if ('ResizeObserver' in window) {
        ro = new ResizeObserver(measureFooter)
        footerEl.value && ro.observe(footerEl.value)
    }
})
onBeforeUnmount(() => {
    clearInterval(t);
    ro?.disconnect?.()
})
</script>


<style scoped>
/* Layout tổng */
.comment {
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 0;
}

/* Sticky mentions + pinned files */
.sticky-mentions {
    position: sticky;
    top: 0;
    z-index: 99;
    background: #fff;
    border-bottom: 1px solid #eaeaea;
}

.pinned-item {
    background: #fafafa;
    padding: 2px 6px;
    border-radius: 6px;
}

/* List comments */
.list-comment {
    flex: 1 1 auto;
    min-height: 0;
    overflow-y: auto;
    overflow-x: hidden;
    padding-right: 2px;
    scrollbar-width: thin;
    scrollbar-color: rgba(0, 0, 0, .35) transparent;
}

.list-comment::-webkit-scrollbar {
    width: 6px;
}

.list-comment::-webkit-scrollbar-track {
    background: transparent;
}

.list-comment::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, .28);
    border-radius: 8px;
}

/* Footer composer */
.footer-fixed {
    position: sticky;
    bottom: 0;
    z-index: 5;
    background: #fff;
    border-top: 1px solid #f0f0f0;
    padding-top: 10px;
    box-shadow: 0 -4px 10px rgba(0, 0, 0, .03);
}

.load-more {
    margin-bottom: 8px;
    text-align: center
}

.composer-actions {
    margin-top: 10px;
    display: flex;
    align-items: center;
    gap: 8px;
    justify-content: flex-end;
}

/* Popover chọn người */
.mention-row {
    margin-top: 8px;
    display: flex;
    gap: 8px;
    align-items: flex-start;
    flex-wrap: wrap;
}

.mention-pop {
    display: grid;
    gap: 8px;
    min-width: 320px;
}

.mention-pop .row {
    display: flex;
    align-items: center;
    gap: 8px;
}

.mention-pop .lbl {
    width: 64px;
    color: #666;
}

/* Misc */
.list-comment {
    margin-top: 8px;
}

.comment-content {
    margin-bottom: 10px;
}

.content {
    margin-top: 10px;
    overflow-wrap: anywhere;
    word-break: break-word;
}

.content-time {
    margin-top: 12px;
}

.list-file {
    margin-top: 10px;
}

.file {
    position: relative;
}

.close-file {
    position: absolute;
    top: -14px;
    left: 34px;
    font-size: 20px;
    cursor: pointer;
}

/* Attachments grid */
.cm-att {
    margin-top: 8px;
    display: grid;
    grid-template-columns:repeat(auto-fill, minmax(150px, 1fr));
    gap: 8px;
}

.cm-att__card {
    position: relative;
    border: 1px solid #f0f0f0;
    border-radius: 10px;
    padding: 6px;
    background: #fff;
}

.cm-att__thumb {
    width: 100%;
    object-fit: cover;
    border-radius: 6px;
}

.cm-att__icon {
    height: 56px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #fafafa;
    border-radius: 6px;
}

.cm-att__icon-i {
    font-size: 22px;
    opacity: .9;
}

.cm-att__title {
    display: block;
    margin-top: 6px;
    font-size: 12px;
    line-height: 1.2;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    color: #1677ff;
}

/* Approve popover */
.approve-pop {
    min-width: 200px;
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.approve-pop .info {
    font-size: 13px;
    color: #444;
}

.approve-pop .actions {
    display: flex;
    justify-content: space-between;
    gap: 6px;
}

/* Pin button + pinned files */
.pin-btn {
    position: absolute;
    top: 6px;
    right: 6px;
    font-size: 16px;
    transition: color .2s;
}

.pin-btn:hover {
    color: #faad14;
}

.pinned-files {
    background: #fffbe6;
    border: 1px solid #ffe58f;
    border-radius: 8px;
    margin-bottom: 8px;
}

.pinned-item {
    display: flex;
    align-items: center;
    gap: 4px;
    background: #fff;
    border: 1px solid #f0f0f0;
    padding: 4px 8px;
    border-radius: 6px;
}

.pinned-link {
    color: #1677ff;
    text-decoration: none;
}

.pinned-link:hover {
    text-decoration: underline;
}

.unpin {
    font-size: 12px;
    color: #999;
    cursor: pointer;
}

.unpin:hover {
    color: #ff4d4f;
}

/* Card nền mềm, bo tròn, viền nhẹ */
.chip-card {
    min-width: 240px;
    max-width: 360px;
    padding: 8px 10px;
    border-radius: 10px;
    border: 1px solid #e6ebf1;
    background: #f7f9fc;
    transition: box-shadow .15s ease, transform .05s ease;
}

.chip-card:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, .06);
}

.chip-card.is-approved {
    background: #f6ffed;
    border-color: #b7eb8f;
}

.chip-card.is-pending {
    background: #eef6ff;
    border-color: #b7d8ff;
}

.chip-card.is-rejected {
    background: #fff2f0;
    border-color: #ffccc7;
}

.chip-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 6px;
}

.chip-title {
    display: flex;
    align-items: center;
    gap: 6px;
    font-weight: 600;
    color: #2b2f36;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.state-text {
    font-weight: 600;
}

.chip-close {
    height: auto;
    line-height: 1;
    padding: 0 4px;
    font-size: 14px;
    color: #9aa4b2;
}

.chip-close:hover {
    color: #111827;
    background: transparent;
}

.chip-meta {
    margin-top: 4px;
    font-size: 12px;
    color: #667085;
}

/* status dot */
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

/* popover */
.approve-pop {
    min-width: 260px;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.pop-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
}

.role-pill {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: #475467;
    border: 1px dashed #d0d5dd;
    padding: 2px 8px;
    border-radius: 999px;
    background: #fafafa;
}

.pop-time {
    font-size: 12px;
    color: #475467;
}

.sticky-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 6px 8px;
    border-bottom: 1px solid #f0f0f0;
    background: #fff;
}

.sticky-title {
    font-weight: 600;
    color: #333;
}

.sticky-more {
    color: #888;
    margin-left: 6px;
    font-size: 12px;
}

.sticky-actions .ant-btn {
    padding: 0 6px;
}

.more-pill {
    cursor: pointer;
    user-select: none;
}

.chip-card {
    max-width: 340px;
}

@media (max-width: 768px) {
    .chip-card {
        max-width: 100%;
    }
}


</style>
