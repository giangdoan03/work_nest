<template>
    <a-card bordered class="doc-section">
        <template #title>Tài liệu đính kèm</template>

        <template #extra>
            <a-segmented
                v-model:value="activeMode"
                :options="[
          { label: 'Lưu link', value: 'link' },
          { label: 'Upload file', value: 'upload' }
        ]"
            />
        </template>

        <!-- ================= Lưu link (ưu tiên & đặt trước) ================= -->
        <div v-if="activeMode === 'link'">
            <a-form layout="vertical" @submit.prevent>
                <a-form-item label="Tiêu đề tài liệu (link)">
                    <a-input
                        v-model:value="manualLink.title"
                        placeholder="Ví dụ: HSMT - Gói ABC - 2025"
                        allow-clear
                        @pressEnter="trySubmitLink"
                    />
                </a-form-item>

                <a-form-item label="URL tài liệu">
                    <a-input
                        v-model:value="manualLink.url"
                        placeholder="https://..."
                        type="url"
                        allow-clear
                        @pressEnter="trySubmitLink"
                    >
                        <template #prefix><LinkOutlined/></template>
                    </a-input>
                </a-form-item>

                <a-form-item>
                    <a-space>
                        <a-button type="primary" :disabled="!canSubmitLink" @click="submitLink">
                            Lưu tài liệu (link)
                        </a-button>
                        <a-typography-text type="secondary">URL phải hợp lệ và có tiêu đề.</a-typography-text>
                    </a-space>
                </a-form-item>
            </a-form>
        </div>

        <!-- ================= Upload file (đặt sau) ================= -->
        <div v-else>
            <a-form layout="vertical" @submit.prevent>
                <a-form-item name="file" class="mb-0">
                    <a-upload-dragger
                        :before-upload="handleBeforeUpload"
                        :multiple="true"
                        :disabled="loadingUploadFile"
                        :show-upload-list="false"
                        accept="*"
                    >
                        <p class="ant-upload-drag-icon"><PaperClipOutlined/></p>
                        <p class="ant-upload-text">Kéo thả file vào đây hoặc bấm để chọn</p>
                        <p class="ant-upload-hint">Hỗ trợ nhiều file. Dung lượng/định dạng tuỳ cấu hình server.</p>
                    </a-upload-dragger>
                </a-form-item>

                <!-- Tiêu đề cho từng file chờ upload -->
                <a-form-item v-if="pendingFiles.length" label="Tiêu đề cho file đã chọn" class="mt-3">
                    <div class="pending-list">
                        <div
                            v-for="(file, index) in pendingFiles"
                            :key="file.uid || file.name || index"
                            class="pending-item"
                        >
                            <a-input
                                v-model:value="file.title"
                                :status="!file.title ? 'error' : ''"
                                :placeholder="`Tiêu đề cho: ${file.name || 'file #' + (index+1)}`"
                                allow-clear
                                @pressEnter="trySubmitUpload"
                            />
                        </div>
                    </div>
                </a-form-item>

                <a-form-item style="margin-top: 20px">
                    <a-space>
                        <a-button
                            type="primary"
                            :loading="loadingUploadFile"
                            :disabled="!canSubmitUpload || loadingUploadFile"
                            @click="submitUpload"
                        >
                            Lưu tài liệu (file)
                        </a-button>
                        <a-typography-text type="secondary">Yêu cầu: mỗi file cần có tiêu đề.</a-typography-text>
                    </a-space>
                </a-form-item>
            </a-form>
        </div>

        <!-- ================= Preview chung (file + link + pending) ================= -->
        <a-divider v-if="attachmentCards.length" orientation="center" style="margin-top:16px;">Đã đính kèm</a-divider>

        <a-list
            v-if="attachmentCards.length"
            class="att-grid"
            :grid="{ gutter: 8, xs: 1, sm: 2, md: 3, lg: 4, xl: 4 }"
            :data-source="attachmentCards"
        >
            <template #renderItem="{ item }">
                <a-list-item>
                    <a-card hoverable class="att-card att-card--sm" :bodyStyle="{ padding: '10px 10px 8px' }">
                        <!-- ẢNH -->
                        <template v-if="item.kind === 'image'">
                            <a-image :src="item.url" :height="thumbH" :alt="item.name" />
                        </template>

                        <!-- LINK: favicon + icon -->
                        <template v-else-if="item.kind === 'link'">
                            <div class="att-link-thumb">
                                <img :src="favicon(item.url)" class="att-favicon" @error="hideBrokenFavicon" />
                                <LinkOutlined class="att-link-icon" />
                            </div>
                        </template>

                        <!-- FILE khác: icon loại -->
                        <template v-else>
                            <div class="att-icon-wrap">
                                <component :is="item.icon" class="att-icon" />
                            </div>
                        </template>

                        <div class="att-meta">
                            <div class="att-title" :title="item.title || item.name">{{ item.title || item.name }}</div>
                            <div class="att-sub" v-if="item.is_link">
                                <a :href="item.url" target="_blank" rel="noopener">{{ prettyUrl(item.url) }}</a>
                            </div>
                            <div class="att-sub" v-else :title="item.name">{{ item.name }}</div>
                        </div>

                        <div class="att-actions">
                            <a-tooltip title="Xem">
                                <a-button size="small" shape="circle" @click="openAttachment(item)"><EyeOutlined/></a-button>
                            </a-tooltip>
                            <a-tooltip v-if="!item.is_link" title="Tải xuống">
                                <a-button size="small" shape="circle" @click="downloadAttachment(item)"><DownloadOutlined/></a-button>
                            </a-tooltip>

                            <!-- Nút gửi duyệt -->
                            <a-tooltip v-if="!item.pending" title="Gửi duyệt tài liệu">
                                <a-button size="small" shape="circle" type="primary" @click="openSendApproval(item)">
                                    <SendOutlined />
                                </a-button>
                            </a-tooltip>

                            <a-tooltip title="Xoá">
                                <a-button size="small" shape="circle" danger @click="removeAttachment(item)"><DeleteOutlined/></a-button>
                            </a-tooltip>
                        </div>

                        <!-- badges -->
                        <span v-if="item.ext" class="att-ext">{{ item.ext }}</span>
                        <a-tag v-if="item.pending" color="orange" class="att-badge">Chưa lưu</a-tag>
                    </a-card>
                </a-list-item>
            </template>
        </a-list>

        <a-empty v-else description="Chưa có tài liệu" />

        <!-- ======= Modal: Gửi duyệt ======= -->
        <a-modal
            v-model:open="showSend"
            title="Gửi duyệt tài liệu"
            :confirm-loading="sending"
            @ok="submitSendApproval"
            @cancel="clearSendApproval"
        >
            <a-form layout="vertical">
                <a-form-item label="Người duyệt" :validate-status="!sendForm.approver_ids.length ? 'error' : ''" :help="!sendForm.approver_ids.length ? 'Chọn ít nhất 1 người duyệt' : ''">
                    <a-select
                        v-model:value="sendForm.approver_ids"
                        mode="multiple"
                        show-search
                        :options="approverOptions"
                        placeholder="Chọn người duyệt"
                        :filter-option="filterUser"
                    />
                </a-form-item>
                <a-form-item label="Ghi chú (tuỳ chọn)">
                    <a-textarea v-model:value="sendForm.note" :rows="3" placeholder="Thông tin bổ sung cho người duyệt"/>
                </a-form-item>
            </a-form>
        </a-modal>
    </a-card>
</template>

<script setup>
import {
    PaperClipOutlined, LinkOutlined, EyeOutlined, DownloadOutlined, DeleteOutlined,
    FilePdfOutlined, FileWordOutlined, FileExcelOutlined, FilePptOutlined, FileTextOutlined,
    SendOutlined
} from '@ant-design/icons-vue'
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { message } from 'ant-design-vue'
import { useUserStore } from '@/stores/user'

// APIs document
import { uploadDocumentToWP, uploadDocumentLink } from '@/api/document'
// Giữ nguyên fetch file theo task & delete như bạn đang dùng
import { getTaskFilesAPI, deleteTaskFilesAPI } from '@/api/task'

// API gửi duyệt + danh sách user
import { sendApproval } from '@/api/approvals'
import { getUsers } from '@/api/user'

/* ====== PROPS ====== */
const props = defineProps({
    taskId: { type: [String, Number], required: true },
    departmentId: { type: [String, Number], default: null }
})

/* ====== STATE ====== */
const store = useUserStore()
const activeMode = ref('link')
const loadingUploadFile = ref(false)
const fileList = ref([])
const pendingFiles = ref([])
const manualLink = reactive({ title: '', url: '' })
const thumbH = 96

// Gửi duyệt
const showSend = ref(false)
const sending = ref(false)
const sendingItem = ref(null)
const sendForm = reactive({
    approver_ids: [],
    note: ''
})
const approverOptions = ref([])

/* ====== HELPERS ====== */
const IMAGE_EXTS = new Set(['jpg','jpeg','png','gif','webp','bmp','svg'])
const PDF_EXTS   = new Set(['pdf'])
const WORD_EXTS  = new Set(['doc','docx'])
const EXCEL_EXTS = new Set(['xls','xlsx','csv'])
const PPT_EXTS   = new Set(['ppt','pptx'])

function toBool(v) { return v === true || v === 1 || v === '1' }

function extOf(name = '') {
    const n = String(name).split('?')[0]
    const i = n.lastIndexOf('.')
    return i >= 0 ? n.slice(i + 1).toLowerCase() : ''
}

function detectKind({ is_link, name, file_type, mime_type, url }) {
    const linkLike = toBool(is_link) || String(file_type || '').toLowerCase() === 'link'
    if (linkLike) return 'link'
    const ft = String(mime_type || file_type || '').toLowerCase()
    const e  = extOf(name || url || '')
    if (ft.startsWith('image/') || IMAGE_EXTS.has(e)) return 'image'
    if (PDF_EXTS.has(e))   return 'pdf'
    if (WORD_EXTS.has(e))  return 'word'
    if (EXCEL_EXTS.has(e)) return 'excel'
    if (PPT_EXTS.has(e))   return 'ppt'
    return 'other'
}

function pickIcon(kind) {
    switch (kind) {
        case 'pdf':   return FilePdfOutlined
        case 'word':  return FileWordOutlined
        case 'excel': return FileExcelOutlined
        case 'ppt':   return FilePptOutlined
        case 'link':  return LinkOutlined
        default:      return FileTextOutlined
    }
}

function prettyUrl(u) {
    try {
        const url = new URL(u)
        const path = url.pathname.replace(/^\/+/, '')
        const short = path.length > 36 ? path.slice(0, 36) + '…' : path
        return url.host + (short ? '/' + short : '')
    } catch { return u }
}

function favicon(u) {
    try {
        const host = new URL(u).hostname
        return `https://www.google.com/s2/favicons?domain=${host}&sz=64`
    } catch { return '' }
}
function hideBrokenFavicon(e) {
    if (e?.target) e.target.style.opacity = 0
}

/* Chuẩn hoá data hiển thị */
const attachmentCards = computed(() => {
    const serverItems = (fileList.value || []).map(f => {
        const isLink = toBool(f.is_link) || String(f.file_type).toLowerCase() === 'link'
        const url = isLink ? (f.link_url || f.file_path) : f.file_path
        const kind = detectKind({
            is_link: isLink,
            name: f.file_name,
            file_type: f.file_type,
            mime_type: f.mime_type,
            url
        })
        return {
            id: f.id,
            name: f.file_name || '',
            title: f.title || '',
            url,
            is_link: isLink,
            kind,
            icon: pickIcon(kind),
            ext: extOf(f.file_name || url),
            pending: false,
            _source: 'server',
            full: f
        }
    })

    const pendingItems = (pendingFiles.value || []).filter(Boolean).map((p, i) => {
        const url = p.raw ? URL.createObjectURL(p.raw) : ''
        const kind = detectKind({ is_link: false, name: p.name, mime_type: p.raw?.type, url })
        return {
            id: 'pending-' + i,
            name: p.name || '',
            title: p.title || '',
            url,
            is_link: false,
            kind,
            icon: pickIcon(kind),
            ext: extOf(p.name || ''),
            pending: true,
            _source: 'pending',
            full: p
        }
    })

    return [...pendingItems, ...serverItems]
})

/* ====== VALIDATION ====== */
const canSubmitUpload = computed(() => {
    const arr = (pendingFiles.value || []).filter(Boolean)
    return arr.length && arr.every(f => (f.title || '').trim())
})
const canSubmitLink = computed(() => {
    const t = (manualLink.title || '').trim()
    const u = (manualLink.url || '').trim()
    if (!t || !u) return false
    try { const parsed = new URL(u); return !!parsed.protocol && !!parsed.host } catch { return false }
})

/* ====== ACTIONS ====== */
function handleBeforeUpload(file) {
    pendingFiles.value.push({ uid: file.uid, raw: file, name: file.name, title: '' })
    return false // chặn upload mặc định của AntD
}

async function fetchTaskFiles() {
    if (!props.taskId) return
    try {
        const res = await getTaskFilesAPI(props.taskId)
        const data = Array.isArray(res?.data) ? res.data : []
        fileList.value = data.map(f => ({
            ...f,
            uid: f.id || f.file_name,
            name: f.file_name,
            url: f.is_link ? (f.link_url || f.file_path) : f.file_path,
            status: 'done'
        }))
    } catch (e) {
        console.error('fetchTaskFiles error', e)
        fileList.value = []
    }
}

async function submitUpload() {
    const arr = (pendingFiles.value || []).filter(Boolean)
    if (!arr.length) return message.warning('Chưa chọn file nào.')
    if (arr.some(f => !f.raw || !(f.title || '').trim())) return message.error('Thiếu tiêu đề.')

    loadingUploadFile.value = true
    try {
        const deptId = props.departmentId ?? (store?.currentUser?.department_id ?? '')
        for (const f of arr) {
            const fd = new FormData()
            fd.append('file', f.raw, f.name)
            fd.append('title', f.title.trim())
            fd.append('department_id', String(deptId))
            fd.append('visibility', 'private')
            fd.append('task_id', String(props.taskId)) // để BE gắn vào task_files
            await uploadDocumentToWP(fd)
        }
        pendingFiles.value = []
        await fetchTaskFiles()
        message.success('Đã lưu tài liệu.')
    } catch (e) {
        console.error(e)
        message.error('Upload thất bại.')
    } finally {
        loadingUploadFile.value = false
    }
}
function trySubmitUpload() {
    if (canSubmitUpload.value && !loadingUploadFile.value) submitUpload()
}

async function submitLink() {
    if (!canSubmitLink.value) return
    try {
        await uploadDocumentLink({
            title: manualLink.title.trim(),
            file_url: manualLink.url.trim(), // BE nhận 'file_url'
            department_id: props.departmentId ?? store?.currentUser?.department_id,
            visibility: 'private',
            task_id: props.taskId
        })
        manualLink.title = ''
        manualLink.url = ''
        await fetchTaskFiles()
        message.success('Đã lưu link tài liệu.')
    } catch (e) {
        console.error(e)
        message.error('Lưu link thất bại.')
    }
}
function trySubmitLink() {
    if (canSubmitLink.value) submitLink()
}

function openAttachment(it) { window.open(it.url, '_blank', 'noopener') }
function downloadAttachment(it) { window.open(it.url, '_blank', 'noopener') }

async function removeAttachment(it) {
    if (it._source === 'pending') {
        const i = pendingFiles.value.findIndex(p => p === it.full)
        if (i >= 0) pendingFiles.value.splice(i, 1)
        return
    }
    try {
        await deleteTaskFilesAPI(it.full.id)
        await fetchTaskFiles()
        message.success('Đã xoá file.')
    } catch (e) {
        console.error(e)
        message.error('Xoá thất bại.')
    }
}

/* ====== GỬI DUYỆT ====== */
function filterUser(input, option) {
    return option?.label?.toLowerCase?.().includes?.(input.toLowerCase())
}
async function loadApprovers() {
    try {
        const res = await getUsers()
        const arr = Array.isArray(res?.data) ? res.data : []
        approverOptions.value = arr.map(u => ({ value: String(u.id), label: u.name || u.email || `#${u.id}` }))
    } catch (e) {
        approverOptions.value = []
    }
}
function openSendApproval(item) {
    sendingItem.value = item
    showSend.value = true
    sendForm.approver_ids = []
    sendForm.note = ''
    loadApprovers()
}
function clearSendApproval() {
    showSend.value = false
    sendingItem.value = null
    sendForm.approver_ids = []
    sendForm.note = ''
}
async function submitSendApproval() {
    if (!sendForm.approver_ids.length) {
        return message.error('Vui lòng chọn ít nhất 1 người duyệt.')
    }
    try {
        sending.value = true
        await sendApproval({
            target_type: 'document',
            target_id: sendingItem.value.id,
            approver_ids: sendForm.approver_ids.map(id => Number(id)),
            note: sendForm.note || ''
        })
        message.success('Đã gửi duyệt tài liệu.')
        clearSendApproval()
    } catch (e) {
        console.error(e)
        message.error('Gửi duyệt thất bại.')
    } finally {
        sending.value = false
    }
}

/* ====== LIFECYCLE ====== */
onMounted(fetchTaskFiles)
watch(() => props.taskId, fetchTaskFiles)
</script>

<style scoped>
/* Grid gọn hơn */
.att-grid { margin-top: 8px; }

/* Card nhỏ gọn */
.att-card { border-radius: 12px; overflow: hidden; }
.att-card--sm {
    --att-thumb-h: 96px;
    --att-icon-size: 30px;
    --att-pad-x: 8px;
    --att-pad-y: 6px;
}

/* Vùng icon/ảnh nhỏ lại */
.att-icon-wrap { display:flex; align-items:center; justify-content:center; height: var(--att-thumb-h); background:#fafafa; }
.att-icon { font-size: var(--att-icon-size); opacity: .9; }

/* Link thumb */
.att-link-thumb { height: var(--att-thumb-h); background:#fafafa; display:flex; align-items:center; justify-content:center; position:relative; }
.att-favicon { width:22px; height:23px; border-radius:6px; position:absolute; left:8px; top:8px; }
.att-link-icon { font-size: var(--att-icon-size); opacity:.9; }

/* Meta & chữ nhỏ hơn */
.att-meta { padding: 6px var(--att-pad-x) 0; }
.att-title { font-weight:600; font-size:13px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.att-sub { color:#889; font-size:11px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }

/* Hàng nút hành động thu gọn */
.att-actions { display:flex; gap:6px; padding: 6px var(--att-pad-x) 8px; justify-content:flex-end; }
.att-actions :deep(.ant-btn) { width:22px; height:22px; padding:0; }

/* badges */
.att-badge { position:absolute; top:6px; left:6px; border-radius:999px; font-size:10px; padding:0 6px; }
.att-ext { position:absolute; top:6px; right:6px; font-size:10px; padding:0 6px; background:#f0f1f5; border-radius:999px; text-transform:uppercase; color:#555; }
</style>

<style>
.ant-list-item {
    padding-left: 0 !important;
    padding-right: 0 !important;
}
</style>
