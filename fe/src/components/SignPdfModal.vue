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
            <!-- Trái: PDF + công cụ -->
            <div class="left">
                <div class="tools">
                    <a-select v-model:value="pageNum" style="width: 120px">
                        <a-select-option v-for="p in pageCount" :key="p" :value="p">
                            Trang {{ p }}
                        </a-select-option>
                    </a-select>
                    <a-input-number v-model:value="scale" :min="0.5" :max="3" :step="0.1"/>
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
                    <div class="pdf-viewer">
                        <canvas ref="canvasRef" class="pdf-canvas"/>
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
                </div>
            </div>
        </div>
        <template #footer>
            <a-button :disabled="saving" @click="$emit('update:open', false)">
                Hủy
            </a-button>

            <a-button :disabled="!signedBlobUrl || saving" @click="downloadSigned">
                Tải bản đã ký
            </a-button>

            <a-button :disabled="saving" @click="downloadOriginal">
                Tải bản gốc
            </a-button>
            <a-button
                :loading="savingApprove"
                :disabled="saving || !isPdfReady"
                @click="handleApproveDuyet"
            >
                Duyệt
            </a-button>

            <a-button type="primary" :loading="saving" :disabled="!isPdfReady || saving" @click="handleSave">
                Lưu bản đã ký
            </a-button>
        </template>
    </a-modal>
</template>

<script setup>
import {ref, watch, nextTick, shallowRef, markRaw, computed, onBeforeUnmount} from 'vue'
import {message} from 'ant-design-vue'
import {checkSession} from '@/api/auth' // ⭐ dùng axios client chung

import { uploadTaskFileSigned , approveDocument} from '@/api/document'

// -------- pdf.js (legacy) + worker url --------
import * as pdfjsLib from 'pdfjs-dist/legacy/build/pdf'
import pdfWorker from 'pdfjs-dist/legacy/build/pdf.worker.min.js?url'

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfWorker

// -------- pdf-lib lazy --------
let PDFLib = null
const loadPdfLib = async () => {
    if (!PDFLib) PDFLib = await import('pdf-lib')
}

// -------- tesseract lazy (OCR fallback) --------
let Tesseract = null
const loadTesseract = async () => {
    if (!Tesseract) Tesseract = (await import('tesseract.js')).default
}
const TESSDATA_URL = 'https://tessdata.projectnaptha.com/4.0.0'

// -------- props / emits --------
const props = defineProps({
    open: {type: Boolean, default: false},
    pdfUrl: {type: String, default: ''},
    signatureUrl: {type: String, default: ''},

    // Auto place
    autoPlace: {type: Boolean, default: true},
    markers: {type: [String, Array], default: () => ['HCNS', 'chuky1', 'chuky2', 'chuky3']},
    markerWidthPct: {type: Number, default: 25},
    yOffsetPct: {type: Number, default: -18},
    centerOnMarker: {type: Boolean, default: true},

    // OCR
    useOCR: {type: Boolean, default: true},
    ocrScale: {type: Number, default: 2},
    ocrLang: {type: String, default: 'eng+vie'},
    caseInsensitive: {type: Boolean, default: true},
    wholeWord: {type: Boolean, default: true},

    // Lưu xong có đóng modal không
    closeAfterSave: {type: Boolean, default: false},
    // --- thêm prop signTarget ---
    signTarget: { type: Object, default: null },
})
const emits = defineEmits(['update:open', 'done'])

// -------- state --------
const canvasRef = ref()
const stageRef = ref()
const pdfDoc = shallowRef(null)
const pageNum = ref(1)
const pageCount = ref(1)
const scale = ref(1)

const sigRef = ref()
const sigX = ref(40)
const sigY = ref(40)
const sigW = ref(200)
const opacity = ref(100)
const saving   = ref(false)
const isPdfReady = ref(false)
const currentUser = ref(null)

const signedBlobUrl = ref('') // 🔹 URL tải bản đã ký
const savingApprove = ref(false)



const localSignatureUrl = ref('') // fallback /api/check
const effectiveSignatureUrl = computed(() => props.signatureUrl || localSignatureUrl.value)

// render control
let currentRenderTask = null
let renderQueued = false
let destroyed = false

// base size cache
const basePageSize = new Map()

// -------- markers động từ props + preferred_marker --------
function normalizeMarkers(input) {
    if (Array.isArray(input)) {
        return input.map(String).map(s => s.trim()).filter(Boolean)
    }
    return String(input || '')
        .split(',')
        .map(s => s.trim())
        .filter(Boolean)
}

function downloadSigned() {
    if (!signedBlobUrl.value) return
    const a = document.createElement('a')
    a.href = signedBlobUrl.value
    a.download = 'signed.pdf'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
}

function downloadOriginal() {
    if (!props.pdfUrl) return message.warning('Không có file gốc.')
    const a = document.createElement('a')
    a.href = props.pdfUrl
    // nếu bạn muốn force download filename
    a.download = 'original.pdf'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
}


const myMarkers = ref(normalizeMarkers(props.markers))

// -------- helpers --------
function handleRatio() {
    try {
        const el = sigRef.value
        return el && el.naturalWidth ? el.naturalHeight / el.naturalWidth : 0.35
    } catch {
        return 0.35
    }
}

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

// -------- drag / resize --------
let draggingSig = false, scalingSig = false
let dragStart = {x: 0, y: 0}, sigStart = {x: 0, y: 0, w: 0}
let rafId = 0, pendingEvt = null

function startSigDrag(e) {
    draggingSig = true
    dragStart = {x: e.clientX, y: e.clientY}
    sigStart = {x: sigX.value, y: sigY.value, w: sigW.value}
}

function startScale(e) {
    scalingSig = true
    dragStart = {x: e.clientX, y: e.clientY}
    sigStart = {x: sigX.value, y: sigY.value, w: sigW.value}
}

function onDrag(e) {
    pendingEvt = e
    if (rafId) return
    rafId = requestAnimationFrame(() => {
        rafId = 0
        const evt = pendingEvt;
        pendingEvt = null
        if (!evt) return
        const box = stageRef.value?.getBoundingClientRect()
        const ratio = handleRatio()
        if (!box) return

        if (draggingSig) {
            const dx = evt.clientX - dragStart.x
            const dy = evt.clientY - dragStart.y
            const w = sigW.value
            const h = w * ratio
            const maxX = Math.max(0, box.width - 16 - w)
            const maxY = Math.max(0, box.height - 16 - h)
            sigX.value = Math.min(Math.max(0, sigStart.x + dx), maxX)
            sigY.value = Math.min(Math.max(0, sigStart.y + dy), maxY)
        } else if (scalingSig) {
            const dx = evt.clientX - dragStart.x
            const newW = Math.max(30, sigStart.w + dx)
            const h = newW * ratio
            const maxW = Math.max(30, box.width - 16 - sigX.value)
            const maxH = Math.max(30, box.height - 16 - sigY.value)
            sigW.value = Math.min(newW, maxW, maxH / ratio)
        }
    })
}

function endDrag() {
    draggingSig = false
    scalingSig = false
    if (rafId) {
        cancelAnimationFrame(rafId)
        rafId = 0
        pendingEvt = null
    }
}

// -------- render helpers --------
function queueRender() {
    if (renderQueued) return
    renderQueued = true
    requestAnimationFrame(async () => {
        renderQueued = false
        isPdfReady.value = false
        try {
            await renderPage()
        } finally {
            if (!destroyed) isPdfReady.value = true
        }
    })
}

async function renderPage() {
    if (!pdfDoc.value || !canvasRef.value || destroyed) return
    if (currentRenderTask) {
        try {
            currentRenderTask.cancel()
        } catch {
        }
        currentRenderTask = null
    }

    const page = await pdfDoc.value.getPage(pageNum.value)
    const container = stageRef.value || canvasRef.value.parentElement
    const box = container?.getBoundingClientRect()
    if (!box?.width || !box?.height) return

    const baseViewport = page.getViewport({scale: 1, rotation: 0})
    const dpr = window.devicePixelRatio || 1
    const cssScale = box.width / baseViewport.width
    const renderScale = cssScale * dpr
    const renderViewport = page.getViewport({scale: renderScale, rotation: 0})

    const canvas = canvasRef.value
    const ctx = canvas.getContext('2d')

    canvas.width = Math.floor(renderViewport.width)
    canvas.height = Math.floor(renderViewport.height)
    canvas.style.width = Math.round(baseViewport.width * cssScale) + 'px'
    canvas.style.height = Math.round(baseViewport.height * cssScale) + 'px'

    ctx.clearRect(0, 0, canvas.width, canvas.height)

    const task = page.render({canvasContext: ctx, viewport: renderViewport})
    currentRenderTask = task
    try {
        await task.promise
    } catch (e) {
        if (e?.name !== 'RenderingCancelledException') throw e
    } finally {
        if (currentRenderTask === task) currentRenderTask = null
    }
}

function fitWidth() {
    const box = stageRef.value?.getBoundingClientRect()
    if (!box || !pdfDoc.value) return
    pdfDoc.value.getPage(pageNum.value).then(p => {
        const vp = p.getViewport({scale: 1, rotation: 0})
        scale.value = Math.max(0.5, Math.min(3, (box.width - 24) / vp.width))
    })
}

function resetView() {
    scale.value = 1
    sigX.value = 40
    sigY.value = 40
    sigW.value = 200
}

async function getBaseSize(pIndex) {
    if (basePageSize.has(pIndex)) return basePageSize.get(pIndex)
    const page = await pdfDoc.value.getPage(pIndex)
    const vp = page.getViewport({scale: 1})
    const sz = {w: vp.width, h: vp.height}
    basePageSize.set(pIndex, sz)
    return sz
}

function buildRegex(query, caseInsensitive = true, wholeWord = true) {
    const esc = String(query).replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    const flags = caseInsensitive ? 'iu' : 'u'
    if (wholeWord) {
        try {
            return new RegExp(`(?<![\\p{L}\\p{N}_])${esc}(?![\\p{L}\\p{N}_])`, flags)
        } catch {
            return new RegExp(`\\b${esc}\\b`, caseInsensitive ? 'i' : '')
        }
    }
    return new RegExp(esc, caseInsensitive ? 'i' : '')
}

// -------- auto-place (AcroForm → TEXT → OCR) --------
async function tryAutoPlaceSignature() {
    if (!pdfDoc.value) return false

    // 1) AcroForm Sig/Widget
    for (let p = pdfDoc.value.numPages; p >= 1; p--) {
        try {
            const page = await pdfDoc.value.getPage(p)
            const annots = await page.getAnnotations({intent: 'display'})
            const sigAnnot = (annots || []).find(a =>
                a?.fieldType === 'Sig' ||
                (a?.fieldType === 'Widget' && /Sig/i.test(String(a?.fieldName || ''))) ||
                /signature/i.test(String(a?.fieldName || ''))
            )
            if (sigAnnot?.rect) {
                const vp = page.getViewport({scale: scale.value, rotation: 0})
                const [llx, lly, urx, ury] = sigAnnot.rect
                const pdfW = page.view[2] - page.view[0]
                const pdfH = page.view[3] - page.view[1]

                const xCanvas = (llx / pdfW) * vp.width
                const yCanvas = vp.height - (ury / pdfH) * vp.height
                const wCanvas = ((urx - llx) / pdfW) * vp.width
                const hCanvas = ((ury - lly) / pdfH) * vp.height

                pageNum.value = p
                const ratio = handleRatio()
                sigW.value = Math.max(60, Math.min(wCanvas * 0.8, 400))
                sigX.value = Math.max(8, xCanvas + (wCanvas - sigW.value) / 2)
                const sigH = sigW.value * ratio
                sigY.value = Math.max(8, yCanvas + (hCanvas - sigH) / 2)
                return true
            }
        } catch {
        }
    }

    // 2) TEXT markers (dùng myMarkers)
    const baseMarkers = normalizeMarkers(props.markers)
    const markers = (myMarkers.value && myMarkers.value.length)
        ? myMarkers.value
        : baseMarkers

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
                return {str: it.str || '', x: e, y: f, w, h}
            }).filter(s => s.str)

            spans.sort((p, q) => q.y - p.y || p.x - q.x)
            const lines = []
            for (const s of spans) {
                const L = lines.find(l => Math.abs(l.y - s.y) <= Y_TOL)
                if (L) L.items.push(s); else lines.push({y: s.y, items: [s]})
            }

            for (const line of lines) {
                line.items.sort((p, q) => p.x - q.x)
                let textLine = '';
                const segs = [];
                let cursor = 0
                for (let i = 0; i < line.items.length; i++) {
                    const it = line.items[i], prev = line.items[i - 1]
                    if (i > 0) {
                        const gap = it.x - (prev.x + prev.w), avgH = (it.h + prev.h) / 2
                        if (gap > avgH * GAP) {
                            textLine += ' ';
                            cursor += 1
                        }
                    }
                    const start = cursor;
                    textLine += it.str;
                    cursor += it.str.length
                    segs.push({start, end: cursor, x: it.x, y: it.y, w: it.w, h: it.h})
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
                        minX = Math.min(minX, g.x);
                        maxX = Math.max(maxX, g.x + g.w)
                        minY = Math.min(minY, g.y - g.h);
                        maxY = Math.max(maxY, g.y)
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
        textHits.push(...h.map(o => ({...o, _m: m})))
    }

    // 3) OCR fallback (vẫn dùng markers đã build)
    if (props.useOCR && !textHits.length) {
        await loadTesseract()
        for (let pageIndex = 1; pageIndex <= pdfDoc.value.numPages; pageIndex++) {
            const page = await pdfDoc.value.getPage(pageIndex)
            const vp1 = page.getViewport({scale: 1})
            const scaleOCR = Math.max(1, Math.min(3, props.ocrScale))
            const vp = page.getViewport({scale: scaleOCR})
            const off = document.createElement('canvas')
            off.width = Math.floor(vp.width);
            off.height = Math.floor(vp.height)
            await page.render({canvasContext: off.getContext('2d'), viewport: vp}).promise

            const res = await Tesseract.recognize(off, props.ocrLang, {
                langPath: TESSDATA_URL, logger: () => {
                }
            })
            const words = res?.data?.words || []
            for (const w of words) {
                const text = (w.text || '').trim()
                if (!text) continue
                for (const m of markers) {
                    const re = buildRegex(m, props.caseInsensitive, props.wholeWord)
                    if (!re.test(text)) continue
                    const {x0, y0, x1, y1} = w.bbox || {}
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

    // Ưu tiên marker trùng preferred_marker của user hiện tại
    const pm = (currentUser.value?.preferred_marker || '').trim()
    let candidates = textHits
    if (pm) {
        const prefer = textHits.filter(h => h._m === pm)
        if (prefer.length) {
            candidates = prefer
        }
    }

    const byPageDesc = [...candidates].sort((a,b) => b.pageIndex - a.pageIndex)
    const topPage = byPageDesc[0].pageIndex
    const samePage = candidates.filter(h => h.pageIndex === topPage)
    samePage.sort((a,b) => (a.pdfY - b.pdfY))
    const hit = samePage[0]

    const rawPage = await pdfDoc.value.getPage(hit.pageIndex)
    const vpBase = rawPage.getViewport({scale: 1, rotation: 0})
    const vpView = rawPage.getViewport({scale: scale.value, rotation: 0})

    const wpct = Math.max(5, Math.min(80, Number(props.markerWidthPct || 25)))
    const targetCanvasW = vpView.width * (wpct / 100)
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

// -------- IO --------
async function loadPdf() {
    if (!props.pdfUrl) return
    isPdfReady.value = false
    try {
        const res = await fetch(props.pdfUrl)
        const buffer = await res.arrayBuffer()
        const task = pdfjsLib.getDocument({data: buffer})
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
            } catch {
            }
        }
    } catch (err) {
        console.error('loadPdf lỗi:', err)
        message.error('Không tải được tài liệu PDF.')
    }
}

// -------- lifecycle --------
watch(() => props.open, async (v) => {
    if (v) {
        destroyed = false
        isPdfReady.value = false
        await nextTick()
        await loadPdfLib()

        // reset markers theo props
        myMarkers.value = normalizeMarkers(props.markers)

        // fallback chữ ký & marker động từ /api/check
        localSignatureUrl.value = props.signatureUrl || ''
        try {
            const res = await checkSession()
            const user = res.data?.user || {}
            currentUser.value = user

            // chữ ký mặc định
            if (!localSignatureUrl.value && user.signature_url) {
                localSignatureUrl.value = user.signature_url
            }

            // preferred_marker lên đầu
            const pm = (user.preferred_marker || '').trim()
            if (pm) {
                const set = new Set([pm, ...myMarkers.value])
                myMarkers.value = Array.from(set)
            }
        } catch (e) {
            console.error('Lỗi checkSession:', e)
        }

        await loadPdf()
    } else {
        destroyed = true
        if (currentRenderTask){ try{ currentRenderTask.cancel() }catch{} currentRenderTask = null }
        pdfDoc.value = null

        if (signedBlobUrl.value) {
            URL.revokeObjectURL(signedBlobUrl.value)
            signedBlobUrl.value = ''
        }
    }
}, {immediate: true})

watch([pageNum, scale], () => {
    if (pdfDoc.value) queueRender()
})

onBeforeUnmount(() => {
    destroyed = true
    if (currentRenderTask){ try{ currentRenderTask.cancel() }catch{} currentRenderTask = null }
    if (signedBlobUrl.value) {
        URL.revokeObjectURL(signedBlobUrl.value)
        signedBlobUrl.value = ''
    }
})
// -------- save --------
async function handleSave() {
    if (!props.pdfUrl) return message.warning('Không có file PDF để ký.')
    if (!effectiveSignatureUrl.value) return message.warning('Chưa có ảnh chữ ký.')
    if (!pdfDoc.value) return message.warning('Vui lòng chờ PDF tải xong.')
    if (!PDFLib) await loadPdfLib()

    saving.value = true
    try {
        if (props.autoPlace && effectiveSignatureUrl.value &&
            (!sigRef.value || (sigX.value === 40 && sigY.value === 40))) {
            try {
                await tryAutoPlaceSignature()
            } catch {
            }
        }

        const [pdfRes, sigRes] = await Promise.all([
            fetch(props.pdfUrl),
            fetch(effectiveSignatureUrl.value)
        ])
        if (!pdfRes.ok || !sigRes.ok) throw new Error('Không tải được file hoặc ảnh')
        const pdfBytes = await pdfRes.arrayBuffer()
        const imgBytes = await sigRes.arrayBuffer()

        const {PDFDocument, degrees} = PDFLib
        const pdfDocW = await PDFDocument.load(pdfBytes, {updateMetadata: false})
        const page = pdfDocW.getPage(pageNum.value - 1)

        let img
        try {
            img = await pdfDocW.embedPng(imgBytes)
        } catch {
            img = await pdfDocW.embedJpg(imgBytes)
        }

        const rawPage = await pdfDoc.value.getPage(pageNum.value)
        const pageRotate = (rawPage.rotate || 0) % 360
        const vpRender = rawPage.getViewport({scale: scale.value, rotation: 0})

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
            case 0:
                break
            case 180:
                xPdf = pdfW - xPdf - wPdf
                yPdf = pdfH - yPdf - hPdf
                break
            case 90: {
                const nx = yPdf
                const ny = pdfW - (xPdf + wPdf)
                xPdf = nx;
                yPdf = ny
                const t = wPdf;
                wPdf = hPdf;
                hPdf = t
                rotateDeg = 90
                break
            }
            case 270: {
                const nx = pdfH - (yPdf + hPdf)
                const ny = xPdf
                xPdf = nx;
                yPdf = ny
                const t = wPdf;
                wPdf = hPdf;
                hPdf = t
                rotateDeg = 270
                break
            }
        }

        // --- sau khi đã tính xPdf, yPdf, wPdf, hPdf, rotateDeg ---
        page.drawImage(img, {
            x: xPdf, y: yPdf, width: wPdf, height: hPdf,
            opacity: opacity.value / 100,
            rotate: rotateDeg ? degrees(rotateDeg) : undefined
        })

        // --- thêm: chèn thời gian ký nhỏ, bên dưới ảnh ---
        try {
            // cố gắng register fontkit (cần để embed custom TTF)
            try {
                const fontkitMod = await import('@pdf-lib/fontkit')
                const fontkit = fontkitMod?.default || fontkitMod
                pdfDocW.registerFontkit(fontkit)
            } catch (e) {
                console.warn('Không load được @pdf-lib/fontkit, sẽ fallback nếu cần:', e)
            }

            // đường dẫn font Unicode trong public
            const fontUrl = '/fonts/NotoSans-Regular.ttf'
            let usedFont = null
            let fontSize = Math.max(5, Math.min(12, (wPdf / 20))) // cài theo bạn
            let timeText = ''
            try {
                // build time string: Date dd/mm/yyyy HH:MM:SS
                const now = new Date()
                const day = String(now.getDate()).padStart(2, '0')
                const month = String(now.getMonth() + 1).padStart(2, '0')
                const year = now.getFullYear()
                const hours = String(now.getHours()).padStart(2, '0')
                const minutes = String(now.getMinutes()).padStart(2, '0')
                const seconds = String(now.getSeconds()).padStart(2, '0')
                timeText = `Date: ${day}/${month}/${year}, ${hours}:${minutes}:${seconds}`;

                // thử load font unicode
                const fResp = await fetch(fontUrl)
                if (fResp.ok) {
                    const fBytes = await fResp.arrayBuffer()
                    usedFont = await pdfDocW.embedFont(fBytes)
                } else {
                    console.warn('Không load được TTF Unicode, status=', fResp.status)
                }
            } catch (e) {
                console.warn('Lỗi khi load/embed font Unicode:', e)
            }

            // helper sanitize nếu phải fallback sang WinAnsi
            const sanitizeToAscii = (s) => {
                try {
                    const nd = s.normalize('NFD').replace(/\p{Diacritic}/gu, '')
                    return nd.replace(/Đ/g, 'D').replace(/đ/g, 'd')
                } catch {
                    return s.replace(/[Đđ]/g, c => c === 'Đ' ? 'D' : 'd').replace(/[^\x00-\x7F]/g, '')
                }
            }

            if (!usedFont) {
                // fallback: embed Helvetica (WinAnsi) and sanitize text to avoid WinAnsi error
                usedFont = await pdfDocW.embedFont(PDFLib.StandardFonts.Helvetica)
                timeText = sanitizeToAscii(timeText)
            }

            // tính kích thước / vị trí như cũ
            const textWidth = usedFont.widthOfTextAtSize(timeText, fontSize)
            const textHeight = (typeof usedFont.heightAtSize === 'function') ? usedFont.heightAtSize(fontSize) : fontSize

            let textX = xPdf + (wPdf - textWidth) / 2
            let textY = yPdf - textHeight - 4
            if (textY < 0) textY = yPdf + hPdf + 4

            // draw text (rotate giữ nguyên)
            page.drawText(timeText, {
                x: textX,
                y: textY,
                size: fontSize,
                font: usedFont,
                opacity: 1,
                rotate: rotateDeg ? degrees(rotateDeg) : undefined
            })
        } catch (err) {
            console.warn('Không chèn được thời gian ký:', err)
        }


        const out = await pdfDocW.save({ useObjectStreams: false })
        const signedBlob = new Blob([out], { type: 'application/pdf' })

        // 🔹 cập nhật URL cho nút "Tải bản đã ký"
        if (signedBlobUrl.value) {
            URL.revokeObjectURL(signedBlobUrl.value)
        }
        signedBlobUrl.value = URL.createObjectURL(signedBlob)

        emits('done', signedBlob)
        message.success('Đã chèn chữ ký đúng vị trí.')


        if (props.closeAfterSave) emits('update:open', false)

        try {
            const buf = await fetch(signedBlobUrl.value).then(r => r.arrayBuffer())
            const task = pdfjsLib.getDocument({ data: buf })
            const doc = await task.promise
            pdfDoc.value = markRaw(doc)
            pageCount.value = doc.numPages
            queueRender()
        } catch {
        }
    } catch (e) {
        console.error(e)
        message.error('Ký thất bại.')
    } finally {
        saving.value = false
    }
}





async function handleApproveDuyet() {
    if (!props.pdfUrl) return message.warning('Không có file PDF để duyệt.');
    if (!pdfDoc.value) return message.warning('Vui lòng chờ PDF tải xong.');

    const target = props.signTarget || (typeof signTarget !== 'undefined' ? signTarget.value : null);
    if (!target) {
        console.warn('No signTarget — payload sẽ không có task_file_id.');
    }

    // === 1) Chặn duyệt nếu FE biết là đã duyệt ===
    // === 1) Chặn duyệt: verify trực tiếp từ server (an toàn hơn) ===
    let alreadyApproved = false;

    if (target) {
        // 1. quick local check (fast UX)
        const quick = (
            String(target.status || '').toLowerCase() === 'approved' ||
            String(target.approval?.status || '').toLowerCase() === 'approved' ||
            String(target.document?.status || '').toLowerCase() === 'approved'
        );
        if (quick) {
            alreadyApproved = true;
        } else if (target.approval_id) {
            // 2. nếu quick không khẳng định, gọi server để verify thật
            try {
                // getApprovalDetail là API bạn đang có trong code
                const detRes = await getApprovalDetail(target.approval_id);
                const det = detRes?.data || {};
                const apv = det.approval || {};
                const doc = det.document || {};
                // kiểm tra các cờ trên server
                const srvOk = (
                    String(apv.status || '').toLowerCase() === 'approved' ||
                    String(doc.status || '').toLowerCase() === 'approved'
                );

                // nếu server có signatures mới (file_signatures) mà status = approved -> xem là đã duyệt
                const sigs = det.signatures || det.file_signatures || [];
                const hasApprovedSig = Array.isArray(sigs) && sigs.some(s => String(s.status || '').toLowerCase() === 'approved');

                alreadyApproved = srvOk || hasApprovedSig;

                // nếu server trả thông tin bước và step hiện đã được approved bởi bạn/ai đó
                const steps = det.steps || [];
                if (!alreadyApproved && Array.isArray(steps)) {
                    // nếu tất cả steps trước đó đều approved và current step không thuộc user => coi là đã qua
                    const anyCurrent = steps.some(s => String(s.status || '').toLowerCase() === 'pending');
                    // nếu không có pending step => đã hoàn tất
                    if (!anyCurrent) {
                        alreadyApproved = true;
                    }
                }
            } catch (e) {
                // Gọi server fail: không chặn (vì backend idempotent sẽ bảo vệ)
                console.warn('Không thể verify trạng thái duyệt từ server, sẽ tiếp tục. ', e);
                alreadyApproved = false;
            }
        }
    }

    if (alreadyApproved) {
        return message.info('Tài liệu này đã được duyệt trước đó.');
    }

    savingApprove.value = true;

    try {
        // ============================
        // (2) CHÈN TEXT DUYỆT LÊN PDF
        // ============================
        const pdfRes = await fetch(props.pdfUrl);
        if (!pdfRes.ok) throw new Error('Không tải được file PDF');
        const pdfBytes = await pdfRes.arrayBuffer();

        const { PDFDocument, rgb, StandardFonts } = PDFLib;
        const pdfDocW = await PDFDocument.load(pdfBytes, { updateMetadata: false });

        // try load fontkit
        try {
            const fontkitMod = await import('@pdf-lib/fontkit');
            pdfDocW.registerFontkit(fontkitMod.default || fontkitMod);
        } catch (e) {
            console.warn('Không thể load fontkit:', e);
        }

        // chọn trang cuối
        const lastIndex = Math.max(0, pdfDocW.getPageCount() - 1);
        const page = pdfDocW.getPage(lastIndex);
        const pdfW = page.getWidth();

        // tên người duyệt
        const rawApprover =
            currentUser.value?.full_name ||
            currentUser.value?.name ||
            currentUser.value?.username ||
            'NguoiDuyet';

        // bỏ dấu + ký tự unicode nếu font không hỗ trợ
        const sanitizeToAscii = (s) => {
            try {
                const nd = s.normalize('NFD').replace(/\p{Diacritic}/gu, '');
                return nd.replace(/Đ/g, 'D').replace(/đ/g, 'd').replace(/[^\x00-\x7F ]/g, '');
            } catch {
                return String(s).replace(/[Đđ]/g, c => c === 'Đ' ? 'D' : 'd').replace(/[^\x00-\x7F ]/g, '');
            }
        };

        const approverDisplay = sanitizeToAscii(rawApprover);

        const now = new Date();
        const pad = (n) => String(n).padStart(2, '0');
        const vnTime = `${pad(now.getDate())}/${pad(now.getMonth()+1)}/${now.getFullYear()}, ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;

        const timeText = `${approverDisplay} — Date: ${vnTime}`;

        // try unicode font
        let usedFont = null;
        try {
            const f = await fetch('/fonts/NotoSans-Regular.ttf');
            if (f.ok) {
                const fBytes = await f.arrayBuffer();
                usedFont = await pdfDocW.embedFont(fBytes);
            }
        } catch (e) {
            console.warn('Unicode font fail, fallback Helvetica.');
        }
        if (!usedFont) usedFont = await pdfDocW.embedFont(StandardFonts.Helvetica);

        const fontSize = 6;
        const textWidth = usedFont.widthOfTextAtSize(timeText, fontSize);
        const textHeight = usedFont.heightAtSize ? usedFont.heightAtSize(fontSize) : fontSize;
        const margin = 20;

        const textX = Math.max(margin, pdfW - margin - textWidth);
        const textY = margin;

        page.drawRectangle({
            x: textX,
            y: textY - 2,
            width: textWidth,
            height: 0.5,
            color: rgb(0, 0, 0)
        });

        page.drawText(timeText, {
            x: textX,
            y: textY,
            size: fontSize,
            font: usedFont,
            color: rgb(0, 0, 0)
        });

        // tạo blob để preview local
        const out = await pdfDocW.save({ useObjectStreams: false });
        const outBlob = new Blob([out], { type: 'application/pdf' });

        if (signedBlobUrl.value) URL.revokeObjectURL(signedBlobUrl.value);
        signedBlobUrl.value = URL.createObjectURL(outBlob);

        emits('approved', outBlob);
        message.success('Đã chèn thông tin duyệt vào file (local).');

        // ============================
        // (3) LƯU METADATA VÀO DB
        // ============================
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
        };

        let res;
        try {
            res = await approveDocument(payload);
        } catch (e) {
            const msg = e?.response?.data?.message || e.message;
            return message.error(msg || 'Lỗi khi lưu thông tin duyệt.');
        }

        const serverData = res?.data || {};

        // nếu server báo đã duyệt từ trước → xử lý idempotent
        if (serverData?.message && /được duyệt trước/i.test(serverData.message)) {
            message.info(serverData.message);

            const existingSig = serverData?.data;
            if (target) {
                target.status = 'approved';
                if (target.approval) target.approval.status = 'approved';
                target.file_signature = existingSig;
            }

            emits('done', outBlob);
            if (typeof fetchData === 'function') {
                try { await fetchData(); } catch {}
            }

            savingApprove.value = false;
            return;
        }

        // tạo mới thành công
        message.success(serverData?.message || 'Duyệt thành công.');

        if (target) {
            target.status = 'approved';
            if (target.approval) target.approval.status = 'approved';
            target.file_signature = serverData?.data || null;
        }

        emits('done', outBlob);
        if (typeof fetchData === 'function') {
            try { await fetchData(); } catch {}
        }

        // ============================
        // (4) reload UI preview
        // ============================
        try {
            const buf = await fetch(signedBlobUrl.value).then(r => r.arrayBuffer());
            const doc = await pdfjsLib.getDocument({ data: buf }).promise;
            pdfDoc.value = markRaw(doc);
            pageCount.value = doc.numPages;
            queueRender();
        } catch (e) {
            console.warn('Không reload preview:', e);
        }

    } catch (err) {
        console.error(err);
        message.error('Duyệt thất bại.');
    } finally {
        savingApprove.value = false;
    }
}





</script>

<style scoped>
.wrap {
    display: flex;
    gap: 12px;
}

.left {
    flex: 1 1 auto;
}

.right {
    width: 280px;
}

.tools {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-bottom: 8px;
}

.stage {
    position: relative;
    border: 1px solid #eee;
    border-radius: 8px;
    padding: 8px;
    overflow: auto;
    background: #fafafa;
}

canvas {
    display: block;
    max-width: 100%;
    background: #fff;
    border-radius: 4px;
}

.sig {
    position: absolute;
    user-select: none;
    cursor: move;
}

.handle {
    position: absolute;
    width: 16px;
    height: 16px;
    border: 2px solid #1677ff;
    background: #fff;
    border-radius: 4px;
    cursor: nwse-resize;
    box-shadow: 0 1px 2px rgba(0, 0, 0, .12);
}
</style>
