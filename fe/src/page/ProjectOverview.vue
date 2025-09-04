<template>
    <div class="custom-overview">
        <a-card>
            <a-tabs v-model:activeKey="activeTabKey" @change="handleTabChange">
                <a-tab-pane key="1">
                    <template #tab>
                        <ShopOutlined /> P.Kinh Doanh
                    </template>
                    <DepartmentTasks v-if="activeTabKey === '1'" :departmentId="1" />
                </a-tab-pane>
                <a-tab-pane key="2">
                    <template #tab>
                        <DollarOutlined /> P.Tài Chính Kế toán
                    </template>
                    <DepartmentTasks v-if="activeTabKey === '2'" :departmentId="2" />
                </a-tab-pane>
                <a-tab-pane key="3">
                    <template #tab>
                        <ShoppingOutlined /> P.Thương Mại
                    </template>
                    <DepartmentTasks v-if="activeTabKey === '3'" :departmentId="3" />
                </a-tab-pane>
                <!--            <a-tab-pane key="4">-->
                <!--                <template #tab>-->
                <!--                    <ToolOutlined /> P.Dịch Vụ Kỹ Thuật-->
                <!--                </template>-->
                <!--                <DepartmentTasks v-if="activeTabKey === '4'" :departmentId="4" />-->
                <!--            </a-tab-pane>-->
                <a-tab-pane key="4">
                    <template #tab>
                        <TeamOutlined /> P.Hành Chính Nhân Sự
                    </template>
                    <DepartmentTasks v-if="activeTabKey === '4'" :departmentId="4" />
                </a-tab-pane>
                <a-tab-pane key="5" :departmentId="5">
                    <template #tab>
                        <AppstoreOutlined /> Tổng quan gói thầu - hợp đồng
                    </template>
                    <!--                <div class="header-actions">-->
                    <!--                    <a :href="`${origin}/gantt-chart`" target="_blank" class="gantt-link">📊 Xem biểu đồ Gantt</a>-->
                    <!--                </div>-->

                    <div class="table-scroll tiny-scroll">
                        <table class="custom-table">
                            <thead>
                            <tr>
                                <th style="min-width: 80px;">Khách hàng</th>
                                <th style="min-width: 50px">Loại</th>
                                <th style="min-width: 50px">Tên</th>
                                <th style="min-width: 90px">Bước quy trình</th>
                                <th style="min-width: 95px">Task đang chạy</th>
                                <th style="min-width: 60px;">Đề nghị</th>
                                <th style="min-width: 50px;">Người thực hiện</th>
                                <th style="min-width: 80px">Bắt đầu</th>
                                <th style="min-width: 80px">Kết thúc</th>
                                <th style="min-width: 80px">Tiến độ</th>
                                <th style="min-width: 70px;">Độ ưu tiên</th>
                                <th style="min-width: 100px">Trạng thái</th>
                                <th style="min-width: 100px">Hạn</th>
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
                                                    <td v-if="groupIdx === 0 && itemIdx === 0 && stepIdx === 0 && taskIdx === 0" :rowspan="getTotalRows(customer)" class="customer-cell vertical-text name_customer">
                                                        <a-tooltip :title="customer.customer_name">
                                                  <span>
                                                    {{ truncatedName(customer.customer_name) }}
                                                  </span>
                                                        </a-tooltip>
                                                    </td>

                                                    <!-- Loại -->
                                                    <td v-if="itemIdx === 0 && stepIdx === 0 && taskIdx === 0"
                                                        :rowspan="group.items.reduce((sum, it) => sum + it.tasks.length, 0)"
                                                        class="type-cell" style="border-right: 1px solid #e0e0e0">
                                                        {{ group.type === 'bidding' ? 'Gói thầu' : 'Hợp đồng' }}
                                                    </td>

                                                    <!-- Tên -->
                                                    <td v-if="stepIdx === 0 && taskIdx === 0"
                                                        :rowspan="item.tasks.length"
                                                        class="title-cell" style="max-width: 150px;border-right: 1px solid #e0e0e0">
                                                        <a-tooltip :title="item.title">
                                                            <span class="ellipsis-text">{{ item.title }}</span>
                                                        </a-tooltip>
                                                    </td>


                                                    <!-- Bước quy trình -->
                                                    <td v-if="taskIdx === 0" :rowspan="stepTasks.length" class="step_code" style="max-width: 150px">
                                                        <a-tooltip :title="task.step_title">
                                                            <router-link :to="getLinkedRoute(task)" class="ellipsis-text" style="color: #096dd9; text-decoration: none">
                                                                <span v-if="task.step_code">B{{ task.step_code }} - </span>{{ task.step_title }}
                                                            </router-link>
                                                        </a-tooltip>
                                                    </td>

                                                    <!-- Các ô còn lại -->
                                                    <td class="task-cell" style="border-left: 1px solid #e0e0e0">
                                                        <a-tooltip :title="task.title" v-if="task.title">
                                                            <router-link :to="`/internal-tasks/${task.id}/info`" class="ellipsis-text" style="color: #1890ff">
                                                                {{ task.title }}
                                                            </router-link>
                                                        </a-tooltip>
                                                        <span v-else class="muted">Chưa có nhiệm vụ</span>
                                                    </td>

                                                    <td style="text-align: center; width: 100px">
                                                        <a-tooltip :title="task.proposed_name || 'Chưa có'">
                                                            <a-avatar size="small"
                                                                      :style="{
                                                                backgroundColor: getAvatarColor(task.proposed_name),
                                                                verticalAlign: 'middle',
                                                                cursor: 'default',
                                                                marginRight: '4px'
                                                              }"
                                                            >
                                                                {{ task.proposed_name?.charAt(0).toUpperCase() || '?' }}
                                                            </a-avatar>
                                                        </a-tooltip>
                                                    </td>

                                                    <td style="text-align: center; width: 100px">
                                                        <a-tooltip :title="task.assignee?.name || 'Chưa có'">
                                                            <a-avatar
                                                                size="small"
                                                                :style="{
                                                            backgroundColor: getAvatarColor(task.assignee?.name),
                                                            verticalAlign: 'middle',
                                                            cursor: 'default',
                                                            marginRight: '4px'
                                                          }"
                                                            >
                                                                {{ task.assignee?.name?.charAt(0).toUpperCase() || '?' }}
                                                            </a-avatar>
                                                        </a-tooltip>
                                                    </td>

                                                    <td @click="openDateModal(task)" style="cursor: pointer;">
                                                        <div style="display: flex; flex-direction: column; align-items: center; line-height: 1.4;">
                                                    <span>
                                                      {{ task.start_date ? formatDate(task.start_date) : '—' }}
                                                    </span>
                                                        </div>
                                                    </td>

                                                    <td @click="openDateModal(task)" style="cursor: pointer;">
                                                        <div style="display: flex; flex-direction: column; align-items: center; line-height: 1.4;">
                                                        <span style="color: #f5222d;">
                                                      {{ task.end_date ? formatDate(task.end_date) : '—' }}
                                                    </span>
                                                        </div>
                                                    </td>

                                                    <td style="cursor: pointer">
                                                        <a-tooltip title="Click để cập nhật tiến độ">
                                                            <div @click="openProgressModal(task)" style="cursor: pointer; width: 100px; margin: 0 auto">
                                                                <a-progress
                                                                    :percent="Number(task.progress) || 0"
                                                                    size="small"
                                                                    :status="getProgressStatus(task.progress)"
                                                                    :format="(percent) => `${percent}%`"
                                                                    :stroke-color="{
                                                                  '0%': '#108ee9',
                                                                  '100%': '#87d068',
                                                                }"
                                                                    :show-info="true"
                                                                />
                                                            </div>
                                                        </a-tooltip>
                                                    </td>
                                                    <td style="text-align: center">
                                                        <a-tag v-if="task.priority" :color="getPriorityColor(task.priority)" bordered>
                                                            {{ task.priority === 'high' ? 'Cao' : task.priority === 'normal' ? 'Trung bình' : 'Thấp' }}
                                                        </a-tag>
                                                        <span v-else class="muted">—</span>
                                                    </td>
                                                    <td style="text-align: center">
                                                        <a-tag v-if="task.status" :color="getStatusColor(task.status)">
                                                            {{ getTaskStatusText(task.status) }}
                                                        </a-tag>
                                                        <span v-else class="muted">—</span>
                                                    </td>

                                                    <td style="text-align: center">
                                                        <a-tooltip v-if="task.days_overdue > 0" :title="task.overdue_reason || 'Chưa rõ lý do'">
                                                            <a-tag color="red" style="cursor: pointer;" @click="openOverdueReasonModal(task)">
                                                                Quá hạn {{ task.days_overdue }} ngày
                                                            </a-tag>
                                                        </a-tooltip>
                                                        <a-tag v-else-if="task.days_remaining > 0" color="orange">
                                                            Còn {{ task.days_remaining }} ngày
                                                        </a-tag>

                                                        <a-tag v-else color="#faad14" style="color: black; font-weight: bold;">
                                                            Hạn hôm nay
                                                        </a-tag>
                                                    </td>

                                                </tr>
                                            </template>
                                        </template>
                                    </template>
                                </template>
                            </template>
                            </tbody>

                        </table>
                    </div>

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
            </a-tabs>
        </a-card>

        <!-- Progress Change Modal -->
        <a-modal
                v-model:open="progressModalVisible"
                title="Cập nhật"
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
                            :stroke-width="20"
                    />
                </div>
            </div>
        </a-modal>

        <a-modal
                v-model:open="dateModalVisible"
                title="Cập nhật thời gian"
                okText="Lưu"
                cancelText="Hủy"
                @ok="updateDates"
                @cancel="dateModalVisible = false"
                :confirm-loading="updatingDates"
        >
            <div style="text-align: center; padding: 20px;">
                <h4>{{ selectedTask?.title }}</h4>
                <a-range-picker
                        v-model:value="dateRange"
                        style="width: 100%; margin-top: 20px;"
                        format="DD/MM/YYYY"
                        :getPopupContainer="triggerNode => triggerNode.parentNode"
                />
            </div>
        </a-modal>

        <a-modal
                v-model:open="overdueModalVisible"
                title="Cập nhật lý do quá hạn"
                okText="Lưu"
                cancelText="Hủy"
                :confirm-loading="updatingOverdueReason"
                @ok="submitOverdueReason"
        >
            <div style="margin-top: 16px;">
                <a-textarea
                        v-model:value="overdueReasonInput"
                        :rows="4"
                        placeholder="Nhập lý do quá hạn..."
                />
            </div>
        </a-modal>



    </div>
</template>

<script setup>
import {ref, onMounted, watch, nextTick } from 'vue';
import {getProjectOverviewAPI} from '@/api/project';
import {message} from 'ant-design-vue';
import { formatDate } from '@/utils/formUtils';
import DepartmentTasks from '@/components/DepartmentTasks.vue'
import { updateTask } from '@/api/task' // API bạn đã viết
import dayjs from 'dayjs'
import {
    UserOutlined,
    CalendarOutlined,
    ClockCircleOutlined,
    ExclamationCircleOutlined,
    CheckCircleOutlined,
    FieldTimeOutlined,
    ShopOutlined,
    DollarOutlined,
    ShoppingOutlined,
    ToolOutlined,
    TeamOutlined,
    AppstoreOutlined
} from '@ant-design/icons-vue';
import { useRoute, useRouter } from 'vue-router'
const route = useRoute()
const router = useRouter()

const origin = window.location.origin;
const data = ref([]);
const pagination = ref({page: 1, limit: 10, total: 0});
const EXPIRING_SOON_DAYS = 3;

const selectedTask = ref(null)

let progressModalVisible = ref(false)
const progressUpdating = ref(false)
const newProgressValue = ref(0)


let dateModalVisible = ref(false)
const updatingDates = ref(false)
const dateRange = ref([]) // [startDate, endDate]


const overdueModalVisible = ref(false)
const overdueReasonInput = ref('')
const updatingOverdueReason = ref(false)



const isExpiringOrOverdue = (t) =>
    (t.days_overdue && t.days_overdue > 0) ||
    (t.days_remaining && t.days_remaining <= EXPIRING_SOON_DAYS);

const isValidAndExpiringTask = (t) =>
    isValidTask(t) &&
    t.status !== 'done' &&
    isExpiringOrOverdue(t);

// Gán mặc định từ URL nếu có, nếu không thì tab đầu tiên
const activeTabKey = ref(route.query.tab || '1')
const currentDeptId = ref(1)

// Theo dõi tab thay đổi để cập nhật URL
watch(activeTabKey, (newVal) => {
    router.replace({ query: { ...route.query, tab: newVal } })
})

const truncatedName = (name) => {
    return name.length > 12 ? name.slice(0, 10) + '…' : name;
}

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
                        isValidAndExpiringTask(t)
                    )
                    .sort((a, b) => {
                        const stepDiff = Number(a.step_code) - Number(b.step_code);
                        if (stepDiff !== 0) return stepDiff;

                        const statusOrder = { 'overdue': 1, 'doing': 2, 'todo': 3, 'done': 4 };
                        return (statusOrder[a.status] || 5) - (statusOrder[b.status] || 5);
                    })
                    .map(t => ({
                        id: t.id,
                        title: t.title,
                        linked_id: t.linked_id,
                        linked_type: t.linked_type,
                        step_code: t.step_code,
                        status: t.status,
                        step_title: t.step_title || null,
                        priority: t.priority,
                        assignee: assignees.find(a => String(a.id) === String(t.assigned_to)) || null,
                        proposed_name: t.proposed_name || null,
                        start_date: t.start_date || null,
                        end_date: t.end_date || null,
                        extensions: t.extensions || [],
                        days_remaining: t.days_remaining,
                        days_overdue: t.days_overdue,
                        overdue_reason: t.overdue_reason || null,
                        progress: t.progress !== undefined ? Number(t.progress) : null
                    }));

                const progress = tasks.length
                    ? Math.round((tasks.filter(t => t.status === 'done').length / tasks.length) * 100)
                    : null;

                return {
                    title: i.title,
                    tasks,
                    progress
                };
            }).filter(i => i.tasks.length > 0) // ✅ loại bỏ items không có task
        };
    };

    const result = [];
    if (customer.biddings?.length) {
        const biddingGroup = group(customer.biddings, 'bidding');
        if (biddingGroup.items.length) result.push(biddingGroup);
    }

    if (customer.contracts?.length) {
        const contractGroup = group(customer.contracts, 'contract');
        if (contractGroup.items.length) result.push(contractGroup);
    }

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

function getAvatarColor(name) {
    const colors = ['#fa8c16', '#1890ff', '#f56a00', '#7265e6', '#13c2c2'];
    if (!name) return '#ccc';
    return colors[name.charCodeAt(0) % colors.length];
}

const openProgressModal = (task) => {
    selectedTask.value = task;
    newProgressValue.value = task.progress || 0;
    progressModalVisible.value = true;
};


const updateProgress = async () => {
    if (!selectedTask.value) return;

    progressUpdating.value = true;

    try {
        await updateTask(selectedTask.value.id, {
            progress: newProgressValue.value
        });

        message.success('Cập nhật tiến độ thành công');
        progressModalVisible.value = false;

        // Gọi lại fetchOverview() hoặc refresh dữ liệu nếu cần
        await fetchOverview?.();
    } catch (e) {
        console.error(e);
        message.error('Cập nhật tiến độ thất bại');
    } finally {
        progressUpdating.value = false;
    }
};


const getProgressStatus = (progress) => {
    if (!progress) return 'normal'
    if (progress >= 100) return 'success'
    if (progress >= 80) return 'normal'
    if (progress >= 50) return 'active'
    return 'exception'
}

const isOverdue = (endDate) => {
    return new Date(endDate) < new Date();
};


const openDateModal = (task) => {
    selectedTask.value = task
    dateRange.value = [
        task.start_date ? dayjs(task.start_date) : null,
        task.end_date ? dayjs(task.end_date) : null
    ]
    dateModalVisible.value = true
}

const updateDates = async () => {
    if (!selectedTask.value) return

    updatingDates.value = true
    try {
        const [start, end] = dateRange.value
        await updateTask(selectedTask.value.id, {
            start_date: start.format('YYYY-MM-DD'),
            end_date: end.format('YYYY-MM-DD')
        })

        message.success('Cập nhật thời gian thành công')  // ✅ thông báo khi thành công
        dateModalVisible.value = false
        // 🔄 Nếu cần, gọi hàm load lại dữ liệu ở đây
    } catch (err) {
        console.error(err)
        message.error('Cập nhật thời gian thất bại') // ❌ thông báo khi lỗi
    } finally {
        updatingDates.value = false
    }
}


const openOverdueReasonModal = (task) => {
    selectedTask.value = task
    overdueReasonInput.value = task.overdue_reason || ''
    overdueModalVisible.value = true
}

const findTaskByIdInData = (taskId) => {
    for (const customer of data.value || []) {
        for (const type of ['biddings', 'contracts']) {
            for (const item of customer[type] || []) {
                if (item.tasks) {
                    for (const task of item.tasks) {
                        if (String(task.id) === String(taskId)) return task;
                    }
                }
            }
        }
    }
    return null;
};


const submitOverdueReason = async () => {
    if (!selectedTask.value) return;

    try {
        await updateTask(selectedTask.value.id, {
            overdue_reason: overdueReasonInput.value
        });

        message.success('Cập nhật lý do thành công');
        overdueModalVisible.value = false;

        // Gọi lại API để đồng bộ tooltip & dữ liệu task
        await fetchOverview();

    } catch (err) {
        console.error(err);
        message.error('Cập nhật lý do thất bại');
    }
};



const isValidTask = (t) => t.priority === 'high' || t.is_priority === true;

const getTotalRows = (customer) => {
    const grouped = getGroupedRows(customer);
    return grouped.reduce((total, group) => {
        return total + group.items.reduce((sum, i) => sum + i.tasks.length, 0);
    }, 0);
};

const getLinkedRoute = (task) => {
    if (!task?.linked_type || !task?.linked_id) return '/project-overview';
    return task.linked_type === 'bidding'
        ? { name: 'bid-detail', params: { id: task.linked_id } }
        : { name: 'contract-detail', params: { id: task.linked_id } };
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

.table-scroll {
    overflow-x: auto;             /* cho scroll ngang */
    -webkit-overflow-scrolling: touch;
}

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
    padding: 8px 10px;
    font-size: 10px;
}

.custom-table td {
    border-bottom: 1px solid #e0e0e0;
    padding: 0 5px;
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

td a, td, td span{
    font-size: 10px;
}
td span{
    font-size: 10px;
}
</style>
