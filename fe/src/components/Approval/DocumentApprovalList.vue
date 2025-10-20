<template>
    <a-card bordered>
        <!-- Bộ lọc -->
        <a-space style="margin-bottom: 12px" align="center" wrap>
            <a-select
                v-model:value="selectedDept"
                :options="departmentOptions"
                placeholder="Chọn phòng ban"
                style="min-width: 240px"
                allowClear
                @change="reload"
            />
            <a-input-search
                v-model:value="q"
                placeholder="Tìm theo tiêu đề"
                allowClear
                style="max-width: 320px"
                @search="reload"
            />
        </a-space>

        <!-- Danh sách -->
        <a-table
            :columns="cols"
            :data-source="pagedRows"
            :loading="loading"
            row-key="rowKey"
            :pagination="false"
            :locale="{ emptyText: 'Không có văn bản' }"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'title'">
                    <div class="title">
                        <a-typography-text>{{ record.title }}</a-typography-text>
                    </div>
                </template>

                <template v-else-if="column.key === 'submitted_at'">
                    {{ formatTime(record.submitted_at) || '—' }}
                </template>

                <!-- cột action -->
                <template v-else-if="column.key === 'action'">
                    <a-space align="center" wrap>
                        <a-button @click="openPreview(record)">Xem</a-button>
                        <a-button
                            type="primary"
                            :loading="approvingId === record.rowKey"
                            :disabled="record.__approved"
                            @click="approveNow(record)"
                        >
                            Duyệt
                        </a-button>
                        <a-button danger @click="reject(record)" :disabled="record.__approved">Từ chối</a-button>
                        <a-button @click="openOriginal(record)" :disabled="!record.file_url">Mở file</a-button>
                        <a-button @click="signAndPreview(record)">Ký thử (ảnh)</a-button>

                        <a-tag v-if="record.__approved" color="green" style="margin-left:6px">
                            <CheckCircleTwoTone twoToneColor="#52c41a" style="margin-right:4px"/>
                            Đã duyệt
                        </a-tag>
                    </a-space>
                </template>
            </template>
        </a-table>

        <!-- Phân trang -->
        <div class="mt-3" v-if="pager.total > 0">
            <a-pagination
                :current="pager.current"
                :pageSize="pager.pageSize"
                :total="pager.total"
                show-size-changer
                :pageSizeOptions="['10','20','50']"
                @change="onPageChange"
                @showSizeChange="onPageSizeChange"
            />
        </div>

        <!-- Modal xem PDF -->
        <a-modal v-model:open="previewOpen" title="Bản Xem trước" :footer="null" width="80%">
            <iframe
                v-if="previewUrl"
                :src="previewUrl"
                style="width:100%;height:78vh;border:none;"
            ></iframe>
        </a-modal>

        <!-- Modal duyệt -->
        <a-modal
            v-model:open="approveOpen"
            title="Thông tin duyệt"
            ok-text="Chèn & Tải xuống"
            cancel-text="Huỷ"
            :confirm-loading="approving"
            @ok="handleApproveSubmit"
        >
            <a-form layout="vertical">
                <a-form-item label="Người duyệt" required>
                    <a-input v-model:value="form.signerName" placeholder="Nhập tên người duyệt"/>
                </a-form-item>

                <a-form-item label="Số văn bản" required extra="Tự sinh: có thể sửa">
                    <a-input v-model:value="form.docNo"/>
                </a-form-item>

                <a-form-item label="Ghi chú (tuỳ chọn)">
                    <a-input v-model:value="form.note"/>
                </a-form-item>

                <a-alert type="info" show-icon>
                    <template #message>
                        Nếu file nguồn là URL khác domain và bị CORS, hãy <b>chọn file PDF từ máy</b> bên dưới.
                    </template>
                </a-alert>

                <a-form-item label="(Tuỳ chọn) Chọn file PDF từ máy để duyệt">
                    <input type="file" accept="application/pdf" @change="onPickLocalPdf"/>
                    <div v-if="localPdfName" class="hint">Đã chọn: {{ localPdfName }}</div>
                </a-form-item>
            </a-form>
        </a-modal>
    </a-card>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import { PDFDocument, rgb } from 'pdf-lib'
import fontkit from '@pdf-lib/fontkit'
import { CheckCircleTwoTone } from '@ant-design/icons-vue'
import { getDocumentsByDepartment, getDocumentById, uploadDocumentToWP } from '@/api/document'
import { approveApproval, getApproval } from '@/api/approvals'
import fontUrl from '@/assets/fonts/Roboto-Regular.ttf?url'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const baseURL = import.meta.env.VITE_API_URL

const props = defineProps({
    mySignatureUrl: { type: String, default: '' }
})

/* ---------- State ---------- */
const approvingId = ref(null)
const previewPdfAb = ref(null)

const selectedDept = ref(null)
const departmentOptions = ref([
    { label: 'Phòng Hành chính - Nhân sự', value: 1 },
    { label: 'Phòng Tài chính - Kế toán', value: 2 },
    { label: 'Phòng Thương mại', value: 3 },
    { label: 'Phòng Dịch vụ - Kỹ thuật', value: 4 },
])

const q = ref('')
const rows = ref([])
const loading = ref(false)

const pager = ref({ current: 1, pageSize: 10, total: 0 })
const pagedRows = computed(() => {
    const start = (pager.value.current - 1) * pager.value.pageSize
    return rows.value.slice(start, start + pager.value.pageSize)
})

const cols = [
    { title: 'Tiêu đề', key: 'title', dataIndex: 'title' },
    { title: 'Gửi lúc', key: 'submitted_at', dataIndex: 'submitted_at', width: 180 },
    { title: 'Tác vụ',  key: 'action',       dataIndex: 'action',       width: 320 },
]

const formatTime = (ts) => (ts ? new Date(ts).toLocaleString('vi-VN') : '')

function nextDocNoLocal() {
    const n = (parseInt(localStorage.getItem('doc_seq') || '0', 10) + 1)
    localStorage.setItem('doc_seq', String(n))
    return n.toString().padStart(2, '0')
}

/* ---------- Proxy helpers ---------- */
function toSameOrigin(url) {
    if (!url) return ''
    try {
        const u = new URL(url, window.location.origin)
        if (u.origin === window.location.origin) {
            return u.pathname + (u.search || '')
        }
        return `/api/proxy?url=${encodeURIComponent(u.href)}`
    } catch {
        return url
    }
}
function toProxyUrl(url) {
    try {
        const u = new URL(url, window.location.origin)
        if (/^https?:/i.test(u) && u.origin !== window.location.origin) {
            return '/pdf-proxy' + u.pathname + (u.search || '')
        }
        return u.pathname + (u.search || '')
    } catch { return url || '' }
}
const isPdfUrl = (u) => typeof u === 'string' && /\.pdf(\?|#|$)/i.test(u || '')
const safeUrl = (p) => {
    const s = String(p || '')
    return /^https?:\/\//i.test(s) ? s : (s ? `${baseURL}/${s}` : '')
}

/* ---------- Fetch strict ---------- */
async function fetchBytesStrict(url, label = 'file') {
    const r = await fetch(url, { cache: 'no-store' })
    if (!r.ok) throw new Error(`Tải ${label} thất bại (${r.status}). URL: ${url}`)
    const ab = await r.arrayBuffer()
    const head = new Uint8Array(ab.slice(0, 16))
    const txt = new TextDecoder().decode(head)
    if (txt.startsWith('<!') || txt.toLowerCase().includes('<html')) {
        throw new Error(`Nhận về HTML thay vì ${label}. Kiểm tra proxy / đường dẫn: ${url}`)
    }
    return ab
}

/* ---------- Font cache ---------- */
let __fontBytesCache = null
async function loadFontBytesCached() {
    if (__fontBytesCache) return __fontBytesCache
    const res = await fetch(fontUrl, { cache: 'force-cache' })
    if (!res.ok) throw new Error('Không tải được font')
    __fontBytesCache = new Uint8Array(await res.arrayBuffer())
    return __fontBytesCache
}

/* ---------- Image helpers ---------- */
function dataUrlToBytes(dataUrl) {
    const base64 = dataUrl.split(',')[1]
    const bin = atob(base64)
    const u8 = new Uint8Array(bin.length)
    for (let i = 0; i < bin.length; i++) u8[i] = bin.charCodeAt(i)
    return u8.buffer
}
function sniffImageType(bytes) {
    const u8 = new Uint8Array(bytes)
    const isPng = u8[0]===0x89 && u8[1]===0x50 && u8[2]===0x4e && u8[3]===0x47 && u8[4]===0x0d && u8[5]===0x0a && u8[6]===0x1a && u8[7]===0x0a
    return isPng ? 'png' : 'jpg'
}
async function embedImageFromUrl(pdfDoc, url, cache) {
    if (!url) return null
    if (cache.has(url)) return cache.get(url)
    let bytes
    if (url.startsWith('data:')) {
        bytes = dataUrlToBytes(url)
    } else {
        bytes = await fetchBytesStrict(toProxyUrl(url), 'ảnh chữ ký')
    }
    const kind = sniffImageType(bytes)
    const img = (kind === 'png') ? await pdfDoc.embedPng(bytes) : await pdfDoc.embedJpg(bytes)
    cache.set(url, img)
    return img
}

/* ---------- Approval data normalize ---------- */
function parseSignedAt(rec) {
    var z = function(n){ return String(n).padStart(2,'0') }
    if (rec && rec.signed_at && rec.signed_at.date && rec.signed_at.time) return rec.signed_at.date + ' ' + rec.signed_at.time
    if (rec && rec.signed_at && rec.signed_at.iso) {
        var d = new Date(rec.signed_at.iso); return z(d.getDate())+'/'+z(d.getMonth()+1)+'/'+d.getFullYear()+' '+z(d.getHours())+':'+z(d.getMinutes())
    }
    if (rec && rec.signed_at && Number.isFinite(rec.signed_at.timestamp)) {
        var ts = rec.signed_at.timestamp > 1e12 ? rec.signed_at.timestamp : rec.signed_at.timestamp*1000
        var d2 = new Date(ts); return z(d2.getDate())+'/'+z(d2.getMonth()+1)+'/'+d2.getFullYear()+' '+z(d2.getHours())+':'+z(d2.getMinutes())
    }
    var d3 = new Date(); return z(d3.getDate())+'/'+z(d3.getMonth()+1)+'/'+d3.getFullYear()+' '+z(d3.getHours())+':'+z(d3.getMinutes())
}
function isSigned(rec) {
    var hasSignedAt = !!(rec && rec.signed_at && (rec.signed_at.date || rec.signed_at.iso || Number.isFinite(rec.signed_at.timestamp)))
    return (rec && (rec.status === 'approved' || rec.status === 'signed')) || hasSignedAt
}
/* chuyển steps BE -> signerRecords */
function stepsToSignerRecords(steps) {
    return (steps||[]).map(function(s, i){
        return {
            signer_id: s.user_id || s.approver_id || (i+1),
            name: s.approver_name || s.name || ('Người ký ' + (i+1)),
            signature_image: s.signature_url || '',
            signed_at: s.approved_at ? { iso: s.approved_at } : (s.signed_at || null),
            order: Number.isFinite(s.order) ? s.order : (i+1),
            position: s.position || null,
            status: s.status || (s.approved_at ? 'signed' : 'pending')
        }
    })
}
async function fetchSignerRecords(instanceId) {
    if (!instanceId) return []
    try {
        const res = await getApproval(instanceId)
        const steps = res && (res.data?.steps || res.data?.data?.steps) || []
        return stepsToSignerRecords(steps)
    } catch {
        return []
    }
}

/* ---------- Core renderer: 3 trên + 1 dưới lệch phải ---------- */
async function renderSignatureSlots(pdfDoc, signerRecords, opts) {
    opts = opts || {}
    var applyAllPages = !!opts.applyAllPages
    var bottomPad = Number.isFinite(opts.bottomPad) ? opts.bottomPad : 48
    var sidePad   = Number.isFinite(opts.sidePad)   ? opts.sidePad   : 40
    var customW   = Number.isFinite(opts.customW)   ? opts.customW   : null
    var customH   = Number.isFinite(opts.customH)   ? opts.customH   : null
    var scalePercent = Number.isFinite(opts.scalePercent) ? opts.scalePercent : 100
    var nameSize  = Number.isFinite(opts.nameSize)  ? opts.nameSize  : 16
    var timeSize  = Number.isFinite(opts.timeSize)  ? opts.timeSize  : 14
    var lineGap   = Number.isFinite(opts.lineGap)   ? opts.lineGap   : 5
    var belowPad  = Number.isFinite(opts.belowPad)  ? opts.belowPad  : 7
    var fallbackImageUrl = (typeof opts.fallbackImageUrl === 'string') ? opts.fallbackImageUrl : null

    if (pdfDoc.registerFontkit) pdfDoc.registerFontkit(fontkit)
    const fontBytes = await loadFontBytesCached()
    const font = await pdfDoc.embedFont(fontBytes, { subset: true })

    const pages = pdfDoc.getPages()
    const targetPages = applyAllPages ? pages : [pages[pages.length - 1]]

    const imageCache = new Map()
    let fallbackSigImg = null
    if (fallbackImageUrl) {
        try { fallbackSigImg = await embedImageFromUrl(pdfDoc, fallbackImageUrl, imageCache) } catch {}
    }

    // Ước lượng tỉ lệ chung để ra slotH đồng nhất
    let aspect = 2.5
    if (fallbackSigImg) aspect = fallbackSigImg.width / fallbackSigImg.height
    else {
        try {
            const first = (signerRecords||[]).find(r => r.signature_image)
            if (first) {
                const tmp = await embedImageFromUrl(pdfDoc, first.signature_image, imageCache)
                if (tmp && tmp.width && tmp.height) aspect = tmp.width / tmp.height
            }
        } catch {}
    }

    const list4 = prepareSignerSlots(signerRecords)

    async function drawOne(page, rec, xLeft, yBottom, slotW, slotH) {
        if (!rec) return

        // Ảnh nào cũng ép đúng kích thước slot (đảm bảo phẳng hàng)
        let img = null
        if (rec.signature_image) {
            try { img = await embedImageFromUrl(pdfDoc, rec.signature_image, imageCache) }
            catch { if (fallbackSigImg) img = fallbackSigImg }
        } else if (fallbackSigImg) img = fallbackSigImg

        const W = slotW
        const H = slotH
        if (img) page.drawImage(img, { x: xLeft, y: yBottom, width: W, height: H })

        const name = rec.name || 'Người ký'
        const timeStr = parseSignedAt(rec)

        const nameW = font.widthOfTextAtSize(name, nameSize)
        const timeW = font.widthOfTextAtSize(timeStr, timeSize)
        const nameX = xLeft + (W - nameW)/2
        const timeX = xLeft + (W - timeW)/2
        const baseY = Math.max(10, yBottom - belowPad - nameSize - timeSize - lineGap)

        page.drawText(name, { x: nameX, y: baseY + timeSize + lineGap, size: nameSize, font, color: rgb(0,0,0) })
        page.drawText(timeStr, { x: timeX, y: baseY, size: timeSize, font, color: rgb(0,0,0) })
    }

    for (const page of targetPages) {
        const { width } = page.getSize()

        const colsTop = 3
        const available = width - sidePad - 10
        let slotW = (customW || (available / (colsTop + 0.5)))
        let gapTop = Math.min(28, Math.max(6, slotW * 0.12))

        // Fit vào vùng lệch phải
        function fit() {
            let total = colsTop * slotW + (colsTop - 1) * gapTop
            if (total <= available) return
            gapTop = 6
            total = colsTop * slotW + (colsTop - 1) * gapTop
            if (total <= available) return
            slotW = (available - (colsTop - 1) * gapTop) / colsTop
        }
        fit()

        // Chiều cao slot cố định cho mọi ảnh
        let slotH = (customH || (slotW / aspect))
        slotH = Math.round(slotH * (scalePercent / 100))

        const totalRowW = colsTop * slotW + (colsTop - 1) * gapTop
        const xStartRight = width - sidePad - totalRowW

        const yBottomRow = bottomPad
        const vGap = 26
        const yTop = yBottomRow + slotH + (nameSize + timeSize + lineGap + belowPad) + vGap

        // Hàng trên (3 ảnh) — cùng yBottom = yTop -> đáy trùng nhau => phẳng hàng
        let x = xStartRight
        for (let i=0;i<3;i++) {
            await drawOne(page, list4[i], x, yTop, slotW, slotH)
            x += slotW + gapTop
        }
        // Hàng dưới (1 ảnh) — căn giữa block
        await drawOne(page, list4[3], xStartRight + (totalRowW - slotW)/2, yBottomRow, slotW, slotH)
    }
}


/* dùng order + position nếu có, lấy chuỗi liên tiếp đã ký từ đầu */
function prepareSignerSlots(records) {
    const sorted = (records||[]).slice().sort(function(a,b){
        const ao = Number.isFinite(a && a.order) ? a.order : 1e9
        const bo = Number.isFinite(b && b.order) ? b.order : 1e9
        return ao - bo
    })
    const seq = []
    for (var i=0;i<sorted.length;i++) {
        var r = sorted[i]
        if (isSigned(r)) seq.push(r); else break
    }
    var top = [null,null,null]
    var bottom = null
    // ưu tiên position
    for (var j=0;j<seq.length;j++) {
        var rr = seq[j]; var pos = rr.position
        if (pos && pos.row==='top' && [0,1,2].includes(pos.index)) {
            if (!top[pos.index]) top[pos.index] = rr
        } else if (pos && pos.row==='bottom') {
            if (!bottom) bottom = rr
        }
    }
    for (var k=0;k<seq.length;k++) {
        var r2 = seq[k]; if (r2.position) continue
        var idx = top.findIndex(function(x){return x===null})
        if (idx !== -1) top[idx] = r2
        else if (!bottom) bottom = r2
    }
    return [top[0], top[1], top[2], bottom]
}

/* ---------- API: get PDF URL ---------- */
async function getPreviewPdfUrl(record) {
    if (record && record.instance_id) {
        try {
            const { data } = await getApproval(record.instance_id)
            const signed = data && data.signed_pdf_url
            if (signed && /\.pdf(\?|#|$)/i.test(signed)) return toProxyUrl(signed)
        } catch (e) { console.warn('getPreviewPdfUrl: getApproval lỗi', e) }
    }
    if (isPdfUrl(record?.file_url)) return toProxyUrl(record.file_url)
    if (isPdfUrl(record?.url))      return toProxyUrl(record.url)

    if (record?.document_id && typeof getDocumentById === 'function') {
        try {
            const doc = await getDocumentById(record.document_id)
            if (isPdfUrl(doc?.file_path)) return toProxyUrl(doc.file_path)
        } catch (e) { console.warn('getPreviewPdfUrl: getDocumentById lỗi', e) }
    }
    return ''
}

/* ---------- List fetch ---------- */
async function fetchRows() {
    loading.value = true
    try {
        const res = await getDocumentsByDepartment(selectedDept.value)
        const docs = Array.isArray(res?.data?.data) ? res.data.data : []
        let adapted = docs
            .filter(d => String(d.file_path || '').toLowerCase().endsWith('.pdf'))
            .map(d => ({
                rowKey: `${d.id}-${d.instance_id ?? 'noinst'}`,
                instance_id: d.instance_id ?? null,
                document_id: d.id,
                title: d.title,
                file_url: safeUrl(d.file_path),
                submitted_at: d.created_at,
                step: d.step ?? null,
                _approver_name: d._approver_name ?? null,
                target_type: 'document',
                target_id: d.id,
            }))

        const text = (q.value || '').trim().toLowerCase()
        if (text) adapted = adapted.filter(r => (r.title || '').toLowerCase().includes(text))

        rows.value = adapted
        pager.value.total = adapted.length
        if ((pager.value.current - 1) * pager.value.pageSize >= pager.value.total) {
            pager.value.current = 1
        }
    } catch (e) {
        console.error(e)
        message.error('Không thể tải danh sách văn bản')
    } finally {
        loading.value = false
    }
}
function reload() { pager.value.current = 1; fetchRows() }
function onPageChange(p) { pager.value.current = p }
function onPageSizeChange(cur, size) { pager.value.pageSize = size; pager.value.current = 1 }

/* ---------- Actions ---------- */
const previewOpen = ref(false)
const previewUrl = ref('')
const approveOpen = ref(false)
const approving = ref(false)
const activeRecord = ref(null)
const localPdfAb = ref(null)
const localPdfName = ref('')

const form = reactive({ signerName: '', docNo: '', note: '' })

function openApproveModal(r) {
    activeRecord.value = r
    approveOpen.value = true
    localPdfAb.value = null
    localPdfName.value = ''
    form.signerName = r._approver_name || ''
    form.docNo = nextDocNoLocal()
    form.note = ''
}
function onPickLocalPdf(e) {
    const f = e.target.files?.[0]
    if (!f) return
    localPdfName.value = f.name
    const reader = new FileReader()
    reader.onload = () => { localPdfAb.value = reader.result }
    reader.readAsArrayBuffer(f)
}

async function openPreview(r) {
    try {
        const rawPdfUrl = await getPreviewPdfUrl(r)
        if (!rawPdfUrl) { message.warning('Không tìm thấy file PDF của văn bản này.'); return }
        previewUrl.value = isPdfUrl(rawPdfUrl) ? toProxyUrl(rawPdfUrl) : toSameOrigin(rawPdfUrl)
        previewOpen.value = true

        const resp = await fetch(toProxyUrl(r.file_url), { cache: 'no-store' })
        if (!resp.ok) throw new Error('Không tải được PDF để ký nối tiếp')
        previewPdfAb.value = await resp.arrayBuffer()
    } catch (e) {
        console.error(e)
        message.error(e?.message || 'Không thể mở bản xem trước')
    }
}
function openOriginal(r) {
    if (!r.file_url) return
    window.open(r.file_url, '_blank', 'noopener')
}

/* ---------- Crypto ---------- */
async function sha256Hex(bufferLike) {
    const ab = bufferLike instanceof ArrayBuffer ? bufferLike : bufferLike.buffer
    if (typeof window !== 'undefined' && window.crypto?.subtle && window.isSecureContext) {
        const hashBuf = await window.crypto.subtle.digest('SHA-256', ab)
        return [...new Uint8Array(hashBuf)].map(b => b.toString(16).padStart(2, '0')).join('')
    }
    const CryptoJS = (await import('crypto-js')).default
    const u8 = new Uint8Array(ab)
    const wordArray = CryptoJS.lib.WordArray.create(u8)
    return CryptoJS.SHA256(wordArray).toString(CryptoJS.enc.Hex)
}

/* ---------- Block text ---------- */
async function stampTextBlock(arrayBuffer, info) {
    const pdfDoc = await PDFDocument.load(arrayBuffer)
    if (pdfDoc.registerFontkit) pdfDoc.registerFontkit(fontkit)
    const fontBytes = await loadFontBytesCached()
    const font = await pdfDoc.embedFont(fontBytes, { subset: true })

    const pages = pdfDoc.getPages()
    const boxW = 220
    const boxH = 46
    const BOTTOM_OFFSET = 16
    const black = rgb(0, 0, 0)
    const red   = rgb(1, 0, 0)
    const white = rgb(1, 1, 1)

    for (const page of pages) {
        const { width } = page.getSize()
        const x = width - boxW - 50
        const y = BOTTOM_OFFSET

        page.drawLine({
            start: { x, y: y + boxH },
            end:   { x: x + boxW, y: y + boxH },
            thickness: 1.0,
            color: black
        })

        page.drawRectangle({
            x, y, width: boxW, height: boxH,
            color: white,
            opacity: 0.85
        })

        const size = 9
        const lineGap = 12
        const line1 = `Ký bởi: ${info.signerName} | Số văn bản: ${info.docNo}`
        const line2 = `Ngày ký: ${info.date} | Giờ ký: ${info.time}`

        const w1 = font.widthOfTextAtSize(line1, size)
        const w2 = font.widthOfTextAtSize(line2, size)
        const blockW = Math.max(w1, w2)
        const blockX = x + (boxW - blockW) / 2

        let cy = y + boxH - size - 4
        page.drawText(line1, { x: blockX, y: cy, size, font, color: red })
        cy -= lineGap
        page.drawText(line2, { x: blockX, y: cy, size, font, color: red })
    }

    return await pdfDoc.save()
}

/* ---------- Unified flows ---------- */
// Ký thử: thêm “mình” là người kế tiếp (giả lập signed), rồi render theo layout
// ==== REPLACE your signAndPreview with this version ====
async function signAndPreview(r) {
    try {
        // 1) Lấy PDF nguồn
        const pdfUrl = await getPreviewPdfUrl(r)
        if (!pdfUrl) { message.warning('Không tìm thấy file PDF để ký thử'); return }
        const baseAb = await fetchBytesStrict(pdfUrl, 'PDF')
        const pdfDoc = await PDFDocument.load(baseAb)
        if (pdfDoc.registerFontkit) pdfDoc.registerFontkit(fontkit)

        // 2) Font Unicode (giống btnRun: ưu tiên font tuỳ chọn -> NotoSans -> Helvetica)
        // Ở đây dùng font local Roboto bạn đã bundle để ổn định Unicode
        const fontBytes = await loadFontBytesCached()
        const font = await pdfDoc.embedFont(fontBytes, { subset: true })

        // 3) Dữ liệu người ký (giống btnRun):
        //    - Lấy từ BE (steps) → chuyển thành signerRecords
        //    - Thêm “người ký thử” (bạn) vào cuối, status=signed
        const signerRecords = await fetchSignerRecords(r.instance_id)
        const now = new Date()
        const myName = userStore.user?.name || userStore.user?.full_name || 'Người duyệt'
        const mySig  = (props.mySignatureUrl || '').trim()
        if (!mySig) { message.warning('Bạn chưa có chữ ký cá nhân. Vào hồ sơ người dùng để tải chữ ký.'); return }
        signerRecords.push({
            signer_id: 'me-preview',
            name: myName,
            signature_image: mySig,
            signed_at: { iso: now.toISOString() },
            order: (signerRecords.length + 1),
            status: 'signed'
        })

        // 4) Fallback image (nếu URL ảnh lỗi)
        let fallbackSigImg = null
        const imageCache = new Map()
        async function embedImageFromUrlLocal(url) {
            if (!url) return null
            if (imageCache.has(url)) return imageCache.get(url)
            let bytes
            if (url.startsWith('data:')) {
                bytes = dataUrlToBytes(url)
            } else {
                bytes = await fetchBytesStrict(toProxyUrl(url), 'ảnh chữ ký')
            }
            const kindIsPng = (() => {
                const u8 = new Uint8Array(bytes)
                return u8[0]===0x89 && u8[1]===0x50 && u8[2]===0x4e && u8[3]===0x47 && u8[4]===0x0d && u8[5]===0x0a && u8[6]===0x1a && u8[7]===0x0a
            })()
            const img = kindIsPng ? await pdfDoc.embedPng(bytes) : await pdfDoc.embedJpg(bytes)
            imageCache.set(url, img)
            return img
        }
        try { fallbackSigImg = await embedImageFromUrlLocal(mySig) } catch { /* optional */ }

        // 5) ƯỚC LƯỢNG TỈ LỆ ẢNH (aspect) giống demo
        let aspect = 2.5
        if (fallbackSigImg) aspect = fallbackSigImg.width / fallbackSigImg.height
        else {
            try {
                const first = signerRecords.find(r => r.signature_image)
                if (first) {
                    const tmp = await embedImageFromUrlLocal(first.signature_image)
                    if (tmp && tmp.width && tmp.height) aspect = tmp.width / tmp.height
                }
            } catch {}
        }

        // 6) Tham số UI giống demo
        const nameSize = 16, timeSize = 14, lineGap = 5, belowPad = 7
        const bottomPad = 48    // tương đương $('bottomPt') trong demo
        const sidePad   = 40    // tương đương $('sidePt')
        const scaleFactor = 1.0 // tương đương slider 100%

        // Chuẩn bị slot theo “ký theo thứ tự”
        const list4 = prepareSignerSlots(signerRecords)

        // Thu thập URL ảnh hỏng (để warn)
        const failedUrls = []

        async function drawOne(page, rec, xLeft, yBottom, w) {
            if (!rec) return
            let img = null
            if (rec.signature_image) {
                try { img = await embedImageFromUrlLocal(rec.signature_image) }
                catch (e) {
                    failedUrls.push(rec.signature_image)
                    if (fallbackSigImg) img = fallbackSigImg
                }
            } else if (fallbackSigImg) img = fallbackSigImg

            const H = Math.round((w / aspect) * scaleFactor)
            if (img) page.drawImage(img, { x: xLeft, y: yBottom, width: w, height: H })

            const name = rec.name || 'Người ký'
            const timeStr = parseSignedAt(rec)
            const nameW = font.widthOfTextAtSize(name, nameSize)
            const timeW = font.widthOfTextAtSize(timeStr, timeSize)
            const nameX = xLeft + (w - nameW) / 2
            const timeX = xLeft + (w - timeW) / 2
            const baseY = Math.max(10, yBottom - belowPad - nameSize - timeSize - lineGap)

            page.drawText(name, { x: nameX, y: baseY + timeSize + lineGap, size: nameSize, font, color: rgb(0,0,0) })
            page.drawText(timeStr, { x: timeX, y: baseY, size: timeSize, font, color: rgb(0,0,0) })

            return H
        }

        // 7) Vẽ giống y hệt demo: bố cục lệch phải (3 trên + 1 dưới)
        const pages = pdfDoc.getPages()
        const targetPages = [pages[pages.length - 1]] // demo mặc định 1 trang cuối; muốn allPages thì đổi ở đây

        for (const page of targetPages) {
            const { width } = page.getSize()
            const colsTop = 3
            const available = width - sidePad - 10 // chừa 10pt trái giống demo
            // baseW = available / (colsTop + 0.5)
            let sigW = (available / (colsTop + 0.5)) * scaleFactor
            let sigH = Math.round(sigW / aspect)

            // Gap động
            const minGap = 6, maxGap = 28
            let gapTop = Math.min(maxGap, Math.max(minGap, sigW * 0.12))

            // Fit vào available (giữ gap tối thiểu)
            function fitWithinAvailable() {
                let total = colsTop * sigW + (colsTop - 1) * gapTop
                if (total <= available) return
                gapTop = minGap
                total = colsTop * sigW + (colsTop - 1) * gapTop
                if (total <= available) return
                sigW = (available - (colsTop - 1) * gapTop) / colsTop
                sigH = Math.round(sigW / aspect)
            }
            fitWithinAvailable()

            const totalRowWidth = colsTop * sigW + (colsTop - 1) * gapTop
            const xStartRight = width - sidePad - totalRowWidth

            // Hàng dưới (đáy ảnh)
            const yBottomRow = bottomPad
            // Hàng trên = hàng dưới + cao ảnh + nhãn + vGap
            const vGap = 26
            const yTop = yBottomRow + sigH + (nameSize + timeSize + lineGap + belowPad) + vGap

            // Vẽ 3 chữ ký hàng trên
            let x = xStartRight
            for (let i = 0; i < 3; i++) {
                const rec = list4[i]
                if (rec) await drawOne(page, rec, x, yTop, sigW)
                x += sigW + gapTop
            }

            // Vẽ 1 chữ ký hàng dưới (căn giữa block phải)
            const bottomRec = list4[3]
            if (bottomRec) {
                const xCenter = xStartRight + (totalRowWidth - sigW) / 2
                await drawOne(page, bottomRec, xCenter, yBottomRow, sigW)
            }
        }

        // 8) Cảnh báo URL ảnh lỗi (nếu có)
        if (failedUrls.length) {
            message.warning(`Một số ảnh chữ ký không tải được và đã dùng ảnh fallback:\n- ` + failedUrls.join('\n- '))
        }

        // 9) Xuất xem trước
        const outBytes = await pdfDoc.save()
        const blob = new Blob([outBytes], { type: 'application/pdf' })
        previewUrl.value = URL.createObjectURL(blob)
        previewOpen.value = true
    } catch (e) {
        console.error(e)
        message.error(e?.message || 'Ký thử thất bại (CORS hoặc URL không hợp lệ)')
    }
}


// Duyệt nhanh: mình là người kế tiếp thật → render + upload + notify BE
async function approveNow(r) {
    if (approvingId.value) return
    try {
        approvingId.value = r.rowKey

        const signerName = userStore.user?.name || userStore.user?.full_name || 'Người duyệt'
        const sigUrlRaw  = props.mySignatureUrl || ''
        if (!sigUrlRaw) { message.warning('Bạn chưa có chữ ký cá nhân. Vào hồ sơ người dùng để tải chữ ký.'); return }

        const pdfUrl = await getPreviewPdfUrl(r)
        if (!pdfUrl) { message.warning('Không tìm thấy file PDF để duyệt'); return }

        const baseAb  = await fetchBytesStrict(pdfUrl, 'PDF')
        const pdfDoc  = await PDFDocument.load(baseAb)

        const signerRecords = await fetchSignerRecords(r.instance_id)
        const now = new Date()
        signerRecords.push({
            signer_id: 'me',
            name: signerName,
            signature_image: sigUrlRaw,
            signed_at: { iso: now.toISOString() },
            order: (signerRecords.length + 1),
            status: 'signed'
        })

        await renderSignatureSlots(pdfDoc, signerRecords, {
            applyAllPages:false, sidePad:40, bottomPad:48, scalePercent:100, fallbackImageUrl: sigUrlRaw
        })

        const stampedAb = await pdfDoc.save()

        // upload bản đã ký lên WP
        const file = new File([stampedAb], `signed_${r.title || 'document'}.pdf`, { type: 'application/pdf' })
        const fd   = new FormData()
        fd.append('file', file)
        fd.append('title', `Đã duyệt - ${r.title || 'document'}`)
        fd.append('department_id', String(r.department_id || selectedDept.value || 1))
        fd.append('visibility', 'department')

        const upRes = await uploadDocumentToWP(fd)
        const signedPdfUrl = upRes?.data?.url || upRes?.data?.data?.url
        if (!signedPdfUrl) throw new Error('Upload PDF đã ký thất bại')

        // Gọi BE lưu vết
        const nowStr = new Date().toLocaleString('vi-VN')
        if (r.instance_id) {
            await approveApproval(r.instance_id, {
                note: `Đã duyệt bởi ${signerName} lúc ${nowStr}`,
                signature_url: sigUrlRaw,
                signed_pdf_url: signedPdfUrl,
            })
        }

        // UI
        const row = rows.value.find(x => x.rowKey === r.rowKey)
        if (row) row.__approved = true
        previewUrl.value = URL.createObjectURL(new Blob([stampedAb], { type: 'application/pdf' }))
        previewOpen.value = true
        message.success('Duyệt & chèn chữ ký thành công')
    } catch (e) {
        console.error(e)
        message.error(e?.message || 'Duyệt thất bại')
    } finally {
        approvingId.value = null
    }
}

/* Duyệt & tải xuống: render chữ ký theo layout rồi đóng block text, tải về + evidence */
async function handleApproveSubmit() {
    if (!form.signerName || !form.docNo) {
        message.warning('Vui lòng nhập Người duyệt và Số văn bản')
        return
    }
    const r = activeRecord.value
    if (!r) return

    approving.value = true
    try {
        // 1) Chọn nguồn PDF
        let baseAb
        if (previewPdfAb?.value) {
            baseAb = previewPdfAb.value
        } else if (localPdfAb?.value) {
            baseAb = localPdfAb.value
        } else {
            const rawPdfUrl = await getPreviewPdfUrl(r)
            if (!rawPdfUrl) throw new Error('Không tìm thấy PDF nguồn')
            const resp = await fetch(toSameOrigin(rawPdfUrl), { cache: 'no-store' })
            if (!resp.ok) throw new Error('Tải PDF thất bại (CORS?)')
            baseAb = await resp.arrayBuffer()
        }

        const beforeHash = await sha256Hex(baseAb)

        // 2) Chèn chữ ký của mình theo layout chung (nếu có ảnh chữ ký)
        let stampedAb = baseAb
        if (props?.mySignatureUrl) {
            try {
                const pdfDoc = await PDFDocument.load(stampedAb)
                const signerRecords = await fetchSignerRecords(r.instance_id)
                const now = new Date()
                signerRecords.push({
                    signer_id: 'me-approve',
                    name: form.signerName || userStore.user?.name || 'Người duyệt',
                    signature_image: props.mySignatureUrl,
                    signed_at: { iso: now.toISOString() },
                    order: (signerRecords.length + 1),
                    status: 'signed'
                })
                await renderSignatureSlots(pdfDoc, signerRecords, {
                    applyAllPages:false, sidePad:40, bottomPad:48, scalePercent:100, fallbackImageUrl: props.mySignatureUrl
                })
                stampedAb = await pdfDoc.save()
            } catch (e) {
                console.warn('Chèn ảnh chữ ký thất bại, vẫn tiếp tục đóng block text.', e)
            }
        }

        // 3) Đóng block text
        const now = new Date()
        const info = {
            signerName: form.signerName,
            docNo: `TTID${String(form.docNo).padStart(3, '0')}`,
            time: now.toLocaleTimeString('vi-VN'),
            date: now.toLocaleDateString('vi-VN'),
            note: form.note || ''
        }
        stampedAb = await stampTextBlock(stampedAb, info)

        // 4) Hash sau
        const afterHash = await sha256Hex(stampedAb)

        // 5) Cập nhật preview + tải xuống
        previewPdfAb.value = stampedAb

        const blob = new Blob([stampedAb], { type: 'application/pdf' })
        const url = URL.createObjectURL(blob)
        previewUrl.value = url
        previewOpen.value = true

        const a = document.createElement('a')
        a.href = url
        a.download = `signed_${r.title || 'document'}.pdf`
        a.click()

        // 6) Evidence JSON (offline)
        const evidence = {
            version: 1,
            generatedAt: now.toISOString(),
            title: r.title,
            document_id: r.document_id,
            file_url: r.file_url,
            signerName: info.signerName,
            docNo: info.docNo,
            date: info.date,
            time: info.time,
            note: info.note,
            userAgent: navigator.userAgent,
            hashes: { before_sha256: beforeHash, after_sha256: afterHash }
        }
        const evBlob = new Blob([JSON.stringify(evidence, null, 2)], { type: 'application/json' })
        const evUrl = URL.createObjectURL(evBlob)
        const evA = document.createElement('a')
        evA.href = evUrl
        evA.download = `evidence_${info.docNo}.json`
        evA.click()

        // 7) Cờ UI
        approveOpen.value = false
        const row = rows.value.find(x => x.document_id === r.document_id)
        if (row) row.__approved = true

        message.success('Đã chèn chữ ký & cập nhật bản xem thử')

        // (Tuỳ chọn) gọi BE approve:
        // if (r.instance_id) {
        //   await approveApproval(r.instance_id, {
        //     note: `Duyệt số văn bản ${info.docNo}`,
        //     signature_url: props?.mySignatureUrl || null
        //   })
        //   await reload()
        // }

    } catch (e) {
        console.error(e)
        message.error(e?.message || 'Duyệt thất bại (CORS hoặc file lỗi)')
    } finally {
        approving.value = false
    }
}

/* ---------- Reject demo ---------- */
async function reject(r) {
    try { message.success('(Demo) Đã từ chối cục bộ') }
    catch { message.error('Từ chối thất bại') }
}

onMounted(fetchRows)
</script>

<style scoped>
.mt-3 { margin-top: 12px; }
.title { display: flex; align-items: center; }
.hint { font-size: 12px; color: #888; margin-top: 4px; }
</style>
