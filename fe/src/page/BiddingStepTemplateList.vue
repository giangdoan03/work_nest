<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách bước mẫu đấu thầu</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm bước mới</a-button>
        </a-flex>

        <a-table
            :columns="columns"
            :data-source="tableData"
            :loading="loading"
            style="margin-top: 12px"
            row-key="id"
            :scroll="{ y: 'calc(100vh - 330px)' }"
        >
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ index + 1 }}
                </template>
                <template v-else-if="column.dataIndex === 'step_number'">
                    <a-tag color="blue">Bước {{ record.step_number }}</a-tag>
                </template>
                <template v-else-if="column.dataIndex === 'title'">
                    <a-typography-text strong style="cursor: pointer;" @click="editStep(record)">
                        {{ record.title }}
                    </a-typography-text>
                </template>
                <template v-else-if="column.dataIndex === 'department'">
                    <a-space wrap>
                        <a-tag v-for="dept in record.department" :key="dept">{{ dept }}</a-tag>
                    </a-space>
                </template>
                <template v-else-if="column.dataIndex === 'action'">
                    <a-space>
                        <EditOutlined class="icon-action" @click="editStep(record)" />
                        <a-popconfirm
                            title="Xoá bước này?"
                            ok-text="Xoá"
                            cancel-text="Hủy"
                            @confirm="deleteStep(record.id)"
                        >
                            <DeleteOutlined class="icon-action" style="color: red;" />
                        </a-popconfirm>
                    </a-space>
                </template>
            </template>
        </a-table>

        <a-drawer
            :title="selectedStep ? 'Chỉnh sửa bước mẫu' : 'Thêm bước mẫu'"
            :width="500"
            :open="openDrawer"
            @close="onCloseDrawer"
            :footer-style="{ textAlign: 'right' }"
        >
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-form-item label="Số bước (STT)" name="step_number">
                    <a-input-number v-model:value="formData.step_number" min="1" style="width: 100%" />
                </a-form-item>

                <a-form-item label="Tên bước" name="title">
                    <a-input v-model:value="formData.title" placeholder="Nhập tên bước" />
                </a-form-item>

                <a-form-item label="Phòng ban phụ trách" name="department">
                    <a-select
                        v-model:value="formData.department"
                        mode="multiple"
                        :options="departmentOptions"
                        placeholder="Chọn phòng ban phụ trách"
                        allow-clear
                    />
                </a-form-item>
            </a-form>

            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" :loading="loadingCreate" @click="submitStep">
                        {{ selectedStep ? 'Cập nhật' : 'Thêm mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { message } from 'ant-design-vue'
import { EditOutlined, DeleteOutlined } from '@ant-design/icons-vue'
import {
    getStepTemplatesAPI,
    createStepTemplateAPI,
    updateStepTemplateAPI,
    deleteStepTemplateAPI
} from '@/api/step-template'
import { getDepartments } from '@/api/department'

const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)
const selectedStep = ref(null)
const formRef = ref(null)
const tableData = ref([])

const departmentList = ref([])
const departmentOptions = computed(() =>
    departmentList.value.map(d => ({ label: d.name, value: d.name }))
)

const formData = ref({
    step_number: null,
    title: '',
    department: []
})

const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
    { title: 'Bước số', dataIndex: 'step_number', key: 'step_number',  width: '100px'},
    { title: 'Tên bước', dataIndex: 'title', key: 'title' },
    { title: 'Phòng ban', dataIndex: 'department', key: 'department' },
    { title: 'Hành động', dataIndex: 'action', key: 'action' }
]

const rules = {
    step_number: [{ required: true, message: 'Vui lòng nhập số bước' }],
    title: [{ required: true, message: 'Vui lòng nhập tên bước' }],
    department: [{ required: true, type: 'array', message: 'Vui lòng chọn ít nhất 1 phòng ban' }]
}

const fetchStepTemplates = async () => {
    loading.value = true
    try {
        const res = await getStepTemplatesAPI()
        tableData.value = Array.isArray(res.data)
            ? res.data.map(item => ({
                ...item,
                department: (() => {
                    try {
                        const parsed = JSON.parse(item.department)
                        return Array.isArray(parsed) ? parsed : []
                    } catch {
                        return []
                    }
                })()
            }))
            : []
    } catch (err) {
        console.error(err)
        message.error('Không thể tải danh sách bước mẫu')
    } finally {
        loading.value = false
    }
}

const fetchDepartments = async () => {
    try {
        const res = await getDepartments()
        departmentList.value = res.data || []
    } catch (err) {
        console.error(err)
        message.error('Không thể tải phòng ban')
    }
}

const showPopupCreate = () => {
    formData.value = { step_number: null, title: '', department: [] }
    selectedStep.value = null
    openDrawer.value = true
}

const editStep = (record) => {
    selectedStep.value = record
    formData.value = {
        ...record,
        department: Array.isArray(record.department)
            ? record.department
            : (() => {
                try {
                    return JSON.parse(record.department)
                } catch {
                    return []
                }
            })()
    }
    openDrawer.value = true
}

const submitStep = async () => {
    try {
        await formRef.value.validate()
        loadingCreate.value = true
        const payload = {
            ...formData.value,
            department: JSON.stringify(formData.value.department)
        }
        if (selectedStep.value) {
            await updateStepTemplateAPI(selectedStep.value.id, payload)
            message.success('Cập nhật thành công')
        } else {
            await createStepTemplateAPI(payload)
            message.success('Thêm mới thành công')
        }
        await fetchStepTemplates()
        onCloseDrawer()
    } catch (e) {
        console.error(e)
        message.error('Không thể lưu bước')
    } finally {
        loadingCreate.value = false
    }
}

const deleteStep = async (id) => {
    try {
        await deleteStepTemplateAPI(id)
        message.success('Đã xoá bước')
        await fetchStepTemplates()
    } catch (e) {
        console.error(e)
        message.error('Xoá thất bại')
    }
}

const onCloseDrawer = () => {
    openDrawer.value = false
    selectedStep.value = null
    formData.value = { step_number: null, title: '', department: [] }
    formRef.value?.resetFields()
}

onMounted(() => {
    fetchStepTemplates()
    fetchDepartments()
})
</script>

<style scoped>
.icon-action {
    font-size: 18px;
    margin-right: 8px;
    cursor: pointer;
}
</style>