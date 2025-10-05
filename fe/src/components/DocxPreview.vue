<!-- DocxPreview.vue -->
<template><div ref="root" class="docx-preview"></div></template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { renderAsync } from 'docx-preview'

const props = defineProps({ src: { type: String, required: true } })
const root = ref(null)

async function load() {
    const buf = await fetch(props.src).then(r => r.arrayBuffer())
    await renderAsync(buf, root.value, undefined, { className: 'docx' })
}
onMounted(load)
watch(() => props.src, load)
</script>

<style scoped>
/* tùy chỉnh theme docx nếu cần */
.docx-preview :deep(.docx) { background:#fff; padding:16px; }
</style>
