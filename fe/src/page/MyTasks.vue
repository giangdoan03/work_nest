<template>
    <a-card bordered>
        <a-spin :spinning="loading" size="large" tip="Đang tải dữ liệu...">
            <div class="dashboard">
                <a-page-header title="Nhiệm vụ của tôi" style="padding-left: 0; padding-top: 0" />

                <!-- Summary Cards -->
                <div class="summary-cards">
                    <a-card
                        v-for="item in stats"
                        :key="item.key"
                        :style="{ backgroundColor: item.bg }"
                        @click="openDrawer(item.key, item.label)"
                    >
                        <a-space direction="vertical" align="center">
                            <component :is="item.icon" :style="{ fontSize: '32px', color: item.color }" />
                            <div>{{ item.label }}</div>
                            <h2 class="number" :style="{ color: item.color }">{{ item.count }}</h2>
                        </a-space>
                    </a-card>
                </div>

                <a-divider>Tổng quan công việc</a-divider>

                <!-- Charts -->
                <div class="charts">
                    <div class="chart-box">
                        <h4 class="title_chart">Tỉ lệ công việc</h4>
                        <PieChart :data="tasks" />
                    </div>
                    <div class="chart-box">
                        <h4 class="title_chart">Công việc theo tháng</h4>
                        <BarByMonth :data="tasks" />
                    </div>
                </div>

                <a-divider>Danh sách công việc</a-divider>

                <!-- Task Table -->
                <a-table
                    :columns="columnsPersonal"
                    :dataSource="tasks"
                    rowKey="id"
                    bordered
                    size="small"
                >
                    <template #bodyCell="{ column, record, index}">
                        <template v-if="column.key === 'stt'">
                            {{ index + 1 }}
                        </template>
                        <template v-if="column.dataIndex === 'title'">
                            <router-link :to="`/non-workflow/${record.id}/info`" style="color:#1890ff;">
                                {{ record.title }}
                            </router-link>
                        </template>
                        <template v-else-if="column.dataIndex === 'status'">
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
                            <a-tooltip :title="record.assigned_to_name">
                                <a-avatar
                                    :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }"
                                    size="small"
                                >
                                    {{ getFirstLetter(record.assigned_to_name) }}
                                </a-avatar>
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

                <div v-if="!tasks.length" class="no-tasks">
                    <p>Không có nhiệm vụ nào.</p>
                </div>
            </div>

            <!-- Drawer for Today Tasks -->
            <a-drawer
                :title="drawerTitle"
                placement="right"
                :width="1000"
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
                        <template #bodyCell="{ column, record, index }">
                            <template v-if="column.dataIndex === 'index'">
                                {{ (currentPage - 1) * pageSize + index + 1 }}
                            </template>
                            <template v-if="column.dataIndex === 'status'">
                                <a-tag :color="getStatusColor(record.status)">
                                    {{ getTaskStatusText(record.status) }}
                                </a-tag>
                            </template>
                            <template v-else-if="column.dataIndex === 'title'">
                                <a-tooltip :title="record.title">
                                    <div style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap;">
                                        <router-link :to="`/non-workflow/${record.id}/info`" style="color: #1890ff;">
                                            {{ record.title }}
                                        </router-link>
                                    </div>
                                </a-tooltip>
                            </template>

                            <template v-else-if="column.dataIndex === 'priority'">
                                <a-tag :color="getPriorityColor(record.priority)">
                                    {{ getPriorityText(record.priority) }}
                                </a-tag>
                            </template>
                            <template v-else-if="column.dataIndex === 'progress'">
                                <a-progress @click="openProgressModal(record)" style="cursor: pointer;" :percent="Number(record.progress)"
                                            :stroke-color="{
                                  '0%': '#108ee9',
                                  '100%': '#87d068',
                                }"
                                            :status="record.progress >= 100 ? 'success' : 'active'"
                                            size="small"
                                            :show-info="true"
                                />
                            </template>
                            <template v-else-if="column.dataIndex === 'assigned_to_name'">
                                <a-tooltip :title="record.assigned_to_name">
                                    <a-avatar
                                        :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }"
                                        size="small"
                                    >
                                        {{ getFirstLetter(record.assigned_to_name) }}
                                    </a-avatar>
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'assignee'">
                                <a-tooltip placement="top" :title="record.assignee">
                                    <a-avatar
                                        :style="{ backgroundColor: getAvatarColor(record.assignee) }"
                                        size="small"
                                    >
                                        {{ getFirstLetter(record.assigned_to_name) }}
                                    </a-avatar>
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
    </a-card>
</template>
<script setup>
import { ref, onMounted, computed } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import { getMyTasksAPI } from '@/api/task'
import PieChart from '@/components/PieChart.vue'
import BarByMonth from '@/components/BarByMonth.vue'

import {
    CheckOutlined,
    ClockCircleOutlined,
    FlagOutlined,
    FileTextOutlined,
    ProjectOutlined,
    StopOutlined, FieldTimeOutlined, CalendarOutlined, FireOutlined, CheckCircleOutlined
} from '@ant-design/icons-vue'
import {updateTask} from "../api/task";

const tasks = ref([])
const loading = ref(false)

const fetchTasks = async () => {
    try {
        loading.value = true
        const res = await getMyTasksAPI()
        tasks.value = res.data.data || []
    } catch (e) {
        message.error('Không thể tải danh sách nhiệm vụ')
    } finally {
        loading.value = false
    }
}

onMounted(fetchTasks)

const today = new Date().toISOString().slice(0, 10)

const stats = computed(() => [
    {
        key: 'today',
        label: 'Công việc xử lý hôm nay',
        count: tasks.value.filter(t => t.end_date === today).length,
        icon: FlagOutlined,
        color: '#faad14',
        bg: '#fffbe6'
    },
    {
        key: 'week',
        label: 'Việc theo tuần',
        count: tasks.value.filter(t => dayjs(t.end_date).isSame(dayjs(), 'week')).length,
        icon: FieldTimeOutlined,
        color: '#722ed1',
        bg: '#f9f0ff'
    },
    {
        key: 'month',
        label: 'Công việc theo tháng',
        count: tasks.value.filter(t => dayjs(t.end_date).isSame(dayjs(), 'month')).length,
        icon: CalendarOutlined,
        color: '#40a9ff',
        bg: '#e6f7ff'
    },
    {
        key: 'urgent',
        label: 'Công việc gấp cần xử lý',
        count: tasks.value.filter(t =>
            t.priority === 'high' && t.status !== 'done'
        ).length,
        icon: FireOutlined,
        color: '#ff4d4f',
        bg: '#fff1f0'
    },
    {
        key: 'done',
        label: 'Công việc hoàn thành',
        count: tasks.value.filter(t => t.status === 'done').length,
        icon: CheckCircleOutlined,
        color: '#52c41a',
        bg: '#f6ffed'
    },
    {
        key: 'overdue',
        label: 'Công việc quá hạn',
        count: tasks.value.filter(t => t.status === 'overdue').length,
        icon: StopOutlined,
        color: '#ff4d4f',
        bg: '#fff1f0'
    },
])



const drawerVisible = ref(false)
const drawerTitle = ref('')
const drawerFilterKey = ref('')
const currentPage = ref(1)
const pageSize = ref(5)

const progressModalVisible = ref(false)
const selectedTask = ref(null)
const newProgressValue = ref(0)
const progressUpdating = ref(false)

const openDrawer = (key, title) => {
    drawerFilterKey.value = key
    drawerTitle.value = title
    currentPage.value = 1
    drawerVisible.value = true
}

const drawerColumns = [
    {
        title: 'STT',
        dataIndex: 'index',
        key: 'index',
        width: 60,
        align: 'center'
    },
    {
        title: 'Tiêu đề',
        dataIndex: 'title',
        key: 'title',
        align: 'center',
    },
    {
        title: 'Trạng thái',
        dataIndex: 'status',
        key: 'status',
        align: 'center',
    },
    {
        title: 'Mức độ ưu tiên',
        dataIndex: 'priority',
        key: 'priority',
        align: 'center',
    },
    {
        title: 'Tiến độ',
        dataIndex: 'progress',
        key: 'progress',
        align: 'center',
    },
    {
        title: 'Người thực hiện',
        dataIndex: 'assigned_to_name',
        key: 'assigned_to_name',
        align: 'center',
    },
    {
        title: 'Ngày bắt đầu',
        dataIndex: 'start_date',
        key: 'start_date',
        align: 'center',
    },
    {
        title: 'Hạn',
        dataIndex: 'deadline',
        key: 'deadline',
        align: 'center',
    },
]

const columnsPersonal = [
    {
        title: 'STT',
        key: 'index',
        width: 60,
        align: 'center',
        customRender: ({ index }) =>
            (currentPage.value - 1) * pageSize.value + index + 1,
    },
    { title: 'Tên việc', dataIndex: 'title', key: 'title'},
    { title: 'Người thực hiện', dataIndex: 'assignee', key: 'assignee', align: 'center' },
    { title: 'Tiến độ', dataIndex: 'progress', key: 'progress', align: 'center' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status', align: 'center' },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority', align: 'center' },
    { title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date', align: 'center' },
    { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date', align: 'center' },
    { title: 'Hạn', dataIndex: 'deadline', key: 'deadline', width: 120, align: 'center' }
];



const filteredTasks = computed(() => {
    if (!drawerFilterKey.value) return []

    if (drawerFilterKey.value === 'week') {
        return tasks.value.filter(t => dayjs(t.end_date).isSame(dayjs(), 'week'))
    }

    if (drawerFilterKey.value === 'today') {
        return tasks.value.filter(t => t.end_date === today)
    }

    if (drawerFilterKey.value === 'month') {
        return tasks.value.filter(t => dayjs(t.end_date).isSame(dayjs(), 'month'))
    }

    if (drawerFilterKey.value === 'urgent') {
        // 👈 thêm điều kiện status !== 'done' để đồng bộ với card
        return tasks.value.filter(t => t.priority === 'high' && t.status !== 'done')
    }
    if (drawerFilterKey.value === 'overdue') {
        return tasks.value.filter(t => t.status === 'overdue')
    }

    if (drawerFilterKey.value === 'done') {
        return tasks.value.filter(t => t.status === 'done')
    }

    return []
})


const paginatedTasks = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value
    const end = start + pageSize.value
    return filteredTasks.value.slice(start, end)
})

const emptyMessage = computed(() => `Không có công việc trong mục "${drawerTitle.value}"`)


const handleCardClick = (item) => {
    const strategy = filterStrategies[item.key];
    if (strategy) {
        const { title, message, data } = strategy();
        filteredTasks.value = data;
        drawerTitle.value = title;
        emptyMessage.value = message;
        drawerVisible.value = true;
    }
};


const openProgressModal = (task) => {
    selectedTask.value = task;
    newProgressValue.value = Number(task.progress) || 0;   // ✅ fix warning
    progressModalVisible.value = true;
};

const updateProgress = async () => {
    if (!selectedTask.value) return;
    progressUpdating.value = true;
    try {
        await updateTask(selectedTask.value.id, { progress: newProgressValue.value });
        await fetchTasks()

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
        const today = new Date().toISOString().slice(0, 10);
        return {
            title: 'Công việc cần xử lý hôm nay',
            message: 'Không có nhiệm vụ nào hôm nay.',
            data: tasks.value.filter(t => t.end_date === today),
        };
    },
    urgent: () => ({
        title: 'Công việc gấp cần xử lý',
        message: 'Không có nhiệm vụ gấp nào.',
        data: tasks.value.filter(t =>
            t.priority === 'high' && t.status !== 'done'
        )
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
};

const formatDate = (dateStr) => dateStr ? dayjs(dateStr).format('DD/MM/YYYY') : '—'

const getStatusText = (status) => ({
    todo: 'Chờ thực hiện',
    doing: 'Đang thực hiện',
    done: 'Hoàn thành',
    overdue: 'Quá hạn'
}[status] || 'Không xác định')

// Sử dụng function có sẵn getUserName

const getUserName = (userId) => {
    if (!userId || !users.value.length) return 'N/A'
    const user = users.value.find(u => u.id == userId)
    return user ? user.name : 'N/A'
}

const getUserById = getUserName;
</script>

<style>
.summary-cards .ant-card-body{
    cursor: pointer;
}
.title_chart {
    text-align: center;
    color: rgb(170, 170, 170);
}
</style>

<style scoped>
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
}
.charts {
    display: flex;
    flex-wrap: wrap;
    gap: 24px;
    margin-bottom: 24px;
}
.chart-box {
    flex: 1;
    min-width: 400px;
    background: #fff;
    padding: 16px;
    border-radius: 8px;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}
.no-tasks {
    text-align: center;
    padding: 32px;
    font-style: italic;
}
</style>
