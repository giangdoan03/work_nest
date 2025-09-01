<template>
    <div>
        <a-flex justify="space-between" align="center" class="mb-3">
            <a-typography-title :level="4">Nhiệm vụ cần duyệt</a-typography-title>

            <a-input-search
                v-model:value="searchTitle"
                placeholder="Tìm theo tiêu đề (meta_json.title)"
                allow-clear
                style="max-width: 320px"
                @pressEnter="handleSearch"
            />
        </a-flex>

        <!-- ✅ Chỉ còn 2 tab: Cần duyệt / Đã xử lý -->
        <a-tabs v-model:activeKey="activeTab" @change="handleTabChange">
            <a-tab-pane key="pending" tab="Cần duyệt" />
            <a-tab-pane key="resolved" tab="Đã xử lý" />
        </a-tabs>

        <a-table
            :columns="columns"
            :data-source="rows"
            :loading="loading"
            :pagination="pagination"
            row-key="id"
            :locale="{ emptyText: 'Không có bản ghi' }"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <!-- Loại -->
                <template v-if="column.dataIndex === 'target_type'">
                    <a-tag>{{ mapTypeLabel(record.target_type) }}</a-tag>
                </template>

                <!-- Tiêu đề + Link -->
                <template v-else-if="column.dataIndex === 'title'">
                    <router-link
                        v-if="record.meta_json?.url"
                        :to="record.meta_json.url"
                        class="link"
                    >
                        {{ record.meta_json?.title || displayFallbackTitle(record) }}
                    </router-link>
                    <span v-else>{{ record.meta_json?.title || displayFallbackTitle(record) }}</span>
                </template>

                <!-- Cấp hiện tại -->
                <template v-else-if="column.dataIndex === 'current_level'">
                    Cấp {{ (record.current_level ?? 0) + 1 }}
                </template>

                <!-- Tổng cấp -->
                <template v-else-if="column.dataIndex === 'total_steps'">
                    {{ record._total_steps ?? '—' }}
                </template>

                <!-- Tiến độ -->
                <template v-else-if="column.dataIndex === 'progress'">
                    <a-progress
                        :percent="progressPercent(record)"
                        :status="progressPercent(record) === 100 ? 'success' : 'active'"
                        size="small"
                    />
                    <div class="text-xs text-gray-500">
                        <a-tag :color="progressColor(record)" style="font-size:12px;">
                            {{ progressText(record) }}
                        </a-tag>
                    </div>
                </template>

                <!-- Trạng thái -->
                <template v-else-if="column.dataIndex === 'status'">
                    <a-tag :color="statusColor(record.status)">{{ statusText(record.status) }}</a-tag>
                </template>

                <!-- Người gửi -->
                <template v-else-if="column.dataIndex === 'submitted_by'">
                    {{ record._submitted_by_name || ('#' + (record.submitted_by ?? '—')) }}
                </template>

                <!-- Thời điểm gửi -->
                <template v-else-if="column.dataIndex === 'submitted_at'">
                    {{ formatTime(record.submitted_at) || '—' }}
                </template>

                <!-- Hành động -->
                <template v-else-if="column.dataIndex === 'action'">
                    <a-space>
                        <a-button
                            v-if="activeTab === 'pending'"
                            type="primary"
                            @click="openModal(record, 'approve')"
                        >Duyệt</a-button>
                        <a-button
                            v-if="activeTab === 'pending'"
                            danger
                            @click="openModal(record, 'reject')"
                        >Từ chối</a-button>
                        <a-button @click="viewTimeline(record)">Chi tiết</a-button>
                    </a-space>
                </template>
            </template>
        </a-table>

        <!-- Modal nhập comment -->
        <a-modal
            v-model:open="modalVisible"
            :title="modalAction === 'approve' ? 'Xác nhận duyệt' : 'Từ chối phê duyệt'"
            ok-text="Xác nhận"
            cancel-text="Hủy"
            :confirm-loading="submitting"
            @ok="handleModalSubmit"
        >
            <a-form layout="vertical">
                <a-form-item label="Ghi chú (không bắt buộc)">
                    <a-textarea v-model:value="comment" placeholder="Nhập ghi chú…" />
                </a-form-item>
            </a-form>
        </a-modal>

        <!-- Modal Timeline -->
        <a-modal v-model:open="timelineVisible" title="Chi tiết phê duyệt" :footer="null" width="620px">
            <a-timeline>
                <a-timeline-item
                    v-for="st in timelineSteps"
                    :key="st.level"
                    :color="timelineColor(st.status)"
                >
                    <template v-if="st.status === 'approved'">
                        Cấp {{ st.level }}: {{ st._approver_name || ('#' + st.approver_id) }} đã duyệt lúc {{ formatTime(st.commented_at) }}
                        <div v-if="st.note">📝 {{ st.note }}</div>
                    </template>
                    <template v-else-if="st.status === 'rejected'">
                        Cấp {{ st.level }}: {{ st._approver_name || ('#' + st.approver_id) }} từ chối lúc {{ formatTime(st.commented_at) }}
                        <div v-if="st.note">📝 {{ st.note }}</div>
                    </template>
                    <template v-else>
                        Cấp {{ st.level }}: Đang chờ duyệt
                    </template>
                </a-timeline-item>
            </a-timeline>
        </a-modal>
    </div>
</template>


<script setup>
import { ref, onMounted, watch } from 'vue'
import { message } from 'ant-design-vue'
import debounce from 'lodash/debounce'
import {
    getApprovalInbox,
    getApproval,
    approveApproval,
    rejectApproval,
    listApprovals
} from '@/api/approvals'

// ================== STATE ==================
const activeTab   = ref('pending')   // 'pending' | 'resolved'
const rows        = ref([])
const loading     = ref(false)
const searchTitle = ref('')

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    showTotal: (t) => `Tổng ${t} bản ghi`
})

const modalVisible   = ref(false)
const submitting     = ref(false)
const comment        = ref('')
const modalAction    = ref('approve') // 'approve' | 'reject'
const selectedRecord = ref(null)

const timelineVisible = ref(false)
const timelineSteps   = ref([])

// ================== COLUMNS ==================
const columns = [
    { title: 'Loại',         dataIndex: 'target_type',   key: 'target_type',   width: 120 },
    { title: 'Tiêu đề',      dataIndex: 'title',         key: 'title',         width: 300 },
    { title: 'Cấp hiện tại', dataIndex: 'current_level', key: 'current_level', width: 120, align: 'center' },
    { title: 'Tổng cấp',     dataIndex: 'total_steps',   key: 'total_steps',   width: 110, align: 'center' },
    { title: 'Tiến độ',      dataIndex: 'progress',      key: 'progress',      width: 180 },
    { title: 'Trạng thái',   dataIndex: 'status',        key: 'status',        width: 120, align: 'center' },
    { title: 'Người gửi',    dataIndex: 'submitted_by',  key: 'submitted_by',  width: 160 },
    { title: 'Gửi lúc',      dataIndex: 'submitted_at',  key: 'submitted_at',  width: 180 },
    { title: 'Hành động',    dataIndex: 'action',        key: 'action',        width: 240 }
]

// ================== UTILS ==================
const toInt = (v, d = 0) => {
    const n = Number(v)
    return Number.isFinite(n) ? n : d
}

const safeParseJSON = (v) => {
    if (v == null) return null
    if (typeof v === 'object') return v
    try { return JSON.parse(v) } catch { return null }
}

const normalizeApprovalRow = (ai = {}) => {
    const meta = safeParseJSON(ai.meta_json)
    return {
        ...ai,
        meta_json: meta,
        current_level: toInt(ai.current_level),
        _total_steps: ai._total_steps != null ? toInt(ai._total_steps) : undefined,
    }
}

// ================== FETCH ==================
const fetchData = async () => {
    loading.value = true
    try {
        const common = {
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: (searchTitle.value || '').trim() || undefined, // ⚠️ chỉ có tác dụng nếu BE inbox có xử lý search
        }

        // gợi ý: nếu bạn là admin và muốn xem tất cả pending, đổi scope: 'all'
        const scope = 'mine' // hoặc 'all'

        const { data } = activeTab.value === 'pending'
            ? await getApprovalInbox({
                page: pagination.value.current,
                per_page: pagination.value.pageSize,
                search: (searchTitle.value || '').trim() || undefined,
                target_types: 'bidding,contract,bidding_step,contract_step,task', // lấy đủ
                // scope: 'all'  // nếu bạn muốn luôn ép hiển thị tất cả bất kể admin hay không
            })
            : await listApprovals({
                page: pagination.value.current,
                per_page: pagination.value.pageSize,
                status: 'approved,rejected',
                acted_by_me: 1,
                target_types: 'bidding,contract,bidding_step,contract_step,task',
            })

        // debug
        if (activeTab.value === 'pending') {
            console.log('Inbox data:', data?.data)
            console.log('Pager:', data?.pager)
        } else {
            console.log('Resolved data:', data?.data)
            console.log('Pager:', data?.pager)
        }

        const items = Array.isArray(data?.data) ? data.data : []
        rows.value = items.map(normalizeApprovalRow)
        pagination.value.total = toInt(data?.pager?.total, items.length)
    } catch (e) {
        message.error('Không thể tải danh sách phê duyệt')
    } finally {
        loading.value = false
    }
}



// (giữ nếu template vẫn @change trên <a-tabs>)
const handleTabChange = () => {
    pagination.value.current = 1
    fetchData()
}
const handleTableChange = (pg) => {
    pagination.value.current = pg.current
    pagination.value.pageSize = pg.pageSize
    fetchData()
}
const handleSearch = () => {
    pagination.value.current = 1
    fetchData()
}

// ================== ACTIONS ==================
const openModal = (record, action) => {
    selectedRecord.value = record
    modalAction.value = action === 'reject' ? 'reject' : 'approve'
    comment.value = ''
    modalVisible.value = true
}

const handleModalSubmit = async () => {
    if (!selectedRecord.value?.id || submitting.value) return
    submitting.value = true
    try {
        const id = selectedRecord.value.id
        const payload = comment.value ? { note: comment.value } : {}

        if (modalAction.value === 'approve') {
            await approveApproval(id, payload)
            message.success('Duyệt thành công')
        } else {
            await rejectApproval(id, payload)
            message.success('Từ chối thành công')
        }

        modalVisible.value = false

        // Optimistic update + cập nhật phân trang mượt
        rows.value = rows.value.filter(r => r.id !== id)
        pagination.value.total = Math.max(0, pagination.value.total - 1)
        if (rows.value.length === 0 && pagination.value.current > 1) {
            pagination.value.current -= 1
        }

        if (activeTab.value === 'pending') activeTab.value = 'resolved'
        await fetchData()
    } catch (e) {
        message.error(
            e?.response?.data?.message ||
            (modalAction.value === 'approve' ? 'Duyệt thất bại' : 'Từ chối thất bại')
        )
    } finally {
        submitting.value = false
    }
}

// ================== TIMELINE ==================
const viewTimeline = async (record) => {
    try {
        const { data } = await getApproval(record.id)
        timelineSteps.value = Array.isArray(data?.steps) ? data.steps : []
        timelineVisible.value = true
    } catch {
        message.error('Không thể tải chi tiết phê duyệt')
    }
}

// ================== UI HELPERS ==================
const mapTypeLabel = (t) => ({
    bidding: 'Gói thầu',
    contract: 'Hợp đồng',
    bidding_step: 'Bước gói thầu',
    contract_step: 'Bước hợp đồng',
    task: 'Nhiệm vụ',
}[t] || t || '—')

const statusColor = (s) => s === 'approved' ? 'green' : s === 'rejected' ? 'red' : s === 'pending' ? 'orange' : ''

const statusText = (s) => s === 'approved' ? 'Đã duyệt' : s === 'rejected' ? 'Từ chối' : s === 'pending' ? 'Đang chờ' : '—'

const progressPercent = (r) => {
    const total = toInt(r._total_steps ?? r.total_steps, 0)
    if (total <= 0) return r.status === 'approved' ? 100 : 0
    if (r.status === 'approved') return 100
    const approvedCount = Math.min(total, toInt(r.current_level))
    return Math.round((approvedCount / total) * 100)
}

const progressText = (r) => {
    const total = toInt(r._total_steps ?? r.total_steps, 0)
    if (total <= 0) {
        return r.status === 'pending' ? 'Chưa chọn người duyệt' : 'Không cần phê duyệt'
    }
    if (r.status === 'approved') return `Hoàn tất (${total}/${total})`
    if (r.status === 'rejected') return `Bị từ chối tại cấp ${toInt(r.current_level) + 1}`
    return `Đang duyệt: Cấp ${toInt(r.current_level) + 1}/${total}`
}



const progressColor = (r) => r.status === 'approved' ? 'green' : r.status === 'rejected' ? 'red' : 'orange'

const displayFallbackTitle = (r) => `[${mapTypeLabel(r.target_type)}] #${r.target_id}`
const formatTime = (ts) => (ts ? new Date(ts).toLocaleString('vi-VN') : '')
const timelineColor = (s) => (s === 'approved' ? 'green' : s === 'rejected' ? 'red' : 'orange')

// ================== WATCHERS ==================
watch(activeTab, () => {
    pagination.value.current = 1
    fetchData()
})
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
.link { color: #1677ff; }
</style>
