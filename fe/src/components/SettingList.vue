<template>
    <div>
        <a-page-header title="Cài đặt bước mẫu gói thầu" />

        <a-table
                :columns="columns"
                :data-source="steps"
                row-key="step_number"
                :pagination="false"
                bordered
        >
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="editStep(index)">Sửa</a-button>
                        <a-popconfirm title="Xoá bước này?" @confirm="removeStep(index)">
                            <a-button type="link" danger>Xoá</a-button>
                        </a-popconfirm>
                    </a-space>
                </template>
            </template>
        </a-table>

        <a-divider />

        <a-form layout="inline" @submit.prevent>
            <a-form-item>
                <a-input-number v-model:value="form.step_number" :min="1" placeholder="STT" />
            </a-form-item>
            <a-form-item>
                <a-input v-model:value="form.title" placeholder="Tiêu đề bước" />
            </a-form-item>
            <a-form-item>
                <a-input v-model:value="form.department" placeholder="Phòng ban phụ trách" />
            </a-form-item>
            <a-form-item>
                <a-button type="primary" @click="addOrUpdate">Lưu bước</a-button>
                <a-button style="margin-left: 8px" @click="resetForm">Hủy</a-button>
            </a-form-item>
        </a-form>

        <a-divider />

        <a-button type="primary" @click="saveToSetting">Lưu toàn bộ vào hệ thống</a-button>
    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue'
    import { message } from 'ant-design-vue'
    import {
        getSettingByKey,
        updateSetting,
        createSetting
    } from '../api/setting' // Tùy cấu trúc project của bạn

    const steps = ref([])
    const settingId = ref(null)

    const form = ref({
        step_number: null,
        title: '',
        department: ''
    })

    const editingIndex = ref(null)

    const columns = [
        { title: 'STT', dataIndex: 'step_number', key: 'step_number', width: 80 },
        { title: 'Tiêu đề', dataIndex: 'title', key: 'title' },
        { title: 'Phòng ban', dataIndex: 'department', key: 'department' },
        { title: 'Hành động', key: 'action', width: 120 }
    ]

    const fetchSetting = async () => {
        try {
            const res = await getSettingByKey('bidding_steps')
            settingId.value = res.data.id
            const parsed = JSON.parse(res.data.value)
            steps.value = parsed.steps ?? []
        } catch (err) {
            steps.value = []
            settingId.value = null
        }
    }

    const addOrUpdate = () => {
        if (!form.value.title || !form.value.step_number) {
            return message.warning('Vui lòng nhập đầy đủ STT và Tiêu đề bước')
        }

        const item = { ...form.value }

        if (editingIndex.value !== null) {
            steps.value.splice(editingIndex.value, 1, item)
        } else {
            steps.value.push(item)
        }

        resetForm()
    }

    const editStep = (index) => {
        editingIndex.value = index
        form.value = { ...steps.value[index] }
    }

    const removeStep = (index) => {
        steps.value.splice(index, 1)
    }

    const resetForm = () => {
        form.value = { step_number: null, title: '', department: '' }
        editingIndex.value = null
    }

    const saveToSetting = async () => {
        const setting = {
            key: 'bidding_steps',
            value: JSON.stringify({ steps: steps.value })
        }

        try {
            if (settingId.value) {
                await updateSetting(settingId.value, setting)
                message.success('Đã cập nhật bước mẫu')
            } else {
                const res = await createSetting(setting)
                settingId.value = res.data.id
                message.success('Đã tạo mới bước mẫu')
            }
        } catch (err) {
            message.error('Lỗi khi lưu cài đặt')
        }
    }

    onMounted(fetchSetting)
</script>
