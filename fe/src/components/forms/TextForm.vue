<template>
    <a-form layout="vertical">
        <a-form-item label="Nội dung văn bản">
            <a-textarea v-model:value="text" :rows="4" placeholder="Nhập nội dung..." />
        </a-form-item>
    </a-form>
</template>

<script setup>
import { computed } from 'vue'
const form = defineModel()

const text = computed({
    get: () => form?.settings?.data || '',
    set: val => {
        if (form?.settings) form.settings.data = val
    }
})
</script>