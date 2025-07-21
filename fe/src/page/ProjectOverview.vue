<template>
    <div class="custom-overview">
        <a-tabs v-model:activeKey="activeTabKey" @change="handleTabChange">
            <a-tab-pane key="1" tab="Tổng quan gói thầu - hợp đồng">
                <div class="header-actions">
                    <a :href="`${origin}/gantt-chart`" target="_blank" class="gantt-link">📊 Xem biểu đồ Gantt</a>
                </div>

                <table class="custom-table">
                    <thead>
                    <tr>
                        <th style="width: 50px">Khách hàng</th>
                        <th style="width: 100px">Loại</th>
                        <th>Tên</th>
                        <th>Bước quy trình</th>
                        <th>Task đang chạy</th>
                        <th>Độ ưu tiên</th>
                        <th style="width: 150px">Đề nghị</th>
                        <th style="width: 150px">Người phụ trách</th>
                        <th style="width: 100px">Bắt đầu</th>
                        <th style="width: 100px">Kết thúc</th>
                        <th style="width: 100px">Gia hạn</th>
                        <th style="width: 150px">Trạng thái</th>
                    </tr>
                    </thead>
                    <tbody>
                    <template v-for="customer in data" :key="customer.customer_id">
                        <template v-for="(group, groupIdx) in getGroupedRows(customer)" :key="groupIdx">
                            <template v-for="(item, itemIdx) in group.items.filter(it => it.tasks?.length)" :key="itemIdx">
                                <template v-for="(stepTasks, stepTitle, stepIdx) in groupByStep(item.tasks)" :key="stepTitle">
                                    <template v-for="(task, taskIdx) in stepTasks" :key="taskIdx">
                                        <tr class="row-hover">
                                            <!-- Khách hàng -->
                                            <td v-if="groupIdx === 0 && itemIdx === 0 && stepIdx === 0 && taskIdx === 0"
                                                :rowspan="getTotalRows(customer)"
                                                class="customer-cell vertical-text name_customer">
                                                {{ customer.customer_name }}
                                            </td>

                                            <!-- Loại -->
                                            <td v-if="itemIdx === 0 && stepIdx === 0 && taskIdx === 0"
                                                :rowspan="group.items.reduce((sum, it) => sum + it.tasks.length, 0)"
                                                class="type-cell">
                                                {{ group.type === 'bidding' ? 'Gói thầu' : 'Hợp đồng' }}
                                            </td>

                                            <!-- Tên -->
                                            <td v-if="stepIdx === 0 && taskIdx === 0"
                                                :rowspan="item.tasks.length"
                                                class="title-cell">
                                                {{ item.title }}
                                            </td>

                                            <!-- Bước quy trình -->
                                            <td
                                                v-if="taskIdx === 0"
                                                :rowspan="stepTasks.length"
                                                class="step_code"
                                            >
                                                <a-tooltip :title="task.step_title">
                                                    <span class="ellipsis-text">
                                                      <span v-if="task.step_code">B{{ task.step_code }} - </span>{{ task.step_title }}
                                                    </span>
                                                </a-tooltip>
                                            </td>


                                            <!-- Các ô còn lại -->
                                            <td class="task-cell">
                                                <a-tooltip :title="task.title" v-if="task.title">
                                                    <span class="ellipsis-text">• {{ task.title }}</span>
                                                </a-tooltip>
                                                <span v-else class="muted">Chưa có nhiệm vụ</span>
                                            </td>
                                            <td>
                                                <a-tag v-if="task.priority" :color="getPriorityColor(task.priority)" bordered>
                                                    {{ task.priority === 'high' ? 'Cao' : task.priority === 'normal' ? 'Trung bình' : 'Thấp' }}
                                                </a-tag>
                                                <span v-else class="muted">—</span>
                                            </td>
                                            <td>{{ task.proposed_name || 'Chưa có' }}</td>
                                            <td>{{ task.assignee?.name || 'Chưa có' }}</td>
                                            <td>{{ task.start_date ? formatDate(task.start_date) : '—' }}</td>
                                            <td>{{ task.end_date ? formatDate(task.end_date) : '—' }}</td>
                                            <td>
                                                <ul v-if="task.extensions?.length" class="extension-list">
                                                    <li v-for="(ext, extIdx) in task.extensions" :key="extIdx">
                                                        {{ formatDate(ext.new_end_date) }}
                                                    </li>
                                                </ul>
                                                <span v-else class="muted">—</span>
                                            </td>
                                            <td>
                                                <a-tag v-if="task.status" :color="getStatusColor(task.status)">
                                                    {{ getTaskStatusText(task.status) }}
                                                </a-tag>
                                                <span v-else class="muted">—</span>
                                            </td>
                                        </tr>
                                    </template>
                                </template>
                            </template>
                        </template>
                    </template>
                    </tbody>

                </table>

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
            </a-tab-pane>

            <a-tab-pane key="2" tab="P.Kinh Doanh">
                <DepartmentTasks v-if="activeTabKey === '2'" :departmentId="1" />
            </a-tab-pane>
            <a-tab-pane key="3" tab="P.Tài Chính Kế toán">
                <DepartmentTasks v-if="activeTabKey === '3'" :departmentId="2" />
            </a-tab-pane>
            <a-tab-pane key="4" tab="P.Thương Mại">
                <DepartmentTasks v-if="activeTabKey === '4'" :departmentId="3" />
            </a-tab-pane>
            <a-tab-pane key="5" tab="P.Dịch Vụ Kỹ Thuật">
                <DepartmentTasks v-if="activeTabKey === '5'" :departmentId="4" />
            </a-tab-pane>
            <a-tab-pane key="6" tab="P.Hành Chính Nhân Sự">
                <DepartmentTasks v-if="activeTabKey === '6'" :departmentId="5" />
            </a-tab-pane>
        </a-tabs>
    </div>
</template>

<script setup>
import {ref, onMounted, watch } from 'vue';
import {getProjectOverviewAPI} from '@/api/project';
import {message} from 'ant-design-vue';
import { formatDate } from '@/utils/formUtils';
import DepartmentTasks from '@/components/DepartmentTasks.vue'
import { useRoute, useRouter } from 'vue-router'
const route = useRoute()
const router = useRouter()

const origin = window.location.origin;
const data = ref([]);
const pagination = ref({page: 1, limit: 10, total: 0});

// Gán mặc định từ URL nếu có, nếu không thì tab đầu tiên
const activeTabKey = ref(route.query.tab || '1')
const currentDeptId = ref(1)

// Theo dõi tab thay đổi để cập nhật URL
watch(activeTabKey, (newVal) => {
    router.replace({ query: { ...route.query, tab: newVal } })
})

const getGroupedRows = (customer) => {
    const allTasks = customer.tasks || [];
    const assignees = customer.assignees || [];

    const group = (items, type) => {
        return {
            type,
            items: items.map(i => {
                const tasks = allTasks
                    .filter(t =>
                        t.linked_type === type &&
                        String(t.linked_id) === String(i.id) &&
                        isValidTask(t)
                    )
                    .sort((a, b) => {
                        // 🟢 Ưu tiên sắp theo step_code trước, rồi mới theo status
                        const stepDiff = Number(a.step_code) - Number(b.step_code);
                        if (stepDiff !== 0) return stepDiff;

                        const statusOrder = { 'overdue': 1, 'doing': 2, 'todo': 3, 'done': 4 };
                        return (statusOrder[a.status] || 5) - (statusOrder[b.status] || 5);
                    })
                    .map(t => ({
                        title: t.title,
                        step_code: t.step_code,
                        status: t.status,
                        step_title: t.step_title || null,
                        priority: t.priority,
                        assignee: assignees.find(a => String(a.id) === String(t.assigned_to)) || null,
                        proposed_name: t.proposed_name || null,
                        start_date: t.start_date || null,
                        end_date: t.end_date || null,
                        extensions: t.extensions || []
                    }));

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
    if (customer.biddings?.length) result.push(group(customer.biddings, 'bidding'));
    if (customer.contracts?.length) result.push(group(customer.contracts, 'contract'));
    return result;
};

const groupByStep = (tasks) => {
    return tasks.reduce((acc, task) => {
        const key = task.step_title || '—';
        if (!acc[key]) acc[key] = [];
        acc[key].push(task);
        return acc;
    }, {});
};

const handleTabChange = (key) => {
    activeTabKey.value = key
    const mapping = {
        '2': 1,
        '3': 2,
        '4': 3,
        '5': 4,
        '6': 5
    }
    currentDeptId.value = mapping[key] ?? null
}


const getPriorityColor = (priority) => {
    switch (priority) {
        case 'high':
            return 'red';
        case 'normal':
            return 'orange';
        case 'low':
            return 'blue';
        default:
            return 'default';
    }
};


const isValidTask = (t) => t.priority === 'high' || t.is_priority === true;

const getTotalRows = (customer) => {
    const allTasks = customer.tasks || [];

    const count = (items, type) => {
        return items.reduce((sum, i) => {
            const itemTasks = allTasks.filter(t =>
                t.linked_type === type &&
                String(t.linked_id) === String(i.id) &&
                isValidTask(t)
            );
            return sum + itemTasks.length;
        }, 0);
    };

    let total = 0;
    if (customer.biddings) total += count(customer.biddings, 'bidding');
    if (customer.contracts) total += count(customer.contracts, 'contract');
    return total;
};



const fetchOverview = async () => {
    try {
        const res = await getProjectOverviewAPI({
            page: pagination.value.page,
            limit: pagination.value.limit
        });
        data.value = res.data.data;
        pagination.value.total = res.data.total;
    } catch (e) {
        message.error('Không thể tải dữ liệu tổng quan');
    }
};

const onPageSizeChange = (current, size) => {
    pagination.value.page = 1;
    pagination.value.limit = size;
    fetchOverview();
};

const getTaskStatusText = (status) => {
    switch (status) {
        case 'todo':
            return 'Chưa làm';
        case 'doing':
            return 'Đang triển khai';
        case 'done':
            return 'Đã hoàn thành';
        case 'overdue':
            return 'Quá hạn';
        default:
            return 'Không xác định';
    }
};


const getStatusColor = (status) => {
    switch (status) {
        case 'todo':
            return '#2db7f5'; // xanh nhạt
        case 'doing':
            return '#108ee9'; // xanh dương
        case 'done':
            return '#87d068'; // xanh lá
        case 'overdue':
            return '#f50';    // đỏ
        default:
            return 'default';
    }
};


onMounted(fetchOverview);
</script>


<style scoped>

.name_customer {
    text-transform: uppercase;
}
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
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
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

.task-status.overdue {
    color: white;
    background-color: red;
    padding: 2px 6px;
    border-radius: 4px;
}
.task-status.done {
    background-color: #52c41a;
    color: white;
    padding: 2px 6px;
    border-radius: 4px;
}
.task-status.doing {
    background-color: #faad14;
    color: white;
    padding: 2px 6px;
    border-radius: 4px;
}
.task-status.todo {
    background-color: #d9d9d9;
    color: black;
    padding: 2px 6px;
    border-radius: 4px;
}
.ellipsis-text {
    display: inline-block;
    max-width: 200px; /* hoặc theo layout bạn muốn */
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    vertical-align: middle;
}
</style>
