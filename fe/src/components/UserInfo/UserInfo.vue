<template>
    <div>
        <a-typography-title :level="4" style="margin-bottom: 24px;">Thông tin cá nhân</a-typography-title>
        <a-form :model="form" layout="vertical" @finish="handleSubmit">
            <!-- Ảnh đại diện -->
            <a-form-item label="Ảnh đại diện">
                <a-upload
                    list-type="picture-card"
                    :file-list="avatarFileList"
                    :on-preview="handlePreview"
                    :on-remove="(file) => handleRemoveFile('avatar', file)"
                    :before-upload="(file) => handleBeforeUpload('avatar', file)"
                >
                    <div>
                        <upload-outlined/>
                        <div style="margin-top: 8px">Upload</div>
                    </div>
                </a-upload>
            </a-form-item>

            <!-- Họ tên -->
            <a-form-item label="Họ và tên" required>
                <a-input v-model:value="form.name" placeholder="Nhập họ tên" :disabled="!isEditMode"/>
            </a-form-item>

            <!-- Email -->
            <a-form-item label="Email" required>
                <a-input v-model:value="form.email" placeholder="example@mail.com" :disabled="!isEditMode"/>
            </a-form-item>

            <!-- Số điện thoại -->
            <a-form-item label="Số điện thoại" required>
                <a-input v-model:value="form.phone" placeholder="Nhập số điện thoại" :disabled="!isEditMode"/>
            </a-form-item>

            <!-- Chức danh -->
            <a-form-item label="Phòng ban">
                <a-input v-model:value="form.job_title" placeholder="VD: Phòng hành chính nhân sự" :disabled="!isEditMode"/>
            </a-form-item>

            <!-- Nút hành động -->
            <a-form-item class="margin-bot-0" v-if="isEditMode">
                <a-space>
                    <a-button type="primary" html-type="submit">Lưu</a-button>
                    <a-button @click="goBack">Huỷ</a-button>
                </a-space>
            </a-form-item>
            <a-form-item class="margin-bot-0" v-else>
                <a-space>
                    <a-button @click="changeEditMode">Thay đổi thông tin</a-button>
                </a-space>
            </a-form-item>
        </a-form>

        <!-- Modal xem ảnh -->
        <a-modal v-model:open="previewVisible" :title="previewTitle" footer={null}>
            <img :src="previewImage" alt="Preview" style="width: 100%"/>
        </a-modal>
    </div>
</template>

<script setup>
import {ref, onMounted, computed } from 'vue'
import {useRoute, useRouter} from 'vue-router'
import { uploadFile, getUserDetail } from '../../api/user'
import {getStores} from '../../api/store'
import {message} from 'ant-design-vue'
import {UploadOutlined} from '@ant-design/icons-vue'

import {useUserStore} from '../../stores/user'

const userStore = useUserStore()

const route = useRoute()
const router = useRouter()

const form = ref({
    id: null, // 👈 Thêm dòng này
    name: '',
    email: '',
    phone: '',
    department_id: '',
    avatar: ''
})
const formSaved = ref()


const avatarFileList = ref([])
const previewImage = ref('')
const previewVisible = ref(false)
const previewTitle = ref('')


const isEditMode = ref(false)

const validatePersonForm = () => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    const phoneRegex = /^[0-9]{9,15}$/

    if (!avatarFileList.value || avatarFileList.value.length === 0) {
        message.error('Vui lòng upload ảnh đại diện')
        return false
    }

    if (!form.value.name?.trim()) {
        message.error('Tên cá nhân là bắt buộc')
        return false
    }

    if (!form.value.email || !emailRegex.test(form.value.email)) {
        message.error('Vui lòng nhập email hợp lệ')
        return false
    }

    if (!form.value.phone || !phoneRegex.test(form.value.phone)) {
        message.error('Vui lòng nhập số điện thoại hợp lệ')
        return false
    }

    if (!form.value.job_title?.trim()) {
        message.error('Vui lòng nhập chức danh')
        return false
    }

    return true
}



const handleSubmit = async () => {

}


const handlePreview = (file) => {
    previewImage.value = file.url || file.thumbUrl
    previewVisible.value = true
    previewTitle.value = file.name || ''
}

const handleBeforeUpload = async (field, file) => {
    const hide = message.loading('Đang tải lên...', 0)
    try {
        const response = await uploadFile(file)
        const url = response.data.url
        form.value.avatar = url
        avatarFileList.value = [
            {
                uid: Date.now(),
                name: file.name,
                status: 'done',
                url
            }
        ]
        message.success('Upload thành công')
    } catch (error) {
        message.error('Upload thất bại')
    } finally {
        hide()
    }
    return false
}

const handleRemoveFile = () => {
    form.value.avatar = ''
    avatarFileList.value = []
}

const goBack = () => {
    isEditMode.value = false;
    form.value = formSaved.value;
}
const changeEditMode = () => {
    isEditMode.value = true;
}
const getUser = async () => {
    const res = await getUserDetail(route.params.id);
    
    if(res.status && res.data.id){
        form.value = res.data;
        formSaved.value = res.data;
    }
}

onMounted(async () => {
    if(route.params.id){
        isEditMode.value = false;
        getUser();
    }
})

</script>

<style scoped>
    :deep(.ant-input-disabled) {
        cursor: auto;
    }
    .margin-bot-0 {
        margin-bottom: 0 !important;
    }

</style>