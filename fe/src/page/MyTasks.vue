<template>
    <div>
        <a-page-header title="Nhiệm vụ của tôi" style="padding-left: 0; padding-top: 0" />

        <!-- Bộ lọc thời gian -->
        <div style="margin-bottom: 16px;">
            <a-select v-model:value="timeframe" @change="fetchTasks" style="width: 200px;">
                <a-select-option value="all">Tất cả</a-select-option>
                <a-select-option value="day">Hôm nay</a-select-option>
                <a-select-option value="week">Tuần này</a-select-option>
                <a-select-option value="month">Tháng này</a-select-option>
                <a-select-option value="year">Năm nay</a-select-option>
            </a-select>
        </div>

        <!-- Bảng nhiệm vụ -->
        <a-table :dataSource="tasks" :loading="loading" :rowKey="record => record.id" bordered>
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
                    <a-tag :color="getStatusColor(record.status)">{{ getStatusText(record.status) }}</a-tag>
                </template>
            </a-table-column>
            <a-table-column title="Mức độ ưu tiên" key="priority">
                <template #default="{ record }">
                    <a-tag :color="getPriorityColor(record.priority)">{{ getPriorityText(record.priority) }}</a-tag>
                </template>
            </a-table-column>
        </a-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import { getMyTasksAPI } from '@/api/task'

const loading = ref(false)
const tasks = ref([])
const timeframe = ref('all')

const fetchTasks = async () => {
    try {
        loading.value = true
        const res = await getMyTasksAPI({ timeframe: timeframe.value })
        tasks.value = res.data.data
    } catch (e) {
        message.error('Không thể tải danh sách nhiệm vụ')
    } finally {
        loading.value = false
    }
}

const formatDate = (dateStr) => dateStr ? dayjs(dateStr).format('DD/MM/YYYY') : '—'

const getStatusText = (status) => ({
    todo: 'Chưa làm',
    doing: 'Đang làm',
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

onMounted(fetchTasks)
</script>
