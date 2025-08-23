<template>
    <div>
        <!--        <a-flex justify="space-between">-->
        <!--            <div>-->
        <!--                <a-typography-title :level="5">Danh sách nhiệm vụ</a-typography-title>-->
        <!--            </div>-->
        <!--            <a-button type="primary" @click="showPopupCreate('internal')">Thêm nhiệm vụ mới</a-button>-->
        <!--        </a-flex>-->

        <a-row  justify="space-between" :gutter="[12,12]">
            <!-- Trái: nhóm filter nhanh + icon mở drawer -->
            <a-col flex="auto">
                <a-space wrap>
                    <!-- Lọc theo loại -->
                    <a-button-group>
                        <a-button :type="dataFilter.linked_type === null ? 'primary' : 'default'"
                                  @click="filterByType(null)">
                            Tất cả ({{ totalTasks }})
                        </a-button>
                        <a-button :type="dataFilter.linked_type === 'bidding' ? 'primary' : 'default'"
                                  @click="filterByType('bidding')">Gói thầu</a-button>
                        <a-button :type="dataFilter.linked_type === 'contract' ? 'primary' : 'default'"
                                  @click="filterByType('contract')">Hợp đồng</a-button>
                        <a-button :type="dataFilter.linked_type === 'internal' ? 'primary' : 'default'"
                                  @click="filterByType('internal')">Công việc nội bộ</a-button>
                    </a-button-group>

                    <!-- Icon mở drawer filter chi tiết -->
                    <a-badge :count="activeFilterCount || null" :offset="[0,6]">
                        <a-button type="default" @click="showFilterDrawer = true">
                            <template #icon><FilterOutlined /></template>
                        </a-button>
                    </a-badge>

                </a-space>
            </a-col>

            <!-- Phải: nút Xoá (sát mép phải) -->
            <a-col flex="none" style="text-align: right">
                <a-popconfirm
                    :title="`Bạn chắc chắn muốn xoá ${selectedRowKeys.length} nhiệm vụ?`"
                    ok-text="Xoá"
                    cancel-text="Hủy"
                    placement="topRight"
                    :getPopupContainer="t => t.parentNode"
                    :okButtonProps="{ danger: true, loading: deletingBulk }"
                    :cancelButtonProps="{ disabled: deletingBulk }"
                    :disabled="selectedRowKeys.length === 0"
                    @confirm="handleBulkDelete"
                >
                    <a-button
                        danger
                        type="primary"
                        :loading="deletingBulk"
                        :disabled="selectedRowKeys.length === 0 || deletingBulk"
                    >
                        Xoá {{ selectedRowKeys.length }} nhiệm vụ
                    </a-button>
                </a-popconfirm>
            </a-col>
        </a-row>

        <a-table
            :columns="columns"
            :data-source="tableData"
            :loading="loading"
            @change="handleTableChange"
            :pagination="pagination"
            :row-selection="rowSelection"
            style="margin-top: 8px;table-layout: fixed;"
            row-key="id"
            :scroll="{ x: 'max-content'}"
            class="custom_table_list_task tiny-scroll"
        >
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.dataIndex === 'title'">
                    <a-tooltip :title="text">
                        <a-typography-text
                            style="cursor: pointer; display: inline-block; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                            @click="showPopupDetail(record)">
                            {{ text }}
                        </a-typography-text>
                    </a-tooltip>
                </template>

                <template v-if="column.dataIndex === 'priority'">
                    <a-tag v-if="text" :color="checkPriority(text).color">{{ checkPriority(text).title }}</a-tag>
                </template>

                <template v-if="column.dataIndex === 'assigned_to'">
                    <a-tooltip :title="record.assignee?.name || '—'">
                        <a-avatar size="small"
                                  :style="{ backgroundColor: getAvatarColor(record.assignee?.name),verticalAlign: 'middle',cursor: 'default'}">
                            {{ record.assignee?.name?.charAt(0).toUpperCase() || '?' }}
                        </a-avatar>
                    </a-tooltip>
                </template>

                <template v-if="column.dataIndex === 'linked_type'">
                    <a-tag :color="getLinkedTypeTag(text).color" style="cursor: pointer;">
                        {{ getLinkedTypeTag(text).label }}
                    </a-tag>
                </template>

                <template v-if="column.dataIndex === 'linked_id'">
                    <a-tooltip :title="getLinkedName(record.linked_type, text)">
                        <span v-if="record.linked_type === 'bidding' || record.linked_type === 'contract'"
                              style="color: #1890ff; cursor: pointer; display: inline-block; max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                              @click="goToLinkedDetail(record)">
                          {{ getLinkedName(record.linked_type, text) }}
                        </span>
                    </a-tooltip>
                </template>

                <template v-if="column.dataIndex === 'step_info'">
                    <div class="step_info_title">
                        <a-tooltip :title="getLinkedName(record.linked_type, record.linked_id)
                          ? 'Thuộc: ' + getLinkedName(record.linked_type, record.linked_id): ''">
                        <span v-if="record.step_code" style="color: #1890ff; cursor: pointer;"
                              @click="goToLinkedDetail(record)">
                          B{{ record.step_code }} - {{ record.step_name || '—' }}
                        </span>
                            <span v-else>
                          {{ record.step_name || '—' }}
                        </span>
                        </a-tooltip>
                    </div>
                </template>

                <template v-if="column.dataIndex === 'progress'">
                    <a-progress
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
                <template v-if="column.dataIndex === 'start_date' || column.dataIndex === 'end_date'">
                    {{ formatDate(text) || '—' }}
                </template>

                <template v-if="column.dataIndex === 'deadline'">
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
                <template v-if="column.dataIndex === 'status'">
                    <a-tag :color="getStatusColor(text)">
                        {{ getStatusLabel(text) }}
                    </a-tag>
                </template>

                <template v-else-if="column.dataIndex === 'action'">
                    <a-dropdown placement="left" :trigger="['click']"
                                :getPopupContainer="triggerNode => triggerNode.parentNode">
                        <a-button>
                            <template #icon>
                                <MoreOutlined/>
                            </template>
                        </a-button>
                        <template #overlay>
                            <a-menu>
                                <a-menu-item @click="showPopupDetail(record)">
                                    <InfoCircleOutlined class="icon-action" style="color: blue;"/>
                                    Chi tiết
                                </a-menu-item>
                                <a-menu-item>
                                    <a-popconfirm
                                        title="Bạn chắc chắn muốn xóa nhiệm vụ này?"
                                        ok-text="Xóa"
                                        cancel-text="Hủy"
                                        @confirm="deleteConfirm(record.id)"
                                        placement="topRight"
                                    >
                                        <div style="width: 100%; text-align: start;">
                                            <DeleteOutlined class="icon-action" style="color: red;"/>
                                            Xóa
                                        </div>
                                    </a-popconfirm>
                                </a-menu-item>
                            </a-menu>
                        </template>
                    </a-dropdown>
                </template>

            </template>
        </a-table>
        <DrawerCreateTask
            v-model:open-drawer="openDrawer"
            :list-user="listUser"
            @submitForm="submitForm"
        />

        <!-- Drawer chứa filter chi tiết -->
        <a-drawer
            v-model:open="showFilterDrawer"
            title="Bộ lọc nâng cao"
            placement="right"
            width="600"
        >
            <a-row :gutter="[14,14]" style="margin-top: 10px;">
                <!-- Độ ưu tiên -->
                <a-form-item label="Độ ưu tiên">
                    <a-button-group style="width:100%; display:flex; gap:1px;">
                        <a-button
                            :type="dataFilter.priority === null ? 'primary' : 'default'"
                            style="flex:1"
                            @click="filterByPriority(null)"
                        >Tất cả</a-button>

                        <a-button
                            :type="dataFilter.priority === 'low' ? 'primary' : 'default'"
                            danger ghost
                            style="flex:1"
                            @click="filterByPriority('low')"
                        >Thấp</a-button>

                        <a-button
                            :type="dataFilter.priority === 'normal' ? 'primary' : 'default'"
                            style="flex:1; background:#faad14; color:#fff"
                            @click="filterByPriority('normal')"
                        >Thường</a-button>

                        <a-button
                            :type="dataFilter.priority === 'high' ? 'primary' : 'default'"
                            style="flex:1; background:#f5222d; color:#fff"
                            @click="filterByPriority('high')"
                        >Cao</a-button>
                    </a-button-group>
                </a-form-item>
                <a-col :span="24">
                    <a-input
                        v-model:value="dataFilter.title"
                        placeholder="Tìm việc theo tiêu đề"
                        allow-clear
                    />
                </a-col>

                <a-col :span="24">
                    <a-select
                        v-model:value="dataFilter.id_department"
                        :options="optionsDepartment"
                        placeholder="Chọn phòng ban"
                        :allowClear="true"
                        style="width: 100%"
                    />
                </a-col>

                <a-col :span="24">
                    <a-select
                        v-model:value="dataFilter.status"
                        :options="statusOption"
                        placeholder="Chọn trạng thái"
                        :allowClear="true"
                        style="width: 100%"
                    />
                </a-col>

                <a-col :span="24">
                    <a-select
                        v-model:value="dataFilter.assigned_to"
                        :options="optionsAssigned"
                        placeholder="Người phụ trách"
                        :allowClear="true"
                        show-search
                        option-filter-prop="label"
                        :filter-option="(input, option) =>
          normalizeText(option?.label ?? '').includes(normalizeText(input))
        "
                        :getPopupContainer="trigger => trigger.parentNode"
                        style="width: 100%"
                    />
                </a-col>

                <a-col :span="24">
                    <a-config-provider :locale="locale">
                        <a-range-picker
                            v-model:value="dateRange"
                            format="YYYY-MM-DD"
                            style="width: 100%;"
                            allowClear
                            :placeholder="['Từ ngày', 'Đến ngày']"
                            :getPopupContainer="triggerNode => triggerNode.parentNode"
                        />
                    </a-config-provider>
                </a-col>
            </a-row>

            <!-- Footer -->
            <template #footer>
                <div style="display:flex; align-items:center; justify-content:space-between; width:100%;">
                    <a-typography-text type="secondary" v-if="activeFilterCount > 0">
                        Đang áp dụng {{ activeFilterCount }} bộ lọc
                    </a-typography-text>
                    <span></span>
                    <a-space>
                        <a-button @click="resetDrawerFilters" :disabled="!hasAnyAdvancedFilter">Reset</a-button>
                        <a-button @click="showFilterDrawer = false">Đóng</a-button>
                        <a-button type="primary" @click="applyDrawerFilters">Áp dụng</a-button>
                    </a-space>
                </div>
            </template>
        </a-drawer>

    </div>
</template>

<script setup>
import {ref, onMounted, computed} from 'vue'
import {getTasks, deleteTask} from '../api/task'
import {getDepartments} from '../api/department'
import {getUsers} from '@/api/user';
import {message} from 'ant-design-vue'
import {useRoute, useRouter} from 'vue-router';
import {
    InfoCircleOutlined,
    DeleteOutlined,
    MoreOutlined,
    UnorderedListOutlined,
    FilterOutlined
} from '@ant-design/icons-vue';
import DrawerCreateTask from "../components/common/DrawerCreateTask.vue";
import viVN from 'ant-design-vue/es/locale/vi_VN';
import {debounce} from 'lodash-es'
import {formatDate} from '@/utils/formUtils'

import {getBiddingsAPI} from '@/api/bidding.js'
import {getContractsAPI} from '@/api/contract.js'

import {useUserStore} from '@/stores/user'

const userStore = useUserStore()
import {useCommonStore} from '@/stores/common';

const commonStore = useCommonStore()
const showFilterDrawer = ref(false)

// computed kiểm tra xem có đang lọc không
const hasText = (v) => ((v ?? '').toString().trim().length > 0)

const activeFilterCount = computed(() => {
    const f = dataFilter.value
    let n = 0
    if (hasText(f.title)) n++
    if (f.id_department) n++
    if (f.status) n++
    if (f.priority) n++
    if (f.assigned_to) n++
    if (f.start_date && f.end_date) n++
    return n
})

// cái này giữ nguyên để enable/disable nút Reset
const hasAnyAdvancedFilter = computed(() => {
    const f = dataFilter.value
    return (
        hasText(f.title) ||
        !!f.id_department ||
        !!f.status ||
        !!f.priority ||
        !!f.assigned_to ||
        (!!f.start_date && !!f.end_date)
    )
})

// Reset toàn bộ trường trong Drawer về mặc định
const resetDrawerFilters = () => {
    dataFilter.value.title = ''
    dataFilter.value.id_department = null
    dataFilter.value.status = null
    dataFilter.value.priority = null
    dataFilter.value.assigned_to = null
    dataFilter.value.start_date = null
    dataFilter.value.end_date = null
    dataFilter.value.linked_type = null
    dateRange.value = []
    // GIỮ nguyên dataFilter.value.linked_type (bộ lọc nhanh bên ngoài)
    applyDrawerFilters() // gọi luôn để reload
}

// Áp dụng và đóng
const applyDrawerFilters = () => {
    dataFilter.value.page = 1
    getInternalTask()
    showFilterDrawer.value = false
}

const locale = ref(viVN);
const router = useRouter()
const tableData = ref([])
const loading = ref(false)
const openDrawer = ref(false)
const listUser = ref([])
const listDepartment = ref([])
const dataFilter = ref({
    linked_type: null,
    id_department: null,
    status: null,
    priority: null,
    assigned_to: null,
    due_date: null,
    start_date: null,
    end_date: null,
    title: '',
    page: 1,
    per_page: 10
})

const selectedRowKeys = ref([])

const rowSelection = computed(() => ({
    selectedRowKeys: selectedRowKeys.value,
    onChange: (newSelectedRowKeys) => {
        selectedRowKeys.value = newSelectedRowKeys
    }
}))

const onTitleSearch = debounce(() => {
    dataFilter.value.page = 1
    getInternalTask()
}, 500)

const dateRange = ref([])
const totalTasks = computed(() => pagination.value.total)
const filteredCount = computed(() => tableData.value.length)

const getAvatarColor = (name) => {
    if (!name) return '#ccc';

    // Hash tên thành 1 số
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }

    // Tạo màu HSL từ hash
    const hue = Math.abs(hash) % 360;
    return `hsl(${hue}, 65%, 55%)`; // màu tươi sáng, đẹp
};


const onRangeChange = (dates, dateStrings) => {
    if (dateStrings[0] && dateStrings[1]) {
        dataFilter.value.start_date = dateStrings[0]
        dataFilter.value.end_date = dateStrings[1]
    } else {
        dataFilter.value.start_date = null
        dataFilter.value.end_date = null
    }
    getInternalTask()
}
const deletingBulk = ref(false)
const handleBulkDelete = async () => {
    if (deletingBulk.value || selectedRowKeys.value.length === 0) return
    deletingBulk.value = true
    try {
        await Promise.all(selectedRowKeys.value.map(id => deleteTask(id)))
        message.success(`Đã xoá ${selectedRowKeys.value.length} nhiệm vụ`)
        selectedRowKeys.value = []
        await getInternalTask()
    } catch (e) {
        message.error('Xoá hàng loạt thất bại')
    } finally {
        deletingBulk.value = false
    }
}

const filterByType = (type) => {
    dataFilter.value.linked_type = type
    getInternalTask()
}

const filterByPriority = (priority) => {
    dataFilter.value.priority = priority
    getInternalTask()
}

const optionsLinkType = computed(() => {
    return [
        {value: 'bidding', label: "Gói thầu"},
        {value: 'contract', label: "Hợp đồng"},
        {value: 'internal', label: "Nhiệm vụ nội bộ"},
    ]
})
const priorityOption = computed(() => {
    return [
        {value: 'low', label: "Thấp"},
        {value: 'normal', label: "Thường"},
        {value: 'high', label: "Cao"},
    ]
})
const statusOption = computed(() => {
    return [
        {value: 'todo', label: "Việc cần làm"},
        {value: 'doing', label: "Đang thực hiện"},
        {value: 'done', label: "Hoàn thành"},
        {value: 'overdue', label: "Quá hạn"},
    ]
})
const optionsAssigned = computed(() => {
    return listUser.value.map(ele => {
        return {value: ele.id, label: ele.name}
    })
})
const optionsDepartment = computed(() => {
    return listDepartment.value.map(ele => {
        return {value: ele.id, label: ele.name}
    })
})

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    showQuickJumper: true,
    showTotal: total => `Tổng ${total} nhiệm vụ`
})

const columns = [
    {
        title: 'STT',
        key: 'index',
        width: 50,
        align: 'center',
        fixed: 'left',
        customRender: ({index}) => {
            const cur = Number(pagination.value?.current ?? 1)
            const size = Number(pagination.value?.pageSize ?? 10)
            return (cur - 1) * size + index + 1
        }
    },
    {title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title', width: 200, ellipsis: true},
    // {title: 'Bước tiến trình', dataIndex: 'step_info', key: 'step_info', width: 200, ellipsis: true},
    {title: 'Loại Task', dataIndex: 'linked_type', key: 'linked_type'},
    // { title: 'Gói thầu || Hợp đồng', dataIndex: 'linked_id', key: 'linked_id' },
    {title: 'Độ ưu tiên', dataIndex: 'priority', key: 'priority'},
    {title: 'Người thực hiện', dataIndex: 'assigned_to', key: 'assigned_to', width: 120, align: 'center'},
    {title: 'Bắt đầu', dataIndex: 'start_date', key: 'start_date', align: 'center'},
    {title: 'Kết thúc', dataIndex: 'end_date', key: 'end_date', align: 'center'},
    {title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: 150, align: 'center'},
    {
        title: 'Hạn',
        dataIndex: 'deadline',
        key: 'deadline',
        customRender: ({record}) => {
            const overdue = record.days_overdue;
            const remaining = record.days_remaining;

            if (overdue > 0) {
                return `Quá hạn ${overdue} ngày`;
            } else if (remaining >= 0) {
                return `Còn ${remaining} ngày`;
            } else {
                return '—';
            }
        },
        align: 'center',
    },
    {
        title: 'Trạng thái',
        dataIndex: 'status',
        key: 'status',
        width: 100,
        align: 'center',
    },

    // {title: 'Hành động', dataIndex: 'action', key: 'action', width: 100, align: 'center'},
];

const changeDateTime = (day, date) => {
    if (date) {
        dataFilter.value.due_date = date;
    } else {
        dataFilter.value.due_date = "";
    }
    dataFilter.value.page = 1
    getInternalTask()
}
const getInternalTask = async () => {
    loading.value = true
    try {
        const user = userStore.currentUser;

        // Xóa filter cũ (tránh chồng chéo)
        dataFilter.value.assigned_to = null
        dataFilter.value.id_department = null

        // 👇 Phân quyền lọc theo vai trò
        const roleId = Number(user?.role_id)
        if (roleId === 3) {
            dataFilter.value.assigned_to = user.id
        } else if (roleId === 2) {
            dataFilter.value.id_department = user.department_id
        }
        // Admin không cần giới hạn

        const response = await getTasks(dataFilter.value)

        tableData.value = response.data.data ?? []

        const pg = response.data.pagination
        pagination.value = {
            ...pagination.value,
            current: pg.page,
            total: pg.total,
            pageSize: pg.per_page
        }
    } catch (e) {
        message.error('Không thể tải nhiệm vụ')
    } finally {
        loading.value = false
    }
}


const listBidding = ref([])
const listContract = ref([])

const getBiddings = async () => {
    try {
        const res = await getBiddingsAPI()
        listBidding.value = res.data.data
    } catch (e) {
        message.error('Không thể tải gói thầu')
    }
}

const getContracts = async () => {
    try {
        const res = await getContractsAPI()
        listContract.value = res.data
    } catch (e) {
        message.error('Không thể tải hợp đồng')
    }
}

const getLinkedName = (type, id) => {
    if (type === 'bidding' && Array.isArray(listBidding.value)) {
        const found = listBidding.value.find(ele => ele.id === id)
        return found ? found.title : '—'
    } else if (type === 'contract' && Array.isArray(listContract.value)) {
        const found = listContract.value.find(ele => ele.id === id)
        return found ? found.title : '—'
    }
    return '—'
}

const normalizeText = (s = '') =>
    s.toString()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()


const getLinkedTypeTag = (type) => {
    switch (type) {
        case 'bidding':
            return {label: 'Gói thầu', color: 'blue'}
        case 'contract':
            return {label: 'Hợp đồng', color: 'green'}
        case 'internal':
            return {label: 'Nội bộ', color: 'default'}
        default:
            return {label: 'Không rõ', color: 'red'}
    }
}


const goToLinkedDetail = (record) => {
    if (record.linked_type === 'bidding') {
        router.push(`/bid-detail/${record.linked_id}`)
    } else if (record.linked_type === 'contract') {
        router.push(`/contracts/${record.linked_id}`)
    }
}

const deleteConfirm = async (internalId) => {
    try {
        await deleteTask(internalId);
        await getInternalTask();
    } catch (e) {
        message.error('Xóa nhiệm vụ không thành công')
    } finally {
    }
}
const showPopupDetail = async (record) => {
    await router.push({
        name: "internal-tasks-info",
        params: {id: record.id, task_name: record.name}
    })
}

import {watch} from 'vue'

const common = useCommonStore()
const showPopupCreate = (v) => {
    commonStore.setLinkedType(v);
    // nếu cần lưu loại
    commonStore.setLinkedType && commonStore.setLinkedType(v)
    openDrawer.value = true;
}
const submitForm = () => {
    getInternalTask();
}
const checkPriority = (text) => {
    switch (text) {
        case 'low':
            return {title: "Thấp", color: "success"};
        case 'normal':
            return {title: "Thường", color: "warning"};
        case 'high':
            return {title: "Cao", color: "error"};
        default:
            return {title: "", color: ""};
    }
};

const getUserById = (userId) => {
    let data = listUser.value.find(ele => ele.id === userId);
    if (!data) {
        return "";
    }
    return data.name;
}
const getLinkedType = (text) => {
    switch (text) {
        case 'bidding':
            return "Gói thầu";
        case 'contract':
            return "Hợp đồng";
        case 'internal':
            return "Nhiệm vụ nội bộ";
        default:
            return ""
    }
}

const getUser = async () => {
    loading.value = true
    try {
        const response = await getUsers();
        listUser.value = response.data;
    } catch (e) {
        message.error('Không thể tải người dùng')
    } finally {
        loading.value = false
    }
}
const getDepartment = async () => {
    loading.value = true
    try {
        const response = await getDepartments();
        listDepartment.value = response.data;
    } catch (e) {
        message.error('Không thể tải người dùng')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (pager) => {
    dataFilter.value.page = pager.current
    dataFilter.value.per_page = pager.pageSize
    getInternalTask()
}

const getStatusColor = (status) => {
    switch (status) {
        case 'todo':
            return 'default';
        case 'doing':
            return 'blue';
        case 'done':
            return 'green';
        case 'overdue':
            return 'red';
        case 'request_approval':
            return 'orange';
        default:
            return 'default';
    }
};

const getStatusLabel = (status) => {
    switch (status) {
        case 'todo':
            return 'Chưa bắt đầu';
        case 'doing':
            return 'Đang thực hiện';
        case 'done':
            return 'Hoàn thành';
        case 'overdue':
            return 'Quá hạn';
        case 'request_approval':
            return 'Chờ phê duyệt';
        default:
            return 'Không rõ';
    }
};
// Lắng nghe tín hiệu
watch(() => common.createTaskSignal, () => {
    showPopupCreate(common.createTaskType)
})

onMounted(() => {
    getInternalTask();
    getUser();
    getDepartment();
    getBiddings()
    getContracts()
})
</script>

<style>
.custom_table_list_task td {
    white-space: normal !important;
}

.step_info_title span {
    display: inline-block;
    max-width: 200px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.custom_table_list_task table tr td {
    font-size: 13px !important;
}

table tr td a {
    font-size: 13px !important;
}

table tr td span {
    font-size: 13px !important;
}

table .ant-progress-small:where(.css-dev-only-do-not-override-3m4nqy).ant-progress-line {
    font-size: 14px !important;
}

table .ant-table-thead > tr > th {
    color: #83868c !important;
    font-weight: 400 !important;
    font-size: 12px !important;
}
</style>

<style scoped>
:deep(.ant-pagination) {
    margin-bottom: 0 !important;
}

.icon-action {
    font-size: 18px;
    margin-right: 8px;
    cursor: pointer;
}

&
:last-child {
    margin-right: 0;
}
</style>
