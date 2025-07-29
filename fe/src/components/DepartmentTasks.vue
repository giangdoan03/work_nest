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
                    <h4>Danh sách công việc còn 1 ngày hết hạn</h4>
                    <a-table 
                        :columns="columns" 
                        :dataSource="tasksDueIn1Day" 
                        rowKey="id" 
                        bordered 
                        size="small" 
                        :pagination="false"
                        :scroll="{ x: 900, y: 300 }"
                        :locale="{ emptyText: 'Không có dữ liệu' }"
                    >
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
                                            :percent="record.progress || 0" 
                                            size="small" 
                                            :status="getProgressStatus(record.progress)"
                                            :format="(percent) => `${percent}%`"
                                            :stroke-width="20"
                                        />
                                    </div>
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'name'">
                                <a-tooltip 
                                    placement="top"
                                    :overlayStyle="{ maxWidth: '300px' }"
                                >
                                    <template #title>
                                        <div style="text-align: center; padding: 8px;">
                                            <a-avatar 
                                                :style="{ backgroundColor: getAvatarColor(record.name) }"
                                                size="large"
                                                style="margin-bottom: 8px;"
                                            >
                                                {{ getFirstLetter(record.name) }}
                                            </a-avatar>
                                            <div style="font-weight: bold; color: white;">{{ record.name }}</div>
                                        </div>
                                    </template>
                                    <div style="display: flex; justify-content: center; align-items: center;">
                                        <a-avatar 
                                            :style="{ backgroundColor: getAvatarColor(record.name) }"
                                            size="small"
                                        >
                                            {{ getFirstLetter(record.name) }}
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
                                            <a-avatar 
                                                :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }"
                                                size="large"
                                                style="margin-bottom: 8px;"
                                            >
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
                            <template v-else-if="column.dataIndex === 'end_date'">
                                {{ formatDate(record.end_date) }}
                            </template>
                        </template>
                    </a-table>

                    <div v-if="!tasksDueIn1Day.length" class="no-tasks">
                        <p>Không có công việc nào còn 1 ngày hết hạn.</p>
                    </div>
                </div>

                <div class="table-section">
                    <h4>Danh sách Công việc cần thực hiện GẤP</h4>
                    <a-table 
                        :columns="columns" 
                        :dataSource="urgentTasks" 
                        rowKey="id" 
                        bordered 
                        size="small" 
                        :pagination="false"
                        :scroll="{ x: 900, y: 300 }"
                        :locale="{ emptyText: 'Không có dữ liệu' }"
                    >
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
                                            :percent="record.progress || 0" 
                                            size="small" 
                                            :status="getProgressStatus(record.progress)"
                                            :format="(percent) => `${percent}%`"
                                            :stroke-width="20"
                                        />
                                    </div>
                                </a-tooltip>
                            </template>
                            <template v-else-if="column.dataIndex === 'name'">
                                <a-tooltip 
                                    placement="top"
                                    :overlayStyle="{ maxWidth: '300px' }"
                                >
                                    <template #title>
                                        <div style="text-align: center; padding: 8px;">
                                            <a-avatar 
                                                :style="{ backgroundColor: getAvatarColor(record.name) }"
                                                size="large"
                                                style="margin-bottom: 8px;"
                                            >
                                                {{ getFirstLetter(record.name) }}
                                            </a-avatar>
                                            <div style="font-weight: bold; color: white;">{{ record.name }}</div>
                                        </div>
                                    </template>
                                    <div style="display: flex; justify-content: center; align-items: center;">
                                        <a-avatar 
                                            :style="{ backgroundColor: getAvatarColor(record.name) }"
                                            size="small"
                                        >
                                            {{ getFirstLetter(record.name) }}
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
                                            <a-avatar 
                                                :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }"
                                                size="large"
                                                style="margin-bottom: 8px;"
                                            >
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
                            <template v-else-if="column.dataIndex === 'end_date'">
                                {{ formatDate(record.end_date) }}
                            </template>
                        </template>
                    </a-table>

                    <div v-if="!urgentTasks.length" class="no-tasks">
                        <p>Không có công việc GẤP nào.</p>
                    </div>
                </div>
            </div>

        </div>

        <!-- Drawer for Today Tasks -->
        <a-drawer
            :title="drawerTitle"
            placement="right"
            :width="800"
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
                                        :percent="record.progress || 0" 
                                        size="small" 
                                        :status="getProgressStatus(record.progress)"
                                        :format="(percent) => `${percent}%`"
                                        :stroke-width="20"
                                    />
                                </div>
                            </a-tooltip>
                        </template>
                        <template v-else-if="column.dataIndex === 'name'">
                            <a-tooltip 
                                placement="top"
                                :overlayStyle="{ maxWidth: '300px' }"
                            >
                                <template #title>
                                    <div style="text-align: center; padding: 8px;">
                                        <a-avatar 
                                            :style="{ backgroundColor: getAvatarColor(record.name) }"
                                            size="large"
                                            style="margin-bottom: 8px;"
                                        >
                                            {{ getFirstLetter(record.name) }}
                                        </a-avatar>
                                        <div style="font-weight: bold; color: white;">{{ record.name }}</div>
                                    </div>
                                </template>
                                <div style="display: flex; justify-content: center; align-items: center;">
                                    <a-avatar 
                                        :style="{ backgroundColor: getAvatarColor(record.name) }"
                                        size="small"
                                    >
                                        {{ getFirstLetter(record.name) }}
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
                                        <a-avatar 
                                            :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }"
                                            size="large"
                                            style="margin-bottom: 8px;"
                                        >
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
                                        {{ getFirstLetter(record.assigned_to_name) }}
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
import { ref, onMounted, watch, computed } from 'vue'
import {
    ClockCircleOutlined,
    FlagOutlined,
    FireOutlined,
    CheckCircleOutlined,
    StopOutlined
} from '@ant-design/icons-vue'
import { formatDate } from '@/utils/formUtils';
import PieChart from './PieChart.vue'
import BarChart from './BarChart.vue'
import { getTasks } from '@/api/task'
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
const progressModalVisible = ref(false)
const progressUpdating = ref(false)
const selectedTask = ref(null)
const newProgressValue = ref(0)

const paginatedTasks = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value
    const end = start + pageSize.value
    return filteredTasks.value.slice(start, end)
})

const tasksDueIn1Day = computed(() => {
    const tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    const tomorrowStr = tomorrow.toISOString().slice(0, 10)
    return tasks.value.filter(task => task.end_date === tomorrowStr)
})

const urgentTasks = computed(() => {
    return tasks.value.filter(task => task.priority === 'high')
})

const columns = [
    { title: 'Tên công việc', dataIndex: 'title', key: 'title' },
    { title: 'Người thực hiện', dataIndex: 'name', key: 'name' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority' },
    { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date' }
]

const drawerColumns = [
    { title: 'Tên công việc', dataIndex: 'title', key: 'title', width: 200, ellipsis: true },
    { title: 'Người thực hiện', dataIndex: 'name', key: 'name', width: 80, align: 'center' },
    { title: 'Người giao việc', dataIndex: 'assigned_to_name', key: 'assigned_to_name', width: 80, align: 'center' },
    { title: 'Tiến trình', dataIndex: 'progress', key: 'progress', width: 120, align: 'center' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 120, align: 'center' },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority', width: 80, align: 'center' },
    { title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date', width: 120, align: 'center' },
    { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date', width: 120, align: 'center' }
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
        
        // Map assigned_to IDs to user names
        tasks.value = tasks.value.map(task => ({
            ...task,
            assigned_to_name: getUserName(task.assigned_to)
        }))
        
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
    const today = new Date().toISOString().slice(0, 10)
    stats.value = [
        // {
        //     key: 'total',
        //     label: 'Công việc lãnh đạo giao xử lý',
        //     count: data.length,
        //     icon: ClockCircleOutlined,
        //     color: '#1890ff',
        //     bg: '#e6f7ff'
        // },
        {
            key: 'today',
            label: 'Công việc cần xử lý hôm nay',
            count: data.filter(t => t.end_date === today).length,
            icon: FlagOutlined,
            color: '#faad14',
            bg: '#fffbe6'
        },
        {
            key: 'urgent',
            label: 'Công việc GẤP cần xử lý',
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
            label: 'Công việc QUÁ HẠN',
            count: data.filter(t => t.status === 'overdue').length,
            icon: StopOutlined,
            color: '#ff4d4f',
            bg: '#fff1f0'
        }
    ]
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

const handleCardClick = (item) => {
    // Implement navigation or filtering logic here
    // For example, if 'today' is clicked, filter tasks for today
    if (item.key === 'today') {
        const today = new Date().toISOString().slice(0, 10);
        filteredTasks.value = tasks.value.filter(t => t.end_date === today);
        drawerTitle.value = 'Công việc cần xử lý hôm nay';
        emptyMessage.value = 'Không có nhiệm vụ nào hôm nay.';
        drawerVisible.value = true; // Open the drawer
    } else if (item.key === 'urgent') {
        filteredTasks.value = tasks.value.filter(t => t.priority === 'high');
        drawerTitle.value = 'Công việc GẤP cần xử lý';
        emptyMessage.value = 'Không có nhiệm vụ GẤP nào.';
        drawerVisible.value = true;
    } else if (item.key === 'done') {
        filteredTasks.value = tasks.value.filter(t => t.status === 'done');
        drawerTitle.value = 'Công việc hoàn thành';
        emptyMessage.value = 'Không có nhiệm vụ hoàn thành nào.';
        drawerVisible.value = true;
    } else if (item.key === 'overdue') {
        filteredTasks.value = tasks.value.filter(t => t.status === 'overdue');
        drawerTitle.value = 'Công việc QUÁ HẠN';
        emptyMessage.value = 'Không có nhiệm vụ QUÁ HẠN nào.';
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
        await getTasks({ id: selectedTask.value.id, progress: newProgressValue.value });
        // Reload tasks to update progress
        await loadTasks();
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
