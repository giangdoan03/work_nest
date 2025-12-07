<template>
    <div>
        <a-card>
            <a-page-header
                title="Chi tiết gói thầu"
                sub-title="Xem thông tin và tiến trình xử lý"
                @back="goBack"
                style="padding: 0 0 20px;"
            />
            <a-descriptions bordered :column="2">
                <!-- Hàng 1 -->
                <a-descriptions-item label="Tên"><strong>{{ bidding?.title }}</strong></a-descriptions-item>

                <a-descriptions-item label="Trạng thái">
                    <a-tag :color="getStatusColor(bidding?.status)">
                        {{ getStatusText(bidding?.status) }}
                    </a-tag>
                </a-descriptions-item>

                <!-- Hàng 2 -->
                <a-descriptions-item label="Giá trị">{{ formatCurrency(bidding?.estimated_cost) }}</a-descriptions-item>
                <a-descriptions-item label="Khách hàng">
                    <a @click="goToCustomerDetail(bidding?.customer_id)" style="color: #1890ff; cursor: pointer;">
                        {{ getCustomerName(bidding?.customer_id) }}
                    </a>
                </a-descriptions-item>

                <!-- Hàng 3 -->
                <a-descriptions-item label="Người phụ trách">
                    <a v-if="bidding?.assigned_to" @click="goToUserDetail(bidding.assigned_to)"
                       style="color: #1890ff; cursor: pointer;">
                        {{ getAssignedUserName(bidding?.assigned_to) }}
                    </a>
                    <span v-else>Không xác định</span>
                </a-descriptions-item>

                <a-descriptions-item label="Người giao việc">
                    <template v-if="bidding?.manager_id">
                        <a @click="goToUserDetail(bidding.manager_id)" style="color:#1890ff; cursor:pointer;">
                            {{ bidding?.manager_name || `Người #${bidding.manager_id}` }}
                        </a>
                    </template>
                    <span v-else>Không xác định</span>
                </a-descriptions-item>

                <a-descriptions-item label="Thời gian">
                    <div class="time-item start">
                        <span class="label">Bắt đầu:</span>
                        <span class="value">{{ formatDate(bidding?.start_date) }}</span>
                    </div>
                    <div class="time-item end">
                        <span class="label">Kết thúc:</span>
                        <span class="value">{{ formatDate(bidding?.end_date) }}</span>
                    </div>
                </a-descriptions-item>

                <a-descriptions-item label="Tiến độ">
                    <a-tooltip :title="detailProgressText(bidding)">
                        <div class="desc-progress">
                            <a-progress
                                :percent="detailProgressPercent(bidding)"
                                :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"
                                :status="isBiddingApproved(bidding) ? 'success' : 'active'"
                                size="small"
                                :show-info="false"
                            />
                        </div>
                    </a-tooltip>
                </a-descriptions-item>

                <!-- Hàng 4 -->
                <a-descriptions-item label="Mô tả">
                    {{ bidding?.description }}
                </a-descriptions-item>
                <!-- Hạn -->
                <a-descriptions-item label="Hạn">
                    <a-tag :color="deadlineColor(bidding)">
                        {{ deadlineText(bidding) }}
                    </a-tag>
                </a-descriptions-item>
                <!-- 👇 Người phối hợp (gom của TẤT CẢ bước) -->
                <a-descriptions-item label="Người thực hiện">
                    <template v-if="(bidding?.collaborators_detail?.length || 0) > 0">
                        <a-space size="small" align="center" wrap>
                            <a-avatar-group :maxCount="5" size="small">
                                <a-tooltip
                                    v-for="u in bidding.collaborators_detail"
                                    :key="u.id"
                                    :title="u.name || 'Không rõ'"
                                    placement="top"
                                >
                                    <a-avatar :style="{ backgroundColor: getAvatarColor(u.name) }">
                                        {{ getInitials(u.name) }}
                                    </a-avatar>
                                </a-tooltip>
                            </a-avatar-group>
                        </a-space>
                    </template>
                    <span v-else>—</span>
                </a-descriptions-item>
            </a-descriptions>

            <a-typography-title :level="5" class="mt-30 mb-30">Tiến trình xử lý</a-typography-title>

            <a-spin :spinning="loadingSteps">
                <a-steps direction="vertical" :current="currentStepIndex()">
                    <a-step v-for="(step, index) in steps" :key="step.id" :status="mapStepStatus(step.status)">
                        <template #title>
                            <div style="display:flex;justify-content:space-between;align-items:center;width:100%;">
                                <!-- Bên trái: tiêu đề + statistic -->
                                <div
                                    @click.stop="goToStepTasks(step)"
                                    @keydown.enter.prevent="goToStepTasks(step)"
                                    @keydown.space.prevent="goToStepTasks(step)"
                                    :class="{ 'active-step-title': activeStepId === step.id }"
                                    role="button" tabindex="0"
                                    style="display:flex;align-items:center;cursor:pointer;color:#1890ff;gap:12px;"
                                ><span style="text-decoration: underline;">
                                    Bước {{ step.step_number ?? '-' }}: {{ step.title ?? '-' }}
                            </span>
                                    <div style="display:flex;align-items:center;gap:6px;">
                                        <!-- Statistic -->
                                        <a-tooltip
                                            v-if="isAllTasksDone(step)"
                                            :title="tooltipDoneTitle(step)"
                                            placement="top"
                                        >
                                            <a-statistic
                                                :value="step.task_done_count ?? 0"
                                                :suffix="'/' + (step.task_count ?? 0) + ' task đã xong'"
                                                :value-style="{ fontSize: '13px', color: '#555' }"
                                            />
                                        </a-tooltip>
                                        <a-statistic
                                            v-else
                                            :value="step.task_done_count ?? 0"
                                            :suffix="'/' + (step.task_count ?? 0) + ' task đã xong'"
                                            :value-style="{ fontSize: '13px', color: '#555' }"
                                        />
                                    </div>
                                </div>

                                <!-- Bên phải: nút gửi duyệt -->
<!--                                <div>-->
<!--                                    <a-tooltip :title="stepSendUI(step).tip" placement="top">-->
<!--                                        <a-button type="link" size="small" :disabled="stepSendUI(step).disabled" @click.stop="onClickSend(step)">-->
<!--                                            <template #icon><SendOutlined/></template>-->
<!--                                            {{ stepSendUI(step).text }}-->
<!--                                        </a-button>-->
<!--                                    </a-tooltip>-->
<!--                                </div>-->
                            </div>
                        </template>

                        <template #description>
                            <a-descriptions
                                size="small"
                                :column="{ xs: 1, sm: 1, md: 2, lg: 2, xl: 2 }"
                                bordered
                                style="background: #fafafa; border-radius: 6px;"
                                :labelStyle="{ width: '200px' }"
                            >
                                <!-- Phòng ban -->
                                <a-descriptions-item label="Phòng ban">
                                    <a-tag
                                        v-for="(dep, i) in parseDepartment(step.department)"
                                        :key="i"
                                        color="blue"
                                        style="margin-right:4px"
                                    >{{ dep }}
                                    </a-tag>
                                </a-descriptions-item>

                                <!-- Ngày bắt đầu -->
                                <a-descriptions-item label="Ngày bắt đầu">
                                    <a-typography-text
                                        v-if="!isEditing(step, 'start')"
                                        type="secondary"
                                        @click.stop="editDateStart(step)"
                                    >
                                        {{ step.start_date ? formatDate(step.start_date) : '---' }}
                                        <EditOutlined/>
                                    </a-typography-text>
                                    <a-date-picker
                                        v-else
                                        style="width:100%"
                                        v-model:value="dateStart"
                                        :format="'YYYY-MM-DD'"
                                        :allowClear="true"
                                        :disabledDate="disabledStartDate"
                                        @change="updateStepStartDate"
                                    />
                                </a-descriptions-item>

                                <!-- Trạng thái -->
                                <a-descriptions-item label="Trạng thái">
                                    <a-popover
                                        :open="openStatusForId === step.id"
                                        trigger="click"
                                        placement="bottomLeft"
                                        @openChange="(v) => openStatusForId = v ? step.id : null"
                                    >
                                        <template #content>
                                            <a-select
                                                style="width:180px"
                                                :value="String(step.status)"
                                                @change="(val) => onChangeStatus(step, val)"
                                            >
                                                <a-select-option value="0">Chưa bắt đầu</a-select-option>
                                                <a-select-option value="1">Đang xử lý</a-select-option>
                                                <a-select-option value="2">Hoàn thành</a-select-option>
                                                <a-select-option value="3">Bỏ qua</a-select-option>
                                            </a-select>
                                        </template>

                                        <a-tag :color="getStepStatusColor(step.status)" class="status-tag">
                                            {{ statusText(step.status) }}
                                            <EditOutlined style="margin-left:6px;font-size:14px"/>
                                        </a-tag>
                                    </a-popover>
                                </a-descriptions-item>

                                <!-- Ngày kết thúc -->
                                <a-descriptions-item label="Ngày kết thúc">
                                    <a-typography-text
                                        v-if="!isEditing(step, 'end')"
                                        type="secondary"
                                        @click.stop="editDateEnd(step)"
                                    >
                                        {{ step.end_date ? formatDate(step.end_date) : '---' }}
                                        <EditOutlined/>
                                    </a-typography-text>
                                    <a-date-picker
                                        v-else
                                        style="width:100%"
                                        v-model:value="dateEnd"
                                        :format="'YYYY-MM-DD'"
                                        :allowClear="true"
                                        :disabledDate="disabledEndDate"
                                        @change="updateStepEndDate"
                                    />
                                </a-descriptions-item>

                                <!-- Người phụ trách -->
                                <a-descriptions-item label="Người phụ trách">
                                    <a-popover
                                        :open="openAssignForId === step.id"
                                        trigger="click"
                                        placement="bottomLeft"
                                        @openChange="(v) => openAssignForId = v ? step.id : null"
                                    >
                                        <template #content>
                                            <a-select
                                                style="width:180px"
                                                :value="step.assigned_to || null"
                                                placeholder="Chọn người phụ trách"
                                                allowClear
                                                @change="(val) => onChangeAssigned(step, val)"
                                            >
                                                <a-select-option v-for="u in users" :key="u.id" :value="u.id">
                                                    {{ u.name }}
                                                </a-select-option>
                                            </a-select>
                                        </template>

                                        <span class="assigned-display">
                                      <a v-if="step.assigned_to" @click.stop.prevent style="color:#1890ff;">
                                        {{ getAssignedUserName(step.assigned_to) }}
                                      </a>
                                      <span v-else>Không xác định</span>
                                      <EditOutlined style="margin-left:6px;font-size:14px"/>
                                    </span>
                                    </a-popover>
                                </a-descriptions-item>

                                <!-- Hạn -->
                                <a-descriptions-item label="Hạn">
                                    <template v-if="deadlineInfo(step.end_date).type === 'overdue'">
                                        <a-tag color="error">Quá hạn {{ deadlineInfo(step.end_date).days }} ngày</a-tag>
                                    </template>
                                    <template v-else-if="deadlineInfo(step.end_date).type === 'today'">
                                        <a-tag color="#faad14">Hạn chót hôm nay</a-tag>
                                    </template>
                                    <template v-else-if="deadlineInfo(step.end_date).type === 'remaining'">
                                        <a-tag color="green">Còn {{ deadlineInfo(step.end_date).days }} ngày</a-tag>
                                    </template>
                                    <template v-else>—</template>
                                </a-descriptions-item>

                                <!-- Người phối hợp -->
                                <a-descriptions-item label="Người thực hiện">
                                    <template v-if="step.assignees_detail?.length">
                                        <a-avatar-group size="small" :maxCount="5">
                                            <a-tooltip
                                                v-for="u in step.assignees_detail"
                                                :key="u.id"
                                                :title="u.name || 'Không rõ'"
                                            >
                                                <a-avatar :style="{ backgroundColor: getAvatarColor(u.name) }">
                                                    {{ getInitials(u.name) }}
                                                </a-avatar>
                                            </a-tooltip>
                                        </a-avatar-group>
                                    </template>
                                    <span v-else>—</span>
                                </a-descriptions-item>
                            </a-descriptions>
                        </template>
                    </a-step>
                </a-steps>
            </a-spin>
        </a-card>
        <!-- Drawer hiển thị chi tiết bước -->
        <a-drawer
            title="Danh sách nhiệm vụ"
            placement="right"
            :visible="drawerVisible"
            @close="closeDrawer"
            width="1200"
        >
            <template v-if="selectedStep">
                <a-row :gutter="16" justify="end">
                    <a-col>
                        <a-button type="primary" @click="showPopupCreate">
                            Thêm nhiệm vụ mới
                        </a-button>
                    </a-col>
                </a-row>

                <!-- Nếu không có task -->
                <a-empty v-if="relatedTasks.length === 0" description="Không có công việc"/>

                <!-- Nếu có task -->
                <template v-else>
                    <!-- Header -->
                    <div style="
                          display: flex;
                          justify-content: space-between;
                          padding: 8px 0;
                          font-weight: 500;
                          color: #555;
                          border-bottom: 1px solid #f0f0f0;
                        "
                    >
                    </div>

                    <!-- Danh sách nhiệm vụ -->
                    <a-table
                        :columns="treeColumns"
                        :dataSource="relatedTasks"
                        rowKey="id"
                        :pagination="false"
                        :scroll="{ x: 'max-content'}"
                    >

                        <template #bodyCell="{ column, record, index }">
                            <!-- STT -->
                            <template v-if="column.key === 'index'">
                                {{ index + 1 }}
                            </template>

                            <!-- ➕ Nút thêm -->
                            <template v-else-if="column.key === 'add'">
                                <a-tooltip title="Thêm việc con cấp cuối cùng">
                                    <a-button
                                        type="text"
                                        shape="circle"
                                        @click.stop="openSubtaskDrawer(record)"
                                        :style="{ width: '30px', height: '32px', padding: 0 }"
                                    >
                                        <PlusOutlined/>
                                    </a-button>
                                </a-tooltip>
                            </template>

                            <!-- Tên công việc -->
                            <template v-else-if="column.dataIndex === 'title'">
                                <router-link :to="`/non-workflow/${record.id}/info`">
                                    <span
                                        class="task-title"
                                        :class="{ child: record.parent_id }"
                                    >
                                      {{ record.title }}
                                    </span>
                                </router-link>
                            </template>

                            <!-- Người thực hiện -->
                            <template v-else-if="column.dataIndex === 'assigned_to'">
                                {{ getAssignedUserName(record.assigned_to) }}
                            </template>

                            <!-- Tiến trình -->
                            <template v-else-if="column.dataIndex === 'progress'">
                                <a-progress
                                    :percent="detailProgressPercent(bidding)"
                                    :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"
                                    :status="isBiddingApproved(bidding) ? 'success' : 'active'"
                                    size="small"
                                    :show-info="false"
                                />
                            </template>

                            <!-- Ưu tiên -->
                            <template v-else-if="column.dataIndex === 'priority'">
                                <a-tag :color="getPriorityColor(record.priority)">
                                    {{ getPriorityText(record.priority) }}
                                </a-tag>
                            </template>

                            <!-- Bắt đầu / Kết thúc -->
                            <template v-else-if="column.dataIndex === 'start_date'">
                                {{ formatDate(record.start_date) }}
                            </template>
                            <template v-else-if="column.dataIndex === 'end_date'">
                                {{ formatDate(record.end_date) }}
                            </template>

                            <!-- Trạng thái -->
                            <template v-else-if="column.dataIndex === 'status'">
                                <a-tag :color="getTaskStatusColor(record.status)">
                                    {{ getTaskStatusText(record.status) }}
                                </a-tag>
                            </template>

                            <!-- Hạn (tính từ end_date) -->
                            <template v-else-if="column.dataIndex === 'deadline'">
                                <template v-if="deadlineInfo(record.end_date).type === 'overdue'">
                                    <a-tag color="error">Quá hạn {{ deadlineInfo(record.end_date).days }} ngày</a-tag>
                                </template>
                                <template v-else-if="deadlineInfo(record.end_date).type === 'today'">
                                    <a-tag :color="'#faad14'">Hạn chót hôm nay</a-tag>
                                </template>
                                <template v-else-if="deadlineInfo(record.end_date).type === 'remaining'">
                                    <a-tag color="green">Còn {{ deadlineInfo(record.end_date).days }} ngày</a-tag>
                                </template>
                                <template v-else>—</template>
                            </template>

                            <!-- Duyệt -->
                            <template v-else-if="column.dataIndex === 'approval_status'">
                                <template v-if="record.status === 'done' && record.approval_status === 'approved'">
                                    <a-tag color="green">Hoàn thành & Đã duyệt</a-tag>
                                </template>
                                <template v-else-if="record.status === 'done'">
                                    <a-tag :color="getApprovalStatusColor(record.approval_status)">
                                        {{ getApprovalStatusText(record.approval_status) }}
                                    </a-tag>
                                </template>
                                <template v-else>—</template>
                            </template>
                        </template>
                    </a-table>
                </template>
            </template>
        </a-drawer>

        <DrawerCreateSubtask
            :open="subDrawerOpen"
            :parentTask="subDrawerParent"
            :listUser="users"
            @update:open="v => subDrawerOpen = v"
            @created="handleSubtaskCreated"
        />


        <DrawerCreateTask
            v-model:open-drawer="openDrawer"
            :list-user="users"
            type="bidding"
            @submitForm="handleDrawerSubmit"
        />
    </div>
</template>

<script setup>
/* =========================
 * Imports
 * ========================= */
import { ref, onMounted, computed, reactive, shallowRef } from 'vue'
import dayjs from 'dayjs'
import viVN from 'ant-design-vue/es/locale/vi_VN'
import { message } from 'ant-design-vue'
import { useRoute, useRouter } from 'vue-router'
import {formatDate, formatCurrency} from '@/utils/formUtils'
import {
    getBiddingAPI,
    cloneFromTemplatesAPI,
    getBiddingStepsAPI,
    updateBiddingStepAPI,
    completeBiddingStepAPI
} from '@/api/bidding'
import { sendApproval } from '@/api/approvals'
import { getUsers } from '@/api/user.js'
import { getCustomers } from '../api/customer'
import { getTasks, getTasksByBiddingStep } from '@/api/task'
import { useUserStore } from '@/stores/user'
import { useStepStore } from '@/stores/step'
import { useCommonStore } from '@/stores/common'

// Icons có thể đang dùng trong template
import { SendOutlined, EditOutlined, MinusOutlined, PlusOutlined } from '@ant-design/icons-vue'

// Components có thể đang dùng trong template
import DrawerCreateTask from '@/components/common/DrawerCreateTask.vue'
import DrawerCreateSubtask from '@/components/common/DrawerCreateSubtask.vue'
import {addEntityMember, removeEntityMember} from "@/api/entityMembers.js";

dayjs.locale('vi')

/* =========================
 * Stores & Router
 * ========================= */
const userStore = useUserStore()
const stepStore = useStepStore()
const commonStore = useCommonStore()
const route = useRoute()
const router = useRouter()

/* =========================
 * Reactive State
 * ========================= */
const id = String(route.params.id ?? '')
const bidding = shallowRef({})
const steps = ref([])
const loadingSteps = ref(false)

const users = ref([])
const customers = ref([])

const drawerVisible = ref(false)
const selectedStep = ref(null)
const activeStepId = ref(null)

const openDrawer = ref(false) // DrawerCreateTask
const subDrawerOpen = ref(false) // DrawerCreateSubtask
const subDrawerParent = ref(null)

const showEditTitle = ref(false)
const editedTitle = ref('')

const dateStart = ref()
const dateEnd = ref()
const editing = reactive({ id: null, field: null })

const quickDrawerVisible = ref(false)
const quickDrawerRecord = ref(null)

const allTasks = ref([]) // nếu template cần
const relatedTasks = computed(() => stepStore.relatedTasks)
const loading = ref(false)

/** Bổ sung các ref còn thiếu để tránh lỗi runtime trong getInternalTask */
const dataFilter = ref({})
const tableData = ref([])
const pagination = ref({ current: 1, total: 0, pageSize: 10 })

/* =========================
 * Constants & Helpers
 * ========================= */
const PROGRESS_COLOR = '#1890ff'

const STATUS_TEXT = {
    1: 'Đang chuẩn bị',
    2: 'Trúng thầu',
    3: 'Hủy thầu'
}
const STEP_STATUS_TEXT = { '0': 'Chưa bắt đầu', '1': 'Đang xử lý', '2': 'Đã hoàn thành', '3': 'Bỏ qua' }
const STEP_STATUS_COLOR = { '0': 'default', '1': 'blue', '2': 'green', '3': 'orange' }
const STEP_STATUS_MAP = { '0': 'wait', '1': 'process', '2': 'finish', '3': 'error' }
const APPROVAL_TEXT = { approved: 'Đã duyệt', pending: 'Chờ duyệt', rejected: 'Từ chối' }
const APPROVAL_COLOR = { approved: 'green', pending: 'blue', rejected: 'red', default: 'gray' }
const TASK_STATUS_TEXT = { todo: 'Chưa bắt đầu', doing: 'Đang làm', done: 'Hoàn thành', overdue: 'Trễ hạn' }
const TASK_STATUS_COLOR = { todo: 'default', doing: 'blue', done: 'green', overdue: 'red' }



// ===== Helpers bổ sung cho cột =====
const fmtDate = (v) => (v ? dayjs(v).format('DD/MM/YYYY') : '—')

const getPriorityText = (priority) =>
    ({ high: 'Cao', normal: 'Bình thường', low: 'Thấp' }[String(priority)] ?? 'Không xác định')

const getPriorityColor = (priority) =>
    ({ high: 'red', normal: 'orange', low: 'blue' }[String(priority)] ?? 'default')

// ===== Cột bảng cây nhiệm vụ (tree table) =====
const treeColumns = [
    { title: 'STT', key: 'index', width: 60, align: 'center', fixed: 'left',
        customRender: ({ index }) => index + 1
    },
    { title: 'Thêm việc con', key: 'add', width: 120, align: 'center', fixed: 'left' },
    { title: 'Tên công việc', dataIndex: 'title', key: 'title', width: 240, ellipsis: true },

    { title: 'Người thực hiện', dataIndex: 'assigned_to', key: 'assigned_to', width: 160,
        customRender: ({ text }) => getAssignedUserName(text)
    },

    { title: 'Tiến trình', dataIndex: 'progress', key: 'progress', width: 140, align: 'center',
        customRender: ({ text }) => `${Number(text ?? 0)}%`
    },

    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority', width: 120, align: 'center',
        customRender: ({ text }) => getPriorityText(text)
    },

    { title: 'Bắt đầu', dataIndex: 'start_date', key: 'start_date', width: 120, align: 'center',
        customRender: ({ text }) => fmtDate(text)
    },
    { title: 'Kết thúc', dataIndex: 'end_date', key: 'end_date', width: 120, align: 'center',
        customRender: ({ text }) => fmtDate(text)
    },

    { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 140, align: 'center',
        // task.status: 'todo' | 'doing' | 'done' | 'overdue'
        customRender: ({ text }) => getTaskStatusText(text)
    },

    { title: 'Hạn', dataIndex: 'deadline', key: 'deadline', width: 160, align: 'center',
        // dùng record để tính hạn theo end_date / days_remaining / days_overdue
        customRender: ({ record }) => deadlineText(record)
    },

    { title: 'Duyệt', dataIndex: 'approval_status', key: 'approval_status', width: 160, align: 'center',
        customRender: ({ text }) => getApprovalStatusText(text)
    }
]


const safeToNumber = v => (v === null || v === undefined || v === '' ? 0 : Number(v))
const tryParse = v => { try { return typeof v === 'string' ? JSON.parse(v) : v } catch { return null } }

/** Maps O(1) lookup */
const usersById = computed(() => {
    const m = Object.create(null)
    for (const u of users.value) m[String(u.id)] = u
    return m
})
const customersById = computed(() => {
    const m = Object.create(null)
    for (const c of customers.value) m[String(c.id)] = c
    return m
})

/* =========================
 * Derived / Business Logic
 * ========================= */
const isBiddingApproved = b => String(b?.approval_status) === 'approved' || Number(b?.status) === 2

const detailProgressPercent = b => {
    const base = safeToNumber(b?.progress?.bidding_progress)
    if (isBiddingApproved(b)) return 100

    const expired = safeToNumber(b?.days_overdue) > 0 || (!!b?.end_date && dayjs().isAfter(dayjs(b.end_date), 'day'))

    return expired && base > 90 ? 90 : base
}

const detailProgressText = b => {
    const p = detailProgressPercent(b)
    const done = safeToNumber(b?.progress?.steps_completed)
    const total = safeToNumber(b?.progress?.steps_total)
    if (!total) return 'Chưa có bước nào'
    if (isBiddingApproved(b)) return `Đã hoàn thành toàn bộ ${total} bước (100%)`
    if (done === 0) return `Chưa bắt đầu (${done}/${total} bước)`
    if (done < total) return `Đã hoàn thành ${done}/${total} bước (~${p}%)`
    return `Đã hoàn thành ${total}/${total} bước (~${p}%)`
}

const deadlineInfo = b => {
    if (!b || !b.end_date) return { text: 'Không xác định', color: 'default' }
    const r = safeToNumber(b.days_remaining)
    const o = safeToNumber(b.days_overdue)
    if (o > 0) return { text: `Quá hạn ${o} ngày`, color: 'red' }
    if (r > 0) return { text: `Còn ${r} ngày`, color: 'green' }
    return { text: 'Đến hạn hôm nay', color: 'orange' }
}

const getProgressStatus = p => {
    const progress = safeToNumber(p)
    if (progress >= 100) return 'success'
    if (progress >= 80) return 'normal'
    if (progress >= 50) return 'active'
    return 'exception'
}

const getInitials = name => {
    if (!name) return '?'
    const parts = name.trim().split(/\s+/)
    return (parts[0][0] + (parts[parts.length - 1]?.[0] || '')).toUpperCase()
}
const getFirstLetter = name => (!name || name === 'N/A' ? '?' : name.charAt(0).toUpperCase())

const getAvatarColor = name => {
    if (!name || name === 'N/A') return '#d9d9d9'
    const colors = [
        '#f5222d', '#fa8c16', '#fadb14', '#52c41a',
        '#13c2c2', '#1890ff', '#722ed1', '#eb2f96',
        '#fa541c', '#faad14', '#a0d911', '#52c41a',
        '#13c2c2', '#1890ff', '#722ed1', '#eb2f96'
    ]
    let hash = 0
    for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
    return colors[Math.abs(hash) % colors.length]
}

/* =========================
 * Step Approval Logic
 * ========================= */
const stepApprovalStatus = s => String(s?.approval_status || '').toLowerCase()
const isAllTasksDone = s => {
    const total = safeToNumber(s?.task_count)
    const done = safeToNumber(s?.task_done_count)
    return total >= 1 && done === total
}
const stepSendState = s => {
    const st = stepApprovalStatus(s)
    if (st === 'approved') return 'approved'
    if (st === 'pending') return 'sent'
    if (isAllTasksDone(s)) return 'canSend'
    return 'disabled'
}
const stepSendUI = s => {
    switch (stepSendState(s)) {
        case 'approved': return { text: 'Đã duyệt', disabled: true, tip: 'Bước đã được phê duyệt.' }
        case 'sent':     return { text: 'Đã gửi',   disabled: true, tip: 'Đang chờ phê duyệt.' }
        case 'canSend':  return { text: 'Gửi duyệt',disabled: false,tip: '🎯 Tất cả task đã hoàn thành. Nhấn để gửi duyệt.' }
        default:         return { text: 'Gửi duyệt',disabled: true, tip: 'Cần hoàn tất tất cả task (≥1 task và 100%).' }
    }
}
const onClickSend = step => {
    if (stepSendState(step) === 'canSend') sendStepForApproval(step)
}
const tooltipDoneTitle = s => {
    const total = safeToNumber(s?.task_count)
    const st = stepApprovalStatus(s)
    if (total < 1) return 'Bước này chưa có công việc. Hãy thêm ít nhất 1 task trước khi gửi duyệt.'
    if (st === 'approved') return '✅ Bước đã được phê duyệt.'
    if (st === 'pending') return '⏳ Đã gửi phê duyệt. Vui lòng chờ.'
    return '🎉 Tất cả task trong bước đã hoàn thành. Hãy bấm “Gửi duyệt” để hoàn tất bước.'
}
const pickApproverIds = s => {
    if (Array.isArray(s?.approver_ids)) return s.approver_ids.map(Number).filter(Boolean)
    const stepsArr = tryParse(s?.approval_steps)
    if (Array.isArray(stepsArr)) return stepsArr.map(x => Number(x?.approver_id)).filter(Boolean)
    if (Array.isArray(s?.approvers_detail)) return s.approvers_detail.map(x => Number(x?.id)).filter(Boolean)
    if (s?.assigned_to) return [Number(s.assigned_to)]
    return []
}
const sendStepForApproval = async step => {
    const approverIds = pickApproverIds(step)
    if (!approverIds.length) return message.warning('Chưa cấu hình người duyệt cho bước này')

    const payload = {
        target_type: 'bidding_step',
        target_id: Number(step.id),
        approver_ids: approverIds,
        meta: {
            title: `Bước ${step.step_number}: ${step.title}`,
            url: `/biddings/${bidding.value.id}/info`
        }
    }

    try {
        await sendApproval(payload)
        message.success('Đã gửi phê duyệt')
        step.approval_status = 'pending' // optimistic
        await fetchSteps()
    } catch (e) {
        console.error(e)
        message.error(e?.response?.data?.message || 'Không thể gửi phê duyệt')
    }
}

// ===== Deadline helpers (drop-in) =====
const toNum = (v) => {
    const n = Number(v)
    return Number.isFinite(n) ? n : 0
}

/**
 * Trả về { text, color, tag, daysRemaining, daysOverdue }
 * - color: 'red' | 'green' | 'orange' | 'default'
 * - tag: 'overdue' | 'remaining' | 'dueToday' | 'unknown'
 */
const computeDeadline = (b) => {
    if (!b || !b.end_date) {
        return { text: 'Không xác định', color: 'default', tag: 'unknown', daysRemaining: 0, daysOverdue: 0 }
    }

    let r = toNum(b.days_remaining ?? 0)
    let o = toNum(b.days_overdue ?? 0)

    // Fallback nếu BE chưa tính sẵn
    if (r === 0 && o === 0) {
        const diff = dayjs(b.end_date).startOf('day').diff(dayjs().startOf('day'), 'day')
        if (diff > 0) r = diff
        else if (diff < 0) o = Math.abs(diff)
    }

    if (o > 0) {
        return { text: `Quá hạn ${o} ngày`, color: 'red', tag: 'overdue', daysRemaining: r, daysOverdue: o }
    }
    if (r > 0) {
        return { text: `Còn ${r} ngày`, color: 'green', tag: 'remaining', daysRemaining: r, daysOverdue: 0 }
    }
    return { text: 'Đến hạn hôm nay', color: 'orange', tag: 'dueToday', daysRemaining: 0, daysOverdue: 0 }
}

// Giữ API như bạn đang gọi trong template:
const deadlineText  = (b) => computeDeadline(b).text
const deadlineColor = (b) => computeDeadline(b).color



/* =========================
 * Step Drawer & Tasks
 * ========================= */
const openStepDrawer = async step => {
    selectedStep.value = { ...step }
    stepStore.setSelectedStep({ ...step })
    activeStepId.value = step.id
    drawerVisible.value = true

    const filter = {}
    const user = userStore.currentUser || {}
    if (String(user.role_id) === '3') filter.assigned_to = user.id
    else if (String(user.role_id) === '2') filter.id_department = user.department_id

    try {
        const res = await getTasksByBiddingStep(step.id, filter)
        stepStore.setRelatedTasks(Array.isArray(res.data) ? res.data : [])
    } catch (e) {
        console.error('❌ Không thể tải công việc của bước', e)
        stepStore.setRelatedTasks([])
    }
}
const closeDrawer = () => {
    drawerVisible.value = false
    activeStepId.value = null
    dateStart.value = null
    dateEnd.value = null
    editing.id = null
    editing.field = null
}

const openSubtaskDrawer = parentRow => {
    subDrawerParent.value = {
        id: parentRow.id,
        linked_type: parentRow.linked_type ?? (stepStore.selectedStep ? 'bidding' : 'internal'),
        linked_id: parentRow.linked_id ?? commonStore.biddingIdParent ?? null,
        step_id: parentRow.step_id ?? stepStore.selectedStep?.id ?? null,
        step_code: parentRow.step_code ?? stepStore.selectedStep?.step_number ?? null,
        id_department: parentRow.id_department ?? null
    }
    subDrawerOpen.value = true
}

function handleSubtaskCreated(newTask) {
    const parentId = Number(newTask.parent_id)
    const list = stepStore.relatedTasks.slice()
    const parent = list.find(x => Number(x.id) === parentId)
    if (parent) {
        parent.children = parent.children || []
        parent.children.push(newTask)
    } else {
        list.push(newTask)
    }
    stepStore.setRelatedTasks(list)
}

/* =========================
 * Step inline edit (title/dates/status/assignee)
 * ========================= */
const isEditing = (step, field) => editing.id === step.id && editing.field === field
const editDateStart = step => {
    selectedStep.value = step
    dateStart.value = step.start_date ? dayjs(step.start_date) : null
    editing.id = step.id
    editing.field = 'start'
}
const editDateEnd = step => {
    selectedStep.value = step
    dateEnd.value = step.end_date ? dayjs(step.end_date) : null
    editing.id = step.id
    editing.field = 'end'
}
const disabledStartDate = current => {
    const end = dateEnd.value || (selectedStep.value?.end_date ? dayjs(selectedStep.value.end_date) : null)
    return !!(end && current && current > end.endOf('day'))
}
const disabledEndDate = current => {
    const start = dateStart.value || (selectedStep.value?.start_date ? dayjs(selectedStep.value.start_date) : null)
    return !!(start && current && current < start.startOf('day'))
}
const updateStepDate = async (field, date, step) => {
    try {
        const payload = { [field]: date ? dayjs(date).format('YYYY-MM-DD') : null }
        await updateBiddingStepAPI(step.id, payload)
        message.success(`Đã cập nhật ${field === 'start_date' ? 'ngày bắt đầu' : 'ngày kết thúc'}`)
        step[field] = payload[field] // cập nhật local
        editing.id = null
        editing.field = null
        await fetchSteps()
    } catch (e) {
        console.error(`Lỗi cập nhật ${field}:`, e)
        message.error(`Không thể cập nhật ${field}`)
    }
}
const updateStepStartDate = v => updateStepDate('start_date', v, selectedStep.value)
const updateStepEndDate = v => updateStepDate('end_date', v, selectedStep.value)

const updateStepTitle = async () => {
    const title = editedTitle.value.trim()
    if (!title) return message.warning('Tiêu đề không được để trống')
    try {
        await updateBiddingStepAPI(selectedStep.value.id, { title })
        selectedStep.value.title = title
        message.success('Cập nhật tiêu đề thành công')
        showEditTitle.value = false
        await fetchSteps()
    } catch (e) {
        console.error('Không thể cập nhật tiêu đề bước', e)
        message.error('Lỗi khi cập nhật tiêu đề')
    }
}

const openStatusForId = ref(null)
const onChangeStatus = async (step, val) => {
    openStatusForId.value = step.id
    await updateStepStatus(Number(val), step)
    openStatusForId.value = null
}
const updateStepStatus = async (newStatus, step) => {
    try {
        if (Number(newStatus) === 2) {
            await completeBiddingStepAPI(step.id)
            message.success('Bước đã hoàn thành và bước kế tiếp đã được mở')
        } else {
            await updateBiddingStepAPI(step.id, { status: Number(newStatus) })
            message.success('Đã cập nhật trạng thái bước')
        }
        step.status = Number(newStatus) // optimistic
        drawerVisible.value = false
        await fetchData()
    } catch (e) {
        console.warn('⚠️ Lỗi cập nhật bước:', e)
        const errMsg =
            e?.response?.data?.messages?.error ||
            e?.response?.data?.message ||
            '❌ Đã xảy ra lỗi khi cập nhật bước'
        if (e?.response?.status === 400) message.warning(errMsg)
        else message.error(errMsg)
    }
}

const openAssignForId = ref(null)
const onChangeAssigned = async (step, val) => {
    openAssignForId.value = step.id
    const bidId = Number(route.params.id)

    // Cập nhật trong bước
    await updateStepAssignedTo(val, step)

    // Nếu chọn người mới
    if (val) {
        try {
            await addEntityMember({
                entity_type: "bidding",
                entity_id: bidId,
                user_id: Number(val)
            })

            console.log("✔ Gán người phụ trách + thêm quyền truy cập:", val)
        } catch (e) {
            console.error("❌ Lỗi khi thêm quyền:", e)
        }
    } else {
        // Nếu clear → optional: xoá quyền
        try {
            await removeEntityMember({
                entity_type: "bidding",
                entity_id: bidId,
                user_id: Number(step.assigned_to)
            })
            console.log("✔ Gỡ người phụ trách + xoá quyền")
        } catch (e) {}
    }

    openAssignForId.value = null
}

const updateStepAssignedTo = async (userId, step) => {
    try {
        if (!userId) return message.warning('Vui lòng chọn người phụ trách hợp lệ')
        await updateBiddingStepAPI(step.id, { assigned_to: userId })
        step.assigned_to = userId // optimistic
        message.success('Đã cập nhật người phụ trách')
        await fetchSteps()
    } catch (e) {
        console.error('Lỗi khi cập nhật người phụ trách:', e)
        const msg =
            e?.response?.data?.messages?.error ||
            e?.response?.data?.message ||
            'Cập nhật người phụ trách thất bại'
        message.error(msg)
    }
}

/* =========================
 * Fetchers
 * ========================= */
const fetchUsers = async () => {
    try {
        const res = await getUsers()
        users.value = Array.isArray(res?.data) ? res.data : []
    } catch (e) {
        console.error('Không thể tải danh sách người dùng:', e)
    }
}
const fetchCustomers = async () => {
    try {
        const res = await getCustomers()
        customers.value = res?.data?.data || []
    } catch (e) {
        console.error(e)
        message.error('Không thể tải danh sách khách hàng')
    }
}
const fetchSteps = async () => {
    try {
        loadingSteps.value = true
        const stepRes = await getBiddingStepsAPI(id)
        // so sánh kiểu an toàn
        steps.value = (Array.isArray(stepRes?.data) ? stepRes.data : []).filter(s => String(s.bidding_id) === String(id))
    } catch (e) {
        console.error('Lỗi khi tải bước:', e)
        message.error('Không thể tải tiến trình xử lý')
    } finally {
        loadingSteps.value = false
    }
}
const fetchData = async () => {
    try {
        const res = await getBiddingAPI(id)
        bidding.value = res?.data || {}
        loadingSteps.value = true
        const stepRes = await getBiddingStepsAPI(id)
        steps.value = (Array.isArray(stepRes?.data) ? stepRes.data : []).filter(s => String(s.bidding_id) === String(id))
        commonStore.setBiddingIdParent(res?.data?.id)
    } catch (e) {
        console.error(e)
        message.error('Không thể tải dữ liệu')
    } finally {
        loadingSteps.value = false
    }
}

/* =========================
 * Misc UI helpers needed by template
 * ========================= */
const statusText = status => STEP_STATUS_TEXT[String(status)] || 'Không rõ'
const getStepStatusColor = status => STEP_STATUS_COLOR[String(status)] || 'default'
const mapStepStatus = status => STEP_STATUS_MAP[String(status)] || 'wait'

const getStatusColor = status => {
    switch (Number(status)) {
        case 1: return 'blue'
        case 2: return 'green'
        case 3: return 'red'
        default: return 'default'
    }
}
const getStatusText = status => STATUS_TEXT[Number(status)] ?? 'Không rõ'
const getApprovalStatusText = st => APPROVAL_TEXT[String(st)] ?? 'Không rõ'
const getApprovalStatusColor = st => APPROVAL_COLOR[String(st)] ?? 'gray'

const getTaskStatusText = st => TASK_STATUS_TEXT[String(st)] || 'Không rõ'
const getTaskStatusColor = st => TASK_STATUS_COLOR[String(st)] || 'default'

const parseDepartment = val => {
    const parsed = tryParse(val)
    if (Array.isArray(parsed)) return parsed
    return val ? [val] : []
}

const lastCompletedIndex = () => {
    for (let i = steps.value.length - 1; i >= 0; i--) if (String(steps.value[i].status) === '2') return i
    return -1
}
const currentStepIndex = () => {
    const next = lastCompletedIndex() + 1
    return next >= steps.value.length ? steps.value.length - 1 : next
}

const getAssignedUserName = userId => {
    if (!userId) return 'Không xác định'
    return usersById.value[String(userId)]?.name || `Người dùng #${userId}`
}
const getCustomerName = cid => {
    if (!cid) return 'Đang tải...'
    return customersById.value[String(cid)]?.name || `Khách hàng #${cid}`
}
const goToUserDetail = userId => { if (userId) router.push({ name: 'user-detail', params: { id: userId } }) }
const goToCustomerDetail = customerId => { if (customerId) router.push({ name: 'customer-detail', params: { id: String(customerId) } }) }

const showPopupCreate = () => {
    const step = stepStore.selectedStep
    if (step) {
        stepStore.setSelectedStep({ ...step })
        const filter = {}
        const u = userStore.currentUser || {}
        if (String(u.role_id) === '3') filter.assigned_to = u.id
        else if (String(u.role_id) === '2') filter.id_department = u.department_id

        getTasksByBiddingStep(step.id, filter)
            .then(res => stepStore.setRelatedTasks(Array.isArray(res?.data) ? res.data : []))
            .catch(() => stepStore.setRelatedTasks([]))
    }
    openDrawer.value = true
}

const handleDrawerSubmit = async () => {
    const u = userStore.currentUser || {}
    const filter = {}
    if (String(u.role_id) === '3') filter.assigned_to = u.id
    else if (String(u.role_id) === '2') filter.id_department = u.department_id

    if (stepStore.selectedStep?.id) {
        try {
            // chờ BE hoàn tất insert
            await new Promise(r => setTimeout(r, 500))
            const res = await getTasksByBiddingStep(stepStore.selectedStep.id, filter)
            const tasks = Array.isArray(res?.data) ? res.data : Array.isArray(res?.data?.data) ? res.data.data : []
            stepStore.setRelatedTasks(tasks)
            await fetchSteps()
        } catch (err) {
            console.error('❌ Không thể load task sau khi tạo:', err)
            message.error('Không thể tải danh sách công việc sau khi tạo')
        }
    }
}

/** Nếu template dùng form tìm kiếm “nhiệm vụ nội bộ” */
const submitForm = () => getInternalTask()
const getInternalTask = async () => {
    loading.value = true
    try {
        const response = await getTasks(dataFilter.value)
        tableData.value = response?.data?.data ?? []
        const pg = response?.data?.pagination || {}
        pagination.value = {
            current: pg.page ?? 1,
            total: pg.total ?? 0,
            pageSize: pg.per_page ?? 10
        }
    } catch (e) {
        message.error('Không thể tải nhiệm vụ')
    } finally {
        loading.value = false
    }
}

/* =========================
 * Navigation helpers
 * ========================= */
const goBack = () => {
    if (window.history.length > 1) router.back()
    else router.push('/bid-list')
}

const goToStepTasks = (step) => {
    const bidId = Number(route.params.id) // 👈 lấy id gói thầu từ route hiện tại
    router.push({
        name: 'bidding-step-tasks',
        params: { bidId, stepId: Number(step.id) }
    })
}

/* =========================
 * Lifecycle
 * ========================= */
onMounted(async () => {
    await Promise.all([fetchData(), fetchCustomers(), fetchUsers()])
})

/* =========================
 * Expose (if needed by template)
 * (script setup auto-exposes refs; list kept for clarity)
 * ========================= */
// nothing extra
</script>


<style>
.ant-descriptions-item-content {
    width: 300px;
}

.active-step-title .ant-statistic-content span {
    color: #FFFFFF;
}

/* Cân cột, đồng nhất label, bố cục gọn */
.desc-grid :deep(.ant-descriptions-view) {
    table-layout: fixed;
    width: 100%;
}

.desc-grid :deep(.ant-descriptions-item-label) {
    width: 140px !important; /* đồng nhất label */
    max-width: 140px;
    white-space: nowrap;
}

.desc-grid :deep(.ant-descriptions-item-content) {
    width: calc(100% - 140px); /* cột nội dung cố định thẳng hàng */
}

/* Item có control hiển thị đẹp hơn */
.desc-grid .status-tag,
.desc-grid .assigned-display {
    display: inline-flex;
    align-items: center;
}

/* Tag list phòng ban gọn gàng */
.desc-grid :deep(.ant-tag) {
    margin: 2px 4px 2px 0;
}

/* Responsive: mobile 1 cột, label gọn hơn */
@media (max-width: 576px) {
    .desc-grid :deep(.ant-descriptions-item-label) {
        width: 120px !important;
        max-width: 120px;
    }
}

.active-step-title .ant-statistic-content span {
    color: #FFFFFF;
}

.time-item {
    display: flex;
    align-items: center;
    margin-bottom: 4px;
    font-size: 14px;
}

.time-item .label {
    font-weight: 500;
    color: #555;
    min-width: 70px; /* để thẳng hàng */
}

.time-item .value {
    color: #1890ff;
}

.time-item.start .value {
    color: #52c41a; /* xanh lá cho ngày bắt đầu */
}

.time-item.end .value {
    color: #f5222d; /* đỏ cho ngày kết thúc */
}

.status-tag {
    cursor: pointer;
    user-select: none;
    display: inline-flex;
    align-items: center;
}

.assigned-display {
    cursor: pointer;
    display: inline-flex;
    align-items: center;
}

.desc-progress {
    display: flex;
    align-items: center;
    gap: 8px;
    min-width: 80px; /* rộng hơn 1 chút cho đẹp */
    cursor: default; /* hoặc pointer nếu muốn click mở chi tiết */
}

.desc-progress :deep(.ant-progress) {
    flex: 1;
}

.progress-meta {
    white-space: nowrap;
    font-size: 12px;
    color: rgba(0, 0, 0, .65);
}

/* Nếu thấy progress vẫn đổi sang xanh lá ở trạng thái success của AntD */
:deep(.ant-progress-bg),
:deep(.ant-progress-success-bg) {
    background-color: #1890ff !important;
}

</style>

<style scoped>
.active-step-title {
    background-color: #91d5ff;
    border-radius: 4px;
    padding: 0 8px;
}

.active-step-title span {
    color: #ffffff !important;
}

.step-actions {
    margin-top: 12px;
    text-align: right;
}

.ant-steps-item-title {
    color: rgba(0, 0, 0, 0.85) !important;
    font-weight: 500;
    cursor: pointer;
}

.mt-30 {
    margin-top: 30px;
}

.mb-30 {
    margin-bottom: 30px;
}

.ant-list-items li {
    padding-left: 0;
    padding-right: 0;
}

:deep(.ant-table-row-indent) {
    display: inline-block !important;
}

/* === Antd Table: thu nhỏ thanh cuộn === */

/* Firefox */
:deep(.ant-table-content),
:deep(.ant-table-body) {
    scrollbar-width: thin; /* mảnh hơn */
    scrollbar-color: rgba(0, 0, 0, .25) transparent;
}

/* WebKit (Chrome/Edge/Safari) – CUỘN NGANG của bảng */
:deep(.ant-table-content::-webkit-scrollbar) {
    height: 6px;
}

:deep(.ant-table-content::-webkit-scrollbar-thumb) {
    background: rgba(0, 0, 0, 0.25);
    border-radius: 4px;
}

:deep(.ant-table-content::-webkit-scrollbar-thumb:hover) {
    background: rgba(0, 0, 0, 0.45);
}

:deep(.ant-table-content::-webkit-scrollbar-track) {
    background: transparent;
}

/* Nếu sau này dùng scroll.y (cuộn DỌC) thì áp thêm: */
:deep(.ant-table-body::-webkit-scrollbar) {
    width: 6px;
}

:deep(.ant-table-body::-webkit-scrollbar-thumb) {
    background: rgba(0, 0, 0, 0.25);
    border-radius: 4px;
}

:deep(.ant-table-body::-webkit-scrollbar-thumb:hover) {
    background: rgba(0, 0, 0, 0.45);
}

:deep(.ant-table-body::-webkit-scrollbar-track) {
    background: transparent;
}

/* Áp dụng cho toàn bộ bảng Antd */
:deep(td) {
    font-size: 12px;
    padding: 0 12px; /* tuỳ chỉnh thêm nếu muốn */
}

/* Task cha */
:deep(.task-title) {
    display: inline-block;
    font-weight: 500;
    font-size: 14px;
    color: #1890ff;
}

/* Task con */
:deep(.task-title.child) {
    position: relative;
    padding-left: 30px; /* thụt vào */
    font-weight: normal;
    font-size: 12px;
    color: #555;
}

/* Đường nối cha–con */
:deep(.task-title.child)::before {
    content: '';
    position: absolute;
    left: 10px;
    top: 50%;
    width: 14px;
    height: 1px;
    background: #ccc; /* gạch ngang */
}

:deep(.task-title.child)::after {
    content: '';
    position: absolute;
    left: 10px;
    top: 0;
    bottom: 50%;
    border-left: 1px solid #ccc; /* gạch dọc */
}
</style>
