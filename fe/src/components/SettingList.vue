<template>
    <div>
        <a-page-header title="Cài đặt người dùng" />

        <a-table
            :columns="columns"
            :data-source="settings"
            row-key="id"
            :loading="loading"
            :pagination="false"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="edit(record)">Sửa</a-button>
                        <a-popconfirm title="Xoá cài đặt này?" @confirm="remove(record.id)">
                            <a-button type="link" danger>Xoá</a-button>
                        </a-popconfirm>
                    </a-space>
                </template>
            </template>
        </a-table>

        <a-divider />

        <a-form layout="inline" @submit.prevent>
            <a-form-item>
                <a-input v-model:value="newSetting.key" placeholder="Key" />
            </a-form-item>
            <a-form-item>
                <a-input v-model:value="newSetting.value" placeholder="Value" />
            </a-form-item>
            <a-form-item>
                <a-button type="primary" @click="save">Lưu</a-button>
            </a-form-item>
        </a-form>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import {
    getSettings,
    createSetting,
    deleteSetting,
    updateSetting,
} from '../api/setting'

const settings = ref([])
const loading = ref(false)

const newSetting = ref({
    id: null,
    key: '',
    value: '',
})

const columns = [
    { title: 'Key', dataIndex: 'key', key: 'key' },
    { title: 'Value', dataIndex: 'value', key: 'value' },
    { title: 'Hành động', key: 'action' },
]

const fetchSettings = async () => {
    loading.value = true
    try {
        const res = await getSettings()
        settings.value = res.data
    } catch (err) {
        message.error('Không thể tải settings')
    } finally {
        loading.value = false
    }
}

const save = async () => {
    try {
        if (newSetting.value.id) {
            await updateSetting(newSetting.value.id, newSetting.value)
            message.success('Đã cập nhật cài đặt')
        } else {
            await createSetting(newSetting.value)
            message.success('Đã thêm cài đặt')
        }
        newSetting.value = { id: null, key: '', value: '' }
        fetchSettings()
    } catch (err) {
        message.error('Lỗi khi lưu cài đặt')
    }
}

const edit = (item) => {
    newSetting.value = { ...item }
}

const remove = async (id) => {
    try {
        await deleteSetting(id)
        message.success('Đã xoá')
        fetchSettings()
    } catch (err) {
        message.error('Lỗi khi xoá')
    }
}

onMounted(fetchSettings)
</script>
