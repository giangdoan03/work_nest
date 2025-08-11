<template>
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
                        <h2>{{ item.count }}</h2>
                    </a-space>
                </a-card>
            </div>

            <a-divider>Tổng quan công việc</a-divider>

            <!-- Charts -->
            <div class="charts">
                <div class="chart-box">
                    <h4>Tỉ lệ công việc</h4>
                    <PieChart :data="tasks" />
                </div>
                <div class="chart-box">
                    <h4>Công việc theo tháng</h4>
                    <BarByMonth :data="tasks" />
                </div>
            </div>

            <a-divider>Danh sách công việc</a-divider>

            <!-- Task Table -->
            <a-table :dataSource="tasks" :loading="loading" :rowKey="record => record.id" bordered size="small">
                <a-table-column title="Tiêu đề" key="title">
                    <template #default="{ record }">
                        <div style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap;" :title="record.title">
                            <router-link :to="`/internal-tasks/${record.id}/info`" style="color: #1890ff;">
                                {{ record.title }}
                            </router-link>
                        </div>
                    </template>
                </a-table-column>

                <a-table-column title="Mô tả" dataIndex="description" key="description" :ellipsis="true" />

                <a-table-column title="Liên kết" key="linked_type">
                    <template #default="{ record }">
                        <a-tag color="blue" v-if="record.linked_type === 'contract'">Hợp đồng</a-tag>
                        <a-tag color="purple" v-else-if="record.linked_type === 'bidding'">Gói thầu</a-tag>
                        <a-tag color="orange" v-else>Nội bộ</a-tag>
                    </template>
                </a-table-column>

                <a-table-column title="Ngày kết thúc" key="end_date">
                    <template #default="{ record }">{{ formatDate(record.end_date) }}</template>
                </a-table-column>

                <a-table-column title="Trạng thái" key="status">
                    <template #default="{ record }">
                        <a-tag :color="getStatusColor(record.status)">
                            {{ getStatusText(record.status) }}
                        </a-tag>
                    </template>
                </a-table-column>

                <a-table-column title="Số lần gia hạn" key="extension_count">
                    <template #default="{ record }">{{ record.extension_count || 0 }}</template>
                </a-table-column>

                <a-table-column title="Mức độ ưu tiên" key="priority">
                    <template #default="{ record }">
                        <a-tag :color="getPriorityColor(record.priority)">
                            {{ getPriorityText(record.priority) }}
                        </a-tag>
                    </template>
                </a-table-column>
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
                    <template #bodyCell="{ column, record }">
                        <template v-if="column.dataIndex === 'status'">
                            <a-tag :color="getStatusColor(record.status)">
                                {{ getTaskStatusText(record.status) }}
                            </a-tag>
                        </template>
                        <template v-else-if="column.dataIndex === 'title'">
                            <a-tooltip :title="record.title">
                                <div style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap;">
                                    <router-link :to="`/internal-tasks/${record.id}/info`" style="color: #1890ff;">
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
                        <template v-else-if="column.dataIndex === 'assignee'">
                            <a-tooltip placement="top" :overlayStyle="{ maxWidth: '300px' }">
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
                                        <a-avatar
                                                :style="{ backgroundColor: getAvatarColor(getUserById(record.create_by)) }"
                                                size="large"
                                                style="margin-bottom: 12px;"
                                        >
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
    StopOutlined
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
        key: 'todo',
        label: 'Công việc chờ bạn',
        count: tasks.value.filter(t => t.status === 'todo').length,
        icon: ClockCircleOutlined,
        color: '#1890ff',
        bg: '#e6f7ff'
    },
    {
        key: 'done',
        label: 'Việc bạn đã hoàn thành',
        count: tasks.value.filter(t => t.status === 'done').length,
        icon: CheckOutlined,
        color: '#52c41a',
        bg: '#f6ffed'
    },
    {
        key: 'overdue',
        label: 'Việc bạn quá hạn',
        count: tasks.value.filter(t => t.status === 'overdue').length,
        icon: StopOutlined,
        color: '#ff4d4f',
        bg: '#fff1f0'
    },
    {
        key: 'today',
        label: 'Công việc cần xử lý hôm nay',
        count: tasks.value.filter(t => t.end_date === today).length,
        icon: FlagOutlined,
        color: '#faad14',
        bg: '#fffbe6'
    },
    {
        key: 'week',
        label: 'Việc trong tuần',
        count: tasks.value.filter(t => dayjs(t.end_date).isSame(dayjs(), 'week')).length,
        icon: FileTextOutlined,
        color: '#722ed1',
        bg: '#f9f0ff'
    },
    {
        key: 'projects',
        label: 'Dự án đang thực hiện',
        count: tasks.value.filter(t => ['bidding', 'contract'].includes(t.linked_type)).length,
        icon: ProjectOutlined,
        color: '#40a9ff',
        bg: '#e6f7ff'
    }
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
        title: 'Tiêu đề',
        dataIndex: 'title',
        key: 'title',
    },
    {
        title: 'Trạng thái',
        dataIndex: 'status',
        key: 'status',
    },
    {
        title: 'Mức độ ưu tiên',
        dataIndex: 'priority',
        key: 'priority',
    },
    {
        title: 'Tiến độ',
        dataIndex: 'progress',
        key: 'progress',
    },
    {
        title: 'Người thực hiện',
        dataIndex: 'assignee',
        key: 'assignee',
    },
    // {
    //     title: 'Người tạo',
    //     dataIndex: 'create_by',
    //     key: 'create_by',
    // },
    {
        title: 'Ngày bắt đầu',
        dataIndex: 'start_date',
        key: 'start_date',
    },
    {
        title: 'Hạn',
        dataIndex: 'deadline',
        key: 'deadline',
    },
]


const filteredTasks = computed(() => {
    if (!drawerFilterKey.value) return []

    if (drawerFilterKey.value === 'week') {
        return tasks.value.filter(t => dayjs(t.end_date).isSame(dayjs(), 'week'))
    }

    if (drawerFilterKey.value === 'projects') {
        return tasks.value.filter(t => ['bidding', 'contract'].includes(t.linked_type))
    }

    if (drawerFilterKey.value === 'today') {
        return tasks.value.filter(t => t.end_date === today)
    }

    return tasks.value.filter(t => t.status === drawerFilterKey.value)
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
    newProgressValue.value = task.progress || 0;
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



//
// const getStatusColor = (status) => ({
//     todo: 'default',
//     doing: 'blue',
//     done: 'green',
//     overdue: 'red'
// }[status] || 'gray')
//
// const getPriorityText = (priority) => ({
//     low: 'Thấp',
//     normal: 'Trung bình',
//     high: 'Cao'
// }[priority] || 'Không rõ')
//
// const getPriorityColor = (priority) => ({
//     low: 'default',
//     normal: 'blue',
//     high: 'red'
// }[priority] || 'default')
</script>

<style>
.summary-cards .ant-card-body{
    cursor: pointer;
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
