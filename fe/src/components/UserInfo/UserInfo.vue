<template>
    <div>
        <a-typography-title :level="4" style="margin-bottom: 24px;">Thông tin cá nhân</a-typography-title>
        <a-form :model="form" :rules="rules" layout="vertical" @finish="handleSubmit" ref="formRef">
            <!-- Ảnh đại diện -->
            <a-form-item label="Ảnh đại diện" name="avatar">
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
            <a-form-item label="Họ và tên" name="name">
                <a-input v-model:value="form.name" placeholder="Nhập họ tên" :disabled="!isEditMode"/>
            </a-form-item>

            <!-- Email -->
            <a-form-item label="Email" name="email">
                <a-input v-model:value="form.email" placeholder="example@mail.com" :disabled="!isEditMode"/>
            </a-form-item>

            <!-- Số điện thoại -->
            <a-form-item label="Số điện thoại" name="phone">
                <a-input v-model:value="form.phone" placeholder="Nhập số điện thoại" :disabled="!isEditMode"/>
            </a-form-item>

            <!-- Chức danh -->
            <a-form-item label="Phòng ban" name="department">
                <a-input v-model:value="form.department_id" placeholder="VD: Phòng hành chính nhân sự" :disabled="!isEditMode"/>
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
import { log } from 'node:console'

const userStore = useUserStore()

const route = useRoute()
const router = useRouter()


const props = defineProps({
    dataUser: {
        type: Object,
        default: () => ({})
    }
})

const form = ref({
    id: null, // 👈 Thêm dòng này
    name: '',
    email: '',
    phone: '',
    department_id: '',
    avatar: ''
})
const formSaved = ref()
const formRef = ref()


const avatarFileList = ref([])
const previewImage = ref('')
const previewVisible = ref(false)
const previewTitle = ref('')


const isEditMode = ref(false)

const rules = {
    name: [{ required: true, message: 'Họ và tên là bắt buộc', trigger: 'change' }],
    email: [{ required: true, message: 'Email là bắt buộc', trigger: 'change' }],
    phone: [{ required: true, message: 'Số điện thoại là bắt buộc', trigger: 'change' }],
    department: [{ required: true, message: 'Phòng ban là bắt buộc', trigger: 'change' }]
}




const handleSubmit = async () => {
    console.log(form.value);
}


const handlePreview = (file) => {
    previewImage.value = file.url || file.thumbUrl
    previewVisible.value = true
    previewTitle.value = file.name || ''
}

const handleBeforeUpload = async (field, file) => {
    const hide = message.loading('Đang tải lên...', 0)
    try {
        console.log();
        
        let params = {
            file: file,
            user_id: route.params.id
        }
        const formData = new FormData();
        Object.entries(params).forEach(([key, value]) => {
            formData.append(key, value);
        });
        params = formData;
        return
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
    resetFormValidate()
    isEditMode.value = false;
    form.value = formSaved.value;
}
const changeEditMode = () => {
    isEditMode.value = true;
}
const resetFormValidate = () => {
    formRef.value.resetFields();
};

onMounted(async () => {
    if(props.dataUser){
        isEditMode.value = false;
        form.value = props.dataUser;
        formSaved.value = props.dataUser;
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