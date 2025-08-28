<template>
    <div>
        <!-- Tìm kiếm + Tabs trạng thái phê duyệt -->
        <a-flex justify="space-between" align="center" style="margin-bottom:10px">
            <a-input
                v-model:value="searchTerm"
                allow-clear
                style="width:320px"
                placeholder="Tìm gói thầu theo tiêu đề…"
            >
                <template #prefix><SearchOutlined /></template>
            </a-input>
        </a-flex>

        <a-tabs v-model:activeKey="activeApprovalTab" @change="handleTabChange" style="margin-bottom:10px">
            <a-tab-pane key="all" tab="Tất cả" />
            <a-tab-pane key="pending" tab="Chờ duyệt" />
            <a-tab-pane key="approved" tab="Đã duyệt" />
            <a-tab-pane key="rejected" tab="Từ chối" />
        </a-tabs>

        <!-- Bảng -->
        <a-table
            :columns="columns"
            :data-source="tableData"
            :loading="loading"
            row-key="id"
            :pagination="pagination"
            :scroll="{ x: 'max-content' }"
            @change="handleTableChange"
        >
            <template #bodyCell="slot">
                <!-- STT -->
                <template v-if="slot.column?.dataIndex === 'stt'">
                    {{ (pagination.current - 1) * pagination.pageSize + slot.index + 1 }}
                </template>

                <!-- Tiêu đề -->
                <template v-else-if="slot.column?.key === 'title'">
                    <a-tooltip :title="slot.record.title">
                        <a-typography-text strong style="cursor:pointer" @click="goToDetail(slot.record.id)">
                            {{ truncateText(slot.record.title, 28) }}
                        </a-typography-text>
                    </a-tooltip>
                </template>

                <!-- Người phụ trách -->
                <template v-else-if="slot.column?.dataIndex === 'assigned_to_name'">
                    <a-tooltip :title="slot.record.assigned_to_name || 'N/A'">
                        <span>{{ slot.record.assigned_to_name || 'N/A' }}</span>
                    </a-tooltip>
                </template>

                <!-- Trạng thái duyệt -->
                <template v-else-if="slot.column?.dataIndex === 'approval_status'">
                    <a-tag :color="getApprovalColor(slot.record.approval_status)">
                        {{ getApprovalText(slot.record.approval_status) }}
                    </a-tag>
                </template>

                <!-- Cấp hiện tại / tổng (1/1, 2/2, …) -->
                <template v-else-if="slot.column?.dataIndex === 'approval_level'">
                    <a-badge
                        v-if="slot.record.approval_steps?.length"
                        :count="`${Number(slot.record.current_level ?? 0) + 1}/${slot.record.approval_steps.length}`"
                    />
                    <span v-else>—</span>
                </template>

                <!-- Danh sách tên người duyệt -->
                <template v-else-if="slot.column?.dataIndex === 'approvers'">
                    <a-tooltip :title="approverNames(slot.record)">
                        <span>{{ truncateText(approverNames(slot.record), 40) }}</span>
                    </a-tooltip>
                </template>

                <!-- Hành động -->
                <template v-else-if="slot.column?.dataIndex === 'action'">
                    <!-- Gửi phê duyệt / Gửi lại -->
                    <a-tooltip
                        v-if="canShowSend(slot.record)"
                        :title="slot.record.approval_status === APPROVAL_STATUS.REJECTED ? 'Gửi phê duyệt lại' : 'Gửi phê duyệt'"
                    >
                        <SendOutlined class="icon-action" style="color:#faad14;" @click="openSendApproval(slot.record)" />
                    </a-tooltip>

                    <!-- Duyệt / Từ chối / Sửa người duyệt (khi đang chờ duyệt) -->
                    <template v-if="Number(slot.record.status) === STATUS.SENT_FOR_APPROVAL && (slot.record.approval_status ?? 'pending') === APPROVAL_STATUS.PENDING">
                        <a-tooltip title="Phê duyệt">
                            <CheckOutlined class="icon-action" style="color:#52c41a;" @click="openDecision(slot.record, 'approve')" />
                        </a-tooltip>
                        <a-tooltip title="Từ chối">
                            <CloseOutlined class="icon-action" style="color:#ff4d4f;" @click="openDecision(slot.record, 'reject')" />
                        </a-tooltip>
                        <a-tooltip title="Sửa người duyệt">
                            <EditOutlined class="icon-action" style="color:#1890ff" @click="editApproval(slot.record)" />
                        </a-tooltip>
                    </template>
                </template>
            </template>
        </a-table>

        <!-- Modal chọn/sửa người duyệt (≥ 1 cấp) -->
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
                <a-alert type="info" show-icon>Thứ tự người duyệt sẽ theo thứ tự bạn chọn trong danh sách.</a-alert>
            </a-form>
        </a-modal>

        <!-- Modal nhập lý do duyệt / từ chối -->
        <a-modal
            v-model:open="decisionVisible"
            :title="decisionType === 'approve' ? 'Phê duyệt gói thầu' : 'Từ chối gói thầu'"
            :confirm-loading="loadingCreate"
            @ok="submitDecision"
        >
            <a-form layout="vertical">
                <a-form-item :label="decisionType === 'approve' ? 'Lý do phê duyệt (tuỳ chọn)' : 'Lý do từ chối (khuyến nghị nhập)'">
                    <a-textarea v-model:value="decisionNote" :rows="4" placeholder="Nhập lý do..." />
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { message } from 'ant-design-vue'
import { EditOutlined, SearchOutlined, SendOutlined, CheckOutlined, CloseOutlined } from '@ant-design/icons-vue'
import { getBiddingsAPI, sendBiddingForApprovalAPI, approveBiddingAPI, rejectBiddingAPI, updateApprovalStepsAPI } from '@/api/bidding'
import { getUsers } from '@/api/user.js'
import { useRouter } from 'vue-router'

const router = useRouter()

/** ===== STATE ===== */
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const searchTerm = ref('')

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    pageSizeOptions: ['10', '20', '50', '100'],
    showTotal: (total, range) => `${range[0]}-${range[1]} / ${total} gói thầu`
})

const userOptions = ref([])
const usersMap = ref({})

const sendApprovalVisible = ref(false)
const sendApprovalTarget  = ref(null)
const approverIdsSelected = ref([]) // ≥ 1 id

// Modal lý do approve/reject
const decisionVisible = ref(false)
const decisionType    = ref('approve') // 'approve' | 'reject'
const decisionNote    = ref('')
const decisionRow     = ref(null)

// Tabs lọc theo trạng thái duyệt
const activeApprovalTab = ref('all') // 'all' | 'pending' | 'approved' | 'rejected'

/** ===== CONSTANTS ===== */
const STATUS = Object.freeze({
    PREPARING: 1,
    WON: 2,
    CANCELLED: 3,
    SENT_FOR_APPROVAL: 4,
})

const APPROVAL_STATUS = Object.freeze({
    PENDING: 'pending',
    APPROVED: 'approved',
    REJECTED: 'rejected',
})
const APPROVAL_STATUS_MAP = {
    [APPROVAL_STATUS.PENDING]:  { text: 'Chờ duyệt',  color: 'gold'  },
    [APPROVAL_STATUS.APPROVED]: { text: 'Đã duyệt',   color: 'green' },
    [APPROVAL_STATUS.REJECTED]: { text: 'Từ chối',    color: 'red'   },
}
const getApprovalText  = s => (APPROVAL_STATUS_MAP[s]?.text ?? '—')
const getApprovalColor = s => (APPROVAL_STATUS_MAP[s]?.color ?? 'default')

/** ===== COLUMNS ===== */
const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: 70 },
    { title: 'Tên gói thầu', dataIndex: 'title', key: 'title' },
    { title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'center', width: 160 },

    // 3 cột phê duyệt
    { title: 'Trạng thái duyệt', dataIndex: 'approval_status', key: 'approval_status', align: 'center', width: 140 },
    { title: 'Cấp', dataIndex: 'approval_level', key: 'approval_level', align: 'center', width: 90 },
    { title: 'Người duyệt', dataIndex: 'approvers', key: 'approvers', width: 280 },

    { title: 'Hành động', dataIndex: 'action', key: 'action', width: 200 },
]

/** ===== HELPERS ===== */
const truncateText = (text, len=30) => !text ? '' : (text.length > len ? text.slice(0, len) + '…' : text)
const approverNames = (r) => (r.approval_steps || []).map(s => s.approver_name || ('#' + s.approver_id)).join(', ')
const canShowSend = (row) => {
    const st = Number(row.status)
    // Không hiện khi đã WON/CANCELLED
    if ([STATUS.WON, STATUS.CANCELLED].includes(st)) return false
    // Hiện khi bị từ chối (cho phép gửi lại)
    if ((row.approval_status ?? 'pending') === APPROVAL_STATUS.REJECTED) return true
    // Lần đầu: đang chuẩn bị + pending
    return st === STATUS.PREPARING && (row.approval_status ?? 'pending') === APPROVAL_STATUS.PENDING
}

/** ===== API ===== */
const fetchUsers = async () => {
    const res = await getUsers()
    userOptions.value = res.data.map(u => ({ label: u.name, value: Number(u.id) }))
    usersMap.value = Object.fromEntries(res.data.map(u => [Number(u.id), u.name]))
}

const getBiddings = async () => {
    loading.value = true
    try {
        const keyword = (searchTerm.value || '').trim()
        const params = {
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: keyword || undefined
        }
        // lọc theo tab
        if (activeApprovalTab.value !== 'all') {
            params.approval_status = activeApprovalTab.value // pending | approved | rejected
        }

        const res = await getBiddingsAPI(params)
        const { data, pager } = res.data || {}

        const parseApprovalSteps = (raw) => {
            let arr = []
            try {
                if (Array.isArray(raw)) arr = raw
                else if (typeof raw === 'string' && raw.trim()) arr = JSON.parse(raw)
            } catch (_) { arr = [] }
            return arr.map(s => ({
                ...s,
                approver_id: Number(s.approver_id ?? s.id ?? s.user_id),
                approver_name: usersMap.value[Number(s.approver_id)] || null,
            }))
        }

        tableData.value = (data || []).map(r => ({
            ...r,
            status: r.status != null ? Number(r.status) : null,
            approval_status: r.approval_status ?? APPROVAL_STATUS.PENDING,
            approval_steps: parseApprovalSteps(r.approval_steps),
            current_level: Number(r.current_level ?? 0)
        }))

        if (pager) {
            pagination.value.total   = +pager.total || 0
            pagination.value.current = +pager.current_page || 1
            pagination.value.pageSize= +pager.per_page || pagination.value.pageSize
        }
    } finally {
        loading.value = false
    }
}

/** ===== Actions ===== */
const goToDetail = (id) => router.push({ name: 'bid-detail', params: { id } })

const openSendApproval = (row) => {
    sendApprovalTarget.value = row
    // gợi ý sẵn manager nếu có
    approverIdsSelected.value = row.manager_id ? [Number(row.manager_id)] : []
    sendApprovalVisible.value = true
}

const editApproval = (row) => {
    sendApprovalTarget.value = row
    const ids = (row.approval_steps || []).map(s => Number(s.approver_id)).filter(Boolean)
    approverIdsSelected.value = ids.length ? ids : (row.manager_id ? [Number(row.manager_id)] : [])
    sendApprovalVisible.value = true
}

const confirmSendApproval = async () => {
    // ≥ 1 người duyệt
    if (!Array.isArray(approverIdsSelected.value) || approverIdsSelected.value.length < 1) {
        message.warning('Cần chọn tối thiểu 1 người duyệt.')
        return
    }
    const uniqueIds = approverIdsSelected.value
        .map(n => Number(n))
        .filter((n,i,arr) => Number.isInteger(n) && arr.indexOf(n) === i)
    if (!uniqueIds.length) {
        message.warning('Danh sách người duyệt không hợp lệ.')
        return
    }

    const target = sendApprovalTarget.value
    if (!target?.id) {
        message.error('Thiếu thông tin gói thầu.')
        return
    }

    const isEdit = Array.isArray(target.approval_steps) && target.approval_steps.length > 0
    if (isEdit && (target.approval_status === APPROVAL_STATUS.APPROVED)) {
        message.warning('Gói thầu đã phê duyệt xong, không thể thay đổi người duyệt.')
        return
    }

    try {
        loadingCreate.value = true
        if (isEdit && target.approval_status !== APPROVAL_STATUS.REJECTED) {
            // đang chờ duyệt → chỉ cho cập nhật danh sách
            await updateApprovalStepsAPI(target.id, { approver_ids: uniqueIds })
            message.success('Cập nhật người duyệt thành công.')
        } else {
            // gửi lần đầu hoặc gửi lại sau khi bị từ chối
            await sendBiddingForApprovalAPI(target.id, { approver_ids: uniqueIds })
            message.success(target.approval_status === APPROVAL_STATUS.REJECTED ? 'Đã gửi phê duyệt lại.' : 'Đã gửi phê duyệt.')
        }
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

// Mở modal lý do approve / reject
const openDecision = (row, type) => {
    decisionRow.value  = row
    decisionType.value = type
    decisionNote.value = ''
    decisionVisible.value = true
}

// Gửi approve / reject kèm note
const submitDecision = async () => {
    if (!decisionRow.value?.id) {
        message.error('Thiếu thông tin gói thầu.')
        return
    }
    try {
        loadingCreate.value = true
        const payload = { note: decisionNote.value || null }
        if (decisionType.value === 'approve') {
            await approveBiddingAPI(decisionRow.value.id, payload)
            message.success('Đã phê duyệt.')
        } else {
            await rejectBiddingAPI(decisionRow.value.id, payload)
            message.success('Đã từ chối.')
        }
        decisionVisible.value = false
        await getBiddings()
    } catch (e) {
        message.error(e?.response?.data?.message || (decisionType.value === 'approve' ? 'Phê duyệt thất bại.' : 'Từ chối thất bại.'))
    } finally {
        loadingCreate.value = false
    }
}

/** ===== Effects ===== */
let searchTimer = null
watch(searchTerm, () => {
    clearTimeout(searchTimer)
    searchTimer = setTimeout(() => {
        pagination.value.current = 1
        getBiddings()
    }, 300)
})

const handleTableChange = (pag) => {
    pagination.value.current = pag.current
    pagination.value.pageSize = pag.pageSize
    getBiddings()
}

const handleTabChange = () => {
    pagination.value.current = 1
    getBiddings()
}

onMounted(async () => {
    await fetchUsers()
    await getBiddings()
})
</script>

<style scoped>
.icon-action {
    font-size: 18px;
    margin-right: 18px;
    cursor: pointer;
}
</style>
