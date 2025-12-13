<template>
    <div>
        <a-card>
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
                row-key="id"
                :pagination="pagination"
                :scroll="{ x: 1300 }"
                tableLayout="fixed"
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
                        <a-tag color="green">
                            {{ record.step_code }}
                        </a-tag>
                    </template>
                    <template v-else-if="column.dataIndex === 'title'">
                        <a-typography-text style="cursor: pointer;" @click="editStep(record)">
                            {{ record.title }}
                        </a-typography-text>
                    </template>
                    <template v-else-if="column.dataIndex === 'department'">
                        <a-space wrap>
                            <a-tag v-for="dept in record.department" :key="dept">{{ dept }}</a-tag>
                        </a-space>
                    </template>
                    <template v-else-if="column.dataIndex === 'processing_basis'">
                        <a-tooltip
                            :title="record.processing_basis || '-'"
                            :overlayStyle="{ whiteSpace: 'pre-line', maxWidth: '500px' }"
                        >
                            <a-typography-text
                                :content="record.processing_basis || '-'"
                                :ellipsis="{ showTitle: false }"
                            />
                        </a-tooltip>
                    </template>

                    <template v-else-if="column.dataIndex === 'processing_detail'">
                        <a-tooltip
                            :title="record.processing_detail || '-'"
                            :overlayStyle="{ whiteSpace: 'pre-line', maxWidth: '600px' }"
                        >
                            <a-typography-text
                                :content="record.processing_detail || '-'"
                                :ellipsis="{ showTitle: false }"
                            />
                        </a-tooltip>
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
        </a-card>

        <a-drawer
            :title="selectedStep ? 'Chỉnh sửa bước mẫu' : 'Thêm bước mẫu'"
            :width="700"
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
                <a-form-item
                    label="Thông tin, chứng từ là căn cứ xử lý"
                    name="processing_basis"
                >
                    <a-textarea
                        v-model:value="formData.processing_basis"
                        :rows="7"
                        placeholder="Nhập thông tin, chứng từ làm căn cứ xử lý"
                        show-count
                        :maxlength="1000"
                    />
                </a-form-item>

                <a-form-item
                    label="Nội dung xử lý chi tiết"
                    name="processing_detail"
                >
                    <a-textarea
                        v-model:value="formData.processing_detail"
                        :rows="7"
                        placeholder="Nhập nội dung xử lý chi tiết"
                        show-count
                        :maxlength="2000"
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
    step_code: '',
    title: '',
    department: [],
    processing_basis: '',
    processing_detail: ''
})

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    showTotal: (total, range) => `${range[0]}-${range[1]} / ${total}`
})

const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: 50, 'align': 'center'},
    { title: 'Bước số', dataIndex: 'step_number', key: 'step_number', width: 80, 'align': 'center' },
    { title: 'Mã bước', dataIndex: 'step_code', key: 'step_code', width: 100, 'align': 'center' },
    { title: 'Tên bước', dataIndex: 'title', key: 'title',  width: 180 },
    {
        title: 'Căn cứ xử lý',
        dataIndex: 'processing_basis',
        key: 'processing_basis',
        ellipsis: { showTitle: true },
        width: 150
    },
    {
        title: 'Nội dung xử lý',
        dataIndex: 'processing_detail',
        key: 'processing_detail',
        ellipsis: { showTitle: true },
        width: 150
    },
    { title: 'Phòng ban', dataIndex: 'department', key: 'department', width: 100},
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: 100, 'align': 'center' },
]

const rules = {
    step_number: [{ required: true, message: 'Vui lòng nhập số bước' }],
    step_code: [{ required: true, message: 'Vui lòng nhập mã bước' }],
    title: [{ required: true, message: 'Vui lòng nhập tên bước' }],
    department: [{ required: true, type: 'array', message: 'Chọn ít nhất 1 phòng ban' }],
    processing_basis: [{ required: true, message: 'Vui lòng nhập căn cứ xử lý' }],
    processing_detail: [{ required: true, message: 'Vui lòng nhập nội dung xử lý' }]
}


const rowNumber = (index) =>
    (pagination.value.current - 1) * pagination.value.pageSize + index + 1


const onTableChange = (pag) => {
    pagination.value = { ...pagination.value, ...pag }
    fetchStepTemplates()
}

const parseDept = (raw) => {
    if (!raw) return []
    try {
        const parsed = typeof raw === 'string' ? JSON.parse(raw) : raw
        return Array.isArray(parsed) ? parsed : []
    } catch {
        return []
    }
}

const fetchStepTemplates = async () => {
    loading.value = true
    try {
        const { current, pageSize } = pagination.value

        const res = await getStepTemplatesAPI({
            page: current,
            per_page: pageSize,
        })

        const list = Array.isArray(res.data?.data)
            ? res.data.data
            : []

        tableData.value = list.map(item => ({
            ...item,
            department: parseDept(item.department),
        }))

        const meta = res.data?.pagination
        if (meta) {
            pagination.value = {
                ...pagination.value,
                pageSize: meta.per_page ?? pageSize,
                total: meta.total ?? pagination.value.total,
                // ❌ TUYỆT ĐỐI KHÔNG SET current Ở ĐÂY
            }
        }
    } catch (err) {
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
    formData.value = {
        step_number: null,
        step_code: '',
        title: '',
        department: []
    }
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