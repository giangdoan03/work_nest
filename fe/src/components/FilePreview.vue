<template>
    <div class="file-preview">
        <!-- PDF -->
        <iframe v-if="isPDF" :src="url" class="preview-frame" />

        <!-- Ảnh -->
        <img v-else-if="isImage" :src="url" class="preview-img" />

        <!-- DOCX render nội bộ; nếu fail -> office viewer -->
        <div v-else-if="isDocx && !forceOfficeViewer" ref="docxContainer" class="docx-view"></div>

        <!-- Excel nội bộ (tuỳ chọn); có thể bỏ nếu chỉ muốn Office Viewer -->
        <div v-else-if="isExcel && !forceOfficeViewer" ref="excelContainer" class="excel-view"></div>

        <!-- Office Web Viewer: .doc, .ppt, .xls… hoặc fallback -->
        <iframe v-else-if="useOfficeViewer" :src="officeEmbedUrl" class="preview-frame" />

        <!-- Cuối cùng: không hỗ trợ -->
        <div v-else class="preview-empty">Không hỗ trợ xem trước định dạng này.</div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { renderAsync } from 'docx-preview'
import Spreadsheet from "x-data-spreadsheet";
// Nếu dùng x-data-spreadsheet thì giữ import; không dùng có thể xoá
// import Spreadsheet from 'x-data-spreadsheet'

const props = defineProps({ url: { type: String, required: true } })

const docxContainer = ref(null)
const excelContainer = ref(null)
const forceOfficeViewer = ref(false)  // bật khi render nội bộ fail

const ext = computed(() => (props.url.split('?')[0].split('#')[0].split('.').pop() || '').toLowerCase())
const isPDF   = computed(() => ext.value === 'pdf')
const isImage = computed(() => ['png','jpg','jpeg','gif','webp','bmp','svg'].includes(ext.value))
const isDocx  = computed(() => ext.value === 'docx')
const isDoc   = computed(() => ext.value === 'doc')
const isExcel = computed(() => ['xls','xlsx','csv'].includes(ext.value))
const isPpt   = computed(() => ['ppt','pptx'].includes(ext.value))

// Dùng Office Viewer nếu là .doc / .ppt / .xls… hoặc nếu đã bật fallback
const useOfficeViewer = computed(() => forceOfficeViewer.value || isDoc.value || isPpt.value || (isExcel.value && true))

// Office Web Viewer
const officeEmbedUrl = computed(() =>
    `https://view.officeapps.live.com/op/embed.aspx?src=${encodeURIComponent(props.url)}`
)
// (Tuỳ chọn) Google Docs Viewer – đôi khi render tốt file public nhỏ
const googleEmbedUrl = computed(() =>
  `https://docs.google.com/gview?embedded=1&url=${encodeURIComponent(props.url)}`
)

onMounted(async () => {
    // Thử render DOCX nội bộ; nếu lỗi -> fallback Office Viewer
    if (isDocx.value && docxContainer.value) {
        try {
            const blob = await fetch(props.url, { mode: 'cors' }).then(r => r.blob())
            await renderAsync(blob, docxContainer.value)
        } catch (e) {
            console.warn('DOCX inline render failed, fallback to Office Viewer:', e)
            forceOfficeViewer.value = true
        }
    }

    // (Tuỳ chọn) render Excel nội bộ, nếu không muốn dùng Office Viewer cho Excel thì bỏ comment:
    if (isExcel.value && excelContainer.value) {
      try {
        new Spreadsheet(excelContainer.value, { showToolbar: false }).loadData({})
      } catch (e) {
        console.warn('Excel inline render failed, fallback to Office Viewer:', e)
        forceOfficeViewer.value = true
      }
    }
})
</script>

<style scoped>
.preview-frame { width: 100%; height: 600px; border: 0; background: #fff; }
.preview-img   { max-width: 100%; max-height: 600px; object-fit: contain; background: #fff; }
.docx-view, .excel-view { width: 100%; height: 600px; overflow: auto; background: #fff; }
.preview-empty { padding: 40px 12px; text-align: center; color: #888; }
</style>
