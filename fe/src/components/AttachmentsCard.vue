<template>
    <a-card bordered class="doc-section">
        <div class="doc-header">
            <a-tooltip title="Tải lại danh sách tài liệu">
                <a-button
                    type="text"
                    size="small"
                    class="refresh-btn"
                    @click="refresh"
                >
                    Tải lại
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
            <!-- Nút Xóa hàng loạt Office -->
            <div v-if="activeTab === 'office'" style="margin: 10px 0;">
                <a-button
                    danger
                    :disabled="selectedOfficeKeys.length === 0"
                    @click="deleteOfficeBulk"
                >
                    Xoá đã chọn ({{ selectedOfficeKeys.length }})
                </a-button>
            </div>

            <!-- 🔥 Nút Xoá hàng loạt -->
            <div v-if="activeTab === 'pdf'" style="margin: 10px 0;">
                <a-button
                    danger
                    :disabled="selectedRowKeys.length === 0"
                    @click="deleteBulk"
                >
                    Xoá đã chọn ({{ selectedRowKeys.length }})
                </a-button>
            </div>
            <a-table
                v-if="activeTab === 'office'"
                :data-source="officeFiles"
                :columns="columns"
                row-key="id"
                bordered
                size="small"
                :row-selection="officeRowSelection"
                :scroll="{ x: 'max-content' }"
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
                                    @click="openDocTypePopup(record)"
                                >
                                    <FilePdfOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Xóa -->
<!--                            <a-tooltip title="Xoá">-->
<!--                                <a-button-->
<!--                                    size="small"-->
<!--                                    danger-->
<!--                                    @click="onClickDelete(record)"-->
<!--                                    :loading="deleting[record._key]"-->
<!--                                >-->
<!--                                    <DeleteOutlined/>-->
<!--                                </a-button>-->
<!--                            </a-tooltip>-->



                        </a-space>
                    </template>

                </template>
            </a-table>

            <a-table
                v-else-if="activeTab === 'pdf'"
                :data-source="convertedPdfs"
                :columns="pdfColumns"
                row-key="id"
                bordered
                size="small"
                :row-selection="{ selectedRowKeys, onChange: onSelectChange }"
                :scroll="{ x: 'max-content' }"
            >
                <template #bodyCell="{ column, record }">
                    <template v-if="column.dataIndex === 'actions'">
                        <a-space>

                            <!-- Trình ký -->
                            <a-tooltip title="Trình ký tài liệu">
                                <a-button
                                    size="small"
                                    type="primary"
                                    @click="openSendApproval(record)"
                                >
                                    <SendOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Xoá -->
                            <a-tooltip title="Xoá PDF">
                                <a-button
                                    size="small"
                                    danger
                                    @click="deleteConverted(record)"
                                >
                                    <DeleteOutlined />
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
    <a-modal
        v-model:open="showDocType"
        title="Chọn loại văn bản"
        ok-text="Chuyển sang PDF"
        class="doc-type-modal"
        @ok="confirmConvert"
    >
        <div class="doc-type-box">

            <div class="doc-type-hint">
                <InfoCircleOutlined class="info-icon" />
                <span>
                Hãy chọn loại văn bản để hệ thống xử lý đúng luồng duyệt:
                <b>Nội bộ</b> hoặc <b>Phát hành</b>.
            </span>
            </div>

            <a-radio-group v-model:value="selectedDocType" class="doc-type-radio">
                <a-radio value="internal">Nội bộ <small>(Mặc định)</small></a-radio>
                <a-radio value="external">Phát hành</a-radio>
            </a-radio-group>

        </div>
    </a-modal>


</template>

<script setup>
import {
    LinkOutlined, EyeOutlined, DownloadOutlined, SendOutlined,DeleteOutlined,InfoCircleOutlined,
    FilePdfOutlined, FileWordOutlined, FileExcelOutlined, FilePptOutlined, FileTextOutlined, UserOutlined, ReloadOutlined, EditOutlined
} from '@ant-design/icons-vue'
import { computed, onMounted, ref, watch, reactive, nextTick, onBeforeUnmount } from 'vue'
import { message, Modal } from 'ant-design-vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'

// API
import { getUsers } from '@/api/user'
import { convertDriveToPdfAPI } from '@/api/approvals.js'
import {
    getCommentFilesByTask,
    deleteDocumentAPI, deleteTaskFileAPI, deleteCommentAPI, bulkDeleteDocuments
} from '@/api/taskFiles'
import { useUserStore } from '@/stores/user'

import * as pdfjsLib from "pdfjs-dist/legacy/build/pdf";
import { PDFDocument, degrees } from "pdf-lib";
import {
    uploadPdfToWordPress,
    saveConvertedDocument,
    getConvertedPdfList, deleteConvertedPdf, bulkDeleteConvertedPdf
} from "@/api/document.js";
import {sendDocumentToSign} from "@/api/documentSign.js";


// ---------- setup ----------
dayjs.locale('vi')
const store = useUserStore()

// ---------- props ----------
const props = defineProps({
    taskId: { type: [String, Number], required: true },
    departmentId: { type: [Number, String], default: null }
})

// ---------- state ----------
const thumbH = 96
const loading = ref(false)
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
const convertedPdfs = ref([]);

const showDocType = ref(false)
const convertingItem = ref(null)
const selectedDocType = ref("internal")  // mặc định nội bộ


const isPdf = r => (r.ext || '').toLowerCase() === 'pdf'

// File Office = word, excel, ppt
const officeExts = new Set(['doc','docx','xls','xlsx','ppt','pptx'])

const officeFiles = computed(() =>
    taskFileItems.value.filter(f => officeExts.has(f.ext))
)

const canConvert = r => !isPdf(r)

const selectedOfficeKeys = ref([]);

const officeRowSelection = {
    selectedRowKeys: selectedOfficeKeys,
    onChange: (keys) => {
        selectedOfficeKeys.value = keys;
    }
};


// ---------- consts & helpers ----------
const IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const PDF_EXTS   = new Set(['pdf'])
const WORD_EXTS  = new Set(['doc', 'docx'])
const EXCEL_EXTS = new Set(['xls', 'xlsx', 'csv'])
const PPT_EXTS   = new Set(['ppt', 'pptx'])

const columns = [
    { title: "Tên tài liệu", dataIndex: "title", key: "title", width: 150 },
    { title: "Kiểu file", dataIndex: "ext", key: "ext", width: 100, align: "center" },
    { title: "Người upload", dataIndex: "uploader", key: "uploader", width: 170 },
    { title: "Thời gian", dataIndex: "created_at", key: "created_at", width: 150 },
    { title: "Hành động", dataIndex: "actions", key: "actions", width: 100, align: "center" },
];

const pdfColumns = [
    {
        title: "Tên PDF",
        dataIndex: "title",
        key: "title",
        width: 200
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

// Danh sách id được chọn
const selectedRowKeys = ref([]);

const onSelectChange = (keys) => {
    selectedRowKeys.value = keys;
};


const aborter = { controller: null }
const deleting = reactive({})

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

const officeViewer = (url) => `https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(url)}`;

const converting = reactive({});

function openDocTypePopup(item) {
    convertingItem.value = item
    selectedDocType.value = "internal"   // mặc định
    showDocType.value = true
}

async function confirmConvert() {
    showDocType.value = false
    await convertToPdf(convertingItem.value, selectedDocType.value)
}


async function fetchConvertedPdfs() {
    try {
        const { data } = await getConvertedPdfList(props.taskId);
        console.log(data)
        convertedPdfs.value = (data.files || []).map(f => ({
            _key: String(f.id),
            id: f.id,
            title: f.title || 'Converted PDF',
            url: f.file_url,
            drive_id: f.drive_id,
            wp_id: f.wp_id,
            file_url: f.file_url,
            mime: f.mime_type,
            task_file_id: f.task_file_id,
            created_at: f.wp_created_at || f.created_at,
        }));
    } catch (e) {
        console.error(e);
        message.error("Không lấy được PDF đã convert");
    }
}



async function convertToPdf(item, docType = "internal") {

    converting[item._key] = true;

    try {
        const { data } = await convertDriveToPdfAPI(item.drive_id);

        if (!data?.pdf_id) {
            return message.error("Chuyển PDF thất bại.");
        }

        const original = item.name.replace(/\.[^.]+$/, "");
        const pdfFilename = `origin_${original}.pdf`;

        const realPdfUrl = `https://drive.google.com/uc?export=download&id=${data.pdf_id}`;

        const wpUploaded = await uploadPdfToWordPress(realPdfUrl, pdfFilename);

        if (!wpUploaded) {
            return message.error("Upload WordPress thất bại!");
        }

        // GỬI THÊM doc_type
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
            doc_type: docType,  // ← thêm vào đây
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
    } catch (e) {
        message.error((e?.response?.data?.message) || 'Không tải được tài liệu của task.')
    } finally {
        loading.value = false
    }
}


const canSendApproval = (item) => item.status === 'not_sent'

// nạp trạng thái active cho các task_file_id (comment-id không có API này)

// ---------- modal ----------
async function openSendApproval(item) {
    console.log('item', item)
    // Lấy converted_id (tuỳ item trong list của bạn)
    const convertedId =
        Number(item.converted_id) ||
        Number(item.id) ||
        Number(item.wp_id) ||
        null

    if (!convertedId) {
        return message.error('Không tìm thấy converted_id hợp lệ để gửi ký.')
    }

    // Lưu đối tượng đang chuẩn bị gửi ký
    sendingItem.value = {
        ...item,
        converted_id: convertedId
    }

    // Reset form
    sendForm.approver_ids = []
    showSend.value = true
}


async function submitSendApproval() {
    if (!sendForm.approver_ids.length) {
        return message.error('Vui lòng chọn ít nhất 1 người ký.')
    }

    const item = sendingItem.value

    if (!item) return

    sending.value = true

    try {
        // Lấy converted_id từ item hiện tại
        const convertedId = Number(item.converted_id) || Number(item.id) || Number(item.wp_id) || null

        if (!convertedId) {
            message.error('Không tìm thấy converted_id hợp lệ.')
            return
        }

        const payload = {
            converted_id: convertedId,
            approver_ids: sendForm.approver_ids.map(Number),
            task_file_id: item.task_file_id || null
        }

        const res = await sendDocumentToSign(payload)

        message.success(res.data?.message || 'Đã gửi tài liệu đi ký.')

        // cập nhật trạng thái FE
        item.status = 'pending'
        clearSendApproval()

    } catch (e) {
        console.error('submitSendApproval error:', e)
        message.error(e?.response?.data?.message || 'Không thể gửi duyệt.')
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

const deleteConverted = (record) => {
    Modal.confirm({
        title: "Bạn có chắc muốn xoá PDF này?",
        content: record.title,
        okText: "Xoá",
        okType: "danger",
        cancelText: "Huỷ",

        onOk: async () => {
            try {
                await deleteConvertedPdf(record.id);
                message.success("Đã xoá PDF");
                await fetchConvertedPdfs();
            } catch (e) {
                const apiMsg =
                    e.response?.data?.messages?.error ||
                    e.response?.data?.message ||
                    "Không xoá được PDF";

                message.error(apiMsg);
            }
        }
    });
};


const deleteBulk = () => {
    Modal.confirm({
        title: "Bạn có chắc muốn xoá các PDF đã chọn?",
        content: `Tổng số: ${selectedRowKeys.value.length} file`,
        okText: "Xoá",
        okType: "danger",
        cancelText: "Huỷ",

        onOk: async () => {
            try {
                await bulkDeleteConvertedPdf(selectedRowKeys.value);

                message.success("Đã xoá các PDF đã chọn");
                selectedRowKeys.value = [];
                await fetchConvertedPdfs();
            } catch (e) {
                const apiMsg =
                    e.response?.data?.messages?.error ||
                    e.response?.data?.message ||
                    "Không thể xoá các file đã chọn";

                message.error(apiMsg);
            }
        }
    });
};

const deleteOfficeBulk = () => {
    Modal.confirm({
        title: "Bạn có chắc muốn xoá các file Office đã chọn?",
        content: `Tổng số: ${selectedOfficeKeys.value.length} file`,
        okText: "Xoá",
        okType: "danger",
        cancelText: "Huỷ",

        onOk: async () => {
            try {
                const ids = selectedOfficeKeys.value;

                await bulkDeleteDocuments({ ids });

                message.success("Đã xoá các file Office đã chọn");

                selectedOfficeKeys.value = [];
                await refresh();

            } catch (e) {
                console.log("ERROR RAW:", e);
                const data = e.response?.data;

                const apiMsg =
                    data?.messages?.error ||       // đúng field API của bạn
                    data?.messages?.message ||     // nếu BE trả kiểu khác
                    data?.message ||               // fallback kiểu CodeIgniter mặc định
                    e.message ||                   // fallback JS
                    "Không thể xoá các file đã chọn";

                message.error(apiMsg);
            }

        }
    });
};







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
    justify-content: end;
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
/* ==== Popup chọn loại tài liệu ==== */

.doc-type-modal .ant-modal-content {
    border-radius: 10px;
    padding: 20px 24px 16px;
}

.doc-type-box {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

/* Hộp mô tả */
.doc-type-hint {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    font-size: 13px;
    color: #444;
    background: #f5f9ff;
    padding: 12px 14px;
    border-radius: 6px;
    border-left: 3px solid #1677ff;
    line-height: 1.45;
}

.doc-type-hint .info-icon {
    color: #1677ff;
    font-size: 16px;
    margin-top: 1px;
}

/* Radio group */
.doc-type-radio {
    padding-left: 4px;
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.doc-type-radio .ant-radio-wrapper {
    font-size: 14px;
}


@keyframes spin {
    from { transform: rotate(0deg); }
    to   { transform: rotate(360deg); }
}


</style>
