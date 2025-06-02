<template>
    <div>
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
                <a-input v-model:value="form.name" placeholder="Nhập họ tên"/>
            </a-form-item>

            <!-- Email -->
            <a-form-item label="Email" required>
                <a-input v-model:value="form.email" placeholder="example@mail.com"/>
            </a-form-item>

            <!-- Số điện thoại -->
            <a-form-item label="Số điện thoại" required>
                <a-input v-model:value="form.phone" placeholder="Nhập số điện thoại"/>
            </a-form-item>

            <!-- Chức danh -->
            <a-form-item label="Phòng ban">
                <a-input v-model:value="form.job_title" placeholder="VD: Phòng hành chính nhân sự"/>
            </a-form-item>

            <!-- Nút hành động -->
            <a-form-item class="margin-bot-0">
                <a-space>
                    <a-button type="primary" html-type="submit">Lưu</a-button>
                    <a-button @click="goBack">Huỷ</a-button>
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
import { uploadFile } from '../../api/userv2'
import {getStores} from '../../api/store'
import {message} from 'ant-design-vue'
import {UploadOutlined} from '@ant-design/icons-vue'

import {useUserStore} from '../../stores/user'

const userStore = useUserStore()

const route = useRoute()
const router = useRouter()

const form = ref({
    user_id: null, // 👈 Thêm dòng này
    name: '',
    email: '',
    phone: '',
    department_id: '',
    avatar: ''
})


const avatarFileList = ref([])
const previewImage = ref('')
const previewVisible = ref(false)
const previewTitle = ref('')


const isEditMode = computed(() => !!route.params.id);

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

const goBack = () => router.push('/persons')

onMounted(async () => {

})

</script>

<style scoped>
    .margin-bot-0 {
        margin-bottom: 0 !important;
    }
    .custom-disabled-switch.ant-switch-disabled {
        background: #d9d9d9 !important; /* Màu xám */
        border-color: #d9d9d9 !important;
    }

    .link-list-wrapper {
        margin-top: 20px;
    }

    .iphone-mockup {
        width: 310px;
        height: 640px;
        margin: 0 auto;
        border: 10px solid #1c1c1e;
        border-radius: 48px;
        background: #000;
        position: relative;
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
        overflow: hidden;
    }

    /* Notch */
    .notch {
        position: absolute;
        top: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 150px;
        height: 30px;
        background: #000;
        border-bottom-left-radius: 16px;
        border-bottom-right-radius: 16px;
        z-index: 2;
    }

    /* Inner screen */
    .iphone-screen {
        width: 100%;
        height: 100%;
        background: #fff;
        border-radius: 36px;
        overflow-y: auto;
        padding-bottom: 12px;
        padding-top: 40px; /* để chừa notch */
        box-sizing: border-box;
        position: relative;
        z-index: 1;
    }

    /* Image and info inside screen */
    .screen-img {
        width: 100%;
        height: auto;
        border-radius: 0;
        object-fit: cover;
    }

    .info {
        padding: 12px;
        font-size: 14px;
        text-align: center;
    }

    .dynamic-island {
        position: absolute;
        top: 14px;
        left: 50%;
        transform: translateX(-50%);
        width: 110px;
        height: 30px;
        background: #000;
        border-radius: 20px;
        z-index: 2;
        transition: all 0.3s ease;
        box-shadow: 0 0 6px rgba(255, 255, 255, 0.05);
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        padding: 0 8px;
    }

    .dynamic-island.expanded {
        width: 180px;
        height: 40px;
        border-radius: 24px;
    }

    .marquee {
        width: 100%;
        overflow: hidden;
        white-space: nowrap;
        position: relative;
    }

    .marquee-content {
        display: inline-block;
        padding-left: 100%;
        animation: scrollText 10s linear infinite;
        color: #fff;
        font-size: 12px;
        opacity: 0.8;
    }

    .active-card {
        box-shadow: 0 0 8px #52c41a;
    }

    @keyframes scrollText {
        0% {
            transform: translateX(0);
        }
        100% {
            transform: translateX(-100%);
        }
    }

</style>