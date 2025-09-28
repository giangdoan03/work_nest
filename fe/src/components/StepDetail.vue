<template>
    <div class="p-4">
        <a-breadcrumb class="mb-3">
            <a-breadcrumb-item><router-link to="/">Trang chủ</router-link></a-breadcrumb-item>
            <a-breadcrumb-item>{{ typeLabel }}</a-breadcrumb-item>
            <a-breadcrumb-item>Chi tiết bước #{{ id }}</a-breadcrumb-item>
        </a-breadcrumb>

        <!-- Nút quay lại -->
        <a-button class="mb-3" @click="goBack">← Quay lại</a-button>

        <!-- THÔNG TIN BƯỚC -->
        <a-card :loading="loadingStep" class="mb-4" :title="step?.title || `Bước #${id}`" style="margin-bottom: 15px">
            <template #extra>
                <a-tag :color="statusColor(toInt(step?.status))">{{ statusText(toInt(step?.status)) }}</a-tag>
            </template>

            <!-- 3 cột tóm tắt -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <div class="text-gray-500 text-sm mb-1">Phòng ban</div>
                    <div>{{ departmentText || '—' }}</div>
                </div>
                <div>
                    <div class="text-gray-500 text-sm mb-1">Hạn</div>
                    <div>
                        <a-tag v-if="step?.end_date" class="mr-2">{{ formatDate(step.end_date) }}</a-tag>
                        <a-tag v-if="daysTag.text" :color="daysTag.color">{{ daysTag.text }}</a-tag>
                        <span v-else>—</span>
                    </div>
                </div>
                <div>
                    <div class="text-gray-500 text-sm mb-1">Tiến độ</div>
                    <div>
                        <a-progress :percent="progressPercent" :status="progressPercent===100?'success':undefined" style="max-width:260px" />
                        <div class="text-xs text-gray-500">{{ progressText }}</div>
                    </div>
                </div>
            </div>

            <!-- chi tiết thêm -->
            <a-descriptions class="mt-4" bordered size="small" :column="{ xs: 1, sm: 1, md: 2, lg: 2, xl: 2 }">
                <a-descriptions-item label="ID bước">#{{ step?.id }}</a-descriptions-item>
                <a-descriptions-item label="Gói thầu">#{{ step?.bidding_id }}</a-descriptions-item>
                <a-descriptions-item label="Số thứ tự">{{ step?.step_number }}</a-descriptions-item>

                <a-descriptions-item label="Mã bước / Step code">{{ step?.step_code || '—' }}</a-descriptions-item>
                <a-descriptions-item label="Người phụ trách">
                    {{ step?.assigned_to_name || (step?.assigned_to ? ('#'+step.assigned_to) : '—') }}
                </a-descriptions-item>
                <a-descriptions-item label="Trạng thái duyệt">
                    <a-tag :color="approvalColor(step?.approval_status)">{{ approvalText(step?.approval_status) }}</a-tag>
                </a-descriptions-item>

                <a-descriptions-item label="Cấp hiện tại">Cấp {{ toInt(step?.current_level) + 1 }}</a-descriptions-item>
                <a-descriptions-item label="Task liên kết">
                    <router-link v-if="step?.task_id" :to="taskLinkById(step.task_id)" class="link">
                        #{{ step.task_id }}
                    </router-link>
                    <span v-else>—</span>
                </a-descriptions-item>
                <a-descriptions-item label="Khách hàng">{{ step?.customer_id || '—' }}</a-descriptions-item>

                <a-descriptions-item label="Tạo lúc">{{ formatDateTime(step?.created_at) }}</a-descriptions-item>
                <a-descriptions-item label="Cập nhật">{{ formatDateTime(step?.updated_at) }}</a-descriptions-item>
            </a-descriptions>
        </a-card>

        <!-- TIMELINE PHÊ DUYỆT -->
        <a-card v-if="approvalSteps.length" class="mb-4" title="Timeline phê duyệt" style="margin-bottom: 15px">
            <a-timeline>
                <a-timeline-item v-for="st in approvalSteps" :key="st.level" :color="timelineColor(st.status)">
                    Cấp {{ st.level }}:
                    <strong>{{ st.status==='approved' ? 'Đã duyệt' : st.status==='rejected' ? 'Từ chối' : 'Đang chờ' }}</strong>
                    • Người duyệt: {{ st._approver_name || (st.approver_id ? ('#'+st.approver_id) : '—') }}
                    <template v-if="st.commented_at"> • {{ formatDateTime(st.commented_at) }}</template>
                    <div v-if="st.note">📝 {{ st.note }}</div>
                </a-timeline-item>
            </a-timeline>
        </a-card>

        <!-- TASKS -->
        <a-card :loading="loadingTasks" title="Công việc thuộc bước này">
            <template #extra>
                <span class="text-sm text-gray-500">Tổng: {{ rows.length }}</span>
            </template>

            <a-table
                :columns="taskColumns"
                :data-source="rows"
                row-key="id"
                :pagination="{ pageSize: 10 }"
                :scroll="{ x: 1100 }"
            >
                <template #bodyCell="{ column, record }">
                    <template v-if="column.dataIndex==='title'">
                        <router-link :to="taskLink(record)" class="link">{{ record.title || ('Task #'+record.id) }}</router-link>
                    </template>

                    <template v-else-if="column.dataIndex==='approval_status'">
                        <a-tag :color="approvalColor(record.approval_status)">{{ approvalText(record.approval_status) }}</a-tag>
                    </template>

                    <template v-else-if="column.dataIndex==='progress'">
                        <a-progress :percent="toInt(record.progress)" :status="toInt(record.progress)>=100?'success':undefined" />
                    </template>

                    <template v-else-if="column.dataIndex==='status'">
                        <a-tag :color="taskStatusColor(record.status)">{{ taskStatusText(record.status) }}</a-tag>
                    </template>

                    <template v-else-if="column.dataIndex==='assignee_name'">
                        {{ record.assignee_name || record.assigned_to_name || (record.assigned_to ? '#'+record.assigned_to : '—') }}
                    </template>

                    <template v-else-if="column.dataIndex==='start_date'">
                        {{ record.start_date ? formatDate(record.start_date) : '—' }}
                    </template>

                    <template v-else-if="column.dataIndex==='end_date'">
                        <div>
                            <div>{{ record.end_date ? formatDate(record.end_date) : '—' }}</div>
                            <div v-if="record._days">
                                <a-tag v-if="record._days.remaining===0 && record.end_date" color="gold">Đến hạn hôm nay</a-tag>
                                <a-tag v-else-if="record._days.remaining>0" color="green">{{ record._days.remaining }} ngày còn lại</a-tag>
                                <a-tag v-else-if="record._days.overdue>0" color="red">Trễ {{ record._days.overdue }} ngày</a-tag>
                            </div>
                        </div>
                    </template>
                </template>
            </a-table>
        </a-card>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import { useRouter } from 'vue-router'
const router = useRouter()
import { getBiddingStepAPI, getTasksByBiddingStepAPI } from '@/api/bidding.js' // đảm bảo file này export đủ 4 hàm như mình gợi ý

const props = defineProps({
    id:   { type: Number, required: true },
    type: { type: String,  required: true } // 'bidding' | 'contract'
})

const loadingStep  = ref(false)
const loadingTasks = ref(false)
const step         = ref(null)
const rows         = ref([])

const typeLabel = computed(() => props.type === 'bidding' ? 'Gói thầu' : 'Hợp đồng')

/** ===== Columns cho bảng task ===== */
const taskColumns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: 'Tiêu đề', dataIndex: 'title', key: 'title', width: 200, ellipsis: true },
    { title: 'Người thực hiện', dataIndex: 'assignee_name', key: 'assignee_name', width: 200 },
    { title: 'Duyệt', dataIndex: 'approval_status', key: 'approval_status', width: 120 },
    { title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: 160 },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 140 },
    { title: 'Bắt đầu', dataIndex: 'start_date', key: 'start_date', width: 120 },
    { title: 'Kết thúc', dataIndex: 'end_date', key: 'end_date', width: 120 },
]

/** ===== Utils & formatters ===== */
const toInt      = (v, d=0)=> Number.isFinite(+v) ? (+v) : d
const formatDate = (v)=> v ? dayjs(v).format('DD/MM/YYYY') : ''
const formatDateTime = (v)=> v ? dayjs(v).format('DD/MM/YYYY HH:mm') : ''

const statusColor = (s)=> s===2?'green':s===1?'blue':s===0?'default':''
const statusText  = (s)=> s===2?'Hoàn thành':s===1?'Đang làm':s===0?'Chưa bắt đầu':'—'

const taskStatusColor = (s)=> s==='done'?'green':s==='todo'?'default':'blue'
const taskStatusText  = (s)=> s==='done'?'Hoàn thành':s==='todo'?'Mới tạo':'Đang làm'

const approvalColor = (s)=> s==='approved'?'green':s==='rejected'?'red':s==='pending'?'orange':''
const approvalText  = (s)=> s==='approved'?'Đã duyệt':s==='rejected'?'Từ chối':s==='pending'?'Đang chờ':'—'
const timelineColor = (s)=> s==='approved'?'green':s==='rejected'?'red':'orange'

/** Parse helpers */
const tryParse = (v) => {
    if (v == null) return null
    if (typeof v === 'object') return v
    try { return JSON.parse(v) } catch { return null }
}

const taskLinkById = (id) => ({ path: `/non-workflow/${String(id)}/info` })

/** Department text (array hoặc string) */
const departmentText = computed(() => {
    const raw = step.value?.department
    const arr = tryParse(raw)
    if (Array.isArray(arr)) return arr.join(', ')
    return raw || ''
})

/** Approval steps (array đã parse) */
const approvalSteps = computed(() => {
    const arr = tryParse(step.value?.approval_steps)
    return Array.isArray(arr) ? arr : []
})

/** Tag ngày cho header */
const daysTag = computed(() => {
    if (!step.value?.end_date) return {text:'', color:''}
    const d = computeDays(step.value.end_date)
    if (!d) return {text:'', color:''}
    if (d.remaining === 0) return {text:'Đến hạn hôm nay', color:'gold'}
    if (d.remaining > 0)  return {text:`${d.remaining} ngày còn lại`, color:'green'}
    if (d.overdue > 0)    return {text:`Trễ ${d.overdue} ngày`, color:'red'}
    return {text:'', color:''}
})

/** Tiến độ header */
const progressPercent = computed(() => {
    if (Number.isFinite(+step.value?.step_progress)) return toInt(step.value.step_progress)
    const list = rows.value || []
    if (!list.length) return toInt(step.value?.status) === 2 ? 100 : 0
    const doneApproved = list.filter(t => (t.status==='done' || toInt(t.progress)>=100) && t.approval_status==='approved').length
    return Math.round((doneApproved / list.length) * 100)
})
const progressText = computed(() => {
    const total = rows.value?.length || 0
    if (!total) return toInt(step.value?.status)===2 ? 'Hoàn tất (không có task)' : 'Chưa có task'
    const doneApproved = rows.value.filter(t => (t.status==='done' || toInt(t.progress)>=100) && t.approval_status==='approved').length
    return `Đã duyệt xong ${doneApproved}/${total} task`
})

/** Task detail link */
const taskLink = (t) => ({ path: `/non-workflow/${String(t.id)}/info` })

function computeDays(dateStr){
    if (!dateStr) return null
    const today = dayjs().startOf('day')
    const due   = dayjs(dateStr).startOf('day')
    if (!due.isValid()) return null
    const diff = due.diff(today, 'day')
    if (diff === 0) return { remaining: 0, overdue: 0 }
    if (diff > 0)  return { remaining: diff, overdue: 0 }
    return { remaining: 0, overdue: Math.abs(diff) }
}

const axiosErr = (e, fb) => e?.response?.data?.message || e?.message || fb

/** Fetch step */
async function fetchStep () {
    loadingStep.value = true
    try {
        const { data } = props.type === 'bidding'
            ? await getBiddingStepAPI(props.id)
            : ''

        // Chuẩn hoá kiểu dữ liệu (convert number string -> number…)
        step.value = {
            ...data,
            id: toInt(data.id),
            bidding_id: toInt(data.bidding_id),
            step_number: toInt(data.step_number),
            status: toInt(data.status),
            current_level: toInt(data.current_level),
            assigned_to: data.assigned_to != null ? toInt(data.assigned_to) : null
        }
    } catch (e) {
        message.error(axiosErr(e, 'Không tải được chi tiết bước'))
    } finally { loadingStep.value = false }
}

/** Fetch tasks */
async function fetchTasks () {
    loadingTasks.value = true
    try {
        const { data } = props.type === 'bidding'
            ? await getTasksByBiddingStepAPI(props.id)
            : ''

        const list = Array.isArray(data?.tasks) ? data.tasks : Array.isArray(data) ? data : []
        rows.value = list.map(t => ({
            ...t,
            id: toInt(t.id),
            assigned_to: t.assigned_to != null ? toInt(t.assigned_to) : null,
            progress: toInt(t.progress),
            _days: computeDays(t.end_date)
        }))
    } catch (e) {
        message.error(axiosErr(e, 'Không tải được tasks'))
    } finally { loadingTasks.value = false }
}

const goBack = () => {
    // Có lịch sử thì back
    if (window.history.length > 1) return router.back()

    // Fallback theo loại
    if (props.type === 'bidding') {
        // nếu đã load step thì ưu tiên về trang gói thầu kèm anchor #steps
        if (step.value?.bidding_id) {
            return router.push(`/biddings/${step.value.bidding_id}/info#steps`)
        }
        return router.push('/biddings')
    } else {
        // dành cho contract_step nếu bạn dùng chung component
        if (step.value?.contract_id) {
            return router.push(`/contracts/${step.value.contract_id}#steps`)
        }
        return router.push('/contracts')
    }
}

onMounted(async () => {
    await fetchStep()
    await fetchTasks()
})
</script>

<style scoped>
.mb-3 { margin-bottom: 12px; }
.p-4  { padding: 16px; }
.link { color: #1677ff; }
</style>
