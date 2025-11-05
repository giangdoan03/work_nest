<template>
    <a-modal
        :open="open"
        title="Ký tài liệu"
        width="920px"
        ok-text="Lưu bản đã ký"
        cancel-text="Hủy"
        :confirm-loading="saving"
        :ok-button-props="{ disabled: !isPdfReady || saving }"
        @cancel="$emit('update:open', false)"
        @ok="handleSave"
    >
        <div class="wrap">
            <!-- Bên trái: PDF + công cụ -->
            <div class="left">
                <div class="tools">
                    <a-select v-model:value="pageNum" style="width: 120px">
                        <a-select-option v-for="p in pageCount" :key="p" :value="p">
                            Trang {{ p }}
                        </a-select-option>
                    </a-select>
                    <a-input-number v-model:value="scale" :min="0.5" :max="3" :step="0.1" />
                    <a-button @click="fitWidth">Fit width</a-button>
                    <a-button @click="resetView">Reset</a-button>
                </div>

                <!-- Canvas PDF -->
                <div
                    class="stage"
                    ref="stageRef"
                    @mousemove="onDrag"
                    @mouseup="endDrag"
                    @mouseleave="endDrag"
                >
                    <canvas ref="canvasRef" />
                    <img
                        v-if="signatureUrl"
                        ref="sigRef"
                        class="sig"
                        :src="signatureUrl"
                        :style="sigStyle"
                        draggable="false"
                        @mousedown.stop="startSigDrag"
                        alt=""
                    />
                    <div
                        v-if="signatureUrl"
                        class="handle"
                        :style="handleStyle"
                        @mousedown.stop="startScale"
                    />
                </div>
            </div>

            <!-- Bên phải: điều chỉnh -->
            <div class="right">
                <a-form layout="vertical">
                    <a-form-item label="Kích cỡ chữ ký">
                        <a-slider v-model:value="sigW" :min="60" :max="600" />
                    </a-form-item>
                    <a-form-item label="Độ mờ">
                        <a-slider v-model:value="opacity" :min="40" :max="100" />
                    </a-form-item>
                </a-form>
                <a-alert type="info" show-icon>
                    Nhấp & kéo ảnh chữ ký để di chuyển. Kéo ô vuông góc phải-dưới để thay đổi kích cỡ.
                </a-alert>
            </div>
        </div>
    </a-modal>
</template>

<script setup>
import {
    ref, watch, nextTick, shallowRef, markRaw, computed,
    onBeforeUnmount
} from 'vue'
import { message } from 'ant-design-vue'

// --- pdf.js setup ---
import * as pdfjsLib from 'pdfjs-dist'
import 'pdfjs-dist/build/pdf.worker.min.js'
pdfjsLib.GlobalWorkerOptions.workerSrc = 'pdf.worker.min.js'

// --- pdf-lib dynamic import ---
let PDFLib = null
const loadPdfLib = async () => {
    if (!PDFLib) PDFLib = await import('pdf-lib')
}

// --- props / emits ---
const props = defineProps({
    open: { type: Boolean, default: false },
    pdfUrl: { type: String, default: '' },
    signatureUrl: { type: String, default: '' }
})
const emits = defineEmits(['update:open', 'done'])

// --- state ---
const canvasRef = ref()
const stageRef = ref()
const pdfDoc = shallowRef(null)
const pageNum = ref(1)
const pageCount = ref(1)
const scale = ref(1.2)

const sigRef = ref()
const sigX = ref(40)
const sigY = ref(40)
const sigW = ref(200)
const opacity = ref(100)
const saving = ref(false)
const isPdfReady = ref(false)

// --- render control (chống chồng render) ---
let currentRenderTask = null
let renderQueued = false
let destroyed = false

function handleRatio () {
    try {
        const el = sigRef.value
        if (!el || !el.naturalWidth) return 0.35
        return el.naturalHeight / el.naturalWidth
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

// --- drag/scale signature ---
let draggingSig = false
let scalingSig = false
let dragStart = { x: 0, y: 0 }
let sigStart = { x: 0, y: 0, w: 0 }

function startSigDrag (e) {
    draggingSig = true
    dragStart = { x: e.clientX, y: e.clientY }
    sigStart = { x: sigX.value, y: sigY.value, w: sigW.value }
}
function startScale (e) {
    scalingSig = true
    dragStart = { x: e.clientX, y: e.clientY }
    sigStart = { x: sigX.value, y: sigY.value, w: sigW.value }
}
function onDrag (e) {
    if (draggingSig) {
        const dx = e.clientX - dragStart.x
        const dy = e.clientY - dragStart.y
        sigX.value = Math.max(0, sigStart.x + dx)
        sigY.value = Math.max(0, sigStart.y + dy)
    } else if (scalingSig) {
        const dx = e.clientX - dragStart.x
        sigW.value = Math.max(30, sigStart.w + dx)
    }
}
function endDrag () {
    draggingSig = false
    scalingSig = false
}

// --- render helpers ---
function queueRender () {
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

async function renderPage () {
    if (!pdfDoc.value || !canvasRef.value || destroyed) return

    // Hủy render cũ nếu còn
    if (currentRenderTask) {
        try { currentRenderTask.cancel() } catch {}
        currentRenderTask = null
    }

    const page = await pdfDoc.value.getPage(pageNum.value)

    // HIỂN THỊ ĐÚNG CHIỀU: bỏ rotation metadata khi render viewer
    const viewport = page.getViewport({ scale: scale.value, rotation: 0 })

    const canvas = canvasRef.value
    const ctx = canvas.getContext('2d')
    canvas.width = viewport.width
    canvas.height = viewport.height
    ctx.clearRect(0, 0, canvas.width, canvas.height)

    const task = page.render({ canvasContext: ctx, viewport })
    currentRenderTask = task
    try {
        await task.promise
    } catch (e) {
        // cancel thì pdf.js ném RenderingCancelledException -> bỏ qua
        if (e?.name !== 'RenderingCancelledException') throw e
    } finally {
        if (currentRenderTask === task) currentRenderTask = null
    }
}

// --- IO ---
async function loadPdf () {
    if (!props.pdfUrl) return
    isPdfReady.value = false
    try {
        const res = await fetch(props.pdfUrl)
        const buffer = await res.arrayBuffer()
        const task = pdfjsLib.getDocument({ data: buffer })
        const doc = await task.promise
        pdfDoc.value = markRaw(doc)
        pageCount.value = doc.numPages
        pageNum.value = 1
        queueRender()
        console.log('✅ PDF load qua fetch thành công')
    } catch (err) {
        console.error('❌ loadPdf lỗi:', err)
        message.error('Không tải được tài liệu PDF.')
    }
}

function fitWidth () {
    const box = stageRef.value?.getBoundingClientRect()
    if (!box || !pdfDoc.value) return
    pdfDoc.value.getPage(pageNum.value).then((p) => {
        // viewport hiển thị cũng bỏ rotation
        const vp = p.getViewport({ scale: 1, rotation: 0 })
        scale.value = Math.max(0.5, Math.min(3, (box.width - 24) / vp.width))
        // watcher sẽ queueRender()
    })
}
function resetView () {
    scale.value = 1.2
    sigX.value = 40
    sigY.value = 40
    sigW.value = 200
    // watcher sẽ queueRender()
}

// --- lifecycle ---
watch(() => props.open, async (v) => {
    if (v) {
        destroyed = false
        isPdfReady.value = false
        await nextTick()
        await loadPdfLib()
        await loadPdf()
    } else {
        destroyed = true
        if (currentRenderTask) { try { currentRenderTask.cancel() } catch {} currentRenderTask = null }
        pdfDoc.value = null
    }
}, { immediate: true })

watch([pageNum, scale], () => {
    if (pdfDoc.value) queueRender()
})

onBeforeUnmount(() => {
    destroyed = true
    if (currentRenderTask) { try { currentRenderTask.cancel() } catch {} currentRenderTask = null }
})

// --- save ---
async function handleSave () {
    if (!props.pdfUrl) return message.warning('Không có file PDF để ký.')
    if (!props.signatureUrl) return message.warning('Chưa có ảnh chữ ký.')
    if (!pdfDoc.value) return message.warning('Vui lòng chờ PDF tải xong.')
    if (!PDFLib) await loadPdfLib()

    saving.value = true
    try {
        // tải dữ liệu pdf + ảnh chữ ký
        const [pdfRes, sigRes] = await Promise.all([
            fetch(props.pdfUrl),
            fetch(props.signatureUrl)
        ])
        if (!pdfRes.ok || !sigRes.ok) throw new Error('Không tải được file hoặc ảnh')
        const pdfBytes = await pdfRes.arrayBuffer()
        const imgBytes = await sigRes.arrayBuffer()

        const { PDFDocument } = PDFLib
        const pdfDocW = await PDFDocument.load(pdfBytes, { updateMetadata: false })
        const page = pdfDocW.getPage(pageNum.value - 1)

        let img
        try { img = await pdfDocW.embedPng(imgBytes) } catch { img = await pdfDocW.embedJpg(imgBytes) }

        // Lấy trang gốc từ pdf.js để biết rotation metadata
        const rawPage = await pdfDoc.value.getPage(pageNum.value)
        const pageRotate = (rawPage.rotate || 0) % 360

        // viewport dùng cho tính toán TỪ canvas (đang hiển thị rotation:0)
        const vpCanvas = rawPage.getViewport({ scale: 1, rotation: 0 })
        const pdfW = page.getWidth()
        const pdfH = page.getHeight()
        // tỉ lệ từ canvas -> pdf user space
        const scaleX = pdfW / vpCanvas.width
        const scaleY = pdfH / vpCanvas.height

        const sigCanvasW = sigW.value
        const sigCanvasH = sigW.value * handleRatio()

        // Canvas: (0,0) là top-left; PDF: (0,0) là bottom-left
        // Tính theo không xoay (rotation:0 hiển thị)
        let xPdf = sigX.value * scaleX
        let yPdf = (vpCanvas.height - (sigY.value + sigCanvasH)) * scaleY
        const wPdf = sigCanvasW * scaleX
        const hPdf = sigCanvasH * scaleY

        // Nếu trang PDF có metadata Rotate (90/180/270), cần quy đổi vị trí
        // để khi viewer áp dụng rotation, chữ ký vẫn nằm đúng chỗ.
        switch (pageRotate) {
            case 0:
                // giữ nguyên
                break
            case 180:
                // gương qua tâm trang
                xPdf = pdfW - xPdf - wPdf
                yPdf = pdfH - yPdf - hPdf
                break
            case 90:
                // quay 90° CW: (x,y,w,h) -> (y, pdfW - (x + w), h, w), rồi xoay ảnh 90°
                // Để đơn giản giữ ảnh không xoay thêm, chỉ quy đổi vị trí theo trang
                // (đủ chính xác cho đa số mẫu; nếu cần tuyệt đối khớp, dùng rotate: degrees(90))
            {
                const nx = yPdf
                const ny = pdfW - (xPdf + wPdf)
                xPdf = nx
                yPdf = ny
                // nếu muốn xoay nội dung ảnh theo trang:
                // page.drawImage(img, { x: xPdf, y: yPdf, width: hPdf, height: wPdf, rotate: PDFLib.degrees(90) })
                // return;
            }
                break
            case 270:
            {
                const nx = pdfH - (yPdf + hPdf)
                const ny = xPdf
                xPdf = nx
                yPdf = ny
                // có thể xoay ảnh 270° tương tự chú thích ở case 90
            }
                break
        }

        page.drawImage(img, {
            x: xPdf,
            y: yPdf,
            width: wPdf,
            height: hPdf,
            opacity: opacity.value / 100
        })

        const out = await pdfDocW.save({ useObjectStreams: false })
        emits('done', new Blob([out], { type: 'application/pdf' }))
        emits('update:open', false)
    } catch (e) {
        console.error(e)
        message.error('Ký thất bại.')
    } finally {
        saving.value = false
    }
}
</script>

<style scoped>
.wrap {
    display: flex;
    gap: 12px;
}
.left { flex: 1 1 auto; }
.right { width: 280px; }
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
    background: white;
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
    box-shadow: 0 1px 2px rgba(0,0,0,0.12);
}
</style>
