<!-- src/views/BiddingStepTasks.vue -->
<template>
    <div>
        <a-card bordered>
            <a-page-header
                :title="`Bước ${step?.step_number || stepId}: ${step?.title || ''}`"
                :sub-title="bidding?.title || bidding?.name || '—'"
                @back="() => router.back()"
                style="padding:0 0 12px"
            >
                <template #extra>
                    <a-button type="primary" @click="openCreateTask">Thêm nhiệm vụ mới</a-button>
                </template>
            </a-page-header>

            <a-spin :spinning="loading">
                <a-empty v-if="tasks.length === 0" description="Không có công việc" />
                <a-table
                    :columns="columns"
                    :data-source="pagedTasks"
                    row-key="id"
                    :pagination="pagination"
                    :scroll="{ x: 'max-content' }"
                    :expandedRowKeys="expandedKeys"
                    :expandRowByClick="false"
                    :childrenColumnName="'children'"
                    :expandable="{ expandIcon: () => null }"
                    @change="handleTableChange"
                >
                    <template #bodyCell="{ column, record }">
                        <!-- STT (DFS) -->
                        <template v-if="column.key === 'index'">
                            <span class="index-badge">{{ record._order }}</span>
                        </template>

                        <!-- Expander -->
                        <template v-else-if="column.key === 'expander'">
                            <div class="exp-cell" :style="{ paddingLeft: `${record._level * 12}px` }">
                                <template v-if="record.children?.length">
                                    <button
                                        class="exp-btn"
                                        :aria-expanded="isExpanded(record)"
                                        :title="isExpanded(record) ? 'Thu gọn' : 'Mở rộng'"
                                        @click.stop="toggleExpand(record)"
                                        @keydown.enter.prevent="toggleExpand(record)"
                                        @keydown.space.prevent="toggleExpand(record)"
                                    >
                                        <component :is="isExpanded(record) ? MinusSquareOutlined : PlusSquareOutlined" />
                                    </button>
                                </template>
                                <template v-else>
                                    <span class="exp-placeholder" aria-hidden="true"></span>
                                </template>
                            </div>
                        </template>

                        <!-- Tên công việc -->
                        <template v-else-if="column.key === 'title'">
                            <router-link :to="buildTaskLink(record)" class="task-title-cell">
                                <span class="task-title" :class="{ child: record.parent_id }">
                                  {{ truncate(record.title, 25) }}
                                </span>
                            </router-link>
                        </template>

                        <!-- Người thực hiện -->
                        <template v-else-if="column.key === 'assigned_to'">
                            {{ getAssignedUserName(record.assigned_to) }}
                        </template>

                        <!-- Tiến trình -->
                        <template v-else-if="column.key === 'progress'">
                            {{ Number(record.progress ?? 0) }}%
                        </template>

                        <!-- Ưu tiên -->
                        <template v-else-if="column.key === 'priority'">
                            <a-tag :color="record._meta.priorityColor">{{ record._meta.priorityText }}</a-tag>
                        </template>

                        <!-- Ngày -->
                        <template v-else-if="column.key === 'start_date'">{{ fmtDate(record.start_date) }}</template>
                        <template v-else-if="column.key === 'end_date'">{{ fmtDate(record.end_date) }}</template>

                        <!-- Trạng thái -->
                        <template v-else-if="column.key === 'status'">
                            <a-tag :color="record._meta.statusColor">{{ record._meta.statusText }}</a-tag>
                        </template>

                        <!-- Hạn -->
                        <template v-else-if="column.key === 'deadline'">
                            <template v-if="record._meta.deadline.type === 'overdue'">
                                <a-tag color="error">Quá hạn {{ record._meta.deadline.days }} ngày</a-tag>
                            </template>
                            <template v-else-if="record._meta.deadline.type === 'today'">
                                <a-tag :color="'#faad14'">Hạn chót hôm nay</a-tag>
                            </template>
                            <template v-else-if="record._meta.deadline.type === 'remaining'">
                                <a-tag color="green">Còn {{ record._meta.deadline.days }} ngày</a-tag>
                            </template>
                            <template v-else>—</template>
                        </template>

                        <!-- Duyệt -->
                        <template v-else-if="column.key === 'approval_status'">
                            <div class="approval-cell" @click.self="openSendApproval(record)" style="cursor:pointer">
                                <a-space :size="8" align="center">
                                    <template v-if="record.status === 'done' && record.approval_status === 'approved'">
                                        <a-tag color="green">Hoàn thành & Đã duyệt</a-tag>
                                    </template>
                                    <template v-else>
                                        <a-tag :color="record._meta.approvalColor" @click.stop="openSendApproval(record)">
                                            {{ record._meta.approvalText }}
                                        </a-tag>

                                        <!-- Chỉ hiện nút khi đang pending & tôi là người duyệt -->
                                        <template v-if="String(record.approval_status || '').toLowerCase() === 'pending' && isMyApprover(record)">
                                            <a-button size="small" type="primary" @click.stop="approveTask(record)">Duyệt</a-button>
                                            <a-button size="small" danger @click.stop="rejectTask(record)">Từ chối</a-button>
                                        </template>
                                    </template>
                                </a-space>
                            </div>
                        </template>

                        <!-- Thao tác -->
                        <template v-else-if="column.key === 'actions'">
                            <a-popconfirm
                                title="Bạn chắc chắn muốn xoá công việc này?"
                                ok-text="Xoá"
                                cancel-text="Huỷ"
                                ok-type="danger"
                                :disabled="deletingId === record.id"
                                @confirm="() => onDeleteTask(record)"
                            >
                                <a-button danger type="link" :loading="deletingId === record.id">
                                    <DeleteOutlined />
                                </a-button>
                            </a-popconfirm>
                        </template>
                    </template>
                </a-table>
            </a-spin>
        </a-card>

        <!-- Drawer tạo task ROOT -->
        <DrawerCreateTask
            v-model:open-drawer="openDrawer"
            :list-user="users"
            type="bidding"
            :create-as-root="createAsRoot"
            @update:open-drawer="v => { openDrawer = v; if (!v) createAsRoot = false }"
            @submitForm="reloadTasks"
        />

        <!-- Drawer tạo subtask -->
        <DrawerCreateSubtask
            :open="subDrawerOpen"
            :parentTask="subDrawerParent"
            :listUser="users"
            @update:open="v => (subDrawerOpen = v)"
            @created="handleSubtaskCreated"
        />

        <!-- Modal chọn người duyệt -->
        <a-modal
            v-model:open="sendApprovalVisible"
            title="Chọn người duyệt"
            :confirm-loading="loadingCreate"
            @ok="confirmSendApproval"
        >
            <a-form layout="vertical">
                <a-form-item label="Người duyệt">
                    <a-select
                        v-model:value="approverIdsSelected"
                        mode="multiple"
                        :options="userOptions"
                        placeholder="Chọn ít nhất 1 người duyệt"
                        :max-tag-count="3"
                    />
                </a-form-item>
                <a-alert type="info" show-icon>
                    Sau khi lưu, nhiệm vụ sẽ chuyển sang trạng thái <b>chờ duyệt</b>.
                </a-alert>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup>
import { ref, onMounted, computed, reactive } from 'vue'
import dayjs from 'dayjs'
import { useRoute, useRouter } from 'vue-router'
import { message, Modal } from 'ant-design-vue'
import { DeleteOutlined, PlusSquareOutlined, MinusSquareOutlined } from '@ant-design/icons-vue'

import { getBiddingAPI, getBiddingStepsAPI } from '@/api/bidding'
import { getTasksByBiddingStep, deleteTask, updateTask } from '@/api/task'
import { getUsers } from '@/api/user'
import { approveTaskSimpleAPI, rejectTaskSimpleAPI } from '@/api/taskApproval.js'
import { useUserStore } from '@/stores/user' // cần có store user hiện tại
import DrawerCreateTask from '@/components/common/DrawerCreateTask.vue'
import DrawerCreateSubtask from '@/components/common/DrawerCreateSubtask.vue'


const route = useRoute()
const router = useRouter()
const bidId = Number(route.params.bidId)
const stepId = Number(route.params.stepId)

const step = ref(null)
const bidding = ref(null)
const tasks = ref([])
const users = ref([])
const loading = ref(false)
const deletingId = ref(null)

const openDrawer = ref(false)
const createAsRoot = ref(false)
const subDrawerOpen = ref(false)
const subDrawerParent = ref(null)

const expandedKeys = ref([])

/* ====== APPROVAL (task) ====== */
const APPROVAL_STATUS = Object.freeze({
    PENDING: 'pending',
    APPROVED: 'approved',
    REJECTED: 'rejected'
})
const sendApprovalVisible = ref(false)
const loadingCreate = ref(false)
const sendApprovalTarget = ref(null)
const approverIdsSelected = ref([])

const store = useUserStore()
const meId = computed(() => Number(store?.currentUser?.id || 0))

const userOptions = computed(() =>
    users.value.map(u => ({ label: u.name, value: Number(u.id) }))
)

/* ---------- Toggle expand ---------- */
const toggleExpand = (row) => {
    const k = String(row?.id ?? row)
    const list = expandedKeys.value
    const i = list.indexOf(k)
    if (i === -1) list.push(k)
    else list.splice(i, 1)
}
const isExpanded = (row) => expandedKeys.value.includes(String(row?.id ?? row))

/* ---------- Dictionaries ---------- */
const PRIORITY_TEXT = { high: 'Cao', normal: 'Bình thường', low: 'Thấp' }
const PRIORITY_COLOR = { high: 'red', normal: 'green', low: 'blue' }
const TASK_STATUS_TEXT = { todo: 'Chưa bắt đầu', doing: 'Đang triển khai', done: 'Hoàn thành', overdue: 'Trễ hạn' }
const TASK_STATUS_COLOR = { todo: 'default', doing: 'green', done: 'green', overdue: 'red' }
const APPROVAL_TEXT = { approved: 'Đã duyệt', pending: 'Chờ duyệt', rejected: 'Từ chối' }
const APPROVAL_COLOR = { approved: 'green', pending: 'blue', rejected: 'red', default: 'gray' }

/* ---------- Utils ---------- */
const fmtDate = (v) => (v ? (dayjs(v).isValid() ? dayjs(v).format('DD/MM/YYYY') : '—') : '—')
const truncate = (text, len = 30) => (!text ? '' : text.length > len ? `${text.slice(0, len)}...` : text)

const usersById = computed(() => {
    const m = new Map()
    for (const u of users.value) m.set(String(u.id), u)
    return m
})
const getAssignedUserName = (uid) =>
    usersById.value.get(String(uid))?.name || (uid ? `Người dùng #${uid}` : 'Không xác định')

const buildDeadlineMeta = (endDate) => {
    if (!endDate) return { type: 'none', days: 0 }
    const dEnd = dayjs(endDate)
    if (!dEnd.isValid()) return { type: 'none', days: 0 }
    const diff = dEnd.startOf('day').diff(dayjs().startOf('day'), 'day')
    if (diff < 0) return { type: 'overdue', days: Math.abs(diff) }
    if (diff === 0) return { type: 'today', days: 0 }
    return { type: 'remaining', days: diff }
}

const annotateTask = (t) => {
    const priorityKey = String(t.priority ?? '').toLowerCase()
    const statusKey = String(t.status ?? '').toLowerCase()
    const approvalKey = String(t.approval_status ?? '').toLowerCase()

    let approverIds = []
    try {
        approverIds = Array.isArray(t.approver_ids) ? t.approver_ids : JSON.parse(t.approver_ids || '[]')
    } catch { approverIds = [] }

    const approverNames = approverIds.map(id => usersById.value.get(String(id))?.name || `#${id}`)

    return {
        ...t,
        approver_ids: approverIds,
        approver_names: approverNames,
        _meta: {
            priorityText: PRIORITY_TEXT[priorityKey] ?? 'Không xác định',
            priorityColor: PRIORITY_COLOR[priorityKey] ?? 'default',
            statusText: TASK_STATUS_TEXT[statusKey] ?? 'Không rõ',
            statusColor: TASK_STATUS_COLOR[statusKey] ?? 'default',
            approvalText: APPROVAL_TEXT[approvalKey] ?? 'Không rõ',
            approvalColor: APPROVAL_COLOR[approvalKey] ?? 'gray',
            deadline: buildDeadlineMeta(t.end_date),
        },
    }
}

/* Tôi có phải người duyệt của task này không? */
const isMyApprover = (row) => {
    try {
        const ids = Array.isArray(row.approver_ids) ? row.approver_ids : JSON.parse(row.approver_ids || '[]')
        return ids.map(Number).includes(meId.value)
    } catch { return false }
}

/* ---------- Build tree + DFS order ---------- */
const toTree = (flat) => {
    const byId = new Map()
    flat.forEach((r) => {
        const n = annotateTask(r)
        n.id = String(n.id)
        n.parent_id = n.parent_id == null || n.parent_id === '' ? null : String(n.parent_id)
        n.children = []
        n._level = 0
        byId.set(n.id, n)
    })

    const roots = []
    for (const n of byId.values()) {
        if (n.parent_id && byId.has(n.parent_id)) byId.get(n.parent_id).children.push(n)
        else roots.push(n)
    }

    const sortFn = (a, b) => {
        const aC = dayjs(a.created_at).valueOf() || 0
        const bC = dayjs(b.created_at).valueOf() || 0
        if (aC !== bC) return aC - bC
        const aS = dayjs(a.start_date).valueOf() || 0
        const bS = dayjs(b.start_date).valueOf() || 0
        if (aS !== bS) return aS - bS
        return String(a.title || '').localeCompare(String(b.title || ''))
    }
    const sortAll = (arr) => {
        arr.sort(sortFn)
        arr.forEach((ch) => sortAll(ch.children))
    }
    sortAll(roots)

    let order = 0
    const dfs = (arr, level = 0) => {
        for (const n of arr) {
            n._order = ++order
            n._level = level
            if (n.children?.length) dfs(n.children, level + 1)
        }
    }
    dfs(roots)

    return roots
}

/* ---------- Columns ---------- */
const columns = [
    { title: 'STT', key: 'index', width: 50, align: 'center', className: 'stt-col' },
    { title: 'Việc con', key: 'expander', width: 100, align: 'center', className: 'expander-col' },
    { title: 'Tên công việc', dataIndex: 'title', key: 'title', align: 'left' },
    { title: 'Người thực hiện', dataIndex: 'assigned_to', key: 'assigned_to', width: 180 },
    { title: 'Tiến trình', dataIndex: 'progress', key: 'progress', width: 120, align: 'center' },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority', width: 120, align: 'center' },
    { title: 'Bắt đầu', dataIndex: 'start_date', key: 'start_date', width: 120, align: 'center' },
    { title: 'Kết thúc', dataIndex: 'end_date', key: 'end_date', width: 120, align: 'center' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 140, align: 'center' },
    { title: 'Hạn', dataIndex: 'deadline', key: 'deadline', width: 160, align: 'center' },
    { title: 'Phê duyệt', dataIndex: 'approval_status', key: 'approval_status', width: 220, align: 'center' },
    { title: 'Thao tác', key: 'actions', width: 80, align: 'center', fixed: 'right' },
]

const buildTaskLink = (row) => {
    if (bidId && stepId) {
        return { name: 'bidding-task-info-in-step', params: { bidId: String(bidId), stepId: String(stepId), id: String(row.id) } }
    }
    return { name: 'bidding-task-info', params: { id: String(row.id) } }
}

/* ---------- Pagination ---------- */
const pagination = reactive({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    pageSizeOptions: ['5', '10', '20', '50', '100'],
    showTotal: (total, [a, b]) => `${a}-${b} / ${total}`,
})
const pagedTasks = computed(() => {
    const start = (pagination.current - 1) * pagination.pageSize
    const end = start + pagination.pageSize
    return tasks.value.slice(start, end)
})
const ensurePageInRange = () => {
    const pages = Math.max(1, Math.ceil((pagination.total || 0) / pagination.pageSize))
    if (pagination.current > pages) pagination.current = pages
}
const handleTableChange = (pag) => {
    pagination.current = pag.current || 1
    pagination.pageSize = pag.pageSize || pagination.pageSize
}

/* ---------- Data loaders ---------- */
const load = async () => {
    loading.value = true
    try {
        const [bidRes, stepsRes, usersRes] = await Promise.all([
            getBiddingAPI(bidId),
            getBiddingStepsAPI(bidId),
            getUsers(),
        ])
        bidding.value = bidRes?.data ?? null
        users.value = Array.isArray(usersRes?.data) ? usersRes.data : []
        const list = Array.isArray(stepsRes?.data) ? stepsRes.data : []
        step.value = list.find((s) => String(s.id) === String(stepId)) || null
        await reloadTasks()
    } catch (e) {
        console.error(e)
        message.error('Không thể tải dữ liệu bước/nhiệm vụ')
    } finally {
        loading.value = false
    }
}

const reloadTasks = async () => {
    const res = await getTasksByBiddingStep(stepId, {})
    const raw = Array.isArray(res?.data) ? res.data : []
    tasks.value = toTree(raw)
    pagination.total = tasks.value.length
    ensurePageInRange()
}

/* ---------- Create / Subtask ---------- */
const openCreateTask = () => {
    createAsRoot.value = true
    openDrawer.value = true
}
const openSubtaskDrawer = (parentRow) => {
    subDrawerParent.value = {
        id: parentRow.id,
        linked_type: 'bidding',
        linked_id: bidId,
        step_id: stepId,
        step_code: step.value?.step_number ?? null,
        id_department: parentRow.id_department ?? null,
    }
    subDrawerOpen.value = true
}
const handleSubtaskCreated = async () => {
    await reloadTasks()
}

/* ---------- Delete ---------- */
const onDeleteTask = async (record) => {
    try {
        deletingId.value = record.id
        await deleteTask(record.id)
        message.success('Đã xoá công việc')
        await reloadTasks()
    } catch (e) {
        console.error(e)
        message.error('Xoá công việc thất bại')
    } finally {
        deletingId.value = null
    }
}

/* ========== APPROVAL: chọn người duyệt & GỬI DUYỆT (đơn giản) ========== */
const openSendApproval = (task) => {
    sendApprovalVisible.value = true
    sendApprovalTarget.value = task
    try {
        const ids = Array.isArray(task.approver_ids) ? task.approver_ids : JSON.parse(task.approver_ids || '[]')
        approverIdsSelected.value = ids.map(id => Number(id))
    } catch { approverIdsSelected.value = [] }
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

const confirmSendApproval = async () => {
    if (!Array.isArray(approverIdsSelected.value) || approverIdsSelected.value.length === 0) {
        message.warning('Cần chọn tối thiểu 1 người duyệt.')
        return
    }
    const uniqueIds = [...new Set(approverIdsSelected.value.map(n => Number(n)).filter(Number.isInteger))]
    if (!uniqueIds.length) {
        message.warning('Danh sách người duyệt không hợp lệ.')
        return
    }

    const target = sendApprovalTarget.value
    if (!target?.id) {
        message.error('Thiếu thông tin công việc.')
        return
    }

    try {
        loadingCreate.value = true
        await updateTask(target.id, {
            approver_ids: uniqueIds,
            approval_status: 'pending',
        })
        message.success('Đã gửi phê duyệt.')
        sendApprovalVisible.value = false
        approverIdsSelected.value = []
        sendApprovalTarget.value = null
        await reloadTasks()
    } catch (e) {
        const msg = e?.response?.data?.message || 'Thao tác thất bại.'
        message.error(msg)
    } finally {
        loadingCreate.value = false
    }
}

/* ========== APPROVAL: Duyệt/Từ chối (đơn giản) ========== */
const approveTask = async (row) => {
    if (!isMyApprover(row)) {
        message.warning('Bạn không nằm trong danh sách người duyệt.')
        return
    }
    const ok = await confirmAsync({
        title: 'Phê duyệt?',
        content: 'Xác nhận phê duyệt nhiệm vụ này?',
        okText: 'Phê duyệt'
    })
    if (!ok) return
    try {
        await approveTaskSimpleAPI(row.id, {}) // có thể gửi { comment } nếu muốn
        message.success('Đã phê duyệt.')
        await reloadTasks()
    } catch (e) {
        message.error(e?.response?.data?.message || 'Phê duyệt thất bại.')
    }
}

const rejectTask = async (row) => {
    if (!isMyApprover(row)) {
        message.warning('Bạn không nằm trong danh sách người duyệt.')
        return
    }
    const ok = await confirmAsync({
        title: 'Từ chối phê duyệt?',
        content: 'Bạn chắc chắn từ chối?',
        okButtonProps: { danger: true },
        okText: 'Từ chối'
    })
    if (!ok) return
    try {
        await rejectTaskSimpleAPI(row.id, {}) // có thể gửi { comment } nếu muốn
        message.success('Đã từ chối.')
        await reloadTasks()
    } catch (e) {
        message.error(e?.response?.data?.message || 'Từ chối thất bại.')
    }
}

onMounted(load)
</script>

<style scoped>
.task-title{display:inline-block;font-size:14px;color:#000000}
.task-title.child{position:relative;padding-left:30px;font-weight:400;font-size:12px;color:#555}
.task-title.child::before{content:'';position:absolute;left:10px;top:50%;width:14px;height:1px;background:#ccc}
.task-title.child::after{content:'';position:absolute;left:10px;top:0;bottom:50%;border-left:1px solid #ccc}
:deep(.ant-table-row-expand-icon),:deep(.ant-table-row-indent),:deep(td.ant-table-row-expand-icon-cell){display:none!important}
:deep(td.expander-col){vertical-align:middle;padding:6px 8px}
.exp-cell{display:flex;align-items:center;justify-content:center;min-height:32px}
:root{--exp-size:28px;--exp-radius:999px;--exp-border:#d9d9d9;--exp-icon:#8c8c8c;--exp-hover:#1677ff;--exp-open-border:#95de64;--exp-open-bg:#f6ffed;--exp-open-icon:#389e0d}
.exp-btn{width:var(--exp-size);height:var(--exp-size);border:1px solid var(--exp-border);border-radius:var(--exp-radius);background:#fff;display:inline-flex;align-items:center;justify-content:center;line-height:1;cursor:pointer;transition:all .18s ease;box-shadow:0 1px 0 rgba(0,0,0,.02);color:var(--exp-icon)}
.exp-btn>svg{transition:transform .18s ease,color .18s ease}
.exp-btn:hover{border-color:var(--exp-hover);box-shadow:0 0 0 3px rgba(22,119,255,.14);color:var(--exp-hover)}
.exp-btn:focus-visible{outline:none;box-shadow:0 0 0 3px rgba(22,119,255,.22)}
.exp-btn:active{transform:scale(.98)}
.exp-btn[aria-expanded="true"]{border-color:var(--exp-open-border);background:var(--exp-open-bg);color:var(--exp-open-icon);box-shadow:0 0 0 3px rgba(82,196,26,.14)}
.exp-btn[aria-expanded="true"]>svg{transform:scale(1.03)}
.exp-placeholder{width:var(--exp-size);height:var(--exp-size);border:1px dashed #ececec;border-radius:var(--exp-radius);opacity:.45}
.approval-cell{min-height:32px}
</style>
