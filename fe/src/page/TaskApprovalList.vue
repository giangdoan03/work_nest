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
                    placeholder="Tìm theo tên tệp, người gửi…"
                    allow-clear
                    @search="onSearch"
                    class="search-input"
                >
                    <template #enterButton>
                        <a-button type="primary" class="search-btn">
                            <template #icon><SearchOutlined /></template>
                            Tìm
                        </a-button>
                    </template>
                </a-input-search>

                <a-space class="toolbar-actions">
                    <a-button @click="fetchData" :loading="loading" class="btn-ghost">
                        <template #icon><ReloadOutlined /></template>
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
                <a-list-item :key="itemKey(item)" class="list-item">
                    <a-card class="file-card" :hoverable="true">
                        <!-- ⭐ TAG ở góc phải -->
                        <div class="doc-type-tag" v-if="item.doc_type">
                            <a-tag :class="item.doc_type === 'internal' ? 'tag-internal-gradient' : 'tag-external-gradient'">
                                {{ item.doc_type === 'internal' ? 'Nội bộ' : 'Phát hành' }}
                            </a-tag>
                        </div>

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
                                <!-- ⭐ CONTEXT TASK -->
                                <div class="file-task" v-if="item.task">
                                    <FolderOutlined class="task-icon" />

                                    <span class="task-title" :title="item.task.title">
                                        {{ item.task.title }}
                                    </span>
                                    <template v-if="item.linked">
                                        <span class="task-sep">·</span>
                                        <span class="linked-type">
                                            {{ linkedTypeLabel(item.linked.type) }}:
                                        </span>
                                        <span class="linked-name" :title="item.linked.name">
                                            {{ item.linked.name }}
                                        </span>
                                    </template>

                                    <!-- ✅ STEP -->
                                    <div class="linked-step" v-if="item.linked?.step">
                                        ↳ Bước {{ item.linked.step.number }}:
                                        <span class="step-title" :title="item.linked.step.title">
                                            {{ item.linked.step.title }}
                                        </span>
                                    </div>
                                </div>

                                <div class="file-status">
                                    <a-tag color="blue" class="step-tag">
                                        Bước #{{ item.sequence || 1 }}
                                    </a-tag>

                                    <a-tag :color="statusColor(item.status)" class="status-tag">
                                        {{ labelStatus(item.status) }}
                                    </a-tag>

                                </div>

                                <div class="steps-line" v-if="stepsOf(item).length">
                                    <span class="steps-label">Chuỗi ký:</span>
                                    <template v-for="(s, idx) in stepsOf(item)" :key="s.id || s.step_id || idx">
                                        <a-tag :class="[  pillClass(s), { skipped: s.status === 'skipped' && !isVisuallyCompleted(s, stepsOf(item)), 'auto-signed': isVisuallyCompleted(s, stepsOf(item))} ]" :color="isVisuallyCompleted(s, stepsOf(item)) ? 'green' : undefined">
                                        {{ s.approver_name }}
                                            <span>
                                                ({{ displayStepStatus(s, stepsOf(item)) }})
                                            </span>
                                        </a-tag>
                                    </template>
                                </div>
                            </div>

                            <div class="file-actions">
                                <a-tooltip :title="mySignatureUrl ? signTooltip(item) : 'Bạn chưa tải chữ ký số'">
                                    <a-button
                                        size="large"
                                        shape="circle"
                                        type="dashed"
                                        @click="openSign(item)"
                                    >
                                        <EyeOutlined />
                                    </a-button>
                                </a-tooltip>
                                <a-tooltip :title="approveTooltip(item)">
                                    <a-button
                                        size="large"
                                        shape="circle"
                                        type="dashed"
                                        :disabled="!canApprove(item)"
                                        @click="openApprove(item)"
                                    >
                                        <CheckCircleOutlined />
                                    </a-button>
                                </a-tooltip>

                                <a-tooltip :title="signButtonTooltip(item)">
                                    <a-button
                                        :class="{ 'btn-signed': isSigned(item) }"
                                        size="large"
                                        shape="circle"
                                        type="dashed"
                                        :loading="signing[itemKey(item)]"
                                        :disabled="isSignedByMe(item) || !canSign(item)"
                                        @click="onClickSign(item)"
                                    >
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
            :parent-loading="loading"
            @done="handleSignedBlob"
            @refresh="fetchData"
        />
    </a-card>
</template>

<script setup>
import {computed, onMounted, reactive, ref} from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'
import {
    DeleteOutlined,
    EyeOutlined,
    FileExcelOutlined,
    FilePdfOutlined,
    FilePptOutlined,
    FileTextOutlined,
    FileWordOutlined,
    ReloadOutlined,
    SearchOutlined,
    UserOutlined,
    CheckCircleOutlined,
    FolderOutlined
} from '@ant-design/icons-vue'
import {message, Modal} from 'ant-design-vue'

import SignPdfModal from '../components/SignPdfModal.vue'
import {checkSession} from '@/api/auth.js'
import {approveExternalDocument, uploadSignedPdf} from '@/api/document'

import {deleteSignStep, getMySignInbox, getDocumentSignDetail, signDocument} from '@/api/documentSign'

dayjs.locale('vi')

/* ---------- reactive state ---------- */
const loading = ref(false)
const rows = ref([])
const keyword = ref('')
const current = ref(1)
const pageSize = ref(10)

/* signing state */
const signOpen = ref(false)
const signTarget = ref(null)
const mySignatureUrl = ref('')
const isAdmin = ref(false)
const isSuper = ref(false)
const currentUserId = ref(null)
const currentUserName = ref('')
const deleting = reactive({})

const { confirm } = Modal

/* ---------- helpers ---------- */
const IMAGE = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const WORD = new Set(['doc', 'docx'])
const EXCEL = new Set(['xls', 'xlsx', 'csv'])
const PPT = new Set(['ppt', 'pptx'])
const PDF = new Set(['pdf'])

async function openApprove(item) {
    confirm({
        title: 'Xác nhận duyệt',
        content: 'Bạn chắc chắn muốn duyệt văn bản này?',
        okText: 'Duyệt',
        cancelText: 'Hủy',
        async onOk() {
            try {
                const payload = {
                    task_file_id: item.task_file_id || item.id,
                    document_id: item.converted_id,
                    signed_by: currentUserId.value,
                    signed_at: new Date().toISOString(),
                    status: 'signed',
                    note: `Duyệt bởi ${currentUserName.value}`,
                    signed_file_name: item.title || item.name || null,
                    signed_file_path: item.signed_url || item.url || item.original_url || null,
                    signed_file_size: item.file_size || null,
                    signed_mime: 'application/pdf',
                    approver_display: currentUserName.value
                }


                await approveExternalDocument(payload)

                message.success('Đã lưu thông tin duyệt.')

                // cập nhật UI nhẹ (KHÔNG đụng PDF)
                item.status = 'approved'

                // optional: reload list cho chắc
                await fetchData()

            } catch (e) {
                const msg = e?.response?.data?.message || 'Duyệt thất bại.'
                message.error(msg)
            }
        }
    })
}


function isSigned(item) {
    return String(item?.status).toLowerCase() === 'signed'
}

function isSignedByMe(item) {
    if (!Array.isArray(item?.steps) || !currentUserId.value) return false

    return item.steps.some(
        s =>
            Number(s.approver_id) === Number(currentUserId.value) &&
            String(s.status).toLowerCase() === 'signed'
    )
}

function signButtonTooltip(item) {
    if (isSignedByMe(item)) {
        return 'Bạn đã ký tài liệu này'
    }

    if (String(item?.status).toLowerCase() === 'signed') {
        return 'Tài liệu đã được ký'
    }

    if (canSign(item)) {
        return 'Ký tài liệu'
    }

    return 'Chưa tới lượt bạn ký'
}



const signing = reactive({})
async function onClickSign(item) {
    if (!item?.converted_id) {
        return message.error('Thiếu converted_id.')
    }

    confirm({
        title: 'Xác nhận ký',
        content: 'Bạn chắc chắn muốn ký tài liệu này?',
        okText: 'Ký',
        cancelText: 'Hủy',
        async onOk() {
            const key = itemKey(item)
            signing[key] = true

            try {
                // 🟢 GỌI API KÝ – CHỈ UPDATE DB
                const res = await signDocument({
                    converted_id: item.converted_id,
                    signature_url: mySignatureUrl.value || null,
                    comment: null
                })

                const data = res.data || {}

                message.success('Đã ký tài liệu.')

                // 🟢 Update UI local
                item.status = 'signed'
                item.signed_url = data.signed_pdf_url || data.signed_url || null

                // 🟢 update đúng step hiện tại
                const step = item.steps?.find(
                    s =>
                        Number(s.approver_id) === Number(currentUserId.value) &&
                        String(s.status).toLowerCase() === 'pending'
                )
                if (step) {
                    step.status = 'signed'
                    step.is_current = false
                    step.signed_at = new Date().toISOString()
                }

                // 🟢 reload lại list cho chắc
                await fetchData()

            } catch (e) {
                console.error('signDocument error', e)
                message.error(e?.response?.data?.message || 'Ký thất bại.')
            } finally {
                signing[key] = false
            }
        }
    })
}


function canApprove(item) {
    const docType = String(item.doc_type || '').toLowerCase()

    // ❌ chỉ duyệt văn bản phát hành
    if (docType !== 'external') return false

    // ❌ đã duyệt thì không duyệt lại
    if (String(item.status).toLowerCase() === 'approved') return false

    const cur = findCurrentStep(item)
    if (!cur) return false

    return Number(cur.approver_id) === Number(currentUserId.value)
}


function approveTooltip(item) {
    if (String(item.doc_type).toLowerCase() !== 'external')
        return 'Chỉ áp dụng cho văn bản phát hành'

    if (String(item.status).toLowerCase() === 'approved')
        return 'Văn bản đã được duyệt'

    return 'Phê duyệt văn bản'
}


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
    if (s === 'signed' || s === 'approved') return 'Đã duyệt'
    if (s === 'rejected') return 'Từ chối'
    return s || '—'
}
const statusColor = (s) => {
    s = String(s || '').toLowerCase()
    if (s === 'pending' || s === 'waiting') return 'gold'
    if (s === 'signed' || s === 'approved') return 'green'
    if (s === 'rejected') return 'red'
    return 'default'
}


function highestSignedSequence(steps = []) {
    return Math.max(
        0,
        ...steps
            .filter(s => String(s.status).toLowerCase() === 'signed')
            .map(s => Number(s.sequence || 0))
    )
}

function isVisuallyCompleted(step, steps = []) {
    const maxSignedSeq = highestSignedSequence(steps)

    // ký thật
    if (String(step.status).toLowerCase() === 'signed') return true

    // bị override bởi người cấp cao hơn
    return (
        maxSignedSeq > 0 &&
        Number(step.sequence) > maxSignedSeq
    )
}

function displayStepStatus(step, steps = []) {
    if (String(step.status).toLowerCase() === 'signed') return 'đã ký'

    if (isVisuallyCompleted(step, steps))
        return 'hoàn tất'

    if (step.status === 'pending') return 'đang chờ'
    if (step.status === 'waiting') return 'chờ ký'

    return 'chưa ký'
}

function stepsOf(item) { return Array.isArray(item.steps) ? item.steps : [] }

function findCurrentStep(item) {
    const s = stepsOf(item).find(
        st => st.is_current || String(st.status).toLowerCase() === 'pending'
    )
    return s || null
}

function canSign(item) {
    if (!item?.steps || !currentUserId.value) return false

    const myStep = item.steps.find(
        s => Number(s.approver_id) === Number(currentUserId.value)
    )
    if (!myStep) return false
    if (myStep.status === 'skipped') return false

    // ✅ TH1: tới lượt bình thường
    if (myStep.status === 'pending') return true

    // ✅ TH2: override – tôi là người có sequence LỚN NHẤT
    const maxSeq = Math.max(...item.steps.map(s => Number(s.sequence || 0)))

    if (
        Number(myStep.sequence) === maxSeq &&
        myStep.status !== 'signed'
    ) {
        return true
    }

    return false
}





function signTooltip(item) {
    if (hasSigned(item)) return 'Bạn đã ký – bấm để xem lại'
    if (canSignNow(item)) return 'Xem và ký tài liệu'

    const cur = findCurrentStep(item)
    if (!cur) return 'Không có bước hiện tại'

    return `Chưa tới lượt: Bước #${cur.sequence} — ${cur.approver_name || 'người duyệt'}`
}


/* step helpers */
const stepStatusLabel = (step) => {
    const s = String(step.status || step.step_status || '').toLowerCase()
    if (step.is_approved || s === 'signed' || s === 'approved') return 'Đã ký'
    if (step.is_rejected || s === 'rejected') return 'Từ chối'
    if (step.is_current || s === 'pending' || s === 'active') return 'Đang chờ bạn ký'
    if (s === 'waiting') return 'Chờ ký'
    return 'Chưa ký'
}
const stepStatusColor = (step) => {
    const s = String(step.status || step.step_status || '').toLowerCase()
    if (step.is_rejected || s === 'rejected') return 'red'
    if (step.is_approved || s === 'signed' || s === 'approved') return 'green'
    if (step.is_current || s === 'pending' || s === 'active') return 'blue'
    if (s === 'waiting') return 'gold'
    return 'default'
}

function shortStepStatus(step) {
    const s = String(
        step.status ||
        (step.is_approved && 'approved') ||
        (step.is_rejected && 'rejected') ||
        (step.is_current && 'current') ||
        ''
    ).toLowerCase()
    if (s === 'approved' || s === 'signed') return 'đã ký'
    if (s === 'rejected') return 'từ chối'
    if (s === 'current' || s === 'pending') return 'đang chờ'
    if (s === 'waiting') return 'chờ ký'
    return 'chưa ký'
}
function pillClass(step) {
    const s = String(
        step.status ||
        (step.is_approved && 'approved') ||
        (step.is_rejected && 'rejected') ||
        (step.is_current && 'current') ||
        ''
    ).toLowerCase()
    if (s === 'approved' || s === 'signed') return 'att-approval-pill--approved'
    if (s === 'rejected') return 'att-approval-pill--rejected'
    if (s === 'current' || s === 'waiting' || s === 'pending') return 'att-approval-pill--pending'
    return 'att-approval-pill--idle'
}

/* stable unique key */
function itemKey(it) {
    return String(it.task_file_id || it.converted_id || it.id || (it.url || it.file_path) || Math.random())
}

/* ---------- shaping / filtering / pagination ---------- */
const shaped = computed(() => (rows.value || []).map(r => {
    const url = r.url || r.file_path || ''
    const kind = detectKind({ url })
    return {
        ...r,
        url,
        kind,
        icon: pickIcon(kind),
        title: r.title ?? r.name ?? null,
        uploader_name: r.uploader_name ?? null,
        created_at: r.created_at ?? null,
    }
}))

const filtered = computed(() => {
    const k = keyword.value.trim().toLowerCase()
    if (!k) return shaped.value
    return shaped.value.filter(it =>
        (it.title || '').toLowerCase().includes(k) ||
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
    onChange: (p, ps) => { current.value = p; pageSize.value = ps }
}))

const onSearch = () => { current.value = 1 }

/* ---------- API interactions ---------- */

async function fetchSignature() {
    try {
        const res = await checkSession()
        const user = res.data?.user ?? res.data ?? {}

        mySignatureUrl.value = user.signature_url || ''
        currentUserId.value = user.id ? Number(user.id) : null
        currentUserName.value =
            user.name || user.full_name || user.username || ''

    } catch (e) {
        console.error('fetchSignature error', e)
    }
}


async function fetchData() {
    loading.value = true
    try {
        const res = await getMySignInbox()
        const payload = res.data ?? {}
        rows.value = payload.items ?? payload.data ?? payload.rows ?? []
        current.value = 1
    } catch (e) {
        console.error('fetchData error', e)
        message.error(e?.response?.data?.message || 'Không tải được danh sách cần duyệt.')
    } finally {
        loading.value = false
    }
}

function hasSigned(item) {
    const steps = item.steps || []
    return steps.some(
        s =>
            String(s.approver_id) === String(currentUserId.value) &&
            s.status === 'signed'
    )
}

function canSignNow(item) {
    const cur = findCurrentStep(item)
    if (!cur) return false

    return (
        String(cur.approver_id) === String(currentUserId.value) &&
        cur.status === 'pending'
    )
}


/* ---------- sign flow (open modal + handle signed blob) ---------- */

async function openSign(item) {

    try {
        loading.value = true

        const res = await getDocumentSignDetail(item.converted_id)
        const detail = res.data || {}

        const signedSteps = (detail.steps || []).filter(
            s => s.status === 'signed' || s.is_approved
        )

        signTarget.value = {
            ...item,
            pdfUrl: hasSigned(item)
                ? (item.signed_url || item.url || item.original_url)
                : (item.url || item.file_path),

            steps: detail.steps || [],        // ⭐ RẤT QUAN TRỌNG
            signedSteps,                      // ⭐ cho chữ ký cũ
            doc_type: detail.document?.doc_type || item.doc_type,
            document: detail.document || item.document,
            status: detail.document?.status || item.status,
            readOnly: hasSigned(item),
            detail
        }

        signOpen.value = true

    } catch (e) {
        console.error('openSign error', e)
        message.error('Không lấy được thông tin chuỗi ký')
    } finally {
        loading.value = false
    }
}


function linkedTypeLabel(type) {
    switch (type) {
        case 'bidding':
            return 'Gói thầu'
        case 'contract':
            return 'Hợp đồng'
        default:
            return 'Liên kết'
    }
}


// Nhận blob từ modal, upload lên WP, rồi gọi API signDocument
async function handleSignedBlob(blobOrUrl) {
    const it = signTarget.value
    if (!it?.converted_id) {
        return message.error('Thiếu converted_id.')
    }

    try {
        // 1) Convert blob or URL thành Blob thật
        let fileBlob = null
        if (blobOrUrl instanceof Blob) {
            fileBlob = blobOrUrl
        } else if (typeof blobOrUrl === 'string') {
            const resp = await fetch(blobOrUrl)
            if (!resp.ok) throw new Error('Không tải được file đã ký.')
            fileBlob = await resp.blob()
        } else if (blobOrUrl?.data) {
            fileBlob = new Blob([blobOrUrl.data], { type: 'application/pdf' })
        }

        if (!fileBlob) {
            return message.error('Dữ liệu ký không hợp lệ.')
        }

        // 2) Upload file ký lên backend/WordPress
        const form = new FormData()
        const filename = it.title || it.name || 'signed.pdf'

        form.append('file', fileBlob, filename)
        form.append('converted_id', it.converted_id)

        if (mySignatureUrl.value)
            form.append('signature_url', mySignatureUrl.value)

        if (it.task_file_id)
            form.append('task_file_id', it.task_file_id)

        const res = await uploadSignedPdf(form)
        const data = res.data || {}
        const signedUrl = data.signed_url
        //****//
        if (!signedUrl) {
            return message.error('Server không trả về URL file đã ký.')
        }

        // 3) Update UI local
        message.success('Đã ký tài liệu.')

        signOpen.value = false

        if (signTarget.value) {
            signTarget.value.status = 'signed'

            // update đúng step
            const step = signTarget.value.steps?.find(
                s => s.approver_id === currentUserId && s.status === 'pending'
            )
            if (step) {
                step.status = 'signed'
                step.is_current = false
            }
        }

    } catch (e) {
        console.error('handleSignedBlob error', e)
        message.error(e?.response?.data?.message || e.message || 'Lỗi ký.')
    }
}


/* ---------- delete flow ---------- */
async function onClickDelete(item) {
    const key = itemKey(item)
    confirm({
        title: 'Xác nhận xóa',
        content: 'Bạn có chắc chắn muốn xóa bước ký này?',
        okText: 'Xóa',
        okType: 'danger',
        cancelText: 'Hủy',
        async onOk() {
            deleting[key] = true
            try {
                const id = Number(item.id)
                if (!Number.isFinite(id) || id <= 0) {
                    message.error('Thiếu id bước ký.')
                    return
                }

                // 🟢 API mới để xoá step ký
                await deleteSignStep(id)

                message.success('Đã xóa bước ký.')
                await fetchData()

            } catch (e) {
                console.error('delete error', e)
                message.error(e?.response?.data?.message || 'Không thể xóa bước ký.')
            } finally {
                deleting[key] = false
            }
        }
    })
}

/* ---------- lifecycle ---------- */
onMounted(() => {
    fetchSignature()
    fetchData()
})
</script>

<style scoped>
.inbox-files-card { border-radius: 12px; padding: 20px; box-shadow: 0 6px 18px rgba(15,23,42,0.06); }
.page-header { margin-bottom: 18px; border-radius: 8px; padding-left: 0; padding-top: 0; }
.toolbar { display:flex; justify-content:space-between; align-items:center; gap:12px; margin-bottom:14px; flex-wrap:wrap; }
.toolbar-left { display:flex; gap:12px; align-items:center }
.search-input { min-width:320px; max-width:520px }
.search-btn { height:32px }
.toolbar-actions .btn-ghost { height:32px }
.toolbar-right .stats { display:flex; align-items:baseline; gap:6px; color:#445 }
.stat-number { font-weight:700; font-size:16px }
.stat-label { color:#7a869a; font-size:13px }

.files-list { width:100% }
.list-item { padding:0 }
.file-card { width:100%; border-radius:10px }
.file-row { display:grid; grid-template-columns:76px 1fr auto; gap:16px }
.file-thumb { width:76px; height:76px; display:flex; align-items:center; justify-content:center; background:linear-gradient(180deg,#fbfdff 0%,#f7f9fb 100%); border-radius:10px; overflow:hidden; box-shadow:0 1px 0 rgba(16,24,40,0.04) inset; }
.thumb-icon { font-size:30px; opacity:.9 }
.file-meta { min-width:0 }
.file-title { font-weight:600; font-size:15px; color:#0f1724; white-space:nowrap; overflow:hidden; text-overflow:ellipsis }
.file-sub { margin-top:6px; color:#6b7280; font-size:13px; display:flex; gap:8px; align-items:center }
.file-sub .uploader { font-weight:500 }
.file-sub .dot { color:#cbd5e1 }
.file-links { margin-top:8px }
.file-status { margin-top:10px; display:flex; gap:8px; align-items:center; flex-wrap:wrap }
.step-tag, .status-tag { font-size:12px; padding:0 8px; height:26px; display:inline-flex; align-items:center }
.steps-line { margin-top:8px; display:flex; align-items:center; gap:8px; flex-wrap:wrap }
.steps-label { color:#8892a6; font-size:12px }
.step-pill { font-size:11px; padding:0 8px; border-radius:14px; line-height:20px }
.att-approval-pill-status { margin-left:6px; color:#6b7280; font-weight:500 }
.file-actions { display:flex; gap:8px; align-items:center }
.icon-pen { width:18px; height:18px }

.att-approval-pill--approved { background:#f6ffed; color:#389e0d; border:1px solid #bae7bd }
.att-approval-pill--pending { background:#fffbe6; color:#d48806; border:1px solid #ffe58f }
.att-approval-pill--rejected { background:#fff1f0; color:#a61d24; border:1px solid #ffccc7 }
.att-approval-pill--idle { background:#fbfbfb; color:#6b7280; border:1px solid #e6eaf0 }

ul.ant-list-items li { margin-bottom:10px }
.ant-card-body { padding-top:0 !important }
.file-card {
    position: relative;
}

.doc-type-tag {
    position: absolute;
    top: 20px;
    right: 20px;
    z-index: 10;
    pointer-events: none; /* để click không bị cản */
}

.doc-type-tag .ant-tag {
    font-size: 11px;
    padding: 2px 8px;
    border-radius: 6px;
}

.tag-internal-gradient {
    background: linear-gradient(135deg, #4e8ef6, #6bb9ff);
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 600;
}

.tag-external-gradient {
    background: linear-gradient(135deg, #00c98d, #4be2a7);
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 600;
}

.btn-signed {
    background: #f5f5f5;
    color: #999;
    cursor: not-allowed;
}
.file-task {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px;
    font-size: 14px;
}

.task-icon {
    font-size: 15px;
}

.task-title {
    font-weight: 600;
    color: #262626;
}

.task-sep {
    color: #bfbfbf;
}

.linked-type {
    color: #8c8c8c;
    font-size: 13px;
}

.linked-name {
    color: #262626;
    font-weight: 500;
    max-width: 280px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.linked-step {
    width: 100%;
    margin-left: 22px;
    font-size: 13px;
    color: #595959;
}

.step-title {
    font-style: italic;
    color: #434343;
}

.task-icon {
    font-size: 15px;
    color: #003b6d;
    margin-right: 2px;
}
.step-pill.skipped {
    opacity: 0.4;
    text-decoration: line-through;
}
.step-pill.auto-signed {
    background: #f6ffed;
    border: 1px solid #b7eb8f;
    color: #237804;
    font-weight: 500;
}

@media (max-width:880px) {
    .file-row { grid-template-columns:64px 1fr }
    .file-actions { margin-top:8px }
}
@media (max-width:520px) {
    .search-input { min-width:180px }
    .file-row { grid-template-columns:56px 1fr }
    .file-thumb { width:56px; height:56px }
    .file-title { font-size:14px }
}
</style>
