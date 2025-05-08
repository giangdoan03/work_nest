<template>
    <a-card :title="isEditMode ? 'Sửa quà tặng' : 'Thêm mới quà tặng'">
        <a-form
            ref="formRef"
            :model="form"
            :rules="rules"
            layout="vertical"
            @submit.prevent="handleSubmit"
        >
            <a-form-item label="Tên quà (*)" name="name">
                <a-input v-model:value="form.name" placeholder="Nhập tên quà" />
            </a-form-item>

            <a-form-item label="Ảnh quà (*)" name="image">
                <a-upload
                    name="file"
                    list-type="picture-card"
                    :max-count="1"
                    :customRequest="uploadImage"
                    :file-list="fileList"
                    @remove="handleRemove"
                    accept="image/*"
                >
                    <div v-if="fileList.length === 0">
                        <PlusOutlined />
                        <div style="margin-top: 8px">Upload</div>
                    </div>
                </a-upload>
            </a-form-item>

            <a-form-item label="Loại quà (*)" name="type">
                <a-select v-model:value="form.type" placeholder="Chọn loại quà">
                    <a-select-option value="point">Điểm VNPoint</a-select-option>
                    <a-select-option value="physical">Hiện vật</a-select-option>
                </a-select>
            </a-form-item>

            <a-form-item label="Giá trị (*)" name="value">
                <a-input-number v-model:value="form.value" style="width: 100%" />
            </a-form-item>

            <a-form-item label="Trạng thái">
                <a-switch v-model:checked="form.status" checked-children="Hiển thị" un-checked-children="Ẩn" />
            </a-form-item>

            <a-form-item label="Mô tả">
                <quill-editor v-model:content="form.description" contentType="html" style="min-height: 150px;" />
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
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import {
    getLoyaltyGift,
    createLoyaltyGift,
    updateLoyaltyGift,
    uploadFile
} from '../api/loyalty'
import Quill from 'quill'
import 'quill/dist/quill.snow.css'

const route = useRoute()
const router = useRouter()

const formRef = ref()
const loading = ref(false)
const isEditMode = computed(() => !!route.params.id)

const form = reactive({
    name: '',
    image: '',
    type: '',
    value: null,
    status: true,
    description: ''
})

const fileList = ref([])

const rules = {
    name: [{ required: true, message: 'Tên quà bắt buộc', trigger: 'blur' }],
    image: [{ required: true, message: 'Ảnh là bắt buộc', trigger: 'blur' }],
    type: [{ required: true, message: 'Chọn loại quà', trigger: 'change' }],
    value: [{ required: true, message: 'Giá trị là bắt buộc', trigger: 'blur' }]
}

const fetchGift = async () => {
    try {
        const response = await getLoyaltyGift(route.params.id)
        Object.assign(form, response.data)
        if (form.image) {
            fileList.value = [
                {
                    uid: '-1',
                    name: 'image.png',
                    status: 'done',
                    url: form.image
                }
            ]
        }
    } catch {
        message.error('Không tìm thấy quà tặng')
        router.push('/loyalty/gifts')
    }
}

const uploadImage = async ({ file, onSuccess, onError }) => {
    try {
        const response = await uploadFile(file)
        const url = response.data.url
        form.image = url
        fileList.value = [
            {
                uid: Date.now().toString(),
                name: file.name,
                status: 'done',
                url
            }
        ]
        onSuccess()
    } catch {
        onError()
        message.error('Upload thất bại')
    }
}

const handleRemove = () => {
    form.image = ''
    fileList.value = []
}

const handleSubmit = async () => {
    try {
        await formRef.value.validate()
        loading.value = true

        if (isEditMode.value) {
            await updateLoyaltyGift(route.params.id, form)
            message.success('Cập nhật thành công')
        } else {
            await createLoyaltyGift(form)
            message.success('Tạo mới thành công')
        }

        router.push('/loyalty/gifts')
    } catch {
        message.error('Đã xảy ra lỗi')
    } finally {
        loading.value = false
    }
}

const goBack = () => router.push('/loyalty/gifts')

onMounted(() => {
    if (isEditMode.value) {
        fetchGift()
    }
})
</script>

<style scoped>
:deep(.ql-editor) {
    min-height: 150px;
}
</style>
