<template>
    <div>
        <a-flex justify="space-between" align="center" class="mb-3">
            <a-typography-title :level="4">Nhiệm vụ cần duyệt</a-typography-title>

            <!-- 🔍 Tìm kiếm tên nhiệm vụ -->
            <a-input-search
                v-model:value="searchTitle"
                placeholder="Tìm theo tên nhiệm vụ"
                allow-clear
                style="max-width: 300px;"
                @pressEnter="handleSearch"
            />
        </a-flex>

        <!-- ================== TAB CHA ================== -->
        <a-tabs v-model:activeKey="parentTab">
            <!-- ===== Tab cha 1: chứa toàn bộ module duyệt ===== -->
            <a-tab-pane key="tab1" tab="Nhiệm vụ con">
                <!-- ===== Tab con hiện có ===== -->
                <a-tabs v-model:activeKey="activeTab" @change="handleTabChange">
                    <a-tab-pane key="resolved" tab="Đã duyệt / Từ chối" />
                    <a-tab-pane key="pending" tab="Cần duyệt" />
                </a-tabs>

                <!-- ===== Bảng danh sách ===== -->
                <a-table
                    :columns="columns"
                    :data-source="taskApprovals"
                    :loading="loading"
                    :pagination="pagination"
                    row-key="id"
                    :locale="{ emptyText: 'Không có nhiệm vụ nào' }"
                    @change="handleTableChange"
                >
                    <template #bodyCell="{ column, record }">
                        <!-- Tên nhiệm vụ -->
                        <template v-if="column.dataIndex === 'title'">
                            <router-link :to="`/internal-tasks/${record.task_id}/info`">
                                {{ record.title }}
                            </router-link>
                        </template>

                        <!-- Người thực hiện -->
                        <template v-else-if="column.dataIndex === 'assigned_to_name'">
                            {{ record.assigned_to_name || '—' }}
                        </template>

                        <!-- Cấp hiện tại -->
                        <template v-else-if="column.dataIndex === 'level'">
                            Cấp {{ record.level }}
                        </template>

                        <!-- Tổng cấp (fallback nếu BE chưa enrich) -->
                        <template v-else-if="column.dataIndex === 'approval_steps_total'">
                            {{ record.approval_steps_total ?? record.approval_steps ?? '—' }}
                        </template>

                        <!-- Trạng thái -->
                        <template v-else-if="column.dataIndex === 'status'">
                            <a-tag :color="getStatusColor(record.status)">
                                {{ getStatusText(record.status) }}
                            </a-tag>
                        </template>

                        <!-- Tiến độ -->
                        <template v-else-if="column.dataIndex === 'approval_progress'">
                            <a-progress
                                :percent="getProgressPercent(record)"
                                :status="getProgressPercent(record) === 100 ? 'success' : 'active'"
                                size="small"
                            />
                            <div class="text-xs text-gray-500">
                                <a-tag :color="getLevelTagColorSmart(record)" style="font-size: 12px;">
                                    {{ getLevelTextSmart2(record) }}
                                </a-tag>
                            </div>
                        </template>

                        <!-- Thời gian duyệt -->
                        <template v-else-if="column.dataIndex === 'approved_at'">
                            {{ formatTime(record.approved_at) || '—' }}
                        </template>

                        <!-- Hành động -->
                        <template v-else-if="column.dataIndex === 'action'">
                            <a-space>
                                <a-tooltip :title="!record.can_approve ? (record.cannot_reason || 'Không đủ quyền') : ''">
                                    <a-button
                                        type="primary"
                                        :disabled="!record.can_approve"
                                        @click="openModal(record, 'approve')"
                                    >
                                        Duyệt
                                    </a-button>
                                </a-tooltip>

                                <a-tooltip :title="!record.can_reject ? (record.cannot_reason || 'Không đủ quyền') : ''">
                                    <a-button
                                        danger
                                        :disabled="!record.can_reject"
                                        @click="openModal(record, 'reject')"
                                    >
                                        Từ chối
                                    </a-button>
                                </a-tooltip>

                                <a-button @click="viewTimeline(record)">Chi tiết</a-button>
                            </a-space>
                        </template>
                    </template>
                </a-table>

                <!-- ✅ Modal nhập comment -->
                <a-modal
                    v-model:open="modalVisible"
                    :title="modalAction === 'approve' ? 'Xác nhận duyệt' : 'Từ chối nhiệm vụ'"
                    ok-text="Xác nhận"
                    cancel-text="Hủy"
                    :confirm-loading="submitting"
                    @ok="handleModalSubmit"
                >
                    <a-form layout="vertical">
                        <a-form-item label="Ghi chú (không bắt buộc)">
                            <a-textarea v-model:value="comment" placeholder="Nhập lý do hoặc ghi chú..." />
                        </a-form-item>
                    </a-form>
                </a-modal>

                <!-- ✅ Modal dòng thời gian duyệt -->
                <a-modal
                    v-model:open="timelineVisible"
                    title="Chi tiết duyệt nhiệm vụ"
                    :footer="null"
                    width="600px"
                >
                    <a-timeline>
                        <a-timeline-item
                            v-for="step in approvalTimeline"
                            :key="step.level"
                            :color="getTimelineColor(step.status)"
                        >
                            <template v-if="step.status === 'approved'">
                                <span><CheckCircleOutlined style="margin-right: 6px;" /></span>
                                Cấp {{ step.level }}: {{ step.approved_by_name }} đã duyệt lúc {{ formatTime(step.approved_at) }}
                                <div v-if="step.comment">📝 {{ step.comment }}</div>
                            </template>

                            <template v-else-if="step.status === 'rejected'">
                                <span><CloseCircleOutlined style="margin-right: 6px;" /></span>
                                Cấp {{ step.level }}: {{ step.approved_by_name }} từ chối lúc {{ formatTime(step.approved_at) }}
                                <div v-if="step.comment">📝 {{ step.comment }}</div>
                            </template>

                            <template v-else-if="step.status === 'pending'">
                                <span><ClockCircleOutlined style="margin-right: 6px;" /></span>
                                Cấp {{ step.level }}: Đang chờ duyệt
                            </template>

                            <template v-else>
                                <span><ArrowRightOutlined style="margin-right: 6px;" /></span>
                                Cấp {{ step.level }}: Chưa đến lượt
                            </template>
                        </a-timeline-item>
                    </a-timeline>
                </a-modal>
            </a-tab-pane>

            <!-- ===== Tab cha 2 ===== -->
            <a-tab-pane key="tab2" tab="Gói thầu" force-render>
                <!-- Nhúng nguyên UI danh sách + duyệt gói thầu -->
                <BidListForTab :embedded="true" ref="bidListRef" />
            </a-tab-pane>

            <!-- ===== Tab cha 3 ===== -->
            <a-tab-pane key="tab3" tab="Tab 3">
                <div class="p-3 text-gray-500">Nội dung tab 3</div>
            </a-tab-pane>
        </a-tabs>
    </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { message } from 'ant-design-vue'
import {
    CheckCircleOutlined,
    CloseCircleOutlined,
    ClockCircleOutlined,
    ArrowRightOutlined,
} from '@ant-design/icons-vue'
import debounce from 'lodash/debounce'
import {
    getTaskApprovals,
    approveTaskAPI,
    rejectTaskAPI,
    getFullApprovalStatus,
    canActApprovalAPI
} from '@/api/taskApproval'
import BidList from "@/page/BidList.vue";
import BidListForTab from "@/components/BidListForTab.vue";

// ================== STATE ==================
const parentTab = ref('tab1')            // <-- Tab cha (mặc định Tab 1)
const taskApprovals = ref([])
const loading = ref(false)
const activeTab = ref('pending')         // tab con hiện có
const searchTitle = ref('')

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    showTotal: (t) => `Tổng ${t} nhiệm vụ`
})

const modalVisible = ref(false)
const submitting = ref(false)
const comment = ref('')
const selectedRecord = ref(null)
const modalAction = ref('approve')

const timelineVisible = ref(false)
const approvalTimeline = ref([])

// ================== COLUMNS ==================
const columns = [
    { title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title', width: 250 },
    { title: 'Người thực hiện', dataIndex: 'assigned_to_name', key: 'assigned_to_name', width: 200 },
    { title: 'Cấp hiện tại', dataIndex: 'level', key: 'level', width: 100, align: 'center'  },
    { title: 'Tổng cấp', dataIndex: 'approval_steps_total', key: 'approval_steps_total', width: 100, align: 'center' },
    { title: 'Tiến độ', dataIndex: 'approval_progress', key: 'approval_progress', width: 160},
    { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 120, align: 'center'},
    { title: 'Người duyệt', dataIndex: 'approved_by_name', key: 'approved_by_name', width: 160 },
    { title: 'Thời gian duyệt', dataIndex: 'approved_at', key: 'approved_at', width: 180 },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: 240 }
]

// ================== FETCH DATA ==================
const fetchData = async () => {
    loading.value = true
    try {
        const res = await getTaskApprovals({
            page: pagination.value.current,
            limit: pagination.value.pageSize,
            status: activeTab.value === 'pending' ? 'pending' : 'resolved',
            search: (searchTitle.value || '').trim()
        })
        taskApprovals.value = res.data?.data || []
        pagination.value.total = Number(res.data?.total || 0)
    } catch (e) {
        message.error('Không thể tải danh sách duyệt')
    } finally {
        loading.value = false
    }
}

const handleTabChange = () => {
    pagination.value.current = 1
    fetchData()
}

const handleTableChange = (paginationChange) => {
    pagination.value.current = paginationChange.current
    pagination.value.pageSize = paginationChange.pageSize
    fetchData()
}

const handleSearch = () => {
    pagination.value.current = 1
    fetchData()
}

// ================== ACTIONS ==================
const openModal = async (record, action) => {
    selectedRecord.value = record
    modalAction.value = action
    comment.value = ''

    try {
        // Nếu list đã có quyền và đang ở tab pending → tiết kiệm 1 call
        if (activeTab.value === 'pending' && (record.can_approve || record.can_reject)) {
            if (action === 'approve' && !record.can_approve) return message.warning(record.cannot_reason || 'Bạn không thể duyệt bản ghi này')
            if (action === 'reject' && !record.can_reject) return message.warning(record.cannot_reason || 'Bạn không thể từ chối bản ghi này')
            modalVisible.value = true
            return
        }

        const { data } = await canActApprovalAPI(record.id)
        if (action === 'approve' && !data.can_approve) {
            return message.warning(data.cannot_reason || 'Bạn không thể duyệt bản ghi này')
        }
        if (action === 'reject' && !data.can_reject) {
            return message.warning(data.cannot_reason || 'Bạn không thể từ chối bản ghi này')
        }
        modalVisible.value = true
    } catch {
        message.error('Không kiểm tra được quyền hành động')
    }
}

const handleModalSubmit = async () => {
    if (!selectedRecord.value) return
    submitting.value = true
    try {
        if (modalAction.value === 'approve') {
            await approveTaskAPI(selectedRecord.value.id, { comment: comment.value })
            message.success('Duyệt thành công')
        } else {
            await rejectTaskAPI(selectedRecord.value.id, { comment: comment.value })
            message.success('Từ chối thành công')
        }
        modalVisible.value = false
        await fetchData()
    } catch {
        message.error(modalAction.value === 'approve' ? 'Duyệt thất bại' : 'Từ chối thất bại')
    } finally {
        submitting.value = false
    }
}

// ================== TIMELINE ==================
const viewTimeline = async (record) => {
    if (!record?.task_id) return
    try {
        const res = await getFullApprovalStatus(record.task_id)
        approvalTimeline.value = res.data || []
        timelineVisible.value = true
    } catch {
        message.error('Không thể tải chi tiết duyệt')
    }
}

watch(timelineVisible, (open) => {
    if (!open) approvalTimeline.value = []
})

// ================== HELPERS ==================
const getTimelineColor = (status) => {
    switch (status) {
        case 'approved': return 'green'
        case 'rejected': return 'red'
        case 'pending':  return 'orange'
        default:         return 'gray'
    }
}

const getApprovedAndTotal = (record) => {
    const approved = Number(record.approved_levels ?? 0)
    const total    = Number(record.approval_steps_total ?? record.approval_steps ?? 0)
    return { approved, total }
}

const getProgressPercent = (record) => {
    const total     = Number(record.approval_steps_total ?? record.approval_steps ?? 0)
    const approved  = Number(record.approved_levels ?? 0)
    const level     = Number(record.level ?? 0)
    const taskState = String(record.task_approval_status ?? '').toLowerCase()
    const isResolvedRow = (activeTab.value === 'resolved') || (record.status !== 'pending')

    if (total <= 0) return 0

    if (isResolvedRow) {
        if (record.status === 'rejected') {
            return Math.max(0, Math.round(((level - 1) / total) * 100))
        }
        return Math.round((Math.min(level, total) / total) * 100)
    }

    if (total === 1) {
        return approved >= 1 ? 100 : 0
    }
    if (taskState === 'approved') return 100
    return Math.round((Math.min(approved, total) / total) * 100)
}

const getLevelTextSmart2 = (record) => {
    const total     = Number(record.approval_steps_total ?? record.approval_steps ?? 0)
    const approved  = Number(record.approved_levels ?? 0)
    const level     = Number(record.level ?? 0)
    const cur       = Number(record.current_level ?? record.level ?? 0)
    const taskState = String(record.task_approval_status ?? '').toLowerCase()
    const isResolvedRow = (activeTab.value === 'resolved') || (record.status !== 'pending')

    if (total === 0) return 'Không cần duyệt'

    if (isResolvedRow) {
        if (record.status === 'rejected') {
            const done = Math.max(0, level - 1)
            return `Bị từ chối tại cấp ${level} (${done}/${total})`
        }
        if (level < total) return `Đã duyệt ${level}/${total} (${Math.round((level/total)*100)}%)`
        return `Hoàn tất (${total}/${total})`
    }

    if (total === 1) {
        return approved >= 1 ? 'Hoàn tất (1/1)' : 'Chưa duyệt (0/1)'
    }
    if (taskState === 'approved' || approved >= total) return `Hoàn tất (${total}/${total})`
    if (taskState === 'rejected') return `Bị từ chối (${approved}/${total})`
    if (approved === 0) return cur > 0 ? `Đang chờ: Cấp ${cur}/${total}` : `Chưa bắt đầu (0/${total})`
    return cur > 0
        ? `Đang duyệt: Cấp ${cur}/${total} (đã ${approved}/${total})`
        : `Đã duyệt ${approved}/${total}`
}

const getLevelTagColorSmart = (record) => {
    const { approved, total } = getApprovedAndTotal(record)
    const statusTask = String(record.task_approval_status ?? '').toLowerCase()

    if (total === 0) return 'default'
    if (statusTask === 'rejected') return 'red'
    if (total === 1) return approved >= 1 ? 'green' : 'gray'
    if (statusTask === 'approved' || approved >= total) return 'green'
    if (approved === 0) return 'gray'
    return 'orange'
}

const getStatusColor = (status) => {
    switch (status) {
        case 'pending':  return 'orange'
        case 'approved': return 'green'
        case 'rejected': return 'red'
        default:         return ''
    }
}

const getStatusText = (status) => {
    switch (status) {
        case 'pending':  return 'Đang chờ'
        case 'approved': return 'Đã duyệt'
        case 'rejected': return 'Từ chối'
        default:         return '—'
    }
}

const formatTime = (ts) => (ts ? new Date(ts).toLocaleString('vi-VN') : '')

// Debounce tìm kiếm
watch(searchTitle, debounce(() => {
    pagination.value.current = 1
    fetchData()
}, 400))

onMounted(fetchData)
</script>

<style scoped>
.mb-3 { margin-bottom: 12px; }
.text-xs { font-size: 12px; }
.text-gray-500 { color: #8c8c8c; }
.p-3 { padding: 12px; }
</style>
