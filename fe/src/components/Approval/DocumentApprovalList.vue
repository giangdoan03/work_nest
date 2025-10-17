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
                allow-clear
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
                    <a-space align="center">
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
                :src="`/pdfjs/viewer.html?file=${encodeURIComponent(previewUrl)}`"
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
import {getDocumentsByDepartment, getDocumentDetail, getDocumentById} from '@/api/document'
import fontUrl from '@/assets/fonts/Roboto-Regular.ttf?url'

import { useUserStore } from '@/stores/user'
const userStore = useUserStore()

const baseURL = import.meta.env.VITE_API_URL

const props = defineProps({
    mySignatureUrl: { type: String, default: '' }
})

const approvingId = ref(null)  // loading theo từng row

import { uploadDocumentToWP } from '@/api/document'
import { approveApproval, getApproval } from '@/api/approvals'

/* ================= helpers URL / proxy ================= */
const previewPdfAb = ref(null)


async function approveNow(r) {
    if (approvingId.value) return
    try {
        approvingId.value = r.rowKey

        // 1) kiểm tra chữ ký cá nhân
        const signerName = userStore.user?.name || userStore.user?.full_name || 'Người duyệt'
        const sigUrlRaw  = props.mySignatureUrl || ''
        if (!sigUrlRaw) {
            message.warning('Bạn chưa có chữ ký cá nhân. Vào hồ sơ người dùng để tải chữ ký.')
            return
        }

        // 2) Lấy PDF nguồn + xác định slot (không chồng lên chữ ký trước)
        const pdfUrl = await getPreviewPdfUrl(r)
        if (!pdfUrl) { message.warning('Không tìm thấy file PDF để duyệt'); return }

        const baseAb  = await fetchBytesStrict(pdfUrl, 'PDF')
        const pdfDoc  = await PDFDocument.load(baseAb)

        const idx = await getNextSignatureIndex(r.instance_id) // số chữ ký đã có
        const last = pdfDoc.getPage(pdfDoc.getPageCount() - 1)
        const { width: pageW } = last.getSize()
        const pos = computeSignaturePosition(pageW, idx)

        // 3) nhúng ảnh chữ ký và vẽ theo vị trí tính sẵn
        const imgAb = await fetchBytesStrict(toProxyUrl(sigUrlRaw), 'ảnh chữ ký')
        const sig   = await embedImageAuto(pdfDoc, imgAb)
        last.drawImage(sig, { x: pos.x, y: pos.y, width: pos.sigW, height: pos.sigH })

        // 4) caption dưới mỗi chữ ký (tên + ngày giờ)
        // 4) caption dưới mỗi chữ ký (tên + ngày giờ) — DÙNG FONT UNICODE
        const now = new Date()
        const cap1 = signerName
        const cap2 = `Ký: ${now.toLocaleDateString('vi-VN')} ${now.toLocaleTimeString('vi-VN')}`

// 👇 Nhúng font Unicode (Roboto) thay cho StandardFonts.Helvetica
        pdfDoc.registerFontkit(fontkit)
        const fontBytes = await loadFontBytes()          // bạn đã có hàm này ở dưới
        const vnFont = await pdfDoc.embedFont(fontBytes, { subset: true })

        const capSize = 8
        last.drawText(cap1, { x: pos.x, y: pos.y - (capSize + pos.gapY), size: capSize, font: vnFont })
        last.drawText(cap2, { x: pos.x, y: pos.y - (2 * capSize + pos.gapY + 2), size: capSize, font: vnFont })


        const stampedAb = await pdfDoc.save()

        // 5) upload bản đã ký lên WP
        const file = new File([stampedAb], `signed_${r.title || 'document'}.pdf`, { type: 'application/pdf' })
        const fd   = new FormData()
        fd.append('file', file)
        fd.append('title', `Đã duyệt - ${r.title || 'document'}`)
        fd.append('department_id', String(r.department_id || selectedDept.value || 1))
        fd.append('visibility', 'department')

        const upRes = await uploadDocumentToWP(fd)
        const signedPdfUrl = upRes?.data?.url || upRes?.data?.data?.url
        if (!signedPdfUrl) throw new Error('Upload PDF đã ký thất bại')

        // 6) Gọi BE để lưu vết + giữ URL bản đã ký
        const nowStr = new Date().toLocaleString('vi-VN')
        if (r.instance_id) {
            await approveApproval(r.instance_id, {
                note: `Đã duyệt bởi ${signerName} lúc ${nowStr}`,
                signature_url: sigUrlRaw,
                signed_pdf_url: signedPdfUrl,
            })
        }

        // 7) Cập nhật UI + mở preview bản đã ký
        const row = rows.value.find(x => x.rowKey === r.rowKey)
        if (row) row.__approved = true
        previewUrl.value = toProxyUrl(signedPdfUrl)
        previewOpen.value = true
        message.success('Duyệt & chèn chữ ký thành công')
    } catch (e) {
        console.error(e)
        message.error(e?.message || 'Duyệt thất bại')
    } finally {
        approvingId.value = null
    }
}


function toSameOrigin(url) {
    if (!url) return ''
    try {
        const u = new URL(url, window.location.origin)
        if (u.origin === window.location.origin) {
            return u.pathname + (u.search || '')
        }
        // Nếu khác origin → dùng BE proxy (ví dụ /api/proxy?url=)
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

/** Lấy URL PDF để xem/ ký (từ record + fallback gọi chi tiết tài liệu) */

async function getPreviewPdfUrl(record) {
    // Ưu tiên: nếu có instance_id -> lấy bản đã ký gần nhất
    if (record?.instance_id) {
        try {
            const { data } = await getApproval(record.instance_id)
            const signed = data?.signed_pdf_url
            if (signed && /\.pdf(\?|#|$)/i.test(signed)) {
                return toProxyUrl(signed) // 👈 dùng bản đã ký gần nhất
            }
        } catch (e) {
            console.warn('getPreviewPdfUrl: getApproval lỗi', e)
        }
    }

    // fallback: từ chính record / document detail
    if (isPdfUrl(record?.file_url)) return toProxyUrl(record.file_url)
    if (isPdfUrl(record?.url))      return toProxyUrl(record.url)

    if (record?.document_id && typeof getDocumentById === 'function') {
        try {
            const doc = await getDocumentById(record.document_id)
            if (isPdfUrl(doc?.file_path)) return toProxyUrl(doc.file_path)
        } catch (e) {
            console.warn('getPreviewPdfUrl: getDocumentById lỗi', e)
        }
    }

    return ''
}

/* =============== fetch strict =============== */
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

function detectImageType(u8) {
    if (u8[0] === 0x89 && u8[1] === 0x50 && u8[2] === 0x4E && u8[3] === 0x47) return 'png'
    if (u8[0] === 0xFF && u8[1] === 0xD8 && u8[2] === 0xFF) return 'jpg'
    return 'unknown'
}

async function embedImageAuto(pdfDoc, imgAb) {
    const u8 = new Uint8Array(imgAb)
    const kind = detectImageType(u8)
    if (kind === 'png') return pdfDoc.embedPng(imgAb)
    if (kind === 'jpg') return pdfDoc.embedJpg(imgAb)
    throw new Error('Unsupported image format (need PNG or JPG)')
}

async function signPdfOnLastPage(pdfUrl, signUrl) {
    const pdfBytes = await fetchBytesStrict(toProxyUrl(pdfUrl), 'PDF');
    const pdfDoc = await PDFDocument.load(pdfBytes);

    const imgAb = await fetchBytesStrict(toProxyUrl(signUrl), 'ảnh chữ ký');
    const sig = await embedImageAuto(pdfDoc, imgAb);

    const last = pdfDoc.getPage(pdfDoc.getPageCount() - 1);
    const { width } = last.getSize();
    const sigW = 140, sigH = 60;
    last.drawImage(sig, { x: width - sigW - 48, y: 48, width: sigW, height: sigH });

    const out = await pdfDoc.save();
    return URL.createObjectURL(new Blob([out], { type: 'application/pdf' }));
}

/* ===================== state ===================== */
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

/* ===================== table ===================== */
const cols = [
    { title: 'Tiêu đề', key: 'title', dataIndex: 'title' },
    { title: 'Gửi lúc', key: 'submitted_at', dataIndex: 'submitted_at', width: 180 },
    { title: 'Tác vụ',  key: 'action',       dataIndex: 'action',       width: 320 },
]

/* ===================== utils ===================== */
const formatTime = (ts) => (ts ? new Date(ts).toLocaleString('vi-VN') : '')

function nextDocNoLocal() {
    const n = (parseInt(localStorage.getItem('doc_seq') || '0', 10) + 1)
    localStorage.setItem('doc_seq', String(n))
    return n.toString().padStart(2, '0')
}

/* =============== fetch rows =============== */
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
                file_url: safeUrl(d.file_path), // có thể là relative → baseURL + path
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

function reload() {
    pager.value.current = 1
    fetchRows()
}
function onPageChange(p) { pager.value.current = p }
function onPageSizeChange(cur, size) { pager.value.pageSize = size; pager.value.current = 1 }

/* =============== actions =============== */
async function openPreview(r) {
    try {
        const rawPdfUrl = await getPreviewPdfUrl(r)
        if (!rawPdfUrl) { message.warning('Không tìm thấy file PDF của văn bản này.'); return }
        previewUrl.value = isPdfUrl(rawPdfUrl) ? toProxyUrl(rawPdfUrl) : toSameOrigin(rawPdfUrl)
        previewOpen.value = true

        // reset đếm ký thử cho văn bản này
        previewSigLocal.value[keyOf(r)] = 0

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

const previewOpen = ref(false)
const previewUrl = ref('')

/* =============== approve modal =============== */
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

/* =============== crypto / font =============== */
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

async function loadFontBytes() {
    const res = await fetch(fontUrl)
    if (!res.ok) throw new Error('Không tải được font')
    return new Uint8Array(await res.arrayBuffer())
}

/* =============== stamp block text =============== */
async function stampTextBlock(arrayBuffer, info) {
    const pdfDoc = await PDFDocument.load(arrayBuffer)
    pdfDoc.registerFontkit(fontkit)
    const fontBytes = await loadFontBytes()
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

/* =============== ký thử (ảnh) =============== */
async function signAndPreview(r) {
    try {
        const pdfUrl = await getPreviewPdfUrl(r)
        if (!pdfUrl) { message.warning('Không tìm thấy file PDF để ký thử'); return }
        const rawSig = props.mySignatureUrl || ''
        if (!rawSig) { message.warning('Bạn chưa có chữ ký cá nhân. Vào hồ sơ người dùng để tải chữ ký.'); return }

        const baseAb = await fetchBytesStrict(pdfUrl, 'PDF')
        const pdfDoc = await PDFDocument.load(baseAb)

        // ✅ index = approved trên BE + ký thử local
        const approvedIdx = await getNextSignatureIndex(r.instance_id)
        const key = keyOf(r)
        const localIdx = previewSigLocal.value[key] || 0
        const idx = approvedIdx + localIdx

        const last = pdfDoc.getPage(pdfDoc.getPageCount() - 1)
        const { width: pageW } = last.getSize()
        const pos = computeSignaturePosition(pageW, idx)

        const imgAb = await fetchBytesStrict(toProxyUrl(rawSig), 'ảnh chữ ký')
        const sig = await embedImageAuto(pdfDoc, imgAb)
        last.drawImage(sig, { x: pos.x, y: pos.y, width: pos.sigW, height: pos.sigH })

        // caption Unicode
        pdfDoc.registerFontkit(fontkit)
        const fontBytes = await loadFontBytes()
        const vnFont = await pdfDoc.embedFont(fontBytes, { subset: true })
        const now = new Date()
        const cap1 = userStore.user?.name || userStore.user?.full_name || 'Người duyệt'
        const cap2 = `Ký: ${now.toLocaleDateString('vi-VN')} ${now.toLocaleTimeString('vi-VN')}`
        const capSize = 8
        last.drawText(cap1, { x: pos.x, y: pos.y - (capSize + pos.gapY), size: capSize, font: vnFont })
        last.drawText(cap2, { x: pos.x, y: pos.y - (2 * capSize + pos.gapY + 2), size: capSize, font: vnFont })

        const out = await pdfDoc.save()
        previewUrl.value = URL.createObjectURL(new Blob([out], { type: 'application/pdf' }))
        previewOpen.value = true

        // ✅ tăng bộ đếm ký thử cho lần sau
        previewSigLocal.value[key] = localIdx + 1
    } catch (e) {
        console.error(e)
        message.error(e?.message || 'Ký thử thất bại (CORS hoặc URL không hợp lệ)')
    }
}



/* =============== approve (chèn ký + text, cập nhật preview) =============== */
async function handleApproveSubmit() {
    if (!form.signerName || !form.docNo) {
        message.warning('Vui lòng nhập Người duyệt và Số văn bản')
        return
    }
    const r = activeRecord.value
    if (!r) return

    approving.value = true
    try {
        // 1) Chọn nguồn PDF: preview -> local -> fetch URL
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

        // 2) Nếu có ảnh chữ ký cá nhân → chèn trước
        let stampedAb = baseAb
        if (props?.mySignatureUrl) {
            const withSignatureImage = async (pdfAb, signatureUrl, opt = {}) => {
                const { xRightPadding = 48, yBottom = 48, width = 140, height = 60 } = opt
                const pdfDoc = await PDFDocument.load(pdfAb)
                const imgRes = await fetch(toSameOrigin(signatureUrl), { cache: 'no-store' })
                if (!imgRes.ok) throw new Error('Không tải được ảnh chữ ký')
                const imgAb = await imgRes.arrayBuffer()
                const u8 = new Uint8Array(imgAb)
                const isPng = (u8[0] === 0x89 && u8[1] === 0x50 && u8[2] === 0x4E)

                const sig = isPng ? await pdfDoc.embedPng(imgAb) : await pdfDoc.embedJpg(imgAb)
                const page = pdfDoc.getPage(pdfDoc.getPageCount() - 1)
                const { width: pageW } = page.getSize()
                page.drawImage(sig, {
                    x: pageW - width - xRightPadding,
                    y: yBottom,
                    width,
                    height
                })
                return await pdfDoc.save()
            }

            try {
                stampedAb = await withSignatureImage(stampedAb, props.mySignatureUrl)
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

        // 4) Hash sau khi đóng dấu
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

        // (Tuỳ chọn) Gọi API approve BE:
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

/* =============== reject demo =============== */
async function reject(r) {
    try {
        message.success('(Demo) Đã từ chối cục bộ')
    } catch {
        message.error('Từ chối thất bại')
    }
}

// Số chữ ký đã có trong phiên -> slot kế tiếp
// Đếm số step đã approved để xác định slot kế tiếp
async function getNextSignatureIndex(instanceId) {
    if (!instanceId) return 0
    try {
        const res = await getApproval(instanceId) // GET /document-approvals/{id}
        const steps = res?.data?.steps || res?.data?.data?.steps || []
        return steps.filter(s => s.status === 'approved').length
    } catch {
        return 0
    }
}

// đếm số lần ký thử (local) theo mỗi document/instance
const previewSigLocal = ref(Object.create(null))
const keyOf = (r) => String(r.instance_id || r.rowKey || r.document_id)

/** Tính toạ độ dựa theo index: xếp 3 cột, 2 hàng (tối đa 6 chữ ký ở đáy trang) */
/** Slot chữ ký: 2 cột (trái/phải), nhiều hàng; cao hơn để tránh block text */
/**
 * Chia đều theo hàng: 3 cột/hàng (0..2 cùng 1 dòng), 3..5 ở dòng kế.
 * Tự co sigW nếu trang hẹp để không bị âm khoảng cách.
 */
function computeSignaturePosition(pageWidth, index) {
    // cấu hình
    const MAX_PER_ROW   = 3;     // số chữ ký mỗi hàng
    const PAD_H         = 48;    // lề trái/phải
    const Y_BASE        = 120;   // nâng khỏi mép dưới để tránh block text/logo
    const ROW_GAP       = 26;    // khoảng cách giữa 2 hàng
    const CAP_GAP       = 8;     // khoảng cách giữa ảnh và caption
    const CAP_HEIGHT    = 18 * 2; // 2 dòng caption cỡ ~8–9pt

    // kích thước ảnh chữ ký gốc
    let sigW = 160;
    let sigH = 70;

    // vùng khả dụng theo chiều ngang
    const avail = Math.max(100, pageWidth - PAD_H * 2); // an toàn
    // khoảng hở tối thiểu giữa các cột
    const MIN_GAP = 16;

    // tính khoảng hở nếu giữ nguyên sigW
    let gap = (avail - MAX_PER_ROW * sigW) / (MAX_PER_ROW - 1);

    // nếu trang hẹp → co sigW/sigH để gap >= MIN_GAP
    if (gap < MIN_GAP) {
        const needTotal = MAX_PER_ROW * sigW + (MAX_PER_ROW - 1) * MIN_GAP;
        const scale = Math.min(1, avail / needTotal);
        sigW = Math.floor(sigW * scale);
        sigH = Math.floor(sigH * scale);
        gap  = Math.max(MIN_GAP, (avail - MAX_PER_ROW * sigW) / (MAX_PER_ROW - 1));
    }

    // xác định hàng/cột theo index
    const row = Math.floor(index / MAX_PER_ROW);       // 0,1,2,...
    const col = index % MAX_PER_ROW;                   // 0..(MAX_PER_ROW-1)

    // x bắt đầu từ trái, chia đều
    const x = PAD_H + col * (sigW + gap);
    // y: base + (sigH + CAP_HEIGHT + ROW_GAP) * row
    const rowHeight = sigH + CAP_HEIGHT + ROW_GAP;
    const y = Y_BASE + row * rowHeight;

    return { x, y, sigW, sigH, gapY: CAP_GAP };
}




onMounted(fetchRows)
</script>

<style scoped>
.mt-3 { margin-top: 12px; }
.title { display: flex; align-items: center; }
.hint { font-size: 12px; color: #888; margin-top: 4px; }
</style>
