<template>
    <a-spin :spinning="loading" size="large" tip="Đang tải dữ liệu...">
        <div class="dashboard">
            <div class="summary-cards">
                <a-card 
                    v-for="item in stats" 
                    :key="item.key" 
                    :style="{ backgroundColor: item.bg, cursor: 'pointer' }"
                    @click="handleCardClick(item)"
                    class="summary-card"
                    :data-color="item.color"
                >
                    <a-space direction="vertical" align="center">
                        <component :is="item.icon" :style="{ fontSize: '32px', color: item.color }" />
                        <div>{{ item.label }}</div>
                        <h2>{{ item.count }}</h2>
                    </a-space>
                </a-card>
            </div>

            <a-divider>Tổng quan công việc</a-divider>

            <div class="charts">
                <div class="chart-box">
                    <h4>Tỷ lệ hoàn thành theo tháng</h4>
                    <PieChart :data="tasks" />
                </div>
                <div class="chart-box">
                    <h4>Công việc theo người thực hiện</h4>
                    <BarChart :data="tasks" />
                </div>
            </div>

            <div class="tables-container">
                <div class="table-section">
                    <h4>Công việc còn 1 ngày hết hạn</h4>
                    <a-table 
                        :columns="columns" 
                        :dataSource="tasksDueIn1Day" 
                        rowKey="id" 
                        bordered 
                        size="small" 
                        :pagination="false"
                        :scroll="{ x: 1200, y: 300 }"
                        :locale="{ emptyText: 'Không có dữ liệu' }"
                        class="tiny-scroll"
                    >
                        <template #emptyText>
                            <div style="height: 250px; padding-top: 90px;">
                                Không có dữ liệu
                            </div>
                        </template>
                        <template #bodyCell="{ column, record }">
                            <template v-if="column.dataIndex === 'status'">
                                <a-tag :color="getStatusColor(record.status)">
                                    {{ getTaskStatusText(record.status) }}
                                </a-tag>
                            </template>
                            <template v-else-if="column.dataIndex === 'priority'">
                                <a-tag :color="getPriorityColor(record.priority)">
                                    {{ getPriorityText(record.priority) }}
                                </a-tag>
                            </template>
                            <template v-else-if="column.dataIndex === 'progress'">
                                <a-tooltip title="Click để thay đổi tiến trình">
                                    <div @click="openProgressModal(record)" style="cursor: pointer;">
                                        <a-progress
                                            @click="openProgressModal(record)" style="cursor: pointer;"
                                            :percent="Number(record.progress)"
                                            :stroke-color="{
                                  '0%': '#108ee9',
                                  '100%': '#87d068',
                                }"
                                            :status="record.progress >= 100 ? 'success' : 'active'"
                                            size="small"
                                            :show-info="true"
                                        />
                                    </div>
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'assignee'">
                                <a-tooltip 
                                    placement="top"
                                    :overlayStyle="{ maxWidth: '300px' }"
                                >
                                    <template #title>
                                        <div style="text-align: center; padding: 8px;">
                                            <a-avatar 
                                                :style="{ backgroundColor: getAvatarColor(record.assignee?.name) }"
                                                size="large"
                                                style="margin-bottom: 8px;"
                                            >
                                                {{ getFirstLetter(record.assignee?.name) }}
                                            </a-avatar>
                                            <div style="font-weight: bold; color: white;">{{ record.assignee?.name }}</div>
                                        </div>
                                    </template>
                                    <div style="display: flex; justify-content: center; align-items: center;">
                                        <a-avatar 
                                            :style="{ backgroundColor: getAvatarColor(record.assignee?.name) }"
                                            size="small"
                                        >
                                            {{ getFirstLetter(record.assignee?.name) }}
                                        </a-avatar>
                                    </div>
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'assigned_to_name'">
                                <a-tooltip 
                                    placement="top"
                                    :overlayStyle="{ maxWidth: '300px' }"
                                >
                                    <template #title>
                                        <div style="text-align: center; padding: 8px;">
                                            <a-avatar :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }" size="large" style="margin-bottom: 8px;">
                                                {{ getFirstLetter(record.assigned_to_name) }}
                                            </a-avatar>
                                            <div style="font-weight: bold; color: white;">{{ record.assigned_to_name }}</div>
                                        </div>
                                    </template>
                                    <div style="display: flex; justify-content: center; align-items: center;">
                                        <a-avatar 
                                            :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }"
                                            size="small"
                                        >
                                            {{ getFirstLetter(record.name) }}
                                        </a-avatar>
                                    </div>
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'start_date'">
                                {{ formatDate(record.start_date) }}
                            </template>
                            <template v-else-if="column.dataIndex === 'deadline'">
                                <a-tag v-if="record.days_overdue > 0" color="error">
                                    Quá hạn {{ record.days_overdue }} ngày
                                </a-tag>
                                <a-tag v-else-if="record.days_remaining > 0" color="green">
                                    Còn {{ record.days_remaining }} ngày
                                </a-tag>
                                <a-tag v-else-if="record.days_remaining === 0" :color="'#faad14'">
                                    Hạn chót hôm nay
                                </a-tag>
                                <a-tag v-else>
                                    —
                                </a-tag>
                            </template>
                        </template>
                    </a-table>

                </div>

                <div class="table-section">
                    <h4>Công việc cần thực hiện gấp</h4>
                    <a-table
                        :columns="columns"
                        :dataSource="urgentTasks"
                        rowKey="id"
                        bordered
                        size="small"
                        class="tiny-scroll"
                        :scroll="{ x: 1200, y: 300 }"
                        :pagination="{
                            current: urgentPage.current,
                            pageSize: urgentPage.pageSize,
                            total: urgentTasks.length,
                            showSizeChanger: true,
                            showQuickJumper: true,
                            pageSizeOptions: ['5','10','20','50','100']
                          }"
                        @change="onUrgentTableChange"
                    >

                    <template #emptyText>
                            <div style="height: 250px; padding-top: 90px;">
                                Không có dữ liệu
                            </div>
                        </template>

                        <template #bodyCell="{ column, record }">
                            <template v-if="column.dataIndex === 'title'">
                                <a-tooltip :title="record.title" placement="top" :overlayStyle="{ maxWidth: '360px' }" :overlayInnerStyle="{ whiteSpace: 'pre-line' }">
                                    <router-link :to="`/internal-tasks/${record.id}/info`" style="color:#1890ff; display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                        {{ record.title }}
                                    </router-link>
                                </a-tooltip>
                            </template>
                            <template v-if="column.dataIndex === 'status'">
                                <a-tag :color="getStatusColor(record.status)">
                                    {{ getTaskStatusText(record.status) }}
                                </a-tag>
                            </template>
                            <template v-else-if="column.dataIndex === 'progress'">
                                <a-tooltip title="Click để thay đổi tiến trình">
                                    <a-progress
                                        @click="openProgressModal(record)" style="cursor: pointer;"
                                        :percent="Number(record.progress)"
                                        :stroke-color="{
                                  '0%': '#108ee9',
                                  '100%': '#87d068',
                                }"
                                        :status="record.progress >= 100 ? 'success' : 'active'"
                                        size="small"
                                        :show-info="true"
                                    />
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'priority'">
                                <a-tag :color="getPriorityColor(record.priority)">
                                    {{ getPriorityText(record.priority) }}
                                </a-tag>
                            </template>
                            <template v-else-if="column.dataIndex === 'assignee'">
                                <a-tooltip placement="top" :overlayStyle="{ maxWidth: '300px' }">
                                    <template #title>
                                        <div style="text-align: center; padding: 8px;">
                                            <a-avatar :style="{ backgroundColor: getAvatarColor(record.assignee?.name) }" size="large" style="margin-bottom: 8px;">
                                                {{ getFirstLetter(record.assignee?.name) }}
                                            </a-avatar>
                                            <div style="font-weight: bold; color: white;">{{ record.assignee?.name }}</div>
                                        </div>
                                    </template>
                                    <div style="display: flex; justify-content: center; align-items: center;">
                                        <a-avatar :style="{ backgroundColor: getAvatarColor(record.assignee?.name) }" size="small">
                                            {{ getFirstLetter(record.assignee?.name) }}
                                        </a-avatar>
                                    </div>
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'assigned_to_name'">
                                <a-tooltip placement="top" :overlayStyle="{ maxWidth: '300px' }">
                                    <template #title>
                                        <div style="text-align: center; padding: 8px;">
                                            <a-avatar :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }" size="large" style="margin-bottom: 8px;">
                                                {{ getFirstLetter(record.assigned_to_name) }}
                                            </a-avatar>
                                            <div style="font-weight: bold; color: white;">{{ record.assigned_to_name }}</div>
                                        </div>
                                    </template>
                                    <div style="display: flex; justify-content: center; align-items: center;">
                                        <a-avatar :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }" size="small">
                                            {{ getFirstLetter(record.name) }}
                                        </a-avatar>
                                    </div>
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'start_date'">
                                {{ formatDate(record.start_date) }}
                            </template>
                            <template v-else-if="column.dataIndex === 'end_date'">
                                {{ formatDate(record.end_date) }}
                            </template>
                            <template v-else-if="column.dataIndex === 'deadline'">
                                <a-tag v-if="record.days_overdue > 0" color="error">
                                    Quá hạn {{ record.days_overdue }} ngày
                                </a-tag>
                                <a-tag v-else-if="record.days_remaining > 0" color="green">
                                    Còn {{ record.days_remaining }} ngày
                                </a-tag>
                                <a-tag v-else-if="record.days_remaining === 0" :color="'#faad14'">
                                    Hạn chót hôm nay
                                </a-tag>
                                <a-tag v-else>
                                    —
                                </a-tag>
                            </template>
                        </template>
                    </a-table>

                    <div v-if="!urgentTasks.length" class="no-tasks">
                        <p>Không có công việc gấp nào.</p>
                    </div>
                </div>
            </div>

        </div>

        <!-- Drawer for Today Tasks -->
        <a-drawer
            :title="drawerTitle"
            placement="right"
            :width="1200"
            :open="drawerVisible"
            @close="drawerVisible = false"
        >
            <div v-if="filteredTasks.length">
                <div style="margin-bottom: 16px; text-align: left;">
                    <a-pagination
                        v-model:current="currentPage"
                        v-model:pageSize="pageSize"
                        :total="filteredTasks.length"
                        :show-size-changer="true"
                        :show-quick-jumper="true"
                        size="small"
                    />
                </div>
                <a-table 
                    :columns="drawerColumns" 
                    :dataSource="paginatedTasks" 
                    rowKey="id" 
                    size="small"
                    bordered
                    :scroll="{ x: 900, y: 400 }"
                    :pagination="false"
                    :locale="{ emptyText: 'Không có dữ liệu' }"
                >
                    <template #emptyText>
                        <div style="height: 250px; padding-top: 90px;">
                            Không có dữ liệu
                        </div>
                    </template>
                    <template #bodyCell="{ column, record }">
                        <template v-if="column.dataIndex === 'status'">
                            <a-tag :color="getStatusColor(record.status)">
                                {{ getTaskStatusText(record.status) }}
                            </a-tag>
                        </template>
                        <template v-else-if="column.dataIndex === 'title'">
                            <a-tooltip :title="record.title" placement="top" :overlayStyle="{ maxWidth: '360px' }" :overlayInnerStyle="{ whiteSpace: 'pre-line' }">
                            <router-link :to="`/internal-tasks/${record.id}/info`" style="color:#1890ff; display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                {{ record.title }}
                            </router-link>
                            </a-tooltip>
                        </template>

                        <template v-else-if="column.dataIndex === 'priority'">
                            <a-tag :color="getPriorityColor(record.priority)">
                                {{ getPriorityText(record.priority) }}
                            </a-tag>
                        </template>
                        <template v-else-if="column.dataIndex === 'progress'">
                            <a-progress
                                @click="openProgressModal(record)" style="cursor: pointer;"
                                :percent="Number(record.progress)"
                                :stroke-color="{
                                  '0%': '#108ee9',
                                  '100%': '#87d068',
                                }"
                                :status="record.progress >= 100 ? 'success' : 'active'"
                                size="small"
                                :show-info="true"
                            />
                        </template>
                        <template v-else-if="column.dataIndex === 'assignee'">
                            <a-tooltip placement="top" :overlayStyle="{ maxWidth: '300px' }">
                                <template #title>
                                    <div style="text-align: center; padding: 8px;">
                                        <a-avatar :style="{ backgroundColor: getAvatarColor(record.assignee?.name) }" size="large" style="margin-bottom: 8px;">
                                            {{ getFirstLetter(record.assignee?.name) }}
                                        </a-avatar>
                                        <div style="font-weight: bold; color: white;">{{ record.assignee?.name }}</div>
                                    </div>
                                </template>
                                <div style="display: flex; justify-content: center; align-items: center;">
                                    <a-avatar :style="{ backgroundColor: getAvatarColor(record.assignee?.name) }" size="small">
                                        {{ getFirstLetter(record.assignee?.name) }}
                                    </a-avatar>
                                </div>
                            </a-tooltip>
                        </template>
                                <template v-else-if="column.dataIndex === 'create_by'">
                                <a-tooltip placement="top" :overlayStyle="{ maxWidth: '400px', wordWrap: 'break-word', whiteSpace: 'normal' }">
                                    <template #title>
                                        <div style="text-align: center; padding: 12px; min-width: 200px;">
                                            <a-avatar :style="{ backgroundColor: getAvatarColor(getUserById(record.create_by)) }" size="large" style="margin-bottom: 12px;">
                                                {{ getFirstLetter(getUserById(record.create_by)) }}
                                            </a-avatar>
                                            <div style="font-weight: bold; color: white; word-wrap: break-word; white-space: normal; line-height: 1.4;">{{ getUserById(record.create_by) }}</div>
                                        </div>
                                    </template>
                                    <div style="display: flex; justify-content: center; align-items: center;">
                                        <a-avatar :style="{ backgroundColor: getAvatarColor(getUserById(record.create_by)) }" size="small">
                                            {{ getFirstLetter(getUserById(record.create_by)) }}
                                        </a-avatar>
                                    </div>
                                </a-tooltip>
                            </template>
                        <template v-else-if="column.dataIndex === 'start_date'">
                            {{ formatDate(record.start_date) }}
                        </template>
                        <template v-else-if="column.dataIndex === 'deadline'">
                            <a-tag v-if="record.days_overdue > 0" color="error">
                                Quá hạn {{ record.days_overdue }} ngày
                            </a-tag>
                            <a-tag v-else-if="record.days_remaining > 0" color="green">
                                Còn {{ record.days_remaining }} ngày
                            </a-tag>
                            <a-tag v-else-if="record.days_remaining === 0" :color="'#faad14'">
                                Hạn chót hôm nay
                            </a-tag>
                            <a-tag v-else>
                                —
                            </a-tag>
                        </template>
                    </template>
                </a-table>
            </div>
            <div v-else class="no-tasks-drawer">
                <a-empty :description="emptyMessage" />
            </div>
        </a-drawer>

        <!-- Progress Change Modal -->
        <a-modal
            v-model:open="progressModalVisible"
            title="Thay đổi tiến trình"
            okText="Lưu"
            cancelText="Hủy"
            @ok="updateProgress"
            @cancel="progressModalVisible = false"
            :confirm-loading="progressUpdating"
        >
            <div style="text-align: center; padding: 20px;">
                <h4>{{ selectedTask?.title }}</h4>
                <div style="margin: 20px 0;">
                    <a-slider
                        v-model:value="newProgressValue"
                        :min="0"
                        :max="100"
                        :step="5"
                        :marks="{ 0: '0%', 25: '25%', 50: '50%', 75: '75%', 100: '100%' }"
                        style="width: 100%;"
                    />
                </div>
                <div style="margin-top: 20px;">
                    <a-progress 
                        :percent="newProgressValue" 
                        size="large"
                        :format="(percent) => `${percent}%`"
                        :stroke-width="30"
                    />
                </div>
            </div>
        </a-modal>
    </a-spin>
</template>

<script setup>
import { ref, onMounted, watch, computed, reactive } from 'vue'
import {
    ClockCircleOutlined,
    FlagOutlined,
    FireOutlined,
    CheckCircleOutlined,
    StopOutlined,
    FieldTimeOutlined,   // ⟵ tuần
    CalendarOutlined     // ⟵ tháng
} from '@ant-design/icons-vue'
import { formatDate } from '@/utils/formUtils';
import PieChart from './PieChart.vue'
import BarChart from './BarChart.vue'
import { getTasks, updateTask } from '@/api/task'
import { getUsers } from '@/api/user'



const props = defineProps({
    departmentId: [String, Number]
})

const loading = ref(false)
const tasks = ref([])
const stats = ref([])
const drawerVisible = ref(false)
const filteredTasks = ref([])
const drawerTitle = ref('')
const emptyMessage = ref('')
const users = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
let progressModalVisible = ref(false)
const progressUpdating = ref(false)
const selectedTask = ref(null)
const newProgressValue = ref(0)

const paginatedTasks = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value
    const end = start + pageSize.value
    console.log('filteredTasks', filteredTasks)
    return filteredTasks.value.slice(start, end)
})

const tasksDueIn1Day = computed(() => {
    const tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    const tomorrowStr = tomorrow.toISOString().slice(0, 10)
    return tasks.value.filter(task => task.end_date === tomorrowStr)
})

// const urgentTasks = computed(() => {
//     return tasks.value.filter(task => task.priority === 'high')
// })

const urgentPage = reactive({
    current: 1,
    pageSize: 10,
})

const onUrgentTableChange = (pagination/*, filters, sorter, extra*/) => {
    urgentPage.current = pagination.current
    urgentPage.pageSize = pagination.pageSize
}


// weight cho ưu tiên
const PRIORITY_WEIGHT = { high: 3, normal: 2, low: 1 }

// Tất cả task, sắp xếp theo ưu tiên giảm dần
const urgentTasks = computed(() => {
    return [...tasks.value].sort((a, b) => {
        const wa = PRIORITY_WEIGHT[a.priority] ?? 0
        const wb = PRIORITY_WEIGHT[b.priority] ?? 0
        if (wa !== wb) return wb - wa // desc: high > normal > low

        // tie-breaker (tuỳ chọn): hạn sớm hơn đứng trước
        const da = a.end_date ? new Date(a.end_date) : null
        const db = b.end_date ? new Date(b.end_date) : null
        if (da && db) return da - db
        if (da && !db) return -1
        if (!da && db) return 1
        return 0
    })
})

// Khi danh sách thay đổi, đảm bảo current không vượt quá tổng trang
watch(() => urgentTasks.value.length, (len) => {
    const totalPages = Math.ceil(len / urgentPage.pageSize) || 1
    if (urgentPage.current > totalPages) urgentPage.current = totalPages
})


const columns = [
    { title: 'Tên công việc', dataIndex: 'title', key: 'title', width: 200, ellipsis: true },
    { title: 'Người thực hiện', dataIndex: 'assignee', key: 'assignee' },
    { title: 'Tiến trình', dataIndex: 'progress', key: 'progress', width: 120, align: 'center' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority' },
    {
        title: 'Bắt đầu',
        dataIndex: 'start_date',
        key: 'start_date',
        width: 120,
        align: 'center',
        customRender: ({ text }) => formatDate(text),
        sorter: (a, b) => new Date(a.start_date) - new Date(b.start_date),
    },
    {
        title: 'Kết thúc',
        // nếu backend trả end_date (như ví dụ của bạn) thì dùng end_date
        dataIndex: 'end_date', // hoặc đổi thành 'deadline' nếu bạn vẫn lưu theo tên đó
        key: 'end_date',
        width: 120,
        align: 'center',
        customRender: ({ text }) => formatDate(text),
        sorter: (a, b) => new Date(a.end_date) - new Date(b.end_date),
    },
    { title: 'Hạn', dataIndex: 'deadline', key: 'deadline' }
]

const drawerColumns = [
    { title: 'Tên công việc', dataIndex: 'title', key: 'title', width: 200, ellipsis: true },
    { title: 'Người thực hiện', dataIndex: 'assignee', key: 'assignee', width: 80, align: 'center' },
    { title: 'Tiến trình', dataIndex: 'progress', key: 'progress', width: 120, align: 'center' },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority', width: 100, align: 'center' },

    {
        title: 'Bắt đầu',
        dataIndex: 'start_date',
        key: 'start_date',
        width: 120,
        align: 'center',
        customRender: ({ text }) => formatDate(text),
        sorter: (a, b) => new Date(a.start_date) - new Date(b.start_date),
    },
    {
        title: 'Kết thúc',
        // nếu backend trả end_date (như ví dụ của bạn) thì dùng end_date
        dataIndex: 'end_date', // hoặc đổi thành 'deadline' nếu bạn vẫn lưu theo tên đó
        key: 'end_date',
        width: 120,
        align: 'center',
        customRender: ({ text }) => formatDate(text),
        sorter: (a, b) => new Date(a.end_date) - new Date(b.end_date),
    },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 120, align: 'center' },
    { title: 'Hạn', dataIndex: 'deadline', key: 'deadline', width: 120, align: 'center' }
]

const loadTasks = async () => {
    if (!props.departmentId) return
    loading.value = true
    try {
        // Load tasks and users in parallel for faster performance
        const [tasksRes, usersRes] = await Promise.all([
            getTasks({ id_department: props.departmentId, per_page: 100 }),
            getUsers()
        ])

        tasks.value = tasksRes.data.data || []
        users.value = usersRes.data || []

        // Không cần map assigned_to_name nữa vì đã sử dụng create_by
        tasks.value = tasks.value

        updateStats(tasks.value)
    } catch (e) {
        console.error(e)
        tasks.value = []
        users.value = []
    } finally {
        loading.value = false
    }
}

const getUserName = (userId) => {    
    if (!userId || !users.value.length) return 'N/A'
    const user = users.value.find(u => u.id == userId)
    return user ? user.name : 'N/A'
}

const updateStats = (data) => {
    const today = new Date()
    const todayStr = today.toISOString().slice(0, 10)

    // helpers
    const toDate = (s) => {
        if (!s) return null
        const [y, m, d] = s.split('-').map(Number)
        return new Date(y, m - 1, d)
    }
    // tuần: Mon..Sun
    const monday = new Date(today)
    monday.setDate(today.getDate() - ((today.getDay() + 6) % 7))
    monday.setHours(0, 0, 0, 0)
    const sunday = new Date(monday)
    sunday.setDate(monday.getDate() + 6)
    sunday.setHours(23, 59, 59, 999)

    // tháng hiện tại
    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1)
    const monthEnd   = new Date(today.getFullYear(), today.getMonth() + 1, 0)
    monthStart.setHours(0,0,0,0)
    monthEnd.setHours(23,59,59,999)

    const isInRange = (d, start, end) => d && d >= start && d <= end

    const weekCount = data.filter(t => {
        const d = toDate(t.end_date)
        return isInRange(d, monday, sunday)
    }).length

    const monthCount = data.filter(t => {
        const d = toDate(t.end_date)
        return isInRange(d, monthStart, monthEnd)
    }).length

    stats.value = [
        {
            key: 'today',
            label: 'Công việc cần xử lý hôm nay',
            count: data.filter(t => t.end_date === todayStr).length,
            icon: FlagOutlined,
            color: '#faad14',
            bg: '#fffbe6'
        },
        {
            key: 'week',
            label: 'Công việc theo tuần',
            count: weekCount,
            icon: FieldTimeOutlined,
            color: '#1d39c4',
            bg: '#f0f5ff'
        },
        {
            key: 'month',
            label: 'Công việc theo tháng',
            count: monthCount,
            icon: CalendarOutlined,
            color: '#13c2c2',
            bg: '#e6fffb'
        },
        {
            key: 'urgent',
            label: 'Công việc gấp cần xử lý',
            count: data.filter(t => t.priority === 'high').length,
            icon: FireOutlined,
            color: '#722ed1',
            bg: '#f9f0ff'
        },
        {
            key: 'done',
            label: 'Công việc hoàn thành',
            count: data.filter(t => t.status === 'done').length,
            icon: CheckCircleOutlined,
            color: '#52c41a',
            bg: '#f6ffed'
        },
        {
            key: 'overdue',
            label: 'Công việc quá hạn',
            count: data.filter(t => t.status === 'overdue').length,
            icon: StopOutlined,
            color: '#ff4d4f',
            bg: '#fff1f0'
        }
    ]
}

// Helpers tính khoảng ngày
const toDate = (s) => {
    if (!s) return null
    const [y, m, d] = s.split('-').map(Number)
    return new Date(y, m - 1, d)
}
const isInRange = (d, start, end) => d && d >= start && d <= end

const getThisWeekRange = () => {
    const today = new Date()
    const monday = new Date(today)
    monday.setDate(today.getDate() - ((today.getDay() + 6) % 7))
    monday.setHours(0,0,0,0)
    const sunday = new Date(monday)
    sunday.setDate(monday.getDate() + 6)
    sunday.setHours(23,59,59,999)
    return { start: monday, end: sunday }
}

const getThisMonthRange = () => {
    const today = new Date()
    const start = new Date(today.getFullYear(), today.getMonth(), 1)
    const end   = new Date(today.getFullYear(), today.getMonth() + 1, 0)
    start.setHours(0,0,0,0)
    end.setHours(23,59,59,999)
    return { start, end }
}


const getTaskStatusText = (status) => {
    switch (status) {
        case 'todo': return 'Chưa làm'
        case 'doing': return 'Đang triển khai'
        case 'done': return 'Đã hoàn thành'
        case 'overdue': return 'Quá hạn'
        default: return 'Không xác định'
    }
}
const getStatusColor = (status) => {
    switch (status) {
        case 'todo': return 'default'
        case 'doing': return 'processing'
        case 'done': return 'success'
        case 'overdue': return 'error'
        default: return 'default'
    }
}
const getPriorityText = (priority) => {
    switch (priority) {
        case 'high': return 'Gấp'
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

const filterStrategies = {
    today: () => {
        const today = new Date().toISOString().slice(0, 10)
        return {
            title: 'Công việc cần xử lý hôm nay',
            message: 'Không có nhiệm vụ nào hôm nay.',
            data: tasks.value.filter(t => t.end_date === today),
        }
    },
    week: () => {
        const { start, end } = getThisWeekRange()
        return {
            title: 'Công việc trong tuần này',
            message: 'Không có nhiệm vụ nào trong tuần này.',
            data: tasks.value.filter(t => isInRange(toDate(t.end_date), start, end)),
        }
    },
    month: () => {
        const { start, end } = getThisMonthRange()
        return {
            title: 'Công việc trong tháng này',
            message: 'Không có nhiệm vụ nào trong tháng này.',
            data: tasks.value.filter(t => isInRange(toDate(t.end_date), start, end)),
        }
    },
    urgent: () => ({
        title: 'Công việc gấp cần xử lý',
        message: 'Không có nhiệm vụ GẤP nào.',
        data: tasks.value.filter(t => t.priority === 'high'),
    }),
    done: () => ({
        title: 'Công việc hoàn thành',
        message: 'Không có nhiệm vụ hoàn thành nào.',
        data: tasks.value.filter(t => t.status === 'done'),
    }),
    overdue: () => ({
        title: 'Công việc quá hạn',
        message: 'Không có nhiệm vụ quá hạn nào.',
        data: tasks.value.filter(t => t.status === 'overdue'),
    }),
}


const handleCardClick = (item) => {
    const strategy = filterStrategies[item.key]
    if (strategy) {
        const { title, message, data } = strategy()
        filteredTasks.value = data
        drawerTitle.value = title
        emptyMessage.value = message
        currentPage.value = 1
        drawerVisible.value = true
    }
}


const openProgressModal = (task) => {
    selectedTask.value = task;
    newProgressValue.value = Number(task.progress) || 0; // ✅ ép kiểu về số
    progressModalVisible.value = true;
};


const updateProgress = async () => {
    if (!selectedTask.value) return;
    progressUpdating.value = true;
    try {
        await updateTask(selectedTask.value.id, { progress: newProgressValue.value });
        
        // Cập nhật trực tiếp trong bảng thay vì reload
        const taskToUpdate = tasks.value.find(t => t.id === selectedTask.value.id);
        if (taskToUpdate) {
            taskToUpdate.progress = newProgressValue.value;
        }
        
        // Cập nhật trong filteredTasks nếu có
        const filteredTaskToUpdate = filteredTasks.value.find(t => t.id === selectedTask.value.id);
        if (filteredTaskToUpdate) {
            filteredTaskToUpdate.progress = newProgressValue.value;
        }
        
        // Close modal and reset values
        progressModalVisible.value = false;
        selectedTask.value = null;
        newProgressValue.value = 0;
    } catch (e) {
        console.error(e);
        // Optionally show an error message to the user
    } finally {
        progressUpdating.value = false;
    }
};

// Sử dụng function có sẵn getUserName
const getUserById = getUserName;

onMounted(() => {
    loadTasks()
})
watch(() => props.departmentId, loadTasks)
watch(() => filteredTasks.value, () => {
    currentPage.value = 1
})
</script>


<style>
.charts {
    display: flex;
    flex-wrap: wrap;
    gap: 24px;
    margin-top: 32px;
}
.chart-box {
    flex: 1;
    min-width: 400px;
    background: #fff;
    padding: 16px;
    border-radius: 8px;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

.tables-container {
    display: flex;
    flex-wrap: wrap;
    gap: 24px;
    margin-top: 32px;
}

.table-section {
    flex: 1;
    min-width: 600px;
    height: 400px;
    background: #fff;
    padding: 16px;
    border-radius: 8px;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

.table-section h4 {
    margin-bottom: 16px;
    color: #1890ff;
    font-weight: 600;
}

.table-section .ant-table-wrapper {
    height: calc(100% - 60px);
    min-height: 300px;
}

.table-section .ant-table {
    height: 100%;
}

.table-section .ant-table-tbody {
    height: calc(100% - 40px);
    min-height: 260px;
}

.table-section .ant-table-tbody > tr {
    height: 40px;
}
/* Firefox */
.tiny-scroll .ant-table-body,
.tiny-scroll .ant-table-content,
.tiny-scroll .ant-table-header {
    scrollbar-width: thin;                         /* mảnh hơn */
    scrollbar-color: rgba(0,0,0,.35) transparent;  /* màu tay kéo */
}

/* Chrome/Edge/Safari */
.tiny-scroll .ant-table-body::-webkit-scrollbar,
.tiny-scroll .ant-table-content::-webkit-scrollbar,
.tiny-scroll .ant-table-header::-webkit-scrollbar {
    width: 6px;   /* dọc */
    height: 6px;  /* ngang – chỉnh xuống 4px nếu muốn nhỏ nữa */
}
.tiny-scroll .ant-table-body::-webkit-scrollbar-thumb,
.tiny-scroll .ant-table-content::-webkit-scrollbar-thumb,
.tiny-scroll .ant-table-header::-webkit-scrollbar-thumb {
    background: rgba(0,0,0,.35);
    border-radius: 6px;
}
.tiny-scroll .ant-table-body::-webkit-scrollbar-track,
.tiny-scroll .ant-table-content::-webkit-scrollbar-track,
.tiny-scroll .ant-table-header::-webkit-scrollbar-track {
    background: transparent;
}


@media (max-width: 1200px) {
    .table-section {
        min-width: 100%;
        flex: none;
        height: 350px;
    }
    
    .table-section .ant-table-wrapper {
        min-height: 250px;
    }
    
    .table-section .ant-table-tbody {
        min-height: 210px;
    }
}
</style>
<style scoped>
.dashboard {
    padding: 16px;
}
.summary-cards {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    margin-bottom: 24px;
}
.summary-cards .ant-card {
    flex: 1;
    min-width: 200px;
    text-align: center;
    transition: all 0.3s ease;
}

.summary-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}


.no-tasks {
    text-align: center;
    padding: 32px;
    font-style: italic;
}

.no-tasks-drawer {
    text-align: center;
    padding: 40px 0;
}
</style>
