<template>
    <a-card :bordered="false" class="inbox-files-card">
        <!-- PAGE HEADER -->
        <a-page-header
            :ghost="false"
            title="Danh sách văn bản cần duyệt / ký"
            sub-title="Các tài liệu bạn cần xem xét, ký hoặc phê duyệt"
            class="page-header"
        />

        <!-- Toolbar -->
        <div class="toolbar">
            <div class="toolbar-left">
                <a-input-search
                    v-model:value="keyword"
                    :placeholder="'Tìm theo tên tệp, người gửi…'"
                    allow-clear
                    @search="onSearch"
                    class="search-input"
                >
                    <template #enterButton>
                        <a-button type="primary" class="search-btn">
                            <template #icon>
                                <SearchOutlined />
                            </template>
                            Tìm
                        </a-button>
                    </template>
                </a-input-search>

                <a-space class="toolbar-actions">
                    <a-button @click="fetchData" :loading="loading" class="btn-ghost">
                        <template #icon>
                            <ReloadOutlined />
                        </template>
                        Làm mới
                    </a-button>
                </a-space>
            </div>

            <div class="toolbar-right">
                <div class="stats" v-if="total">
                    <span class="stat-number">{{ total }}</span>
                    <span class="stat-label">tài liệu</span>
                </div>
            </div>
        </div>

        <!-- List -->
        <a-list
            :loading="loading"
            :data-source="paged"
            :locale="{ emptyText: 'Không có tài liệu nào cần bạn duyệt.' }"
            item-layout="horizontal"
            :pagination="paginationCfg"
            class="files-list"
        >
            <template #renderItem="{ item }">
                <a-list-item :key="item.approval_id" class="list-item">
                    <a-card class="file-card" :hoverable="true">
                        <div class="file-row">
                            <div class="file-thumb">
                                <component :is="item.icon" class="thumb-icon" v-if="item.kind !== 'image'" />
                                <a-image v-else :src="item.url" :height="64" />
                            </div>

                            <div class="file-meta">
                                <div class="file-title" :title="item.title || item.name">
                                    {{ item.title || item.name }}
                                </div>

                                <div class="file-sub">
                                    <UserOutlined />
                                    <span class="uploader">{{ item.uploader_name || '—' }}</span>
                                    <span class="dot">·</span>
                                    <span class="time">{{ formatDate(item.created_at) }}</span>
                                </div>

                                <div class="file-links" v-if="item.url">
                                    <a-button type="link" @click="openFile(item)" class="link-btn">
                                        <template #icon>
                                            <LinkOutlined />
                                        </template>
                                        Mở tài liệu
                                    </a-button>
                                </div>

                                <div class="file-status">
                                    <a-tag color="blue" class="step-tag">Bước #{{item.current_step_index || item.sequence || 1}}</a-tag>
                                    <a-tag :color="statusColor(item.status)" class="status-tag">{{ labelStatus(item.status) }}</a-tag>
                                </div>

                                <div class="steps-line" v-if="stepsOf(item).length">
                                    <span class="steps-label">Chuỗi ký:</span>
                                    <template v-for="(s, idx) in stepsOf(item)" :key="s.id || s.step_id || idx">
                                        <a-tag :class="pillClass(s)" class="step-pill">
                                            {{ s.approver_name || ('#' + (s.approver_id || s.id || idx)) }}
                                            <span class="att-approval-pill-status">({{ shortStepStatus(s) }})</span>
                                        </a-tag>
                                    </template>
                                </div>
                            </div>

                            <div class="file-actions">
                                <a-tooltip title="Xem trước">
                                    <a-button size="large" shape="circle" @click="openFile(item)">
                                        <EyeOutlined />
                                    </a-button>
                                </a-tooltip>

                                <a-tooltip title="Tải / mở">
                                    <a-button size="large" shape="circle" @click="download(item)">
                                        <DownloadOutlined />
                                    </a-button>
                                </a-tooltip>

                                <a-tooltip v-if="item.kind === 'pdf' && mySignatureUrl" title="Ký tài liệu">
                                    <a-button size="large" shape="circle" type="dashed" @click="openSign(item)">
                                        <img :src="'/pen-icon.svg'" class="icon-pen" alt="pen" />
                                    </a-button>
                                </a-tooltip>

                                <a-tooltip title="Xóa tài liệu">
                                    <a-button
                                        size="large"
                                        shape="circle"
                                        type="dashed"
                                        :loading="deleting[itemKey(item)]"
                                        @click="onClickDelete(item)"
                                    >
                                        <DeleteOutlined />
                                    </a-button>
                                </a-tooltip>
                            </div>
                        </div>
                    </a-card>
                </a-list-item>
            </template>
        </a-list>

        <!-- Modal ký PDF -->
        <SignPdfModal
            v-if="signOpen && signTarget?.pdfUrl"
            v-model:open="signOpen"
            :pdf-url="signTarget.pdfUrl"
            :signature-url="mySignatureUrl"
            :sign-target="signTarget"
            @done="handleSignedBlob"
        />
    </a-card>
</template>

<script setup>
// (Script nội dung giữ nguyên logic như file gốc của bạn)
import {computed, onMounted, reactive, ref} from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'
import {
    DeleteOutlined,
    DownloadOutlined,
    EyeOutlined,
    FileExcelOutlined,
    FilePdfOutlined,
    FilePptOutlined,
    FileTextOutlined,
    FileWordOutlined,
    ReloadOutlined,
    SearchOutlined,
    UserOutlined,
    LinkOutlined
} from '@ant-design/icons-vue'
import {message, Modal} from 'ant-design-vue'

// 📦 API
import {deleteDocumentAPI, getMyApprovalInboxFiles, uploadSignedPdf} from '@/api/document'
import {deleteCommentAPI, deleteTaskFile as deleteTaskFileAPI} from '@/api/taskFiles'
import {approveDocumentApproval, getApprovalDetail} from '@/api/approvals'


// 🖋 Modal ký PDF
import SignPdfModal from '../components/SignPdfModal.vue'
import {checkSession} from "@/api/auth.js";

dayjs.locale('vi')

/* ---------------- state ---------------- */
const loading = ref(false)
const rows = ref([])
const keyword = ref('')
const current = ref(1)
const pageSize = ref(10)

/* ---------------- ký file ---------------- */
const signOpen = ref(false)
const signTarget = ref(null)
const mySignatureUrl = ref('')
const { confirm } = Modal
const deleting = reactive({}) // map: key -> boolean


async function fetchSignature() {
    try {
        const res = await checkSession()
        const user = res.data?.user || res.data || {}
        mySignatureUrl.value = user.signature_url || ''
        console.log('✅ Signature URL:', mySignatureUrl.value)
    } catch (e) {
        console.error('Lỗi khi lấy signature_url:', e)
    }
}

async function openSign(item) {
    // item đã qua shaped: có url nếu có file_path
    const fallbackUrl = item?.url || item?.file_path
    if (!fallbackUrl) {
        return message.warning('Không có file PDF để ký.')
    }

    try {
        const res = await getApprovalDetail(item.approval_id)
        const {approval, document, steps} = res.data || {}

        const pdfUrl =
            document?.signed_pdf_url ||   // ✅ nếu phiên đã ký 1 lần
            document?.file_path ||
            fallbackUrl
        if (!pdfUrl) {
            return message.error('Không tìm thấy đường dẫn file để ký.')
        }

        signTarget.value = {
            ...item,
            approval,
            steps: steps || [],
            pdfUrl,              // 👈 modal dùng trường này
        }

        signOpen.value = true
    } catch (e) {
        console.error(e)
        message.error(
            e?.response?.data?.message ||
            'Không tải được thông tin phiên duyệt.'
        )
    }
}

async function handleSignedBlob(blobOrUrl) {
    const it = signTarget.value;
    if (!it?.approval_id) return;

    try {
        // --- normalize incoming blob/url ---
        let fileBlob = null;

        // case: nothing passed
        if (!blobOrUrl) {
            console.warn('handleSignedBlob: no blob received', blobOrUrl);
            return message.error('Không có file đã ký để tải lên.');
        }

        // case: already a Blob or File
        if (blobOrUrl instanceof Blob || (typeof File !== 'undefined' && blobOrUrl instanceof File)) {
            fileBlob = blobOrUrl;
        } else if (typeof blobOrUrl === 'string') {
            // likely an objectURL or remote URL: fetch it
            try {
                const resp = await fetch(blobOrUrl);
                if (!resp.ok) throw new Error('Không tải được URL của file đã ký.');
                fileBlob = await resp.blob();
            } catch (e) {
                console.error('Không fetch được URL thành Blob:', e);
                return message.error('Không tải được file đã ký từ URL.');
            }
        } else if (typeof blobOrUrl === 'object' && blobOrUrl.data) {
            // defensive: maybe caller sent { data: ArrayBuffer } etc.
            try {
                fileBlob = new Blob([blobOrUrl.data], { type: 'application/pdf' });
            } catch (e) { /* fallthrough */ }
        }

        if (!fileBlob || !(fileBlob instanceof Blob)) {
            console.warn('handleSignedBlob: invalid blob', blobOrUrl);
            return message.error('Dữ liệu chữ ký không hợp lệ (không phải file).');
        }

        // prepare formdata
        const form = new FormData();
        // filename: ưu tiên tên nguồn, fallback sang signed.pdf
        const filename = it.name || it.title || 'signed.pdf';
        form.append('file', fileBlob, filename);
        form.append('approval_id', it.approval_id);

        await uploadSignedPdf(form);
        await approveDocumentApproval(it.approval_id);

        message.success('Đã ký và duyệt thành công.');
        await fetchData();
    } catch (e) {
        console.error('Upload signed PDF error:', e);
        message.error(e?.response?.data?.message || 'Lỗi khi ký hoặc duyệt.');
    }
}



/* ---------------- helpers ---------------- */
const IMAGE = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const WORD = new Set(['doc', 'docx'])
const EXCEL = new Set(['xls', 'xlsx', 'csv'])
const PPT = new Set(['ppt', 'pptx'])
const PDF = new Set(['pdf'])

const extOf = (name = '') => {
    const base = String(name).split('?')[0]
    const i = base.lastIndexOf('.')
    return i >= 0 ? base.slice(i + 1).toLowerCase() : ''
}
const detectKind = (obj = {}) => {
    const src = obj.url || obj.name || obj.title || ''
    const e = extOf(src)
    if (IMAGE.has(e)) return 'image'
    if (PDF.has(e)) return 'pdf'
    if (WORD.has(e)) return 'word'
    if (EXCEL.has(e)) return 'excel'
    if (PPT.has(e)) return 'ppt'
    return 'other'
}
const pickIcon = (kind) => ({
    pdf: FilePdfOutlined, word: FileWordOutlined, excel: FileExcelOutlined, ppt: FilePptOutlined
}[kind] || FileTextOutlined)

const formatDate = (dt) => dt ? dayjs(dt).format('HH:mm DD/MM/YYYY') : '—'
const labelStatus = (s) => {
    s = String(s || '').toLowerCase()
    if (s === 'pending') return 'Chờ duyệt'
    if (s === 'approved') return 'Đã duyệt'
    if (s === 'rejected') return 'Từ chối'
    return s || '—'
}
const statusColor = (s) => {
    s = String(s || '').toLowerCase()
    if (s === 'pending') return 'gold'
    if (s === 'approved') return 'green'
    if (s === 'rejected') return 'red'
    return 'default'
}

/* ---------------- data shaping ---------------- */
const shaped = computed(() =>
    (rows.value || []).map(r => {
        const url =
            r.signed_pdf_url ||   // ✅ nếu đã ký thì dùng bản ký
            r.file_path ||
            r.url || ''
        const kind = detectKind({url})

        return {
            ...r,
            url,            // 👈 từ giờ dùng url chung
            kind,
            icon: pickIcon(kind),
        }
    })
)


const filtered = computed(() => {
    const k = keyword.value.trim().toLowerCase()
    if (!k) return shaped.value
    return shaped.value.filter(it =>
        (it.title || '').toLowerCase().includes(k) ||
        (it.uploader_name || '').toLowerCase().includes(k)
        (it.uploader_name || '').toLowerCase().includes(k)
    )
})
const total = computed(() => filtered.value.length)
const paged = computed(() => {
    const start = (current.value - 1) * pageSize.value
    return filtered.value.slice(start, start + pageSize.value)
})
const paginationCfg = computed(() => ({
    current: current.value,
    pageSize: pageSize.value,
    total: total.value,
    showTotal: t => `Tổng ${t} mục`,
    showSizeChanger: true,
    pageSizeOptions: ['5', '10', '20', '50'],
    onChange: (p, ps) => {
        current.value = p;
        pageSize.value = ps
    }
}))
const onSearch = () => {
    current.value = 1
}

/* ---------------- actions ---------------- */
function openFile(it) {
    if (!it.url) return
    window.open(it.url, '_blank', 'noopener')
}

function download(it) {
    if (!it.url) return
    window.open(it.url, '_blank', 'noopener')
}

/* ---------------- fetch ---------------- */
async function fetchData() {
    loading.value = true;
    try {
        const res = await getMyApprovalInboxFiles();
        const payload = res.data ?? {};

        // modern API: { items: [ { approval: {...}, document: {...}, steps: [...] }, ... ] }
        const items = payload.items ?? payload.data ?? payload?.rows ?? [];

        // If items already contain approval/document/steps, use them directly.
        rows.value = items.map(it => {
            // normalize shape — keep FE expectations from previous shaped computed
            // possible keys: approval, document, steps OR approval_id, document_id, title, file_path, ...
            if (it.approval || it.document || Array.isArray(it.steps)) {
                return {
                    ...it,
                    // keep older keys for backwards compatibility
                    approval_id: it.approval?.id ?? it.approval_id ?? it.approval_id,
                    document_id: it.document?.id ?? it.document_id ?? it.document_id,
                    title: it.document?.title ?? it.title ?? it.name ?? null,
                    file_path: it.document?.file_path ?? it.file_path ?? it.url ?? null,
                }
            }

            // fallback: return raw item (FE will still render basic fields)
            return it;
        });
        current.value = 1;
    } catch (e) {
        console.error('fetchData error', e);
        message.error(e?.response?.data?.message || 'Không tải được danh sách cần duyệt.');
    } finally {
        loading.value = false;
    }
}


// async function fetchData() {
//     loading.value = true
//     try {
//         const { data } = await getMyApprovalInboxFiles()
//         const baseItems = data?.items ?? data?.data ?? []
//
//         rows.value = baseItems
//         current.value = 1
//
//     } catch (e) {
//         console.error(e)
//         message.error(e?.response?.data?.message || 'Không tải được danh sách cần duyệt.')
//     } finally {
//         loading.value = false
//     }
// }

const stepStatusLabel = (step) => {
    const s = String(step.status || step.step_status || '').toLowerCase()

    if (step.is_approved || s === 'approved') return 'Đã ký'
    if (step.is_rejected || s === 'rejected') return 'Từ chối'
    if (step.is_current || s === 'active')   return 'Đang chờ bạn ký'
    if (s === 'waiting')                     return 'Chờ ký'
    return 'Chưa ký'
}

const stepStatusColor = (step) => {
    const s = String(step.status || step.step_status || '').toLowerCase()

    if (step.is_rejected || s === 'rejected') return 'red'
    if (step.is_approved || s === 'approved') return 'green'
    if (step.is_current || s === 'active')    return 'blue'
    if (s === 'waiting')                      return 'gold'
    return 'default'
}


// Lấy danh sách bước ký cho 1 item
function stepsOf(item) {
    if (!item) return []
    return Array.isArray(item.steps) ? item.steps : []
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

/* ----- helper key (unique per item) ----- */
function itemKey(it) {
    // ưu tiên task_file_id / approval_id / id / url
    return String(it.task_file_id || it.approval_id || it.id || (it.url || it.file_path) || Math.random())
}

/* ----- hàm xoá chung ----- */
async function onClickDelete(item) {
    const key = itemKey(item);

    confirm({
        title: 'Xác nhận xóa',
        content: 'Bạn có chắc chắn muốn xóa tài liệu này?',
        okText: 'Xóa',
        okType: 'danger',
        cancelText: 'Hủy',
        async onOk() {
            deleting[key] = true;
            try {
                // chọn id ưu tiên: document_id / id / approval_id / task_file_id
                const rawId = item.id ?? item.document_id ?? item.approval_id ?? item.task_file_id;
                const id = Number(rawId);
                console.log('Deleting item rawId=', rawId, '-> id=', id, 'item=', item);

                if (!Number.isFinite(id) || id <= 0) {
                    message.error('Thiếu id hợp lệ để xóa.');
                    return;
                }

                if (item.source === 'document' || item._source === 'document') {
                    await deleteDocumentAPI(id); // wrapper axios của bạn
                } else if (item.task_file_id) {
                    await deleteTaskFileAPI(Number(item.task_file_id));
                } else if (item.source === 'comment' || item._source === 'comment') {
                    await deleteCommentAPI(id); // nếu bạn thêm API này
                } else {
                    // fallback: thử document delete
                    await deleteDocumentAPI(id);
                }

                message.success('Đã xóa tài liệu.');
                await fetchData();
            } catch (e) {
                console.error('delete error', e);
                const msg = e?.response?.data?.message || e?.message || 'Không thể xóa tài liệu.';
                message.error(msg);
            } finally {
                deleting[key] = false;
            }
        }
    });
}



onMounted(() => {
    fetchSignature()
    fetchData()
})
</script>

<style scoped>
/* Container */
.inbox-files-card {
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 6px 18px rgba(15, 23, 42, 0.06);
}

.page-header {
    margin-bottom: 18px;
    border-radius: 8px;
    padding-left: 0;
    padding-top: 0;
}

/* Toolbar */
.toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-bottom: 14px;
    flex-wrap: wrap;
}

.toolbar-left {
    display: flex;
    gap: 12px;
    align-items: center;
}

.search-input {
    min-width: 320px;
    max-width: 520px;
}

.search-btn {
    height: 32px;
}

.toolbar-actions .btn-ghost {
    height: 32px;
}

.toolbar-right .stats {
    display: flex;
    align-items: baseline;
    gap: 6px;
    color: #445;
}
.stat-number {
    font-weight: 700;
    font-size: 16px;
}
.stat-label {
    color: #7a869a;
    font-size: 13px;
}

/* List */
.files-list {
    width: 100%;
}
.list-item {
    padding: 0;
}

.file-card {
    width: 100%;
    border-radius: 10px;
}

.file-row {
    display: grid;
    grid-template-columns: 76px 1fr auto;
    gap: 16px;
    align-items: center;
}

.file-thumb {
    width: 76px;
    height: 76px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(180deg, #fbfdff 0%, #f7f9fb 100%);
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 1px 0 rgba(16,24,40,0.04) inset;
}

.thumb-icon {
    font-size: 30px;
    opacity: .9;
}

.file-meta {
    min-width: 0;
}

.file-title {
    font-weight: 600;
    font-size: 15px;
    color: #0f1724;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.file-sub {
    margin-top: 6px;
    color: #6b7280;
    font-size: 13px;
    display: flex;
    gap: 8px;
    align-items: center;
}
.file-sub .uploader { font-weight: 500 }
.file-sub .dot { color: #cbd5e1 }

.file-links {
    margin-top: 8px;
}

.file-status {
    margin-top: 10px;
    display: flex;
    gap: 8px;
    align-items: center;
    flex-wrap: wrap;
}

.step-tag, .status-tag {
    font-size: 12px;
    padding: 0 8px;
    height: 26px;
    display: inline-flex;
    align-items: center;
}

.steps-line {
    margin-top: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
}
.steps-label {
    color: #8892a6;
    font-size: 12px;
}
.step-pill {
    font-size: 11px;
    padding: 0 8px;
    border-radius: 14px;
    line-height: 20px;
}
.att-approval-pill-status { margin-left: 6px; color: #6b7280; font-weight: 500 }

/* Action buttons */
.file-actions {
    display: flex;
    gap: 8px;
    align-items: center;
}
.icon-pen {
    width: 18px;
    height: 18px;
}

/* pill colors */
.att-approval-pill--approved {
    background: #f6ffed;
    color: #389e0d;
    border: 1px solid #bae7bd;
}
.att-approval-pill--pending {
    background: #fffbe6;
    color: #d48806;
    border: 1px solid #ffe58f;
}
.att-approval-pill--rejected {
    background: #fff1f0;
    color: #a61d24;
    border: 1px solid #ffccc7;
}
.att-approval-pill--idle {
    background: #fbfbfb;
    color: #6b7280;
    border: 1px solid #e6eaf0;
}
ul.ant-list-items li {
    margin-bottom: 10px;
}
.ant-card-body {
    padding-top: 0 !important;
}
/* Responsive tweaks */
@media (max-width: 880px) {
    .file-row {
        grid-template-columns: 64px 1fr;
    }
    .file-actions { margin-top: 8px }
}

@media (max-width: 520px) {
    .search-input { min-width: 180px }
    .file-row { grid-template-columns: 56px 1fr }
    .file-thumb { width: 56px; height: 56px }
    .file-title { font-size: 14px }
}
</style>
