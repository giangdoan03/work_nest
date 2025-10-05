<!-- PdfPreview.vue -->
<template><canvas ref="cv" class="max-w-full"></canvas></template>

<script setup>
import * as pdfjsLib from 'pdfjs-dist'
import pdfjsWorker from 'pdfjs-dist/build/pdf.worker.mjs?url'
import { onMounted, ref, watch } from 'vue'

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfjsWorker
const props = defineProps({ src: { type: String, required: true }, page: { type: Number, default: 1 } })
const cv = ref(null)

async function render() {
    const pdf = await pdfjsLib.getDocument(props.src).promise
    const pg = await pdf.getPage(props.page)
    const viewport = pg.getViewport({ scale: 1.2 })
    const canvas = cv.value
    const ctx = canvas.getContext('2d')
    canvas.width = viewport.width
    canvas.height = viewport.height
    await pg.render({ canvasContext: ctx, viewport }).promise
}
onMounted(render)
watch(() => [props.src, props.page], render)
</script>
