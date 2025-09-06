<!-- src/views/BiddingStepTasks.vue -->
<template>
    <div>
        <a-card bordered>
            <a-page-header
                :title="`Bước ${step?.step_number || stepId}: ${step?.title || ''}`"
                sub-title="Danh sách nhiệm vụ"
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
                    v-else
                    :columns="treeColumns"
                    :dataSource="tasks"
                    rowKey="id"
                    :pagination="false"
                    :scroll="{ x: 'max-content' }"
                >
                    <template #bodyCell="{ column, record, index }">
                        <template v-if="column.key === 'index'">{{ index + 1 }}</template>

                        <template v-else-if="column.key === 'add'">x</template>

                        <template v-else-if="column.dataIndex === 'title'">
                            <router-link
                                :to="{ name: 'bidding-task-info', params: { id: record.id } }"
                                class="task-title-cell"
                            >
                        <span class="task-title" :class="{ child: record.parent_id }">
                          {{ truncateText(record.title, 25) }}
                        </span>
                            </router-link>
                        </template>

                        <template v-else-if="column.dataIndex === 'assigned_to'">
                            {{ getAssignedUserName(record.assigned_to) }}
                        </template>

                        <template v-else-if="column.dataIndex === 'progress'">
                            {{ Number(record.progress ?? 0) }}%
                        </template>

                        <template v-else-if="column.dataIndex === 'priority'">
                            <a-tag :color="getPriorityColor(record.priority)">{{ getPriorityText(record.priority) }}</a-tag>
                        </template>

                        <template v-else-if="column.dataIndex === 'start_date'">{{ fmtDate(record.start_date) }}</template>
                        <template v-else-if="column.dataIndex === 'end_date'">{{ fmtDate(record.end_date) }}</template>

                        <template v-else-if="column.dataIndex === 'status'">
                            <a-tag :color="getTaskStatusColor(record.status)">{{ getTaskStatusText(record.status) }}</a-tag>
                        </template>

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
            </a-spin>
        </a-card>

        <DrawerCreateTask
            v-model:open-drawer="openDrawer"
            :list-user="users"
            type="bidding"
            @submitForm="reloadTasks"
        />
        <DrawerCreateSubtask
            :open="subDrawerOpen"
            :parentTask="subDrawerParent"
            :listUser="users"
            @update:open="v => subDrawerOpen = v"
            @created="handleSubtaskCreated"
        />
    </div>
</template>


<script setup>
import {ref, onMounted, computed} from 'vue'
import dayjs from 'dayjs'
import {useRoute, useRouter} from 'vue-router'
import {message} from 'ant-design-vue'
import {PlusOutlined} from '@ant-design/icons-vue'

import {getBiddingAPI, getBiddingStepsAPI} from '@/api/bidding'
import {getTasksByBiddingStep} from '@/api/task'
import {getUsers} from '@/api/user'
import DrawerCreateTask from '@/components/common/DrawerCreateTask.vue'
import DrawerCreateSubtask from '@/components/common/DrawerCreateSubtask.vue'

// ===== props từ router
const route = useRoute()
const router = useRouter()
const bidId = Number(route.params.bidId)
const stepId = Number(route.params.stepId)

// ===== state
const step = ref(null)
const bidding = ref(null)
const tasks = ref([])
const users = ref([])
const loading = ref(false)

const openDrawer = ref(false)
const subDrawerOpen = ref(false)
const subDrawerParent = ref(null)

// ===== helpers tối giản (tái dùng logic của bạn)
const fmtDate = v => (v ? dayjs(v).format('DD/MM/YYYY') : '—')
const getPriorityText = p => ({high:'Cao',normal:'Bình thường',low:'Thấp'}[String(p)] ?? 'Không xác định')
const getPriorityColor = p => ({high:'red',normal:'orange',low:'blue'}[String(p)] ?? 'default')
const TASK_STATUS_TEXT = { todo:'Chưa bắt đầu', doing:'Đang làm', done:'Hoàn thành', overdue:'Trễ hạn' }
const TASK_STATUS_COLOR = { todo:'default', doing:'blue', done:'green', overdue:'red' }
const getTaskStatusText = s => TASK_STATUS_TEXT[String(s)] || 'Không rõ'
const getTaskStatusColor = s => TASK_STATUS_COLOR[String(s)] || 'default'

const APPROVAL_TEXT = { approved:'Đã duyệt', pending:'Chờ duyệt', rejected:'Từ chối' }
const APPROVAL_COLOR = { approved:'green', pending:'blue', rejected:'red', default:'gray' }
const getApprovalStatusText = s => APPROVAL_TEXT[String(s)] ?? 'Không rõ'
const getApprovalStatusColor = s => APPROVAL_COLOR[String(s)] ?? 'gray'

const usersById = computed(() => {
    const m = {}
    for (const u of users.value) m[String(u.id)] = u
    return m
})
const getAssignedUserName = uid => usersById.value[String(uid)]?.name || (uid ? `Người dùng #${uid}` : 'Không xác định')

// hạn (tái dùng nhanh)
const deadlineInfo = (endDate) => {
    if (!endDate) return { type:'none', days:0 }
    const diff = dayjs(endDate).startOf('day').diff(dayjs().startOf('day'),'day')
    if (diff < 0) return { type:'overdue', days: Math.abs(diff) }
    if (diff === 0) return { type:'today', days: 0 }
    return { type:'remaining', days: diff }
}
const deadlineText  = (b) => {
    const d = deadlineInfo(b?.end_date ?? b?.endDate ?? null)
    if (d.type === 'overdue') return `Quá hạn ${d.days} ngày`
    if (d.type === 'today') return 'Đến hạn hôm nay'
    if (d.type === 'remaining') return `Còn ${d.days} ngày`
    return '—'
}
const deadlineColor = (b) => {
    const d = deadlineInfo(b?.end_date ?? b?.endDate ?? null)
    return d.type === 'overdue' ? 'red' : d.type === 'today' ? 'orange' : d.type === 'remaining' ? 'green' : 'default'
}

// step status hiển thị
const STEP_STATUS_TEXT = { '0':'Chưa bắt đầu','1':'Đang xử lý','2':'Đã hoàn thành','3':'Bỏ qua' }
const STEP_STATUS_COLOR = { '0':'default','1':'blue','2':'green','3':'orange' }
const statusText = s => STEP_STATUS_TEXT[String(s)] || 'Không rõ'
const getStepStatusColor = s => STEP_STATUS_COLOR[String(s)] || 'default'

// cột bảng (tương thích với template cũ)
const treeColumns = [
    { title:'STT', key:'index', width:60, align:'center' },
    {
        title:'Tên công việc',
        dataIndex:'title',
        key:'title',
        width:240,
        ellipsis: { showTitle: false }
    },
    { title:'Việc con', key:'add', width:120, align:'center' },
    { title:'Người thực hiện', dataIndex:'assigned_to', key:'assigned_to', width:160 },
    { title:'Tiến trình', dataIndex:'progress', key:'progress', width:140, align:'center' },
    { title:'Ưu tiên', dataIndex:'priority', key:'priority', width:120, align:'center' },
    { title:'Bắt đầu', dataIndex:'start_date', key:'start_date', width:120, align:'center' },
    { title:'Kết thúc', dataIndex:'end_date', key:'end_date', width:120, align:'center' },
    { title:'Trạng thái', dataIndex:'status', key:'status', width:140, align:'center' },
    { title:'Hạn', dataIndex:'deadline', key:'deadline', width:160, align:'center' },
    { title:'Duyệt', dataIndex:'approval_status', key:'approval_status', width:160, align:'center' },
]

const truncateText = (text, length = 30) => {
    if (!text) return '';
    return text.length > length ? text.slice(0, length) + '...' : text;
}

// fetch
const load = async () => {
    try {
        loading.value = true
        const [bidRes, stepsRes, usersRes] = await Promise.all([
            getBiddingAPI(bidId),
            getBiddingStepsAPI(bidId),
            getUsers(),
        ])
        bidding.value = bidRes?.data ?? null
        users.value = Array.isArray(usersRes?.data) ? usersRes.data : []
        const list = Array.isArray(stepsRes?.data) ? stepsRes.data : []
        step.value = list.find(s => String(s.id) === String(stepId)) || null
        await reloadTasks()
    } catch (e) {
        console.error(e)
        message.error('Không thể tải dữ liệu bước/nhiệm vụ')
    } finally {
        loading.value = false
    }
}

const reloadTasks = async () => {
    const filter = {}
    // nếu bạn muốn lọc theo role, tái dùng logic cũ:
    // const u = useUserStore().currentUser || {}
    // if (String(u.role_id) === '3') filter.assigned_to = u.id
    // else if (String(u.role_id) === '2') filter.id_department = u.department_id
    const res = await getTasksByBiddingStep(stepId, filter)
    tasks.value = Array.isArray(res?.data) ? res.data : []
}

// thêm subtask
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

const handleSubtaskCreated = (newTask) => {
    const list = tasks.value.slice()
    const parent = list.find(x => Number(x.id) === Number(newTask.parent_id))
    if (parent) {
        parent.children = parent.children || []
        parent.children.push(newTask)
    } else {
        list.push(newTask)
    }
    tasks.value = list
}

const openCreateTask = () => {
    openDrawer.value = true
}

onMounted(load)
</script>

<style scoped>
.task-title { display:inline-block; font-weight:500; font-size:13px; color:#1890ff; }
.task-title.child { position:relative; padding-left:30px; font-weight:normal; font-size:12px; color:#555; }
.task-title.child::before { content:''; position:absolute; left:10px; top:50%; width:14px; height:1px; background:#ccc; }
.task-title.child::after { content:''; position:absolute; left:10px; top:0; bottom:50%; border-left:1px solid #ccc; }
</style>
