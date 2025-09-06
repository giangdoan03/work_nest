<template>
    <div>
        <a-card bordered title="Quản lý khách hàng">
            <!-- Toolbar -->
            <div class="card-title">
                <div class="toolbar">
                    <a-input
                        v-model:value="filters.search"
                        allow-clear
                        style="width: 260px"
                        placeholder="Tìm tên, SĐT hoặc email…"
                    >
                        <template #prefix><SearchOutlined /></template>
                    </a-input>

                    <a-select v-model:value="filters.customer_group" placeholder="Nhóm khách hàng" allow-clear style="width: 180px">
                        <a-select-option value="vip">VIP</a-select-option>
                        <a-select-option value="regular">Đối tác thường</a-select-option>
                    </a-select>

                    <a-range-picker
                        v-model:value="filters.dateRange"
                        style="width: 260px"
                        :getPopupContainer="node => node.parentNode"
                    />

                    <a-select
                        v-model:value="filters.assigned_to"
                        :options="userOptions"
                        placeholder="Người phụ trách"
                        allow-clear
                        show-search
                        option-filter-prop="label"
                        style="width: 220px"
                    >
                        <template #suffixIcon><TeamOutlined /></template>
                    </a-select>

                    <a-segmented
                        v-model:value="density"
                        :options="[
              { label: 'Gọn', value: 'small' },
              { label: 'Vừa', value: 'middle' },
              { label: 'Rộng', value: 'large' }
            ]"
                    />

                    <a-popover trigger="click" placement="bottomRight">
                        <a-button :icon="h(SettingOutlined)">Cột</a-button>
                        <template #content>
                            <a-checkbox-group v-model:value="visibleCols" :options="columnToggles" />
                        </template>
                    </a-popover>

                    <a-button :icon="h(DownloadOutlined)" @click="exportCSV" :loading="exporting">Export CSV</a-button>

                    <a-tooltip title="Làm mới">
                        <a-button :loading="loading" @click="fetchCustomers" :icon="h(ReloadOutlined)" />
                    </a-tooltip>

                    <a-button type="primary" :icon="h(PlusOutlined)" @click="showPopupCreate">Thêm khách hàng</a-button>
                </div>
            </div>

            <!-- Bulk actions -->
            <div class="bulkbar">
                <a-button
                    type="primary"
                    danger
                    :disabled="selectedRowKeys.length === 0"
                    @click="handleBulkDelete"
                >
                    Xóa {{ selectedRowKeys.length }} khách hàng
                </a-button>
                <a-button @click="fetchCustomers" type="default">Tìm kiếm</a-button>
            </div>

            <!-- Table -->
            <a-table
                :columns="columns"
                :data-source="customers"
                :loading="loading"
                :size="density"
                row-key="id"
                bordered
                :pagination="pagination"
                @change="handleTableChange"
                :scroll="{ x: 'max-content', y: 'calc(100vh - 420px)' }"
                :row-selection="rowSelection"
            >
                <template #bodyCell="{ column, record, index, text }">
                    <!-- STT -->
                    <template v-if="column.key === 'stt'">
                        {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
                    </template>

                    <!-- Tên -->
                    <template v-else-if="column.key === 'name'">
                        <a-typography-text strong class="link" @click="showPopupDetail(record)">
                            {{ text }}
                        </a-typography-text>
                    </template>

                    <!-- Nhóm -->
                    <template v-else-if="column.key === 'group'">
                        <a-tag :color="record.customer_group === 'vip' ? 'gold' : 'default'">
                            {{ record.customer_group === 'vip' ? 'VIP' : 'Đối tác thường' }}
                        </a-tag>
                    </template>

                    <!-- Email / Địa chỉ -->
                    <template v-else-if="column.key === 'email'">
                        <a-tooltip :title="text"><span class="ellipsis-1">{{ text }}</span></a-tooltip>
                    </template>
                    <template v-else-if="column.key === 'address'">
                        <a-tooltip :title="text"><span class="ellipsis-1">{{ text }}</span></a-tooltip>
                    </template>

                    <!-- Người phụ trách -->
                    <template v-else-if="column.key === 'assigned_to'">
                        <a-tag color="blue">{{ getUserName(record.assigned_to) }}</a-tag>
                    </template>

                    <!-- Lần tương tác gần nhất -->
                    <template v-else-if="column.key === 'last_interaction'">
                        <span :title="formatDate(text)">{{ fromNow(text) }}</span>
                    </template>

                    <!-- Action -->
                    <template v-else-if="column.key === 'action'">
                        <a-dropdown trigger="click" placement="bottomRight">
                            <a-button type="text" :icon="h(MoreOutlined)" @click.stop />
                            <template #overlay>
                                <a-menu>
                                    <a-menu-item key="view" @click="(info) => onView(info, record)">
                                        <EyeOutlined class="mr-6" /> Xem chi tiết
                                    </a-menu-item>
                                    <a-menu-item key="edit" @click="(info) => onEdit(info, record)">
                                        <EditOutlined class="mr-6" /> Sửa
                                    </a-menu-item>
                                    <a-menu-item key="delete" danger @click="(info) => onDelete(info, record)">
                                        <DeleteOutlined class="mr-6" /> Xóa
                                    </a-menu-item>
                                </a-menu>
                            </template>
                        </a-dropdown>
                    </template>
                </template>
            </a-table>
        </a-card>

        <!-- Drawer -->
        <a-drawer
            :title="selectedCustomer ? 'Cập nhật khách hàng' : 'Tạo khách hàng mới'"
            :width="820"
            :open="openDrawer"
            :body-style="{ paddingBottom: '80px' }"
            @close="onCloseDrawer"
        >
            <a-tabs v-model:activeKey="activeTab" animated>
                <!-- Tab: Thông tin -->
                <a-tab-pane key="info" tab="Thông tin">
                    <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="Tên khách hàng" name="name" has-feedback>
                                    <a-input v-model:value="formData.name" placeholder="Nhập tên khách hàng" />
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item label="Người phụ trách" name="assigned_to" has-feedback>
                                    <a-select
                                        v-model:value="formData.assigned_to"
                                        :options="userOptions"
                                        placeholder="Chọn người phụ trách"
                                        show-search
                                        :filter-option="(i, opt) => (opt?.label||'').toLowerCase().includes(i.toLowerCase())"
                                    />
                                </a-form-item>
                            </a-col>
                        </a-row>

                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="Email" name="email" has-feedback>
                                    <a-input v-model:value="formData.email" placeholder="Nhập email" />
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item label="Số điện thoại" name="phone" has-feedback>
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
                </a-tab-pane>

                <!-- Tab: Tương tác -->
                <a-tab-pane key="interactions" tab="Tương tác">
                    <a-list
                        :data-source="interactionLogs"
                        bordered
                        :locale="{ emptyText: 'Không có tương tác' }"
                        style="margin-bottom: 12px"
                    >
                        <template #renderItem="{ item }">
                            <a-list-item>
                                <a-list-item-meta
                                    :title="`${(item.type||'').toUpperCase()} • ${formatDate(item.interaction_time)}`"
                                    :description="item.content"
                                />
                            </a-list-item>
                        </template>
                    </a-list>

                    <a-form layout="vertical" :model="interactionForm">
                        <a-row :gutter="16">
                            <a-col :span="10">
                                <a-form-item label="Loại tương tác">
                                    <a-select v-model:value="interactionForm.type" placeholder="Chọn loại">
                                        <a-select-option value="call">Gọi điện</a-select-option>
                                        <a-select-option value="email">Email</a-select-option>
                                        <a-select-option value="meeting">Gặp mặt</a-select-option>
                                    </a-select>
                                </a-form-item>
                            </a-col>
                            <a-col :span="14">
                                <a-form-item label="Thời gian">
                                    <a-date-picker show-time style="width: 100%" v-model:value="interactionForm.interaction_time" />
                                </a-form-item>
                            </a-col>
                        </a-row>
                        <a-form-item label="Nội dung">
                            <a-textarea v-model:value="interactionForm.content" :rows="3" placeholder="Nhập nội dung tương tác" />
                        </a-form-item>
                        <a-button type="primary" block @click="submitInteraction">Ghi nhận tương tác</a-button>
                    </a-form>
                </a-tab-pane>

                <!-- Tab: Hợp đồng -->
                <a-tab-pane key="contracts" tab="Hợp đồng">
                    <a-list :data-source="contracts" bordered :locale="{ emptyText: 'Chưa có hợp đồng nào' }">
                        <template #renderItem="{ item }">
                            <a-list-item>
                                <a-list-item-meta
                                    :title="item.title"
                                    :description="`Trạng thái: ${item.status} • ${formatDate(item.start_date)} → ${formatDate(item.end_date)}`"
                                />
                                <div>{{ item.content }}</div>
                            </a-list-item>
                        </template>
                    </a-list>
                </a-tab-pane>
            </a-tabs>

            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" :loading="loadingCreate" @click="submitForm">
                        {{ selectedCustomer ? 'Cập nhật' : 'Thêm mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { computed, h, onMounted, ref } from 'vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/vi'
import { useRouter } from 'vue-router'
import { message, Modal } from 'ant-design-vue'
import {
    createCustomer,
    createCustomerTransaction,
    deleteCustomer,
    getCustomerContracts,
    getCustomers,
    getCustomerTransactions,
    updateCustomer
} from '@/api/customer'
import { getUsers } from '@/api/user'
import {
    DeleteOutlined,
    DownloadOutlined,
    EditOutlined,
    EyeOutlined,
    MoreOutlined,
    PlusOutlined,
    ReloadOutlined,
    SearchOutlined,
    SettingOutlined,
    TeamOutlined
} from '@ant-design/icons-vue'
import { formatDate, formatDateForSave } from '@/utils/formUtils'

dayjs.extend(relativeTime); dayjs.locale('vi')

/* ===== State ===== */
const router = useRouter()
const customers = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const exporting = ref(false)

const openDrawer = ref(false)
const activeTab = ref('info')
const selectedCustomer = ref(null)
const formRef = ref(null)

const density = ref('middle') // small | middle | large

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
    pageSizeOptions: ['10','20','50','100'],
    showTotal: (total, range) => `${range[0]}–${range[1]} / ${total} khách hàng`
})

/* ===== Row selection ===== */
const selectedRowKeys = ref([])
const selectedRows = ref([])
const rowSelection = computed(() => ({
    selectedRowKeys: selectedRowKeys.value,
    onChange: (keys, rows) => { selectedRowKeys.value = keys; selectedRows.value = rows }
}))

/* ===== Users for assignee ===== */
const userOptions = ref([])
const getUserName = (id) => (userOptions.value.find(u => u.value === Number(id))?.label) || 'Không rõ'

/* ===== Columns visibility ===== */
const visibleCols = ref(['group','email','phone','address','city','assigned_to','last_interaction'])
const columnToggles = [
    { label: 'Nhóm', value: 'group' },
    { label: 'Email', value: 'email' },
    { label: 'SĐT', value: 'phone' },
    { label: 'Địa chỉ', value: 'address' },
    { label: 'Tỉnh/TP', value: 'city' },
    { label: 'Người phụ trách', value: 'assigned_to' },
    { label: 'Lần tương tác gần nhất', value: 'last_interaction' }
]

const columns = computed(() => {
    return [
        { title: 'STT', key: 'stt', width: 70, align: 'center', fixed: 'left' },
        { title: 'Tên khách hàng', key: 'name', dataIndex: 'name', width: 240, ellipsis: true },
        visibleCols.value.includes('group') && { title: 'Nhóm', key: 'group', dataIndex: 'customer_group', width: 140, align: 'center' },
        visibleCols.value.includes('email') && { title: 'Email', key: 'email', dataIndex: 'email', width: 220 },
        visibleCols.value.includes('phone') && { title: 'SĐT', key: 'phone', dataIndex: 'phone', width: 140 },
        visibleCols.value.includes('address') && { title: 'Địa chỉ', key: 'address', dataIndex: 'address', width: 260 },
        visibleCols.value.includes('city') && { title: 'Tỉnh/TP', key: 'city', dataIndex: 'city', width: 140 },
        visibleCols.value.includes('assigned_to') && { title: 'Người phụ trách', key: 'assigned_to', dataIndex: 'assigned_to', width: 180 },
        visibleCols.value.includes('last_interaction') && { title: 'Ngày tương tác mới nhất', key: 'last_interaction', dataIndex: 'last_interaction', align: 'center', width: 200 },
        { title: 'Thao tác', key: 'action', width: 90, align: 'center', fixed: 'right' }
    ].filter(Boolean)
})

/* ===== Drawer forms ===== */
const formData = ref({
    name: '', email: '', phone: '', address: '', assigned_to: undefined
})
const rules = computed(() => ({
    name: [{ required: true, message: 'Vui lòng nhập tên khách hàng', trigger: ['blur','change'] }],
    email: [{ required: true, message: 'Vui lòng nhập email', trigger: ['blur','change'] }],
    phone: [{ required: true, message: 'Vui lòng nhập số điện thoại', trigger: ['blur','change'] }],
    assigned_to: [{ required: true, message: 'Vui lòng chọn người phụ trách', trigger: ['blur','change'] }],
}))

/* ===== Interactions / Contracts ===== */
const interactionLogs = ref([])
const interactionForm = ref({ type: '', content: '', interaction_time: null })
const contracts = ref([])

/* ===== Utils ===== */
const fromNow = (v) => v ? dayjs(v).fromNow() : '—'

/* ===== Menu handlers (fix stopPropagation) ===== */
const onView = (info, record) => {
    info?.domEvent?.stopPropagation()
    goToCustomerDetail(record)
}
const onEdit = (info, record) => {
    info?.domEvent?.stopPropagation()
    showPopupDetail(record)
}
const onDelete = (info, record) => {
    info?.domEvent?.stopPropagation()
    Modal.confirm({
        title: 'Xóa khách hàng?',
        content: `Bạn chắc chắn muốn xóa “${record?.name || 'khách hàng'}”?`,
        okText: 'Xóa',
        okType: 'danger',
        cancelText: 'Hủy',
        async onOk() {
            try {
                await deleteCustomer(record.id)
                message.success('Đã xoá khách hàng')
                fetchCustomers()
            } catch {
                message.error('Không thể xoá khách hàng')
            }
        }
    })
}

/* ===== Fetchers ===== */
const fetchCustomers = async () => {
    loading.value = true
    try {
        const params = {
            search: filters.value.search,
            group: filters.value.customer_group,
            assigned_to: filters.value.assigned_to,
            from: filters.value.dateRange?.[0] ? dayjs(filters.value.dateRange[0]).format('YYYY-MM-DD') : undefined,
            to: filters.value.dateRange?.[1] ? dayjs(filters.value.dateRange[1]).format('YYYY-MM-DD') : undefined,
            per_page: pagination.value.pageSize,
            page: pagination.value.current
        }
        const res = await getCustomers(params)
        const { data, pager } = res?.data || {}
        customers.value = Array.isArray(data) ? data : []
        if (pager) {
            pagination.value.total = Number(pager.total) || 0
            pagination.value.current = Number(pager.current_page) || 1
            pagination.value.pageSize = Number(pager.per_page) || pagination.value.pageSize
        }
    } catch {
        message.error('Không thể tải danh sách khách hàng')
    } finally {
        loading.value = false
    }
}

const getUser = async () => {
    try {
        const res = await getUsers()
        userOptions.value = (res?.data || []).map(u => ({ label: u.name, value: Number(u.id) }))
    } catch {
        // silent
    }
}

const fetchInteractionLogs = async (customerId) => {
    try {
        const res = await getCustomerTransactions(customerId)
        interactionLogs.value = res?.data || []
    } catch { interactionLogs.value = [] }
}

const fetchContracts = async (customerId) => {
    try {
        const res = await getCustomerContracts(customerId)
        contracts.value = Array.isArray(res?.data?.data) ? res.data.data : []
    } catch { contracts.value = [] }
}

/* ===== Table handlers ===== */
const handleTableChange = (pag) => {
    pagination.value.current = pag.current
    pagination.value.pageSize = pag.pageSize
    fetchCustomers()
}

/* ===== Bulk delete ===== */
const handleBulkDelete = async () => {
    try {
        await Promise.all(selectedRowKeys.value.map(id => deleteCustomer(id)))
        message.success(`Đã xoá ${selectedRowKeys.value.length} khách hàng`)
        selectedRowKeys.value = []
        fetchCustomers()
    } catch { message.error('Không thể xoá hàng loạt khách hàng') }
}

/* ===== Drawer actions ===== */
const showPopupCreate = () => {
    resetForm()
    selectedCustomer.value = null
    interactionLogs.value = []
    contracts.value = []
    activeTab.value = 'info'
    openDrawer.value = true
}

const showPopupDetail = async (record) => {
    selectedCustomer.value = record
    formData.value = {
        name: record.name || '',
        email: record.email || '',
        phone: record.phone || '',
        address: record.address || '',
        assigned_to: record.assigned_to ? Number(record.assigned_to) : undefined
    }
    openDrawer.value = true
    activeTab.value = 'info'
    await fetchInteractionLogs(record.id)
    await fetchContracts(record.id)
}

const submitForm = async () => {
    try {
        await formRef.value?.validate?.()
        loadingCreate.value = true
        if (selectedCustomer.value) {
            await updateCustomer(selectedCustomer.value.id, formData.value)
            message.success('Cập nhật thành công')
        } else {
            await createCustomer(formData.value)
            message.success('Tạo mới thành công')
        }
        await fetchCustomers()
        onCloseDrawer()
    } catch {
        message.error('Xử lý không thành công')
    } finally {
        loadingCreate.value = false
    }
}

const onCloseDrawer = () => {
    openDrawer.value = false
    resetForm()
    selectedCustomer.value = null
    interactionLogs.value = []
    contracts.value = []
    interactionForm.value = { type: '', content: '', interaction_time: null }
}

const resetForm = () => {
    formData.value = { name: '', email: '', phone: '', address: '', assigned_to: undefined }
    formRef.value?.resetFields?.()
}

/* ===== Interaction submit ===== */
const submitInteraction = async () => {
    if (!selectedCustomer.value) return
    try {
        const payload = {
            customer_id: selectedCustomer.value.id,
            type: interactionForm.value.type,
            content: interactionForm.value.content,
            interaction_time: formatDateForSave(interactionForm.value.interaction_time),
        }
        await createCustomerTransaction(payload)
        message.success('Đã ghi nhận tương tác')
        await fetchInteractionLogs(selectedCustomer.value.id)
        await fetchCustomers() // cập nhật last_interaction
        interactionForm.value = { type: '', content: '', interaction_time: null }
        activeTab.value = 'interactions'
    } catch { message.error('Lỗi khi ghi nhận tương tác') }
}

/* ===== Navigate detail page ===== */
const goToCustomerDetail = (record) => {
    router.push({ name: 'customer-detail', params: { id: String(record.id) } })
}

/* ===== Export CSV ===== */
const exportCSV = async () => {
    try {
        exporting.value = true
        const rows = customers.value || []
        const headers = ['Tên', 'Email', 'SĐT', 'Địa chỉ', 'Tỉnh/TP', 'Nhóm', 'Người phụ trách', 'Lần tương tác gần nhất']
        const csv = [
            headers.join(','),
            ...rows.map(r => ([
                safe(r.name), safe(r.email), safe(r.phone), safe(r.address), safe(r.city),
                safe(r.customer_group), safe(getUserName(r.assigned_to)), safe(formatDate(r.last_interaction))
            ].join(',')))
        ].join('\n')
        const blob = new Blob([`\uFEFF${csv}`], { type: 'text/csv;charset=utf-8;' })
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url; a.download = `customers_${dayjs().format('YYYYMMDD_HHmmss')}.csv`
        a.click(); URL.revokeObjectURL(url)
        message.success('Đã xuất CSV')
    } catch { message.error('Không thể xuất CSV') }
    finally { exporting.value = false }
}
const safe = (v) => {
    const s = (v ?? '').toString().replace(/"/g, '""')
    return `"${s}"`
}

/* ===== Init ===== */
onMounted(() => {
    fetchCustomers()
    getUser()
})
</script>

<style scoped>
.card-title{
    display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:8px;
}
.toolbar{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.bulkbar{ display:flex; justify-content:space-between; align-items:center; gap:8px; margin:12px 0; }

.link{ cursor:pointer; color: var(--brand, #1677ff); }
.link:hover{ text-decoration: underline; }

.mr-6{ margin-right:6px; }
.ellipsis-1{ display:inline-block; max-width: 260px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
:deep(.ant-pagination){ margin-bottom: 0 !important; }
</style>
