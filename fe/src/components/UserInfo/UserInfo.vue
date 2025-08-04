<template>
    <div>
        <a-typography-title :level="4" style="margin-bottom: 24px;">Thông tin cá nhân</a-typography-title>
        <a-form :model="form" :rules="rules" layout="vertical" @finish="handleSubmit" ref="formRef">
            <!-- Ảnh đại diện -->
            <a-form-item label="Ảnh đại diện" name="avatar" v-if="!form.avatar">
                <a-upload
                    list-type="picture-card"
                    :file-list="avatarFileList"
                    :show-upload-list="false"
                    :maxCount="1"
                    :multiple="true"
                    :on-remove="(file) => handleRemoveFile('avatar', file)"
                    :before-upload="(file) => handleBeforeUpload('avatar', file)"
                    ref="uploadAvatar"
                    :customRequest="({ file }) => handleBeforeUpload('avatar', file)"
                >
                    <div>
                        <upload-outlined/>
                        <div style="margin-top: 8px">Tải ảnh lên</div>
                    </div>
                </a-upload>
            </a-form-item>
            <a-form-item label="Ảnh đại diện" name="avatar_isset" v-else>
                <div class="avatar" @mouseover="isHoverAvatar = true" @mouseleave="isHoverAvatar = false">
                    <a-avatar :size="110" shape="square" :src="form.avatar">
                    </a-avatar>
                    <div class="action-icon" v-if="isHoverAvatar">
                        <a-button type="link" style="margin-right: 16px;" @click="handleChangeAvatar">
                            <template #icon>
                                <EditOutlined style="font-size: 22px; color: rgba(0, 0, 0, 0.85);"/>
                            </template>
                        </a-button>
                        <a-button  type="link" @click="handlePreview">
                            <template #icon>
                                <EyeOutlined style="font-size: 22px; color: rgba(0, 0, 0, 0.85);"/>
                            </template>
                        </a-button>
                    </div>
                </div>
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

            <!-- Loại tài khoản -->
            <a-form-item label="Loại tài khoản" name="role">
                <a-input :value="form.role" placeholder="VD: Nhân viên, Trưởng phòng" disabled />
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
        <a-modal :open="previewVisible" :footer="null" @cancel="cancelPreview">
            <img alt="example" style="width: 100%; max-width: 600px; max-height: 600px;" :src="form.avatar" />
        </a-modal>
    </div>
</template>

<script setup>
import {ref, onMounted, computed, watch } from 'vue'
import {useRoute, useRouter} from 'vue-router'
import { uploadFile, updateUser } from '@/api/user.js'
import {message} from 'ant-design-vue'
import {UploadOutlined, EyeOutlined, EditOutlined } from '@ant-design/icons-vue'
import cloneDeep from 'lodash/cloneDeep'

import {useUserStore} from '@/stores/user.js'
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
const uploadAvatar = ref(null);

const avatarFileList = ref([])
const previewVisible = ref(false)
const departments = ref([])

const isHoverAvatar = ref(false);
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
    } else if(!isValidPhoneNumber(value)){
        return Promise.reject('Vui lòng nhập đúng số điện thoại');
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
        // avatar: form.value.avatar,
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

const handlePreview = async file => {    
    previewVisible.value = true;
};
const cancelPreview = () =>{
    previewVisible.value = false;
}
const handleChangeAvatar = () => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.onchange = (e) => {
        const file = e.target.files[0];
        if (file) {
            handleBeforeUpload('avatar', file);
        }
    };
    input.click();
}

const handleBeforeUpload = async (field, file) => {
    const hide = message.loading('Đang tải lên...', 0)
    try {
        let params = {
            file: file,
            user_id: route.params.id
        }
        const response = await uploadFile(params)
        const url = response.data.avatar_url        
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
watch(() => 
props.dataUser, function (value) {
    if(value){
        isEditMode.value = false;
        form.value = cloneDeep(props.dataUser);
        formSaved.value = cloneDeep(props.dataUser);
    }
}, {deep: true})

</script>

<style scoped>
    :deep(.ant-input-disabled) {
        cursor: auto;
    }
    .margin-bot-0 {
        margin-bottom: 0 !important;
    }
    .avatar{
        position: relative;
        z-index: 1;
        width: 110px;
        height: 110px;
    }
    
    .action-icon{
        position: absolute;
        top: 0;
        width: 110px;
        height: 110px;
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 2;
    }
    .action-icon:hover {
        background: rgba(255, 255, 255, 0.397);
    }
</style>