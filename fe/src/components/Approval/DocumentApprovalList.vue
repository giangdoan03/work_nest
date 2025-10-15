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

                <!-- trong template #bodyCell ở cột action, thêm đoạn tag "Đã duyệt" có tick xanh -->
                <template v-else-if="column.key === 'action'">
                    <a-space align="center">
                        <a-button @click="openPreview(record)">Xem</a-button>
                        <a-button type="primary" @click="openApproveModal(record)" :disabled="record.__approved">
                            Duyệt
                        </a-button>
                        <a-button danger @click="reject(record)" :disabled="record.__approved">Từ chối</a-button>
                        <a-button @click="openOriginal(record)" :disabled="!record.file_url">Mở file</a-button>
                        <a-button @click="signAndPreview(record)">Ký thử (ảnh)</a-button>

                        <!-- Tick xanh khi đã duyệt -->
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
        <a-modal v-model:open="previewOpen" title="Xem PDF" :footer="null" width="80%">
            <iframe
                :src="`/pdfjs/viewer.html?file=${encodeURIComponent(previewUrl)}`"
                style="width:100%;height:78vh;border:none;"
            ></iframe>
        </a-modal>

        <!-- Modal duyệt: nhập thông tin -->
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
import {computed, onMounted, reactive, ref} from 'vue'
import {message} from 'ant-design-vue'
import {PDFDocument, rgb} from 'pdf-lib'
import fontkit from '@pdf-lib/fontkit'
import {CheckCircleTwoTone} from '@ant-design/icons-vue'
import {getDocumentsByDepartment} from '@/api/document'
import fontUrl from '@/assets/fonts/Roboto-Regular.ttf?url' // font có tiếng Việt. Đặt file tại public/fonts/Roboto-Regular.ttf

const baseURL = import.meta.env.VITE_API_URL

// ====== State ======
const selectedDept = ref(null)
const departmentOptions = ref([
    {label: 'Phòng Hành chính - Nhân sự', value: 1},
    {label: 'Phòng Tài chính - Kế toán', value: 2},
    {label: 'Phòng Thương mại', value: 3},
    {label: 'Phòng Dịch vụ - Kỹ thuật', value: 4},
])

const q = ref('')
const rows = ref([])
const loading = ref(false)

const pager = ref({current: 1, pageSize: 10, total: 0})
const pagedRows = computed(() => {
    const start = (pager.value.current - 1) * pager.value.pageSize
    return rows.value.slice(start, start + pager.value.pageSize)
})


// Dùng chung: chuyển 1 url PDF bất kỳ sang đường dẫn có proxy (để tránh CORS)
function toProxyUrl(pdfUrl) {
    try {
        const u = new URL(pdfUrl, window.location.origin)
        // Nếu là absolute http/https khác origin → dùng /pdf-proxy + pathname
        if (/^https?:/i.test(u.href) && u.origin !== window.location.origin) {
            return '/pdf-proxy' + u.pathname + (u.search || '')
        }
        // Nếu đã là /pdf-proxy hoặc đã cùng origin → giữ nguyên
        return u.pathname + (u.search || '')
    } catch {
        // relative path sẵn có
        return pdfUrl
    }
}

async function fetchBytesStrict(url) {
    const r = await fetch(url, { cache: 'no-store' })
    if (!r.ok) throw new Error(`Fetch failed ${r.status}: ${url}`)
    const ab = await r.arrayBuffer()
    // Bắt trường hợp trả về HTML (404 bị rewrite)
    const head = new Uint8Array(ab.slice(0, 16))
    const txt = new TextDecoder().decode(head)
    if (txt.startsWith('<!') || txt.startsWith('<ht') || txt.includes('<html')) {
        throw new Error(`Got HTML instead of image at ${url} (check path / proxy)`)
    }
    return ab
}

function detectImageType(u8) {
    // PNG magic: 89 50 4E 47 0D 0A 1A 0A
    if (u8[0] === 0x89 && u8[1] === 0x50 && u8[2] === 0x4E && u8[3] === 0x47) return 'png'
    // JPEG magic: FF D8 FF
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


async function signPdfOnLastPage(pdfUrl, signPngUrl) {
    const src = toProxyUrl(pdfUrl)
    // 1) PDF
    const pdfBytes = await fetchBytesStrict(src)
    const pdfDoc = await PDFDocument.load(pdfBytes)

    // 2) Ảnh chữ ký
    //    - Nếu để trong `public/images/signature.png` thì URL là '/images/signature.png'
    //    - Nếu dùng asset Vite import? Hãy để ở `public/` cho chắc.
    const imgAb = await fetchBytesStrict(signPngUrl)
    const sig = await embedImageAuto(pdfDoc, imgAb)

    // 3) Trang cuối + đặt toạ độ
    const last = pdfDoc.getPage(pdfDoc.getPageCount() - 1)
    const { width } = last.getSize()
    const sigW = 140, sigH = 60
    last.drawImage(sig, { x: width - sigW - 48, y: 48, width: sigW, height: sigH })

    // 4) Trả về blob URL để xem ngay
    const out = await pdfDoc.save()
    return URL.createObjectURL(new Blob([out], { type: 'application/pdf' }))
}


// Gọi từ UI
async function signAndPreview(r) {
    try {
        const srcPdf = r?.file_url || '/pdf-proxy/wp-content/uploads/2025/10/Bang_gia_QR_Code_Marketing_2025.pdf'
        // mở lại modal viewer với file đã ký (blob: URL cùng origin nên pdf.js v5 load được)
        previewUrl.value = await signPdfOnLastPage(srcPdf, '/images/signature.png')
        previewOpen.value = true
    } catch (e) {
        console.error(e)
        message.error('Ký thử thất bại')
    }
}



// Preview
const previewOpen = ref(false)
const previewUrl = ref('')

// Approve modal
const approveOpen = ref(false)
const approving = ref(false)
const activeRecord = ref(null)
const localPdfAb = ref(null)
const localPdfName = ref('')

const form = reactive({
    signerName: '',
    docNo: '',
    note: ''
})

// ====== Columns ======
const cols = [
    {title: 'Tiêu đề', key: 'title', dataIndex: 'title'},
    {title: 'Gửi lúc', key: 'submitted_at', dataIndex: 'submitted_at', width: 180},
    {title: 'Tác vụ', key: 'action', dataIndex: 'action', width: 320}
]


// ====== Helpers ======
const safeUrl = (p) => {
    const s = String(p || '')
    return /^https?:\/\//i.test(s) ? s : (s ? `${baseURL}/${s}` : '')
}
const formatTime = (ts) => (ts ? new Date(ts).toLocaleString('vi-VN') : '')

function nextDocNoLocal() {
    const n = (parseInt(localStorage.getItem('doc_seq') || '0', 10) + 1)
    localStorage.setItem('doc_seq', String(n))
    return n.toString().padStart(2, '0')
}

// ====== Fetch + adapter ======
async function fetchRows() {
    loading.value = true
    try {
        const res = await getDocumentsByDepartment(selectedDept.value)
        const docs = Array.isArray(res?.data?.data) ? res.data.data : []

        let adapted = docs
            .filter(d => String(d.file_path || '').toLowerCase().endsWith('.pdf'))
            .map(d => ({
                rowKey: `${d.id}-${d.instance_id ?? 'noinst'}`,
                instance_id: d.instance_id ?? null, // nếu có workflow
                document_id: d.id,
                title: d.title,
                file_url: safeUrl(d.file_path),
                submitted_at: d.created_at,
                step: d.step ?? null,
                _approver_name: d._approver_name ?? null
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

function onPageChange(p) {
    pager.value.current = p
}

function onPageSizeChange(cur, size) {
    pager.value.pageSize = size
    pager.value.current = 1
}

// ====== View / Open ======
function openPreview(r) {
    // r.file_url có thể là absolute → chuyển sang proxy để không CORS
    previewUrl.value = toProxyUrl(r.file_url || '/pdf-proxy/wp-content/uploads/2025/10/Bang_gia_QR_Code_Marketing_2025.pdf')
    previewOpen.value = true
}


function openOriginal(r) {
    if (!r.file_url) return
    window.open(r.file_url, '_blank', 'noopener')
}

// ====== Approve Modal ======
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
    reader.onload = () => {
        localPdfAb.value = reader.result
    }
    reader.readAsArrayBuffer(f)
}

// ====== Crypto / Font ======
async function sha256Hex(bufferLike) {
    const ab = bufferLike instanceof ArrayBuffer ? bufferLike : bufferLike.buffer;

    // Dùng Web Crypto nếu có (HTTPS hoặc localhost)
    if (typeof window !== 'undefined' && window.crypto?.subtle && window.isSecureContext) {
        const hashBuf = await window.crypto.subtle.digest('SHA-256', ab);
        return [...new Uint8Array(hashBuf)].map(b => b.toString(16).padStart(2, '0')).join('');
    }

    // Fallback: dùng crypto-js khi không có subtle
    const CryptoJS = (await import('crypto-js')).default;
    const u8 = new Uint8Array(ab);
    // Convert ArrayBuffer -> WordArray
    const wordArray = CryptoJS.lib.WordArray.create(u8);
    return CryptoJS.SHA256(wordArray).toString(CryptoJS.enc.Hex);
}

async function loadFontBytes() {
    const res = await fetch(fontUrl)
    if (!res.ok) throw new Error('Không tải được font')
    return new Uint8Array(await res.arrayBuffer())
}


// ====== PDF stamping (không chữ ký ảnh) ======
async function stampTextBlock(arrayBuffer, info) {
    const pdfDoc = await PDFDocument.load(arrayBuffer)
    pdfDoc.registerFontkit(fontkit)
    const fontBytes = await loadFontBytes()
    const font = await pdfDoc.embedFont(fontBytes, { subset: true })

    const pages = pdfDoc.getPages()

    // Khung/Style
    const boxW = 220              // rộng hơn chút cho đủ 2 cột
    const boxH = 46               // thấp hơn để gọn
    const BOTTOM_OFFSET = 16      // ↓ dịch xuống gần mép dưới (giảm số này để xuống nữa)
    const black = rgb(0, 0, 0)
    const red   = rgb(1, 0, 0)
    const white = rgb(1, 1, 1)

    for (const page of pages) {
        const { width } = page.getSize()
        const x = width - boxW - 50
        const y = BOTTOM_OFFSET   // sát đáy hơn

        // Border top đen
        page.drawLine({
            start: { x, y: y + boxH },
            end:   { x: x + boxW, y: y + boxH },
            thickness: 1.0,
            color: black
        })

        // Nền trắng mờ (tránh dính nền PDF)
        page.drawRectangle({
            x, y, width: boxW, height: boxH,
            color: white,
            opacity: 0.85
        })

        // Nội dung: cỡ chữ & khoảng cách nhỏ
        const size = 9             // 👈 chữ nhỏ (9)
        const lineGap = 12         // 👈 khoảng cách dòng ngắn
        const line1 = `Ký bởi: ${info.signerName} | Số văn bản: ${info.docNo}`
        const line2 = `Ngày ký: ${info.date} | Giờ ký: ${info.time}`

        // căn giữa toàn khối text
        const w1 = font.widthOfTextAtSize(line1, size)
        const w2 = font.widthOfTextAtSize(line2, size)
        const blockW = Math.max(w1, w2)
        const blockX = x + (boxW - blockW) / 2

        // đặt gần border-top hơn
        let cy = y + boxH - size - 4

        page.drawText(line1, { x: blockX, y: cy, size, font, color: red })
        cy -= lineGap
        page.drawText(line2, { x: blockX, y: cy, size, font, color: red })
    }

    return await pdfDoc.save()
}





// ====== Approve flow (không cần API lưu) ======
async function handleApproveSubmit() {
    if (!form.signerName || !form.docNo) {
        message.warning('Vui lòng nhập Người duyệt và Số văn bản')
        return
    }

    approving.value = true
    try {
        const r = activeRecord.value
        let originalAb

        if (localPdfAb.value) {
            // ưu tiên file local (tránh CORS)
            originalAb = localPdfAb.value
        } else {
            // tải từ URL (cần CORS hoặc proxy)
            const resp = await fetch(r.file_url, {cache: 'no-store'})
            if (!resp.ok) throw new Error('Tải PDF thất bại (CORS?)')
            originalAb = await resp.arrayBuffer()
        }

        const now = new Date()
        const info = {
            signerName: form.signerName,
            docNo: `TTID${form.docNo.padStart(3, '0')}`, // thêm tiền tố + padding 3 chữ số
            time: now.toLocaleTimeString('vi-VN'),
            date: now.toLocaleDateString('vi-VN'),
            note: form.note || ''
        }

        // hash trước
        const beforeHash = await sha256Hex(originalAb)

        // chèn block
        const stamped = await stampTextBlock(originalAb, info)

        // hash sau
        const afterHash = await sha256Hex(stamped)

        // tải xuống PDF đã chèn (offline)
        const blob = new Blob([stamped], {type: 'application/pdf'})
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `signed_${r.title || 'document'}.pdf`
        a.click()

        // bằng chứng JSON (offline)
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
            hashes: {before_sha256: beforeHash, after_sha256: afterHash}
        }
        const evBlob = new Blob([JSON.stringify(evidence, null, 2)], {type: 'application/json'})
        const evUrl = URL.createObjectURL(evBlob)
        const evA = document.createElement('a')
        evA.href = evUrl
        evA.download = `evidence_${info.docNo}.json`
        evA.click()

        message.success('Đã chèn & tải xuống (offline)')
        approveOpen.value = false

        if (activeRecord.value) {
            const r = rows.value.find(r => r.document_id === activeRecord.value.document_id)
            if (r) r.__approved = true
        }

        // (tuỳ chọn) nếu có workflow:
        // if (r.instance_id) await approveApproval(r.instance_id, { note: `Duyệt số văn bản ${info.docNo}` })
        // reload()
    } catch (e) {
        console.error(e)
        message.error(e?.message || 'Duyệt thất bại (CORS hoặc file lỗi)')
    } finally {
        approving.value = false
    }
}

const COLORS = {
    headerBg: {r: 0.09, g: 0.64, b: 0.24},    // #16a34a (green-600)
    headerText: {r: 1, g: 1, b: 1},
    border: {r: 0.82, g: 0.82, b: 0.82},
    bodyText: {r: 0.12, g: 0.12, b: 0.12},
    labelText: {r: 0.38, g: 0.38, b: 0.38}
}

async function reject(r) {
    try {
        // nếu có workflow:
        // if (!r.instance_id) return message.warning('Không có phiên duyệt để từ chối')
        // await rejectApproval(r.instance_id, { note: '' })
        message.success('(Demo) Đã từ chối cục bộ')
    } catch {
        message.error('Từ chối thất bại')
    }
}

onMounted(fetchRows)
</script>

<style scoped>
.mt-3 {
    margin-top: 12px;
}

.title {
    display: flex;
    align-items: center;
}

.hint {
    font-size: 12px;
    color: #888;
    margin-top: 4px;
}
</style>
