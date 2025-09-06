<template>
    <div class="profile-page">
        <!-- Page header -->
        <a-page-header
            class="profile-header"
            :title="'Thông tin cá nhân'"
            :ghost="false"
        >
            <template #extra>
                <a-badge v-if="isEditMode" status="processing" text="Đang chỉnh sửa" />
                <a-space>
                    <a-button v-if="!isEditMode" type="default" @click="changeEditMode">Thay đổi thông tin</a-button>
                    <template v-else>
                        <a-button @click="goBack">Huỷ</a-button>
                        <a-button type="primary" @click="handleSubmit">Lưu</a-button>
                    </template>
                </a-space>
            </template>
        </a-page-header>

        <a-row :gutter="[24,24]">
            <!-- LEFT: Avatar -->
            <a-col :xs="24" :md="8" :lg="7">
                <a-card class="card avatar-card" :bodyStyle="{padding:'20px'}">
                    <div class="avatar-wrap" @mouseover="isHoverAvatar = true" @mouseleave="isHoverAvatar = false">
                        <a-avatar :size="120" shape="square" :src="avatarSrc" class="avatar-img">
                            <template v-if="!hasAvatar">?</template>
                        </a-avatar>

                        <transition name="fade">
                            <div class="avatar-overlay" v-if="isHoverAvatar">
                                <a-space>
                                    <a-tooltip title="Đổi ảnh">
                                        <a-button shape="circle" @click="handleChangeAvatar">
                                            <template #icon><EditOutlined /></template>
                                        </a-button>
                                    </a-tooltip>
                                    <a-tooltip title="Xem ảnh">
                                        <a-button shape="circle" @click="handlePreview">
                                            <template #icon><EyeOutlined /></template>
                                        </a-button>
                                    </a-tooltip>
                                </a-space>
                            </div>
                        </transition>
                    </div>

                    <div class="avatar-hint">
                        <div>Định dạng: JPG/PNG/GIF/WebP • &lt; 4MB</div>
                        <div>Kích thước đề xuất: 400×400px</div>
                    </div>

                    <!-- Khi chưa có avatar: nút tải lên nhanh -->
                    <div v-if="!hasAvatar" class="avatar-upload-quick">
                        <a-upload
                            list-type="picture-card"
                            :show-upload-list="false"
                            :maxCount="1"
                            :before-upload="beforeAvatarValidate"
                            :customRequest="uploadAvatarRequest"
                            accept="image/*"
                        >
                            <div class="upload-quick">
                                <upload-outlined />
                                <div style="margin-top:8px">Tải ảnh lên</div>
                            </div>
                        </a-upload>
                    </div>
                </a-card>
            </a-col>

            <!-- RIGHT: Info -->
            <a-col :xs="24" :md="16" :lg="17">
                <a-card class="card info-card" :bodyStyle="{padding:'20px'}">
                    <!-- VIEW MODE -->
                    <a-descriptions
                        v-if="!isEditMode"
                        :column="{ xs:1, sm:1, md:2 }"
                        layout="vertical"
                        size="middle"
                        colon
                    >
                        <a-descriptions-item label="Họ và tên">
                            {{ form.name || '—' }}
                        </a-descriptions-item>
                        <a-descriptions-item label="Email">
                            {{ form.email || '—' }}
                        </a-descriptions-item>
                        <a-descriptions-item label="Số điện thoại">
                            {{ form.phone || '—' }}
                        </a-descriptions-item>
                        <a-descriptions-item label="Phòng ban">
                            {{ getNameDepartments || '—' }}
                        </a-descriptions-item>
                        <a-descriptions-item label="Loại tài khoản">
                            {{ form.role || '—' }}
                        </a-descriptions-item>
                    </a-descriptions>

                    <!-- EDIT MODE -->
                    <a-form
                        v-else
                        ref="formRef"
                        layout="vertical"
                        :model="form"
                        :rules="rules"
                        @finish="handleSubmit"
                    >
                        <a-row :gutter="[16,0]">
                            <a-col :xs="24" :md="12">
                                <a-form-item label="Họ và tên" name="name">
                                    <a-input v-model:value="form.name" placeholder="Nhập họ tên" />
                                </a-form-item>
                            </a-col>
                            <a-col :xs="24" :md="12">
                                <a-form-item label="Email" name="email">
                                    <a-input v-model:value="form.email" disabled />
                                </a-form-item>
                            </a-col>
                            <a-col :xs="24" :md="12">
                                <a-form-item label="Số điện thoại" name="phone">
                                    <a-input v-model:value="form.phone" placeholder="Nhập số điện thoại" />
                                </a-form-item>
                            </a-col>
                            <a-col :xs="24" :md="12">
                                <a-form-item label="Phòng ban" name="department">
                                    <a-input :value="getNameDepartments" disabled />
                                </a-form-item>
                            </a-col>
                            <a-col :xs="24" :md="12">
                                <a-form-item label="Loại tài khoản" name="role">
                                    <a-input :value="form.role" disabled />
                                </a-form-item>
                            </a-col>
                        </a-row>
                    </a-form>
                </a-card>
            </a-col>
        </a-row>

        <!-- Modal xem ảnh -->
        <a-modal :open="previewVisible" :footer="null" @cancel="cancelPreview" width="720px">
            <img alt="avatar" style="width:100%; max-width:680px; max-height:680px; display:block; margin:0 auto;" :src="avatarSrc" />
        </a-modal>
    </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { UploadOutlined, EyeOutlined, EditOutlined } from '@ant-design/icons-vue'
import cloneDeep from 'lodash/cloneDeep'

import { useUserStore } from '@/stores/user.js'
import { uploadFile, updateUser, uploadAvatar } from '@/api/user.js'
import { getDepartments } from '@/api/department'

/* ====== stores / route ====== */
const userStore = useUserStore()
const route = useRoute()
const router = useRouter()

/* ====== props / emits ====== */
const props = defineProps({
    dataUser: { type: Object, default: () => ({}) }
})
const emit = defineEmits(['reload'])

/* ====== state ====== */
const form = ref({
    id: null,
    name: '',
    email: '',
    phone: '',
    department_id: '',
    role: '',
    avatar: ''
})
const formSaved = ref()
const formRef = ref()

const departments = ref([])
const previewVisible = ref(false)
const isHoverAvatar = ref(false)
const isEditMode = ref(false)

/* ====== avatar helpers ====== */
const ORIGIN = new URL(import.meta.env.VITE_API_URL).origin
const hasAvatar = computed(() => !!(form.value.avatar && String(form.value.avatar).trim()))
const avatarSrc = computed(() => {
    const v = String(form.value.avatar || '').trim()
    if (!v) return ''
    const base = new URL(ORIGIN)
    const u = new URL(v, ORIGIN) // support relative/absolute
    u.protocol = base.protocol
    u.host = base.host
    return u.href
})

/* ====== validation ====== */
const validateName = async (_r, value) => {
    if (!value) return Promise.reject('Vui lòng nhập họ và tên')
    if (value.length > 200) return Promise.reject('Họ và tên không vượt quá 200 ký tự')
    return Promise.resolve()
}
const validatePhone = async (_r, value) => {
    if (!value) return Promise.reject('Vui lòng nhập số điện thoại')
    if (value.length > 20) return Promise.reject('Số điện thoại không vượt quá 20 ký tự')
    if (!/^(0|\+84)(3[2-9]|5[6|8|9]|7[0|6-9]|8[1-5]|9[0-9])[0-9]{7}$/.test(value)) {
        return Promise.reject('Vui lòng nhập đúng số điện thoại')
    }
    return Promise.resolve()
}
const rules = computed(() =>
    isEditMode.value
        ? {
            name: [{ required: true, validator: validateName, trigger: 'change' }],
            phone: [{ required: true, validator: validatePhone, trigger: 'change' }]
        }
        : {}
)

/* ====== computed ====== */
const getNameDepartments = computed(() => {
    const d = departments.value.find(x => x.id === form.value.department_id)
    return d ? d.name : form.value.department_id
})

/* ====== actions ====== */
const handleSubmit = async () => {
    const params = { name: form.value.name, phone: form.value.phone }
    const { data } = await updateUser(form.value.id, params)
    if (data?.status === 'success') {
        message.success('Cập nhật thông tin thành công')
        emit('reload')
        isEditMode.value = false
    } else {
        message.error('Cập nhật thông tin thất bại')
    }
}

const handlePreview = () => { previewVisible.value = true }
const cancelPreview = () => { previewVisible.value = false }

const handleChangeAvatar = () => {
    const input = document.createElement('input')
    input.type = 'file'
    input.accept = 'image/*'
    input.onchange = (e) => {
        const file = e.target.files?.[0]
        if (!file) return
        if (beforeAvatarValidate(file) !== true) return
        uploadAvatarRequest({ file, onSuccess: () => {}, onError: () => {}, onProgress: () => {} })
    }
    input.click()
}

/* Validate trước khi upload (size + loại file) */
const beforeAvatarValidate = (file) => {
    const isImage = /image\/(jpeg|png|gif|webp)/.test(file.type)
    if (!isImage) { message.error('Chỉ hỗ trợ JPEG/PNG/GIF/WebP'); return false }
    const isLt4M = file.size / 1024 / 1024 < 4
    if (!isLt4M) { message.error('Ảnh phải nhỏ hơn 4MB'); return false }
    return true
}

/* Upload custom */
const uploadAvatarRequest = async ({ file, onSuccess, onError, onProgress }) => {
    const hide = message.loading('Đang tải lên...', 0)
    try {
        const res = await uploadAvatar(file, form.value.id || route.params.id, (percent) => {
            onProgress && onProgress({ percent })
        })
        const rel = res.data?.avatar_path || res.data?.avatar_url
        if (!rel) throw new Error('Không nhận được đường dẫn ảnh')
        form.value.avatar = rel
        message.success('Upload & lưu avatar thành công')
        onSuccess && onSuccess({}, file)
    } catch (e) {
        console.error(e)
        message.error('Upload thất bại')
        onError && onError(e)
    } finally { hide() }
}

/* ====== edit toggle ====== */
const goBack = () => {
    resetFormValidate()
    isEditMode.value = false
    form.value = formSaved.value
}
const changeEditMode = () => {
    isEditMode.value = true
    formSaved.value = cloneDeep(form.value)
}
const resetFormValidate = () => { formRef.value?.resetFields?.() }

/* ====== data ====== */
const getListDepartments = async () => {
    const res = await getDepartments()
    if (res.data) departments.value = res.data
}

/* ====== props sync ====== */
watch(() => props.dataUser, (v) => {
    if (!v) return
    isEditMode.value = false
    const incoming = cloneDeep(v)
    if (!incoming.avatar && form.value.avatar) incoming.avatar = form.value.avatar
    form.value = incoming
    formSaved.value = cloneDeep(incoming)
}, { deep: false })

onMounted(async () => {
    if (props.dataUser) {
        isEditMode.value = false
        form.value = cloneDeep(props.dataUser)
        formSaved.value = cloneDeep(props.dataUser)
    }
    await getListDepartments()
})
</script>

<style scoped>
/* Layout */
.profile-page { max-width: 1080px; margin: 0 auto; }
.profile-header { margin-bottom: 16px; border-radius: 12px; }

/* Cards */
.card {
    border: 1px solid #f0f0f0;
    border-radius: 16px;
    box-shadow: 0 6px 18px rgba(0,0,0,0.04);
}
.avatar-card { text-align: center; }
.info-card   { }

/* Avatar */
.avatar-wrap { position: relative; display: inline-block; }
.avatar-img  { border-radius: 12px; box-shadow: 0 6px 16px rgba(0,0,0,.06); }
.avatar-overlay{
    position: absolute; inset: 0;
    display:flex; align-items:center; justify-content:center;
    background: rgba(255,255,255,.7); border-radius: 12px;
}
.avatar-hint{
    margin-top: 12px; color:#8c8c8c; font-size:12px; line-height:1.4;
}
.avatar-upload-quick{ margin-top: 12px; }
.upload-quick{ text-align:center; color:#8c8c8c; }

/* Smooth fade for overlay */
.fade-enter-active, .fade-leave-active { transition: opacity .18s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

/* Typography tweaks inside descriptions */
:deep(.ant-descriptions-item-label) { color:#8c8c8c; }
:deep(.ant-descriptions-item-content) { font-weight: 500; }

/* Disable cursor for disabled inputs */
:deep(.ant-input[disabled]) { cursor: default; }
</style>
