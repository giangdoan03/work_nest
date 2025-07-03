<template>
    <div class="custom-overview">
        <table class="custom-table">
            <thead>
            <tr>
                <th>Khách hàng</th>
                <th>Loại</th>
                <th>Tên</th>
                <th>Task liên quan</th>
                <th>Người phụ trách</th>
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
                                    class="customer-cell"
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
                      <span class="task-status" :class="task.status">
                        {{ task.status }}
                      </span>
                    </span>
                                    <span v-else class="muted">Chưa có nhiệm vụ</span>
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
    </div>
</template>


<script setup>
import { ref, onMounted } from 'vue'
import { getProjectOverviewAPI } from '@/api/project'
import { message } from 'ant-design-vue'

const data = ref([])

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
                        assigned_to: t.assigned_to,
                        assignee: allAssignees.find(a => String(a.id) === String(t.assigned_to)) || null
                    }))

                const progress = tasks.length
                    ? Math.round((tasks.filter(t => t.status === 'done').length / tasks.length) * 100)
                    : null

                return {
                    title: i.title,
                    tasks,
                    progress
                }
            })
        }
    }

    const result = []
    const allTasks = customer.tasks || []
    const assignees = customer.assignees || []

    if (customer.biddings?.length) result.push(group(customer.biddings, 'bidding', allTasks, assignees))
    if (customer.contracts?.length) result.push(group(customer.contracts, 'contract', allTasks, assignees))

    return result
}

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
        const res = await getProjectOverviewAPI()
        data.value = res.data.data
    } catch (e) {
        message.error('Không thể tải dữ liệu tổng quan')
    }
}

onMounted(fetchOverview)
</script>

<style scoped>
.custom-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 16px;
    font-size: 14px;
    background-color: #fff;
}

.custom-table th {
    background-color: #f2f4f8;
    text-align: center;
    font-weight: 600;
    color: #333;
    border-bottom: 2px solid #ccc;
}

.custom-table td {
    border: 1px solid #e0e0e0;
    padding: 10px;
    vertical-align: middle;
    color: #333;
}

/* ✅ Hover highlight */
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

.progress-cell {
    font-weight: bold;
    color: #52c41a;
    text-align: center;
}

/* ✅ Biểu tượng trạng thái task */
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

/* ✅ Badge người phụ trách */
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

</style>
