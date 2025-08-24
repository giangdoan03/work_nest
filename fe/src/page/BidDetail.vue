<template>
    <div>
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
            <a-descriptions-item label="Chi phí">{{ formatCurrency(bidding?.estimated_cost) }}</a-descriptions-item>

            <a-descriptions-item label="Khách hàng">
                <a @click="goToCustomerDetail(bidding?.customer_id)" style="color: #1890ff; cursor: pointer;">
                    {{ getCustomerName(bidding?.customer_id) }}
                </a>
            </a-descriptions-item>

            <!-- Hàng 3 -->
            <a-descriptions-item label="Người phụ trách">
                <a v-if="bidding?.assigned_to" @click="goToUserDetail(bidding.assigned_to)" style="color: #1890ff; cursor: pointer;">
                    {{ getAssignedUserName(bidding?.assigned_to) }}
                </a>
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
                            :status="detailProgressPercent(bidding) >= 100 ? 'success' : 'active'"
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
            <a-descriptions-item label="Người phối hợp">
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
                        <div
                                @click.stop="openStepDrawer(step)"
                                :class="{'active-step-title': activeStepId === step.id}"
                                style="display: flex;
                                 justify-content: space-between;
                                 align-items: center;
                                 cursor: pointer;
                                 color: #1890ff;">
                                <span style="text-decoration: underline;">
                                  Bước {{ step.step_number ?? '-' }}: {{ step.title ?? '-' }}
                                </span>

                            <a-statistic
                                    :value="step.task_done_count ?? 0"
                                    :suffix="'/' + step.task_count + ' task đã xong'"
                                    :value-style="{ fontSize: '13px', color: '#555' }"
                                    style="padding-left: 10px;"
                            />
                        </div>
                    </template>

                    <template #description>
                        <a-descriptions size="small" :column="{ xs: 1, sm: 1, md: 2, lg: 2, xl: 2 }"
                        bordered
                        style="background: #fafafa; padding: 12px; border-radius: 6px;"
                        :labelStyle="{ width: '100px' }"
                        >
                        <!-- Phòng ban: nhiều tag -> chiếm cả hàng -->
                        <a-descriptions-item label="Phòng ban" style="width: 100px">
                            <template #default>
                                <a-tag
                                    v-for="(dep, i) in parseDepartment(step.department)"
                                    :key="i"
                                    color="blue"
                                    style="margin-right: 4px;"
                                >
                                    {{ dep }}
                                </a-tag>
                            </template>
                        </a-descriptions-item>

                        <!-- Ngày bắt đầu & Ngày kết thúc: đặt cạnh nhau -->
                        <a-descriptions-item label="Ngày bắt đầu" style="width: 150px">
                            <a-typography-text v-if="!isEditing(step, 'start')" type="secondary" @click.stop="editDateStart(step)">
                                {{ step.start_date ? formatDate(step.start_date) : '---' }}
                                <EditOutlined />
                            </a-typography-text>
                            <a-date-picker
                                v-else
                                style="width: 100%"
                                v-model:value="dateStart"
                                :format="'YYYY-MM-DD'"
                                :allowClear="true"
                                :disabledDate="disabledStartDate"
                                @change="updateStepStartDate"
                            />
                        </a-descriptions-item>

                        <!-- Trạng thái & Phụ trách bước: đặt cạnh nhau -->
                        <a-descriptions-item label="Trạng thái">
                            <a-popover
                                :open="openStatusForId === step.id"
                                trigger="click"
                                placement="bottomLeft"
                                @openChange="(v) => openStatusForId = v ? step.id : null"
                            >
                                <template #content>
                                    <a-select style="width: 180px" :value="String(step.status)" @change="(val) => onChangeStatus(step, val)">
                                        <a-select-option value="0">Chưa bắt đầu</a-select-option>
                                        <a-select-option value="1">Đang xử lý</a-select-option>
                                        <a-select-option value="2">Hoàn thành</a-select-option>
                                        <a-select-option value="3">Bỏ qua</a-select-option>
                                    </a-select>
                                </template>

                                <a-tag :color="getStepStatusColor(step.status)" class="status-tag">
                                    {{ statusText(step.status) }}
                                    <EditOutlined style="margin-left: 6px; font-size: 14px;" />
                                </a-tag>
                            </a-popover>
                        </a-descriptions-item>

                        <a-descriptions-item label="Ngày kết thúc" style="width: 150px">
                            <a-typography-text
                                v-if="!isEditing(step, 'end')"
                                type="secondary"
                                @click.stop="editDateEnd(step)"
                            >
                                {{ step.end_date ? formatDate(step.end_date) : '---' }}
                                <EditOutlined />
                            </a-typography-text>
                            <a-date-picker
                                v-else
                                style="width: 100%"
                                v-model:value="dateEnd"
                                :format="'YYYY-MM-DD'"
                                :allowClear="true"
                                :disabledDate="disabledEndDate"
                                @change="updateStepEndDate"
                            />
                        </a-descriptions-item>

                        <a-descriptions-item label="Phụ trách bước">
                            <a-popover
                                :open="openAssignForId === step.id"
                                trigger="click"
                                placement="bottomLeft"
                                @openChange="(v) => openAssignForId = v ? step.id : null"
                            >
                                <template #content>
                                    <a-select
                                        style="width: 180px"
                                        :value="step.assigned_to || null"
                                        placeholder="Chọn người phụ trách"
                                        allowClear
                                        @change="(val) => onChangeAssigned(step, val)"
                                    >
                                        <a-select-option v-for="user in users" :key="user.id" :value="user.id">
                                            {{ user.name }}
                                        </a-select-option>
                                    </a-select>
                                </template>

                                <span class="assigned-display">
                                  <a v-if="step.assigned_to" @click.stop.prevent style="color: #1890ff;">
                                    {{ getAssignedUserName(step.assigned_to) }}
                                  </a>
                                  <span v-else>Không xác định</span>
                                  <EditOutlined style="margin-left: 6px; font-size: 14px;" />
                                </span>
                            </a-popover>
                        </a-descriptions-item>

                        <!-- Hạn: chiếm cả hàng để có chỗ cho tag -->
                        <a-descriptions-item label="Hạn">
                            <template v-if="!isEditing(step, 'end')">
                                <a-tag v-if="deadlineInfo(step.end_date).type === 'remaining'" color="green">
                                    Còn {{ deadlineInfo(step.end_date).days }} ngày
                                </a-tag>
                                <a-tag v-else-if="deadlineInfo(step.end_date).type === 'today'" :color="'#faad14'">
                                    Hạn chót hôm nay
                                </a-tag>
                                <a-tag v-else-if="deadlineInfo(step.end_date).type === 'overdue'" color="error">
                                    Quá hạn {{ deadlineInfo(step.end_date).days }} ngày
                                </a-tag>
                                <a-typography-text v-else type="secondary">—</a-typography-text>
                            </template>
                            <template v-else>
                                <a-tag v-if="deadlineInfo(dateEnd).type === 'remaining'" color="green">
                                    Còn {{ deadlineInfo(dateEnd).days }} ngày
                                </a-tag>
                                <a-tag v-else-if="deadlineInfo(dateEnd).type === 'today'" :color="'#faad14'">
                                    Hạn chót hôm nay
                                </a-tag>
                                <a-tag v-else-if="deadlineInfo(dateEnd).type === 'overdue'" color="error">
                                    Quá hạn {{ deadlineInfo(dateEnd).days }} ngày
                                </a-tag>
                                <a-typography-text v-else type="secondary">—</a-typography-text>
                            </template>
                        </a-descriptions-item>

                            <!-- Người liên quan: chiếm cả hàng để đủ chỗ avatar -->
                            <a-descriptions-item label="Người phối hợp thực hiện">
                                <template v-if="step.assignees_detail?.length">
                                    <a-avatar-group size="small" :maxCount="5">
                                        <a-tooltip
                                            v-for="u in step.assignees_detail"
                                            :key="u.id"
                                            :title="u.name || 'Không rõ'"
                                            placement="top"
                                        >
                                            <a-avatar :style="{ backgroundColor: getAvatarColor(u.name) }">
                                                {{ (u.name || '').charAt(0).toUpperCase() }}
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


        <!-- Drawer hiển thị chi tiết bước -->
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
                                <router-link :to="`/internal-tasks/${record.id}/info`">
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
                type="bidding"
                @submitForm="handleDrawerSubmit"
        />
    </div>
</template>

<script setup>
    import {ref, onMounted, computed, reactive} from 'vue'
    import dayjs from 'dayjs'

    dayjs.locale('vi');
    import viVN from 'ant-design-vue/es/locale/vi_VN';
    import {defineEmits, defineProps} from "@vue/runtime-core";

    import {
        getBiddingAPI,
        cloneFromTemplatesAPI,
        getBiddingStepsAPI,
        updateBiddingStepAPI,
        completeBiddingStepAPI
    } from '@/api/bidding'
    import {getUsers} from '@/api/user.js'
    import {useRoute} from 'vue-router'
    import {message} from 'ant-design-vue'
    import {formatDate, formatCurrency, deadlineInfo} from '@/utils/formUtils'
    import {getCustomers} from '../api/customer' // file API của bạn
    import {useRouter} from 'vue-router'
    import {EditOutlined} from '@ant-design/icons-vue'
    import {useStepStore} from '@/stores/step'

    const stepStore = useStepStore()
    const router = useRouter()
    const route = useRoute()
    const id = route.params.id
    const bidding = ref({})
    const steps = ref([])
    const loadingSteps = ref(false)

    let drawerVisible = ref(false)
    const selectedStep = ref(null)
    const customers = ref([])
    const users = ref([])
    const openDrawer = ref(false)
    const listUser = ref([])
    const activeStepId = ref(null)

    import {useUserStore} from '@/stores/user'

    const userStore = useUserStore()
    const user = userStore.currentUser


    import {getTasks, getTasksByBiddingStep, getTasksByContractStep} from '@/api/task'
    import DrawerCreateTask from "@/components/common/DrawerCreateTask.vue";
    import {updateContractStepAPI} from "@/api/contract-steps.js"; // nếu chưa import

    const allTasks = ref([])
    const relatedTasks = computed(() => stepStore.relatedTasks)
    const loading = ref(false);

    const dateStart = ref()
    const dateEnd = ref()
    const showEditDateStart = ref(false)
    const showEditDateEnd = ref(false)

    // columns đầy đủ
    const relatedColumns = [
        { title: 'STT', key: 'index', width: 60, align: 'center', fixed: 'left' },
        { title: 'Tên công việc', dataIndex: 'title', key: 'title', width: 280, ellipsis: true, fixed: 'left' },
        { title: 'Người thực hiện', dataIndex: 'assigned_to', key: 'assigned_to', width: 160 },
        { title: 'Tiến trình', dataIndex: 'progress', key: 'progress', width: 140, align: 'center' },
        { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority', width: 120, align: 'center' },
        {
            title: 'Bắt đầu',
            dataIndex: 'start_date',
            key: 'start_date',
            width: 120,
            align: 'center',
            sorter: (a, b) => new Date(a.start_date) - new Date(b.start_date),
        },
        {
            title: 'Kết thúc',
            dataIndex: 'end_date',
            key: 'end_date',
            width: 120,
            align: 'center',
            sorter: (a, b) => new Date(a.end_date) - new Date(b.end_date),
        },
        { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 140, align: 'center' },
        { title: 'Hạn', dataIndex: 'deadline', key: 'deadline', width: 160, align: 'center' },
        { title: 'Duyệt', dataIndex: 'approval_status', key: 'approval_status', width: 160, align: 'center' },
    ]

    const editing = reactive({
        id: null,
        field: null
    })

    const isEditing = (step, field) =>
        editing.id === step.id && editing.field === field


    const editDateStart = (step) => {
        selectedStep.value = step
        dateStart.value = step.start_date ? dayjs(step.start_date) : null
        editing.id = step.id
        editing.field = 'start'
    }

    const editDateEnd = (step) => {
        selectedStep.value = step
        dateEnd.value = step.end_date ? dayjs(step.end_date) : null
        editing.id = step.id
        editing.field = 'end'
    }

    /** Start không được > end (nếu end đã có) */
    const disabledStartDate = (current) => {
        const end = dateEnd.value || (selectedStep.value && selectedStep.value.end_date ? dayjs(selectedStep.value.end_date) : null)
        if (!end) return false
        return current && current > end.endOf('day')
    }

    /** End không được < start (nếu start đã có) */
    const disabledEndDate = (current) => {
        const start = dateStart.value || (selectedStep.value && selectedStep.value.start_date ? dayjs(selectedStep.value.start_date) : null)
        if (!start) return false
        return current && current < start.startOf('day')
    }


    const updateStepStartDate = async (value) => {
        // value có thể null nếu user bấm clear
        const newStart = value ? dayjs(value).format('YYYY-MM-DD') : null
        const id = selectedStep.value && selectedStep.value.id
        if (!id) return

        try {
            await updateBiddingStepAPI(id, { start_date: newStart })
            message.success('Cập nhật ngày bắt đầu thành công')
            // cập nhật local để UI phản hồi ngay
            selectedStep.value.start_date = newStart
            editing.id = null
            editing.field = null
            await fetchSteps()
        } catch (e) {
            message.error('Không thể cập nhật ngày bắt đầu')
            console.warn('Lỗi cập nhật ngày bắt đầu:', e)
        }
    }

    // script setup (Vue 3, JS thuần)
    const deadlineText = (b) => {
        if (!b || !b.end_date) return 'Không xác định';
        const r = Number(b.days_remaining ?? 0);
        const o = Number(b.days_overdue ?? 0);

        if (o > 0) return `Quá hạn ${o} ngày`;
        if (r > 0) return `Còn ${r} ngày`;
        return 'Đến hạn hôm nay';
    };

    const deadlineColor = (b) => {
        if (!b || !b.end_date) return 'default';
        const r = Number(b.days_remaining ?? 0);
        const o = Number(b.days_overdue ?? 0);

        if (o > 0) return 'red';
        if (r > 0) return 'green';
        return 'orange'; // hôm nay đến hạn
    };

    // màu cố định cho mọi thanh tiến độ
    const PROGRESS_COLOR = '#1890ff'

    // % tổng của gói thầu trong trang chi tiết
    const detailProgressPercent = (b) => Number(b?.progress?.bidding_progress ?? 0)

    // Text hiển thị: "22% (2/9)"
    const detailProgressText = (b) => {
        const p  = detailProgressPercent(b)
        const dn = Number(b?.progress?.steps_completed ?? 0)
        const tt = Number(b?.progress?.steps_total ?? 0)

        if (!tt) return "Chưa có bước nào"

        if (dn === 0) return `Chưa bắt đầu (${dn}/${tt} bước)`

        if (dn < tt) return `Đã hoàn thành ${dn}/${tt} bước (~${p}%)`

        return `Đã hoàn thành toàn bộ ${tt} bước (100%)`
    }


    const openStatusForId = ref(null)

    const onChangeStatus = async (step, val) => {
        // đồng bộ kiểu dữ liệu nếu BE dùng số
        const newVal = Number(val)
        try {
            await updateStepStatus(newVal, step)   // hàm của bạn
            step.status = newVal                   // cập nhật UI
        } finally {
            openStatusForId.value = null           // đóng popover
        }
    }

    const openAssignForId = ref(null)

    const onChangeAssigned = async (step, val) => {
        await updateStepAssignedTo(val, step)
        step.assigned_to = val || null
        openAssignForId.value = null // đóng popover
    }

    const submitForm = () => {
        getInternalTask();
    }

    const showPopupCreate = () => {
        const step = stepStore.selectedStep // hoặc từ selectedStep.value nếu bạn đang dùng ref

        if (step) {
            // Gán lại selectedStep nếu cần (đảm bảo có dữ liệu mới nhất)
            stepStore.setSelectedStep({...step})

            // Optional: load lại task nếu bạn muốn đảm bảo sau khi thêm sẽ update danh sách
            const dataFilter = {}
            if (String(user.role_id) === '3') {
                dataFilter.assigned_to = user.id
            } else if (String(user.role_id) === '2') {
                dataFilter.id_department = user.department_id
            }

            getTasksByBiddingStep(step.id, dataFilter)
                .then(res => {
                    stepStore.setRelatedTasks(Array.isArray(res.data) ? res.data : [])
                })
                .catch(() => {
                    stepStore.setRelatedTasks([])
                })
        }

        openDrawer.value = true
    }


    const handleDrawerSubmit = async () => {
        const user = userStore.currentUser
        const dataFilter = {}

        if (String(user?.role_id) === '3') {
            dataFilter.assigned_to = user.id
        } else if (String(user?.role_id) === '2') {
            dataFilter.id_department = user.department_id
        }

        if (stepStore.selectedStep?.id) {
            try {
                // ⏳ Đợi một chút để backend hoàn tất insert (nếu cần)
                await new Promise(resolve => setTimeout(resolve, 500))

                const res = await getTasksByBiddingStep(stepStore.selectedStep.id, dataFilter)

                const tasks = Array.isArray(res.data)
                    ? res.data
                    : Array.isArray(res.data?.data)
                        ? res.data.data
                        : []

                stepStore.setRelatedTasks(tasks)
                await fetchSteps()

                setTimeout(() => {
                    console.log('✅ Tasks trong store:', stepStore.relatedTasks)
                }, 300)

            } catch (err) {
                console.error('❌ Không thể load task sau khi tạo:', err)
                message.error('Không thể tải danh sách công việc sau khi tạo')
            }
        }
    }

    const getInternalTask = async () => {
        loading.value = true
        try {
            const response = await getTasks(dataFilter.value)

            tableData.value = response.data.data ?? []

            const pg = response.data.pagination
            pagination.value = {
                ...pagination.value,
                current: pg.page,
                total: pg.total,
                pageSize: pg.per_page
            }
        } catch (e) {
            message.error('Không thể tải nhiệm vụ')
        } finally {
            loading.value = false
        }
    }

    const showEditTitle = ref(false)
    const editedTitle = ref('')

    const editTitle = () => {
        editedTitle.value = selectedStep.value.title || ''
        showEditTitle.value = true
    }

    // Hàm cập nhật tiêu đề bước
    const updateStepTitle = async () => {
        if (editedTitle.value.trim() === '') {
            message.warning('Tiêu đề không được để trống')
            return
        }

        try {
            await updateBiddingStepAPI(selectedStep.value.id, {
                title: editedTitle.value.trim()
            })
            selectedStep.value.title = editedTitle.value.trim()
            message.success('Cập nhật tiêu đề thành công')
            showEditTitle.value = false
            await fetchSteps()
        } catch (e) {
            console.error('Không thể cập nhật tiêu đề bước', e)
            message.error('Lỗi khi cập nhật tiêu đề')
        }
    }



    const updateStepEndDate = async (value) => {
        const newEnd = value ? dayjs(value).format('YYYY-MM-DD') : null
        const id = selectedStep.value && selectedStep.value.id
        if (!id) return

        try {
            await updateBiddingStepAPI(id, { end_date: newEnd })
            message.success('Cập nhật ngày kết thúc thành công')
            selectedStep.value.end_date = newEnd
            editing.id = null
            editing.field = null
            await fetchSteps()
        } catch (e) {
            message.error('Không thể cập nhật ngày kết thúc')
            console.warn('Lỗi cập nhật ngày kết thúc:', e)
        }
    }

    const disabledDate = current => {
        return current && current < dayjs(selectedStep.value.start_date).endOf('day');
    };

    const openStepDrawer = async (step) => {
        selectedStep.value = {...step}
        stepStore.setSelectedStep({...step})
        activeStepId.value = step.id // 👈 đánh dấu bước đang mở
        drawerVisible.value = true

        const dataFilter = {}

        if (String(user.role_id) === '3') {
            // Nhân viên → chỉ xem nhiệm vụ của mình
            dataFilter.assigned_to = user.id
        } else if (String(user.role_id) === '2') {
            // Trưởng phòng → xem được nhiệm vụ của cả phòng
            dataFilter.id_department = user.department_id
        }

        try {
            const res = await getTasksByBiddingStep(step.id, dataFilter)
            stepStore.setRelatedTasks(Array.isArray(res.data) ? res.data : [])
        } catch (e) {
            console.error('❌ Không thể tải công việc của bước', e)
            stepStore.setRelatedTasks([])
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

    const statusText = (status) => {
        return {
            '0': 'Chưa bắt đầu',
            '1': 'Đang xử lý',
            '2': 'Đã hoàn thành',
            '3': 'Bỏ qua',
        }[status] || 'Không rõ'
    }

    const getApprovalStatusText = (status) => {
        switch (status) {
            case 'approved':
                return 'Đã duyệt';
            case 'pending':
                return 'Chờ duyệt';
            case 'rejected':
                return 'Từ chối';
            default:
                return 'Không rõ';
        }
    }

    const getApprovalStatusColor = (status) => {
        switch (status) {
            case 'approved':
                return 'green';
            case 'pending':
                return 'blue';
            case 'rejected':
                return 'red';
            default:
                return 'gray';
        }

    }

    const lastCompletedIndex = () => {
        for (let i = steps.value.length - 1; i >= 0; i--) {
            if (steps.value[i].status === '2') return i
        }
        return -1
    }

    const getStepStatusColor = (status) => {
        return {
            '0': 'default',
            '1': 'blue',
            '2': 'green',
            '3': 'orange',
        }[status] || 'default'
    }

    const mapStepStatus = (status) => {
        return {
            '0': 'wait',
            '1': 'process',
            '2': 'finish',
            '3': 'error',
        }[status] || 'wait'
    }

    const getStatusColor = (status) => {
        switch (Number(status)) {
            case 1: return 'blue'     // Đang chuẩn bị
            case 2: return 'green'    // Trúng thầu
            case 3: return 'red'      // Hủy thầu
            default: return 'default'
        }
    }
    const getPriorityText = (priority) => {
        switch (priority) {
            case 'high': return 'Cao'
            case 'normal': return 'Bình thường'
            case 'low': return 'Thấp'
            default: return 'Không xác định'
        }
    }
    const getPriorityColor = (priority) => {
        switch (priority) {
            case 'high': return 'red'
            case 'normal': return 'orange'
            case 'low': return 'blue'
            default: return 'default'
        }
    }

    const getInitials = (name) => {
        if (!name) return '?'
        const parts = name.trim().split(/\s+/)
        return (parts[0][0] + (parts[parts.length-1]?.[0] || '')).toUpperCase()
    }


    const getProgressStatus = (progress) => {
        if (!progress) return 'normal'
        if (progress >= 100) return 'success'
        if (progress >= 80) return 'normal'
        if (progress >= 50) return 'active'
        return 'exception'
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


    const currentStepIndex = () => {
        const last = lastCompletedIndex()
        const next = last + 1
        return next >= steps.value.length ? steps.value.length - 1 : next
    }

    const parseDepartment = (val) => {
        try {
            const parsed = JSON.parse(val)
            return Array.isArray(parsed) ? parsed : [val]
        } catch (e) {
            return val ? [val] : []
        }
    }


    const getTaskStatusText = (status) => ({
        todo: 'Chưa bắt đầu',
        doing: 'Đang làm',
        done: 'Hoàn thành',
        overdue: 'Trễ hạn'
    }[status] || 'Không rõ')

    const getTaskStatusColor = (status) => ({
        todo: 'default',
        doing: 'blue',
        done: 'green',
        overdue: 'red'
    }[status] || 'default')

    const updateStepStatus = async (newStatus, step) => {
        try {
            if (newStatus === '2') {
                await completeBiddingStepAPI(step.id)
                message.success('Bước đã hoàn thành và bước kế tiếp đã được mở')
            } else {
                await updateBiddingStepAPI(step.id, {status: newStatus})
                message.success('Đã cập nhật trạng thái bước')
            }

            drawerVisible.value = false
            await fetchData()
        } catch (e) {
            console.warn('⚠️ Lỗi cập nhật bước:', e)

            // Ưu tiên lấy thông báo cụ thể từ server nếu có
            const errMsg =
                e?.response?.data?.messages?.error || // CodeIgniter 4 style
                e?.response?.data?.message ||         // Generic REST error
                '❌ Đã xảy ra lỗi khi cập nhật bước'

            if (e?.response?.status === 400) {
                message.warning(errMsg) // Lỗi logic (ví dụ: chưa hoàn thành bước trước)
            } else {
                message.error(errMsg)   // Lỗi nghiêm trọng (server, network,...)
            }
        }
    }

    const updateStepDate = async (field, date, step) => {
        try {
            const payload = {[field]: date ? date.format('YYYY-MM-DD') : null}
            await updateBiddingStepAPI(step.id, payload)
            message.success(`Đã cập nhật ${field === 'start_date' ? 'ngày bắt đầu' : 'ngày kết thúc'}`)
            await fetchSteps()
        } catch (e) {
            console.error(`Lỗi cập nhật ${field}:`, e)
            message.error(`Không thể cập nhật ${field}`)
        }
    }

    const fetchUsers = async () => {
        try {
            const res = await getUsers()
            users.value = res.data;
        } catch (e) {
            console.error('Không thể tải danh sách người dùng:', e)
        }
    }

    const getAssignedUserName = (userId) => {
        if (!userId || !users.value.length) return 'Không xác định'
        const found = users.value.find(u => String(u.id) === String(userId))
        return found?.name || `Người dùng #${userId}`
    }

    const goToUserDetail = (userId) => {
        if (!userId) return
        router.push({name: 'user-detail', params: {id: userId}})
    }


    const fetchSteps = async () => {
        try {
            loadingSteps.value = true
            const stepRes = await getBiddingStepsAPI(id)
            steps.value = stepRes.data.filter(step => step.bidding_id === id)
        } catch (e) {
            console.error('Lỗi khi tải bước:', e)
            message.error('Không thể tải tiến trình xử lý')
        } finally {
            loadingSteps.value = false
        }
    }


    const updateStepAssignedTo = async (userId, step) => {
        try {
            if (!userId) {
                message.warning('Vui lòng chọn người phụ trách hợp lệ')
                return
            }

            await updateBiddingStepAPI(step.id, {assigned_to: userId})
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


    const goToCustomerDetail = (customerId) => {
        if (!customerId) return
        router.push({name: 'customer-detail', params: {id: customerId.toString()}})
    }

    const fetchCustomers = async () => {
        try {
            const res = await getCustomers()
            customers.value = res.data?.data || [] // fix ở đây
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

    import { useCommonStore } from '@/stores/common'
    const commonStore = useCommonStore()


    const fetchData = async () => {
        try {
            const res = await getBiddingAPI(id)
            bidding.value = res.data

            loadingSteps.value = true
            let stepRes = await getBiddingStepsAPI(id)

            if (!stepRes.data?.length) {
                await cloneFromTemplatesAPI(id)
                stepRes = await getBiddingStepsAPI(id)
            }

            steps.value = stepRes.data.filter((step) => step.bidding_id === id)// res.data.id = bidding_id
            commonStore.setBiddingIdParent(res.data.id)   // <— ✅ lưu luôn bidding_id cha
        } catch (e) {
            console.error(e)
            message.error('Không thể tải dữ liệu')
        } finally {
            loadingSteps.value = false
        }
    }

    const getStatusText = (status) => {
        const map = {
            1: 'Đang chuẩn bị',
            2: 'Trúng thầu',
            3: 'Hủy thầu',
        }
        return map[status] ?? `Không rõ`
    }

    const goBack = () => {
        if (window.history.length > 1) {
            router.back();
        } else {
            router.push('/bid-list'); // fallback nếu không có trang trước
        }
    }

    onMounted(async () => {

        await Promise.all([
            fetchData(),
            fetchCustomers(),
            fetchUsers()
        ])
    })

</script>

<style>
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
        cursor: default;  /* hoặc pointer nếu muốn click mở chi tiết */
    }
    .desc-progress :deep(.ant-progress) { flex: 1; }
    .progress-meta { white-space: nowrap; font-size: 12px; color: rgba(0,0,0,.65); }

    /* Nếu thấy progress vẫn đổi sang xanh lá ở trạng thái success của AntD */
    :deep(.ant-progress-bg),
    :deep(.ant-progress-success-bg) { background-color: #1890ff !important; }

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
</style>
