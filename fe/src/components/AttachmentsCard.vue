<template>
    <a-card bordered class="doc-section">
        <!-- SPIN LOADING -->
        <a-spin :spinning="loading" tip="Đang tải tài liệu...">
            <!-- ============== PREVIEW: chỉ từ bình luận ============== -->
            <a-list
                v-if="displayCards.length"
                class="att-grid"
                :grid="{ gutter: 8, xs: 1, sm: 2, md: 3, lg: 4, xl: 4 }"
                :data-source="displayCards"
            >
                <template #renderItem="{ item }">
                    <a-list-item>
                        <a-card hoverable class="att-card att-card--sm" :bodyStyle="{ padding: '10px 10px 8px' }">
                            <template #extra>
                                <a-tag color="blue">Từ bình luận</a-tag>
                            </template>

                            <!-- ẢNH -->
                            <template v-if="item.kind === 'image'">
                                <a-image :src="item.url" :height="thumbH" :alt="item.name" />
                            </template>

                            <!-- LINK -->
                            <template v-else-if="item.kind === 'link'">
                                <div class="att-link-thumb">
                                    <img :src="favicon(item.url)" class="att-favicon" referrerpolicy="no-referrer" @error="hideBrokenFavicon" />
                                    <LinkOutlined class="att-link-icon" />
                                </div>
                            </template>

                            <!-- FILE khác -->
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
                            </div>

                            <!-- badges -->
                            <span v-if="item.ext" class="att-ext">{{ item.ext }}</span>
                        </a-card>
                    </a-list-item>
                </template>
            </a-list>

            <a-empty v-else>
                <template #description>Chưa có tài liệu (từ bình luận)</template>
            </a-empty>
        </a-spin>
    </a-card>
</template>

<script setup>
import {
    LinkOutlined, EyeOutlined, DownloadOutlined,
    FilePdfOutlined, FileWordOutlined, FileExcelOutlined, FilePptOutlined, FileTextOutlined
} from '@ant-design/icons-vue'
import { computed, onMounted, ref, watch } from 'vue'
import { message } from 'ant-design-vue'
import { parseApiError } from '@/utils/apiError'
import { getComments } from '@/api/task'

const props = defineProps({
    taskId: { type: [String, Number], required: true }
})

const thumbH = 96
const commentFileItems = ref([])
const loading = ref(false) // ✅ spinner state

const IMAGE_EXTS = new Set(['jpg','jpeg','png','gif','webp','bmp','svg'])
const PDF_EXTS   = new Set(['pdf'])
const WORD_EXTS  = new Set(['doc','docx'])
const EXCEL_EXTS = new Set(['xls','xlsx','csv'])
const PPT_EXTS   = new Set(['ppt','pptx'])

function extOf(name = '') {
    const n = String(name).split('?')[0]
    const i = n.lastIndexOf('.')
    return i >= 0 ? n.slice(i + 1).toLowerCase() : ''
}

function detectKind({ is_link, name, file_type, mime_type, url }) {
    const ft = String(mime_type || file_type || '').toLowerCase()
    const e  = extOf(name || url || '')
    if (is_link) return 'link'
    if (ft.startsWith('image/') || IMAGE_EXTS.has(e)) return 'image'
    if (PDF_EXTS.has(e))   return 'pdf'
    if (WORD_EXTS.has(e))  return 'word'
    if (EXCEL_EXTS.has(e)) return 'excel'
    if (PPT_EXTS.has(e))   return 'ppt'
    return 'other'
}

function pickIcon(kind) {
    switch (kind) {
        case 'pdf': return FilePdfOutlined
        case 'word': return FileWordOutlined
        case 'excel': return FileExcelOutlined
        case 'ppt': return FilePptOutlined
        case 'link': return LinkOutlined
        default: return FileTextOutlined
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

function favicon() {
    return 'https://assets.develop.io.vn/wp-content/uploads/2025/10/favicon.png';
}

function hideBrokenFavicon(e) {
    if (e?.target) e.target.style.opacity = 0
}

function normalizeKey(url = '') {
    return String(url || '').split('?')[0]
}

const displayCards = computed(() => commentFileItems.value)

/** Lấy file từ bình luận */
async function fetchAllCommentFiles() {
    if (!props.taskId) return
    loading.value = true // ✅ bật spin
    const acc = []
    const seen = new Set()
    try {
        let page = 1
        while (true) {
            const res = await getComments(props.taskId, { page })
            const comments = res?.data?.comments || []
            const totalPages = res?.data?.pagination?.totalPages || 1

            for (const c of comments) {
                for (const f of (c.files || [])) {
                    const isLink = !!f.link_url && !f.file_path
                    const url = isLink ? (f.link_url || '') : (f.file_path || '')
                    const key = normalizeKey(url)
                    if (!key || seen.has(key)) continue
                    seen.add(key)

                    const kind = detectKind({
                        is_link: isLink,
                        name: f.file_name,
                        file_type: f.file_type,
                        mime_type: f.mime_type,
                        url
                    })
                    acc.push({
                        id: f.id,
                        name: f.file_name || '',
                        title: f.title || '',
                        url,
                        is_link: isLink,
                        kind,
                        icon: pickIcon(kind),
                        ext: extOf(f.file_name || url),
                        _source: 'comment',
                        full: { ...f, comment_id: c.id },
                    })
                }
            }

            if (page >= totalPages) break
            page++
        }
    } catch (e) {
        console.error('fetchAllCommentFiles error', e)
        message.error(parseApiError(e) || 'Không tải được file từ bình luận.')
    } finally {
        loading.value = false // ✅ tắt spin
    }
    commentFileItems.value = acc
}

function openAttachment(it) {
    const url = encodeURIComponent(it.url)
    const ext = (it.ext || '').toLowerCase()
    const officeExts = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx']
    if (officeExts.includes(ext)) {
        window.open(`https://view.officeapps.live.com/op/view.aspx?src=${url}`, '_blank', 'noopener')
    } else if (ext === 'pdf') {
        window.open(it.url, '_blank', 'noopener')
    } else {
        window.open(it.url, '_blank', 'noopener')
    }
}

function downloadAttachment(it) {
    window.open(it.url, '_blank', 'noopener')
}

onMounted(fetchAllCommentFiles)
watch(() => props.taskId, fetchAllCommentFiles)
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
.att-ext { position:absolute; top:6px; right:6px; font-size:10px; padding:0 6px; background:#f0f1f5; border-radius:999px; text-transform:uppercase; color:#555; }
</style>

<style>
.ant-list-item {
    padding-left: 0 !important;
    padding-right: 0 !important;
}
</style>
