<template>
    <div style="max-width: 1000px; margin: 0 auto;">
        <a-card>
            <a-page-header
                title="Chi tiết hợp đồng"
                sub-title="Xem thông tin và tiến trình xử lý"
                @back="goBack"
                style="padding: 0 0 20px;"
            />
            <a-descriptions bordered :column="2" size="middle">
                <!-- 1) Hàng 1 -->
                <a-descriptions-item label="Tên hợp đồng">
                    <strong>{{ contract?.title }}</strong>
                </a-descriptions-item>
                <a-descriptions-item label="Trạng thái">
                    <a-tag :color="getStatusColor(contract?.status)">
                        {{ getStatusText(contract?.status) }}
                    </a-tag>
                </a-descriptions-item>

                <!-- 2) Hàng 2 -->
                <a-descriptions-item label="Gói thầu">
                    <a @click="goToBiddingDetail(contract?.bidding_id)" style="color:#1890ff;cursor:pointer">
                        {{ getBiddingTitle(contract?.bidding_id) }}
                    </a>
                </a-descriptions-item>
                <a-descriptions-item label="Chi phí dự tính">
                    {{ getBiddingCost(contract?.bidding_id) }}
                </a-descriptions-item>

                <!-- 3) Hàng 3: Thời gian full dòng -->
                <a-descriptions-item label="Thời gian">
                    <div class="time-item start">
                        <span class="label">Bắt đầu:</span>
                        <span class="value">{{ formatDate(contract?.start_date) }}</span>
                    </div>
                    <div class="time-item end">
                        <span class="label">Kết thúc:</span>
                        <span class="value">{{ formatDate(contract?.end_date) }}</span>
                    </div>
                </a-descriptions-item>

                <a-descriptions-item label="Tiến độ">
                    <a-tooltip>
                        <template #title>
                            <div>
                                <div v-for="(line, i) in detailProgressLines(contract)" :key="i">
                                    {{ line }}
                                </div>
                            </div>
                        </template>

                        <div class="desc-progress">
                            <a-progress
                                :percent="detailProgressPercent(contract)"
                                :stroke-color="{ '0%':'#108ee9', '100%':'#87d068' }"
                                :status="detailProgressPercent(contract) >= 100 ? 'success' : 'active'"
                                size="small"
                                :show-info="false"
                            />
                        </div>
                    </a-tooltip>
                </a-descriptions-item>
                <!-- Hạn: chiếm cả hàng để có chỗ cho tag -->
                <a-descriptions-item label="Hạn">
                    <a-tag v-if="deadlineInfo(contract?.end_date).type === 'remaining'" color="green">
                        Còn {{ deadlineInfo(contract?.end_date).days }} ngày
                    </a-tag>
                    <a-tag v-else-if="deadlineInfo(contract?.end_date).type === 'today'" :color="'#faad14'">
                        Hạn chót hôm nay
                    </a-tag>
                    <a-tag v-else-if="deadlineInfo(contract?.end_date).type === 'overdue'" color="error">
                        Quá hạn {{ deadlineInfo(contract?.end_date).days }} ngày
                    </a-tag>
                    <a-typography-text v-else type="secondary">—</a-typography-text>
                </a-descriptions-item>

                <!-- 4) Hàng 4 -->
                <a-descriptions-item label="Người phụ trách">
                    <a @click="goToUserDetail(contract?.assigned_to)" style="color:#1890ff;cursor:pointer">
                        {{ getAssignedUserName(contract?.assigned_to) }}
                    </a>
                </a-descriptions-item>
                <a-descriptions-item label="Khách hàng">
                    <a @click="goToCustomerDetail(contract?.customer_id)" style="color:#1890ff;cursor:pointer">
                        {{ getCustomerName(contract?.customer_id) }}
                    </a>
                </a-descriptions-item>

                <!-- 👇 Người phối hợp (gom của TẤT CẢ bước) -->
                <a-descriptions-item label="Người phối hợp">
                    <template v-if="(contract?.collaborators_detail?.length || 0) > 0">
                        <a-space size="small" align="center" wrap>
                            <a-avatar-group :maxCount="5" size="small">
                                <a-tooltip
                                    v-for="u in contract.collaborators_detail"
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

                <!-- 5) Hàng 5: Mô tả full dòng -->
                <a-descriptions-item label="Mô tả" :span="2">
                    <div style="white-space: pre-line;">{{ contract?.description || 'Không có mô tả' }}</div>
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
                            </div>
                        </template>
                        <template #description>
                            <a-descriptions
                                class="desc-grid"
                                size="small"
                                :column="{ xs: 1, sm: 1, md: 2, lg: 2, xl: 2 }"
                                bordered
                                :labelStyle="{ width: '200px' }"
                            >
                                <!-- Phòng ban -->
                                <a-descriptions-item label="Phòng ban">
                                    <a-tag
                                        v-for="(dep,i) in parseDepartment(step.department)"
                                        :key="i"
                                        color="blue"
                                        style="margin:2px;"
                                    >{{ dep }}
                                    </a-tag>
                                </a-descriptions-item>

                                <!-- Trạng thái (Popover + Select) -->
                                <a-descriptions-item label="Trạng thái">
                                    <a-popover
                                        :open="openStatusForId === step.id"
                                        trigger="click"
                                        placement="bottomLeft"
                                        @openChange="v => openStatusForId = v ? step.id : null"
                                    >
                                        <template #content>
                                            <a-select style="width:180px" :value="String(step.status)" @change="val => onChangeStatus(step, val)">
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

                                <!-- Phụ trách bước (Popover + Select) -->
                                <a-descriptions-item label="Phụ trách bước">
                                    <a-popover
                                        :open="openAssignForId === step.id"
                                        trigger="click"
                                        placement="bottomLeft"
                                        @openChange="v => openAssignForId = v ? step.id : null"
                                    >
                                        <template #content>
                                            <a-select style="width:200px"
                                                      :value="step.assigned_to || null"
                                                      placeholder="Chọn người phụ trách"
                                                      allowClear
                                                      @change="val => onChangeAssigned(step, val)">
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

                                <!-- Ngày bắt đầu (click để sửa) -->
                                <a-descriptions-item label="Ngày bắt đầu">
                                    <a-typography-text
                                        v-if="!showEditDateStart || activeStepId !== step.id"
                                        type="secondary"
                                        @click.stop="onClickEditStart(step)"
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
                                        :disabledDate="cur => {
                                      const e = step.end_date ? dayjs(step.end_date) : null
                                      return e ? (cur && cur > e.endOf('day')) : false
                                    }"
                                        @change="updateStepStartDate"
                                    />
                                </a-descriptions-item>

                                <!-- Hạn: full dòng để có không gian -->
                                <a-descriptions-item label="Hạn">
                                    <template v-if="deadlineInfo(step.end_date).type === 'overdue'">
                                        <a-tag color="error">Quá hạn {{ deadlineInfo(step.end_date).days }} ngày</a-tag>
                                    </template>
                                    <template v-else-if="deadlineInfo(step.end_date).type === 'today'">
                                        <a-tag :color="'#faad14'">Hạn chót hôm nay</a-tag>
                                    </template>
                                    <template v-else-if="deadlineInfo(step.end_date).type === 'remaining'">
                                        <a-tag color="green">Còn {{ deadlineInfo(step.end_date).days }} ngày</a-tag>
                                    </template>
                                    <template v-else>—</template>
                                </a-descriptions-item>

                                <!-- Ngày kết thúc (click để sửa) -->
                                <a-descriptions-item label="Ngày kết thúc">
                                    <a-typography-text
                                        v-if="!showEditDateEnd || activeStepId !== step.id"
                                        type="secondary"
                                        @click.stop="onClickEditEnd(step)"
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
                                        :disabledDate="cur => {
                                      const s = step.start_date ? dayjs(step.start_date) : null
                                      return s ? (cur && cur < s.startOf('day')) : false
                                    }"
                                        @change="updateStepEndDate"
                                    />
                                </a-descriptions-item>

                                <!-- Người phối hợp thực hiện: full dòng để đủ chỗ avatar -->
                                <a-descriptions-item label="Người phối hợp thực hiện">
                                    <template v-if="step.assignees_detail?.length">
                                        <a-avatar-group size="small" :maxCount="8">
                                            <a-tooltip v-for="u in step.assignees_detail" :key="u.id"
                                                       :title="u.name || 'Không rõ'">
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

        <a-drawer
            title="Danh sách nhiệm vụ"
            placement="right"
            :visible="drawerVisible"
            @close="closeDrawer"
            width="1100"
        >
            <template v-if="selectedStep">
                <a-row :gutter="16" justify="end">
                    <a-col>
                        <a-button type="primary" @click="showPopupCreate">
                            Thêm nhiệm vụ mới
                        </a-button>
                    </a-col>
                </a-row>

                <a-empty v-if="relatedTasks.length === 0" description="Không có công việc"/>

                <template v-else>
                    <!-- Header -->
                    <div style=" display: flex; justify-content: space-between; padding: 8px 0; font-weight: 500; color: #555; border-bottom: 1px solid #f0f0f0;"></div>
                    <!-- Danh sách nhiệm vụ -->
                    <a-table
                        class="tiny-scroll"
                        :columns="relatedColumns"
                        :dataSource="relatedTasks"
                        rowKey="id"
                        bordered
                        size="small"
                        :pagination="false"
                        :scroll="{ x: 1200 }"
                        :locale="{ emptyText: 'Không có dữ liệu' }"
                    >
                        <template #bodyCell="{ column, record, index }">
                            <!-- STT -->
                            <template v-if="column.key === 'index'">
                                {{ index + 1 }}
                            </template>

                            <!-- Tên công việc -->
                            <template v-else-if="column.dataIndex === 'title'">
                                <router-link :to="`/non-workflow/${record.id}/info`">
                                    {{ record.title }}
                                </router-link>
                            </template>

                            <!-- Người thực hiện -->
                            <template v-else-if="column.dataIndex === 'assigned_to'">
                                {{ getAssignedUserName(record.assigned_to) }}
                            </template>

                            <!-- Tiến trình -->
                            <template v-else-if="column.dataIndex === 'progress'">
                                <a-progress
                                    :percent="Number(record.progress)"
                                    :status="Number(record.progress) >= 100 ? 'success' : 'active'"
                                    size="small"
                                    :show-info="true"
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

        <DrawerCreateTask
            v-model:open-drawer="openDrawer"
            :list-user="users"
            type="contract"
            @submitForm="handleDrawerSubmit"
        />
    </div>
</template>

<script setup>
import {computed, onMounted, reactive, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {message} from 'ant-design-vue'
import {formatCurrency, formatDate} from '@/utils/formUtils'
import dayjs from 'dayjs'
import {getContractAPI} from '@/api/contract'
import {getBiddingsAPI} from '@/api/bidding'
import {EditOutlined, SendOutlined} from '@ant-design/icons-vue'
import DrawerCreateTask from "@/components/common/DrawerCreateTask.vue"; // nếu chưa import
import {
    cloneContractStepsFromTemplateAPI,
    completeContractStepAPI,
    getContractStepsAPI,
    updateContractStepAPI
} from '@/api/contract-steps'
import {getTaskDetail, getTasks, getTasksByBiddingStep, getTasksByContractStep} from '@/api/task' // giả sử bạn có API như vậy
const activeStepId = ref(null)

import {useUserStore} from '@/stores/user'

const userStore = useUserStore()
const user = userStore.currentUser

import {getCustomers} from '@/api/customer'
import {getUsers} from '@/api/user.js'

const openDrawer = ref(false)

import {useStepStore} from '@/stores/step'
import {sendApproval} from "@/api/approvals.js";

const stepStore = useStepStore()

const biddings = ref([])

const relatedTasks = computed(() => stepStore.relatedTasks)
const loading = ref(false);

// Định nghĩa cột cho bảng nhiệm vụ
const relatedColumns = ref([
    {
        title: 'STT',
        key: 'index',
        width: 60,
        align: 'center'
    },
    {
        title: 'Tên công việc',
        dataIndex: 'title',
        key: 'title',
        width: 200,
        ellipsis: true
    },
    {
        title: 'Người thực hiện',
        dataIndex: 'assigned_to',
        key: 'assigned_to',
        width: 150,
        align: 'center'
    },
    {
        title: 'Tiến trình',
        dataIndex: 'progress',
        key: 'progress',
        width: 120,
        align: 'center'
    },
    {
        title: 'Ưu tiên',
        dataIndex: 'priority',
        key: 'priority',
        width: 150,
        align: 'center'
    },
    {
        title: 'Bắt đầu',
        dataIndex: 'start_date',
        key: 'start_date',
        width: 100,
        align: 'center'
    },
    {
        title: 'Kết thúc',
        dataIndex: 'end_date',
        key: 'end_date',
        width: 100,
        align: 'center'
    },
    {
        title: 'Trạng thái',
        dataIndex: 'status',
        key: 'status',
        width: 120,
        align: 'center'
    },
    {
        title: 'Hạn',
        dataIndex: 'deadline',
        key: 'deadline',
        width: 120,
        align: 'center'
    },
    {
        title: 'Duyệt',
        dataIndex: 'approval_status',
        key: 'approval_status',
        width: 200,
        align: 'center'
    }
])

const router = useRouter()
const route = useRoute()
const id = route.params.id
const isNewContract = ref(route.query.new === '1') // 👈 xác định hợp đồng mới
const users = ref([])

const contract = ref({})
const steps = ref([])
const loadingSteps = ref(false)

const drawerVisible = ref(false)
const selectedStep = ref(null)
const customers = ref([])
const customerName = ref('Đang tải...')
const allTasks = ref([])
// const relatedTasks = ref([])

const onClickEditStart = (step) => {
    if (!step) return
    selectedStep.value = step
    dateStart.value = step.start_date ? dayjs(step.start_date) : null
    showEditDateStart.value = true
    showEditDateEnd.value = false
    activeStepId.value = step.id
}

const onClickEditEnd = (step) => {
    if (!step) return
    selectedStep.value = step
    dateEnd.value = step.end_date ? dayjs(step.end_date) : null
    showEditDateStart.value = false
    showEditDateEnd.value = true
    activeStepId.value = step.id
}

const showEditDate = ref(false)
const dateStart = ref(null)
const dateEnd = ref(null)
// mở popover theo id step
const openStatusForId = ref(null)
const openAssignForId = ref(null)

const showEditDateStart = ref(false)
const showEditDateEnd = ref(false)
const editDateStart = (step) => {
    if (!step) return
    selectedStep.value = step
    dateStart.value = step.start_date ? dayjs(step.start_date) : null
    showEditDateStart.value = true
    showEditDateEnd.value = false
}

const editDateEnd = (step) => {
    if (!step) return
    selectedStep.value = step
    dateEnd.value = step.end_date ? dayjs(step.end_date) : null
    showEditDateStart.value = false
    showEditDateEnd.value = true
}
const updateStepStartDate = async (value) => {
    if (!selectedStep.value) return
    const newStart = value ? dayjs(value).format('YYYY-MM-DD') : null
    try {
        await updateContractStepAPI(selectedStep.value.id, {start_date: newStart})
        selectedStep.value.start_date = newStart
        message.success('Cập nhật ngày bắt đầu thành công')
        showEditDateStart.value = false
        await fetchSteps()
    } catch (e) {
        message.error('Không thể cập nhật ngày bắt đầu')
    }
}

const updateStepEndDate = async (value) => {
    if (!selectedStep.value) return
    const newEnd = value ? dayjs(value).format('YYYY-MM-DD') : null
    try {
        await updateContractStepAPI(selectedStep.value.id, {end_date: newEnd})
        selectedStep.value.end_date = newEnd
        message.success('Cập nhật ngày kết thúc thành công')
        showEditDateEnd.value = false
        await fetchSteps()
    } catch (e) {
        message.error('Không thể cập nhật ngày kết thúc')
    }
}

const disabledDate = current => {
    return current && current < dayjs(selectedStep.value.start_date).endOf('day');
};
const fetchBiddings = async () => {
    try {
        const res = await getBiddingsAPI()
        biddings.value = res.data?.data || []
    } catch (e) {
        console.error('Không thể tải danh sách gói thầu', e)
    }
}


const editing = reactive({
    id: null,
    field: null
})


// % tiến độ tổng HĐ
const detailProgressPercent = (c) => Number(c?.progress?.contract_progress ?? 0);

// Tooltip mô tả nhanh
const detailProgressLines = (c) => {
    const p = c?.progress || {};
    const stepsDone = Number(p.steps_completed ?? 0);
    const stepsTotal = Number(p.steps_total ?? 0);
    const subDone = Number(p.subtasks_approved ?? 0);
    const subTotal = Number(p.subtasks_total ?? 0);

    const per = Array.isArray(p.per_steps) ? p.per_steps.slice(0, 3) : [];

    return [
        `Tiến độ hợp đồng: ${detailProgressPercent(c)}%`,
        `Bước hoàn thành: ${stepsDone}/${stepsTotal}`,
        `Nhiệm vụ con duyệt: ${subDone}/${subTotal}`
    ];
};

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

// đổi trạng thái step (giống bidding, chú ý cast kiểu)
const onChangeStatus = async (step, val) => {
    const newVal = Number(val)
    try {
        if (newVal === 2 || String(newVal) === '2') {
            await completeContractStepAPI(step.id)
            message.success('Đã hoàn thành và mở bước kế tiếp')
        } else {
            await updateContractStepAPI(step.id, {status: newVal})
            message.success('Đã cập nhật trạng thái bước')
        }
        step.status = newVal
    } catch (e) {
        const msg = e?.response?.data?.messages?.error || 'Đã xảy ra lỗi'
        message.error(msg)
    } finally {
        openStatusForId.value = null
        await fetchSteps()
    }
}

// đổi người phụ trách step
const onChangeAssigned = async (step, val) => {
    try {
        await updateContractStepAPI(step.id, {assigned_to: val || null})
        message.success('Cập nhật người phụ trách thành công')
        step.assigned_to = val || null
    } catch (e) {
        const msg = e?.response?.data?.messages?.error || 'Không thể cập nhật người phụ trách'
        message.error(msg)
    } finally {
        openAssignForId.value = null
        await fetchSteps()
    }
}
const getInitials = (name) => {
    if (!name) return '?'
    const parts = name.trim().split(/\s+/)
    return (parts[0][0] + (parts[parts.length - 1]?.[0] || '')).toUpperCase()
}


const getBiddingTitle = (id) => {
    const found = biddings.value.find(b => String(b.id) === String(id))
    return found?.title || `Gói thầu #${id}`
}

const openStepDrawer = async (step) => {
    selectedStep.value = {...step}
    stepStore.setSelectedStep({...step})
    activeStepId.value = step.id // 👈 đánh dấu bước đang mở
    drawerVisible.value = true

    const user = userStore.currentUser
    const dataFilter = {}

    if (String(user?.role_id) === '3') {
        // Nhân viên → chỉ xem nhiệm vụ của mình
        dataFilter.assigned_to = user.id
    } else if (String(user?.role_id) === '2') {
        // Trưởng phòng → xem được nhiệm vụ của cả phòng
        dataFilter.id_department = user.department_id
    }

    console.log('📤 dataFilter', dataFilter)

    try {
        const res = await getTasksByContractStep(step.id, dataFilter)
        stepStore.setRelatedTasks(Array.isArray(res.data) ? res.data : [])
    } catch (e) {
        console.error('❌ Không thể tải công việc của bước', e)
        message.error('Không thể tải danh sách công việc')
        stepStore.setRelatedTasks([])
    }
}

const showPopupCreate = () => {
    openDrawer.value = true
}

const handleDrawerSubmit = async () => {
    const user = userStore.currentUser
    const dataFilter = {}

    if (String(user?.role_id) === '3') {
        // Nhân viên → chỉ xem nhiệm vụ của mình
        dataFilter.assigned_to = user.id
    } else if (String(user?.role_id) === '2') {
        // Trưởng phòng → xem nhiệm vụ của phòng
        dataFilter.id_department = user.department_id
    }
    // Admin (1) → không lọc gì cả

    if (stepStore.selectedStep?.id) {
        try {
            // 1. Lấy danh sách task mới (sau khi tạo task xong)
            const res = await getTasksByContractStep(stepStore.selectedStep.id, dataFilter)
            const tasks = Array.isArray(res.data) ? res.data : []

            // 2. Cập nhật vào store
            stepStore.setRelatedTasks(tasks)

            // 3. Gọi lại danh sách các bước để cập nhật task_count
            await fetchSteps()

            // 4. Cập nhật lại step đang mở để lấy task_count mới
            const updatedStep = steps.value.find(s => s.id === stepStore.selectedStep.id)
            if (updatedStep) {
                selectedStep.value = {...updatedStep}
                stepStore.setSelectedStep({...updatedStep})
            } else {
                console.warn('⚠️ Không tìm thấy step để cập nhật')
            }

            // 5. Kiểm tra lại tasks trong store
            setTimeout(() => {
                console.log('✅ Tasks trong store:', stepStore.relatedTasks)
            }, 500)

        } catch (err) {
            console.error('❌ Không thể load task sau khi tạo:', err)
            message.error('Không thể tải danh sách công việc sau khi tạo')
        }
    }
}


const getTaskStatusText = (status) => ({
    todo: 'Chưa bắt đầu',
    doing: 'Đang làm',
    done: 'Hoàn thành',
    overdue: 'Trễ hạn',
}[status] || 'Không rõ')

const getTaskStatusColor = (status) => ({
    todo: 'default',
    doing: 'blue',
    done: 'green',
    overdue: 'red',
}[status] || 'default')

// Hàm lấy màu cho mức độ ưu tiên
const getPriorityColor = (priority) => {
    const map = {
        'low': 'green',
        'medium': 'orange',
        'high': 'red',
        'urgent': 'red'
    }
    return map[priority] || 'default'
}

// Hàm lấy text cho mức độ ưu tiên
const getPriorityText = (priority) => {
    const map = {
        'low': 'Thấp',
        'medium': 'Trung bình',
        'high': 'Cao',
        'urgent': 'Khẩn cấp'
    }
    return map[priority] || 'Không xác định'
}

// Hàm tính toán thông tin deadline
const deadlineInfo = (endDate) => {
    if (!endDate) return {type: 'none', days: 0}

    const today = dayjs()
    const deadline = dayjs(endDate)
    const diffDays = deadline.diff(today, 'day')

    if (diffDays < 0) {
        return {type: 'overdue', days: Math.abs(diffDays)}
    } else if (diffDays === 0) {
        return {type: 'today', days: 0}
    } else {
        return {type: 'remaining', days: diffDays}
    }
}

// Hàm lấy màu cho trạng thái duyệt
const getApprovalStatusColor = (status) => {
    const map = {
        'pending': 'orange',
        'approved': 'green',
        'rejected': 'red'
    }
    return map[status] || 'default'
}

// Hàm lấy text cho trạng thái duyệt
const getApprovalStatusText = (status) => {
    const map = {
        'pending': 'Chờ duyệt',
        'approved': 'Đã duyệt',
        'rejected': 'Từ chối'
    }
    return map[status] || 'Không xác định'
}

const getStatusColor = (status) => {
    const map = {
        0: 'gray',
        1: 'blue',
        2: 'orange',
        3: 'cyan',
        4: 'green',
        5: 'red',
    }
    return map[status] || 'default'
}

const getStatusText = (status) => {
    const map = {
        0: 'Nháp',
        1: 'Đang thực hiện',
        2: 'Chờ duyệt',
        3: 'Đã duyệt',
        4: 'Hoàn thành',
        5: 'Đã hủy',
    }
    return map[status] || 'Không xác định'
}

const statusText = (status) => ({
    '0': 'Chưa bắt đầu',
    '1': 'Đang xử lý',
    '2': 'Đã hoàn thành',
    '3': 'Bỏ qua',
}[status] || 'Không rõ')

const mapStepStatus = (status) => ({
    '0': 'wait',
    '1': 'process',
    '2': 'finish',
    '3': 'error',
}[status] || 'wait')

const getStepStatusColor = (status) => ({
    '0': 'default',
    '1': 'blue',
    '2': 'green',
    '3': 'orange',
}[status] || 'default')

const lastCompletedIndex = () => {
    for (let i = steps.value.length - 1; i >= 0; i--) {
        if (steps.value[i].status === '2') return i
    }
    return -1
}

const currentStepIndex = () => {
    const last = lastCompletedIndex()
    const next = last + 1
    return next >= steps.value.length ? steps.value.length - 1 : next
}

const updateStepStatus = async (newStatus, step) => {
    try {
        if (newStatus === '2') {
            await completeContractStepAPI(step.id)
            message.success('Đã hoàn thành và mở bước kế tiếp')
        } else {
            await updateContractStepAPI(step.id, {status: newStatus})
            message.success('Đã cập nhật trạng thái bước')
        }
        drawerVisible.value = false
        await fetchSteps()
    } catch (e) {
        const msg = e?.response?.data?.messages?.error || 'Đã xảy ra lỗi'
        if (e?.response?.status === 400) {
            message.warning(msg) // ⚠️ Cảnh báo nhẹ nhàng
        } else {
            message.error(msg) // ❌ Lỗi khác thì vẫn báo lỗi đỏ
        }
        console.warn('Lỗi cập nhật bước:', msg)
    }
}

const updateStepAssignedTo = async (newUserId, step) => {
    try {
        await updateContractStepAPI(step.id, {assigned_to: newUserId})
        message.success('Cập nhật người phụ trách thành công')
        drawerVisible.value = false
        await fetchSteps()
    } catch (e) {
        const msg = e?.response?.data?.messages?.error || 'Không thể cập nhật người phụ trách'
        message.error(msg)
        console.warn('Lỗi cập nhật người phụ trách:', msg)
    }
}

const showEditTitle = ref(false)
const titleInput = ref('')

const editTitle = () => {
    titleInput.value = selectedStep.value.title || ''
    showEditTitle.value = true
}

const updateStepTitle = async () => {
    const newTitle = titleInput.value.trim()
    if (!newTitle || newTitle === selectedStep.value.title) {
        showEditTitle.value = false
        return
    }

    try {
        await updateContractStepAPI(selectedStep.value.id, {title: newTitle})
        selectedStep.value.title = newTitle
        message.success('Đã cập nhật tiêu đề bước')
        showEditTitle.value = false
        await fetchSteps()
    } catch (e) {
        console.warn('Lỗi cập nhật tiêu đề:', e)
        message.error('Không thể cập nhật tiêu đề')
        showEditTitle.value = false
    }
}


const closeDrawer = () => {
    drawerVisible.value = false
    activeStepId.value = null
    showEditDateStart.value = false
    showEditDateEnd.value = false
    dateStart.value = null
    dateEnd.value = null
}
const fetchCustomers = async () => {
    try {
        const res = await getCustomers()
        customers.value = res.data?.data || []
    } catch (e) {
        console.error(e)
        message.error('Không thể tải danh sách khách hàng')
    }
}

const getCustomerName = (id) => {
    if (!id || !customers.value.length) return 'Đang tải...'
    const customer = customers.value.find(c => String(c.id) === String(id))
    return customer ? customer.name : `Khách hàng #${id}`
}

const getCustomerNameById = async (id) => {
    try {
        const res = await getCustomers({id})
        const matched = res.data?.data?.find(c => c.id === id)
        customerName.value = matched?.name || `Khách hàng #${id}`
    } catch {
        customerName.value = 'Không thể tải khách hàng'
    }
}

const fetchSteps = async () => {
    loadingSteps.value = true
    try {
        if (isNewContract.value && steps.value.length === 0) {
            await cloneContractStepsFromTemplateAPI(id)
        }
        const stepRes = await getContractStepsAPI(id)
        steps.value = Array.isArray(stepRes.data) ? stepRes.data : [];

        // Nếu sau khi fetch đã có steps thì không clone lại nữa
        isNewContract.value = false
    } catch (e) {
        console.error(e)
        message.error('Không thể tải bước xử lý')
    } finally {
        loadingSteps.value = false
    }
}

const fetchData = async () => {
    try {
        // 1. Lấy thông tin hợp đồng
        const res = await getContractAPI(id)
        contract.value = res.data
        // 2. Lấy tên khách hàng nếu có
        if (contract.value.customer_id) {
            try {
                const customerRes = await getCustomers({id: contract.value.customer_id})
                const matched = customerRes.data?.data?.find(c => String(c.id) === String(contract.value.customer_id))
                customerName.value = matched?.name || `Khách hàng #${contract.value.customer_id}`
            } catch (e) {
                console.warn('Không thể tải khách hàng', e)
                customerName.value = 'Không thể tải khách hàng'
            }
        } else {
            customerName.value = 'Không có khách hàng'
        }

        // 3. Lấy bước xử lý
        await fetchSteps()
    } catch (e) {
        console.error(e)
        message.error('Không thể tải hợp đồng')
    }
}

const goToCustomerDetail = (customerId) => {
    if (!customerId) return
    router.push(`/customers/${customerId}`)
}
const parseDepartment = (val) => {
    if (!val) return []
    try {
        const parsed = JSON.parse(val)
        return Array.isArray(parsed) ? parsed : []
    } catch {
        return []
    }
}

const getAssignedUserName = (userId) => {
    if (!userId || !users.value.length) return 'Không xác định'
    const found = users.value.find(u => String(u.id) === String(userId))
    return found?.name || `Người dùng #${userId}`
}

const fetchUsers = async () => {
    try {
        const res = await getUsers()
        users.value = Array.isArray(res.data) ? res.data : res.data?.data || []
    } catch (e) {
        console.error('Không thể tải danh sách người dùng', e)
    }
}

const getBiddingCost = (id) => {
    const bidding = biddings.value.find(b => String(b.id) === String(id))
    return bidding ? formatCurrency(bidding.estimated_cost) : 'Không có dữ liệu'
}


const fetchTasks = async () => {
    const user = userStore.currentUser
    const dataFilter = {
        linked_type: 'contract'
    }

    if (String(user?.role_id) === '3') {
        // Nhân viên → chỉ xem nhiệm vụ của mình
        dataFilter.assigned_to = user.id
    } else if (String(user?.role_id) === '2') {
        // Trưởng phòng → xem nhiệm vụ trong phòng
        dataFilter.id_department = user.department_id
    }
    // Admin (role_id === '1') → không cần lọc thêm

    try {
        const res = await getTasks(dataFilter)
        allTasks.value = res.data?.data || []
    } catch (e) {
        console.error('Không thể tải danh sách task', e)
        message.error('Không thể tải danh sách nhiệm vụ')
    }
}


const goToUserDetail = (userId) => {
    if (!userId) return
    router.push(`/users/${userId}`)
}

const goToBiddingDetail = (id) => {
    if (!id) return
    router.push(`/bid-detail/${id}`)
}

const goBack = () => {
    router.push('/contracts-tasks')
}

const safeToNumber = v => (v === null || v === undefined || v === '' ? 0 : Number(v))
const tryParse = v => { try { return typeof v === 'string' ? JSON.parse(v) : v } catch { return null } }

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
        target_type: 'contract_step',
        target_id: Number(step.id),
        approver_ids: approverIds,
        meta: {
            title: `Bước ${step.step_number}: ${step.title}`,
            url: `/contract/${contract.value.id}/info`
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



const goToStepTasks = (step) => {
    const contractId = Number(route.params.id) // 👈 lấy id gói thầu từ route hiện tại
    router.push({
        name: 'contract-step-tasks',
        params: { contractId, stepId: Number(step.id) }
    })
}

onMounted(() => {
    fetchData()
    fetchCustomers()
    fetchUsers()
    fetchBiddings()
    fetchTasks() // 👈 Thêm dòng này
})
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
@media (max-width: 575.98px) {
    .desc-grid :deep(.ant-descriptions-item-label) {
        width: 120px !important;
        max-width: 120px;
    }
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

.ant-list-item {
    padding-left: 0;
    padding-right: 0;
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

/* CSS cho bảng nhiệm vụ */
.tiny-scroll {
    max-height: 500px;
    overflow-y: auto;
}

.tiny-scroll::-webkit-scrollbar {
    width: 6px;
    height: 6px;
}

.tiny-scroll::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 3px;
}

.tiny-scroll::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border-radius: 3px;
}

.tiny-scroll::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
}

/* CSS cho bảng */
.ant-table-small .ant-table-thead > tr > th {
    background-color: #fafafa;
    font-weight: 600;
    color: #262626;
}

.ant-table-small .ant-table-tbody > tr > td {
    padding: 8px 12px;
}

.ant-table-small .ant-table-tbody > tr:hover > td {
    background-color: #f5f5f5;
}
</style>
