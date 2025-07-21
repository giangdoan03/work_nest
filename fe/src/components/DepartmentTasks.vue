<template>
    <a-spin :spinning="loading" size="large" tip="Đang tải dữ liệu...">
        <div class="dashboard">
            <div class="summary-cards">
                <a-card v-for="item in stats" :key="item.key" :style="{ backgroundColor: item.bg }">
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

            <a-divider>Danh sách công việc</a-divider>
            <a-table :columns="columns" :dataSource="tasks" rowKey="id" bordered size="small" :pagination="false">
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
                    <template v-else-if="column.dataIndex === 'end_date'">
                        {{ formatDate(record.end_date) }}
                    </template>
                </template>
            </a-table>


            <div v-if="!tasks.length" class="no-tasks">
                <p>Không có nhiệm vụ nào.</p>
            </div>
        </div>
    </a-spin>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
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



const props = defineProps({
    departmentId: [String, Number]
})

const loading = ref(false)
const tasks = ref([])
const stats = ref([])

const columns = [
    { title: 'Tên công việc', dataIndex: 'title', key: 'title' },
    { title: 'Người thực hiện', dataIndex: 'name', key: 'name' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority' },
    { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date' }
]

const loadTasks = async () => {
    if (!props.departmentId) return
    loading.value = true
    try {
        const res = await getTasks({ id_department: props.departmentId, per_page: 100 })
        tasks.value = res.data.data || []
        updateStats(tasks.value)
    } catch (e) {
        console.error(e)
        tasks.value = []
    } finally {
        loading.value = false
    }
}

const updateStats = (data) => {
    const today = new Date().toISOString().slice(0, 10)
    stats.value = [
        {
            key: 'total',
            label: 'Công việc lãnh đạo giao xử lý',
            count: data.length,
            icon: ClockCircleOutlined,
            color: '#1890ff',
            bg: '#e6f7ff'
        },
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

onMounted(loadTasks)
watch(() => props.departmentId, loadTasks)
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
.no-tasks {
    text-align: center;
    padding: 32px;
    font-style: italic;
}
</style>
