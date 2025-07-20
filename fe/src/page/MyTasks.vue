<template>
    <a-spin :spinning="loading" size="large" tip="Đang tải dữ liệu...">
        <div class="dashboard">
            <a-page-header title="Nhiệm vụ của tôi" style="padding-left: 0; padding-top: 0" />

            <!-- Summary Cards -->
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
                        <router-link :to="`/internal-tasks/${record.id}/info`" style="color: #1890ff;">
                            {{ record.title }}
                        </router-link>
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

const formatDate = (dateStr) => dateStr ? dayjs(dateStr).format('DD/MM/YYYY') : '—'

const getStatusText = (status) => ({
    todo: 'Chờ thực hiện',
    doing: 'Đang thực hiện',
    done: 'Hoàn thành',
    overdue: 'Quá hạn'
}[status] || 'Không xác định')

const getStatusColor = (status) => ({
    todo: 'default',
    doing: 'blue',
    done: 'green',
    overdue: 'red'
}[status] || 'gray')

const getPriorityText = (priority) => ({
    low: 'Thấp',
    normal: 'Trung bình',
    high: 'Cao'
}[priority] || 'Không rõ')

const getPriorityColor = (priority) => ({
    low: 'default',
    normal: 'blue',
    high: 'red'
}[priority] || 'default')
</script>

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
