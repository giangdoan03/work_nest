<template>
    <a-card bordered class="doc-section">
        <div class="doc-header">
            <div class="doc-header-title">Danh sách tài liệu</div>
            <a-tooltip title="Tải lại danh sách tài liệu">
                <a-button
                    type="text"
                    size="small"
                    class="refresh-btn"
                    @click="refresh"
                >
                    <ReloadOutlined
                        class="refresh-icon"
                        :class="{ 'is-rotating': loading }"
                    />
                </a-button>
            </a-tooltip>
        </div>
        <a-spin :spinning="loading" tip="Đang tải tài liệu...">

            <a-tabs v-model:activeKey="activeTab">
                <a-tab-pane key="office" tab="Tài liệu Word/Excel/Office" />
                <a-tab-pane key="pdf" tab="Tài liệu PDF" />
            </a-tabs>
            <a-table
                v-if="activeTab === 'office'"
                :data-source="officeFiles"
                :columns="columns"
                row-key="_key"
                bordered
                size="small"
            >
                <template #bodyCell="{ column, record }">

                    <!-- Tên tài liệu -->
                    <template v-if="column.dataIndex === 'title'">
                        <div class="file-title">
                            <span>{{ record.title || record.name }}</span>
                        </div>
                    </template>

                    <!-- Kiểu file -->
                    <template v-else-if="column.dataIndex === 'ext'">
                        <a-tag color="blue">{{ record.ext?.toUpperCase() }}</a-tag>
                    </template>

                    <!-- Người upload -->
                    <template v-else-if="column.dataIndex === 'uploader'">
                        {{ record.uploader_name || nameOfUploader(record.uploaded_by) }}
                    </template>

                    <!-- Ngày upload -->
                    <template v-else-if="column.dataIndex === 'created_at'">
                        {{ formatTime(record.created_at) }} — {{ formatDateOnly(record.created_at) }}
                    </template>

                    <!-- Hành động -->
                    <template v-else-if="column.dataIndex === 'actions'">
                        <a-space>

                            <!-- Xem -->
                            <a-tooltip title="Xem">
                                <a-button size="small" @click="openAttachment(record)">
                                    <EyeOutlined/>
                                </a-button>
                            </a-tooltip>

                            <!-- Convert PDF -->
                            <a-tooltip :title="isPdf(record) ? 'File đã là PDF' : 'Chuyển sang PDF'">
                                <a-button
                                    size="small"
                                    :disabled="!canConvert(record)"
                                    :loading="converting[record._key]"
                                    @click="convertToPdf(record)"
                                >
                                    <FilePdfOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Xóa -->
                            <a-tooltip title="Xoá">
                                <a-button
                                    size="small"
                                    danger
                                    @click="onClickDelete(record)"
                                    :loading="deleting[record._key]"
                                >
                                    <DeleteOutlined/>
                                </a-button>
                            </a-tooltip>



                        </a-space>
                    </template>

                </template>
            </a-table>

            <a-table
                v-else-if="activeTab === 'pdf'"
                :data-source="convertedPdfs"
                :columns="pdfColumns"
                row-key="_key"
                bordered
                size="small"
            >
                <template #bodyCell="{ column, record }">
                    <template v-if="column.dataIndex === 'actions'">
                        <a-space>
                            <a-button size="small" type="primary"
                                      :loading="signing[record.id]"
                                      @click="signPdf(record)">
                                <EditOutlined /> Ký
                            </a-button>
                            <!-- Trình ký -->
                            <a-tooltip :title="canSign(record) ? 'Trình ký tài liệu' : 'Chỉ ký khi file là PDF'">
                                <a-button
                                    size="small"
                                    type="primary"
                                    @click="openSendApproval(record)"
                                >
                                    <SendOutlined/>
                                </a-button>
                            </a-tooltip>
                        </a-space>
                    </template>
                </template>
            </a-table>


            <a-empty v-else description="Không có tài liệu trong tab này" />


            <!-- Modal XEM TRƯỚC -->
            <a-modal
                v-model:open="preview.open"
                :title="preview.title"
                width="80%"
                style="top: 20px"
                footer=""
            >
                <div style="height: 80vh;">
                    <!-- Ảnh -->
                    <img
                        v-if="preview.kind === 'image'"
                        :src="preview.url"
                        style="max-width:100%; max-height:100%; display:block; margin:auto;"
                     alt=""/>

                    <!-- PDF -->
                    <iframe
                        v-else-if="preview.kind === 'pdf'"
                        :src="preview.url"
                        style="width:100%; height:100%; border:none;"
                    />

                    <!-- Office (Word, Excel, PowerPoint) dùng Office Viewer -->
                    <iframe
                        v-else-if="preview.kind === 'office'"
                        :src="officeViewer(preview.url)"
                        style="width:100%; height:100%; border:none;"
                    />

                    <!-- Link -->
                    <iframe
                        v-else-if="preview.kind === 'link'"
                        :src="preview.url"
                        style="width:100%; height:100%; border:none;"
                    />

                    <!-- File khác -->
                    <div v-else style="padding: 20px;">
                        <a-alert
                            type="warning"
                            message="Không thể xem trước loại file này"
                            description="Bạn có thể nhấn tải xuống để mở file bằng ứng dụng tương ứng."
                            show-icon
                        />
                    </div>
                </div>
            </a-modal>
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
    LinkOutlined, EyeOutlined, DownloadOutlined, SendOutlined,DeleteOutlined,
    FilePdfOutlined, FileWordOutlined, FileExcelOutlined, FilePptOutlined, FileTextOutlined, UserOutlined, ReloadOutlined, EditOutlined
} from '@ant-design/icons-vue'
import { computed, onMounted, ref, watch, reactive, nextTick, onBeforeUnmount } from 'vue'
import { message, Modal } from 'ant-design-vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'

// API
import { getUsers } from '@/api/user'
import { sendDocumentApproval, getActiveDocumentApproval, convertDriveToPdfAPI, listDrivePdfAPI } from '@/api/approvals.js'
import {
    adoptTaskFileFromPathAPI,
    uploadTaskFileLinkAPI,
    getCommentFilesByTask,
    sendCommentApproval,
    deleteTaskFile,
    deleteDocumentAPI, deleteTaskFileAPI, deleteCommentAPI
} from '@/api/taskFiles'
import { useUserStore } from '@/stores/user'

import * as pdfjsLib from "pdfjs-dist/legacy/build/pdf";
import { PDFDocument, degrees } from "pdf-lib";
import {
    uploadPdfToWordPress,
    uploadTaskFileSigned,
    saveConvertedDocument,
    getConvertedPdfList
} from "@/api/document.js";

const signing = reactive({});

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
const ensuring = reactive({})
const userMap = ref(Object.create(null))
const approverOptions = ref([])
const taskFileItems = ref([])

// Trạng thái duyệt: Map id (task_file_id hoặc comment id) -> {status, instanceId}
const approvalMap = ref({})

// modal gửi duyệt
const showSend = ref(false)
const sending = ref(false)
const sendingItem = ref(null)
const sendForm = reactive({ approver_ids: [], note: '' })
const activeTab = ref("office")
const drivePdfs = ref([]);
const convertedPdfs = ref([]);

const isPdf = r => (r.ext || '').toLowerCase() === 'pdf'

// File Office = word, excel, ppt
const officeExts = new Set(['doc','docx','xls','xlsx','ppt','pptx'])

const officeFiles = computed(() =>
    taskFileItems.value.filter(f => officeExts.has(f.ext))
)

const pdfFiles = computed(() =>
    taskFileItems.value.filter(f => f.ext === 'pdf')
)

const canConvert = r => !isPdf(r)

const canSign = r => isPdf(r) && canSendApproval(r)

// ---------- consts & helpers ----------
const IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const PDF_EXTS   = new Set(['pdf'])
const WORD_EXTS  = new Set(['doc', 'docx'])
const EXCEL_EXTS = new Set(['xls', 'xlsx', 'csv'])
const PPT_EXTS   = new Set(['ppt', 'pptx'])
const OFFICE_EXTS= new Set(['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'])

const columns = [
    { title: "Tên tài liệu", dataIndex: "title", key: "title", width: 100 },
    { title: "Kiểu file", dataIndex: "ext", key: "ext", width: 100, align: "center" },
    { title: "Người upload", dataIndex: "uploader", key: "uploader", width: 150 },
    { title: "Thời gian", dataIndex: "created_at", key: "created_at", width: 180 },
    { title: "Hành động", dataIndex: "actions", key: "actions", width: 220, align: "center" },
];

const pdfColumns = [
    {
        title: "Tên PDF",
        dataIndex: "title",
        key: "title",
    },
    {
        title: "Thời gian",
        dataIndex: "created_at",
        key: "created_at",
        width: 150,
        customRender: ({ record }) => {
            const dt = dayjs(record.created_at);
            if (!dt.isValid()) return "—";

            return dt.format("HH:mm — DD/MM/YYYY");
        }
    },
    {
        title: "Hành động",
        dataIndex: "actions",
        key: "actions",
        width: 120,
    }
];


const aborter = { controller: null }
const deleting = reactive({}) // per-item loading
const { confirm } = Modal

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

const preview = reactive({
    open: false,
    url: "",
    title: "",
    kind: "",
});

const previewKind = (record) => {
    const ext = (record.ext || "").toLowerCase();

    if (["jpg", "jpeg", "png", "gif", "webp", "bmp"].includes(ext)) return "image";
    if (ext === "pdf") return "pdf";
    if (["doc", "docx", "xls", "xlsx", "ppt", "pptx"].includes(ext)) return "office";
    if (record.is_link) return "link";

    return "other";
};

const officeViewer = (url) =>
    `https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(url)}`;

const converting = reactive({});


async function fetchConvertedPdfs() {
    try {
        const { data } = await getConvertedPdfList(props.taskId);

        convertedPdfs.value = (data.files || []).map(f => ({
            _key: String(f.id),
            id: f.id,
            title: f.title || 'Converted PDF',
            url: f.file_url,
            mime: f.mime_type,
            created_at: f.wp_created_at || f.created_at,
        }));
    } catch (e) {
        console.error(e);
        message.error("Không lấy được PDF đã convert");
    }
}



async function convertToPdf(item) {

    converting[item._key] = true;

    try {
        const { data } = await convertDriveToPdfAPI(item.drive_id);

        if (!data?.pdf_id) {
            return message.error("Chuyển PDF thất bại.");
        }

        // --- Tên file PDF sau convert ---
        const original = item.name.replace(/\.[^.]+$/, "");  // bỏ .doc/.docx
        const pdfFilename = `Converted_${original}.pdf`;      // giữ nguyên tên

        // URL tải PDF trực tiếp từ Google Drive
        const realPdfUrl = `https://drive.google.com/uc?export=download&id=${data.pdf_id}`;

        // Upload lên WordPress (⚡ truyền filename)
        const wpUploaded = await uploadPdfToWordPress(realPdfUrl, pdfFilename);

        if (!wpUploaded) {
            return message.error("Upload WordPress thất bại!");
        }

        // Lưu DB
        await saveConvertedDocument({
            wp_id: wpUploaded.id,
            file_url: wpUploaded.source_url,
            mime_type: wpUploaded.mime_type,
            title: pdfFilename,
            size: wpUploaded.raw?.media_details?.filesize ?? null,
            drive_id: item.drive_id,
            task_file_id: item.task_file_id,
            uploaded_by: item.uploaded_by,
            uploader_name: item.uploader_name,
            wp_created_at: wpUploaded.raw?.date_gmt,
        });

        message.success("Đã chuyển & lưu PDF!");

    } catch (e) {
        console.error("convertToPdf error:", e);
        message.error("Lỗi chuyển hoặc upload PDF.");
    } finally {
        converting[item._key] = false;
        await refresh();
    }
}





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

        console.log('rows', rows)

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
                id: r.id,
                task_file_id: r.task_id || null,
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
                _source: r.source,
                status: r.status || null,
                full: r,
                drive_id: r.drive_id || null,
            }

            // seed trạng thái duyệt ngay nếu BE trả sẵn
            const mapKey = it.task_file_id || it.id
            if (r.status && !approvalMap.value[mapKey]) {
                approvalMap.value[mapKey] = { status: String(r.status), instanceId: null }
            }

            items.push(it)
        }

        taskFileItems.value = items

        console.log('taskFileItems.value', taskFileItems.value)
        await refreshApprovalStates()
    } catch (e) {
        message.error((e?.response?.data?.message) || 'Không tải được tài liệu của task.')
    } finally {
        loading.value = false
    }
}

async function fetchDrivePdfs() {
    try {
        const { data } = await listDrivePdfAPI();
        drivePdfs.value = (data.files || []).map(f => ({
            _key: f.id,
            id: f.id,
            title: f.name,
            name: f.name,
            ext: "pdf",
            created_at: f.createdTime,
            // ↓↓↓ URL để xem
            url: getPdfUrl(f.id)
        }));
    } catch (e) {
        console.error(e);
        message.error("Không tải được danh sách PDF từ Google Drive");
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


function clearSendApproval () {
    showSend.value = false
    sendingItem.value = null
    sendForm.approver_ids = []
    sendForm.note = ''
}

// ---------- actions ----------
function openAttachment (it) {
    const raw = it.url || it.file_path
    if (!raw) return

    let previewUrl = raw

    // 1) Nếu là dạng Doc.aspx → ép action=embedview
    if (previewUrl.includes('/_layouts/15/Doc.aspx')) {
        if (previewUrl.includes('action=')) {
            previewUrl = previewUrl.replace(/action=[^&]+/, 'action=embedview')
        } else {
            previewUrl += (previewUrl.includes('?') ? '&' : '?') + 'action=embedview'
        }
    }

    // 2) Nếu là dạng modern /:x:/g/... → thêm action=embedview
    if (previewUrl.match(/\/:.\//)) {
        previewUrl += (previewUrl.includes('?') ? '&' : '?') + 'action=embedview'
    }

    window.open(previewUrl, '_blank', 'noopener')
}

const downloadAttachment = (it) => window.open(it.url, '_blank', 'noopener')

const refresh = async () => {
    try {
        loading.value = true
        await fetchTaskFiles()
        message.destroy()
        message.success('Danh sách tài liệu đã được cập nhật')
    } catch (e) {
        message.error('Không thể tải lại tài liệu')
    } finally {
        loading.value = false
    }
}

async function onClickDelete(item) {
    Modal.confirm({
        title: 'Xác nhận xoá',
        content: 'Bạn có chắc muốn xoá tài liệu này? Hành động không thể hoàn tác.',
        okText: 'Xoá',
        okType: 'danger',
        cancelText: 'Hủy',
        async onOk() {
            deleting[item._key] = true
            try {

                if (item.source === 'document' || item._source === 'document') {
                    await deleteDocumentAPI(Number(item.id))
                } else if (item._source === 'task_file' || item.task_file_id) {
                    await deleteTaskFileAPI(Number(item.task_file_id || item.id))
                } else if (item._source === 'comment') {
                    await deleteCommentAPI(Number(item.id))
                }

                message.success('Đã xoá')
                await refresh()

            } catch (e) {
                message.error(e?.response?.data?.message || 'Không thể xoá')
            } finally {
                deleting[item._key] = false
            }
        }
    })
}

function getPdfUrl(driveId) {
    return `${import.meta.env.VITE_API_BASE}/documents/pdf-download?file_id=${driveId}`;
}

async function autoFindMarker(pdfJsDoc, markers = []) {
    const total = pdfJsDoc.numPages;

    const escapeRegex = s =>
        s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

    const lowerMarkers = markers.map(m => escapeRegex(m.toLowerCase()));

    for (let pageIndex = 1; pageIndex <= total; pageIndex++) {

        const page = await pdfJsDoc.getPage(pageIndex);
        const textContent = await page.getTextContent();

        const items = textContent.items || [];

        for (const item of items) {
            const txt = (item.str || "").trim().toLowerCase();
            if (!txt) continue;

            for (const m of lowerMarkers) {
                if (txt.includes(m)) {

                    // tọa độ trong PDF (transform array)
                    // transform = [a,b,c,d,x,y]
                    const [a, b, c, d, x, y] = item.transform;

                    const fontHeight = Math.abs(d);
                    const textWidth = (item.width || (txt.length * fontHeight)) || 50;

                    return {
                        pageIndex,
                        x,
                        y,
                        w: textWidth,
                        h: fontHeight,
                        marker: item.str
                    };
                }
            }
        }
    }

    return null;
}


async function signPdf(file) {
    signing[file.id] = true;

    try {
        // 🔥 1) Tải PDF từ backend đúng cách
        const pdfRes = await fetch(getPdfUrl(file.id));
        if (!pdfRes.ok) throw new Error("Không tải được PDF từ server.");

        const pdfBytes = await pdfRes.arrayBuffer();

        // 🔥 2) Tải chữ ký
        const sigUrl = store.currentUser?.signature_url;
        if (!sigUrl) throw new Error("User chưa có chữ ký");

        const sigBytes = await fetch(sigUrl).then(r => r.arrayBuffer());

        // 🔥 3) Load bằng pdf-lib để chèn ảnh
        const pdfDoc = await PDFDocument.load(pdfBytes, { updateMetadata: false });

        // 🔥 4) Load PDF bằng pdfjs để detect marker
        const pdfJs = await pdfjsLib.getDocument({ data: pdfBytes }).promise;
        const marker = await autoFindMarker(pdfJs, ["HCNS", "chuky1", "chuky2"]);

        if (!marker) {
            return message.error("Không tìm thấy vị trí ký.");
        }

        // 🔥 5) Chèn signature tại marker
        const page = pdfDoc.getPage(marker.pageIndex - 1);

        let img;
        try {
            img = await pdfDoc.embedPng(sigBytes);
        } catch {
            img = await pdfDoc.embedJpg(sigBytes);
        }

        const sigW = 120;
        const sigH = sigW * 0.35;

        page.drawImage(img, {
            x: marker.x,
            y: marker.y - sigH - 8,
            width: sigW,
            height: sigH,
        });

        const newPdf = await pdfDoc.save();

        // 🔥 6) Upload file PDF đã ký
        const formData = new FormData();
        formData.append("file", new Blob([newPdf], { type: "application/pdf" }));
        formData.append("document_id", file.id);

        await uploadTaskFileSigned(formData);

        message.success("Đã ký thành công!");
        await refresh();
    } catch (err) {
        console.error(err);
        message.error("Ký thất bại.");
    } finally {
        signing[file.id] = false;
    }
}


async function getMarkerXY(pdfDoc, pageIndex, sigW, sigH) {
    const page = await pdfDoc.getPage(pageIndex);
    const text = await page.getTextContent();
    const items = text.items || [];

    let best = items.find(i => i.str.toLowerCase().includes("hcn"));

    if (!best) {
        best = items[0]; // fallback top-left
    }

    return {
        x: best.transform[4],
        y: best.transform[5] - sigH - 10
    };
}




defineExpose({ refresh }) // nếu bạn muốn parent gọi được

// ---------- lifecycle ----------
onMounted(async () => {
    await Promise.all([loadUsers(), fetchTaskFiles()])
})
watch(() => props.taskId, () => fetchTaskFiles())
watch(activeTab, async (val) => {
    if (val === "pdf") {
        await fetchConvertedPdfs();
    }
});

onBeforeUnmount(() => {
    aborter.controller?.abort?.()
})
</script>

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
.doc-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 6px 8px 10px;
    border-bottom: 1px solid #f0f0f0;
    margin-bottom: 8px;
}

.doc-header-title {
    font-weight: 600;
    font-size: 14px;
    color: #333;
    display: flex;
    align-items: center;
    gap: 6px;
}

.refresh-btn {
    color: #555;
    transition: all 0.25s ease;
    border-radius: 6px;
}

.refresh-btn:hover {
    color: #1677ff;
    background-color: #f5f8ff;
}

/* Icon xoay nhẹ khi đang tải */
.refresh-icon {
    font-size: 16px;
    transition: transform 0.25s ease;
}

.is-rotating {
    animation: spin 0.9s linear infinite;
}

.att-list-vertical .ant-list-items {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.att-list-item {
    padding-left: 0 !important;
    padding-right: 0 !important;
}

.att-card {
    width: 100%;
}

.att-card--sm {
    --att-thumb-h: 50px;
    --att-icon-size: 20px;
}

.file-title {
    display: flex;
    align-items: center;
    gap: 8px;
}

.file-icon {
    font-size: 18px;
    color: #1677ff;
}

.ant-table {
    margin-top: 10px;
}


@keyframes spin {
    from { transform: rotate(0deg); }
    to   { transform: rotate(360deg); }
}


</style>
