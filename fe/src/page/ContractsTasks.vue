<template>
    <div>
        <a-card bordere>
            <!-- Header + Search + Badge -->
            <a-flex justify="space-between" align="center" style="margin-bottom:10px">
                <div style="display:flex;align-items:center;gap:8px;">
                    <a-typography-title :level="4" style="margin:0">Danh sách hợp đồng</a-typography-title>
                    <a-badge :count="totalDisplay" show-zero/>
                </div>
                <a-space>
                    <a-input
                        v-model:value="searchTerm"
                        allow-clear
                        style="width:320px"
                        placeholder="Tìm hợp đồng theo tên/mã…"
                    >
                        <template #prefix>
                            <SearchOutlined/>
                        </template>
                    </a-input>
                    <a-button type="primary" @click="showPopupCreate">Thêm hợp đồng mới</a-button>
                </a-space>
            </a-flex>

            <!-- Summary cards -->
            <div class="summary-cards">
                <a-card
                    v-for="item in statsContracts"
                    :key="item.key"
                    :style="{ backgroundColor: item.bg, cursor:'pointer' }"
                    @click="openContractDrawer(item.key,item.label)"
                >
                    <a-space direction="vertical" align="center">
                        <component :is="item.icon" :style="{fontSize:'32px',color:item.color}"/>
                        <div>{{ item.label }}</div>
                        <h2 class="number" :style="{ color: item.color }">{{ item.count }}</h2>
                    </a-space>
                </a-card>
            </div>

            <!-- Bulk actions -->
            <a-flex justify="space-between" align="center" style="margin-top:12px">
                <div>
                    <a-space>
                        <a-button danger v-if="selectedRowKeys.length" @click="handleBulkDelete">
                            Xóa {{ selectedRowKeys.length }} hợp đồng
                        </a-button>
                    </a-space>
                </div>
            </a-flex>

            <!-- Table -->
            <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                row-key="id"
                :pagination="pagination"
                :row-selection="rowSelection"
                :scroll="{ x: 'max-content'}"
                style="margin-top:4px"
                @change="handleTableChange"
            >
                <template #bodyCell="{ column, record, index }">
                    <template v-if="column.dataIndex === 'stt'">
                        {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
                    </template>

                    <template v-else-if="column.key === 'name'">
                        <a-tooltip :title="record.name">
                            <a-typography-text strong style="cursor:pointer" @click="goToContractDetail(record.id)">
                                {{ truncateText(record.name, 25) }}
                            </a-typography-text>
                        </a-tooltip>
                    </template>

                    <!-- ✅ NEW: progress -->
                    <template v-else-if="column.dataIndex === 'progress'">
                        <a-tooltip :title="progressText(record)">
                            <a-progress
                                :percent="progressPercent(record)"
                                :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"
                                :status="progressPercent(record) >= 100 ? 'success' : 'active'"
                                size="small"
                                :show-info="progressPercent(record) >= 100"
                            />
                        </a-tooltip>
                    </template>

                    <!-- Người phụ trách -->
                    <template v-else-if="column.dataIndex === 'assigned_to_name'">
                        <a-tooltip :title="record.assigned_to_name">
                            <BaseAvatar
                                :src="record.assigned_to_avatar"
                                :name="record.assigned_to_name"
                                size="28"
                            />
                        </a-tooltip>
                    </template>

                    <!-- Trạng thái -->
                    <template v-else-if="column.dataIndex === 'status'">
                        <a-tag :color="getStatusColor(record.status)">
                            {{ getStatusLabel(record.status) }}
                        </a-tag>
                    </template>

                    <!-- Ngày tháng -->
                    <template v-else-if="column.dataIndex === 'start_date' || column.dataIndex === 'end_date'">
                        {{ formatDate(record[column.dataIndex]) }}
                    </template>

                    <!-- Hạn -->
                    <template v-else-if="column.dataIndex === 'due'">
                        <div :class="{ 'overdue-cell': Number(record.days_overdue) > 0 }">
                            <a-tag v-if="record.days_remaining > 0" color="green">Còn {{ record.days_remaining }} ngày
                            </a-tag>
                            <a-tag v-else-if="record.days_remaining === 0 && record.days_overdue === 0" color="gold">Hạn
                                chót hôm nay
                            </a-tag>
                            <a-tag v-else-if="record.days_overdue > 0" color="red">Quá hạn {{ record.days_overdue }} ngày
                            </a-tag>
                            <a-tag v-else color="default">Không xác định</a-tag>
                        </div>
                    </template>

                    <!-- Hành động -->
                    <template v-else-if="column.dataIndex === 'action'">
                        <!-- ⭐ Chỉ admin & super_admin mới thấy icon cấp quyền -->
                        <a-tooltip v-if="canManageMembers(record)" title="Cấp quyền truy cập hợp đồng">
                            <UserAddOutlined
                                class="icon-action"
                                style="color:#722ed1;"
                                @click="setActiveRow(record.id); openMemberModal(record)"
                            />
                        </a-tooltip>

                        <a-tooltip title="Chỉnh sửa">
                            <EditOutlined class="icon-action" style="color:#1890ff" @click="showPopupDetail(record)"/>
                        </a-tooltip>
                        <a-popconfirm
                            title="Bạn chắc chắn muốn xóa hợp đồng này?"
                            ok-text="Xóa"
                            cancel-text="Hủy"
                            @confirm="deleteConfirm(record.id)"
                            placement="topRight"
                        >
                            <a-tooltip title="Xoá">
                                <DeleteOutlined class="icon-action" style="color:red;margin:0"/>
                            </a-tooltip>
                        </a-popconfirm>
                    </template>
                </template>
            </a-table>
        </a-card>

        <EntityMemberManager
            v-model:open="showMemberModal"
            entityType="contract"
            :entityId="Number(selectedEntityId)"
            :entityData="selectedEntityData"
            @saved="getContracts"
        />

        <!-- Drawer lọc nhanh theo card -->
        <a-drawer
            :title="drawerContractTitle"
            placement="right"
            :width="1200"
            :open="drawerVisible"
            @close="drawerVisible=false"
        >
            <a-table
                :key="drawerKey + '-' + drawerPagination.current + '-' + drawerPagination.pageSize"
                :columns="drawerColumns"
                :data-source="drawerData"
                :loading="drawerLoading"
                :pagination="drawerPagination"
                @change="handleDrawerTableChange"
                row-key="id"
                size="small"
                bordered
                :scroll="{ x: 'max-content'}"
            >
                <template #bodyCell="{ column, record, index }">
                    <template v-if="column.dataIndex === 'index'">{{ index + 1 }}</template>
                    <template v-else-if="column.key === 'name'">
                        <a-tooltip :title="record.name">
                            <a-typography-text strong style="cursor:pointer" @click="goToContractDetail(record.id)">
                                {{ truncateText(record.name, 25) }}
                            </a-typography-text>
                        </a-tooltip>
                    </template>
                    <template v-else-if="column.dataIndex === 'progress'">
                        <a-progress
                            :percent="progressPercent(record)"
                            :stroke-color="{ '0%':'#108ee9', '100%':'#87d068' }"
                            :status="progressPercent(record) >= 100 ? 'success' : 'active'"
                            size="small"
                        />
                    </template>
                    <template v-else-if="column.dataIndex === 'assigned_to_name'">
                        <a-tooltip :title="record.assigned_to_name">
                            <a-avatar :style="{backgroundColor:getAvatarColor(record.assigned_to_name)}" size="small">
                                {{ getFirstLetter(record.assigned_to_name) }}
                            </a-avatar>
                        </a-tooltip>
                    </template>
                    <template v-else-if="column.dataIndex === 'status'">
                        <a-tag :color="getStatusColor(record.status)">{{ getStatusLabel(record.status) }}</a-tag>
                    </template>
                    <template v-else-if="column.dataIndex === 'start_date'">{{formatDate(record.start_date) }}
                    </template>
                    <template v-else-if="column.dataIndex === 'end_date'">{{ formatDate(record.end_date) }}</template>
                    <template v-else-if="column.dataIndex === 'due'">
                        <a-tag v-if="record.days_remaining>0" color="green">Còn {{ record.days_remaining }} ngày</a-tag>
                        <a-tag v-else-if="record.days_remaining===0&&record.days_overdue===0" color="gold">Hạn chót hôm
                            nay
                        </a-tag>
                        <a-tag v-else-if="record.days_overdue>0" color="red">Quá hạn {{ record.days_overdue }} ngày
                        </a-tag>
                    </template>
                </template>
            </a-table>
        </a-drawer>

        <!-- Drawer tạo/sửa: giữ form hiện có của bạn -->
        <a-drawer :title="selectedContract ? 'Sửa hợp đồng' : 'Tạo hợp đồng mới'" :width="700" :open="openDrawer"
                  :body-style="{ paddingBottom: '80px' }" :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Tên hợp đồng" name="name">
                            <a-input v-model:value="formData.name" placeholder="Nhập tên hợp đồng"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Mã hợp đồng" name="code">
                            <a-input v-model:value="formData.code" placeholder="Nhập mã hợp đồng"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Trạng thái" name="status">
                            <a-select v-model:value="formData.status" placeholder="Chọn trạng thái">
                                <a-select-option :value="0">Nháp</a-select-option>
                                <a-select-option :value="1">Đang thực hiện</a-select-option>
                                <a-select-option :value="2">Chờ duyệt</a-select-option>
                                <a-select-option :value="3">Đã duyệt</a-select-option>
                                <a-select-option :value="4">Hoàn thành</a-select-option>
                                <a-select-option :value="5">Đã hủy</a-select-option>
                            </a-select>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="[16, 0]">
                    <a-col :span="24">
                        <a-checkbox v-model:checked="formData.is_awarded" style="margin-bottom: 12px;"
                                    @change="handleIsAwardedChange"> Đã trúng thầu
                        </a-checkbox>
                    </a-col>
                    <a-col :span="24" v-if="formData.is_awarded">
                        <a-form-item label="Gói thầu đã trúng" name="bidding_id">
                            <a-select v-model:value="formData.bidding_id" :options="awardedBiddings"
                                      placeholder="Chọn gói thầu đã trúng" allow-clear show-search
                                      :filter-option="(input, option) =>option.label.toLowerCase().includes(input.toLowerCase())"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Khách hàng liên quan">
                            <a-select v-model:value="formData.customer_id" :options="customerOptions"
                                      placeholder="Chọn khách hàng liên quan" allow-clear show-search
                                      :disabled="formData.is_awarded"
                                      :filter-option="(input, option) => option.label.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().includes(input.toLowerCase()) || option.label.toLowerCase().includes(input.toLowerCase())"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Người phụ trách" name="assigned_to">
                            <a-select v-model:value="formData.assigned_to" :options="userOptions"
                                      placeholder="Chọn người phụ trách" allow-clear show-search
                                      :filter-option="(input, option) => option.label.toLowerCase().includes(input.toLowerCase())"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Ngày bắt đầu" name="start_date">
                            <a-date-picker v-model:value="formData.start_date" style="width: 100%"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Ngày kết thúc" name="end_date">
                            <a-date-picker v-model:value="formData.end_date" style="width: 100%"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" placeholder="Nhập mô tả hợp đồng"
                                        :rows="4"/>
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" @click="submitForm" html-type="submit" :loading="loadingCreate">
                        {{ selectedContract ? 'Cập nhật' : 'Thêm mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import {ref, computed, onMounted, watch, nextTick} from 'vue'
import dayjs from 'dayjs'

const formRef = ref(null)
import {message, Modal} from 'ant-design-vue'
import {getBiddingsAPI, getBiddingAPI} from '@/api/bidding'
import {
    SearchOutlined,
    CheckCircleOutlined,
    CloseCircleOutlined,
    ClockCircleOutlined,
    StopOutlined,
    EyeOutlined,
    EditOutlined,
    DeleteOutlined,
    UserAddOutlined
} from '@ant-design/icons-vue'
import {useRouter} from 'vue-router'
import {formatDate} from '@/utils/formUtils'
import {
    getContractsAPI,
    createContractAPI,
    updateContractAPI,
    deleteContractAPI,
    canMarkContractAsCompleteAPI,
    cloneStepsFromTemplateAPI
} from '@/api/contract'
import {getUsers} from '@/api/user'
import {getCustomers} from '@/api/customer'
import {addEntityMember} from "@/api/entityMembers.js";
import { useUserStore } from '@/stores/user'
const store = useUserStore()

import {useEntityAccess} from "@/utils/openEntityDetail.js";
const { openEntity } = useEntityAccess();

import EntityMemberManager from "@/components/common/EntityMemberManager.vue";
import BaseAvatar from '@/components/common/BaseAvatar.vue'
// ✅ Tạo factory cho dữ liệu mặc định
const defaultContract = () => ({
    name: '',
    code: '',
    status: 0,
    is_awarded: false,
    start_date: null,
    end_date: null,
    description: '',
    bidding_id: null,
    assigned_to: null,
    customer_id: null,
    priority: 0,
    manager_id: null,
    collaborators: [],
})

const formData = ref(defaultContract())
const isAwarded = computed(() => !!formData.value?.is_awarded)
// Options cho select
const awardedBiddings = ref([])       // gói thầu đã trúng
const userOptions = ref([])       // người phụ trách
const customers = ref([])       // danh sách KH
const showMemberModal = ref(false);
const selectedEntityId = ref(null);
const selectedEntityData = ref(null);
const activeRowId = ref(null);


const customerOptions = computed(() =>
    customers.value.map(c => ({label: c.name, value: String(c.id)}))
)

const canManageMembers = (record) => {
    const currentUserId = Number(store.currentUser?.id);
    return (
        currentUserId === Number(record.assigned_to) ||
        currentUserId === Number(record.manager_id)
    );
};

// Validate helpers
const validateName = async (_r, v) => {
    if (!v) return Promise.reject('Vui lòng nhập tên hợp đồng')
    if (v.length > 200) return Promise.reject('Tên hợp đồng không vượt quá 200 ký tự')
    return Promise.resolve()
}
const validateCode = async (_r, v) => {
    if (!v) return Promise.reject('Vui lòng nhập mã hợp đồng')
    if (v.length > 50) return Promise.reject('Mã hợp đồng không vượt quá 50 ký tự')
    return Promise.resolve()
}
const validateDates = async () => {
    const s = formData.value.start_date
    const e = formData.value.end_date
    if (!s || !e) return Promise.resolve()
    if (dayjs(e).isBefore(s)) return Promise.reject('Ngày kết thúc phải sau ngày bắt đầu')
    return Promise.resolve()
}

const rules = computed(() => ({
    name: [{required: true, validator: validateName, trigger: 'change'}],
    code: [{required: true, validator: validateCode, trigger: 'change'}],
    status: [{required: true, message: 'Vui lòng chọn trạng thái', trigger: 'change'}],
    start_date: [{required: true, message: 'Vui lòng chọn ngày bắt đầu', trigger: 'change'}],
    end_date: [
        {required: true, message: 'Vui lòng chọn ngày kết thúc', trigger: 'change'},
        {validator: validateDates, trigger: 'change'},
    ],
    description: [{required: true, message: 'Vui lòng nhập mô tả', trigger: 'change'}],
    bidding_id: [{required: isAwarded.value, message: 'Vui lòng chọn gói thầu đã trúng', trigger: 'change'}],
    customer_id: [{required: !isAwarded.value, message: 'Vui lòng chọn khách hàng', trigger: 'change'}],
}))

// Gói thầu đã trúng (status WON = 2; nếu BE dùng 2 cho Hoàn tất)
const fetchAwardedBiddings = async () => {
    try {
        const res = await getBiddingsAPI({status: 2, per_page: 1000})
        const list = res?.data?.data ?? res?.data ?? []
        awardedBiddings.value = list.map(b => ({label: b.title, value: String(b.id)}))
    } catch (e) {
        console.error(e)
        message.error('Không thể tải danh sách gói thầu đã trúng')
    }
}

const fetchUsers = async () => {
    try {
        const res = await getUsers()
        const raw = Array.isArray(res.data) ? res.data : res.data?.data || []
        userOptions.value = raw.map(u => ({label: u.name, value: String(u.id)}))
    } catch (e) {
        console.error(e)
    }
}

const fetchCustomers = async () => {
    try {
        const res = await getCustomers({page: 1, per_page: 1000})
        customers.value = res?.data?.data ?? res?.data ?? []
    } catch (e) {
        console.error(e)
    }
}

watch(() => formData.value.bidding_id, async (id) => {
    if (!id) {
        if (formData.value.is_awarded) formData.value.customer_id = null
        return
    }
    try {
        const res = await getBiddingAPI(id)
        formData.value.customer_id = res?.data?.customer_id ?? null
        formData.value.is_awarded = true
    } catch (e) {
        console.error(e)
    }
})


const handleIsAwardedChange = () => {
    if (!formData.value.is_awarded) {
        formData.value.bidding_id = null
    }
}


const router = useRouter()

/* ---------- State cơ bản ---------- */
const tableData = ref([])
const loading = ref(false)
const pagination = ref({
    current: 1, pageSize: 10, total: 0,
    showSizeChanger: true, pageSizeOptions: ['10', '20', '50', '100'],
    showTotal: (total, range) => `${range[0]}-${range[1]} / ${total} hợp đồng`
})

const selectedRowKeys = ref([])
const selectedRows = ref([])
const rowSelection = computed(() => ({
    selectedRowKeys: selectedRowKeys.value,
    onChange: (keys, rows) => {
        selectedRowKeys.value = keys;
        selectedRows.value = rows
    }
}))

/* ---------- Search (debounce) ---------- */
const searchTerm = ref('')
let searchTimer = null
watch(searchTerm, () => {
    clearTimeout(searchTimer)
    searchTimer = setTimeout(() => {
        pagination.value.current = 1
        getContracts()
    }, 300)
})

/* ---------- Summary ---------- */
const summary = ref({status_1: 0, status_2: 0, status_3: 0, important: 0, normal: 0, overdue: 0, total: 0})

// Map thẻ theo schema ContractController (status_1/2/3)
const statsContracts = computed(() => [
    {
        key: 'status_2',
        label: 'Hoàn tất',
        count: summary.value.status_2,
        color: '#52c41a',
        bg: '#f6ffed',
        icon: CheckCircleOutlined
    },
    {
        key: 'important',
        label: 'Quan trọng',
        count: summary.value.important,
        color: '#faad14',
        bg: '#fffbe6',
        icon: ClockCircleOutlined
    },
    {
        key: 'normal',
        label: 'Bình thường',
        count: summary.value.normal,
        color: '#1890ff',
        bg: '#e6f7ff',
        icon: ClockCircleOutlined
    },
    {
        key: 'overdue',
        label: 'Quá hạn',
        count: summary.value.overdue,
        color: '#ff4d4f',
        bg: '#fff1f0',
        icon: CloseCircleOutlined
    },
    {
        key: 'status_3',
        label: 'Đã hủy',
        count: summary.value.status_3,
        color: '#d9363e',
        bg: '#fff1f0',
        icon: StopOutlined
    },
])

/* ---------- Drawer list theo card ---------- */
const drawerVisible = ref(false)
const drawerContractTitle = ref('')
const drawerKey = ref('')
const drawerData = ref([])
const drawerLoading = ref(false)
const drawerPagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    pageSizeOptions: ['10', '20', '50', '100']
})

const drawerColumns = [
    {title: 'STT', dataIndex: 'index', key: 'index', width: '60px', align: 'center'},
    {title: 'Tên hợp đồng', dataIndex: 'name', key: 'name'},
    {title: 'Tiến độ', dataIndex: 'progress', key: 'progress', align: 'center'},
    {title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'center'},
    {title: 'Trạng thái', dataIndex: 'status', key: 'status'},
    {title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date'},
    {title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date'},
    {title: 'Hạn', dataIndex: 'due', key: 'due'},
]

const openContractDrawer = (key, title) => {
    drawerKey.value = key
    drawerContractTitle.value = title
    drawerVisible.value = true
    drawerData.value = []                // reset data cũ
    drawerPagination.value.current = 1
    drawerPagination.value.pageSize = 10
    fetchDrawerList()
}

const handleDrawerTableChange = (pag) => {
    drawerPagination.value.current = pag.current
    drawerPagination.value.pageSize = pag.pageSize
    if (drawerKey.value !== 'overdue') fetchDrawerList()
}

const fetchDrawerList = async () => {
    drawerLoading.value = true
    try {
        const base = {
            page: drawerPagination.value.current,
            per_page: drawerPagination.value.pageSize,
            with_progress: 1,
            _t: Date.now()               // chống cache
        }

        // Lọc theo key
        if (drawerKey.value === 'status_2' || drawerKey.value === 'status_3') {
            const st = drawerKey.value === 'status_2' ? 2 : 3
            const res = await getContractsAPI({...base, status: st})
            const {data, pager} = res.data || {}
            drawerData.value = normalizeRows(data || [])
            applyDrawerPager(pager)
            return
        }

        if (drawerKey.value === 'important' || drawerKey.value === 'normal') {
            const pr = drawerKey.value === 'important' ? 1 : 0
            const res = await getContractsAPI({...base, priority: pr})
            const {data, pager} = res.data || {}
            drawerData.value = normalizeRows(data || [])
            applyDrawerPager(pager)
            return
        }

        if (drawerKey.value === 'overdue') {
            // lấy nhiều rồi lọc client
            const res = await getContractsAPI({page: 1, per_page: 1000, with_progress: 1, _t: Date.now()})
            const all = normalizeRows(res.data?.data || [])
            drawerData.value = all.filter(r => Number(r.days_overdue) > 0)
            drawerPagination.value.total = drawerData.value.length
            drawerPagination.value.current = 1
            return
        }

        // fallback
        drawerData.value = []
        drawerPagination.value.total = 0
    } finally {
        drawerLoading.value = false
    }
}

const applyDrawerPager = (pager) => {
    drawerPagination.value.total = Number(pager?.total ?? 0)
    drawerPagination.value.current = Number(pager?.current_page ?? 1)
    drawerPagination.value.pageSize = Number(pager?.per_page ?? drawerPagination.value.pageSize)
}

/* ---------- Columns chính ---------- */
const columns = [
    {title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px'},
    {title: 'Tên hợp đồng', dataIndex: 'name', key: 'name'},
    {title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: '150px'},
    {title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'center'},
    {title: 'Mã hợp đồng', dataIndex: 'code', key: 'code'},
    {title: 'Trạng thái', dataIndex: 'status', key: 'status'},
    {title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date'},
    {title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date'},
    {title: 'Hạn', dataIndex: 'due', key: 'due', align: 'center'},
    {title: 'Hành động', dataIndex: 'action', key: 'action', width: '140px'},
]

/* ---------- Helpers hiển thị ---------- */
const progressPercent = (r) => r.progress_percent ?? r.progress?.contract_progress ?? 0
const progressText = (r) => {
    const done = Number(r.steps_done ?? r.progress?.steps_completed ?? 0)
    const total = Number(r.steps_total ?? r.progress?.steps_total ?? 0)
    if (!total) return 'Chưa có bước nào'
    if (done === 0) return `Chưa bắt đầu (${total} bước)`
    if (done < total) return `Đã hoàn thành ${done}/${total} bước`
    return `Hoàn thành toàn bộ ${total} bước`
}

const setActiveRow = (id) => {
    activeRowId.value = id;
};

const openMemberModal = (record) => {
    if (!canManageMembers(record)) {
        return message.warning("Bạn không có quyền chỉnh sửa người truy cập hợp đồng");
    }
    selectedEntityData.value = record;
    selectedEntityId.value = record.id;
    showMemberModal.value = true;
};


const getFirstLetter = (name) => (!name || name === 'N/A') ? '?' : name.charAt(0).toUpperCase()
const getAvatarColor = (name) => {
    if (!name || name === 'N/A') return '#d9d9d9'
    const colors = ['#f5222d', '#fa8c16', '#fadb14', '#52c41a', '#13c2c2', '#1890ff', '#722ed1', '#eb2f96', '#fa541c', '#faad14', '#a0d911', '#52c41a', '#13c2c2', '#1890ff', '#722ed1', '#eb2f96']
    let hash = 0;
    for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
    return colors[Math.abs(hash) % colors.length]
}

const getStatusColor = (status) => ({1: 'blue', 2: 'green', 3: 'red'}[Number(status)] || 'default')
const getStatusLabel = (status) => ({
    1: 'Đang thực hiện',
    2: 'Hoàn tất',
    3: 'Đã hủy'
}[Number(status)] || 'Không xác định')

const truncateText = (t, len = 30) => !t ? '' : (t.length > len ? t.slice(0, len) + '…' : t)

/* ---------- Fetch list ---------- */
const normalizeRows = (rows) => (rows || []).map(r => ({
    ...r,
    name: r.name ?? r.title, // BE có thể trả title
    status: r.status != null ? Number(r.status) : null,
    priority: r.priority != null ? Number(r.priority) : undefined,
    progress_percent: r.progress_percent ?? r.progress?.contract_progress ?? 0,
    steps_done: r.steps_done ?? r.progress?.steps_completed ?? 0,
    steps_total: r.steps_total ?? r.progress?.steps_total ?? 0,
    subtasks_done: r.subtasks_done ?? r.progress?.subtasks_approved ?? 0,
    subtasks_total: r.subtasks_total ?? r.progress?.subtasks_total ?? 0,
}))

const getContracts = async () => {
    loading.value = true
    try {
        const res = await getContractsAPI({
            page: pagination.value.current,
            per_page: pagination.value.pageSize, // ví dụ 10
            with_progress: 1,
            search: (searchTerm.value || '').trim() || undefined,
        })
        const {data, pager, summary: s} = res.data || {}
        tableData.value = normalizeRows(data)

        if (s) {
            summary.value = {
                status_1: +s.status_1 || 0,
                status_2: +s.status_2 || 0,
                status_3: +s.status_3 || 0,
                important: +s.important || 0,
                normal: +s.normal || 0,
                overdue: +s.overdue || 0,
                total: +s.total || 0
            }
        }
        if (pager) {
            pagination.value.total = +pager.total || 0
            pagination.value.current = +pager.current_page || 1
            pagination.value.pageSize = +pager.per_page || pagination.value.pageSize
        }
    } finally {
        loading.value = false
    }
}

const totalDisplay = computed(() => {
    if ((searchTerm?.value || '').trim()) return tableData.value.length
    return Number(pagination.value.total || summary.value.total || tableData.value.length)
})

const handleTableChange = (pag) => {
    pagination.value.current = pag.current
    pagination.value.pageSize = pag.pageSize
    getContracts()
}

/* ---------- CRUD actions (tái dùng hàm cũ của bạn) ---------- */
const openDrawer = ref(false)
const selectedContract = ref(null)
const loadingCreate = ref(false)

const showPopupCreate = async () => {
    // KHÔNG gọi resetFields ở đây
    selectedContract.value = null
    formData.value = defaultContract()   // reset bằng model
    openDrawer.value = true              // hiển thị form

    await nextTick()                     // chờ form mount
    formRef.value?.clearValidate?.()     // xoá lỗi (nếu có)
}
const showPopupDetail = async (record) => {
    selectedContract.value = record

    formData.value = {
        ...defaultContract(),
        name: record.name ?? record.title ?? '',
        code: record.code ?? '',
        status: Number(record.status ?? 0),
        start_date: record.start_date ? dayjs(record.start_date) : null,
        end_date: record.end_date ? dayjs(record.end_date) : null,
        description: record.description ?? '',
        bidding_id: record.bidding_id ?? null,
        assigned_to: record.assigned_to ?? null,
        customer_id: record.customer_id ?? record.customer_id ?? null,
        priority: Number(record.priority ?? 0),
        manager_id: record.manager_id ?? null,
        collaborators: Array.isArray(record.collaborators)
            ? record.collaborators
            : (typeof record.collaborators === 'string' && record.collaborators.trim()
                ? (JSON.parse(record.collaborators || '[]') || [])
                : []),
    }

    openDrawer.value = true
    await nextTick()
    formRef.value?.clearValidate?.()
}


const onCloseDrawer = async () => {
    openDrawer.value = false
    await nextTick()
    formRef.value?.clearValidate?.()
}

watch(openDrawer, (open) => {
    if (open && (!formData.value || typeof formData.value !== 'object')) {
        formData.value = defaultContract();
    }
});

const addAccess = async (entityId, userId) => {
    if (!entityId || !userId) return;
    try {
        await addEntityMember({
            entity_type: "contract",
            entity_id: Number(entityId),
            user_id: Number(userId)
        });
        console.log(`✔ contract#${entityId} → cấp quyền cho user ${userId}`);
    } catch (e) {
        console.warn("⚠ Không thể thêm quyền truy cập:", e);
    }
};

const submitForm = async () => {
    try {
        await formRef.value?.validate?.()

        // Chuẩn hóa payload gửi API
        const payload = {
            title: (formData.value.name || '').trim(),
            code: formData.value.code || '',
            status: Number(formData.value.status),
            start_date: formData.value.start_date ? dayjs(formData.value.start_date).format('YYYY-MM-DD') : null,
            end_date: formData.value.end_date ? dayjs(formData.value.end_date).format('YYYY-MM-DD') : null,
            description: formData.value.description || '',
            bidding_id: formData.value.bidding_id || null,
            assigned_to: formData.value.assigned_to || null,
            customer_id: formData.value.customer_id || null,
            priority: Number(formData.value.priority || 0),
            manager_id: formData.value.manager_id || null,
            collaborators: Array.isArray(formData.value.collaborators)
                ? formData.value.collaborators
                : [],
        }

        let newId = null

        // UPDATE CONTRACT
        if (selectedContract.value) {
            await updateContractAPI(selectedContract.value.id, payload)
            newId = selectedContract.value.id
            message.success('Cập nhật hợp đồng thành công')

        } else {
            // CREATE CONTRACT
            const res = await createContractAPI(payload)
            newId = Number(res?.data?.id)

            // Tự clone steps nếu hợp đồng mới
            if (newId) await cloneStepsFromTemplateAPI(newId)

            message.success('Thêm hợp đồng thành công')
        }

        /* -------------------------------------------------
         * ⭐⭐⭐ AUTO ADD ACCESS — Cấp quyền tự động entity_members
         * ------------------------------------------------- */
        if (newId) {

            // Người tạo
            const creatorId = Number(store.currentUser?.id)

            // Gom tất cả user cần được cấp quyền vào 1 list
            const members = new Set([
                creatorId,
                Number(payload.assigned_to),
                Number(payload.manager_id),
                ...payload.collaborators.map(id => Number(id))
            ])

            // Loại bỏ giá trị null / undefined / 0
            const finalMembers = [...members].filter(v => !!v)

            // Gọi API addEntityMember cho từng người
            for (const uid of finalMembers) {
                try {
                    await addEntityMember({
                        entity_type: "contract",
                        entity_id: Number(newId),
                        user_id: Number(uid),
                    })
                    console.log(`✔ grant access: contract#${newId} -> user#${uid}`)
                } catch (e) {
                    console.warn(`⚠ Không thể cấp quyền cho user ${uid}`, e)
                }
            }
        }
        /* ------------------------------------------------- */

        openDrawer.value = false
        await getContracts()

    } catch (e) {
        if (e?.errorFields) return   // lỗi validate form
        console.error(e)
        message.error('Không thể lưu hợp đồng')
    }
}


const deleteConfirm = async (id) => {
    try {
        await deleteContractAPI(id);
        message.success("Xóa hợp đồng thành công");
        await getContracts(); // reload danh sách
    } catch (e) {
        console.error(e);
        message.error("Xóa hợp đồng thất bại");
    }
};


const handleBulkDelete = async () => {
    try {
        await Promise.all(selectedRowKeys.value.map(id => deleteContractAPI(id)))
        message.success(`Đã xoá ${selectedRowKeys.value.length} hợp đồng`)
        selectedRowKeys.value = []
        await getContracts()
    } catch {
        message.error('Không thể xoá hợp đồng')
    }
}

/* ---------- Nav ---------- */
const goToContractDetail = (id) => {
    openEntity("contract", id, "contract-detail");
};

/* ---------- Mount ---------- */
onMounted(() => {
    getContracts()
    fetchUsers()
    fetchCustomers()
    fetchAwardedBiddings()
})
</script>

<style>
.summary-cards .ant-card-body {
    cursor: pointer;
}

:deep(.ant-table-tbody > tr:hover) {
    background-color: #f5faff !important;
    transition: background-color .3s;
}

/* viền trái đỏ cho ô quá hạn */
:deep(.overdue-cell) {
    border-left: 3px solid #ff4d4f;
    padding-left: 8px;
}
</style>

<style scoped>
.icon-action {
    font-size: 18px;
    margin-right: 16px;
    cursor: pointer;
}

.summary-cards {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    margin-bottom: 8px;
}

.summary-cards .ant-card {
    flex: 1;
    min-width: 200px;
    text-align: center;
}
</style>
