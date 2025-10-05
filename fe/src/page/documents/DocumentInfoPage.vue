<template>
    <div class="doc-page">
        <!-- ===== Header ===== -->
        <a-page-header
            :title="doc?.title || `Tài liệu #${id}`"
            :sub-title="displayUrl"
            @back="$router.back()"
        >
            <template #tags>
                <a-space wrap>
                    <a-tag v-if="doc?.visibility" :color="visibilityColor">{{ visLabel }}</a-tag>
                    <a-tag v-if="doc?.file_type" color="geekblue">{{ doc.file_type }}</a-tag>
                    <a-tag v-if="doc?.approval_status" :color="approvalColor">{{ approvalLabel }}</a-tag>
                    <a-tag v-if="doc?.file_size" color="purple">{{ humanSize }}</a-tag>
                </a-space>
            </template>

            <template #extra>
                <a-space>
                    <a-tooltip title="Mở tài liệu gốc">
                        <a-button v-if="isExternal" @click="openExternal">
                            <template #icon><ExportOutlined /></template> Mở
                        </a-button>
                    </a-tooltip>

                    <a-tooltip title="Sao chép đường dẫn">
                        <a-button v-if="doc?.file_path" @click="copyUrl">
                            <template #icon><CopyOutlined /></template>
                        </a-button>
                    </a-tooltip>

                    <a-tooltip title="Tải xuống tệp">
                        <a-button v-if="canDownload" type="primary" @click="downloadFile">
                            <template #icon><DownloadOutlined /></template> Tải xuống
                        </a-button>
                    </a-tooltip>
                </a-space>
            </template>
        </a-page-header>

        <!-- ===== Main Content ===== -->
        <div class="content">
            <!-- Left: Preview -->
            <a-card class="left" :loading="loading" :body-style="{ padding: 0 }">
                <div v-if="!loading" class="preview">
                    <FilePreview :url="absoluteUrl" />
                </div>
            </a-card>


            <!-- Right: Information -->
            <div class="right">
                <a-skeleton v-if="loading" active :paragraph="{ rows: 10 }" />

                <template v-else-if="doc">
                    <a-card title="Thông tin tài liệu">
                        <a-descriptions :column="1" bordered size="middle">
                            <a-descriptions-item label="Tiêu đề">{{ doc.title }}</a-descriptions-item>
                            <a-descriptions-item label="Loại tệp">{{ doc.file_type }}</a-descriptions-item>
                            <a-descriptions-item label="Kích thước">{{ humanSize }}</a-descriptions-item>
                            <a-descriptions-item label="Phòng ban">{{ doc.department_name || doc.department_id }}</a-descriptions-item>
                            <a-descriptions-item label="Người tải lên">{{ doc.uploader_name || doc.uploaded_by }}</a-descriptions-item>
                            <a-descriptions-item label="Quyền truy cập">
                                <a-tag :color="visibilityColor">{{ visLabel }}</a-tag>
                            </a-descriptions-item>
                            <a-descriptions-item label="Nhãn">
                                <a-space wrap>
                                    <a-tag v-for="t in tags" :key="t">{{ t }}</a-tag>
                                    <span v-if="!tags.length">—</span>
                                </a-space>
                            </a-descriptions-item>
                            <a-descriptions-item label="Ngày tạo">{{ fmt(doc.created_at) }}</a-descriptions-item>
                            <a-descriptions-item label="Cập nhật">{{ fmt(doc.updated_at) }}</a-descriptions-item>
                            <a-descriptions-item label="Đường dẫn">
                                <a-typography-paragraph
                                    copyable
                                    :content="absoluteUrl"
                                    style="margin: 0"
                                />
                            </a-descriptions-item>
                        </a-descriptions>
                    </a-card>

                    <a-card v-if="hasApproval" title="Phê duyệt" class="mt">
                        <a-timeline v-if="steps.length">
                            <a-timeline-item
                                v-for="(s, idx) in steps"
                                :key="idx"
                                :color="stepColor(s.status)"
                            >
                                <div class="step-line">
                                    <div class="step-title">
                                        Cấp {{ s.level }} — {{ statusLabel(s.status) }}
                                    </div>
                                    <div class="step-sub">
                                        Người duyệt: {{ s.approver_name || s.approver_id || '—' }}
                                        <span v-if="s.commented_at">• {{ fmt(s.commented_at) }}</span>
                                    </div>
                                    <div v-if="s.note" class="step-note">“{{ s.note }}”</div>
                                </div>
                            </a-timeline-item>
                        </a-timeline>

                        <a-empty v-else description="Chưa có dữ liệu phê duyệt" />
                    </a-card>
                </template>

                <a-empty v-else description="Không tìm thấy tài liệu" />
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from "vue"
import { useRoute, useRouter } from "vue-router"
import { message } from "ant-design-vue"
import {
    FileTextOutlined,
    ExportOutlined,
    CopyOutlined,
    DownloadOutlined,
} from "@ant-design/icons-vue"
import dayjs from "dayjs"
import "dayjs/locale/vi"
dayjs.locale("vi")
import { getDocumentById } from '@/api/document.js'
import FilePreview from "@/components/FilePreview.vue";

// Route
const route = useRoute()
const router = useRouter()
const id = computed(() => Number(route.params.id || 0))

// States
const doc = ref(null)
const loading = ref(true)

// Fetch
async function fetchDocument(id) {
    return await getDocumentById(id)
}

const load = async () => {
    loading.value = true
    try {
        doc.value = await fetchDocument(id.value)
    } catch (e) {
        console.error(e)
        doc.value = null
        message.error("Không tìm thấy hoặc tải tài liệu thất bại.")
    } finally {
        loading.value = false
    }
}

onMounted(load)
watch(id, load)

/* ===== Helpers ===== */
const fmt = (v) => (v ? dayjs(v).format("DD/MM/YYYY HH:mm") : "—")
const tags = computed(() =>
    (doc.value?.tags || "")
        .split(",")
        .map((t) => t.trim())
        .filter(Boolean)
)

const visibilityColor = computed(() => {
    const v = (doc.value?.visibility || "").toLowerCase()
    return (
        {
            public: "green",
            department: "blue",
            custom: "gold",
            private: "red",
        }[v] || "default"
    )
})
const visLabel = computed(() => doc.value?.visibility || "private")

const approvalColor = computed(() => {
    const s = (doc.value?.approval_status || "").toLowerCase()
    return (
        {
            approved: "green",
            pending: "orange",
            rejected: "red",
        }[s] || "default"
    )
})
const approvalLabel = computed(() => doc.value?.approval_status || "not_sent")

const steps = computed(() => {
    const raw = doc.value?.approval_steps
    if (!raw) return []
    try {
        return Array.isArray(raw) ? raw : JSON.parse(raw)
    } catch {
        return []
    }
})
const hasApproval = computed(
    () => !!(doc.value?.approval_status || steps.value.length)
)

const statusLabel = (s) =>
    ({
        approved: "Đã duyệt",
        pending: "Đang chờ",
        rejected: "Từ chối",
    }[String(s || "").toLowerCase()] || "—")
const stepColor = (s) =>
    ({
        approved: "green",
        pending: "orange",
        rejected: "red",
    }[String(s || "").toLowerCase()] || "blue")

// URL logic
const absoluteUrl = computed(() => {
    const p = doc.value?.file_path || ""
    if (/^https?:\/\//i.test(p)) return p
    if (p.startsWith("/")) return p
    return p ? `/${p}` : ""
})
const displayUrl = computed(() => absoluteUrl.value || "—")
const isExternal = computed(() => /^https?:\/\//i.test(absoluteUrl.value))
const canDownload = computed(() => !!absoluteUrl.value)

const openExternal = () => {
    window.open(absoluteUrl.value, "_blank", "noopener,noreferrer")
}
const copyUrl = async () => {
    await navigator.clipboard.writeText(absoluteUrl.value)
    message.success("Đã sao chép URL")
}
const downloadFile = () => {
    const a = document.createElement("a")
    a.href = absoluteUrl.value
    a.download = doc.value?.title || `document-${id.value}`
    a.target = "_blank"
    a.rel = "noopener"
    a.click()
}

const ext = computed(() => {
    const match = (absoluteUrl.value || "").match(/\.([a-z0-9]+)(?:\?|#|$)/i)
    return (match?.[1] || "").toLowerCase()
})
const previewKind = computed(() => {
    const e = ext.value
    if (["png", "jpg", "jpeg", "gif", "webp", "bmp", "svg"].includes(e))
        return "image"
    if (e === "pdf") return "pdf"
    return "none"
})
const humanSize = computed(() => {
    const n = Number(doc.value?.file_size || 0)
    if (!n) return ""
    const u = ["B", "KB", "MB", "GB", "TB"]
    const i = Math.floor(Math.log(n) / Math.log(1024))
    return `${(n / Math.pow(1024, i)).toFixed(i ? 1 : 0)} ${u[i]}`
})
</script>

<style scoped>
.doc-page {
    display: flex;
    flex-direction: column;
    gap: 16px;
}
.content {
    display: grid;
    grid-template-columns: 2fr 1fr;     /* trước là 1.3fr 1fr */
    gap: 16px;
}
.left {
    min-height: 540px;
    border-radius: 8px;
    overflow: hidden;
}
.preview {
    width: 100%;
    height: 100%;
    align-items: center;
    justify-content: center;
    background: #fafafa;
}
.preview-img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
}
.preview-frame {
    width: 100%;
    height: 540px;
    border: 0;
}
.preview-empty {
    text-align: center;
    padding: 48px 12px;
    color: #888;
}
/* cao theo màn hình, trừ chiều cao header/toolbar ~220px */
.preview-frame,
.preview-img,
.docx-view,
.excel-view {
    height: calc(100vh - 220px);        /* trước là 540/600px */
}
.left { min-height: calc(100vh - 220px); }
.preview-empty .ic {
    font-size: 48px;
    color: #bbb;
}
.preview-empty .tt {
    margin-top: 8px;
    font-weight: 600;
    color: #333;
}
.preview-empty .sub {
    font-size: 13px;
    margin-top: 2px;
}
.preview-empty .actions {
    margin-top: 12px;
    display: flex;
    gap: 8px;
    justify-content: center;
}
.right .mt {
    margin-top: 16px;
}
.step-line {
    display: flex;
    flex-direction: column;
    gap: 2px;
}
.step-title {
    font-weight: 600;
}
.step-sub {
    color: #888;
    font-size: 12px;
}
.step-note {
    margin-top: 4px;
    font-style: italic;
    color: #555;
}
@media (max-width: 1100px) {
    .content {
        grid-template-columns: 1fr;
    }
}
</style>
