<template>
    <a-card :title="isEditMode ? 'Sửa chương trình' : 'Tạo chương trình'">
        <a-form
            :model="form"
            :rules="rules"
            layout="vertical"
            ref="formRef"
            @submit.prevent="handleSubmit"
        >
            <a-form-item label="Tên chương trình" name="name">
                <a-input v-model:value="form.name" />
            </a-form-item>

            <a-form-item label="Ảnh đại diện" name="image">
                <a-input v-model:value="form.image" placeholder="URL ảnh" />
            </a-form-item>

            <a-form-item label="Ngày bắt đầu" name="start_date">
                <a-date-picker v-model:value="form.start_date" style="width: 100%" />
            </a-form-item>

            <a-form-item label="Ngày kết thúc" name="end_date">
                <a-date-picker v-model:value="form.end_date" style="width: 100%" />
            </a-form-item>

            <a-form-item>
                <a-space>
                    <a-button type="primary" @click="handleSubmit" :loading="loading">
                        {{ isEditMode ? 'Cập nhật' : 'Tạo mới' }}
                    </a-button>
                    <a-button @click="goBack">Huỷ</a-button>
                </a-space>
            </a-form-item>
        </a-form>
    </a-card>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'

import Quill from 'quill'
import 'quill/dist/quill.snow.css'


import {
    createLoyaltyProgram,
    updateLoyaltyProgram,
    getLoyaltyProgram
} from '../api/loyalty'

const route = useRoute()
const router = useRouter()
const formRef = ref()
const loading = ref(false)

const isEditMode = computed(() => !!route.params.id)

const form = reactive({
    name: '',
    image: '',
    start_date: null,
    end_date: null
})

const rules = {
    name: [{ required: true, message: 'Tên là bắt buộc', trigger: 'blur' }],
    start_date: [{ required: true, message: 'Bắt buộc chọn ngày bắt đầu', trigger: 'change' }],
    end_date: [{ required: true, message: 'Bắt buộc chọn ngày kết thúc', trigger: 'change' }]
}

const fetchProgram = async () => {
    try {
        const response = await getLoyaltyProgram(route.params.id)
        const data = response.data
        form.name = data.name
        form.image = data.image
        form.start_date = data.start_date
        form.end_date = data.end_date
    } catch (e) {
        message.error('Không tìm thấy dữ liệu chương trình')
        router.push('/loyalty/programs')
    }
}

const handleSubmit = async () => {
    try {
        await formRef.value.validate()

        loading.value = true
        const payload = { ...form }

        if (isEditMode.value) {
            await updateLoyaltyProgram(route.params.id, payload)
            message.success('Đã cập nhật chương trình')
        } else {
            await createLoyaltyProgram(payload)
            message.success('Đã tạo chương trình')
        }

        router.push('/loyalty/programs')
    } catch (e) {
        message.error('Có lỗi xảy ra')
    } finally {
        loading.value = false
    }
}

const goBack = () => {
    router.push('/loyalty/programs')
}

onMounted(() => {
    if (isEditMode.value) {
        fetchProgram()
    }
})
</script>
