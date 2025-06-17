<template>
    <a-card bordered>
        <template #title>
            <SettingOutlined /> Cài đặt hệ thống file
        </template>

        <a-form layout="vertical" @submit.prevent>
            <a-row :gutter="16">
                <a-col :span="12">
                    <a-form-item>
                        <template #label>
                            Dung lượng tối đa mỗi file (MB)
                        </template>
                        <a-input-number v-model:value="form.max_file_size" :min="1" style="width: 100%" />
                    </a-form-item>
                </a-col>

                <a-col :span="12">
                    <a-form-item>
                        <template #label>
                            Định dạng được phép (cách nhau bởi dấu phẩy)
                        </template>
                        <a-input v-model:value="form.allowed_types" placeholder="pdf,docx,xlsx,zip" />
                    </a-form-item>
                </a-col>
            </a-row>

            <a-form-item>
                <template #label>
                   Tổ chức thư mục theo
                </template>
                <a-radio-group v-model:value="form.folder_structure">
                    <a-radio value="year_month">Năm / Tháng</a-radio>
                    <a-radio value="department">Phòng ban</a-radio>
                    <a-radio value="uploader">Tên người upload</a-radio>
                </a-radio-group>
            </a-form-item>

            <a-form-item>
                <template #label>
                    Vai trò được phép tải lên
                </template>
                <a-checkbox-group v-model:value="form.upload_roles" :options="roles" />
            </a-form-item>

            <a-form-item>
                <template #label>
                    Vai trò được phép xem công khai
                </template>
                <a-checkbox-group v-model:value="form.view_roles" :options="roles" />
            </a-form-item>

            <a-form-item>
                <a-button type="primary" @click="saveSetting" :loading="saving">
                    <template #icon><SaveOutlined /></template>
                    Lưu cấu hình
                </a-button>
            </a-form-item>
        </a-form>
    </a-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import {
    SettingOutlined,
    FileOutlined,
    FolderOpenOutlined,
    CheckSquareOutlined,
    EyeOutlined,
    SaveOutlined,
} from '@ant-design/icons-vue'
import {
    getDocumentSettings,
    saveDocumentSettings,
} from '../api/document-settings'

const form = ref({
    max_file_size: 10,
    allowed_types: 'pdf,docx,xlsx,zip',
    folder_structure: 'year_month',
    upload_roles: ['admin'],
    view_roles: ['admin'],
})

const roles = [
    { label: 'Admin', value: 'admin' },
    { label: 'Manager', value: 'manager' },
    { label: 'Staff', value: 'staff' },
]

const saving = ref(false)

const saveSetting = async () => {
    saving.value = true
    try {
        await saveDocumentSettings(form.value)
        message.success('Đã lưu cấu hình')
    } catch (err) {
        message.error('Lỗi khi lưu cấu hình')
    } finally {
        saving.value = false
    }
}

const loadSetting = async () => {
    try {
        const res = await getDocumentSettings()
        form.value = { ...form.value, ...res.data }
    } catch (err) {
        message.warning('Không thể tải cấu hình, dùng mặc định.')
    }
}

onMounted(() => {
    loadSetting()
})
</script>
