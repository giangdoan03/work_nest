<template>
    <div>
        <a-card bordered>
            <a-flex justify="space-between" align="center" class="mb-3">
                <a-typography-title :level="4">Nhiệm vụ cần duyệt</a-typography-title>
                <a-input-search
                    v-model:value="searchTitle"
                    placeholder="Tìm theo tiêu đề"
                    allow-clear
                    style="max-width: 320px"
                    @pressEnter="handleSearch"
                />
            </a-flex>

            <!-- Tabs: Cần duyệt / Đã xử lý / Văn bản -->
            <a-tabs v-model:activeKey="activeTab">
                <a-tab-pane key="docs" tab="Duyệt công văn" />
                <a-tab-pane key="pending" tab="Cần duyệt" />
                <a-tab-pane key="resolved" tab="Đã xử lý" />
            </a-tabs>

            <!-- Bảng cho pending + resolved -->
            <template v-if="activeTab !== 'docs'">
                <a-table
                    :columns="columns"
                    :data-source="rows"
                    :loading="loading"
                    :pagination="pagination"
                    row-key="id"
                    :locale="{ emptyText: 'Không có bản ghi' }"
                    :scroll="{ x: 1300 }"
                    @change="handleTableChange"
                >
                    <template #bodyCell="{ column, record }">
                        <!-- Loại -->
                        <template v-if="column.dataIndex === 'target_type'">
                            <a-tag>{{ mapTypeLabel(record.target_type) }}</a-tag>
                        </template>

                        <!-- Tiêu đề + Link (tự nhận diện external/internal) -->
                        <template v-else-if="column.dataIndex === 'title'">
                            <!-- Tab Cần duyệt -->
                            <template v-if="activeTab === 'pending'">
                                <template v-if="isStep(record)">
                                    <router-link :to="stepDetailRoute(record)" class="link">
                                        {{ record.title || displayFallbackTitle(record) }}
                                    </router-link>
                                </template>
                                <template v-else>
                                    <template v-if="isExternalUrl(record.url)">
                                        <a :href="record.url" class="link" target="_blank" rel="noopener">
                                            {{ record.title || displayFallbackTitle(record) }}
                                        </a>
                                    </template>
                                    <template v-else>
                                        <router-link :to="record.url" class="link">
                                            {{ record.title || displayFallbackTitle(record) }}
                                        </router-link>
                                    </template>
                                </template>
                            </template>

                            <!-- Tab Đã xử lý -->
                            <template v-else-if="activeTab === 'resolved'">
                                <template v-if="isExternalUrl(record.url)">
                                    <a-typography-link :href="record.url" target="_blank" rel="noopener">
                                        {{ record.title || displayFallbackTitle(record) }}
                                    </a-typography-link>
                                </template>
                                <template v-else>
                                    <router-link :to="record.url" class="link">
                                        {{ record.title || displayFallbackTitle(record) }}
                                    </router-link>
                                </template>
                            </template>
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
                            <a-progress :percent="progressPercent(record)" :status="progressStatus(record)" size="small" />
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
                                <a-button v-if="activeTab === 'pending'" type="primary" @click="openModal(record, 'approve')">Duyệt</a-button>
                                <a-button v-if="activeTab === 'pending'" danger @click="openModal(record, 'reject')">Từ chối</a-button>
                                <a-button @click="viewTimeline(record)">Chi tiết</a-button>
                            </a-space>
                        </template>
                    </template>
                </a-table>
            </template>

            <!-- Danh sách Văn bản cần duyệt (PDF) -->
            <template v-else>
                <DocumentApprovalList :my-signature-url="mySignatureUrl" />
            </template>
        </a-card>

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
                <a-timeline-item v-for="st in timelineSteps" :key="st.level" :color="timelineColor(st.status)">
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

// Lazy-load component văn bản để tách bớt bundle phần pdf-lib
import DocumentApprovalList from '../components/Approval/DocumentApprovalList.vue'
const mySignatureUrl = ref('')
import { useUserStore } from '@/stores/user'
import { getUserDetail, getUsers } from '@/api/user'
// ================== STATE ==================
const activeTab   = ref('docs')   // 'pending' | 'resolved' | 'docs'
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
    { title: 'Tiến độ',      dataIndex: 'progress',      key: 'progress',      width: 200 },
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
const clamp = (n, min, max) => Math.max(min, Math.min(max, n))
const safeParseJSON = (v) => { if (v == null) return null; if (typeof v === 'object') return v; try { return JSON.parse(v) } catch { return null } }

const makeUrl = (type, id) => {
    const _id = Number(id)
    switch (type) {
        case 'task':          return { name: 'tasks-detail', params: { id: _id } }
        case 'bidding':       return { name: 'biddings-info', params: { id: _id } }
        case 'contract':      return { name: 'contract-detail', params: { id: _id } }
        case 'bidding_step':  return { name: 'BiddingStepDetail', params: { id: _id } }
        case 'contract_step': return { name: 'ContractStepDetail', params: { id: _id } }
        default: return '/'
    }
}

const normalizeApprovalRow = (ai = {}) => {
    const meta = safeParseJSON(ai.meta_json)
    const targetType = meta?.target_type || ai.target_type
    const targetId   = meta?.target_id   || ai.target_id

    return {
        ...ai,
        title: meta?.title || ai.title || `[${ai.target_type}] #${ai.target_id}`,
        url: isExternalUrl(meta?.url) ? meta.url : isExternalUrl(ai.url) ? ai.url : makeUrl(targetType, targetId),
        assignee_name: meta?.assignee_name ?? ai.assignee_name ?? null,
        id: ai.id || ai.approval_id || ai.request_id,
        meta_json: meta,
        current_level: toInt(ai.current_level),
        _total_steps: ai._total_steps != null ? toInt(ai._total_steps) : undefined,
    }
}

const isExternalUrl = (u) => typeof u === 'string' && /^https?:\/\//i.test(u)

// ================== FETCH ==================
const fetchData = async () => {
    if (activeTab.value === 'docs') return // tab docs tự fetch bên trong component con
    loading.value = true
    try {
        const { data } = activeTab.value === 'pending'
            ? await getApprovalInbox({
                page: pagination.value.current,
                per_page: pagination.value.pageSize,
                search: (searchTitle.value || '').trim() || undefined,
                target_types: 'bidding,contract,bidding_step,contract_step,task,document',
            })
            : await listApprovals({
                page: pagination.value.current,
                per_page: pagination.value.pageSize,
                status: 'approved,rejected',
                acted_by_me: 1,
                target_types: 'bidding,contract,bidding_step,contract_step,task,document',
            })

        const items = Array.isArray(data?.data) ? data.data : []
        rows.value = items.map(normalizeApprovalRow)
        pagination.value.total = toInt(data?.pager?.total, items.length)
    } catch (e) {
        message.error('Không thể tải danh sách phê duyệt')
    } finally {
        loading.value = false
    }
}

const isStep = (r) => r?.target_type === 'bidding_step' || r?.target_type === 'contract_step'
const stepDetailRoute = (r) => {
    const id = Number(r?.target_id)
    if (!id) return '/'
    return r.target_type === 'bidding_step'
        ? { name: 'BiddingStepDetail', params: { id } }
        : { name: 'ContractStepDetail', params: { id } }
}

const handleTableChange = (pg) => {
    pagination.value.current = pg.current
    pagination.value.pageSize = pg.pageSize
    fetchData()
}
const handleSearch = () => { pagination.value.current = 1; fetchData() }

// ================== ACTIONS ==================
const openModal = (record, action) => {
    selectedRecord.value = { ...record, id: record.instance_id, step_id: record.step_id }
    modalAction.value = action === 'reject' ? 'reject' : 'approve'
    comment.value = ''
    modalVisible.value = true
}

const handleModalSubmit = async () => {
    const id = selectedRecord.value?.id
    if (!id || submitting.value) return

    submitting.value = true
    try {
        const payload = comment.value ? { note: comment.value } : {}
        if (modalAction.value === 'approve') {
            await approveApproval(id, payload)
            message.success('Duyệt thành công')
        } else {
            await rejectApproval(id, payload)
            message.success('Từ chối thành công')
        }

        modalVisible.value = false

        // cập nhật lại rows cục bộ để nhanh, rồi refetch để chắc
        rows.value = rows.value.filter(r => (r.instance_id || r.id) !== id)
        pagination.value.total = Math.max(0, pagination.value.total - 1)
        if (rows.value.length === 0 && pagination.value.current > 1) {
            pagination.value.current -= 1
        }

        if (activeTab.value === 'pending') activeTab.value = 'resolved'
        await fetchData()
    } catch (e) {
        message.error(e?.response?.data?.message || (modalAction.value === 'approve' ? 'Duyệt thất bại' : 'Từ chối thất bại'))
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

const statusColor = (s) => s === 'approved' ? 'green' : s === 'rejected' ? 'red' : s === 'pending' ? 'orange' : 'default'
const statusText  = (s) => s === 'approved' ? 'Đã duyệt' : s === 'rejected' ? 'Từ chối' : s === 'pending' ? 'Đang chờ' : '—'

const progressPercent = (r) => {
    const total = toInt(r._total_steps ?? r.total_steps, 0)
    if (total <= 0) return r.status === 'approved' ? 100 : 0
    if (r.status === 'approved') return 100
    const approvedCount = Math.min(total, toInt(r.current_level))
    return clamp(Math.round((approvedCount / total) * 100), 0, 100)
}
const progressStatus = (r) => r.status === 'approved' ? 'success' : r.status === 'rejected' ? 'exception' : undefined
const progressText   = (r) => {
    const total = toInt(r._total_steps ?? r.total_steps, 0)
    if (total <= 0) {
        return r.status === 'pending' ? 'Chưa chọn người duyệt' : 'Không cần phê duyệt'
    }
    if (r.status === 'approved') return `Hoàn tất (${total}/${total})`
    if (r.status === 'rejected') return `Bị từ chối tại cấp ${toInt(r.current_level) + 1}`
    return `Đang duyệt: Cấp ${toInt(r.current_level) + 1}/${total}`
}
const progressColor  = (r) => r.status === 'approved' ? 'green' : r.status === 'rejected' ? 'red' : 'orange'

const displayFallbackTitle = (r) => `[${mapTypeLabel(r.target_type)}] #${r.target_id}`
const formatTime = (ts) => (ts ? new Date(ts).toLocaleString('vi-VN') : '')
const timelineColor = (s) => (s === 'approved' ? 'green' : s === 'rejected' ? 'red' : 'orange')

// ================== WATCHERS ==================
watch(activeTab, () => {
    // Chỉ fetch khi là 2 tab danh sách nhiệm vụ; tab docs dùng component con
    if (activeTab.value !== 'docs') {
        pagination.value.current = 1
        fetchData()
    }
})
watch(searchTitle, debounce(() => {
    if (activeTab.value !== 'docs') {
        pagination.value.current = 1
        fetchData()
    }
}, 400))

onMounted(fetchData)
onMounted(async () => {
    try {
        const userStore = useUserStore()
        const myId = userStore?.user?.id

        // Ưu tiên: gọi /users/:id để lấy profile mới nhất
        if (myId) {
            try {
                const res = await getUserDetail(myId)
                // BE có thể trả {data:{...}} hoặc trực tiếp {...}
                const me = res?.data?.data || res?.data || null
                mySignatureUrl.value = me?.signature_url
                    || userStore.user?.signature_url
                    || ''
                return
            } catch {
                // Fallback nhẹ: gọi /users và tìm theo id
                const list = await getUsers()
                const all = Array.isArray(list?.data) ? list.data : (list?.data?.data || [])
                const me = all.find(u => String(u.id) === String(myId)) || null
                mySignatureUrl.value = me?.signature_url
                    || userStore.user?.signature_url
                    || ''
                return
            }
        }

        // Nếu chưa có user trong store (trường hợp hy hữu)
        mySignatureUrl.value = ''
    } catch {
        mySignatureUrl.value = ''
    }
})
</script>

<style scoped>
.mb-3 { margin-bottom: 12px; }
.text-xs { font-size: 12px; }
.text-gray-500 { color: #8c8c8c; }
.p-3 { padding: 12px; }
.link { color: #1677ff; }
</style>
