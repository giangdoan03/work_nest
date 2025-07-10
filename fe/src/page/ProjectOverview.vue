<template>
    <div class="custom-overview">
        <template>
            <div class="header-actions">
                <a :href="`${origin}/gantt-chart`" target="_blank" class="gantt-link">📊 Xem biểu đồ Gantt</a>
            </div>
        </template>
        <table class="custom-table">
            <thead>
            <tr>
                <th style="width: 200px">Khách hàng</th>
                <th style="width: 100px">Loại</th>
                <th>Tên</th>
                <th>Task đang chạy</th>
                <th style="width: 150px">Trạng thái</th>
                <th style="width: 200px">Người phụ trách</th>
                <th>Tiến độ (%)</th>
            </tr>
            </thead>
            <tbody>
            <template v-for="customer in data" :key="customer.customer_id">
                <template v-for="(group, groupIdx) in getGroupedRows(customer)" :key="groupIdx">
                    <template v-for="(item, i) in group.items" :key="i">
                        <template v-for="(task, taskIdx) in item.tasks.length ? item.tasks : [{}]" :key="taskIdx">
                            <tr class="row-hover">
                                <!-- Khách hàng -->
                                <td
                                    v-if="groupIdx === 0 && i === 0 && taskIdx === 0"
                                    :rowspan="getTotalRows(customer)"
                                    class="customer-cell vertical-text"
                                >
                                    {{ customer.customer_name }}
                                </td>

                                <!-- Loại -->
                                <td
                                    v-if="i === 0 && taskIdx === 0"
                                    :rowspan="group.items.reduce((sum, it) => sum + (it.tasks.length || 1), 0)"
                                    :class="['type-cell', group.type]"
                                >
                                    {{ group.type === 'bidding' ? 'Gói thầu' : 'Hợp đồng' }}
                                </td>

                                <!-- Tên -->
                                <td
                                    v-if="taskIdx === 0"
                                    :rowspan="item.tasks.length || 1"
                                    :class="['title-cell', group.type]"
                                >
                                    {{ item.title }}
                                </td>

                                <!-- Task -->
                                <td :class="['task-cell', group.type]">
                                    <span v-if="task.title">
                                      {{ task.title }}
                                    </span>
                                    <span v-else class="muted">Chưa có nhiệm vụ</span>
                                </td>

                                <!-- Trạng thái -->
                                <td :class="['status-cell', group.type]">
                                  <span v-if="task.status" class="task-status" :class="task.status">
                                    {{ getTaskStatusText(task.status) }}
                                  </span>
                                    <span v-else class="muted">—</span>
                                </td>

                                <!-- Người phụ trách -->
                                <td :class="['assignee-cell', group.type]">
                                    <span v-if="task.assignee" class="assignee-badge">
                                      👤 {{ task.assignee.name }}
                                    </span>
                                    <span v-else class="muted">Chưa có</span>
                                </td>

                                <!-- Tiến độ -->
                                <td
                                    v-if="taskIdx === 0"
                                    :rowspan="item.tasks.length || 1"
                                    class="progress-cell"
                                >
                                    <span v-if="item.progress !== null" class="progress-badge">
                                      📊 {{ item.progress }}%
                                    </span>
                                    <span v-else class="muted">—</span>
                                </td>
                            </tr>
                        </template>
                    </template>
                </template>
            </template>
            </tbody>
        </table>

        <!-- ✅ Pagination -->
        <a-pagination
            v-model:current="pagination.page"
            :total="pagination.total"
            :page-size="pagination.limit"
            show-size-changer
            :page-size-options="['5', '10', '20', '50']"
            @change="fetchOverview"
            @showSizeChange="onPageSizeChange"
            style="margin-top: 16px; text-align: right"
        />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getProjectOverviewAPI } from '@/api/project'
import { message } from 'ant-design-vue'
const origin = window.location.origin

const data = ref([])
const pagination = ref({
    page: 1,
    limit: 10,
    total: 0
})

const getGroupedRows = (customer) => {
    const group = (items, type, allTasks, allAssignees) => {
        return {
            type,
            items: items.map(i => {
                const tasks = allTasks
                    .filter(t => t.linked_type === type && String(t.linked_id) === String(i.id))
                    .map(t => ({
                        title: t.title,
                        status: t.status,
                        priority: t.priority,
                        created_at: t.created_at,
                        assigned_to: t.assigned_to,
                        assignee: allAssignees.find(a => String(a.id) === String(t.assigned_to)) || null
                    }))
                    .sort((a, b) => {
                        // Ưu tiên: quá hạn
                        if (a.status === 'overdue' && b.status !== 'overdue') return -1;
                        if (a.status !== 'overdue' && b.status === 'overdue') return 1;

                        // Ưu tiên: priority
                        const priorityRank = { high: 1, medium: 2, low: 3, null: 4 };
                        const prioA = priorityRank[a.priority] || 4;
                        const prioB = priorityRank[b.priority] || 4;
                        if (prioA !== prioB) return prioA - prioB;

                        // Mới hơn lên trước
                        return new Date(b.created_at) - new Date(a.created_at);
                    });

                const progress = tasks.length
                    ? Math.round((tasks.filter(t => t.status === 'done').length / tasks.length) * 100)
                    : null;

                return {
                    title: i.title,
                    tasks,
                    progress
                };
            })
        };
    };

    const result = [];
    const allTasks = customer.tasks || [];
    const assignees = customer.assignees || [];

    if (customer.biddings?.length)
        result.push(group(customer.biddings, 'bidding', allTasks, assignees));
    if (customer.contracts?.length)
        result.push(group(customer.contracts, 'contract', allTasks, assignees));

    return result;
};


const getTotalRows = (customer) => {
    let total = 0
    const allTasks = customer.tasks || []
    const countTasks = (items, type) => {
        return items.reduce((sum, i) => {
            const t = allTasks.filter(t => t.linked_type === type && String(t.linked_id) === String(i.id))
            return sum + (t.length || 1)
        }, 0)
    }

    if (customer.biddings) total += countTasks(customer.biddings, 'bidding')
    if (customer.contracts) total += countTasks(customer.contracts, 'contract')

    return total || 1
}

const fetchOverview = async () => {
    try {
        const res = await getProjectOverviewAPI({
            page: pagination.value.page,
            limit: pagination.value.limit
        })
        data.value = res.data.data
        pagination.value.total = res.data.total
    } catch (e) {
        message.error('Không thể tải dữ liệu tổng quan')
    }
}

const onPageSizeChange = (current, size) => {
    pagination.value.page = 1
    pagination.value.limit = size
    fetchOverview()
}

const getTaskStatusText = (status) => {
    switch (status) {
        case 'todo':
            return 'Chưa làm';
        case 'doing':
            return 'Đang làm';
        case 'done':
            return 'Đã hoàn thành';
        case 'overdue':
            return 'Quá hạn';
        default:
            return 'Không xác định';
    }
};

onMounted(fetchOverview)
</script>

<style scoped>
.custom-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
    background-color: #fff;
}

.custom-table th {
    background-color: #f2f4f8;
    text-align: center;
    font-weight: 600;
    color: #333;
    padding: 15px 10px;
    border: 1px solid #e0e0e0;
}

.custom-table td {
    border: 1px solid #e0e0e0;
    padding: 10px;
    vertical-align: middle;
    color: #333;
}

.row-hover:hover {
    background-color: #f0faff;
    transition: background-color 0.2s ease;
}

.customer-cell {
    background-color: #fafafa;
    font-weight: bold;
    font-size: 15px;
    color: #1d39c4;
}
/*
.type-cell.bidding {
    background-color: #f9f0ff;
    color: #722ed1;
    font-weight: bold;
    text-align: center;
}

.type-cell.contract {
    background-color: #fff2e8;
    color: #fa541c;
    font-weight: bold;
    text-align: center;
}

.title-cell.bidding {
    background-color: #fcf5ff;
    color: #531dab;
}

.title-cell.contract {
    background-color: #fff7e6;
    color: #d4380d;
}

.task-cell.bidding {
    background-color: #faf0fe;
    color: #531dab;
}

.task-cell.contract {
    background-color: #fff1e6;
    color: #d46b08;
}

.assignee-cell.bidding {
    background-color: #fdf4ff;
    color: #531dab;
}

.assignee-cell.contract {
    background-color: #fff7eb;
    color: #d46b08;
}

 */

.progress-cell {
    font-weight: bold;
    color: #52c41a;
    text-align: center;
}

.task-status {
    font-size: 12px;
    margin-left: 6px;
    padding: 2px 6px;
    border-radius: 10px;
    text-transform: uppercase;
    font-weight: bold;
}

.task-status.todo {
    background-color: #e6f7ff;
    color: #1890ff;
}

.task-status.doing {
    background-color: #fffbe6;
    color: #faad14;
}

.task-status.done {
    background-color: #f6ffed;
    color: #52c41a;
}

.assignee-badge {
    display: inline-block;
    background-color: #e6f4ff;
    color: #0958d9;
    padding: 2px 8px;
    border-radius: 10px;
    font-weight: 500;
    font-size: 13px;
}

.progress-badge {
    display: inline-block;
    background-color: #f6ffed;
    color: #237804;
    padding: 4px 8px;
    border-radius: 10px;
    font-weight: 600;
    font-size: 14px;
}

.muted {
    color: #999;
    font-style: italic;
}

.header-actions {
    display: flex;
    justify-content: flex-end;
    margin-bottom: 12px;
}

.gantt-link {
    font-weight: 500;
    color: #096dd9;
    text-decoration: none;
}

.gantt-link:hover {
    text-decoration: underline;
}

/* 🎯 Nút cố định dưới góc phải */
.floating-gantt-link {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: #1890ff;
    color: white;
    padding: 10px 14px;
    border-radius: 6px;
    text-decoration: none;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    font-weight: bold;
    z-index: 1000;
    transition: background 0.3s;
}

.floating-gantt-link:hover {
    background: #40a9ff;
}

.task-status {
    font-weight: 500;
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 12px;
}

.task-status.todo {
    background-color: #e6f7ff;
    color: #1890ff;
}

.task-status.doing {
    background-color: #fffbe6;
    color: #faad14;
}

.task-status.done {
    background-color: #f6ffed;
    color: #52c41a;
}

.task-status.overdue {
    background-color: #fff1f0;
    color: #f5222d;
}
/*
.vertical-text {
    writing-mode: vertical-rl;
    transform: rotate(180deg);
    text-align: center;
    vertical-align: middle;
    white-space: nowrap;
} */

</style>
