<template>
    <div>
        <a-page-header title="Quản lý khách hàng" />

        <!-- Bộ lọc -->
        <a-form layout="inline" @submit.prevent>
            <a-row :gutter="16" style="margin-bottom: 16px">
                <a-col :span="4">
                    <a-input v-model:value="filters.search" placeholder="Tên, sđt hoặc email" allow-clear />
                </a-col>
                <a-col :span="4">
                    <a-select v-model:value="filters.customer_group" placeholder="Nhóm khách hàng" allow-clear>
                        <a-select-option value="vip">VIP</a-select-option>
                        <a-select-option value="regular">Đối tác thường</a-select-option>
                    </a-select>
                </a-col>
                <a-col :span="6">
                    <a-range-picker v-model:value="filters.dateRange" style="width: 100%" />
                </a-col>
                <a-col :span="3">
                    <a-input-number v-model:value="filters.assigned_to" :min="1" placeholder="Người phụ trách ID" style="width: 100%" />
                </a-col>
                <a-col :span="3">
                    <a-button type="primary" @click="fetchCustomers">Tìm kiếm</a-button>
                </a-col>
                <a-col :span="4" style="text-align: right">
                    <a-button type="primary" @click="showPopupCreate">Thêm khách hàng</a-button>
                </a-col>
            </a-row>
        </a-form>

        <a-table
            :columns="columns"
            :data-source="customers"
            :loading="loading"
            row-key="id"
            :pagination="pagination"
            @change="handleTableChange"
            :scroll="{ y: 'calc( 100vh - 330px )' }"
        >
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.key === 'stt'">
                    {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
                </template>
                <template v-else-if="column.key === 'avatar'">
                    <img v-if="record.avatar" :src="record.avatar" alt="avatar" style="width: 50px; height: 50px; object-fit: cover" />
                </template>
                <template v-else-if="column.key === 'name'">
                    <a-typography-text strong style="cursor: pointer" @click="showPopupDetail(record)">{{ text }}</a-typography-text>
                </template>
                <template v-else-if="column.key === 'action'">
                    <a-dropdown placement="left">
                        <a-button>
                            <template #icon>
                                <MoreOutlined />
                            </template>
                        </a-button>
                        <template #overlay>
                            <a-menu>
                                <a-menu-item @click="showPopupDetail(record)">
                                    <EditOutlined class="icon-action" style="color: blue;" />
                                    Chỉnh sửa
                                </a-menu-item>
                                <a-menu-item>
                                    <a-popconfirm
                                        title="Bạn chắc chắn muốn xóa khách hàng này?"
                                        ok-text="Xóa"
                                        cancel-text="Hủy"
                                        @confirm="deleteConfirm(record.id)"
                                        placement="topRight"
                                    >
                                        <div>
                                            <DeleteOutlined class="icon-action" style="color: red;" />
                                            Xóa
                                        </div>
                                    </a-popconfirm>
                                </a-menu-item>
                            </a-menu>
                        </template>
                    </a-dropdown>
                </template>
            </template>
        </a-table>

        <!-- Drawer -->
        <a-drawer
            :title="selectedCustomer ? 'Cập nhật khách hàng' : 'Tạo khách hàng mới'"
            :width="700"
            :open="openDrawer"
            :body-style="{ paddingBottom: '80px' }"
            :footer-style="{ textAlign: 'right' }"
            @close="onCloseDrawer"
        >
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Tên khách hàng" name="name">
                            <a-input v-model:value="formData.name" placeholder="Nhập tên khách hàng" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Email" name="email">
                            <a-input v-model:value="formData.email" placeholder="Nhập Email" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Số điện thoại" name="phone">
                            <a-input v-model:value="formData.phone" placeholder="Nhập số điện thoại" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Địa chỉ" name="address">
                            <a-input v-model:value="formData.address" placeholder="Nhập địa chỉ" />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>

            <!-- Interaction History -->
            <a-divider>Nhật ký tương tác</a-divider>
            <a-list
                :data-source="interactionLogs"
                bordered
                :locale="{ emptyText: 'Không có tương tác' }"
                style="margin-bottom: 16px"
            >
                <template #renderItem="{ item }">
                    <a-list-item>
                        <a-list-item-meta
                            :title="`${item.type ? item.type.toUpperCase() : 'N/A'} - ${formatDate(item.interaction_time)}`"
                            :description="item.content"
                        />
                    </a-list-item>
                </template>
            </a-list>

            <!-- New Interaction Form -->
            <a-form layout="vertical" :model="interactionForm">
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Loại tương tác">
                            <a-select v-model:value="interactionForm.type" placeholder="Chọn loại tương tác">
                                <a-select-option value="call">Gọi điện</a-select-option>
                                <a-select-option value="email">Email</a-select-option>
                                <a-select-option value="meeting">Gặp mặt</a-select-option>
                            </a-select>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Thời gian tương tác">
                            <a-date-picker show-time style="width: 100%" v-model:value="interactionForm.interaction_time" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-form-item label="Nội dung">
                    <a-textarea v-model:value="interactionForm.content" :rows="3" placeholder="Nhập nội dung tương tác" />
                </a-form-item>
                <a-button type="primary" block @click="submitInteraction">Ghi nhận tương tác</a-button>
            </a-form>

            <!-- Contracts List -->
            <a-divider>Danh sách hợp đồng</a-divider>
            <a-list
                :data-source="contracts"
                bordered
                :locale="{ emptyText: 'Chưa có hợp đồng nào' }"
            >
                <template #renderItem="{ item }">
                    <a-list-item>
                        <a-list-item-meta
                            :title="item.title"
                            :description="`Trạng thái: ${item.status} | Từ ${formatDate(item.start_date)} đến ${formatDate(item.end_date)}`"
                        />
                        <div>{{ item.content }}</div>
                    </a-list-item>
                </template>
            </a-list>

            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" @click="submitForm" :loading="loadingCreate">{{ selectedCustomer ? 'Cập nhật' : 'Thêm mới' }}</a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import { getCustomers, getCustomer, createCustomer, updateCustomer, deleteCustomer, getCustomerTransactions, createCustomerTransaction, getCustomerContracts } from '@/api/customer'
import { EditOutlined, DeleteOutlined, MoreOutlined } from '@ant-design/icons-vue'
import { formatDate, formatDateForSave  } from '@/utils/formUtils'

const customers = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)
const formRef = ref(null)
const selectedCustomer = ref(null)


const interactionLogs = ref([])
const contracts = ref([])

const interactionForm = ref({
    type: '',
    content: '',
    interaction_time: null
})
const lastInteraction = ref('')

const filters = ref({
    search: '',
    customer_group: undefined,
    dateRange: [],
    assigned_to: undefined
})

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    pageSizeOptions: ['10', '20', '50', '100']
})

const formData = ref({
    name: '',
    email: '',
    phone: '',
    address: ''
})

const rules = computed(() => ({
    name: [{ required: true, message: 'Vui lòng nhập tên khách hàng', trigger: 'blur' }],
    email: [{ required: true, message: 'Vui lòng nhập email', trigger: 'blur' }],
    phone: [{ required: true, message: 'Vui lòng nhập số điện thoại', trigger: 'blur' }]
}))

const columns = [
    { title: 'STT', key: 'stt' },
    // { title: 'Avatar', key: 'avatar', dataIndex: 'avatar' },
    { title: 'Tên khách hàng', key: 'name', dataIndex: 'name' },
    { title: 'Email', key: 'email', dataIndex: 'email' },
    { title: 'SĐT', key: 'phone', dataIndex: 'phone' },
    { title: 'Địa chỉ', key: 'address', dataIndex: 'address' },
    { title: 'Tỉnh/TP', key: 'city', dataIndex: 'city' },
    { title: 'Ngày tương tác mới nhất', key: 'last_interaction', dataIndex: 'last_interaction', customRender: ({ text }) => formatDate(text)},
    { title: 'Thao tác', key: 'action' }
]

const fetchCustomers = async () => {
    loading.value = true
    try {
        const params = {
            search: filters.value.search,
            customer_group: filters.value.customer_group,
            assigned_to: filters.value.assigned_to,
            from: filters.value.dateRange?.[0] ? dayjs(filters.value.dateRange[0]).format('YYYY-MM-DD') : undefined,
            to: filters.value.dateRange?.[1] ? dayjs(filters.value.dateRange[1]).format('YYYY-MM-DD') : undefined,
            per_page: pagination.value.pageSize,
            page: pagination.value.current
        }
        const res = await getCustomers(params)
        customers.value = res.data.data
        pagination.value.total = res.data.total
    } catch (err) {
        message.error('Không thể tải danh sách khách hàng')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (pag) => {
    pagination.value.current = pag.current
    pagination.value.pageSize = pag.pageSize
    fetchCustomers()
}

const showPopupCreate = () => {
    resetForm()
    selectedCustomer.value = null
    openDrawer.value = true
    interactionLogs.value = []
    contracts.value = []
}

const showPopupDetail = async (record) => {
    selectedCustomer.value = record
    formData.value = {
        name: record.name,
        email: record.email,
        phone: record.phone,
        address: record.address
    }
    openDrawer.value = true
    await fetchInteractionLogs(record.id)
    await fetchContracts(record.id)
}

const submitForm = async () => {
    try {
        await formRef.value.validate()
        loadingCreate.value = true
        if (selectedCustomer.value) {
            await updateCustomer(selectedCustomer.value.id, formData.value)
            message.success('Cập nhật thành công')
        } else {
            await createCustomer(formData.value)
            message.success('Tạo mới thành công')
        }
        fetchCustomers()
        onCloseDrawer()
    } catch (err) {
        message.error('Xử lý không thành công')
    } finally {
        loadingCreate.value = false
    }
}

const deleteConfirm = async (id) => {
    try {
        await deleteCustomer(id)
        message.success('Đã xoá khách hàng')
        fetchCustomers()
    } catch (err) {
        message.error('Không thể xoá khách hàng')
    }
}

const submitInteraction = async () => {
    if (!selectedCustomer.value) return
    try {
        const payload = {
            customer_id: selectedCustomer.value.id,
            type: interactionForm.value.type,
            content: interactionForm.value.content,
            interaction_time: formatDateForSave(interactionForm.value.interaction_time),
            created_by: 2 // có thể thay bằng user hiện tại
        }
        await createCustomerTransaction(payload)
        message.success('Đã ghi nhận tương tác')
        await fetchInteractionLogs(selectedCustomer.value.id)
        await refreshCustomerData(selectedCustomer.value.id) // ✅ Cập nhật bảng chính
        interactionForm.value = { type: '', content: '', interaction_time: null }
    } catch (err) {
        message.error('Lỗi khi ghi nhận tương tác')
    }
}

const fetchInteractionLogs = async (customerId) => {
    try {
        const res = await getCustomerTransactions(customerId)
        interactionLogs.value = res.data
        if (res.data.length > 0) {
            lastInteraction.value = formatDate(res.data[0].interaction_time)
        }
    } catch (err) {
        interactionLogs.value = []
    }
}

const refreshCustomerData = async (customerId) => {
    try {
        const res = await getCustomers({ search: '', page: 1, per_page: 1000 }) // hoặc endpoint riêng nếu có
        const updated = res.data.data.find(c => c.id === customerId)
        if (updated) {
            selectedCustomer.value.last_interaction = formatDateForSave(updated.last_interaction)
        }
    } catch (err) {
        console.warn('Không thể cập nhật lại thông tin khách hàng')
    }
}

const fetchContracts = async (customerId) => {
    try {
        const res = await getCustomerContracts(customerId)
        contracts.value = Array.isArray(res.data) ? res.data : []
    } catch (err) {
        contracts.value = []
    }
}


const resetForm = () => {
    formData.value = {
        name: '',
        email: '',
        phone: '',
        address: ''
    }
    formRef.value?.resetFields()
}

const onCloseDrawer = () => {
    openDrawer.value = false
    resetForm()
    selectedCustomer.value = null
    interactionLogs.value = []
    contracts.value = []
    interactionForm.value = { type: '', content: '', interaction_time: null }
}

onMounted(() => {
    fetchCustomers()
})
</script>