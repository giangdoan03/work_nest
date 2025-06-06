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
                <a-input v-model:value="form.email" placeholder="example@mail.com" disabled/>
            </a-form-item>

            <!-- Số điện thoại -->
            <a-form-item label="Số điện thoại" name="phone">
                <a-input v-model:value="form.phone" placeholder="Nhập số điện thoại" :disabled="!isEditMode"/>
            </a-form-item>

            <!-- Chức danh -->
            <a-form-item label="Phòng ban" name="department">
                <a-input :value="getNameDepartments" placeholder="VD: Phòng hành chính nhân sự" disabled/>
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
import { uploadFile, updateUser } from '../../api/user'
import {message} from 'ant-design-vue'
import {UploadOutlined} from '@ant-design/icons-vue'
import cloneDeep from 'lodash/cloneDeep'

import {useUserStore} from '../../stores/user'
import { getDepartments } from '@/api/department'

const userStore = useUserStore()

const route = useRoute()
const router = useRouter()


const props = defineProps({
    dataUser: {
        type: Object,
        default: () => ({})
    }
})
const emit = defineEmits(['reload'])

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
const departments = ref([])

const isEditMode = ref(false)

const validateName = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập họ và tên');
    } else if(value.length > 200){
        return Promise.reject('Họ và tên không vượt quá 200 ký tự');
    } else {
        return Promise.resolve();
    }
};
const validatePhone = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập số điện thoại');
    } else if(value.length > 20){
        return Promise.reject('Số điện thoại không vượt quá 20 ký tự');
    } else if(value.length > 20){
        return Promise.reject('Số điện thoại không vượt quá 20 ký tự');
    } else {
        return Promise.resolve();
    }
};
function isValidPhoneNumber(phone) {
  const regex = /^(0|\+84)(3[2-9]|5[6|8|9]|7[0|6-9]|8[1-5]|9[0-9])[0-9]{7}$/;
  return regex.test(phone);
}

const rules = computed(() => {
    if (isEditMode.value) {
        return {
            name: [{ required: true, validator: validateName, message: 'Họ và tên là bắt buộc', trigger: 'change' }],
            phone: [{ required: true, validator: validatePhone, message: 'Số điện thoại là bắt buộc', trigger: 'change' }],
        }
    }else{
        return {}
    }
})

const getNameDepartments = computed(() => {
    const department = departments.value.find(item => item.id === form.value.department_id)
    return department ? department.name : form.value.department_id
})

const handleSubmit = async () => {
    let params = {
        name: form.value.name,
        phone: form.value.phone,
    }
    await updateUser(form.value.id, params).then(res => {
        if(res.data.status == "success"){
            message.destroy();
            message.success('Cập nhật thông tin thành công')
            emit('reload');
            isEditMode.value = false;
        }else{
            message.destroy();
            message.error('Cập nhật thông tin thất bại')
        }
    })
}

const handlePreview = (file) => {
    previewImage.value = file.url || file.thumbUrl
    previewVisible.value = true
    previewTitle.value = file.name || ''
}

const handleBeforeUpload = async (field, file) => {
    const hide = message.loading('Đang tải lên...', 0)
    try {
        let params = {
            file: file,
            user_id: route.params.id
        }
        const response = await uploadFile(params)
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
    formSaved.value = cloneDeep(form.value)
}
const resetFormValidate = () => {
    formRef.value.resetFields();
};
const getListDepartments = async () => {
    await getDepartments().then(res => {
        if (res.data) {
            departments.value = res.data;
        }
    });
}
onMounted(async () => {
    if(props.dataUser){
        isEditMode.value = false;
        form.value = cloneDeep(props.dataUser);
        formSaved.value = cloneDeep(props.dataUser);
    }
    await getListDepartments();
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