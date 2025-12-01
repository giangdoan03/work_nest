<template>
    <a-modal
        :open="open"
        title="Ký tài liệu"
        width="820px"
        ok-text="Lưu bản đã ký"
        cancel-text="Hủy"
        :confirm-loading="saving"
        :ok-button-props="{ disabled: !isPdfReady || saving }"
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
                    @mousemove="onDrag"
                    @mouseup="endDrag"
                    @mouseleave="endDrag"
                >
                    <a-spin :spinning="previewSpinning" tip="Đang tải xem trước..." size="large">
                        <div class="pdf-viewer">
                            <canvas ref="canvasRef" class="pdf-canvas" />
                            <!-- signature image & handle (hidden in DOM, used for sizing/drag logic) -->
                            <div style="display: none">
                                <img
                                    v-if="effectiveSignatureUrl"
                                    ref="sigRef"
                                    class="sig"
                                    :src="effectiveSignatureUrl"
                                    :style="sigStyle"
                                    draggable="false"
                                    @mousedown.stop="startSigDrag"
                                    alt=""
                                />
                                <div
                                    v-if="effectiveSignatureUrl"
                                    class="handle"
                                    :style="handleStyle"
                                    @mousedown.stop="startScale"
                                />
                            </div>
                        </div>
                    </a-spin>
                </div>
            </div>
        </div>

        <template #footer>
            <a-button :disabled="saving" @click="$emit('update:open', false)">
                <template #icon><CloseOutlined class="icon-btn" /></template>
                Hủy
            </a-button>

            <a-button @click="downloadSigned">
                <template #icon><DownloadOutlined class="icon-btn" /></template>
                Tải bản đã ký
            </a-button>

            <a-button :disabled="saving" @click="downloadOriginal">
                <template #icon><FilePdfOutlined class="icon-btn" /></template>
                Tải bản gốc
            </a-button>

            <a-button
                :loading="savingApprove"
                :disabled="approveDisabled"
                @click="finalizeApproval"
                title="Nếu document là internal thì không thể duyệt"
            >
                <template #icon><CheckCircleOutlined class="icon-btn" /></template>
                Duyệt văn bản
            </a-button>

            <a-button
                type="primary"
                :loading="saving"
                :disabled="!isPdfReady || saving || disableSignByDocType"
                @click="handleSave"
                title="Nếu document phát hành ra ngoài thì không thể ký"
            >
                <template #icon><EditOutlined class="icon-btn" /></template>
                Ký văn bản
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

/* computed styles for signature handle */
const sigStyle = computed(() => ({
    left: sigX.value + 'px',
    top: sigY.value + 'px',
    width: sigW.value + 'px',
    opacity: (opacity.value / 100).toString()
}))
const handleStyle = computed(() => ({
    left: sigX.value + sigW.value - 8 + 'px',
    top: sigY.value + sigW.value * handleRatio() - 8 + 'px'
}))

/* drag/resize (kept performant) */
let draggingSig = false, scalingSig = false
let dragStart = { x: 0, y: 0 }, sigStart = { x: 0, y: 0, w: 0 }
let rafId = 0, pendingEvt = null

function startSigDrag(e) {
    draggingSig = true
    dragStart = { x: e.clientX, y: e.clientY }
    sigStart = { x: sigX.value, y: sigY.value, w: sigW.value }
}
function startScale(e) {
    scalingSig = true
    dragStart = { x: e.clientX, y: e.clientY }
    sigStart = { x: sigX.value, y: sigY.value, w: sigW.value }
}
function onDrag(e) {
    pendingEvt = e
    if (rafId) return
    rafId = requestAnimationFrame(() => {
        rafId = 0
        const evt = pendingEvt; pendingEvt = null
        if (!evt) return
        const box = stageRef.value?.getBoundingClientRect()
        const ratio = handleRatio()
        if (!box) return

        if (draggingSig) {
            const dx = evt.clientX - dragStart.x
            const dy = evt.clientY - dragStart.y
            const w = sigW.value, h = w * ratio
            const maxX = Math.max(0, box.width - 16 - w)
            const maxY = Math.max(0, box.height - 16 - h)
            sigX.value = Math.min(Math.max(0, sigStart.x + dx), maxX)
            sigY.value = Math.min(Math.max(0, sigStart.y + dy), maxY)
        } else if (scalingSig) {
            const dx = evt.clientX - dragStart.x
            const newW = Math.max(30, sigStart.w + dx)
            const maxW = Math.max(30, box.width - 16 - sigX.value)
            const maxH = Math.max(30, box.height - 16 - sigY.value)
            sigW.value = Math.min(newW, maxW, maxH / ratio)
        }
    })
}
function endDrag() { draggingSig = scalingSig = false; if (rafId) { cancelAnimationFrame(rafId); rafId = 0; pendingEvt = null } }

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

        // đúng công thức PDF.js
        const xCanvas = sig.xPdf * scaleX
        const yCanvas = (pdfH - sig.yPdf - sig.hPdf) * scaleY
        const wCanvas = sig.wPdf * scaleX
        const hCanvas = sig.hPdf * scaleY

        ctx.drawImage(img, xCanvas, yCanvas, wCanvas, hCanvas)
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


/* utility: get base page size (cached) */
async function getBaseSize(pIndex) {
    if (basePageSize.has(pIndex)) return basePageSize.get(pIndex)
    const page = await pdfDoc.value.getPage(pIndex)
    const vp = page.getViewport({ scale: 1 })
    const sz = { w: vp.width, h: vp.height }
    basePageSize.set(pIndex, sz)
    return sz
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


async function tryAutoPlaceSignatureForSignature() {
    const markers = myMarkers.value

    for (const m of markers) {
        const hits = await findSignatureMarkersSimple(m)
        if (hits.length) return hits[0] // lấy kết quả đầu tiên
    }

    return null
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
            hPdf: sigHeight
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
        const { PDFDocument } = PDFLib;

        // --- 1) Tải PDF gốc ---
        const pdfRes = await fetch(props.pdfUrl);
        if (!pdfRes.ok) throw new Error("Không tải được file PDF");
        const pdfBytes = await pdfRes.arrayBuffer();

        const pdfDocW = await PDFDocument.load(pdfBytes);

        // ======================================================
        // 2) NHÚNG CHỮ KÝ CỦA CÁC STEP ĐÃ KÝ TRƯỚC (existingPositions)
        // ======================================================
        for (let pIndex = 0; pIndex < pdfDocW.getPageCount(); pIndex++) {

            const page = pdfDocW.getPage(pIndex);
            const saved = existingPositions.value.filter(x => x.pageIndex === pIndex + 1);

            for (const s of saved) {
                const imgBytes = await fetch(s.signature_url).then(r => r.arrayBuffer());
                let img;
                try { img = await pdfDocW.embedPng(imgBytes); }
                catch { img = await pdfDocW.embedJpg(imgBytes); }

                page.drawImage(img, {
                    x: s.xPdf,
                    y: s.yPdf,
                    width: s.wPdf,
                    height: s.hPdf
                });
            }
        }

        // ======================================================
        // 3) NHÚNG CHỮ KÝ NGƯỜI ĐANG KÝ TRÊN CANVAS
        // ======================================================
        if (effectiveSignatureUrl.value) {

            const imgBytes = await fetch(effectiveSignatureUrl.value).then(r => r.arrayBuffer());
            let img;
            try { img = await pdfDocW.embedPng(imgBytes); }
            catch { img = await pdfDocW.embedJpg(imgBytes); }

            const pageIndex = pageNum.value - 1;
            const page = pdfDocW.getPage(pageIndex);

            const pdfW = page.getWidth();
            const pdfH = page.getHeight();

            // Lấy viewport PDF.js để mapping canvas → PDF
            const rawPage = await pdfDoc.value.getPage(pageNum.value);
            const vp = rawPage.getViewport({ scale: scale.value });

            const sigCanvasW = sigW.value;
            const sigCanvasH = sigCanvasW * handleRatio();

            // Canvas → PDF conversion
            const scaleX = pdfW / vp.width;
            const scaleY = pdfH / vp.height;

            const xPdf = sigX.value * scaleX;
            const yPdf = (vp.height - (sigY.value + sigCanvasH)) * scaleY;

            const wPdf = sigCanvasW * scaleX;
            const hPdf = sigCanvasH * scaleY;

            page.drawImage(img, {
                x: xPdf,
                y: yPdf,
                width: wPdf,
                height: hPdf
            });
        }

        // ======================================================
        // 4) XUẤT FILE CUỐI
        // ======================================================

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

function downloadOriginal() {
    if (!props.pdfUrl) return message.warning('Không có file gốc.')
    const a = document.createElement('a')
    a.href = props.pdfUrl
    a.download = 'original.pdf'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
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
    if (!props.pdfUrl) return message.warning('Không có file PDF để duyệt.')
    if (!pdfDoc.value) return message.warning('Vui lòng chờ PDF tải xong.')


    const target = props.signTarget || null
    console.log('target', target)
    const normalizeStatus = (v) => {
        try { if (v === null || typeof v === 'undefined') return ''; return String(v).trim().toLowerCase() } catch { return '' }
    }

    let alreadyApproved = false
    if (target) {
        const s1 = normalizeStatus(target.status)
        const s2 = normalizeStatus(target.approval?.status)
        const s3 = normalizeStatus(target.document?.status)
        const quick = (s1 === 'approved' || s2 === 'approved' || s3 === 'approved')
        if (quick) alreadyApproved = true
        else if (target.approval_id) {
            try {
                const detRes = await getApprovalDetail(target.approval_id)
                const det = detRes?.data || {}
                const apvStatus = normalizeStatus(det.approval?.status)
                const docStatus = normalizeStatus(det.document?.status)
                let sigs = det.signatures || det.file_signatures || det.file_signature || []
                if (sigs && !Array.isArray(sigs) && typeof sigs === 'object') sigs = Object.values(sigs)
                sigs = Array.isArray(sigs) ? sigs : []
                const hasApprovedSig = sigs.some(s => normalizeStatus(s?.status || s?.state || s) === 'approved')
                alreadyApproved = (apvStatus === 'approved') || (docStatus === 'approved') || hasApprovedSig

                const steps = Array.isArray(det.steps) ? det.steps : []
                if (!alreadyApproved && steps.length) {
                    const unfinished = new Set(['active', 'pending', 'waiting', 'in_progress', 'todo', 'running'])
                    const anyUnfinished = steps.some(s => unfinished.has(normalizeStatus(s?.status || s?.step_status || s?.state || '')))
                    if (!anyUnfinished) alreadyApproved = true
                }
            } catch (e) { console.warn('getApprovalDetail failed:', e); alreadyApproved = false }
        }
    }

    if (alreadyApproved) {
        return message.info('Tài liệu này đã được duyệt trước đó.')
    }

    savingApprove.value = true
    try {
        const pdfRes = await safeFetch(props.pdfUrl)
        if (!pdfRes.ok) throw new Error('Không tải được file PDF')
        const pdfBytes = await pdfRes.arrayBuffer()

        if (!PDFLib) await loadPdfLib()
        const { PDFDocument, rgb, StandardFonts } = PDFLib
        const pdfDocW = await PDFDocument.load(pdfBytes, { updateMetadata: false })
        try {
            const fontkitMod = await import('@pdf-lib/fontkit')
            pdfDocW.registerFontkit(fontkitMod.default || fontkitMod)
        } catch (e) { console.warn('fontkit not available:', e) }

        const lastIndex = Math.max(0, pdfDocW.getPageCount() - 1)
        const page = pdfDocW.getPage(lastIndex)
        const pdfW = page.getWidth()

        const rawApprover = currentUser.value?.full_name || currentUser.value?.name || currentUser.value?.username || 'NguoiDuyet'
        const sanitizeToAscii = s => {
            try {
                const nd = s.normalize('NFD').replace(/\p{Diacritic}/gu, '')
                return nd.replace(/Đ/g, 'D').replace(/đ/g, 'd').replace(/[^\x00-\x7F ]/g, '')
            } catch { return String(s).replace(/[Đđ]/g, c => c === 'Đ' ? 'D' : 'd').replace(/[^\x00-\x7F ]/g, '') }
        }
        const approverDisplay = sanitizeToAscii(rawApprover)
        const now = new Date()
        const pad = n => String(n).padStart(2, '0')
        const vnTime = `${pad(now.getDate())}/${pad(now.getMonth()+1)}/${now.getFullYear()}, ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`
        const timeText = `${approverDisplay} — Date: ${vnTime}`

        let usedFont = await loadFontIfAvailable(pdfDocW)
        if (!usedFont) usedFont = await pdfDocW.embedFont(StandardFonts.Helvetica)

        const fontSize = 6
        const textWidth = usedFont.widthOfTextAtSize(timeText, fontSize)
        const textHeight = typeof usedFont.heightAtSize === 'function' ? usedFont.heightAtSize(fontSize) : fontSize
        const margin = 20
        const textX = Math.max(margin, pdfW - margin - textWidth)
        const textY = margin
        const lineY = textY + textHeight + 2

        page.drawRectangle({ x: textX, y: lineY, width: textWidth, height: 0.7, color: rgb(0, 0, 0) })
        page.drawText(timeText, { x: textX, y: textY, size: fontSize, font: usedFont, color: rgb(0,0,0) })

        const out = await pdfDocW.save({ useObjectStreams: false })
        const outBlob = new Blob([out], { type: 'application/pdf' })
        if (signedBlobUrl.value) { try { URL.revokeObjectURL(signedBlobUrl.value) } catch {} }
        signedBlobUrl.value = URL.createObjectURL(outBlob)

        try {
            const doc = await pdfjsLib.getDocument({ data: out }).promise
            await nextTick()
            pdfDoc.value = markRaw(doc)
            pageCount.value = doc.numPages
            pageNum.value = Math.max(1, Math.min(pageNum.value || 1, doc.numPages))
            queueRender()
        } catch (e) { console.warn('reload preview from bytes failed:', e) }

        emits('done', outBlob)
        emits('refresh')
        message.success('Đã chèn thông tin duyệt vào file (local).')

        const payload = {
            task_file_id: target?.id || target?.source_task_id || target?.file_id || null,
            approval_id: target?.approval_id || null,
            note: `Duyệt bởi ${approverDisplay} lúc ${vnTime}`,
            signed_by: currentUser.value?.id || null,
            signed_at: new Date().toISOString(),
            status: 'approved',
            approver_display: approverDisplay,
            signed_file_name: target?.title || null,
            signed_file_path: target?.signed_pdf_url || null,
            signed_file_size: target?.file_size || null,
            document_id: target?.document_id || target?.document?.id || null,
        }

        let res
        try { res = await approveDocument(payload) } catch (e) {
            const msg = e?.response?.data?.message || e.message
            return message.error(msg || 'Lỗi khi lưu thông tin duyệt.')
        }

        const serverData = res?.data || {}
        if (serverData?.message && /được duyệt trước/i.test(String(serverData.message))) {
            message.info(serverData.message)
            const existingSig = serverData?.data
            if (target) {
                target.status = 'approved'
                if (target.approval) target.approval.status = 'approved'
                target.file_signature = existingSig
            }
            savingApprove.value = false
            return
        }

        message.success(serverData?.message || 'Duyệt thành công.')
        if (target) {
            target.status = 'approved'
            if (target.approval) target.approval.status = 'approved'
            target.file_signature = serverData?.data || null
        }
    } catch (err) {
        console.error('[finalizeApproval] error:', err)
        message.error('Duyệt thất bại.')
    } finally {
        savingApprove.value = false
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
canvas { display:block; max-width:100%; background:#fff; border-radius:4px; }
.sig { position:absolute; user-select:none; cursor:move; }
.handle {
    position:absolute; width:16px; height:16px; border:2px solid #1677ff;
    background:#fff; border-radius:4px; cursor:nwse-resize; box-shadow:0 1px 2px rgba(0,0,0,.12);
}
.icon-btn { font-size: 14px; }
</style>
