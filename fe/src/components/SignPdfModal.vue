<template>
    <a-modal
        :open="open"
        title="Ký tài liệu"
        width="820px"
        ok-text="Lưu bản đã ký"
        cancel-text="Hủy"
        :confirm-loading="saving"
        :ok-button-props="{ disabled: !isPdfReady || saving }"
        centered
        :maskClosable="false"
        @cancel="$emit('update:open', false)"
        @ok="handleSave"
    >
        <div class="wrap">
            <div class="left">
                <div class="tools">
                    <a-select v-model:value="pageNum" style="width: 120px">
                        <a-select-option v-for="p in pageCount" :key="p" :value="p">Trang {{ p }}</a-select-option>
                    </a-select>
                    <a-input-number v-model:value="scale" :min="0.5" :max="3" :step="0.1" />
                    <a-button @click="fitWidth">Fit width</a-button>
                    <a-button @click="resetView">Reset</a-button>
                </div>

                <div
                    class="stage"
                    ref="stageRef"
                >
                    <a-spin :spinning="previewSpinning" tip="Đang tải xem trước..." size="large" style="display:block; min-height: 200px;">
                        <div class="pdf-viewer">
                            <canvas ref="canvasRef" class="pdf-canvas" />
                        </div>
                    </a-spin>
                </div>
            </div>
        </div>

        <template #footer>
            <a-tooltip title="Dành cho văn bản phát hành">
                <a-button :loading="savingApprove" :disabled="approveDisabled" @click="finalizeApproval">
                    <template #icon><CheckCircleOutlined class="icon-btn" /></template>
                    Duyệt văn bản
                </a-button>
            </a-tooltip>
            <a-tooltip title="Dành cho văn bản nội bộ">
                <a-button
                    type="primary"
                    :loading="saving"
                    :disabled="!isPdfReady || saving || disableSignByDocType"
                    @click="handleSave"
                >
                    <template #icon><EditOutlined class="icon-btn" /></template>
                    Ký văn bản
                </a-button>
            </a-tooltip>

            <a-button @click="downloadSigned">
                <template #icon><DownloadOutlined class="icon-btn" /></template>
                Tải xuống
            </a-button>
            <a-button :disabled="saving" @click="$emit('update:open', false)">
                <template #icon><CloseOutlined class="icon-btn" /></template>
                Đóng
            </a-button>
        </template>
    </a-modal>
</template>

<script setup>
/* eslint-disable no-console */
import { ref, shallowRef, markRaw, computed, watch, watchEffect, nextTick, onBeforeUnmount } from 'vue'
import { message } from 'ant-design-vue'

/* icons */
import {
    DownloadOutlined,
    FilePdfOutlined,
    CheckCircleOutlined,
    EditOutlined,
    CloseOutlined
} from '@ant-design/icons-vue'

/* APIs (giữ nguyên) */
import { checkSession } from '@/api/auth'
import { uploadTaskFileSigned, approveDocument } from '@/api/document'
import { getApprovalDetail } from '@/api/approvals.js'

/* pdf/tesseract libs */
import * as pdfjsLib from 'pdfjs-dist/legacy/build/pdf'
import pdfWorker from 'pdfjs-dist/legacy/build/pdf.worker.min.js?url'
pdfjsLib.GlobalWorkerOptions.workerSrc = pdfWorker

let PDFLib = null
const loadPdfLib = async () => { if (!PDFLib) PDFLib = await import('pdf-lib') }

let Tesseract = null
const loadTesseract = async () => { if (!Tesseract) Tesseract = (await import('tesseract.js')).default }
const TESSDATA_URL = 'https://tessdata.projectnaptha.com/4.0.0'

/* Props / emits */
const props = defineProps({
    open: { type: Boolean, default: false },
    pdfUrl: { type: String, default: '' },
    signatureUrl: { type: String, default: '' },

    autoPlace: { type: Boolean, default: true },
    markers: { type: [String, Array], default: () => ['dinhvanvinh', 'nguyencanhhop', 'taquytho', 'chuky3'] },
    markerWidthPct: { type: Number, default: 25 },
    yOffsetPct: { type: Number, default: -18 },
    centerOnMarker: { type: Boolean, default: true },

    useOCR: { type: Boolean, default: true },
    ocrScale: { type: Number, default: 2 },
    ocrLang: { type: String, default: 'eng+vie' },
    caseInsensitive: { type: Boolean, default: true },
    wholeWord: { type: Boolean, default: true },

    closeAfterSave: { type: Boolean, default: false },
    signTarget: { type: Object, default: null },
    parentLoading: { type: Boolean, default: false }
})
const emits = defineEmits(['update:open', 'done', 'refresh'])

/* Refs / state */
const canvasRef = ref(null)
const stageRef = ref(null)
const sigRef = ref(null)

const pdfDoc = shallowRef(null)
const pageNum = ref(1)
const pageCount = ref(1)
const scale = ref(1)

const sigX = ref(40)
const sigY = ref(40)
const sigW = ref(200)
const opacity = ref(100)

const saving = ref(false)
const savingApprove = ref(false)
const isPdfReady = ref(false)
const currentUser = ref(null)

const signedBlobUrl = ref('')
const localSignatureUrl = ref('')
const existingPositions = ref([])

/* helpers */
const effectiveSignatureUrl = computed(() => props.signatureUrl || localSignatureUrl.value)

console.log('effectiveSignatureUrl', effectiveSignatureUrl.value)

function normalizeMarkers(input) {
    if (Array.isArray(input)) return input.map(String).map(s => s.trim()).filter(Boolean)
    return String(input || '').split(',').map(s => s.trim()).filter(Boolean)
}
const myMarkers = ref(normalizeMarkers(props.markers))

function safeFetch(url, opts = {}) {
    return fetch(url, { ...opts })
}

/* small helpers reused */
function buildRegex(query, caseInsensitive = true, wholeWord = true) {
    const esc = String(query).replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    const flags = caseInsensitive ? 'iu' : 'u'
    if (wholeWord) {
        try { return new RegExp(`(?<![\\p{L}\\p{N}_])${esc}(?![\\p{L}\\p{N}_])`, flags) }
        catch { return new RegExp(`\\b${esc}\\b`, caseInsensitive ? 'i' : '') }
    }
    return new RegExp(esc, caseInsensitive ? 'i' : '')
}

function handleRatio() {
    try {
        const el = sigRef.value
        return el && el.naturalWidth ? el.naturalHeight / el.naturalWidth : 0.35
    } catch {
        return 0.35
    }
}


/* render control */
let currentRenderTask = null
let renderQueued = false
let destroyed = false
const basePageSize = new Map()

function queueRender() {
    if (renderQueued) return
    renderQueued = true
    requestAnimationFrame(async () => {
        renderQueued = false
        isPdfReady.value = false
        try { await renderPage() } finally { if (!destroyed) isPdfReady.value = true }
    })
}

async function renderPage() {
    if (!pdfDoc.value || !canvasRef.value || destroyed) return
    if (currentRenderTask) {
        try { currentRenderTask.cancel() } catch {}
        currentRenderTask = null
    }

    const page = await pdfDoc.value.getPage(pageNum.value)
    const container = stageRef.value || canvasRef.value.parentElement
    const box = container?.getBoundingClientRect()
    if (!box?.width || !box?.height) return

    const baseViewport = page.getViewport({ scale: 1, rotation: 0 })
    const dpr = window.devicePixelRatio || 1
    const cssScale = box.width / baseViewport.width
    const renderScale = cssScale * dpr
    const renderViewport = page.getViewport({ scale: renderScale, rotation: 0 })

    const canvas = canvasRef.value
    const ctx = canvas.getContext('2d')

    canvas.width = Math.floor(renderViewport.width)
    canvas.height = Math.floor(renderViewport.height)
    canvas.style.width = Math.round(baseViewport.width * cssScale) + 'px'
    canvas.style.height = Math.round(baseViewport.height * cssScale) + 'px'

    ctx.clearRect(0, 0, canvas.width, canvas.height)

    const task = page.render({ canvasContext: ctx, viewport: renderViewport })
    currentRenderTask = task
    try {
        await task.promise
        await drawSignedStamps()
    } catch (e) { if (e?.name !== 'RenderingCancelledException') throw e }
    finally { if (currentRenderTask === task) currentRenderTask = null }
}


async function drawSignedStamps() {
    const canvas = canvasRef.value
    if (!canvas || !pdfDoc.value) return

    const ctx = canvas.getContext("2d")

    const pageIndex = pageNum.value
    const page = await pdfDoc.value.getPage(pageIndex)

    // --- Lấy kích thước PDF từ PDF.js ---
    const pdfW = page.view[2] - page.view[0]
    const pdfH = page.view[3] - page.view[1]

    // --- Mapping PDF → Canvas ---
    const scaleX = canvas.width / pdfW
    const scaleY = canvas.height / pdfH

    for (const sig of existingPositions.value) {

        if (sig.pageIndex !== pageIndex) continue

        const img = await loadImage(sig.signature_url)

        const xCanvas = sig.xPdf * scaleX
        const yCanvas = (pdfH - sig.yPdf - sig.hPdf) * scaleY
        const wCanvas = sig.wPdf * scaleX
        const hCanvas = sig.hPdf * scaleY

        // --- Vẽ hình chữ ký ---
        ctx.drawImage(img, xCanvas, yCanvas, wCanvas, hCanvas)

        // --- Vẽ timestamp nếu có ---
        if (sig.signed_at) {
            const t = new Date(sig.signed_at)
            const pad = n => String(n).padStart(2, "0")
            const ts =
                `Date: ${pad(t.getDate())}/${pad(t.getMonth()+1)}/${t.getFullYear()}, ` +
                `${pad(t.getHours())}:${pad(t.getMinutes())}:${pad(t.getSeconds())}`
            ctx.fillStyle = "#000"

            const textWidth = ctx.measureText(ts).width

            // căn giữa bên dưới chữ ký
            let tx = xCanvas + (wCanvas - textWidth) / 2
            let ty = yCanvas + hCanvas + 14

            // nếu vượt ra dưới canvas → đưa lên trên chữ ký
            if (ty > canvas.height - 5) {
                ty = yCanvas - 5
            }

            ctx.fillText(ts, tx, ty)
        }
    }
}






function loadImage(url) {
    return new Promise((resolve) => {
        const img = new Image()
        img.crossOrigin = "anonymous"
        img.onload = () => resolve(img)
        img.src = url
    })
}


/* Fit + reset helpers */
function fitWidth() {
    const box = stageRef.value?.getBoundingClientRect()
    if (!box || !pdfDoc.value) return
    pdfDoc.value.getPage(pageNum.value).then(p => {
        const vp = p.getViewport({ scale: 1, rotation: 0 })
        scale.value = Math.max(0.5, Math.min(3, (box.width - 24) / vp.width))
    })
}
function resetView() { scale.value = 1; sigX.value = 40; sigY.value = 40; sigW.value = 200 }

/* Auto-place logic left intact but structured */
const AUTO_SHRINK = 0.5 // 0.5 = 50% (bạn có thể đổi thành 0.4, 0.3,...)

async function tryAutoPlaceSignature() {
    if (!pdfDoc.value) return false

    // 1) AcroForm signature widgets
    for (let p = pdfDoc.value.numPages; p >= 1; p--) {
        try {
            const page = await pdfDoc.value.getPage(p)
            const annots = await page.getAnnotations({ intent: 'display' })
            const sigAnnot = (annots || []).find(a =>
                a?.fieldType === 'Sig' ||
                (a?.fieldType === 'Widget' && /Sig/i.test(String(a?.fieldName || ''))) ||
                /signature/i.test(String(a?.fieldName || ''))
            )
            if (sigAnnot?.rect) {
                const vp = page.getViewport({ scale: scale.value, rotation: 0 })
                const [llx, lly, urx, ury] = sigAnnot.rect
                const pdfW = page.view[2] - page.view[0]
                const pdfH = page.view[3] - page.view[1]

                const xCanvas = (llx / pdfW) * vp.width
                const yCanvas = vp.height - (ury / pdfH) * vp.height
                const wCanvas = ((urx - llx) / pdfW) * vp.width
                const hCanvas = ((ury - lly) / pdfH) * vp.height

                pageNum.value = p
                const ratio = handleRatio()

                // original suggested width (clamped)
                let suggestedW = Math.max(60, Math.min(wCanvas * 0.8, 400))
                // apply shrink
                suggestedW = Math.max(10, Math.round(suggestedW * AUTO_SHRINK))

                sigW.value = suggestedW
                sigX.value = Math.max(8, xCanvas + (wCanvas - sigW.value) / 2)
                const sigH = sigW.value * ratio
                sigY.value = Math.max(8, yCanvas + (hCanvas - sigH) / 2)
                return true
            }
        } catch { /* ignore page-level errors */ }
    }

    // 2) TEXT markers using PDF text content
    const baseMarkers = normalizeMarkers(props.markers)
    const markers = (myMarkers.value && myMarkers.value.length) ? myMarkers.value : baseMarkers

    async function findMarkers_TEXT(q) {
        const re = buildRegex(q, props.caseInsensitive, props.wholeWord)
        const hits = []
        const total = pdfDoc.value.numPages
        const Y_TOL = 2.5, GAP = 0.35
        for (let pageIndex = 1; pageIndex <= total; pageIndex++) {
            const page = await pdfDoc.value.getPage(pageIndex)
            const text = await page.getTextContent()
            const items = text.items || []
            const spans = items.map(it => {
                const [a, , , d, e, f] = it.transform || [1, 0, 0, 1, 0, 0]
                const w = it.width || (it.str?.length || 1) * (Math.abs(a) || 8) || 40
                const h = Math.abs(d) || 12
                return { str: it.str || '', x: e, y: f, w, h }
            }).filter(s => s.str)

            spans.sort((p, q) => q.y - p.y || p.x - q.x)
            const lines = []
            for (const s of spans) {
                const L = lines.find(l => Math.abs(l.y - s.y) <= Y_TOL)
                if (L) L.items.push(s); else lines.push({ y: s.y, items: [s] })
            }

            for (const line of lines) {
                line.items.sort((p, q) => p.x - q.x)
                let textLine = ''
                const segs = []
                let cursor = 0
                for (let i = 0; i < line.items.length; i++) {
                    const it = line.items[i], prev = line.items[i - 1]
                    if (i > 0) {
                        const gap = it.x - (prev.x + prev.w), avgH = (it.h + prev.h) / 2
                        if (gap > avgH * GAP) { textLine += ' '; cursor += 1 }
                    }
                    const start = cursor
                    textLine += it.str
                    cursor += it.str.length
                    segs.push({ start, end: cursor, x: it.x, y: it.y, w: it.w, h: it.h })
                }
                if (!textLine) continue
                const reG = new RegExp(re.source, re.flags.includes('g') ? re.flags : (re.flags + 'g'))
                let m
                while ((m = reG.exec(textLine)) !== null) {
                    const sIdx = m.index, eIdx = sIdx + m[0].length
                    const take = segs.filter(seg => !(seg.end <= sIdx || seg.start >= eIdx))
                    if (!take.length) continue
                    let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity
                    for (const g of take) {
                        minX = Math.min(minX, g.x); maxX = Math.max(maxX, g.x + g.w)
                        minY = Math.min(minY, g.y - g.h); maxY = Math.max(maxY, g.y)
                    }
                    const bboxW = Math.max(1, maxX - minX), bboxH = Math.max(1, maxY - minY)
                    hits.push({
                        pageIndex,
                        pdfX: minX + bboxW / 2,
                        pdfY: minY + bboxH / 2,
                        approxW: bboxW,
                        approxH: bboxH,
                        _m: q
                    })
                }
            }
        }
        return hits
    }

    let textHits = []
    for (const m of markers) {
        const h = await findMarkers_TEXT(m)
        textHits.push(...h.map(o => ({ ...o, _m: m })))
    }

    // 3) OCR fallback
    if (props.useOCR && !textHits.length) {
        await loadTesseract()
        for (let pageIndex = 1; pageIndex <= pdfDoc.value.numPages; pageIndex++) {
            const page = await pdfDoc.value.getPage(pageIndex)
            const vp1 = page.getViewport({ scale: 1 })
            const scaleOCR = Math.max(1, Math.min(3, props.ocrScale))
            const vp = page.getViewport({ scale: scaleOCR })
            const off = document.createElement('canvas')
            off.width = Math.floor(vp.width); off.height = Math.floor(vp.height)
            await page.render({ canvasContext: off.getContext('2d'), viewport: vp }).promise

            const res = await Tesseract.recognize(off, props.ocrLang, { langPath: TESSDATA_URL, logger: () => {} })
            const words = res?.data?.words || []
            for (const w of words) {
                const text = (w.text || '').trim()
                if (!text) continue
                for (const m of markers) {
                    const re = buildRegex(m, props.caseInsensitive, props.wholeWord)
                    if (!re.test(text)) continue
                    const { x0, y0, x1, y1 } = w.bbox || {}
                    if ([x0, y0, x1, y1].some(v => typeof v !== 'number')) continue
                    const cx = (x0 + x1) / 2, cy = (y0 + y1) / 2
                    const bw = (x1 - x0), bh = (y1 - y0)
                    textHits.push({
                        pageIndex,
                        pdfX: cx / scaleOCR,
                        pdfY: vp1.height - cy / scaleOCR,
                        approxW: bw / scaleOCR,
                        approxH: bh / scaleOCR,
                        _m: m
                    })
                }
            }
        }
    }

    if (!textHits.length) return false

    const pm = (currentUser.value?.preferred_marker || '').trim()
    let candidates = textHits
    if (pm) {
        const prefer = textHits.filter(h => h._m === pm)
        if (prefer.length) candidates = prefer
    }

    const byPageDesc = [...candidates].sort((a, b) => b.pageIndex - a.pageIndex)
    const topPage = byPageDesc[0].pageIndex
    const samePage = candidates.filter(h => h.pageIndex === topPage)
    samePage.sort((a, b) => (a.pdfY - b.pdfY))
    const hit = samePage[0]

    const rawPage = await pdfDoc.value.getPage(hit.pageIndex)
    const vpBase = rawPage.getViewport({ scale: 1, rotation: 0 })
    const vpView = rawPage.getViewport({ scale: scale.value, rotation: 0 })

    const wpct = Math.max(5, Math.min(80, Number(props.markerWidthPct || 25)))
    let targetCanvasW = vpView.width * (wpct / 100)
    // apply shrink to marker-based target
    targetCanvasW = Math.max(10, Math.round(targetCanvasW * AUTO_SHRINK))
    const ratio = handleRatio()
    const targetCanvasH = targetCanvasW * ratio

    const xCanvasCenter = (hit.pdfX / vpBase.width) * vpView.width
    const yCanvasCenter = (hit.pdfY / vpBase.height) * vpView.height
    const yOff = (Number(props.yOffsetPct || 0) / 100) * targetCanvasH

    let x = xCanvasCenter - targetCanvasW / 2
    let y = (vpView.height - yCanvasCenter + yOff) - targetCanvasH / 2

    if (!props.centerOnMarker) {
        x = Math.max(8, Math.min(x, vpView.width - targetCanvasW - 8))
        y = Math.max(8, Math.min(y, vpView.height - targetCanvasH - 8))
    }

    pageNum.value = hit.pageIndex
    sigW.value = targetCanvasW
    sigX.value = x
    sigY.value = y
    return true
}


/* load PDF with abort support */
let pdfLoadAbort = null
async function loadPdf() {
    if (!props.pdfUrl) return
    isPdfReady.value = false
    if (pdfLoadAbort) { try { pdfLoadAbort.abort() } catch {} pdfLoadAbort = null }

    pdfLoadAbort = new AbortController()
    try {
        const res = await safeFetch(props.pdfUrl, { signal: pdfLoadAbort.signal })
        if (!res.ok) throw new Error('Không tải được tài liệu PDF')
        const buffer = await res.arrayBuffer()
        const task = pdfjsLib.getDocument({ data: buffer })
        const doc = await task.promise
        pdfDoc.value = markRaw(doc)
        pageCount.value = doc.numPages
        pageNum.value = 1
        basePageSize.clear()
        queueRender()

        if (props.autoPlace && effectiveSignatureUrl.value) {
            try {
                const placed = await tryAutoPlaceSignature()
                if (placed) queueRender()
            } catch {}
        }
    } catch (err) {
        if (err.name === 'AbortError') {
            console.warn('loadPdf aborted')
        } else {
            console.error('loadPdf lỗi:', err)
            message.error('Không tải được tài liệu PDF.')
        }
    } finally {
        pdfLoadAbort = null
    }
}


async function findSignatureMarkersSimple(markerText) {
    if (!pdfDoc.value) return []

    const results = []
    const totalPages = pdfDoc.value.numPages

    // regex marker
    const regex = buildRegex(markerText, props.caseInsensitive, props.wholeWord)

    for (let pageIndex = 1; pageIndex <= totalPages; pageIndex++) {
        const page = await pdfDoc.value.getPage(pageIndex)
        const content = await page.getTextContent()

        for (const item of content.items) {
            if (!item?.str) continue

            const text = String(item.str).trim()
            if (!text) continue

            if (!regex.test(text)) continue   // không match

            // PDF transform matrix → position
            const [a, , , d, x, y] = item.transform

            const width = item.width || Math.abs(a)
            const height = Math.abs(d) || 10

            results.push({
                pageIndex,
                xPdf: x,
                yPdf: y - height,
                wPdf: width,
                hPdf: height,
                textFound: text
            })
        }
    }

    return results
}

function normalizeName(name) {
    if (!name) return ''
    return name
        .normalize('NFD')
        .replace(/\p{Diacritic}/gu, '')
        .replace(/đ/g, 'd').replace(/Đ/g, 'D')
        .replace(/\s+/g, '')
        .toLowerCase()
}

async function findNameInPdf(name) {
    const key = normalizeName(name);
    const regex = new RegExp(key, 'i');

    const results = [];
    const total = pdfDoc.value.numPages;

    for (let pageIndex = 1; pageIndex <= total; pageIndex++) {
        const page = await pdfDoc.value.getPage(pageIndex);
        const content = await page.getTextContent();

        for (const item of content.items) {
            if (!item.str) continue;

            const raw = normalizeName(item.str);
            if (!regex.test(raw)) continue;

            const [a, , , d, x, y] = item.transform;
            const width = item.width || Math.abs(a);
            const height = Math.abs(d) || 10;

            results.push({
                pageIndex,
                xPdf: x,
                yPdf: y - height,
                wPdf: width,
                hPdf: height
            });
        }
    }
    return results;
}


async function autoPlaceExistingSignatures() {
    existingPositions.value = [];

    const steps = props.signTarget?.signedSteps || [];
    if (!steps.length) return;

    for (const step of steps) {
        if (!step.signature_url || !step.approver_name) continue;

        const hits = await findNameInPdf(step.approver_name);
        if (!hits.length) continue;

        const h = hits[0]; // vị trí tên tìm thấy

        // kích thước ảnh chữ ký (PDF unit)
        const sigWidth = h.wPdf * 1.4;       // rộng hơn text 1 chút
        const sigHeight = sigWidth * 0.35;   // tỉ lệ ảnh

        // tâm text
        const centerX = h.xPdf + h.wPdf / 2;
        const centerY = h.yPdf + h.hPdf / 2;

        // vị trí ảnh = căn giữa perfect center
        const sigX = centerX - sigWidth / 2;
        const sigY = centerY - sigHeight / 2;

        existingPositions.value.push({
            pageIndex: h.pageIndex,
            signature_url: step.signature_url,
            xPdf: sigX,
            yPdf: sigY,
            wPdf: sigWidth,
            hPdf: sigHeight,
            signed_at: step.signed_at || step.updated_at || null // thêm dòng này
        });
    }

    queueRender();
}


/* lifecycle: when open changes, load libraries + pdf + user session */
watch(() => props.open, async (v) => {
    if (v) {
        destroyed = false
        isPdfReady.value = false
        await nextTick()
        await loadPdfLib()

        myMarkers.value = normalizeMarkers(props.markers)
        localSignatureUrl.value = props.signatureUrl || ''

        try {
            const res = await checkSession()
            const user = res.data?.user || {}
            currentUser.value = user
            if (!localSignatureUrl.value && user.signature_url) localSignatureUrl.value = user.signature_url

            const pm = (user.preferred_marker || '').trim()
            if (pm) {
                const set = new Set([pm, ...myMarkers.value])
                myMarkers.value = Array.from(set)
            }
        } catch (e) {
            console.error('Lỗi checkSession:', e)
        }

        await loadPdf()
        await autoPlaceExistingSignatures()
        queueRender()
    } else {
        destroyed = true
        if (currentRenderTask) { try { currentRenderTask.cancel() } catch {} currentRenderTask = null }
        if (pdfLoadAbort) { try { pdfLoadAbort.abort() } catch {} pdfLoadAbort = null }
        pdfDoc.value = null
        if (signedBlobUrl.value) { URL.revokeObjectURL(signedBlobUrl.value); signedBlobUrl.value = '' }
    }
}, { immediate: true })

watch([pageNum, scale], () => { if (pdfDoc.value) queueRender() })
onBeforeUnmount(() => {
    destroyed = true
    if (currentRenderTask) { try { currentRenderTask.cancel() } catch {} currentRenderTask = null }
    if (pdfLoadAbort) { try { pdfLoadAbort.abort() } catch {} pdfLoadAbort = null }
    if (signedBlobUrl.value) { URL.revokeObjectURL(signedBlobUrl.value); signedBlobUrl.value = '' }
})

/* Download helpers (create temporary anchor) */
async function downloadSigned() {
    try {
        if (!pdfDoc.value) return message.error("PDF chưa sẵn sàng!");

        await loadPdfLib();
        const { PDFDocument, StandardFonts, rgb } = PDFLib;

        // --- 1) Load PDF gốc ---
        const pdfRes = await fetch(props.pdfUrl);
        if (!pdfRes.ok) throw new Error("Không tải được file PDF");
        const pdfBytes = await pdfRes.arrayBuffer();
        const pdfDocW = await PDFDocument.load(pdfBytes);

        // --------------------------------------------------------------
        // ⭐ ẨN CHECKMARK bằng overlay 50×50
        // --------------------------------------------------------------
        const CHECK_PATTERN = /[✓✔☑🗹]/u;

        for (let pIndex = 0; pIndex < pdfDocW.getPageCount(); pIndex++) {
            const page = pdfDocW.getPage(pIndex);

            const pdfPageJs = await pdfDoc.value.getPage(pIndex + 1);
            const textContent = await pdfPageJs.getTextContent();

            for (const item of textContent.items) {
                if (!item.str) continue;
                if (!CHECK_PATTERN.test(item.str)) continue;

                const [a, , , d, x, y] = item.transform;
                const w = item.width || Math.abs(a) || 12;
                const h = Math.abs(d) || 12;

                const centerX = x + w / 2;
                const centerY = (y - h) + h / 2;

                const boxSize = 50;

                page.drawRectangle({
                    x: centerX - boxSize / 2,
                    y: centerY - boxSize / 2,
                    width: boxSize,
                    height: boxSize,
                    color: rgb(1, 1, 1)
                });
            }
        }

        // --------------------------------------------------------------
        // ⭐ 2) Chèn chữ ký của các bước đã ký trước
        // --------------------------------------------------------------
        for (let pIndex = 0; pIndex < pdfDocW.getPageCount(); pIndex++) {

            const page = pdfDocW.getPage(pIndex);
            const saved = existingPositions.value.filter(x => x.pageIndex === pIndex + 1);

            for (const s of saved) {
                const imgBytes = await fetch(s.signature_url).then(r => r.arrayBuffer());
                let img;
                try { img = await pdfDocW.embedPng(imgBytes); }
                catch { img = await pdfDocW.embedJpg(imgBytes); }

                page.drawImage(img, {
                    x: s.xPdf, y: s.yPdf,
                    width: s.wPdf, height: s.hPdf
                });

                // timestamp của chữ ký trước
                if (s.signed_at) {
                    const tNow = new Date(s.signed_at);
                    const pad = n => String(n).padStart(2, "0");
                    const ts =
                        `Date: ${pad(tNow.getDate())}/${pad(tNow.getMonth()+1)}/${tNow.getFullYear()}, ` +
                        `${pad(tNow.getHours())}:${pad(tNow.getMinutes())}:${pad(tNow.getSeconds())}`;

                    let f = await loadFontIfAvailable(pdfDocW);
                    if (!f) f = await pdfDocW.embedFont(StandardFonts.Helvetica);

                    const fs = Math.max(5, Math.min(12, s.wPdf / 20));
                    const tw = f.widthOfTextAtSize(ts, fs);
                    const th = typeof f.heightAtSize === "function" ? f.heightAtSize(fs) : fs;

                    let tx = s.xPdf + (s.wPdf - tw) / 2;
                    let ty = s.yPdf - th - 4;
                    if (ty < 0) ty = s.yPdf + s.hPdf + 4;

                    page.drawText(ts, {
                        x: tx, y: ty,
                        size: fs,
                        font: f,
                        color: rgb(0, 0, 0)
                    });
                }
            }
        }

        // --------------------------------------------------------------
        // ⭐ 3) Chèn chữ ký người hiện tại (nếu họ đã ký)
        // --------------------------------------------------------------

        // người hiện tại đã ký hay chưa?
        const userHasSigned = existingPositions.value.some(
            s =>
                s.signature_url === effectiveSignatureUrl.value ||
                s.signed_by === currentUser.value?.id
        );

        if (effectiveSignatureUrl.value && userHasSigned) {

            const imgBytes = await fetch(effectiveSignatureUrl.value).then(r => r.arrayBuffer());
            let img;
            try { img = await pdfDocW.embedPng(imgBytes); }
            catch { img = await pdfDocW.embedJpg(imgBytes); }

            const pageIndex = pageNum.value - 1;
            const page = pdfDocW.getPage(pageIndex);

            const pdfW = page.getWidth();
            const pdfH = page.getHeight();

            const rawPage = await pdfDoc.value.getPage(pageNum.value);
            const vp = rawPage.getViewport({ scale: scale.value });

            const sigCanvasW = sigW.value;
            const sigCanvasH = sigCanvasW * handleRatio();

            const scaleX = pdfW / vp.width;
            const scaleY = pdfH / vp.height;

            const xPdf = sigX.value * scaleX;
            const yPdf = (vp.height - (sigY.value + sigCanvasH)) * scaleY;

            const wPdf = sigCanvasW * scaleX;
            const hPdf = sigCanvasH * scaleY;

            // thêm chữ ký người hiện tại
            page.drawImage(img, {
                x: xPdf, y: yPdf,
                width: wPdf, height: hPdf
            });

            // timestamp người hiện tại
            let usedFont2 = await loadFontIfAvailable(pdfDocW);
            if (!usedFont2) usedFont2 = await pdfDocW.embedFont(StandardFonts.Helvetica);

            const now2 = new Date();
            const pad2 = n => String(n).padStart(2, "0");
            const timeText2 =
                `Date: ${pad2(now2.getDate())}/${pad2(now2.getMonth()+1)}/${now2.getFullYear()}, ` +
                `${pad2(now2.getHours())}:${pad2(now2.getMinutes())}:${pad2(now2.getSeconds())}`;

            const fs2 = Math.max(5, Math.min(12, wPdf / 20));
            const tw2 = usedFont2.widthOfTextAtSize(timeText2, fs2);
            const th2 = typeof usedFont2.heightAtSize === "function"
                ? usedFont2.heightAtSize(fs2)
                : fs2;

            let tx2 = xPdf + (wPdf - tw2) / 2;
            let ty2 = yPdf - th2 - 4;
            if (ty2 < 0) ty2 = yPdf + hPdf + 4;

            page.drawText(timeText2, {
                x: tx2, y: ty2,
                size: fs2,
                font: usedFont2,
                color: rgb(0, 0, 0)
            });
        }

        // --------------------------------------------------------------
        // ⭐ 4) Chèn footer duyệt (approver info)
        // --------------------------------------------------------------
        const rawApprover =
            currentUser.value?.full_name ||
            currentUser.value?.name ||
            currentUser.value?.username ||
            "NguoiDuyet";

        const sanitizeToAscii = s => {
            try {
                const nd = s.normalize("NFD").replace(/\p{Diacritic}/gu, "");
                return nd.replace(/Đ/g, "D").replace(/đ/g, "d").replace(/[^\x00-\x7F ]/g, "");
            } catch {
                return s.replace(/[Đđ]/g, c => c === "Đ" ? "D" : "d")
                    .replace(/[^\x00-\x7F ]/g, "");
            }
        };

        const approverDisplay = sanitizeToAscii(rawApprover);

        const now = new Date();
        const pad = n => String(n).padStart(2, "0");
        const vnTime =
            `${pad(now.getDate())}/${pad(now.getMonth()+1)}/${now.getFullYear()}, ` +
            `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;

        const timeText = `${approverDisplay} — Date: ${vnTime}`;

        let usedFont = await loadFontIfAvailable(pdfDocW);
        if (!usedFont) usedFont = await pdfDocW.embedFont(StandardFonts.Helvetica);

        const totalPages = pdfDocW.getPageCount();
        for (let p = 0; p < totalPages; p++) {
            const page = pdfDocW.getPage(p);
            const pdfW = page.getWidth();

            const fontSize = 6;
            const margin = 20;

            const tw = usedFont.widthOfTextAtSize(timeText, fontSize);
            const th = typeof usedFont.heightAtSize === "function"
                ? usedFont.heightAtSize(fontSize)
                : fontSize;

            const textX = Math.max(margin, pdfW - margin - tw);
            const textY = margin;
            const lineY = textY + th + 2;

            page.drawRectangle({
                x: textX, y: lineY,
                width: tw, height: 0.7,
                color: rgb(0, 0, 0)
            });

            page.drawText(timeText, {
                x: textX, y: textY,
                size: fontSize,
                font: usedFont,
                color: rgb(0, 0, 0)
            });
        }

        // --------------------------------------------------------------
        // ⭐ 5) Xuất PDF
        // --------------------------------------------------------------
        const finalBytes = await pdfDocW.save();
        const blob = new Blob([finalBytes], { type: "application/pdf" });
        const url = URL.createObjectURL(blob);

        const a = document.createElement("a");
        a.href = url;
        a.download = "signed.pdf";
        a.click();

        URL.revokeObjectURL(url);

        message.success("Đã tải PDF đã ký!");

    } catch (err) {
        console.error(err);
        message.error("Lỗi tạo PDF đã ký.");
    }
}





/* helper: load font and return usedFont or null (for pdf-lib) */
async function loadFontIfAvailable(pdfDocW) {
    try {
        const fontUrl = '/fonts/NotoSans-Regular.ttf'
        const fResp = await fetch(fontUrl)
        if (fResp.ok) {
            const fBytes = await fResp.arrayBuffer()
            return await pdfDocW.embedFont(fBytes)
        }
    } catch (e) {
        console.warn('loadFontIfAvailable failed', e)
    }
    return null
}

/* Core: handleSave (sign image embedding) - logic preserved */
async function handleSave() {
    if (!props.pdfUrl) return message.warning('Không có file PDF để ký.')
    if (!effectiveSignatureUrl.value) return message.warning('Chưa có ảnh chữ ký.')
    if (!pdfDoc.value) return message.warning('Vui lòng chờ PDF tải xong.')
    if (!PDFLib) await loadPdfLib()

    saving.value = true
    try {
        if (props.autoPlace && effectiveSignatureUrl.value &&
            (!sigRef.value || (sigX.value === 40 && sigY.value === 40))) {
            try { await tryAutoPlaceSignature() } catch {}
        }

        const [pdfRes, sigRes] = await Promise.all([ safeFetch(props.pdfUrl), safeFetch(effectiveSignatureUrl.value) ])
        if (!pdfRes.ok || !sigRes.ok) throw new Error('Không tải được file hoặc ảnh')
        const pdfBytes = await pdfRes.arrayBuffer()
        const imgBytes = await sigRes.arrayBuffer()

        const { PDFDocument, degrees } = PDFLib
        const pdfDocW = await PDFDocument.load(pdfBytes, { updateMetadata: false })
        const page = pdfDocW.getPage(pageNum.value - 1)

        let img
        try { img = await pdfDocW.embedPng(imgBytes) } catch { img = await pdfDocW.embedJpg(imgBytes) }

        const rawPage = await pdfDoc.value.getPage(pageNum.value)
        const pageRotate = (rawPage.rotate || 0) % 360
        const vpRender = rawPage.getViewport({ scale: scale.value, rotation: 0 })

        const pdfW = page.getWidth(), pdfH = page.getHeight()
        const scaleX = pdfW / vpRender.width, scaleY = pdfH / vpRender.height

        const sigCanvasW = sigW.value
        const sigCanvasH = sigW.value * handleRatio()

        let xPdf = sigX.value * scaleX
        let yPdf = (vpRender.height - (sigY.value + sigCanvasH)) * scaleY
        let wPdf = sigCanvasW * scaleX
        let hPdf = sigCanvasH * scaleY
        let rotateDeg = 0

        switch (pageRotate) {
            case 0: break
            case 180:
                xPdf = pdfW - xPdf - wPdf
                yPdf = pdfH - yPdf - hPdf
                break
            case 90: {
                const nx = yPdf
                const ny = pdfW - (xPdf + wPdf)
                xPdf = nx; yPdf = ny
                const t = wPdf; wPdf = hPdf; hPdf = t
                rotateDeg = 90
                break
            }
            case 270: {
                const nx = pdfH - (yPdf + hPdf)
                const ny = xPdf
                xPdf = nx; yPdf = ny
                const t = wPdf; wPdf = hPdf; hPdf = t
                rotateDeg = 270
                break
            }
        }

        page.drawImage(img, {
            x: xPdf, y: yPdf, width: wPdf, height: hPdf,
            opacity: opacity.value / 100,
            rotate: rotateDeg ? degrees(rotateDeg) : undefined
        })

        // add timestamp text (try embed unicode font -> fallback)
        try {
            try {
                const fontkitMod = await import('@pdf-lib/fontkit')
                pdfDocW.registerFontkit(fontkitMod.default || fontkitMod)
            } catch (e) { console.warn('fontkit not available:', e) }

            let usedFont = await loadFontIfAvailable(pdfDocW)
            const fontSize = Math.max(5, Math.min(12, (wPdf / 20)))
            const now = new Date()
            const pad = n => String(n).padStart(2, '0')
            const timeText = `Date: ${pad(now.getDate())}/${pad(now.getMonth()+1)}/${now.getFullYear()}, ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`

            const sanitizeToAscii = s => {
                try {
                    const nd = s.normalize('NFD').replace(/\p{Diacritic}/gu, '')
                    return nd.replace(/Đ/g, 'D').replace(/đ/g, 'd')
                } catch { return s.replace(/[Đđ]/g, c => c === 'Đ' ? 'D' : 'd').replace(/[^\x00-\x7F]/g, '') }
            }

            if (!usedFont) {
                usedFont = await pdfDocW.embedFont(PDFLib.StandardFonts.Helvetica)
            }
            const textForDraw = usedFont === PDFLib.StandardFonts.Helvetica ? sanitizeToAscii(timeText) : timeText

            const textWidth = usedFont.widthOfTextAtSize(textForDraw, fontSize)
            const textHeight = (typeof usedFont.heightAtSize === 'function') ? usedFont.heightAtSize(fontSize) : fontSize
            let textX = xPdf + (wPdf - textWidth) / 2
            let textY = yPdf - textHeight - 4
            if (textY < 0) textY = yPdf + hPdf + 4

            page.drawText(textForDraw, {
                x: textX, y: textY, size: fontSize, font: usedFont, opacity: 1,
                rotate: rotateDeg ? degrees(rotateDeg) : undefined
            })
        } catch (err) { console.warn('Không chèn được thời gian ký:', err) }

        const out = await pdfDocW.save({ useObjectStreams: false })
        const signedBlob = new Blob([out], { type: 'application/pdf' })
        if (signedBlobUrl.value) { try { URL.revokeObjectURL(signedBlobUrl.value) } catch {} }
        signedBlobUrl.value = URL.createObjectURL(signedBlob)

        emits('done', signedBlob)
        message.success('Đã chèn chữ ký đúng vị trí.')
        await loadPdf();
        if (props.closeAfterSave) emits('update:open', false)

        // reload preview from bytes
        try {
            const doc = await pdfjsLib.getDocument({ data: out }).promise
            await nextTick()
            pdfDoc.value = markRaw(doc)
            pageCount.value = doc.numPages
            queueRender()
        } catch (e) {
            console.warn('reload preview failed:', e)
        }
    } catch (e) {
        console.error(e)
        message.error('Ký thất bại.')
    } finally {
        saving.value = false
    }
}

function normalizeStatus(v) {
    try {
        if (v === null || typeof v === 'undefined') return ''
        return String(v).trim().toLowerCase()
    } catch {
        return ''
    }
}

const approveDisabled = computed(() => {
    // nếu parent truyền signTarget prop, ưu tiên dùng props.signTarget; else dùng local computed targetForDoc
    const t = props.signTarget || targetForDoc.value || null

    // trạng thái đã duyệt ở nhiều chỗ: item.status | approval.status | document.status
    const s = normalizeStatus(t?.status || t?.approval?.status || t?.document?.status)

    // disable nếu đang lưu, đang duyệt, pdf chưa sẵn, doc type cấm duyệt, hoặc đã duyệt rồi
    return Boolean(
        saving.value ||
        savingApprove.value ||
        !isPdfReady.value ||
        disableApproveByDocType.value ||
        s === 'approved'
    )
})

/* finalizeApproval: logic preserved, code structured */
async function finalizeApproval() {
    /* -------------------------------------------
       1) VALIDATION
    -------------------------------------------- */
    if (!props.pdfUrl)
        return message.warning("Không có file PDF để duyệt.");

    if (!pdfDoc.value)
        return message.warning("Vui lòng chờ PDF tải xong.");

    const target = props.signTarget || null;

    const normalizeStatus = (v) => {
        try {
            if (v == null) return "";
            return String(v).trim().toLowerCase();
        } catch {
            return "";
        }
    };

    /* -------------------------------------------
       2) CHECK ALREADY APPROVED
    -------------------------------------------- */
    let alreadyApproved = false;

    if (target) {
        const s1 = normalizeStatus(target.status);
        const s2 = normalizeStatus(target.approval?.status);
        const s3 = normalizeStatus(target.document?.status);

        if (s1 === "approved" || s2 === "approved" || s3 === "approved") {
            alreadyApproved = true;
        } else if (target.approval_id) {
            try {
                const detRes = await getApprovalDetail(target.approval_id);
                const det = detRes?.data || {};

                const apvStatus = normalizeStatus(det.approval?.status);
                const docStatus = normalizeStatus(det.document?.status);

                let sigs =
                    det.signatures ||
                    det.file_signatures ||
                    det.file_signature ||
                    [];

                if (!Array.isArray(sigs) && typeof sigs === "object") {
                    sigs = Object.values(sigs);
                }

                sigs = Array.isArray(sigs) ? sigs : [];

                const hasApprovedSig = sigs.some(
                    (s) =>
                        normalizeStatus(s?.status || s?.state || s) ===
                        "approved"
                );

                if (
                    apvStatus === "approved" ||
                    docStatus === "approved" ||
                    hasApprovedSig
                ) {
                    alreadyApproved = true;
                }

                const steps = Array.isArray(det.steps) ? det.steps : [];

                if (!alreadyApproved && steps.length) {
                    const unfinished = new Set([
                        "active",
                        "pending",
                        "waiting",
                        "in_progress",
                        "todo",
                        "running",
                    ]);

                    const anyUnfinished = steps.some((s) =>
                        unfinished.has(
                            normalizeStatus(
                                s?.status ||
                                s?.step_status ||
                                s?.state ||
                                ""
                            )
                        )
                    );

                    if (!anyUnfinished) alreadyApproved = true;
                }
            } catch (e) {
                console.warn("getApprovalDetail failed:", e);
                alreadyApproved = false;
            }
        }
    }

    if (alreadyApproved) {
        return message.info("Tài liệu này đã được duyệt trước đó.");
    }

    /* -------------------------------------------
       3) BEGIN APPROVE
    -------------------------------------------- */
    savingApprove.value = true;

    try {
        const pdfRes = await safeFetch(props.pdfUrl);

        if (!pdfRes.ok)
            throw new Error("Không tải được file PDF");

        const pdfBytes = await pdfRes.arrayBuffer();

        if (!PDFLib) await loadPdfLib();

        const { PDFDocument, rgb, StandardFonts } = PDFLib;

        const pdfDocW = await PDFDocument.load(pdfBytes, {
            updateMetadata: false
        });

        // try enable fontkit
        try {
            const fontkitMod = await import("@pdf-lib/fontkit");
            pdfDocW.registerFontkit(fontkitMod.default || fontkitMod);
        } catch (e) {
            console.warn("fontkit not available:", e);
        }

        /* -------------------------------------------
           4) BUILD APPROVAL TEXT
        -------------------------------------------- */
        const rawApprover =
            currentUser.value?.full_name ||
            currentUser.value?.name ||
            currentUser.value?.username ||
            "NguoiDuyet";

        const sanitizeToAscii = (s) => {
            try {
                const nd = s.normalize("NFD").replace(/\p{Diacritic}/gu, "");
                return nd
                    .replace(/Đ/g, "D")
                    .replace(/đ/g, "d")
                    .replace(/[^\x00-\x7F ]/g, "");
            } catch {
                return String(s)
                    .replace(/[Đđ]/g, (c) => (c === "Đ" ? "D" : "d"))
                    .replace(/[^\x00-\x7F ]/g, "");
            }
        };

        const approverDisplay = sanitizeToAscii(rawApprover);

        const now = new Date();
        const pad = (n) => String(n).padStart(2, "0");

        const vnTime =
            `${pad(now.getDate())}/${pad(now.getMonth() + 1)}/${now.getFullYear()}, ` +
            `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;

        const approveText = `${approverDisplay} — Date: ${vnTime}`;

        /* -------------------------------------------
           5) LOAD FONT FOR WRITING
        -------------------------------------------- */
        let usedFont = await loadFontIfAvailable(pdfDocW);

        if (!usedFont) {
            usedFont = await pdfDocW.embedFont(StandardFonts.Helvetica);
        }

        /* -------------------------------------------
           6) DRAW APPROVAL TEXT ON ALL PAGES
        -------------------------------------------- */
        const pageTotal = pdfDocW.getPageCount();

        for (let i = 0; i < pageTotal; i++) {
            const page = pdfDocW.getPage(i);
            const pdfW = page.getWidth();

            const fontSize = 6;
            const margin = 20;

            const textWidth = usedFont.widthOfTextAtSize(
                approveText,
                fontSize
            );

            const textHeight =
                typeof usedFont.heightAtSize === "function"
                    ? usedFont.heightAtSize(fontSize)
                    : fontSize;

            const x = Math.max(margin, pdfW - margin - textWidth);
            const y = margin;

            const lineY = y + textHeight + 2;

            // draw underline
            page.drawRectangle({
                x,
                y: lineY,
                width: textWidth,
                height: 0.7,
                color: rgb(0, 0, 0)
            });

            // draw text
            page.drawText(approveText, {
                x,
                y,
                size: fontSize,
                font: usedFont,
                color: rgb(0, 0, 0)
            });
        }

        /* -------------------------------------------
           7) SAVE & RELOAD PREVIEW
        -------------------------------------------- */
        const out = await pdfDocW.save({
            useObjectStreams: false
        });

        const outBlob = new Blob([out], {
            type: "application/pdf"
        });

        if (signedBlobUrl.value) {
            try {
                URL.revokeObjectURL(signedBlobUrl.value);
            } catch {}
        }

        signedBlobUrl.value = URL.createObjectURL(outBlob);

        // reload PDF preview
        try {
            const doc = await pdfjsLib.getDocument({
                data: out
            }).promise;

            await nextTick();

            pdfDoc.value = markRaw(doc);
            pageCount.value = doc.numPages;

            pageNum.value = Math.max(
                1,
                Math.min(pageNum.value || 1, doc.numPages)
            );

            queueRender();
        } catch (e) {
            console.warn("reload preview failed:", e);
        }

        emits("done", outBlob);
        emits("refresh");

        message.success("Thông tin duyệt đã được cập nhật vào tài liệu.");
        await loadPdf();

        /* -------------------------------------------
           8) UPDATE BACKEND
        -------------------------------------------- */
        const payload = {
            task_file_id:
                target?.id ||
                target?.source_task_id ||
                target?.file_id ||
                null,

            approval_id: target?.approval_id || null,

            note: `Duyệt bởi ${approverDisplay} lúc ${vnTime}`,

            signed_by: currentUser.value?.id || null,
            signed_at: new Date().toISOString(),

            status: "approved",

            approver_display: approverDisplay,

            signed_file_name: target?.title || null,
            signed_file_path: target?.signed_pdf_url || null,
            signed_file_size: target?.file_size || null,

            document_id:
                target?.document_id ||
                target?.document?.id ||
                null,
        };

        let res;

        try {
            res = await approveDocument(payload);
        } catch (e) {
            const msg = e?.response?.data?.message || e.message;
            return message.error(
                msg || "Lỗi khi lưu thông tin duyệt."
            );
        }

        const serverData = res?.data || {};

        if (
            serverData?.message &&
            /được duyệt trước/i.test(serverData.message)
        ) {
            message.info(serverData.message);

            const existingSig = serverData?.data;

            if (target) {
                target.status = "approved";
                if (target.approval)
                    target.approval.status = "approved";

                target.file_signature = existingSig;
            }

            savingApprove.value = false;
            return;
        }

        message.success(
            serverData?.message || "Duyệt thành công."
        );

        if (target) {
            target.status = "approved";

            if (target.approval)
                target.approval.status = "approved";

            target.file_signature = serverData?.data || null;
        }
    } catch (err) {
        console.error("[finalizeApproval] error:", err);
        message.error("Duyệt thất bại.");
    } finally {
        savingApprove.value = false;
    }
}


/* target/docType logic preserved */
const targetForDoc = computed(() => {
    if (props.signTarget) return props.signTarget
    return null
})
const docType = computed(() => {
    try {
        const t = targetForDoc.value
        if (!t) return null
        return String(t.document?.doc_type || t.doc_type || t?.document_type || '').trim().toLowerCase() || null
    } catch { return null }
})
const disableApproveByDocType = computed(() => docType.value === 'internal')
const disableSignByDocType = computed(() => { if (!docType.value) return false; return docType.value !== 'internal' })

/* preview spinning boolean */
const previewSpinning = computed(() => props.open && (props.parentLoading || !isPdfReady.value))

/* debug traces (optional) */
watch([docType, targetForDoc], () => {
    console.log('[SignModal] targetForDoc:', targetForDoc.value)
    console.log('[SignModal] docType:', docType.value)
})
watchEffect(() => console.log('Child got props.signTarget =', props.signTarget))
</script>

<style scoped>
.wrap { display:flex; gap:12px; }
.left { flex:1 1 auto; }
.right { width:280px; }
.tools { display:flex; gap:8px; align-items:center; margin-bottom:8px; }
.stage {
    position:relative; border:1px solid #eee; border-radius:8px; padding:8px;
    overflow:auto; background:#fafafa;
}
canvas { display:block; max-width:100%; background:#fff; border-radius:4px; width: 100% }
.sig { position:absolute; user-select:none; cursor:move; }
.handle {
    position:absolute; width:16px; height:16px; border:2px solid #1677ff;
    background:#fff; border-radius:4px; cursor:nwse-resize; box-shadow:0 1px 2px rgba(0,0,0,.12);
}
.icon-btn { font-size: 14px; }

:deep(.ant-modal-body) {
    max-height: none !important;
    overflow: hidden !important;
}

.stage {
    overflow: auto !important;
    max-height: calc(100vh - 200px);
}
.stage::-webkit-scrollbar {
    width: 4px;      /* chiều rộng scrollbar dọc */
    height: 4px;     /* chiều cao scrollbar ngang */
}

.stage::-webkit-scrollbar-thumb {
    background: rgba(0,0,0,0.25);
    border-radius: 4px;
}

.stage::-webkit-scrollbar-thumb:hover {
    background: rgba(0,0,0,0.45);
}

.stage::-webkit-scrollbar-track {
    background: rgba(0,0,0,0.05);
}
:deep(.ant-modal-footer) {
    display: flex !important;
    gap: 12px !important;   /* spacing chuẩn */
}

:deep(.ant-modal-footer .ant-btn) {
    margin: 0 !important; /* xoá margin mặc định */
}


</style>
