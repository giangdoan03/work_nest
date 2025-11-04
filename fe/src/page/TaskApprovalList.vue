<!-- src/components/ApprovalInboxFiles.vue -->
<template>
    <a-card :bordered="false" class="inbox-files">
        <!-- Toolbar -->
        <div class="toolbar">
            <a-input-search
                v-model:value="keyword"
                :placeholder="'Tìm theo tên tệp, người gửi…'"
                allow-clear
                @search="onSearch"
                style="max-width: 440px"
            >
                <template #enterButton>
                    <a-button type="primary">
                        <template #icon><SearchOutlined /></template>
                        Tìm
                    </a-button>
                </template>
            </a-input-search>

            <a-space>
                <a-button @click="fetchData" :loading="loading">
                    <template #icon><ReloadOutlined /></template>
                    Làm mới
                </a-button>
            </a-space>
        </div>

        <!-- List -->
        <a-list
            :loading="loading"
            :data-source="paged"
            :locale="{ emptyText: 'Không có tài liệu nào cần bạn duyệt.' }"
            item-layout="horizontal"
            :pagination="paginationCfg"
            class="mt-3"
        >
            <template #renderItem="{ item }">
                <a-list-item :key="item.approval_id">
                    <a-card class="file-card" :hoverable="true">
                        <div class="row">
                            <div class="thumb">
                                <component :is="item.icon" class="thumb-icon" v-if="item.kind!=='image'" />
                                <a-image v-else :src="item.url" :height="64" />
                            </div>

                            <div class="meta">
                                <div class="title" :title="item.title || item.name">
                                    {{ item.title || item.name }}
                                </div>

                                <div class="sub">
                                    <UserOutlined /> {{ item.uploader_name || '—' }}
                                    · {{ formatDate(item.created_at) }}
                                </div>

                                <div class="url" v-if="item.url">
                                    <a-button type="link" :href="item.url" target="_blank" rel="noopener">Mở tệp</a-button>
                                    <a-typography-text type="secondary" copyable>{{ item.url }}</a-typography-text>
                                </div>

                                <div class="status">
                                    <a-tag color="blue">Bước #{{ item.current_step_index || item.sequence || 1 }}</a-tag>
                                    <a-tag :color="statusColor(item.status)">{{ labelStatus(item.status) }}</a-tag>
                                </div>
                            </div>

                            <div class="actions">
                                <a-tooltip title="Xem trước">
                                    <a-button size="small" shape="circle" @click="openFile(item)">
                                        <EyeOutlined />
                                    </a-button>
                                </a-tooltip>

                                <a-tooltip title="Tải / mở">
                                    <a-button size="small" shape="circle" @click="download(item)">
                                        <DownloadOutlined />
                                    </a-button>
                                </a-tooltip>
                            </div>
                        </div>
                    </a-card>
                </a-list-item>
            </template>
        </a-list>
    </a-card>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'
dayjs.locale('vi')

import {
    ReloadOutlined, EyeOutlined, DownloadOutlined, SearchOutlined,
    FilePdfOutlined, FileWordOutlined, FileExcelOutlined, FilePptOutlined, FileTextOutlined,
    UserOutlined
} from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'

// 👉 API wrapper bạn đã có
// export function getMyApprovalInboxFiles() { return instance.get('/approvals/inbox-files') }
import { getMyApprovalInboxFiles } from '@/api/document' // chỉnh path đúng file api của bạn

/* ---------------- state ---------------- */
const loading = ref(false)
const rows    = ref([])
const keyword = ref('')

const current  = ref(1)
const pageSize = ref(10)

/* ---------------- helpers ---------------- */
const IMAGE = new Set(['jpg','jpeg','png','gif','webp','bmp','svg'])
const WORD  = new Set(['doc','docx'])
const EXCEL = new Set(['xls','xlsx','csv'])
const PPT   = new Set(['ppt','pptx'])
const PDF   = new Set(['pdf'])

const extOf = (name='') => {
    const base = String(name).split('?')[0]
    const i = base.lastIndexOf('.')
    return i >= 0 ? base.slice(i+1).toLowerCase() : ''
}
const detectKind = (obj={}) => {
    const src = obj.name || obj.title || obj.url || ''
    const e = extOf(src)
    if (IMAGE.has(e)) return 'image'
    if (PDF.has(e))   return 'pdf'
    if (WORD.has(e))  return 'word'
    if (EXCEL.has(e)) return 'excel'
    if (PPT.has(e))   return 'ppt'
    return 'other'
}
const pickIcon = (kind) => ({
    pdf: FilePdfOutlined, word: FileWordOutlined, excel: FileExcelOutlined, ppt: FilePptOutlined
}[kind] || FileTextOutlined)

const formatDate = (dt) => dt ? dayjs(dt).format('HH:mm DD/MM/YYYY') : '—'
const labelStatus = (s) => {
    s = String(s || '').toLowerCase()
    if (s === 'pending')  return 'Chờ duyệt'
    if (s === 'approved') return 'Đã duyệt'
    if (s === 'rejected') return 'Từ chối'
    return s || '—'
}
const statusColor = (s) => {
    s = String(s || '').toLowerCase()
    if (s === 'pending')  return 'gold'
    if (s === 'approved') return 'green'
    if (s === 'rejected') return 'red'
    return 'default'
}

/* ---------------- data shaping ---------------- */
/**
 * BE (DocumentApprovalController::inboxFiles) trả về:
 * {
 *   items: [{
 *     approval_id, document_id, file_url, name, created_at, status,
 *     markers, signatures, ...
 *   }], total, page, pageSize
 * }
 */
const shaped = computed(() =>
    (rows.value || []).map(r => {
        const kind = detectKind({ name: r.name, url: r.file_url })
        return {
            ...r,
            title: r.title || r.name,
            url: r.file_url,
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
    pageSizeOptions: ['5','10','20','50'],
    onChange: (p, ps) => { current.value = p; pageSize.value = ps }
}))
const onSearch = () => { current.value = 1 }

/* ---------------- actions ---------------- */
function openFile (it) {
    if (!it.url) return
    window.open(it.url, '_blank', 'noopener')
}
function download (it) {
    if (!it.url) return
    window.open(it.url, '_blank', 'noopener')
}

/* ---------------- fetch ---------------- */
async function fetchData () {
    loading.value = true
    try {
        const { data } = await getMyApprovalInboxFiles()
        // ưu tiên `items` nếu có, fallback `data`
        const items = data?.items ?? data?.data ?? []
        rows.value = items
        current.value = 1
    } catch (e) {
        console.error(e)
        message.error(e?.response?.data?.message || 'Không tải được danh sách cần duyệt.')
    } finally {
        loading.value = false
    }
}

onMounted(fetchData)
</script>

<style scoped>
.inbox-files { background: transparent; }
.toolbar { display:flex; gap:12px; align-items:center; justify-content:space-between; flex-wrap:wrap; }
.mt-3 { margin-top: 12px; }

.file-card { width: 100%; }
.row { display:flex; align-items:flex-start; gap:12px; }
.thumb { width: 72px; display:flex; align-items:center; justify-content:center; background:#fafafa; border-radius:8px; height:72px; overflow:hidden; }
.thumb-icon { font-size:28px; opacity:.85; }
.meta { flex:1; min-width:0; }
.title { font-weight:600; font-size:14px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.sub { color:#667; font-size:12px; margin-top:2px; }
.url { display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-top:4px; }
.status { margin-top:6px; display:flex; align-items:center; gap:6px; flex-wrap:wrap; }
.actions { display:flex; gap:6px; align-items:center; }
</style>
