<template>
    <div class="wrap">
        <h2>PDF Auto Sign — Ký vào mọi “HCNS” (có OCR)</h2>

        <!-- Hàng 1: file + paging -->
        <div class="row">
            <label class="btn">
                <input ref="pdfInput" type="file" accept="application/pdf" />
                <span>📄 Chọn PDF…</span>
            </label>

            <label class="btn" title="PNG/JPG, có thể chọn nhiều; nên PNG nền trong suốt">
                <input ref="imgInput" type="file" accept="image/*" multiple />
                <span>🖼️ Chọn ảnh chữ ký (nhiều)</span>
            </label>

            <span class="pill">Trang: {{ currentPage }} / {{ pageCount || '—' }}</span>
            <button @click="prevPage" :disabled="!pdfDoc || currentPage<=1">Prev</button>
            <button @click="nextPage" :disabled="!pdfDoc || currentPage>=pageCount">Next</button>
        </div>

        <!-- Hàng 2: tools -->
        <div class="row">
            <div class="tools" style="gap:12px">
                <label class="radio" title="Nhập nhiều marker, cách nhau dấu phẩy. VD: chuky1, chuky2, chuky3">
                    <span>📍 Marker(s)</span>
                    <input v-model="markerText" type="text" style="width:260px; margin-left:8px" />
                </label>

                <label class="radio" title="Rộng ảnh ký theo % bề ngang trang">
                    <span>W%</span>
                    <input v-model.number="markerWpct" type="number" min="5" max="80" style="width:70px; margin-left:8px" />
                </label>

                <label class="radio" title="Che chữ marker bằng nền trắng">
                    <input v-model="coverMarker" type="checkbox" /> Che marker
                </label>
                <label class="radio" title="Không phân biệt hoa/thường">
                    <input v-model="optCaseInsensitive" type="checkbox" /> i
                </label>
                <label class="radio" title="Khớp nguyên từ (bỏ chọn để 'chứa chuỗi')">
                    <input v-model="optWholeWord" type="checkbox" /> whole word
                </label>

                <label class="radio" title="Dùng OCR khi không thấy text gốc hoặc ép dùng OCR">
                    <input v-model="forceOCR" type="checkbox" /> Dùng OCR fallback
                </label>
                <label class="radio" title="Tỷ lệ render cho OCR (cao hơn = chính xác hơn nhưng chậm hơn)">
                    OCR scale
                    <input v-model.number="ocrScale" type="number" min="1" max="3" style="width:60px; margin-left:8px" />
                </label>
                <label class="radio" title="Ngôn ngữ OCR (eng/vie hoặc 'eng+vie')">
                    Lang
                    <input v-model="ocrLang" type="text" class="mono" style="width:90px; margin-left:8px" />
                </label>

                <label class="radio" title="Bù dọc theo % chiều cao ảnh (âm = đẩy lên)">
                    Y off %
                    <input v-model.number="yOffsetPct" type="number" min="-100" max="100" style="width:70px; margin-left:8px" />
                </label>

                <label class="radio" title="Đặt tâm ảnh trùng tâm marker; không dịch để tránh lệch">
                    <input v-model="centerOnMarker" type="checkbox" /> Giữ tâm vào marker
                </label>

                <button class="primary" @click="autoSign" :disabled="!pdfDoc">⚡ Auto ký toàn tài liệu</button>
                <button @click="probeMarkers" :disabled="!pdfDoc">🔎 Test tìm (trang hiện tại)</button>
            </div>
        </div>

        <!-- Hàng 3: zoom + export -->
        <div class="row">
            <label class="radio">🔍 Zoom
                <input
                    type="range"
                    min="50"
                    max="200"
                    v-model.number="currentZoom"
                    style="width:180px; margin-left:8px"
                    @input="renderPage"
                />
            </label>
            <button @click="fit">Fit width</button>
            <span class="hint">{{ currentZoom }}%</span>
            <button class="primary" :disabled="!pdfBytesOriginal" @click="exportPdf">Tải PDF đã ký</button>
        </div>

        <div class="hint">
            Quy trình: Chọn PDF ➜ Chọn <b>nhiều</b> ảnh chữ ký (nếu cần) ➜ Nhập marker cách nhau dấu phẩy
            (vd: <code>chuky1, chuky2, chuky3</code>) ➜ bấm <b>⚡ Auto ký</b>. Nếu file là scan, bật OCR.
        </div>

        <!-- Canvas + sidebar -->
        <div class="canvasWrap">
            <div><canvas ref="canvasEl"></canvas></div>

            <div class="right">
                <div class="card">
                    <strong>Mục đã thêm</strong>
                    <div class="list">
                        <div v-for="(a,idx) in annotations" :key="idx" class="listItem">
                            <span class="badge">#{{ idx+1 }}</span>
                            <span>{{ a.type==='image' ? '🖼️' : '▭' }} p{{ a.pageIndex }} (x:{{ r(a.pdfX) }}, y:{{ r(a.pdfY) }}, {{ r(a.pdfW) }}x{{ r(a.pdfH) }})</span>
                        </div>
                    </div>
                </div>
                <div class="card">
                    <strong>Thông tin</strong>
                    <div class="hint">{{ info }}</div>
                </div>
            </div>
        </div>

        <div class="footer">
            <span class="hint">⚠️ Script chỉ chèn overlay (rect/ảnh). Không chỉnh sửa text gốc PDF.</span>
            <a class="link" href="#" @click.prevent="loadSample">Dùng thử với sample PDF</a>
        </div>
    </div>
</template>

<script setup>
import { ref, shallowRef, markRaw, computed, onMounted, onBeforeUnmount } from 'vue'



// pdf.js (ESM) + worker qua Vite
import * as pdfjsLib from 'pdfjs-dist/legacy/build/pdf'
import pdfWorker from 'pdfjs-dist/legacy/build/pdf.worker.min.js?url'
pdfjsLib.GlobalWorkerOptions.workerSrc = pdfWorker

// pdf-lib (ESM)
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib'

// tesseract.js (ESM)
import Tesseract from 'tesseract.js'
const TESSDATA_URL = 'https://tessdata.projectnaptha.com/4.0.0'

// Refs / state
const canvasEl = ref(null)
const pdfInput = ref(null)
const imgInput = ref(null)

const info = ref('Chưa có PDF.')
const pdfDoc = shallowRef(null)
const pdfBytesOriginal = ref(null)
const currentPage = ref(1)
const pageCount = ref(0)

const basePdfW = ref(0)
const basePdfH = ref(0)
const bufferScale = ref(1)
const currentZoom = ref(100)

const MAX_CSS_WIDTH = 900
const pageSizeCache = ref(new Map())

const annotations = ref([])
const signatureBank = ref([])

// UI options
const markerText = ref('chuky1, chuky2, chuky3')
const markerWpct = ref(25)
const coverMarker = ref(true)
const optCaseInsensitive = ref(true)
const optWholeWord = ref(true)
const forceOCR = ref(false)
const ocrScale = ref(2)
const ocrLang = ref('eng')
const yOffsetPct = ref(-18)
const centerOnMarker = ref(true)

// helpers
const ctx = computed(() => canvasEl.value?.getContext('2d') || null)
const showInfo = (msg) => (info.value = msg)
const r = (n) => Math.round(Number(n) || 0)

// Fit
function fit() {
    currentZoom.value = 100
    renderPage()
}

async function getBasePageSize(pageIndex) {
    if (pageSizeCache.value.has(pageIndex)) return pageSizeCache.value.get(pageIndex)
    const page = await pdfDoc.value.getPage(pageIndex)
    const vp = page.getViewport({ scale: 1 })
    const sz = { w: vp.width, h: vp.height }
    pageSizeCache.value.set(pageIndex, sz)
    return sz
}

// Load PDF
async function loadPdfFromBytes(bytes) {
    const loadingTask = pdfjsLib.getDocument({ data: bytes })
    const doc = await loadingTask.promise
    pdfDoc.value = markRaw(doc)
    currentPage.value = 1
    pageCount.value = pdfDoc.value.numPages
    pageSizeCache.value.clear()
    currentZoom.value = 100
    await renderPage()
    showInfo(`Trang: ${pdfDoc.value.numPages}. Chọn ảnh chữ ký rồi bấm ⚡ Auto ký.`)
}

async function onPickPdf(e) {
    const file = e.target.files?.[0]
    if (!file) return
    const ab = await file.arrayBuffer()
    const bytes = new Uint8Array(ab)
    pdfBytesOriginal.value = bytes.slice()
    annotations.value = []
    await loadPdfFromBytes(bytes.slice())
}

async function onPickImages(e) {
    const files = Array.from(e.target.files || [])
    signatureBank.value = []
    for (const f of files) {
        if (!f.type.startsWith('image/')) continue
        const src = URL.createObjectURL(f)
        const dims = await new Promise((res) => {
            const img = new Image()
            img.onload = () => res({ w: img.naturalWidth, h: img.naturalHeight })
            img.src = src
        })
        signatureBank.value.push({ src, naturalWidth: dims.w, naturalHeight: dims.h, name: f.name.replace(/\.[^.]+$/, '') })
    }
    if (!signatureBank.value.length) showInfo('Không có ảnh hợp lệ.')
    else showInfo(signatureBank.value.length > 1 ? `Đã chọn ${signatureBank.value.length} ảnh chữ ký.` : `Đã chọn 1 ảnh chữ ký.`)
}

// Render page + overlays
async function renderPage() {
    if (!pdfDoc.value) return
    if (!canvasEl.value) return
    const _ctx = ctx.value
    if (!_ctx) { console.warn('Canvas context chưa sẵn sàng'); return }
    const page = await pdfDoc.value.getPage(currentPage.value)
    const baseViewport = page.getViewport({ scale: 1 })
    basePdfW.value = baseViewport.width
    basePdfH.value = baseViewport.height

    const containerWidth = canvasEl.value.parentElement.getBoundingClientRect().width || MAX_CSS_WIDTH
    const targetCssWidthFit = Math.min(containerWidth, MAX_CSS_WIDTH)
    const cssScale = (targetCssWidthFit * (currentZoom.value / 100)) / baseViewport.width
    const dpr = window.devicePixelRatio || 1
    bufferScale.value = cssScale * dpr

    const viewport = page.getViewport({ scale: bufferScale.value })
    canvasEl.value.width = Math.floor(viewport.width)
    canvasEl.value.height = Math.floor(viewport.height)
    canvasEl.value.style.width = `${Math.round(baseViewport.width * cssScale)}px`
    canvasEl.value.style.height = `${Math.round(baseViewport.height * cssScale)}px`

    await page.render({ canvasContext: _ctx, viewport }).promise

    // rect overlays
    for (const a of annotations.value.filter(x => x.pageIndex === currentPage.value && x.type === 'rect')) {
        const xBuf = a.pdfX * bufferScale.value
        const yBuf = (basePdfH.value - a.pdfY) * bufferScale.value
        ctx.value.save()
        ctx.value.fillStyle = 'white'
        ctx.value.fillRect(xBuf, yBuf - a.pdfH * bufferScale.value, a.pdfW * bufferScale.value, a.pdfH * bufferScale.value)
        ctx.value.restore()
    }
    // image overlays
    for (const a of annotations.value.filter(x => x.pageIndex === currentPage.value && x.type === 'image')) {
        const xBuf = a.pdfX * bufferScale.value
        const yBuf = (basePdfH.value - a.pdfY) * bufferScale.value
        await new Promise((res) => {
            const img = new Image()
            img.onload = () => {
                ctx.value.drawImage(img, xBuf, yBuf - a.pdfH * bufferScale.value, a.pdfW * bufferScale.value, a.pdfH * bufferScale.value)
                res()
            }
            img.src = a.src
        })
    }
}

async function prevPage() {
    if (!pdfDoc.value) return
    currentPage.value = Math.max(1, currentPage.value - 1)
    await renderPage()
}
async function nextPage() {
    if (!pdfDoc.value) return
    currentPage.value = Math.min(pdfDoc.value.numPages, currentPage.value + 1)
    await renderPage()
}

// Regex + find markers
function buildRegex(query, opts = { caseInsensitive: true, wholeWord: true }) {
    const caseInsensitive = opts.caseInsensitive !== false
    const wholeWord = opts.wholeWord !== false
    const esc = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    const flags = (caseInsensitive ? 'iu' : 'u')
    if (wholeWord) {
        try { return new RegExp(`(?<![\\p{L}\\p{N}_])${esc}(?![\\p{L}\\p{N}_])`, flags) }
        catch { return new RegExp(`\\b${esc}\\b`, caseInsensitive ? 'i' : '') }
    } else {
        return new RegExp(esc, caseInsensitive ? 'i' : '')
    }
}

async function findMarkersOnDoc_TEXT(query = 'HCNS', opts = { caseInsensitive: true, wholeWord: true }) {
    const re = buildRegex(query, opts)
    const hits = []
    const total = pdfDoc.value.numPages
    const Y_TOL = 2.5, GAP_RATIO = 0.35

    for (let pageIndex = 1; pageIndex <= total; pageIndex++) {
        const page = await pdfDoc.value.getPage(pageIndex)
        const textContent = await page.getTextContent()
        const items = textContent.items || []
        const spans = items.map(it => {
            const [a,b,c,d,e,f] = it.transform || [1,0,0,1,0,0]
            const w = it.width || (it.str?.length || 1) * (Math.abs(a) || 8) || 40
            const h = Math.abs(d) || 12
            return { str: it.str || '', x: e, y: f, w, h }
        }).filter(s => s.str)

        spans.sort((p,q) => q.y - p.y || p.x - q.x)
        const lines = []
        for (const s of spans) {
            const line = lines.find(L => Math.abs(L.y - s.y) <= Y_TOL)
            if (!line) lines.push({ y: s.y, items: [s] }); else line.items.push(s)
        }

        for (const line of lines) {
            line.items.sort((p,q) => p.x - q.x)
            let text = ''; const segs = []; let cursor = 0
            for (let i=0;i<line.items.length;i++) {
                const it = line.items[i], prev = line.items[i-1]
                if (i>0) {
                    const gap = it.x - (prev.x + prev.w)
                    const avgH = (it.h + prev.h) / 2
                    if (gap > avgH * GAP_RATIO) { text += ' '; cursor += 1 }
                }
                const start = cursor; text += it.str; cursor += it.str.length
                segs.push({ start, end: cursor, x: it.x, y: it.y, w: it.w, h: it.h })
            }
            if (!text) continue

            const reG = new RegExp(re.source, re.flags.includes('g') ? re.flags : (re.flags + 'g'))
            let mm
            while ((mm = reG.exec(text)) !== null) {
                const sIdx = mm.index, eIdx = sIdx + mm[0].length
                const take = segs.filter(seg => !(seg.end <= sIdx || seg.start >= eIdx))
                if (!take.length) continue
                let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity
                for (const g of take) {
                    minX = Math.min(minX, g.x); maxX = Math.max(maxX, g.x + g.w)
                    minY = Math.min(minY, g.y - g.h); maxY = Math.max(maxY, g.y)
                }
                const bboxW = Math.max(1, maxX - minX), bboxH = Math.max(1, maxY - minY)
                const cx = minX + bboxW / 2, cy = minY + bboxH / 2
                hits.push({ pageIndex, pdfX: cx, pdfY: cy, approxW: bboxW, approxH: bboxH })
            }
        }
    }
    return hits
}

async function ocrRecognizePageToHits(pageIndex, query, opts, scale=2, lang='eng') {
    const page = await pdfDoc.value.getPage(pageIndex)
    const vpBase = page.getViewport({ scale: 1 })
    const vp = page.getViewport({ scale })
    const off = document.createElement('canvas')
    off.width = Math.floor(vp.width); off.height = Math.floor(vp.height)
    const offCtx = off.getContext('2d')
    await page.render({ canvasContext: offCtx, viewport: vp }).promise

    const res = await Tesseract.recognize(off, lang, {
        langPath: TESSDATA_URL,
        logger: () => {}, tessedit_pageseg_mode: 6
    })

    const re = buildRegex(query, opts)
    const hits = []
    const words = res?.data?.words || []
    for (const w of words) {
        const text = (w.text || '').trim()
        if (!text) continue
        if (!re.test(text)) continue
        const { x0, y0, x1, y1 } = w.bbox || {}
        if ([x0,y0,x1,y1].some(v => typeof v !== 'number')) continue
        const pdfH = vpBase.height
        const cx_px = (x0 + x1) / 2, cy_px = (y0 + y1) / 2
        const bw_px = x1 - x0, bh_px = y1 - y0
        const pdfX = cx_px / scale, pdfY = pdfH - cy_px / scale
        const approxW = bw_px / scale, approxH = bh_px / scale
        hits.push({ pageIndex, pdfX, pdfY, approxW, approxH })
    }
    return hits
}

async function findMarkersOnDoc_OCR(query='HCNS', opts, scale=2, lang='eng') {
    const total = pdfDoc.value.numPages, all = []
    for (let pageIndex=1; pageIndex<=total; pageIndex++) {
        const pageHits = await ocrRecognizePageToHits(pageIndex, query, opts, Math.max(1, Math.min(3, scale)), lang)
        all.push(...pageHits)
    }
    return all
}

// Actions
async function autoSign() {
    if (!pdfDoc.value) return showInfo('Chưa có PDF.')
    if (!signatureBank.value.length) return showInfo('Hãy chọn ít nhất một ảnh chữ ký (nút 🖼️).')

    const markers = (markerText.value || '').split(',').map(s => s.trim()).filter(Boolean)
    if (!markers.length) return showInfo('Nhập ít nhất một marker, cách nhau bằng dấu phẩy.')

    const opts = { caseInsensitive: optCaseInsensitive.value, wholeWord: optWholeWord.value }
    const allHits = []

    for (let i = 0; i < markers.length; i++) {
        const query = markers[i]
        let hits = await findMarkersOnDoc_TEXT(query, opts)
        if (forceOCR.value || !hits.length) {
            const ocrHits = await findMarkersOnDoc_OCR(query, opts, ocrScale.value, ocrLang.value.trim() || 'eng')
            const key = (h) => `${h.pageIndex}:${r(h.pdfX)}:${r(h.pdfY)}`
            const seen = new Set(hits.map(key))
            for (const h of ocrHits) if (!seen.has(key(h))) hits.push(h)
        }
        for (const h of hits) { h._markerIndex = i; h._markerText = query; allHits.push(h) }
    }
    if (!allHits.length) return showInfo(`Không thấy marker nào (${markers.join(', ')}).`)

    const newAnn = []
    let skipped = 0

    for (const h of allHits) {
        const sig = signatureBank.value[h._markerIndex]
        if (!sig) { skipped++; continue }

        const { w: pageW, h: pageH } = await getBasePageSize(h.pageIndex)
        const wpct = Math.max(5, Math.min(80, Number(markerWpct.value || 25)))
        const targetPdfW = pageW * (wpct / 100)
        const scale = targetPdfW / sig.naturalWidth
        const finalW = targetPdfW
        const finalH = sig.naturalHeight * scale

        const yOff = (Number(yOffsetPct.value || 0) / 100) * finalH

        if (coverMarker.value) {
            const pad = 4
            const rectW = Math.max(h.approxW + pad * 2, finalW * 0.4)
            const rectH = Math.max(h.approxH + pad * 2, finalH * 0.4)
            let coverX = h.pdfX - rectW / 2, coverY = (h.pdfY + yOff) - rectH / 2
            if (!centerOnMarker.value) {
                coverX = Math.max(0, Math.min(coverX, pageW - rectW))
                coverY = Math.max(0, Math.min(coverY, pageH - rectH))
            }
            newAnn.push({ type:'rect', pageIndex: h.pageIndex, pdfX: coverX, pdfY: coverY, pdfW: rectW, pdfH: rectH })
        }

        let pdfXPlace = h.pdfX - finalW / 2
        let pdfYPlace = (h.pdfY + yOff) - finalH / 2
        if (!centerOnMarker.value) {
            pdfXPlace = Math.max(0, Math.min(pdfXPlace, pageW - finalW))
            pdfYPlace = Math.max(0, Math.min(pdfYPlace, pageH - finalH))
        }
        newAnn.push({ type:'image', pageIndex: h.pageIndex, pdfX: pdfXPlace, pdfY: pdfYPlace, pdfW: finalW, pdfH: finalH, src: sig.src })
    }

    annotations.value.push(...newAnn)
    await renderPage()
    const placed = newAnn.filter(a => a.type === 'image').length
    showInfo(skipped>0 ? `Đã ký ${placed} vị trí. Bỏ qua ${skipped} hit vì thiếu ảnh tương ứng marker.` : `Đã ký ${placed} vị trí (tất cả marker đều có ảnh).`)
}

async function probeMarkers() {
    if (!pdfDoc.value) return showInfo('Chưa có PDF.')
    const markers = (markerText.value || '').split(',').map(s => s.trim()).filter(Boolean)
    if (!markers.length) return showInfo('Nhập ít nhất một marker, cách nhau dấu phẩy.')
    const opts = { caseInsensitive: optCaseInsensitive.value, wholeWord: optWholeWord.value }
    let hits = []
    for (const query of markers) {
        let h1 = await findMarkersOnDoc_TEXT(query, opts)
        if (forceOCR.value || !h1.length) {
            const oHits = await findMarkersOnDoc_OCR(query, opts, ocrScale.value, ocrLang.value.trim() || 'eng')
            const key = (h) => `${h.pageIndex}:${r(h.pdfX)}:${r(h.pdfY)}`
            const seen = new Set(h1.map(key))
            for (const hh of oHits) if (!seen.has(key(hh))) h1.push(hh)
        }
        hits.push(...h1)
    }
    await renderPage()
    const pageHits = hits.filter(h => h.pageIndex === currentPage.value)
    if (!pageHits.length) return showInfo(`Trang ${currentPage.value}: không thấy marker nào trong (${markers.join(', ')}).`)
    for (const h of pageHits) drawMarkerDebugBox(h.pdfX, h.pdfY, h.approxW, h.approxH)
    showInfo(`Trang ${currentPage.value}: ${pageHits.length} hit (${markers.join(', ')}) — đã highlight.`)
}

function drawMarkerDebugBox(pdfX, pdfY, pdfW=40, pdfH=16) {
    const xBuf = pdfX * bufferScale.value
    const yBuf = (basePdfH.value - pdfY) * bufferScale.value
    ctx.value.save()
    ctx.value.setLineDash([6,4])
    ctx.value.lineWidth = Math.max(1, 1 * (window.devicePixelRatio || 1))
    ctx.value.strokeStyle = 'rgba(239,68,68,0.95)'
    ctx.value.strokeRect(xBuf - (pdfW/2)*bufferScale.value, yBuf - (pdfH/2)*bufferScale.value, pdfW*bufferScale.value, pdfH*bufferScale.value)
    ctx.value.beginPath()
    ctx.value.moveTo(xBuf - 12, yBuf); ctx.value.lineTo(xBuf + 12, yBuf)
    ctx.value.moveTo(xBuf, yBuf - 12); ctx.value.lineTo(xBuf, yBuf + 12)
    ctx.value.stroke()
    ctx.value.restore()
}

// Export PDF
async function exportPdf() {
    if (!pdfBytesOriginal.value) return
    const pdfDocOut = await PDFDocument.load(pdfBytesOriginal.value)
    await pdfDocOut.embedFont(StandardFonts.Helvetica)

    function mapAnnoToPdfLib(page, pageIndex, a) {
        const media = page.getMediaBox()
        const crop = page.getCropBox ? page.getCropBox() : media

        const libW = crop.width, libH = crop.height
        const jsSize = pageSizeCache.value.get(pageIndex) || { w: libW, h: libH }
        const sx = libW / jsSize.w, sy = libH / jsSize.h

        const w = a.pdfW * sx, h = a.pdfH * sy
        const x_inCropBL = a.pdfX * sx, y_inCropBL = a.pdfY * sy

        const dx = (crop.x ?? 0) - (media.x ?? 0)
        const dy = (crop.y ?? 0) - (media.y ?? 0)

        return { x: dx + x_inCropBL, y: dy + y_inCropBL, w, h }
    }

    for (const a of annotations.value) {
        const page = pdfDocOut.getPage((a.pageIndex || 1) - 1)
        const m = mapAnnoToPdfLib(page, a.pageIndex, a)
        if (a.type === 'rect') {
            page.drawRectangle({ x: m.x, y: m.y, width: m.w, height: m.h, color: rgb(1,1,1) })
        } else if (a.type === 'image') {
            const bytes = await fetch(a.src).then(r => r.arrayBuffer())
            let imgEmbed
            try { imgEmbed = await pdfDocOut.embedPng(bytes) } catch { imgEmbed = await pdfDocOut.embedJpg(bytes) }
            page.drawImage(imgEmbed, { x: m.x, y: m.y, width: m.w, height: m.h })
        }
    }

    const outBytes = await pdfDocOut.save()
    const blob = new Blob([outBytes], { type: 'application/pdf' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a'); a.href = url; a.download = 'signed.pdf'; a.click()
    URL.revokeObjectURL(url)
}

// Sample
async function loadSample() {
    const ab = await fetch('https://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf').then(r => r.arrayBuffer())
    const bytes = new Uint8Array(ab)
    pdfBytesOriginal.value = bytes.slice()
    annotations.value = []
    await loadPdfFromBytes(bytes.slice())
}

// lifecycle
const onResize = () => { if (pdfDoc.value) renderPage() }

onMounted(() => {
    // KHÔNG set workerSrc ở đây nữa — index.html đã cấu hình Blob worker
    pdfInput.value?.addEventListener('change', onPickPdf)
    imgInput.value?.addEventListener('change', onPickImages)
    window.addEventListener('resize', onResize)
})

onBeforeUnmount(() => {
    pdfInput.value?.removeEventListener('change', onPickPdf)
    imgInput.value?.removeEventListener('change', onPickImages)
    window.removeEventListener('resize', onResize)
})
</script>

<style scoped>
:root { --bg:#0f172a; --muted:#1e293b; --ink:#e2e8f0; --accent:#22d3ee; --line:#334155; }
.wrap { max-width:1100px; margin:0 auto; padding:16px; color:var(--ink); font:14px/1.45 ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Arial; }
.row { display:flex; gap:12px; flex-wrap:wrap; align-items:center; margin-bottom:8px; }
.btn { display:inline-flex; align-items:center; gap:8px; padding:8px 10px; border:1px dashed var(--line); border-radius:10px; cursor:pointer; background:var(--muted); }
.btn input[type=file]{display:none}
button { appearance:none; border:1px solid var(--line); background:#0b1220; color:#e2e8f0; padding:8px 12px; border-radius:10px; cursor:pointer; }
button.primary{border-color:transparent; background:linear-gradient(90deg,#06b6d4,#22d3ee); color:#0b1220; font-weight:700;}
button:disabled{opacity:.5; cursor:not-allowed;}
.tools input[type="text"], .tools input[type="number"], .tools select { background:#0b1220; color:#e2e8f0; border:1px solid var(--line); border-radius:8px; padding:8px; }
.radio { display:inline-flex; gap:6px; align-items:center; padding:6px 10px; border:1px solid var(--line); border-radius:10px; }
.canvasWrap { display:grid; grid-template-columns:1fr 320px; gap:12px; margin:16px 0; }
.right { display:flex; flex-direction:column; gap:12px; }
.card { background:var(--muted); border:1px solid var(--line); border-radius:14px; padding:12px; }
.hint { opacity:.8; font-size:12px; }
canvas { width:100%; height:auto; max-width:900px; background:white; border-radius:8px; border:1px solid var(--line); }
.list { max-height:360px; overflow:auto; border:1px solid var(--line); border-radius:10px; }
.listItem { display:flex; justify-content:space-between; gap:8px; padding:8px; border-bottom:1px dashed var(--line); }
.badge { font-size:12px; padding:2px 6px; border-radius:6px; background:#0b1220; border:1px solid var(--line); }
.pill { padding:4px 8px; border:1px solid var(--line); border-radius:999px; }
.mono { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
</style>
