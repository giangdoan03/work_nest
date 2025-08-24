<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách bước mẫu hợp đồng</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm bước mới</a-button>
        </a-flex>

        <a-table
            :columns="columns"
            :data-source="tableData"
            :loading="loading"
            row-key="id"
            :pagination="pagination"
            :scroll="{ x: 'max-content'}"
            @change="onTableChange"
        >
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ rowNumber(index) }}
                </template>
                <template v-else-if="column.dataIndex === 'step_number'">
                    <a-tag color="blue">Bước {{ record.step_number }}</a-tag>
                </template>
                <template v-else-if="column.dataIndex === 'step_code'">
                    <a-typography-text>{{ record.step_code }}</a-typography-text>
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
            :title="selectedStep ? 'Chỉnh sửa bước' : 'Thêm bước mới'"
            :width="500"
            :open="openDrawer"
            @close="onCloseDrawer"
            :footer-style="{ textAlign: 'right' }"
        >
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-form-item label="Số bước (STT)" name="step_number">
                    <a-input-number v-model:value="formData.step_number" min="1" style="width: 100%" />
                </a-form-item>

                <a-form-item label="Mã bước (step_code)" name="step_code">
                    <a-input v-model:value="formData.step_code" placeholder="Nhập mã step_code (VD: bidding_step_01)" />
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
    getContractStepTemplatesAPI,
    createContractStepTemplateAPI,
    updateContractStepTemplateAPI,
    deleteContractStepTemplateAPI
} from '@/api/contract-step-template'
import { getDepartments } from '@/api/department'

// ✅ Không cần contractId ở đây vì là bước mẫu
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
    step_code: '',
    department: []
})

// pagination state
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    showTotal: (total, range) => `${range[0]}-${range[1]} / ${total}`,
})

// STT liên tục theo trang
const rowNumber = (index) =>
    (pagination.value.current - 1) * pagination.value.pageSize + index + 1

// đổi trang / đổi pageSize
const onTableChange = (pag /*, filters, sorter*/) => {
    const pageSizeChanged = pag.pageSize !== pagination.value.pageSize
    pagination.value = {
        ...pagination.value,
        current: pageSizeChanged ? 1 : pag.current, // đổi size -> quay về trang 1
        pageSize: pag.pageSize,
    }
    fetchSteps()
}

// util parse department
const parseDept = (raw) => {
    if (!raw) return []
    try {
        const v = typeof raw === 'string' ? JSON.parse(raw) : raw
        return Array.isArray(v) ? v : []
    } catch { return [] }
}

const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt',  width: '60px' },
    { title: 'Bước số', dataIndex: 'step_number', key: 'step_number',  width: '100px' },
    { title: 'Mã bước', dataIndex: 'step_code', key: 'step_code', width: 300 },
    { title: 'Tên bước', dataIndex: 'title', key: 'title' },
    { title: 'Phòng ban', dataIndex: 'department', key: 'department' },
    { title: 'Hành động', dataIndex: 'action', key: 'action' }
]

const rules = {
    step_number: [{ required: true, message: 'Vui lòng nhập số bước' }],
    title: [{ required: true, message: 'Vui lòng nhập tên bước' }],
    step_code: [{ required: true, message: 'Vui lòng nhập mã bước (step_code)' }],
    department: [{ required: true, type: 'array', message: 'Vui lòng chọn ít nhất 1 phòng ban' }]
}

// Gọi API có phân trang và cập nhật total đúng cách
const fetchSteps = async () => {
    loading.value = true
    try {
        const { current, pageSize } = pagination.value

        const res = await getContractStepTemplatesAPI({
            page: current,
            per_page: pageSize,
        })

        const list = Array.isArray(res.data?.data)
            ? res.data.data
            : Array.isArray(res.data)
                ? res.data
                : []

        tableData.value = list.map(item => ({
            ...item,
            department: parseDept(item.department),
        }))

        // --- TÍNH TOTAL CHUẨN ---
        // Ưu tiên meta.pagination.total; nếu không có thì dùng res.data.total; cuối cùng fallback list.length
        const meta = res.data?.pagination
        const newTotal =
            (meta && typeof meta.total === 'number') ? meta.total
                : (typeof res.data?.total === 'number') ? res.data.total
                    : list.length

        pagination.value = {
            ...pagination.value,
            current: meta?.page ?? current,
            pageSize: meta?.per_page ?? pageSize,
            total: newTotal, // luôn cập nhật total mới
        }

        // Nếu đang ở trang vượt quá tổng trang -> đưa về trang cuối và fetch lại
        const maxPage = Math.max(1, Math.ceil(newTotal / pagination.value.pageSize))
        if (pagination.value.current > maxPage) {
            pagination.value.current = maxPage
            await fetchSteps()
            return
        }
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
    formData.value = {
        step_number: null,
        step_code: '',
        title: '',
        department: []
    }
    selectedStep.value = null
    openDrawer.value = true
}

const editStep = (record) => {
    selectedStep.value = record
    formData.value = {
        ...record,
        department: Array.isArray(record.department) ? record.department : []
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
            await updateContractStepTemplateAPI(selectedStep.value.id, payload)
            message.success('Cập nhật thành công')
        } else {
            await createContractStepTemplateAPI(payload)
            message.success('Thêm mới thành công')
        }
        await fetchSteps()
        onCloseDrawer()
    } catch (e) {
        console.error(e)
        message.error('Không thể lưu bước mẫu')
    } finally {
        loadingCreate.value = false
    }
}

const deleteStep = async (id) => {
    try {
        await deleteContractStepTemplateAPI(id)
        message.success('Đã xoá bước mẫu')
        await fetchSteps()
    } catch (e) {
        console.error(e)
        message.error('Xoá thất bại')
    }
}

const onCloseDrawer = () => {
    openDrawer.value = false
    selectedStep.value = null
    formData.value = {
        step_number: null,
        step_code: '',
        title: '',
        department: []
    }
    formRef.value?.resetFields()
}

onMounted(() => {
    fetchSteps()
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