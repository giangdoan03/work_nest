<template>
    <div>
        <div style="margin-bottom: 10px">
            <a-flex justify="space-between" align="center">
                <div style="display:flex;align-items:center;gap:8px;">
                    <a-typography-title :level="4" style="margin:0">Danh sách gói thầu</a-typography-title>
                    <a-badge :count="totalDisplay" show-zero/>
                </div>
                <a-space>
                    <!-- 🔎 Tìm theo tiêu đề -->
                    <a-input
                        v-model:value="searchTerm"
                        allow-clear
                        style="width: 320px"
                        placeholder="Tìm gói thầu theo tiêu đề…"
                    >
                        <template #prefix>
                            <SearchOutlined/>
                        </template>
                    </a-input>
                    <a-button type="primary" @click="showPopupCreate">Thêm gói thầu mới</a-button>
                </a-space>
            </a-flex>
        </div>
        <div class="summary-cards">
            <a-card
                v-for="item in statsBiddings"
                :key="item.key"
                :style="{ backgroundColor: item.bg, cursor:'pointer'}"
                @click="openBidDrawer(item.key,item.label)"
            >
                <a-space direction="vertical" align="center">
                    <component :is="item.icon" :style="{fontSize:'32px',color:item.color}"/>
                    <div>{{ item.label }}</div>
                    <h2 class="number" :style="{ color: item.color }">{{ item.count }}</h2>
                </a-space>
            </a-card>
        </div>
        <a-flex justify="space-between" align="center" style="margin-top: 12px">
            <div>
                <a-space>
                    <a-button danger v-if="selectedRowKeys.length" @click="handleBulkDelete">
                        Xóa {{ selectedRowKeys.length }} gói thầu
                    </a-button>
                </a-space>
            </div>
        </a-flex>

        <a-table
            :columns="columns"
            :data-source="tableData"
            :loading="loading"
            style="margin-top: 4px"
            row-key="id"
            :pagination="pagination"
            :scroll="{ x: 'max-content'}"
            :row-selection="rowSelection"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
                </template>
                <template v-else-if="column.key === 'title'">
                    <a-tooltip :title="record.title">
                        <a-typography-text strong style="cursor: pointer" @click="goToDetail(record.id)">
                            {{ truncateText(record.title, 25) }}
                        </a-typography-text>
                    </a-tooltip>
                </template>
                <!-- Tiến độ -->
                <template v-else-if="column.dataIndex === 'progress'">
                    <a-tooltip :title="progressText(record)">
                        <a-progress
                            :percent="progressPercent(record)"
                            :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"
                            :status="progressPercent(record) >= 100 ? 'success' : 'active'"
                            size="small"
                            :show-info="progressPercent(record) >= 100"
                            style="cursor: pointer;"
                            @click="openProgressModal(record)"
                        />
                    </a-tooltip>
                </template>

                <!-- Người phụ trách -->
                <template v-else-if="column.dataIndex === 'assigned_to_name'">
                    <a-tooltip :title="record.assigned_to_name">
                        <a-avatar :style="{backgroundColor:getAvatarColor(record.assigned_to_name)}" size="small">
                            {{ getFirstLetter(record.assigned_to_name) }}
                        </a-avatar>
                    </a-tooltip>
                </template>
                <!-- Độ ưu tiên -->
                <template v-else-if="column.dataIndex === 'priority'">
                    <a-tag :color="Number(record.priority) === 1 ? 'red' : 'blue'">
                        {{ Number(record.priority) === 1 ? 'Quan trọng' : 'Bình thường' }}
                    </a-tag>
                </template>

                <!-- Trạng thái -->
                <template v-else-if="column.dataIndex === 'status'">
                    <a-tag v-if="Number(record.status) === STATUS.PREPARING" color="blue">Đang chuẩn bị</a-tag>
                    <a-tag v-else-if="Number(record.status) === STATUS.WON" color="green">Trúng thầu</a-tag>
                    <a-tag v-else-if="Number(record.status) === STATUS.CANCELLED" color="gray">Hủy thầu</a-tag>
                    <span v-else style="color:#999">—</span>
                </template>
                <!-- ✅ Độ ưu tiên: chỉ Bình thường / Quan trọng -->
                <template v-else-if="column.dataIndex === 'priority'">
                    <a-tag v-if="Number(record.priority) === 1" color="red">Quan trọng</a-tag>
                    <a-tag v-else color="blue">Bình thường</a-tag>
                </template>

                <!-- Độ ưu tiên -->
                <template v-else-if="column.dataIndex === 'priority'">
                    <a-tag :color="Number(record.priority) === 1 ? 'red' : 'blue'">
                        {{ Number(record.priority) === 1 ? 'Quan trọng' : 'Bình thường' }}
                    </a-tag>
                </template>

                <!-- Trạng thái: chỉ hiển thị Trúng thầu / Hủy thầu; còn lại gạch ngang -->
                <template v-else-if="column.dataIndex === 'status'">
                    <template v-if="Number(record.status) === 2">
                        <a-tag color="green">Trúng thầu</a-tag>
                    </template>
                    <template v-else-if="Number(record.status) === 3">
                        <a-tag color="gray">Hủy thầu</a-tag>
                    </template>
                    <template v-else>
                        <span style="color:#999">—</span>
                    </template>
                </template>

                <template v-else-if="column.dataIndex === 'estimated_cost'">
                    {{ formatCurrency(record.estimated_cost) }}
                </template>
                <template v-else-if="column.dataIndex === 'start_date' || column.dataIndex === 'end_date'">
                    {{ formatDate(record[column.dataIndex]) }}
                </template>
                <template v-if="column.dataIndex === 'due'">
                    <div :class="{ 'overdue-cell': Number(record.days_overdue) > 0 }">
                        <a-tag v-if="record.days_remaining > 0" color="green">
                            Còn {{ record.days_remaining }} ngày
                        </a-tag>
                        <a-tag v-else-if="record.days_remaining === 0 && record.days_overdue === 0" color="gold">
                            Hạn chót hôm nay
                        </a-tag>
                        <a-tag v-else-if="record.days_overdue > 0" color="red">
                            Quá hạn {{ record.days_overdue }} ngày
                        </a-tag>
                        <a-tag v-else color="default">Không xác định</a-tag>
                    </div>
                </template>

                <template v-else-if="column.dataIndex === 'action'">
                    <a-tooltip title="Xem chi tiết">
                        <EyeOutlined class="icon-action" style="color: #52c41a;" @click="goToDetail(record.id)"/>
                    </a-tooltip>
                    <a-tooltip title="Chỉnh sửa">
                        <EditOutlined class="icon-action" style="color: #1890ff;" @click="showPopupDetail(record)"/>
                    </a-tooltip>
                    <a-popconfirm
                        title="Bạn chắc chắn muốn xoá gói thầu này?"
                        ok-text="Xoá"
                        cancel-text="Huỷ"
                        @confirm="deleteConfirm(record.id)"
                        placement="topRight"
                    >
                        <a-tooltip title="Xoá">
                            <DeleteOutlined class="icon-action" style="color: red;"/>
                        </a-tooltip>
                    </a-popconfirm>
                </template>

            </template>
        </a-table>

        <a-drawer
            title="Tạo gói thầu mới"
            :width="700"
            :open="openDrawer"
            :footer-style="{ textAlign: 'right' }"
            @close="onCloseDrawer"
        >
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-form-item label="Tên gói thầu" name="title">
                    <a-input v-model:value="formData.title" placeholder="Nhập tên gói thầu"/>
                </a-form-item>
                <a-form-item label="Chi tiết mô tả" name="description">
                    <a-textarea v-model:value="formData.description" :rows="3" placeholder="Nhập mô tả chi tiết"/>
                </a-form-item>
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
                    <a-col :span="12">
                        <a-form-item label="Chi phí dự toán" name="estimated_cost">
                            <a-input-number v-model:value="formData.estimated_cost" style="width: 100%" :min="0"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Khách hàng" name="customer_id">
                            <a-select
                                v-model:value="formData.customer"
                                label-in-value
                                :options="customerOptions"
                                placeholder="Chọn khách hàng"
                                show-search
                                :filter-option="(input, option) =>
                        (option?.label ?? '').toLowerCase().includes(input.toLowerCase())"
                                @popupScroll="handleCustomerScroll"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>
                <!-- 👇 Thêm mới -->
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Người quản lý" name="manager_id">
                            <a-select
                                v-model:value="formData.manager_id"
                                :options="userOptions"
                                placeholder="Chọn người quản lý"
                                allow-clear
                                show-search
                                :filter-option="(input, opt)=> (opt?.label ?? '').toLowerCase().includes(input.toLowerCase())"
                            />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Người phụ trách" name="assigned_to">
                            <a-select v-model:value="formData.assigned_to" :options="userOptions" placeholder="Chọn người phụ trách"/>
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Độ ưu tiên" name="priority">
                            <a-select
                                v-model:value="formData.priority"
                                :options="[
                                  { value: 1, label: 'Quan trọng' },
                                  { value: 0, label: 'Bình thường' }
                                ]"
                            />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <!-- Nếu đang sửa & là status tự động (Trúng thầu) thì chỉ hiện tag -->
                        <template v-if="selectedBidding && isAutoStatus">
                            <a-form-item label="Trạng thái">
                                <a-tag :color="getStatusColor(formData.status)">
                                    {{ getStatusText(formData.status) }}
                                </a-tag>
                            </a-form-item>
                        </template>
                        <!-- Ngược lại cho chọn -->
                        <template v-else>
                            <a-form-item label="Trạng thái" name="status">
                                <a-select
                                    v-model:value="formData.status"
                                    :options="editableStatusOptions"
                                    placeholder="Chọn trạng thái"
                                    allow-clear
                                />
                            </a-form-item>
                        </template>
                    </a-col>
                </a-row>

            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Huỷ</a-button>
                    <a-button type="primary" :loading="loadingCreate" @click="submitForm">
                        {{ selectedBidding ? 'Cập nhật' : 'Tạo mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>

        <a-drawer
            :title="drawerBidTitle"
            placement="right"
            :width="1200"
            :open="drawerBidVisible"
            @close="drawerBidVisible = false">
            <a-table
                :columns="drawerBidColumns"
                :data-source="drawerBidData"
                :loading="drawerLoading"
                :pagination="drawerPagination"
                @change="handleDrawerTableChange"
                row-key="id"
                size="small"
                bordered
                :scroll="{ x: 800, y: 400 }"
            >

                <template #bodyCell="{ column, record, index }">
                    <template v-if="column.dataIndex === 'index'">
                        {{ index + 1 }}
                    </template>
                    <!-- THAY cho block hiện có của cột progress -->
                    <!-- Drawer: cột progress -->
                    <template v-else-if="column.dataIndex === 'progress'">
                        <a-progress
                            :percent="progressPercent(record)"
                            :stroke-color="progressColor(record)"
                            :status="Number(record.status) === STATUS.WON ? 'success' : 'active'"
                            size="small"
                        />
                    </template>
                    <!-- Người phụ trách -->
                    <template v-else-if="column.dataIndex === 'assigned_to_name'">
                        <a-tooltip :title="record.assigned_to_name">
                            <a-avatar
                                :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }"
                                size="small"
                            >
                                {{ getFirstLetter(record.assigned_to_name) }}
                            </a-avatar>
                        </a-tooltip>
                    </template>
                    <template v-else-if="column.key === 'title'">
                        <a-tooltip :title="record.title">
                            <a-typography-text strong style="cursor: pointer" @click="goToDetail(record.id)">
                                {{ truncateText(record.title, 25) }}
                            </a-typography-text>
                        </a-tooltip>
                    </template>
                    <template v-else-if="column.dataIndex === 'estimated_cost'">
                        {{ formatCurrency(record.estimated_cost) }}
                    </template>
                    <!-- Độ ưu tiên: chỉ hiển thị Quan trọng | Bình thường -->
                    <template v-else-if="column.dataIndex === 'priority'">
                        <a-tag v-if="record.priority === 1" color="red">Quan trọng</a-tag>
                        <a-tag v-else color="blue">Bình thường</a-tag>
                    </template>
                    <!-- Trạng thái: chỉ hiển thị Trúng thầu | Đã hủy thầu -->
                    <template v-else-if="column.dataIndex === 'status'">
                        <a-tag v-if="Number(record.status) === STATUS.PREPARING" color="blue">Đang chuẩn bị</a-tag>
                        <a-tag v-else-if="Number(record.status) === STATUS.WON" color="green">Trúng thầu</a-tag>
                        <a-tag v-else-if="Number(record.status) === STATUS.CANCELLED" color="gray">Hủy thầu</a-tag>
                        <span v-else style="color:#999">—</span>
                    </template>
                    <template v-else-if="column.dataIndex === 'start_date'">{{
                            formatDate(record.start_date)
                        }}
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

    </div>
</template>

<script setup>
import {ref, onMounted, computed, watch} from 'vue'
import {message,Modal} from 'ant-design-vue'
import {
    CheckCircleOutlined,
    CloseCircleOutlined,
    ClockCircleOutlined,
    EditOutlined,
    DeleteOutlined,
    EyeOutlined,
    FireOutlined,
    StopOutlined,
    SearchOutlined
} from '@ant-design/icons-vue';
import dayjs from 'dayjs'
import {
    getBiddingsAPI,
    createBiddingAPI,
    cloneFromTemplatesAPI, deleteBiddingAPI
} from '@/api/bidding'
import {updateBiddingAPI, canMarkBiddingAsCompleteAPI} from "../api/bidding";
import {formatDate} from '@/utils/formUtils' // nếu bạn đã có
import {getUsers} from '@/api/user.js'

import {useRouter} from 'vue-router'
import {updateTask} from "@/api/task.js";
import {getCustomers} from "@/api/customer.js";

const router = useRouter()

const formRef = ref(null)
const selectedBidding = ref(null)
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)

const progressModalVisible = ref(false)
const selectedTask = ref(null)
const newProgressValue = ref(0)
const progressUpdating = ref(false)
const customerOptions = ref([])

const userOptions = ref([])
const currentPage = ref(1)

const selectedRowKeys = ref([])
const selectedRows = ref([])


const drawerBidVisible = ref(false)
const drawerBidTitle = ref('')
const drawerBidFilterKey = ref('')

const customerPage = ref(1)
const customerTotal = ref(0)
const customerLoading = ref(false)
const searchTerm = ref('')

// --- thêm state ---
const drawerBidData = ref([])
const drawerLoading = ref(false)
const drawerPagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    pageSizeOptions: ['10', '20', '50', '100']
})

const drawerBidColumns = [
    {title: 'STT', dataIndex: 'index', key: 'index', width: '50px', align: 'center'},
    {title: 'Tên gói thầu', dataIndex: 'title', key: 'title'},
    {title: 'Tiến độ', dataIndex: 'progress', key: 'progress', align: 'center'},
    {title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'center'},
    {title: 'Độ ưu tiên', dataIndex: 'priority', key: 'priority'},
    {title: 'Trạng thái', dataIndex: 'status', key: 'status'},
    {title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date'},
    {title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date'},
    {title: 'Hạn', dataIndex: 'due', key: 'due'}
]

const columns = [
    {title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px'},
    {title: 'Tên gói thầu', dataIndex: 'title', key: 'title'},
    {title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: '150px'},
    {title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'center'},
    {title: 'Chi phí dự toán', dataIndex: 'estimated_cost', key: 'estimated_cost'},

    // ✅ Độ ưu tiên dùng đúng field
    {title: 'Độ ưu tiên', dataIndex: 'priority', key: 'priority'},

    // ✅ Trạng thái dùng đúng field
    {title: 'Trạng thái', dataIndex: 'status', key: 'status'},

    {title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date'},
    {title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date'},
    {title: 'Hạn', dataIndex: 'due', key: 'due', align: 'center'},
    {title: 'Hành động', dataIndex: 'action', key: 'action'}
]

const formData = ref({
    title: '',
    description: '',
    customer_id: null,
    estimated_cost: 0,
    status: 0,
    start_date: null,
    end_date: null,
    assigned_to: null,
    customer: null,
    priority: 0,
    manager_id: null,
    collaborators: []  // mảng user_id
})

// gõ tới đâu gọi API tới đó (debounce 300ms)
let searchTimer = null
watch(searchTerm, () => {
    clearTimeout(searchTimer)
    searchTimer = setTimeout(() => {
        pagination.value.current = 1
        getBiddings()
    }, 300)
})

const totalDisplay = computed(() => {
    // Khi đang tìm kiếm client-side => dùng số dòng đang thấy
    if ((searchTerm?.value || '').trim()) return tableData.value.length

    // Mặc định ưu tiên tổng từ server (pager/summary)
    return Number(pagination.value.total || summary.value.total || tableData.value.length)
})


// thêm ở phần khai báo state
const summary = ref({won: 0, important: 0, normal: 0, overdue: 0, lost: 0, total: 0})

const filteredBiddings = computed(() => {
    switch (drawerBidFilterKey.value) {
        case 'won':
            return tableData.value.filter(b => Number(b.status) === STATUS.WON)
        case 'important':
            return tableData.value.filter(b =>
                Number(b.status) === STATUS.PREPARING && Number(b.priority) === PRIORITY.IMPORTANT
            )
        case 'normal':
            return tableData.value.filter(b =>
                Number(b.status) === STATUS.PREPARING && Number(b.priority) === PRIORITY.NORMAL
            )
        case 'overdue':
            return tableData.value.filter(b =>
                Number(b.status) === STATUS.PREPARING && Number(b.days_overdue) > 0
            )
        case 'lost':
            return tableData.value.filter(b => Number(b.status) === STATUS.CANCELLED)
        default:
            return []
    }
})
const displayStatus = (b) => {
    // nếu đã thắng hoặc không trúng thì giữ nguyên
    if (b.status === 0 || b.status === 4) return b.status
    // nếu đã quá hạn theo ngày → coi như 3
    if (Number(b.days_overdue) > 0) return 3
    return b.status
}

// ==== ENUMS & CONSTANTS: đặt TRƯỚC khi dùng ====
const STATUS = Object.freeze({PREPARING: 1, WON: 2, CANCELLED: 3});
const PRIORITY = Object.freeze({NORMAL: 0, IMPORTANT: 1});

const STATUS_MAP = {
    [STATUS.PREPARING]: {text: 'Đang chuẩn bị', color: 'blue'},
    [STATUS.WON]: {text: 'Trúng thầu', color: 'green'},
    [STATUS.CANCELLED]: {text: 'Hủy thầu', color: 'gray'},
};
const PRIORITY_MAP = {
    [PRIORITY.NORMAL]: {text: 'Bình thường', color: 'blue'},
    [PRIORITY.IMPORTANT]: {text: 'Quan trọng', color: 'red'},
};

// Chỉ 2 card có thể gọi API theo status trực tiếp
const CARD_STATUS_MAP = {won: STATUS.WON, lost: STATUS.CANCELLED};

const EDITABLE_STATUS_KEYS = [STATUS.PREPARING, STATUS.CANCELLED]

const editableStatusOptions = computed(() =>
    EDITABLE_STATUS_KEYS.map(k => ({value: k, label: STATUS_MAP[k].text}))
)
const getStatusText = s => (STATUS_MAP[s]?.text ?? 'Không rõ')
const getStatusColor = s => (STATUS_MAP[s]?.color ?? 'default')


// “tự động” chỉ coi là Trúng thầu
const isAutoStatus = computed(() => Number(formData.value.status) === STATUS.WON)

const statsBiddings = computed(() => [
    {
        key: 'won',
        label: 'Trúng thầu',
        count: summary.value.won,
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
        icon: FireOutlined
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
    {key: 'lost', label: 'Không trúng', count: summary.value.lost, color: '#d9363e', bg: '#fff1f0', icon: StopOutlined},
])
const fetchDrawerList = async () => {
    drawerLoading.value = true;
    try {
        const key = drawerBidFilterKey.value;

        // 2 card lấy trực tiếp theo status từ server
        if (key === 'won' || key === 'lost') {
            const res = await getBiddingsAPI({
                status: CARD_STATUS_MAP[key],
                page: drawerPagination.value.current,
                per_page: drawerPagination.value.pageSize,
            });
            const {data, pager} = res.data || {};
            drawerBidData.value = (data ?? []).map(r => ({
                ...r,
                status: Number(r.status),
                priority: Number(r.priority),
                days_overdue: Number(r.days_overdue ?? 0),
            }));
            drawerPagination.value.total = Number(pager?.total ?? 0);
            drawerPagination.value.current = Number(pager?.current_page ?? 1);
            drawerPagination.value.pageSize = Number(pager?.per_page ?? drawerPagination.value.pageSize);
            return;
        }

        // Quan trọng / Bình thường: lọc theo priority, không phụ thuộc status
        if (key === 'important' || key === 'normal') {
            const prio = key === 'important' ? 1 : 0;
            const res = await getBiddingsAPI({
                priority: prio,                         // ✅ server lọc theo priority
                page: drawerPagination.value.current,
                per_page: drawerPagination.value.pageSize,
            });
            const {data, pager} = res.data || {};
            drawerBidData.value = (data ?? []).map(r => ({
                ...r,
                status: Number(r.status),
                priority: Number(r.priority),
                days_overdue: Number(r.days_overdue ?? 0),
            }));
            drawerPagination.value.total = Number(pager?.total ?? 0);
            drawerPagination.value.current = Number(pager?.current_page ?? 1);
            drawerPagination.value.pageSize = Number(pager?.per_page ?? drawerPagination.value.pageSize);
            return;
        }

        // Quá hạn: tính động (ưu tiên lấy nhiều rồi lọc client)
        if (key === 'overdue') {
            const res = await getBiddingsAPI({page: 1, per_page: 1000});
            const all = (res.data?.data ?? []).map(r => ({
                ...r,
                status: Number(r.status),
                priority: Number(r.priority),
                days_overdue: Number(r.days_overdue ?? 0),
            }));
            drawerBidData.value = all.filter(b => b.days_overdue > 0);
            drawerPagination.value.total = drawerBidData.value.length;
            drawerPagination.value.current = 1;
            return;
        }

        drawerBidData.value = [];
    } finally {
        drawerLoading.value = false;
    }
};


// mở drawer → reset & fetch
const openBidDrawer = (key, title) => {
    drawerBidFilterKey.value = key
    drawerBidTitle.value = title
    drawerBidVisible.value = true
    drawerPagination.value.current = 1
    drawerPagination.value.pageSize = 10
    fetchDrawerList()
}

// phân trang trong drawer
const handleDrawerTableChange = (pag) => {
    drawerPagination.value.current = pag.current
    drawerPagination.value.pageSize = pag.pageSize
    if (drawerBidFilterKey.value !== 'overdue') fetchDrawerList()
}

const progressColor = (row) => Number(row.status) === STATUS.WON ? '#52c41a' : '#1890ff';
const PROGRESS_COLOR = '#1890ff' // hoặc màu bạn muốn, ví dụ '#52c41a'

const getProgressStyle = (percent) => {
    if (percent >= 100) {
        return {
            strokeColor: {
                '0%': '#108ee9',
                '100%': '#87d068'
            },
            status: 'success'
        }
    }
    return {
        strokeColor: '#1890ff',
        status: 'active'
    }
}
const progressPercent = (r) => r.progress_percent ?? 0
const progressText = (r) => {
    const done = Number(r.steps_done) || 0
    const total = Number(r.steps_total) || 0

    if (!total) {
        return 'Chưa có bước nào'
    }

    if (done === 0) {
        return `Chưa bắt đầu (${total} bước)`
    }

    if (done < total) {
        return `Đã hoàn thành ${done}/${total} bước`
    }

    return `Hoàn thành toàn bộ ${total} bước`
}



const getFirstLetter = (name) => {
    if (!name || name === 'N/A') return '?'
    return name.charAt(0).toUpperCase()
}

const getAvatarColor = (name) => {
    if (!name || name === 'N/A') return '#d9d9d9'

    // Generate consistent color based on name
    const colors = [
        '#f5222d', '#fa8c16', '#fadb14', '#52c41a',
        '#13c2c2', '#1890ff', '#722ed1', '#eb2f96',
        '#fa541c', '#faad14', '#a0d911', '#52c41a',
        '#13c2c2', '#1890ff', '#722ed1', '#eb2f96'
    ]

    // Simple hash function to get consistent color for same name
    let hash = 0
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash)
    }
    const index = Math.abs(hash) % colors.length
    return colors[index]
}


const openProgressModal = (task) => {
    selectedTask.value = task;
    newProgressValue.value = Number(task.progress) || 0;   // ✅ fix warning
    progressModalVisible.value = true;
};


const rowSelection = computed(() => ({
    selectedRowKeys: selectedRowKeys.value,
    onChange: (keys, rows) => {
        selectedRowKeys.value = keys
        selectedRows.value = rows
    }
}))

const handleBulkDelete = async () => {
    try {
        await Promise.all(selectedRowKeys.value.map(id => deleteBiddingAPI(id)))
        message.success(`Đã xoá ${selectedRowKeys.value.length} gói thầu`)
        selectedRowKeys.value = []
        await getBiddings()
    } catch (err) {
        message.error('Không thể xoá gói thầu')
    }
}

const truncateText = (text, length = 30) => {
    if (!text) return '';
    return text.length > length ? text.slice(0, length) + '...' : text;
}

const customerLabelById = (id) => {
    const opt = customerOptions.value.find(o => o.value === Number(id))
    return opt?.label || null
}

const loadCustomers = async (page = 1) => {
    customerLoading.value = true
    try {
        const res = await getCustomers({page, per_page: 20}) // API index
        const list = res.data.data
        customerTotal.value = res.data.pager.total

        if (page === 1) {
            customerOptions.value = []
        }
        customerOptions.value = [
            ...customerOptions.value,
            ...list.map(c => ({
                value: Number(c.id),
                label: [c.name, c.phone, c.email].filter(Boolean).join(' • ')
            }))
        ]
    } finally {
        customerLoading.value = false
    }
}

const handleCustomerScroll = (e) => {
    const target = e.target
    if (target.scrollTop + target.offsetHeight >= target.scrollHeight - 10) {
        if (customerOptions.value.length < customerTotal.value && !customerLoading.value) {
            customerPage.value++
            loadCustomers(customerPage.value)
        }
    }
}

// lần đầu load
onMounted(() => {
    loadCustomers(1)
})


watch(() => openDrawer.value, (open) => {
    if (open) loadCustomers()
})

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    pageSizeOptions: ['10', '20', '50', '100'],
    showTotal: (total, range) => `${range[0]}-${range[1]} / ${total} gói thầu`
})

const handleTableChange = (pag) => {
    pagination.value.current = pag.current
    pagination.value.pageSize = pag.pageSize
    getBiddings()
}

const rules = {
    title: [{required: true, message: 'Nhập tên gói thầu'}],
    description: [{required: true, message: 'Nhập mô tả'}],
    start_date: [{required: true, message: 'Chọn ngày bắt đầu'}],
    end_date: [{required: true, message: 'Chọn ngày kết thúc'}],
    estimated_cost: [{required: true, message: 'Nhập chi phí dự toán'}],
    status: [{required: true, message: 'Chọn trạng thái'}],
    customer: [
        {required: true, message: 'Chọn khách hàng', trigger: 'change'},
        {
            validator: (_rule, v) => (v && v.value ? Promise.resolve() : Promise.reject('Chọn khách hàng')),
            trigger: 'change'
        }
    ],
    priority: [{required: true, message: 'Chọn độ ưu tiên'}],
    manager_id: [{ required: true, message: 'Chọn người quản lý', trigger: 'change' }],
    collaborators: [{ type: 'array', required: true, message: 'Chọn người phối hợp', trigger: 'change' }]
}

const formatCurrency = (value) => {
    if (!value) return '0 đ'
    return Number(value).toLocaleString('vi-VN') + ' đ'
}

const fetchUsers = async () => {
    const res = await getUsers()
    userOptions.value = res.data.map(user => ({
        label: user.name,
        value: user.id
    }))
}

const getBiddings = async () => {
    loading.value = true
    try {
        const keyword = (searchTerm.value || '').trim()

        // 👉 tham số gọi API
        const params = {
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            with_progress: 1,          // <<— bật trả progress
            search: keyword || undefined // <<— BE dùng 'search'
        }

        const res = await getBiddingsAPI(params)
        const { data, pager, summary: s } = res.data || {}

        // chuẩn hóa + bóc sẵn % tiến độ để hiển thị nhanh
        let rows = (data || []).map(r => ({
            ...r,
            status: r.status != null ? Number(r.status) : null,
            priority: r.priority != null ? Number(r.priority) : 0,
            // fallback nếu BE chưa thêm các field phẳng
            progress_percent: r.progress_percent ?? r.progress?.bidding_progress ?? 0,
            steps_done:       r.steps_done       ?? r.progress?.steps_completed   ?? 0,
            steps_total:      r.steps_total      ?? r.progress?.steps_total       ?? 0,
            subtasks_done:    r.subtasks_done    ?? r.progress?.subtasks_approved ?? 0,
            subtasks_total:   r.subtasks_total   ?? r.progress?.subtasks_total    ?? 0,
        }))

        tableData.value = rows

        if (s) {
            summary.value = {
                won: +s.won || 0,
                important: +s.important || 0,
                normal: +s.normal || 0,
                overdue: +s.overdue || 0,
                lost: +s.lost || 0,
                total: +s.total || 0,
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



const goToDetail = (id) => {
    router.push({name: 'bid-detail', params: {id}})
}

// 🔒 Chỉ các field BE cho phép
const ALLOWED_FIELDS = [
    'title','description','customer_id','estimated_cost','status',
    'start_date','end_date','assigned_to','manager_id','collaborators','priority'
]

// 🧹 Build payload sạch để gửi lên
const buildBiddingPayload = (src) => {
    const payload = {
        title: (src.title || '').trim(),
        description: (src.description || '').trim(),
        // lấy id thật từ select label-in-value hoặc giữ nguyên nếu đã là id
        customer_id: src.customer?.value ?? src.customer_id ?? null,
        estimated_cost: Number(src.estimated_cost) || 0,
        status: Number(src.status),
        start_date: src.start_date ? dayjs(src.start_date).format('YYYY-MM-DD') : null,
        end_date: src.end_date ? dayjs(src.end_date).format('YYYY-MM-DD') : null,
        assigned_to: src.assigned_to ?? null,
        manager_id: src.manager_id ?? null,
        priority: Number(src.priority) || 0,
    }

    // Chắc chắn chỉ giữ các key whitelisted & bỏ undefined
    return Object.fromEntries(
        Object.entries(payload)
            .filter(([k, v]) => ALLOWED_FIELDS.includes(k) && v !== undefined)
    )
}

const submitForm = async () => {
    try {
        await formRef.value?.validate()
        loadingCreate.value = true

        const formatted = buildBiddingPayload(formData.value)

        if (selectedBidding.value) {
            // ⛔ không gửi created_at/updated_at; CI4 tự set updated_at
            // Kiểm tra chuyển trạng thái đặc biệt như bạn đang làm
            const prevStatus = Number(selectedBidding.value.status)
            const nextStatus = Number(formatted.status)

            if (prevStatus !== STATUS.WON && nextStatus === STATUS.WON) {
                const res = await canMarkBiddingAsCompleteAPI(selectedBidding.value.id)
                if (!res?.data?.allow) {
                    message.warning('Cần hoàn tất tất cả bước trước khi chuyển sang "Trúng thầu".')
                    return
                }
            }

            if (prevStatus !== STATUS.CANCELLED && nextStatus === STATUS.CANCELLED) {
                const ok = await confirmAsync({
                    title: 'Xác nhận hủy gói thầu',
                    content: 'Bạn chắc muốn chuyển trạng thái sang "Hủy thầu"?',
                    okButtonProps: { danger: true }
                })
                if (!ok) return
            }

            await updateBiddingAPI(selectedBidding.value.id, formatted)
            message.success('Cập nhật thành công')
        } else {
            const res = await createBiddingAPI(formatted)
            if (formatted.status === STATUS.PREPARING) {
                await cloneFromTemplatesAPI(res.data.id)
            }
            message.success('Tạo gói thầu thành công')
        }

        onCloseDrawer()
        await getBiddings()
    } catch (e) {
        console.error('Lỗi submitForm:', e?.response?.data || e)
        message.error(e?.response?.data?.message || 'Có lỗi xảy ra')
    } finally {
        loadingCreate.value = false
    }
}

const confirmAsync = (opts) =>
    new Promise(resolve => {
        Modal.confirm({
            centered: true,
            okText: 'Đồng ý',
            cancelText: 'Huỷ',
            ...opts,
            onOk: () => resolve(true),
            onCancel: () => resolve(false),
        })
    })


const deleteConfirm = async (id) => {
    try {
        // Gọi API xoá (bạn cần có API deleteBiddingAPI tương ứng)
        await deleteBiddingAPI(id)
        message.success('Xoá gói thầu thành công')
        await getBiddings()
    } catch (e) {
        message.error('Xoá gói thầu thất bại')
    }
}

const showPopupDetail = (record) => {
    selectedBidding.value = record
    const id = record.customer_id != null ? Number(record.customer_id) : null

    // chuẩn hoá collaborators về mảng id cho form select (nếu bạn có UI chọn)
    let collaborators = []
    if (Array.isArray(record.collaborators)) collaborators = record.collaborators
    else if (typeof record.collaborators === 'string' && record.collaborators.trim()) {
        try { collaborators = JSON.parse(record.collaborators) } catch {
            collaborators = record.collaborators.split(',').map(n => Number(n)).filter(Boolean)
        }
    }

    formData.value = {
        ...record,
        status: Number(record.status),
        start_date: dayjs(record.start_date),
        end_date: dayjs(record.end_date),
        customer: id ? { value: id, label: record.customer_name || customerLabelById(id) || `#${id}` } : null,
        priority: record.priority != null ? Number(record.priority) : 0,
        collaborators, // để UI hiển thị chọn lại
    }
    openDrawer.value = true
}


const onCloseDrawer = () => {
    openDrawer.value = false
    selectedBidding.value = null
    formRef.value?.resetFields()
}

const showPopupCreate = () => {
    selectedBidding.value = null
    formRef.value?.resetFields()
    formData.value = {
        title: '',
        description: '',
        customer_id: null,
        estimated_cost: 0,
        status: STATUS.PREPARING,
        priority: PRIORITY.NORMAL,
        start_date: null,
        end_date: null,
        assigned_to: null
    }
    openDrawer.value = true
}

onMounted(() => {
    fetchUsers()
    getBiddings()
})

</script>


<style>
.summary-cards .ant-card-body {
    cursor: pointer;
}

.title_chart {
    text-align: center;
    color: rgb(170, 170, 170);
}

:deep(.ant-table-tbody > tr:hover) {
    background-color: #f5faff !important;
    transition: background-color 0.3s;
}
.progress-cell {
    display: flex;
    align-items: center;
    gap: 8px;
    min-width: 170px;
}
.progress-cell :deep(.ant-progress) { flex: 1; }
.progress-text { white-space: nowrap; font-size: 12px; color: rgba(0,0,0,.65); }

</style>

<style scoped>
.icon-action {
    font-size: 18px;
    margin-right: 24px;
    cursor: pointer;
}

.summary-cards {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
}

.summary-cards .ant-card {
    flex: 1;
    min-width: 200px;
    text-align: center;
}

.no-tasks {
    text-align: center;
    padding: 32px;
    font-style: italic;
}

/* viền trái đỏ + padding nhẹ cho ô quá hạn */
:deep(.overdue-cell) {
    border-left: 3px solid #ff4d4f;
    padding-left: 8px;
}
</style>