<!-- PreviewIframe.vue -->
<template>
    <iframe :src="viewerUrl" class="w-full h-[540px] border-0" />
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({ url: { type: String, required: true } })

const encoded = computed(() => encodeURIComponent(props.url))
const ext = computed(() => (props.url.match(/\.([a-z0-9]+)(\?|#|$)/i)?.[1] || '').toLowerCase())

const viewerUrl = computed(() => {
    if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(ext.value)) {
        return `https://view.officeapps.live.com/op/view.aspx?src=${encoded.value}`
    }
    if (ext.value === 'pdf') {
        return `https://docs.google.com/gview?embedded=1&url=${encoded.value}`
    }
    // fallback
    return props.url
})
</script>
