<!-- XlsxPreview.vue -->
<template><div ref="el" style="height:540px;"></div></template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import * as XLSX from 'xlsx'
import Spreadsheet from 'x-data-spreadsheet'
import 'x-data-spreadsheet/dist/xspreadsheet.css'

const props = defineProps({ src: { type: String, required: true } })
const el = ref(null)
let sheet

async function load() {
    const buf = await fetch(props.src).then(r => r.arrayBuffer())
    const wb = XLSX.read(buf, { type: 'array' })
    const data = wb.SheetNames.map(name => {
        const ws = wb.Sheets[name]
        const json = XLSX.utils.sheet_to_json(ws, { header: 1 })
        return { name, rows: json.map((row, r) => ({ cells: row.reduce((o, v, c) => { o[c] = { text: v ?? '' }; return o }, {}) })) }
    })
    if (!sheet) sheet = new Spreadsheet(el.value, { mode: 'read' })
    sheet.loadData(data)
}
onMounted(load)
watch(() => props.src, load)
</script>
