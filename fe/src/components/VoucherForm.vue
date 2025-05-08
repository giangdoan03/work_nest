<template>
    <a-card :title="isEditMode ? 'Sửa gói voucher' : 'Tạo gói voucher'">
        <a-form :model="form" :rules="rules" ref="formRef" layout="vertical" @submit.prevent="handleSubmit">
            <a-form-item label="Tên gói voucher" name="name">
                <a-input v-model:value="form.name" placeholder="Nhập tên gói voucher" />
            </a-form-item>

            <a-form-item label="Giá trị voucher (VND)" name="value">
                <a-input-number v-model:value="form.value" style="width: 100%" />
            </a-form-item>

            <a-form-item label="Số lượng mã voucher" name="total_quantity">
                <a-input-number v-model:value="form.total_quantity" style="width: 100%" />
            </a-form-item>

            <a-form-item label="Số lượt phát hành tối đa của 1 mã voucher">
                <a-input-number v-model:value="form.max_issue_per_code" style="width: 100%" />
            </a-form-item>

            <a-form-item label="Số lượt sử dụng tối đa của 1 mã voucher">
                <a-input-number v-model:value="form.max_use_per_code" style="width: 100%" />
            </a-form-item>

            <a-form-item label="Số lượt sử dụng tối đa của mỗi người">
                <a-input-number v-model:value="form.max_use_per_user" style="width: 100%" />
            </a-form-item>

            <a-form-item>
                <a-checkbox v-model:checked="form.has_apply_time">Thời gian áp dụng</a-checkbox>
            </a-form-item>

            <a-form-item v-if="form.has_apply_time">
                <a-range-picker v-model:value="form.date_range" style="width: 100%" />
            </a-form-item>

            <a-form-item>
                <a-checkbox v-model:checked="form.use_duration_after_issue">
                    Thời gian hiệu lực kể từ thời điểm phát hành
                </a-checkbox>
            </a-form-item>

            <a-form-item v-if="form.use_duration_after_issue">
                <a-input-group compact>
                    <a-input-number v-model:value="form.valid_after_hour" style="width: 120px" min="1" />
                    <a-select v-model:value="form.valid_after_unit" style="width: 80px">
                        <a-select-option value="hour">Giờ</a-select-option>
                        <a-select-option value="day">Ngày</a-select-option>
                    </a-select>
                </a-input-group>
            </a-form-item>

            <a-form-item label="Mô tả">
                <a-textarea v-model:content="form.description" contentType="html" style="min-height: 150px;" />
            </a-form-item>

            <a-form-item label="Ảnh voucher">
                <a-upload
                    :customRequest="uploadImage"
                    list-type="picture-card"
                    :file-list="fileList"
                    :max-count="1"
                    @remove="handleRemove"
                >
                    <div v-if="fileList.length === 0">
                        <plus-outlined />
                        <div style="margin-top: 8px">Thêm ảnh</div>
                    </div>
                </a-upload>
            </a-form-item>

            <a-form-item>
                <a-checkbox v-model:checked="form.require_owner">Yêu cầu sử dụng voucher chính chủ</a-checkbox>
            </a-form-item>

            <a-form-item>
                <a-checkbox v-model:checked="form.is_lucky_draw">Sử dụng làm mã bốc thăm trúng thưởng</a-checkbox>
            </a-form-item>

            <a-form-item>
                <a-switch v-model:checked="form.status" checked-children="Đang hoạt động" un-checked-children="Tạm dừng" />
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
import Quill from 'quill'
import 'quill/dist/quill.snow.css'
import {
    createVoucherPackage,
    updateVoucherPackage,
    getVoucherPackage,
    uploadFile
} from '../api/loyalty'

const route = useRoute()
const router = useRouter()
const isEditMode = computed(() => !!route.params.id)
const formRef = ref()
const loading = ref(false)
const fileList = ref([])

const form = reactive({
    name: '',
    value: null,
    total_quantity: null,
    max_issue_per_code: null,
    max_use_per_code: null,
    max_use_per_user: null,
    has_apply_time: false,
    date_range: [],
    use_duration_after_issue: false,
    valid_after_hour: null,
    valid_after_unit: 'hour',
    description: '',
    image: '',
    require_owner: false,
    is_lucky_draw: false,
    status: true
})

const rules = {
    name: [{ required: true, message: 'Bắt buộc nhập tên', trigger: 'blur' }],
    value: [{ required: true, message: 'Nhập giá trị voucher', trigger: 'blur' }],
    total_quantity: [{ required: true, message: 'Nhập số lượng voucher', trigger: 'blur' }]
}

const fetchData = async () => {
    try {
        const res = await getVoucherPackage(route.params.id)
        Object.assign(form, res.data)

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
        message.error('Không tìm thấy dữ liệu')
        router.push('/loyalty/voucher-management')
    }
}

const uploadImage = async ({ file, onSuccess, onError }) => {
    try {
        const res = await uploadFile(file)
        form.image = res.data.url
        fileList.value = [
            {
                uid: Date.now().toString(),
                name: file.name,
                status: 'done',
                url: res.data.url
            }
        ]
        onSuccess()
    } catch {
        onError()
        message.error('Lỗi upload ảnh')
    }
}

const handleRemove = () => {
    form.image = ''
    fileList.value = []
}

const handleSubmit = async () => {
    await formRef.value.validate()
    loading.value = true

    const payload = { ...form }

    if (form.date_range.length === 2) {
        payload.start_date = form.date_range[0]
        payload.end_date = form.date_range[1]
    }

    try {
        if (isEditMode.value) {
            await updateVoucherPackage(route.params.id, payload)
            message.success('Cập nhật thành công')
        } else {
            await createVoucherPackage(payload)
            message.success('Tạo mới thành công')
        }

        router.push('/loyalty/voucher-management')
    } catch {
        message.error('Lỗi xử lý dữ liệu')
    } finally {
        loading.value = false
    }
}

const goBack = () => router.push('/loyalty/voucher-management')

onMounted(() => {
    if (isEditMode.value) fetchData()
})
</script>

<style scoped>
:deep(.ql-editor) {
    min-height: 150px;
}
</style>
