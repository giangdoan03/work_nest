<template>
    <div>
            <a-card bordered>
                <div style="margin-bottom: 10px">
                    <a-flex justify="space-between" align="center">
                        <div style="display:flex;align-items:center;gap:8px;">
                            <a-typography-title :level="4" style="margin:0">Danh sách gói thầu</a-typography-title>
                            <a-badge :count="totalDisplay" show-zero />
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
                                    <SearchOutlined />
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
                        :style="{ backgroundColor: item.bg, cursor: 'pointer' }"
                        @click="openBidDrawer(item.key, item.label)"
                    >
                        <a-space direction="vertical" align="center">
                            <component :is="item.icon" :style="{ fontSize: '32px', color: item.color }" />
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
                    :scroll="{ x: 'max-content' }"
                    :row-selection="rowSelection"
                    @change="handleTableChange"
                >
                    <!-- SLOT an toàn: dùng biến 'slot' -->
                    <template #bodyCell="slot">
                        <!-- STT -->
                        <template v-if="slot.column?.dataIndex === 'stt'">
                            {{ (pagination.current - 1) * pagination.pageSize + slot.index + 1 }}
                        </template>

                        <!-- Tiêu đề -->
                        <template v-else-if="slot.column?.key === 'title'">
                            <a-tooltip :title="slot.record.title">
                                <a-typography-text strong style="cursor: pointer" @click="goToDetail(slot.record.id)">
                                    {{ truncateText(slot.record.title, 25) }}
                                </a-typography-text>
                            </a-tooltip>
                        </template>

                        <!-- Tiến độ -->
                        <template v-else-if="slot.column?.dataIndex === 'progress'">
                            <a-tooltip :title="progressText(slot.record)">
                                <a-progress
                                    :percent="progressPercent(slot.record)"
                                    :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"
                                    :status="progressPercent(slot.record) >= 100 ? 'success' : 'active'"
                                    size="small"
                                    :show-info="progressPercent(slot.record) >= 100"
                                    style="cursor: pointer;"
                                    @click="openProgressModal(slot.record)"
                                />
                            </a-tooltip>
                        </template>

                        <!-- Tiến độ (theo mốc thời gian start_date → end_date) -->
                        <!-- Tiến độ (theo mốc thời gian + rule 90%/100%) -->
                        <!--                <template v-else-if="slot.column?.dataIndex === 'progress'">-->
                        <!--                    <a-tooltip :title="timeProgressText(slot.record)">-->
                        <!--                        <a-progress-->
                        <!--                            :percent="visualProgressPercent(slot.record)"-->
                        <!--                            :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"-->
                        <!--                            :status="visualProgressPercent(slot.record) >= 100 ? 'success' : 'active'"-->
                        <!--                            size="small"-->
                        <!--                            :show-info="visualProgressPercent(slot.record) >= 100"-->
                        <!--                            style="cursor: pointer;"-->
                        <!--                            @click="openProgressModal(slot.record)"-->
                        <!--                        />-->
                        <!--                    </a-tooltip>-->
                        <!--                </template>-->

                        <!-- Người phụ trách -->
                        <template v-else-if="slot.column?.dataIndex === 'assigned_to_name'">
                            <a-tooltip
                                :title="slot.record.assigned_to_name || 'N/A'"
                                placement="topLeft"
                                :mouseEnterDelay="0.2"
                            >
                                <BaseAvatar
                                    :src="slot.record.assigned_to_avatar_url || slot.record.assigned_to_avatar"
                                    :name="slot.record.assigned_to_name || 'N/A'"
                                    :size="24"
                                    shape="circle"
                                    :preferApiOrigin="true"
                                />
                            </a-tooltip>
                        </template>

                        <!-- Chi phí -->
                        <template v-else-if="slot.column?.dataIndex === 'estimated_cost'">
                            {{ formatCurrency(slot.record.estimated_cost) }}
                        </template>

                        <!-- Độ ưu tiên -->
                        <template v-else-if="slot.column?.dataIndex === 'priority'">
                            <a-tag :color="Number(slot.record.priority) === 1 ? 'red' : 'blue'">
                                {{ Number(slot.record.priority) === 1 ? 'Cao' : 'Bình thường' }}
                            </a-tag>
                        </template>

                        <!-- Trạng thái -->
                        <template v-else-if="slot.column?.dataIndex === 'status'">
                            <a-tag v-if="Number(slot.record.status) === STATUS.PREPARING" color="blue">Đang chuẩn bị</a-tag>
                            <a-tag v-else-if="Number(slot.record.status) === STATUS.WON" color="green">Trúng thầu</a-tag>
                            <a-tag v-else-if="Number(slot.record.status) === STATUS.SENT_FOR_APPROVAL" color="gold">Gửi phê duyệt</a-tag>
                            <a-tag v-else-if="Number(slot.record.status) === STATUS.CANCELLED" color="gray">Hủy thầu</a-tag>
                            <span v-else style="color:#999">—</span>
                        </template>
                        <!-- Cột Phê duyệt trong template -->
                        <template v-else-if="slot.column?.dataIndex === 'approval_status'">
                            <a-space direction="vertical" size="small">
                                <a-space>
                                    <a-tag :color="getApprovalColor(slot.record.approval_status)">
                                        {{ getApprovalText(slot.record.approval_status) }}
                                    </a-tag>
                                    <a-badge
                                        v-if="slot.record.approval_steps?.length"
                                        :count="`${Number(slot.record.current_level ?? 0) + 1}/${slot.record.approval_steps.length}`"
                                    />
                                </a-space>
                            </a-space>
                        </template>
                        <!-- Ngày -->
                        <template v-else-if="slot.column?.dataIndex === 'start_date' || slot.column?.dataIndex === 'end_date'">
                            {{ formatDate(slot.record[slot.column.dataIndex]) }}
                        </template>

                        <!-- Hạn -->
                        <template v-else-if="slot.column?.dataIndex === 'due'">
                            <div :class="{ 'overdue-cell': Number(slot.record.days_overdue) > 0 }">
                                <a-tag v-if="slot.record.days_remaining > 0" color="green">Còn {{ slot.record.days_remaining }} ngày</a-tag>
                                <a-tag v-else-if="slot.record.days_remaining === 0 && slot.record.days_overdue === 0" color="gold">Hạn chót hôm nay</a-tag>
                                <a-tag v-else-if="slot.record.days_overdue > 0" color="red">Quá hạn {{ slot.record.days_overdue }} ngày</a-tag>
                                <a-tag v-else color="default">Không xác định</a-tag>
                            </div>
                        </template>

                        <!-- Hành động (chỉ ở cột action) -->
                        <template v-else-if="slot.column?.dataIndex === 'action'">
                            <a-tooltip title="Xem chi tiết">
                                <EyeOutlined class="icon-action" style="color:#52c41a;" @click="goToDetail(slot.record.id)" />
                            </a-tooltip>

                            <!-- Gửi phê duyệt lần đầu -->
                            <a-tooltip
                                v-if="Number(slot.record.status) === STATUS.PREPARING && (slot.record.approval_status ?? 'pending') === APPROVAL_STATUS.PENDING"
                                title="Gửi phê duyệt"
                            >
                                <SendOutlined class="icon-action" style="color:#faad14;" @click="openSendApproval(slot.record)" />
                            </a-tooltip>

                            <!-- 👇 Gửi duyệt lại khi đã bị từ chối -->
                            <a-tooltip
                                v-else-if="(slot.record.approval_status ?? '') === APPROVAL_STATUS.REJECTED"
                                title="Gửi lại phê duyệt"
                            >
                                <SendOutlined class="icon-action" style="color:#faad14;" @click="openSendApproval(slot.record)" />
                            </a-tooltip>
                            <template
                                v-if="Number(slot.record.status) === STATUS.SENT_FOR_APPROVAL && (slot.record.approval_status ?? 'pending') === APPROVAL_STATUS.PENDING">
                                <!--                        <a-tooltip title="Phê duyệt">-->
                                <!--                            <CheckOutlined class="icon-action" style="color:#52c41a;" @click="approveCurrentLevel(slot.record)" />-->
                                <!--                        </a-tooltip>-->
                                <!--                        <a-tooltip title="Từ chối">-->
                                <!--                            <CloseOutlined class="icon-action" style="color:#ff4d4f;" @click="rejectCurrentLevel(slot.record)" />-->
                                <!--                        </a-tooltip>-->
                                <!-- Sửa người duyệt -->
                                <a-tooltip title="Sửa người duyệt">
                                    <UserSwitchOutlined
                                        class="icon-action"
                                        style="color:#13c2c2"
                                        @click="editApproval(slot.record)"
                                    />
                                </a-tooltip>
                            </template>

                            <a-tooltip title="Chỉnh sửa">
                                <EditOutlined class="icon-action" style="color:#1890ff;" @click="showPopupDetail(slot.record)" />
                            </a-tooltip>

                            <a-popconfirm
                                title="Bạn chắc chắn muốn xoá gói thầu này?"
                                ok-text="Xoá"
                                cancel-text="Huỷ"
                                @confirm="deleteConfirm(slot.record.id)"
                                placement="topRight"
                            >
                                <a-tooltip title="Xoá">
                                    <DeleteOutlined class="icon-action" style="color:red;" />
                                </a-tooltip>
                            </a-popconfirm>
                        </template>
                    </template>
                </a-table>
            </a-card>

        <!-- Drawer danh sách theo card -->
        <a-drawer
            title="Thông tin gói thầu"
            :width="700"
            :open="openDrawer"
            :footer-style="{ textAlign: 'right' }"
            @close="onCloseDrawer"
        >
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-form-item label="Tên gói thầu" name="title">
                    <a-input v-model:value="formData.title" placeholder="Nhập tên gói thầu" />
                </a-form-item>
                <a-form-item label="Chi tiết mô tả" name="description">
                    <a-textarea v-model:value="formData.description" :rows="3" placeholder="Nhập mô tả chi tiết" />
                </a-form-item>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Ngày bắt đầu" name="start_date">
                            <a-date-picker v-model:value="formData.start_date" style="width:100%" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Ngày kết thúc" name="end_date">
                            <a-date-picker v-model:value="formData.end_date" style="width:100%" />
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Chi phí dự toán" name="estimated_cost">
                            <a-input-number v-model:value="formData.estimated_cost" style="width:100%" :min="0" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Khách hàng" name="customer">
                            <a-select
                                v-model:value="formData.customer"
                                label-in-value
                                :options="customerOptions"
                                placeholder="Chọn khách hàng"
                                show-search
                            />
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Người quản lý" name="manager_id">
                            <a-select v-model:value="formData.manager_id" :options="userOptions" placeholder="Chọn người quản lý" allow-clear />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Người phụ trách" name="assigned_to">
                            <a-select v-model:value="formData.assigned_to" :options="userOptions" placeholder="Chọn người phụ trách" />
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Ưu tiên" name="priority">
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
                        <a-form-item label="Trạng thái" name="status">
                            <a-select v-model:value="formData.status" :options="editableStatusOptions" placeholder="Chọn trạng thái" />
                        </a-form-item>
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

        <!-- Drawer danh sách theo card (mới) -->
        <a-drawer
            v-model:open="drawerBidVisible"
            :title="`Danh sách: ${drawerBidTitle}`"
            :width="1200"
            destroyOnClose
            :footer="null"
        >
            <a-table
                :columns="drawerBidColumns"
                :data-source="drawerBidData"
                :loading="drawerLoading"
                row-key="id"
                :pagination="drawerPagination"
                :scroll="{ x: 'max-content' }"
                @change="handleDrawerTableChange"
            >
                <template #bodyCell="slot">
                    <!-- STT -->
                    <template v-if="slot.column?.dataIndex === 'index'">
                        {{ (drawerPagination.current - 1) * drawerPagination.pageSize + slot.index + 1 }}
                    </template>

                    <!-- Tên gói thầu -->
                    <template v-else-if="slot.column?.key === 'title'">
                        <a-tooltip :title="slot.record.title">
                            <a-typography-text strong style="cursor:pointer" @click="goToDetail(slot.record.id)">
                                {{ truncateText(slot.record.title, 32) }}
                            </a-typography-text>
                        </a-tooltip>
                    </template>

                    <!-- Tiến độ -->
                    <template v-else-if="slot.column?.dataIndex === 'progress'">
                        <a-tooltip :title="progressText(slot.record)">
                            <a-progress
                                :percent="progressPercent(slot.record)"
                                size="small"
                                :status="progressPercent(slot.record) >= 100 ? 'success' : 'active'"
                                :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"
                            />
                        </a-tooltip>
                    </template>

                    <!-- Người phụ trách -->
                    <template v-else-if="slot.column?.dataIndex === 'assigned_to_name'">
                        <a-tooltip :title="slot.record.assigned_to_name || 'N/A'">
                            <a-avatar :style="{ backgroundColor: getAvatarColor(slot.record.assigned_to_name || 'N/A') }" size="small">
                                {{ getFirstLetter(slot.record.assigned_to_name || '?') }}
                            </a-avatar>
                        </a-tooltip>
                    </template>

                    <!-- Độ ưu tiên -->
                    <template v-else-if="slot.column?.dataIndex === 'priority'">
                        <a-tag :color="Number(slot.record.priority) === 1 ? 'red' : 'blue'">
                            {{ Number(slot.record.priority) === 1 ? 'Quan trọng' : 'Bình thường' }}
                        </a-tag>
                    </template>

                    <!-- Trạng thái -->
                    <template v-else-if="slot.column?.dataIndex === 'status'">
                        <a-tag v-if="Number(slot.record.status) === STATUS.PREPARING" color="blue">Đang chuẩn bị</a-tag>
                        <a-tag v-else-if="Number(slot.record.status) === STATUS.WON" color="green">Trúng thầu</a-tag>
                        <a-tag v-else-if="Number(slot.record.status) === STATUS.SENT_FOR_APPROVAL" color="gold">Gửi phê duyệt</a-tag>
                        <a-tag v-else-if="Number(slot.record.status) === STATUS.CANCELLED" color="gray">Hủy thầu</a-tag>
                        <span v-else style="color:#999">—</span>
                    </template>

                    <!-- Ngày -->
                    <template v-else-if="slot.column?.dataIndex === 'start_date' || slot.column?.dataIndex === 'end_date'">
                        {{ formatDate(slot.record[slot.column.dataIndex]) }}
                    </template>

                    <!-- Hạn -->
                    <template v-else-if="slot.column?.dataIndex === 'due'">
                        <div :class="{ 'overdue-cell': Number(slot.record.days_overdue) > 0 }">
                            <a-tag v-if="slot.record.days_remaining > 0" color="green">Còn {{ slot.record.days_remaining }} ngày</a-tag>
                            <a-tag v-else-if="slot.record.days_remaining === 0 && slot.record.days_overdue === 0" color="gold">Hạn chót hôm nay</a-tag>
                            <a-tag v-else-if="slot.record.days_overdue > 0" color="red">Quá hạn {{ slot.record.days_overdue }} ngày</a-tag>
                            <a-tag v-else color="default">Không xác định</a-tag>
                        </div>
                    </template>
                </template>
            </a-table>
        </a-drawer>



        <!-- Modal chọn người duyệt -->
        <a-modal
            v-model:open="sendApprovalVisible"
            title="Chọn người duyệt (≥ 1 cấp)"
            :confirm-loading="loadingCreate"
            @ok="confirmSendApproval"
        >
            <a-form layout="vertical">
                <a-form-item label="Người duyệt (theo thứ tự cấp 1 → cấp 2)">
                    <a-select
                        v-model:value="approverIdsSelected"
                        mode="multiple"
                        :options="userOptions"
                        placeholder="Chọn ít nhất 1 người duyệt"
                        :max-tag-count="3"
                    />
                </a-form-item>
                <a-alert type="info" show-icon>
                    Thứ tự người duyệt sẽ theo thứ tự bạn chọn trong danh sách.
                </a-alert>
            </a-form>
        </a-modal>
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
    SearchOutlined,
    SendOutlined,      // 👈 THÊM
    CheckOutlined,     // 👈 THÊM (duyệt)
    CloseOutlined,     // 👈 THÊM (từ chối)
    UserSwitchOutlined
} from '@ant-design/icons-vue';
import dayjs from 'dayjs'
import {
    getBiddingsAPI,
    createBiddingAPI,
    cloneFromTemplatesAPI, deleteBiddingAPI,
    sendBiddingForApprovalAPI,  // 👈 THÊM
    approveBiddingAPI,          // 👈 THÊM
    rejectBiddingAPI, updateApprovalStepsAPI            // 👈 THÊM
} from '@/api/bidding'
import {updateBiddingAPI, canMarkBiddingAsCompleteAPI} from "../api/bidding";
import {formatDate} from '@/utils/formUtils' // nếu bạn đã có
import {getUsers} from '@/api/user.js'

import {useRouter} from 'vue-router'
import {updateTask} from "@/api/task.js";
import {getCustomers} from "@/api/customer.js";
import BaseAvatar from "@/components/common/BaseAvatar.vue";

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
const usersMap = ref({})

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
    {title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'left'},
    {title: 'Ưu tiên', dataIndex: 'priority', key: 'priority'},
    {title: 'Trạng thái', dataIndex: 'status', key: 'status'},
    {title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date'},
    {title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date'},
    {title: 'Hạn', dataIndex: 'due', key: 'due'}
]

const columns = [
    {title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px'},
    {title: 'Tên gói thầu', dataIndex: 'title', key: 'title'},
    {title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: '150px', align: 'center'},
    {title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'center'},
    {title: 'Chi phí dự toán', dataIndex: 'estimated_cost', key: 'estimated_cost'},
    {title: 'Ưu tiên', dataIndex: 'priority', key: 'priority'},
    // {title: 'Trạng thái', dataIndex: 'status', key: 'status', align: 'center'},
    {title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date'},
    {title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date'},
    {title: 'Hạn', dataIndex: 'due', key: 'due', align: 'center'},
    { title: 'Phê duyệt', dataIndex: 'approval_status', key: 'approval_status', width: 150 },
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

const sendApprovalVisible = ref(false)
const sendApprovalTarget  = ref(null)
const approverIdsSelected = ref([]) // tối thiểu 2 id

// ==== APPROVAL ====
const APPROVAL_STATUS = Object.freeze({
    PENDING: 'pending',
    APPROVED: 'approved',
    REJECTED: 'rejected',
})
const APPROVAL_STATUS_MAP = {
    [APPROVAL_STATUS.PENDING]:  { text: 'Chưa duyệt',   color: 'gold' },
    [APPROVAL_STATUS.APPROVED]: { text: 'Đã duyệt',    color: 'green' },
    [APPROVAL_STATUS.REJECTED]: { text: 'Bị từ chối',  color: 'red' },
}
const getApprovalText  = s => (APPROVAL_STATUS_MAP[s]?.text ?? '—')
const getApprovalColor = s => (APPROVAL_STATUS_MAP[s]?.color ?? 'default')


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
const STATUS = Object.freeze({
    PREPARING: 1,
    WON: 2,
    CANCELLED: 3,
    SENT_FOR_APPROVAL: 4,
})

const PRIORITY = Object.freeze({ NORMAL: 0, IMPORTANT: 1 })

const STATUS_MAP = {
    [STATUS.PREPARING]:        { text: 'Đang chuẩn bị',  color: 'blue' },
    [STATUS.WON]:              { text: 'Trúng thầu',     color: 'green' },
    [STATUS.CANCELLED]:        { text: 'Hủy thầu',       color: 'gray' },
    [STATUS.SENT_FOR_APPROVAL]:{ text: 'Gửi phê duyệt',  color: 'gold' },
}

const PRIORITY_MAP = {
    [PRIORITY.NORMAL]: {text: 'Bình thường', color: 'blue'},
    [PRIORITY.IMPORTANT]: {text: 'Cao', color: 'red'},
};

// Chỉ 2 card có thể gọi API theo status trực tiếp
const CARD_STATUS_MAP = {won: STATUS.WON, lost: STATUS.CANCELLED};

const EDITABLE_STATUS_KEYS = [STATUS.PREPARING, STATUS.CANCELLED, STATUS.SENT_FOR_APPROVAL]

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






// Tính % theo thời gian (0..100) – inclusive ngày đầu/cuối
const timeProgressPercentRaw = (r) => {
    if (!r?.start_date || !r?.end_date) {
        // thiếu ngày thì fallback về % từ server
        return Number(r?.progress_percent ?? r?.progress?.bidding_progress ?? 0)
    }
    const start = dayjs(r.start_date).startOf('day')
    const end   = dayjs(r.end_date).startOf('day')
    if (!start.isValid() || !end.isValid()) {
        return Number(r?.progress_percent ?? r?.progress?.bidding_progress ?? 0)
    }

    let totalDays = end.diff(start, 'day') + 1
    if (totalDays <= 0) totalDays = 1

    const today = dayjs().startOf('day')

    let elapsed
    if (today.isBefore(start))      elapsed = 0
    else if (today.isAfter(end))    elapsed = totalDays
    else                            elapsed = today.diff(start, 'day') + 1

    const pct = Math.round((elapsed / totalDays) * 100)
    return Math.max(0, Math.min(100, pct))
}

// % cuối cùng để hiển thị theo yêu cầu “90% khi quá hạn, 100% chỉ khi đã duyệt”
const visualProgressPercent = (r) => {
    const isApproved = (r?.approval_status ?? 'pending') === 'approved'
    const byTime = timeProgressPercentRaw(r)

    // nếu không có ngày, đã fallback byWork ở trên; áp tiếp rule 100% chỉ khi approved
    if (!r?.start_date || !r?.end_date) {
        return isApproved ? 100 : Math.min(byTime, 99)
    }

    const end = dayjs(r.end_date).startOf('day')
    const today = dayjs().startOf('day')

    if (isApproved) return 100                    // chỉ khi đã duyệt

    // quá hạn -> max 90%
    if (today.isAfter(end)) return Math.min(byTime, 75)

    // chưa quá hạn nhưng ra 100% theo thời gian thì chặn 99%
    if (byTime >= 100) return 99

    return byTime
}

// Tooltip mô tả
const timeProgressText = (r) => {
    if (!r?.start_date || !r?.end_date) {
        return `Tiến độ: ${visualProgressPercent(r)}%`
    }
    const start = dayjs(r.start_date)
    const end   = dayjs(r.end_date)
    const today = dayjs()
    let phase = 'đang diễn ra'
    if (today.isBefore(start)) phase = 'chưa bắt đầu'
    else if (today.isAfter(end)) phase = 'đã kết thúc'

    const p = visualProgressPercent(r)
    return `Tiến độ theo thời gian: ${p}% (${phase}) ${start.format('DD/MM')} → ${end.format('DD/MM')}`
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
    // options cho select
    userOptions.value = res.data.map(u => ({ label: u.name, value: Number(u.id) }))
    // map id -> name cho hiển thị approver
    usersMap.value = Object.fromEntries(res.data.map(u => [Number(u.id), u.name]))
}


// trong BidList.vue
const editApproval = (row) => {
    sendApprovalTarget.value = row
    // nạp lại danh sách cũ vào modal
    const ids = (row.approval_steps || []).map(s => Number(s.approver_id)).filter(Boolean)
    approverIdsSelected.value = ids.length ? ids : (row.manager_id ? [Number(row.manager_id)] : [])
    sendApprovalVisible.value = true
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

        const parseApprovalSteps = (raw) => {
            let arr = []
            try {
                if (Array.isArray(raw)) arr = raw
                else if (typeof raw === 'string' && raw.trim()) arr = JSON.parse(raw)
            } catch (_) { arr = [] }

            // gắn tên từ usersMap (nếu có)
            return arr.map((s) => ({
                ...s,
                approver_id: Number(s.approver_id ?? s.id ?? s.user_id),
                approver_name: usersMap.value[Number(s.approver_id)] || null,
            }))
        }

        let rows = (data || []).map(r => {
            const steps = parseApprovalSteps(r.approval_steps)
            return {
                ...r,
                status: r.status != null ? Number(r.status) : null,
                priority: r.priority != null ? Number(r.priority) : 0,
                progress_percent: r.progress_percent ?? r.progress?.bidding_progress ?? 0,
                steps_done:       r.steps_done       ?? r.progress?.steps_completed   ?? 0,
                steps_total:      r.steps_total      ?? r.progress?.steps_total       ?? 0,
                subtasks_done:    r.subtasks_done    ?? r.progress?.subtasks_approved ?? 0,
                subtasks_total:   r.subtasks_total   ?? r.progress?.subtasks_total    ?? 0,
                approval_status:  r.approval_status ?? APPROVAL_STATUS.PENDING,
                approval_steps:   steps,                      // 👈 luôn là array chuẩn
                current_level:    Number(r.current_level ?? 0),
            }
        })


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


const openSendApproval = (row) => {
    sendApprovalTarget.value = row
    const prev = Array.isArray(row.approval_steps) ? row.approval_steps.map(s => Number(s.approver_id)).filter(Boolean) : []
    approverIdsSelected.value = prev.length ? prev : (row.manager_id ? [Number(row.manager_id)] : [])
    sendApprovalVisible.value = true
}

const confirmSendApproval = async () => {
    // ≥ 1 người duyệt
    if (!Array.isArray(approverIdsSelected.value) || approverIdsSelected.value.length === 0) {
        message.warning('Cần chọn tối thiểu 1 người duyệt.')
        return
    }

    // chuẩn hoá danh sách id
    const uniqueIds = [...new Set(approverIdsSelected.value.map(n => Number(n)).filter(Number.isInteger))]
    if (!uniqueIds.length) {
        message.warning('Danh sách người duyệt không hợp lệ.')
        return
    }

    const target = sendApprovalTarget.value
    if (!target?.id) {
        message.error('Thiếu thông tin gói thầu.')
        return
    }

    const status      = target.approval_status ?? APPROVAL_STATUS.PENDING
    const hasOldSteps = Array.isArray(target.approval_steps) && target.approval_steps.length > 0

    try {
        loadingCreate.value = true

        if (status === APPROVAL_STATUS.APPROVED) {
            // ✅ phiên trước đã duyệt xong → tạo phiên mới từ cấp 1
            const ok = await confirmAsync({
                title: 'Tạo phiên duyệt mới?',
                content: 'Phiên trước đã duyệt hoàn tất. Bạn có muốn tạo một phiên duyệt mới từ cấp 1?',
            })
            if (!ok) return

            await sendBiddingForApprovalAPI(target.id, uniqueIds) // /approvals/send (BE tự deactivate phiên cũ và +version)
            message.success('Đã tạo phiên duyệt mới.')
        } else if (status === APPROVAL_STATUS.REJECTED) {
            // 👉 Gửi lại từ đầu
            await sendBiddingForApprovalAPI(target.id, uniqueIds)
            message.success('Đã gửi lại phê duyệt.')
        } else if (hasOldSteps) {
            // 👉 Đang pending: reset về cấp 1 (kể cả khi danh sách không đổi)
            await updateApprovalStepsAPI(target.id, uniqueIds) // /approvals/{id}/steps (BE reset current_level=0, status=pending)
            message.success('Đã khởi động lại luồng phê duyệt từ cấp 1.')
        } else {
            // 👉 Lần đầu gửi
            await sendBiddingForApprovalAPI(target.id, uniqueIds)
            message.success('Đã gửi phê duyệt.')
        }

        // Đóng modal + refresh
        sendApprovalVisible.value = false
        approverIdsSelected.value = []
        sendApprovalTarget.value  = null
        await getBiddings()
    } catch (e) {
        const msg = e?.response?.data?.message
            || e?.response?.data?.errors?.approver_ids
            || 'Thao tác thất bại.'
        message.error(msg)
    } finally {
        loadingCreate.value = false
    }
}




const approveCurrentLevel = async (row) => {
    try {
        const ok = await confirmAsync({
            title: 'Phê duyệt cấp hiện tại?',
            content: `Bạn xác nhận phê duyệt cấp ${Number(row.current_level ?? 0) + 1}/${row.approval_steps?.length || 0}?`,
            okText: 'Phê duyệt'
        })
        if (!ok) return
        await approveBiddingAPI(row.id)
        message.success('Đã phê duyệt.')
        await getBiddings()
    } catch (e) {
        console.error(e)
        message.error(e?.response?.data?.message || 'Phê duyệt thất bại.')
    }
}

const rejectCurrentLevel = async (row) => {
    try {
        const ok = await confirmAsync({
            title: 'Từ chối phê duyệt?',
            content: `Bạn chắc chắn từ chối ở cấp ${Number(row.current_level ?? 0) + 1}/${row.approval_steps?.length || 0}?`,
            okButtonProps: { danger: true },
            okText: 'Từ chối'
        })
        if (!ok) return
        await rejectBiddingAPI(row.id)
        message.success('Đã từ chối.')
        await getBiddings()
    } catch (e) {
        console.error(e)
        message.error(e?.response?.data?.message || 'Từ chối thất bại.')
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