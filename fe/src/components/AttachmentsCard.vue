<template>
    <a-card bordered class="doc-section">
        <a-spin :spinning="loading" tip="Đang tải tài liệu...">
            <a-list
                v-if="displayCards.length"
                class="att-grid"
                :grid="{ gutter: 8, xs: 1, sm: 2, md: 3, lg: 4, xl: 4 }"
                :data-source="displayCards"
            >
                <template #renderItem="{ item }">
                    <a-list-item>
                        <a-card hoverable class="att-card att-card--sm header_card" :bodyStyle="{ padding: '10px 10px 8px' }">
                            <template #extra>
                                <template v-if="approvalStateOf(item).status">
                                    <a-tag v-if="approvalStateOf(item).pending" color="gold">Chờ duyệt</a-tag>
                                    <a-tag v-else-if="approvalStateOf(item).approved" color="green">Đã duyệt</a-tag>
                                    <a-tag v-else-if="approvalStateOf(item).rejected" color="red">Từ chối</a-tag>
                                </template>
                            </template>

                            <!-- Thumb -->
                            <template v-if="item.kind === 'image'">
                                <a-image :src="item.url" :height="thumbH" :alt="item.name"/>
                            </template>
                            <template v-else-if="item.kind === 'link'">
                                <div class="att-link-thumb">
                                    <img :src="favicon(item.url)" class="att-favicon" referrerpolicy="no-referrer"
                                         @error="hideBrokenFavicon" alt=""/>
                                    <LinkOutlined class="att-link-icon"/>
                                </div>
                            </template>
                            <template v-else>
                                <div class="att-icon-wrap">
                                    <component :is="item.icon" class="att-icon"/>
                                </div>
                            </template>

                            <!-- Meta -->
                            <div class="att-meta">
                                <div class="att-title" :title="item.title || item.name">
                                    {{ item.title || item.name }}
                                </div>

                                <div class="att-sub" v-if="item.is_link"></div>
                                <div class="att-sub" v-else :title="item.name">{{ item.name }}</div>

                                <!-- Uploader line -->
                                <div
                                    class="att-uploader"
                                    v-if="item.uploader_name || item.uploaded_by || item.created_at"
                                >
                                    <div class="att-uploader-left">
                                        <UserOutlined class="att-uploader-ico" />
                                        <a-tooltip :title="item.uploader_name || nameOfUploader(item.uploaded_by)">
                                            <span class="att-uploader-name">
                                                {{ item.uploader_name || nameOfUploader(item.uploaded_by) }}
                                            </span>
                                        </a-tooltip>
                                    </div>
                                    <div class="att-uploader-time" v-if="item.created_at">
                                        {{ formatTime(item.created_at) }} — {{ formatDateOnly(item.created_at) }}
                                    </div>
                                </div>

                                <!-- ✅ Chuỗi ký duyệt: ai đã ký / đang chờ / chưa ký -->
                                <div v-if="stepsOf(item).length" class="att-approval">
                                    <span class="att-approval-label">Ký duyệt:</span>
                                    <span
                                        v-for="s in stepsOf(item)"
                                        :key="s.id"
                                        class="att-approval-pill"
                                        :class="pillClass(s)"
                                    >
                                    {{ s.approver_name || nameOfUploader(s.approver_id) || ('#' + s.approver_id) }}
                                    <span class="att-approval-pill-status">
                                      ({{ shortStepStatus(s) }})
                                    </span>
                                  </span>
                                </div>
                            </div>

                            <!-- Actions -->
                            <div class="att-actions">
                                <a-tooltip title="Xem trước">
                                    <a-button size="small" shape="circle" @click="openAttachment(item)">
                                        <EyeOutlined/>
                                    </a-button>
                                </a-tooltip>

                                <a-tooltip v-if="!item.is_link" title="Tải xuống / mở">
                                    <a-button size="small" shape="circle" @click="downloadAttachment(item)">
                                        <DownloadOutlined/>
                                    </a-button>
                                </a-tooltip>

                                <!-- Gửi duyệt -->
                                <a-tooltip :title="sendBtnTooltip(item)">
                                    <a-button
                                        size="small"
                                        shape="circle"
                                        type="primary"
                                        :loading="ensuring[item._key]"
                                        :disabled="!canSendApproval(item)"
                                        @click="openSendApproval(item)"
                                    >
                                        <SendOutlined/>
                                    </a-button>
                                </a-tooltip>


                            </div>

                            <span v-if="item.ext" class="att-ext">{{ item.ext }}</span>
                        </a-card>
                    </a-list-item>
                </template>
            </a-list>

            <a-empty v-else>
                <template #description>Chưa có tài liệu của công việc</template>
            </a-empty>
        </a-spin>

        <!-- Modal gửi duyệt -->
        <a-modal v-model:open="showSend" title="Gửi duyệt tài liệu"
                 :confirm-loading="sending" @ok="submitSendApproval" @cancel="clearSendApproval">
            <a-form layout="vertical">
                <a-form-item label="Người duyệt"
                             :validate-status="!sendForm.approver_ids.length ? 'error' : ''"
                             :help="!sendForm.approver_ids.length ? 'Chọn ít nhất 1 người duyệt' : ''">
                    <a-select v-model:value="sendForm.approver_ids" mode="multiple" show-search
                              :options="approverOptions" placeholder="Chọn người duyệt"
                              :filter-option="filterUser"/>
                </a-form-item>
                <a-form-item label="Ghi chú (tuỳ chọn)">
                    <a-textarea v-model:value="sendForm.note" :rows="3"/>
                </a-form-item>
            </a-form>
        </a-modal>
    </a-card>
</template>

<script setup>
import {
    LinkOutlined, EyeOutlined, DownloadOutlined, SendOutlined,
    FilePdfOutlined, FileWordOutlined, FileExcelOutlined, FilePptOutlined, FileTextOutlined, UserOutlined
} from '@ant-design/icons-vue'
import { computed, onMounted, ref, watch, reactive, nextTick, onBeforeUnmount } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'

// API
import { getUsers } from '@/api/user'
import { sendDocumentApproval, getActiveDocumentApproval } from '@/api/approvals.js'
import {
    adoptTaskFileFromPathAPI,
    uploadTaskFileLinkAPI,
    getCommentFilesByTask,
    sendCommentApproval
} from '@/api/taskFiles'
import { useUserStore } from '@/stores/user'

// ---------- setup ----------
dayjs.locale('vi')
const store = useUserStore()

// ---------- props ----------
const props = defineProps({
    taskId: { type: [String, Number], required: true }
})

// ---------- state ----------
const thumbH = 96
const loading = ref(false)
const approvalLoading = ref(false)
const ensuring = reactive({})                   // per-item loading khi ensure id
const userMap = ref(Object.create(null))
const approverOptions = ref([])
const taskFileItems = ref([])                   // danh sách item hiển thị

// Trạng thái duyệt: Map id (task_file_id hoặc comment id) -> {status, instanceId}
const approvalMap = ref({})

// modal gửi duyệt
const showSend = ref(false)
const sending = ref(false)
const sendingItem = ref(null)
const sendForm = reactive({ approver_ids: [], note: '' })

// ---------- consts & helpers ----------
const IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const PDF_EXTS   = new Set(['pdf'])
const WORD_EXTS  = new Set(['doc', 'docx'])
const EXCEL_EXTS = new Set(['xls', 'xlsx', 'csv'])
const PPT_EXTS   = new Set(['ppt', 'pptx'])
const OFFICE_EXTS= new Set(['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'])

const aborter = { controller: null }

const formatDateOnly = dt => dayjs(dt).isValid() ? dayjs(dt).format('DD/MM/YYYY') : ''
const formatTime     = dt => dayjs(dt).isValid() ? dayjs(dt).format('HH:mm') : ''
const extOf = (name = '') => {
    const n = String(name).split('?')[0]
    const i = n.lastIndexOf('.')
    return i >= 0 ? n.slice(i + 1).toLowerCase() : ''
}
const detectKind = ({ is_link, name, file_type, mime_type, url }) => {
    const ft = String(mime_type || file_type || '').toLowerCase()
    const e = extOf(name || url || '')
    if (is_link) return 'link'
    if (ft.startsWith('image/') || IMAGE_EXTS.has(e)) return 'image'
    if (PDF_EXTS.has(e))   return 'pdf'
    if (WORD_EXTS.has(e))  return 'word'
    if (EXCEL_EXTS.has(e)) return 'excel'
    if (PPT_EXTS.has(e))   return 'ppt'
    return 'other'
}
const pickIcon = (kind) => ({
    pdf:  FilePdfOutlined,
    word: FileWordOutlined,
    excel:FileExcelOutlined,
    ppt:  FilePptOutlined,
    link: LinkOutlined
}[kind] || FileTextOutlined)

const favicon = () => 'https://assets.develop.io.vn/wp-content/uploads/2025/10/favicon.png'
const hideBrokenFavicon = e => { if (e?.target) e.target.style.opacity = 0 }
const normalizeKey = (url = '') => String(url || '').split('?')[0]

// ---------- users ----------
async function loadUsers () {
    try {
        const { data } = await getUsers()
        userMap.value = Object.fromEntries((data || []).map(u => [String(u.id), u]))
        approverOptions.value = (data || []).map(u => ({
            value: String(u.id),
            label: u.name || u.email || `#${u.id}`
        }))
    } catch (e) {
        console.warn('loadUsers error', e)
        approverOptions.value = []
    }
}
const nameOfUploader = id => id ? (userMap.value[String(id)]?.name || `#${id}`) : '—'
const filterUser = (input, option) =>
    option?.label?.toLowerCase?.().includes?.(input.toLowerCase())

// ---------- data compose ----------
const displayCards = computed(() => taskFileItems.value)

// ---------- fetch task files (comment files + task_files nếu BE đã gộp) ----------
async function fetchTaskFiles () {
    if (!props.taskId) return
    loading.value = true
    const seen = new Set()
    try {
        const { data } = await getCommentFilesByTask(props.taskId)
        const rows = data?.files || []

        const items = []
        for (const r of rows) {
            const url   = r.file_path || ''
            const name  = r.file_name || ''
            const key   = normalizeKey(url)
            if (!key || seen.has(key)) continue
            seen.add(key)

            const isLink = /^https?:\/\//i.test(url)
            const kind   = detectKind({ is_link: isLink, name, url })

            const it = {
                _key: key,
                id: r.id,                                // id nguồn (task_files.id hoặc comment.id)
                task_file_id: r.source === 'task_file' ? r.id : (r.task_file_id ?? null),
                name,
                title: r.title || name,
                url,
                is_link: isLink,
                kind,
                icon: pickIcon(kind),
                ext: extOf(name || url),
                created_at: r.created_at || null,
                updated_at: r.updated_at || null,
                uploaded_by: r.uploaded_by || null,
                uploader_name: r.uploader_name || null,
                _source: r.source,                        // 'task_file' | 'comment'
                status: r.status || null,                 // BE có thể đổ sẵn
                full: r
            }

            // seed trạng thái duyệt ngay nếu BE trả sẵn
            const mapKey = it.task_file_id || it.id
            if (r.status && !approvalMap.value[mapKey]) {
                approvalMap.value[mapKey] = { status: String(r.status), instanceId: null }
            }

            items.push(it)
        }

        taskFileItems.value = items
        await refreshApprovalStates()                 // lấy active state cho task_file_ids
    } catch (e) {
        message.error((e?.response?.data?.message) || 'Không tải được tài liệu của task.')
    } finally {
        loading.value = false
    }
}

// ---------- approvals helpers ----------
function approvalStateOf (item) {
    const key = item.task_file_id || item.id
    // ưu tiên map, fallback item.status nếu có
    const st = approvalMap.value[key] || (item.status ? { status: item.status } : {})
    return {
        status: st.status || null,
        pending: st.status === 'pending',
        approved: st.status === 'approved',
        rejected: st.status === 'rejected'
    }
}

const canSendApproval = (item) => item.status === 'not_sent'

const sendBtnTooltip = (item) => {
    if (item.status === 'pending') return 'Đã gửi duyệt, đang chờ xử lý';
    if (item.status === 'approved') return 'Tài liệu đã được duyệt';
    if (item.status === 'rejected') return 'Tài liệu đã bị từ chối, hãy cập nhật rồi gửi lại';
    return 'Gửi tài liệu này vào quy trình duyệt';
};

// đảm bảo có task_file_id (chỉ dùng cho nguồn task_file hoặc khi thực sự muốn adopt/link)
async function ensureTaskFileId (item) {
    if (item.task_file_id || item._source === 'task_file') {
        return (item.task_file_id ||= item.id)
    }
    ensuring[item._key] = true
    try {
        const isHttp = /^https?:\/\//i.test(item.url)
        if (isHttp) {
            const { data } = await uploadTaskFileLinkAPI(props.taskId, {
                title: item.title || item.name || '',
                url: item.url,
                user_id: Number(store.currentUser?.id)
            })
            const created = Array.isArray(data) ? data[0] : (data?.data || data)
            item.task_file_id = Number(created?.id)
        } else {
            const { data } = await adoptTaskFileFromPathAPI(props.taskId, {
                task_id: Number(props.taskId),
                user_id: Number(store.currentUser?.id),
                file_path: item.url,
                file_name: item.name || ''
            })
            const created = data?.data || data
            item.task_file_id = Number(created?.id)
        }
        return item.task_file_id
    } catch (e) {
        message.error(e?.response?.data?.messages?.error || 'Không tạo được tài liệu để gửi duyệt.')
        return null
    } finally {
        ensuring[item._key] = false
    }
}

// nạp trạng thái active cho các task_file_id (comment-id không có API này)
async function refreshApprovalStates () {
    const ids = (taskFileItems.value || [])
        .map(i => i.task_file_id)
        .filter(Boolean)
    if (!ids.length) return

    approvalLoading.value = true
    try {
        const chunk = 6
        for (let i = 0; i < ids.length; i += chunk) {
            await Promise.all(ids.slice(i, i + chunk).map(async id => {
                try {
                    const a = await getActiveDocumentApproval(id)
                    const status = a?.status ?? null
                    const instanceId = a?.instanceId ?? null
// 👇 thêm steps (tùy BE: steps / approval_steps / data.steps)
                    const steps = a?.steps || a?.approval_steps || []
                    approvalMap.value[id] = { status, instanceId, steps }
                } catch {
                    if (!approvalMap.value[id]) approvalMap.value[id] = { status: null, instanceId: null }
                }
            }))
        }
    } finally {
        approvalLoading.value = false
    }
}

// ---------- modal ----------
async function openSendApproval (item) {
    // Nếu là comment: mở modal ngay, KHÔNG ensure
    if (item._source === 'comment') {
        sendingItem.value = item
        sendForm.approver_ids = []
        sendForm.note = ''
        showSend.value = true
        return
    }

    // Nếu là task_file → ensure + preload trạng thái
    const tfId = await ensureTaskFileId(item)
    if (!tfId) return
    try {
        const a = await getActiveDocumentApproval(tfId)
        approvalMap.value[tfId] = { status: a?.status ?? null, instanceId: a?.instanceId ?? null }
    } catch {}
    sendingItem.value = item
    sendForm.approver_ids = []
    sendForm.note = ''
    showSend.value = true
}

async function submitSendApproval () {
    if (!sendForm.approver_ids.length) {
        return message.error('Vui lòng chọn ít nhất 1 người duyệt.')
    }
    const item = sendingItem.value
    if (!item) return
    sending.value = true

    try {
        // 1) Nguồn comment -> giữ nguyên như bạn đã làm
        if (item._source === 'comment') {
            const { data } = await sendCommentApproval(item.id, {
                user_id: Number(store.currentUser.id),
                approver_ids: sendForm.approver_ids.map(Number),
                note: sendForm.note || ''
            })
            message.success(data?.message || 'Đã gửi duyệt file trong comment.')
            item.status = 'pending'
            clearSendApproval()
            return
        }

        // 2) Nguồn document (tài liệu trong tab Tài liệu)
        // comment-files đã trả id là document_id + source: 'document'
        const docId = Number(item.id)
        if (!docId) {
            message.error('Thiếu document_id hợp lệ.')
            return
        }

        const payload = {
            document_id: docId,
            approver_ids: sendForm.approver_ids.map(Number),
            note: sendForm.note || '',
            source_type: 'document', // optional, cho chắc khớp BE
        }

        const { ok, status, data } = await sendDocumentApproval(payload)

        if (ok) {
            item.status = 'pending'
            message.success('Đã gửi ký duyệt tài liệu.')
            clearSendApproval()
        } else if (status === 409) {
            item.status = 'pending'
            message.warning(data?.message || 'Đối tượng đang chờ duyệt.')
            clearSendApproval()
        } else {
            message.error(data?.message || 'Không thể gửi duyệt.')
        }

    } catch (e) {
        message.error(e?.response?.data?.message || e.message || 'Lỗi máy chủ.')
    } finally {
        sending.value = false
    }
}

// Lấy danh sách bước ký cho 1 item
function stepsOf(item) {
    return item.steps || item.full?.steps || [];
}

// Trạng thái rút gọn cho từng bước
function shortStepStatus(step) {
    const s =
        String(
            step.status
            || (step.is_approved && 'approved')
            || (step.is_rejected && 'rejected')
            || (step.is_pending && 'pending')
            || (step.is_current && 'current')
            || ''
        ).toLowerCase()

    if (s === 'approved') return 'đã ký'
    if (s === 'rejected') return 'từ chối'
    if (s === 'current')  return 'đang chờ'
    if (s === 'waiting' || s === 'pending') return 'chờ ký'
    return 'chưa ký'
}

// CSS class màu theo trạng thái bước
function pillClass(step) {
    const s =
        String(
            step.status
            || (step.is_approved && 'approved')
            || (step.is_rejected && 'rejected')
            || (step.is_pending && 'pending')
            || (step.is_current && 'current')
            || ''
        ).toLowerCase()

    if (s === 'approved') return 'att-approval-pill--approved'
    if (s === 'rejected') return 'att-approval-pill--rejected'
    if (s === 'current' || s === 'waiting' || s === 'pending')
        return 'att-approval-pill--pending'
    return 'att-approval-pill--idle'
}




function clearSendApproval () {
    showSend.value = false
    sendingItem.value = null
    sendForm.approver_ids = []
    sendForm.note = ''
}

// ---------- actions ----------
function openAttachment (it) {
    const ext = (it.ext || '').toLowerCase()
    if (OFFICE_EXTS.has(ext)) {
        const url = encodeURIComponent(it.url)
        window.open(`https://view.officeapps.live.com/op/view.aspx?src=${url}`, '_blank', 'noopener')
        return
    }
    window.open(it.url, '_blank', 'noopener')
}
const downloadAttachment = (it) => window.open(it.url, '_blank', 'noopener')

// ---------- lifecycle ----------
onMounted(async () => {
    await Promise.all([loadUsers(), fetchTaskFiles()])
})
watch(() => props.taskId, () => fetchTaskFiles())
onBeforeUnmount(() => {
    aborter.controller?.abort?.()
})
</script>


<style scoped>
/* Grid */
.att-grid {
    margin-top: 8px;
}

/* Card */
.att-card {
    border-radius: 12px;
    overflow: hidden;
}

.att-card--sm {
    --att-thumb-h: 96px;
    --att-icon-size: 30px;
    --att-pad-x: 8px;
    --att-pad-y: 6px;
}

/* Thumbs */
.att-icon-wrap {
    display: flex;
    align-items: center;
    justify-content: center;
    height: var(--att-thumb-h);
    background: #fafafa;
}

.att-icon {
    font-size: var(--att-icon-size);
    opacity: .9;
}

/* Link thumb */
.att-link-thumb {
    height: var(--att-thumb-h);
    background: #fafafa;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
}

.att-favicon {
    width: 22px;
    height: 23px;
    border-radius: 6px;
    position: absolute;
    left: 8px;
    top: 8px;
}

.att-link-icon {
    font-size: var(--att-icon-size);
    opacity: .9;
}

/* Meta */
.att-meta {
    padding: 6px var(--att-pad-x) 0;
}

.att-title {
    font-weight: 600;
    font-size: 13px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.att-sub {
    color: #889;
    font-size: 11px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Uploader row (1 dòng, co giãn hợp lý) */
.att-uploader {
    align-items: center;
    justify-content: space-between;
    gap: 6px;
    margin-top: 2px;
    font-size: 11px;
    color: #666;
    white-space: nowrap;
}

.att-uploader-left {
    flex: 1;
    min-width: 0;
    display: flex;
    align-items: center;
    gap: 6px;
    overflow: hidden;
}

.att-uploader-ico {
    font-size: 12px;
}

.att-uploader-name {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.att-uploader-time {
    flex: 0 0 auto;
    white-space: nowrap;
    color: #999;
}

/* Actions */
.att-actions {
    display: flex;
    gap: 6px;
    padding: 6px var(--att-pad-x) 8px;
    justify-content: flex-end;
}

.att-actions :deep(.ant-btn) {
    width: 22px;
    height: 22px;
    padding: 0;
}

/* Badges */
.att-ext {
    position: absolute;
    top: 6px;
    right: 6px;
    font-size: 10px;
    padding: 0 6px;
    background: #f0f1f5;
    border-radius: 999px;
    text-transform: uppercase;
    color: #555;
}

.header_card .ant-card-extra {
    margin-left: 0 !important;
}

.att-approval {
    margin-top: 4px;
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    align-items: center;
    font-size: 10px;
    line-height: 1.4;
}

.att-approval-label {
    color: #999;
    margin-right: 2px;
}

.att-approval-pill {
    padding: 0 6px;
    border-radius: 999px;
    background: #f5f5f5;
    color: #555;
    display: inline-flex;
    align-items: center;
    gap: 2px;
    border: 1px solid transparent;
}

.att-approval-pill-status {
    opacity: .9;
}

/* Đã ký */
.att-approval-pill--approved {
    background: #f6ffed;
    color: #389e0d;
    border-color: #b7eb8f;
}

/* Đang/Chờ ký */
.att-approval-pill--pending {
    background: #fffbe6;
    color: #d48806;
    border-color: #ffe58f;
}

/* Từ chối */
.att-approval-pill--rejected {
    background: #fff1f0;
    color: #cf1322;
    border-color: #ffa39e;
}

/* Chưa tới lượt / chưa đụng */
.att-approval-pill--idle {
    background: #fafafa;
    color: #999;
}

</style>

<style>
.ant-list-item {
    padding-left: 0 !important;
    padding-right: 0 !important;
}

.att-uploader {
    align-items: center;
    justify-content: space-between;
    gap: 6px;
    white-space: nowrap;
}

.att-uploader-left {
    flex: 1;
    min-width: 0;
    display: flex;
    gap: 6px;
    overflow: hidden;
}

.att-uploader-name {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.att-uploader-time {
    flex: 0 0 auto;
    white-space: nowrap;
    color: #999;
}

/* ========== Wrapper: grid để nhiều card nhỏ gọn ========== */
.att-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); /* mỗi card tối thiểu 300px */
    gap: 16px;
    align-items: start;
    padding: 8px; /* tuỳ chỉnh */
    box-sizing: border-box;
}

/* Nếu a-list dùng .ant-list-item wrappers */
.att-list .ant-list-item {
    display: block;
    width: 100%;
    padding: 0;
    box-sizing: border-box;
}

/* ========== Giới hạn chiều rộng từng card, canh giữa trong ô grid ========== */
.att-card {
    width: 100%;
    max-width: 300px; /* giảm từ 520 -> 480, chỉnh theo ý */
    margin: 0 auto;
    box-sizing: border-box;
    border-radius: 10px;
}

/* ========== Phiên bản nhỏ hơn của card ========== */
.att-card--sm {
    --att-thumb-h: 68px;      /* index: giảm từ 96 -> 68 */
    --att-icon-size: 22px;    /* giảm từ 30 -> 22 */
    --att-pad-x: 8px;
    --att-pad-y: 6px;
}

/* Giảm padding / font để card trông nhẹ hơn */
.att-meta { padding: 6px var(--att-pad-x) 0; }
.att-title { font-size: 13px; font-weight: 600; line-height: 1.2; }
.att-sub { font-size: 11px; color: #6f7680; }
.att-uploader { font-size: 11px; color: #666; margin-top: 4px; }

/* Thu nhỏ các nút hành động */
.att-actions {
    display: flex;
    gap: 6px;
    padding: 6px var(--att-pad-x) 8px;
    justify-content: flex-end;
}
.att-actions :deep(.ant-btn) {
    width: 22px;
    height: 22px;
    padding: 0;
    font-size: 12px;
}

/* Thu nhỏ pill/status */
.att-approval { font-size: 10px; gap: 6px; margin-top: 6px; }
.att-approval-pill { padding: 0 6px; font-size: 11px; }

/* Badge ext */
.att-ext { top: 6px; right: 6px; font-size: 10px; }

/* Thumbs: đảm bảo thumb không quá cao */
.att-icon-wrap, .att-link-thumb, .a-image {
    height: var(--att-thumb-h);
    max-height: var(--att-thumb-h);
    overflow: hidden;
}

/* ========== Media queries: mobile / tablet ========== */
@media (max-width: 920px) {
    .att-list { grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 12px; }
    .att-card { max-width: 100%; }
    .att-card--sm { --att-thumb-h: 60px; --att-icon-size: 20px; }
}

@media (max-width: 600px) {
    .att-list { grid-template-columns: 1fr; padding: 6px; gap: 10px; }
    .att-card--sm { --att-thumb-h: 56px; --att-icon-size: 18px; --att-pad-x: 6px; }
    .att-title { font-size: 13px; }
    .att-sub, .att-uploader { font-size: 11px; }
}

</style>
