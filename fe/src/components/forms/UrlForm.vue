<template>
    <a-form layout="vertical">
        <a-form-item label="Số điện thoại">
            <a-input v-model:value="phone" placeholder="Nhập số điện thoại" />
        </a-form-item>
        <a-form-item label="Tin nhắn">
            <a-textarea v-model:value="message" :rows="3" placeholder="Nhập nội dung tin nhắn..." />
        </a-form-item>
    </a-form>
</template>

<script setup>
import { computed } from 'vue'
const form = defineModel()

const phone = computed({
    get: () => form?.settings?.phone || '',
    set: val => {
        if (form?.settings) form.settings.phone = val
    }
})

const message = computed({
    get: () => form?.settings?.message || '',
    set: val => {
        if (form?.settings) form.settings.message = val
    }
})
</script>
