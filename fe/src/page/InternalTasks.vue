<template>
    <div>
        <a-card bordered>
            <a-row justify="space-between" :gutter="[12,12]">
                <a-col flex="auto">
                    <a-space wrap>
                        <!-- Lọc theo loại (chỉ Tất cả / Gói thầu / Hợp đồng) -->
                        <a-button-group>
                            <a-button
                                :type="dataFilter.linked_type === null ? 'primary' : 'default'"
                                @click="filterByType(null)"
                            >
                                Tất cả ({{ totalTasks }})
                            </a-button>
                            <a-button
                                :type="dataFilter.linked_type === 'bidding' ? 'primary' : 'default'"
                                @click="filterByType('bidding')"
                            >
                                Gói thầu
                            </a-button>
                            <a-button
                                :type="dataFilter.linked_type === 'contract' ? 'primary' : 'default'"
                                @click="filterByType('contract')"
                            >
                                Hợp đồng
                            </a-button>
                        </a-button-group>

                        <!-- Icon mở drawer filter chi tiết -->
                        <a-badge :count="activeFilterCount || null" :offset="[0,6]">
                            <a-button type="default" @click="showFilterDrawer = true">
                                <template #icon><FilterOutlined /></template>
                            </a-button>
                        </a-badge>
                    </a-space>
                </a-col>

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
                :pagination="{
                    ...pagination,
                    position: ['topRight']
                }"
                :row-selection="rowSelection"
                style="margin-top: 8px; table-layout: fixed;"
                row-key="id"
                :scroll="{ x: 'max-content'}"
                class="custom_table_list_task tiny-scroll"
            >
                <template #bodyCell="{ column, record, text }">
                    <!-- Tiêu đề -->
                    <template v-if="column.dataIndex === 'title'">
                        <div class="title-cell" @click="showPopupDetail(record)" style="cursor:pointer;">
                            <a-tooltip>
                                <template #title>
                                    <div>
                                        <div v-for="(line, i) in getTitleInfo(record).lines" :key="i">{{ line }}</div>
                                    </div>
                                </template>

                                <div class="line-1">
                                    <a-typography-text strong class="ellipsis w-200">{{ text }}</a-typography-text>
                                </div>

                                <div class="line-2" v-if="getTitleInfo(record).subline">
                                    <a-typography-text type="secondary" class="ellipsis w-260">
                                        {{ getTitleInfo(record).subline }}
                                    </a-typography-text>
                                </div>
                            </a-tooltip>
                        </div>
                    </template>

                    <!-- Ưu tiên -->
                    <template v-if="column.dataIndex === 'priority'">
                        <a-tag v-if="text" :color="checkPriority(text).color">{{ checkPriority(text).title }}</a-tag>
                    </template>

                    <!-- Người thực hiện -->
                    <template v-if="column.dataIndex === 'assigned_to'">
                        <a-tooltip :title="record.assignee?.name || '—'">
                            <a-avatar
                                size="small"
                                :style="{ backgroundColor: getAvatarColor(record.assignee?.name), verticalAlign: 'middle', cursor: 'default' }"
                            >
                                {{ record.assignee?.name?.charAt(0).toUpperCase() || '?' }}
                            </a-avatar>
                        </a-tooltip>
                    </template>

                    <!-- Loại Task -->
                    <template v-if="column.dataIndex === 'linked_type'">
                        <a-tag :color="getLinkedTypeTag(text).color" style="cursor: pointer;">
                            {{ getLinkedTypeTag(text).label }}
                        </a-tag>
                    </template>

                    <!-- Tiến độ -->
                    <template v-if="column.dataIndex === 'progress'">
                        <a-progress
                            :percent="Number(record.progress)"
                            :stroke-color="{ '0%': '#108ee9', '100%': '#87d068'}"
                            :status="record.progress >= 100 ? 'success' : 'active'"
                            size="small"
                            :show-info="true"
                        />
                    </template>

                    <!-- Bắt đầu / Kết thúc -->
                    <template v-if="column.dataIndex === 'start_date' || column.dataIndex === 'end_date'">
                        {{ formatDate(text) || '—' }}
                    </template>

                    <!-- Deadline -->
                    <template v-if="column.dataIndex === 'deadline'">
                        <template v-if="calculateDeadline(record.end_date).overdue > 0">
                            <a-tag color="error">
                                Quá hạn {{ calculateDeadline(record.end_date).overdue }} ngày
                            </a-tag>
                        </template>

                        <template v-else-if="calculateDeadline(record.end_date).remaining > 0">
                            <a-tag color="green">
                                Còn {{ calculateDeadline(record.end_date).remaining }} ngày
                            </a-tag>
                        </template>

                        <template v-else-if="calculateDeadline(record.end_date).remaining === 0">
                            <a-tag color="#faad14">Hạn chót hôm nay</a-tag>
                        </template>

                        <template v-else>
                            <a-tag>—</a-tag>
                        </template>
                    </template>


                    <!-- Trạng thái -->
                    <template v-if="column.dataIndex === 'status'">
                        <a-tag :color="getStatusColor(text)">
                            {{ getStatusLabel(text) }}
                        </a-tag>
                    </template>

                    <!-- Actions -->
                    <template v-else-if="column.dataIndex === 'action'">
                        <div class="action-icons">

                            <!-- Cấp quyền -->
                            <a-tooltip title="Cấp quyền truy cập gói thầu">
                                <UserAddOutlined
                                    v-if="canManageMembers(record)"
                                    class="icon-action"
                                    style="color:#722ed1;"
                                    @click="openMemberModal(record)"
                                />
                            </a-tooltip>

                            <!-- Chi tiết -->
                            <a-tooltip title="Chi tiết">
                                <InfoCircleOutlined
                                    class="icon-action"
                                    style="color: blue;"
                                    @click="showPopupDetail(record)"
                                />
                            </a-tooltip>

                            <!-- Xóa -->
                            <a-popconfirm
                                title="Bạn chắc chắn muốn xóa nhiệm vụ này?"
                                ok-text="Xóa"
                                cancel-text="Hủy"
                                @confirm="deleteConfirm(record.id)"
                            >
                                <a-tooltip title="Xóa">
                                    <DeleteOutlined
                                        class="icon-action"
                                        style="color:red; cursor:pointer;"
                                    />
                                </a-tooltip>
                            </a-popconfirm>

                        </div>
                    </template>
                </template>
            </a-table>
        </a-card>

        <EntityMemberManager
            v-model:open="memberModalVisible"
            :entityType="activeEntityType"
            :entityId="activeEntityId"
            :entityData="activeEntityData"
            @saved="fetchTasks"
        />


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
                <a-form-item label="Ưu tiên">
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
                        :filter-option="(input, option) => normalizeText(option?.label ?? '').includes(normalizeText(input))"
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
                            @change="onRangeChange"
                        />
                    </a-config-provider>
                </a-col>
            </a-row>

            <template #footer>
                <div style="display:flex; align-items:center; justify-content:space-between; width:100%;">
                    <a-typography-text type="secondary" v-if="activeFilterCount > 0">
                        Đang áp dụng {{ activeFilterCount }} bộ lọc
                    </a-typography-text>
                    <span></span>
                    <a-space>
                        <a-button type="primary" @click="applyDrawerFilters">Áp dụng</a-button>
                        <a-button @click="resetDrawerFilters" :disabled="!hasAnyAdvancedFilter">Reset</a-button>
                        <a-button @click="showFilterDrawer = false">Đóng</a-button>
                    </a-space>
                </div>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { getTasks, deleteTask } from '../api/task'
import { getDepartments } from '../api/department'
import { getUsers } from '@/api/user'
import { message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import {
    InfoCircleOutlined,
    DeleteOutlined,
    UserAddOutlined,
    FilterOutlined
} from '@ant-design/icons-vue'
import DrawerCreateTask from '../components/common/DrawerCreateTask.vue'
import viVN from 'ant-design-vue/es/locale/vi_VN'
import { formatDate } from '@/utils/formUtils'
import { getBiddingsAPI } from '@/api/bidding.js'
import { getContractsAPI } from '@/api/contract.js'
import { useUserStore } from '@/stores/user'
import { useCommonStore } from '@/stores/common'

// ✅ Chỉ cho phép 2 loại (không còn 'internal')
const TYPES_IN_SCOPE = ['bidding', 'contract']

const userStore = useUserStore()
const commonStore = useCommonStore()
const router = useRouter()

const showFilterDrawer = ref(false)
const loading = ref(false)
const openDrawer = ref(false)

const tableData = ref([])
const listUser = ref([])
const listDepartment = ref([])
const listBidding = ref([])
const listContract = ref([])
const locale = ref(viVN)
const dateRange = ref([])
const showMemberModal = ref(false)
const selectedEntityId = ref(null)
const selectedEntityData = ref(null)

// ⭐ khai báo biến dùng cho modal cấp quyền
const memberModalVisible = ref(false);
const activeEntityId = ref(null);
const activeEntityData = ref(null);
const activeEntityType = ref(null)

import { useEntityAccess } from "@/utils/openEntityDetail";
import EntityMemberManager from "@/components/common/EntityMemberManager.vue";
import {getBiddingById, getContractById} from "@/api/entityMembers.js";
const { openEntity } = useEntityAccess();


const dataFilter = ref({
    linked_type: null, // null = Tất cả (bidding + contract)
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
    onChange: (newSelectedRowKeys) => { selectedRowKeys.value = newSelectedRowKeys }
}))

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    showQuickJumper: true,
    showTotal: total => `Tổng ${total} nhiệm vụ`
})
const totalTasks = computed(() => pagination.value.total)

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

const optionsAssigned = computed(() => listUser.value.map(ele => ({ value: ele.id, label: ele.name })))
const optionsDepartment = computed(() => listDepartment.value.map(ele => ({ value: ele.id, label: ele.name })))

const statusOption = [
    { value: 'todo', label: 'Chưa bắt đầu' },
    { value: 'doing', label: 'Đang thực hiện' },
    { value: 'done', label: 'Hoàn thành' },
    { value: 'overdue', label: 'Quá hạn' },
    { value: 'request_approval', label: 'Chờ phê duyệt' }
]

const columns = [
    { title: 'STT', key: 'index', width: 50, align: 'center', fixed: 'left',
        customRender: ({ index }) => {
            const cur = Number(pagination.value?.current ?? 1)
            const size = Number(pagination.value?.pageSize ?? 10)
            return (cur - 1) * size + index + 1
        }
    },
    { title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title', width: 200, ellipsis: true },
    { title: 'Loại Task', dataIndex: 'linked_type', key: 'linked_type' },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority' },
    { title: 'Người thực hiện', dataIndex: 'assigned_to', key: 'assigned_to', width: 200, align: 'center' },
    { title: 'Bắt đầu', dataIndex: 'start_date', key: 'start_date', align: 'center' },
    { title: 'Kết thúc', dataIndex: 'end_date', key: 'end_date', align: 'center' },
    { title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: 150, align: 'center' },
    { title: 'Hạn', dataIndex: 'deadline', key: 'deadline', align: 'center',
        customRender: ({ record }) => {
            const overdue = record.days_overdue
            const remaining = record.days_remaining
            if (overdue > 0) return `Quá hạn ${overdue} ngày`
            else if (remaining >= 0) return `Còn ${remaining} ngày`
            else return '—'
        }
    },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 100, align: 'center' },
    { title: 'Thao tác', dataIndex: 'action', key: 'action', width: 200, align: 'center' }
]

// ===== Helpers =====
const normalizeText = (s = '') =>
    s.toString().normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()

const getAvatarColor = (name) => {
    if (!name) return '#ccc'
    let hash = 0
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash)
    }
    const hue = Math.abs(hash) % 360
    return `hsl(${hue}, 65%, 55%)`
}

const checkPriority = (text) => {
    switch (text) {
        case 'low': return { title: 'Thấp', color: 'success' }
        case 'normal': return { title: 'Thường', color: 'warning' }
        case 'high': return { title: 'Cao', color: 'error' }
        default: return { title: '', color: '' }
    }
}

const getStatusColor = (status) => {
    switch (status) {
        case 'todo': return 'default'
        case 'doing': return 'blue'
        case 'done': return 'green'
        case 'overdue': return 'red'
        case 'request_approval': return 'orange'
        default: return 'default'
    }
}
const getStatusLabel = (status) => {
    switch (status) {
        case 'todo': return 'Chưa bắt đầu'
        case 'doing': return 'Đang thực hiện'
        case 'done': return 'Hoàn thành'
        case 'overdue': return 'Quá hạn'
        case 'request_approval': return 'Chờ phê duyệt'
        default: return 'Không rõ'
    }
}

const getLinkedTypeTag = (type) => {
    switch (type) {
        case 'bidding': return { label: 'Gói thầu', color: 'blue' }
        case 'contract': return { label: 'Hợp đồng', color: 'green' }
        default: return { label: 'Không rõ', color: 'red' }
    }
}

const getTitleInfo = (r = {}) => {
    const bits = []
    if (r.parent_id && r.parent_title) bits.push(`Việc cha: ${r.parent_title}`)
    if (r.linked_type === 'bidding' && r.linked_title) bits.push(`Gói thầu: ${r.linked_title}`)
    else if (r.linked_type === 'contract' && r.linked_title) bits.push(`Hợp đồng: ${r.linked_title}`)
    if (r.step_name) bits.push(`Bước: ${r.step_name}`)
    const subline = bits.join(' · ')
    const lines = [r.title || '', ...bits]
    return { subline, lines }
}

const openMemberModal = async (record) => {
    activeEntityType.value = record.linked_type;

    // Lấy id thực gốc của entity
    activeEntityId.value = Number(record.linked_id);

    // GỌI API lấy thông tin entity (gói thầu hoặc hợp đồng)
    let entityInfo = null;

    if (record.linked_type === "bidding") {
        const res = await getBiddingById(activeEntityId.value);
        entityInfo = res.data.data;
    }
    else if (record.linked_type === "contract") {
        const res = await getContractById(activeEntityId.value);
        entityInfo = res.data.data;
    }

    // Lưu xuống FE để modal hiển thị
    activeEntityData.value = entityInfo;

    memberModalVisible.value = true;
};




const canManageMembers = (record) => {
    const uid = userStore.currentUser?.id
    return userStore.currentUser?.is_admin || record.created_by === uid
}


// ===== Filters / Actions =====
const filterByType = (type) => {
    dataFilter.value.linked_type = type // null | 'bidding' | 'contract'
    fetchTasks()
}
const filterByPriority = (priority) => {
    dataFilter.value.priority = priority
    fetchTasks()
}

const resetDrawerFilters = () => {
    dataFilter.value.title = ''
    dataFilter.value.id_department = null
    dataFilter.value.status = null
    dataFilter.value.priority = null
    dataFilter.value.assigned_to = null
    dataFilter.value.start_date = null
    dataFilter.value.end_date = null
    dateRange.value = []
    applyDrawerFilters()
}
const applyDrawerFilters = () => {
    dataFilter.value.page = 1
    fetchTasks()
    showFilterDrawer.value = false
}

const handleTableChange = (pager) => {
    dataFilter.value.page = pager.current
    dataFilter.value.per_page = pager.pageSize
    fetchTasks()
}

const deletingBulk = ref(false)
const handleBulkDelete = async () => {
    if (deletingBulk.value || selectedRowKeys.value.length === 0) return
    deletingBulk.value = true
    try {
        await Promise.all(selectedRowKeys.value.map(id => deleteTask(id)))
        message.success(`Đã xoá ${selectedRowKeys.value.length} nhiệm vụ`)
        selectedRowKeys.value = []
        await fetchTasks()
    } catch {
        message.error('Xoá hàng loạt thất bại')
    } finally {
        deletingBulk.value = false
    }
}

const deleteConfirm = async (id) => {
    try {
        await deleteTask(id)
        await fetchTasks()
    } catch {
        message.error('Xóa nhiệm vụ không thành công')
    }
}

const showPopupDetail = (record) => {
    const entityType = record.linked_type;   // bidding | contract | null
    const entityId   = record.linked_id;     // id thực của entity

    if (!entityType || !entityId) {
        message.error("Nhiệm vụ này không thuộc gói thầu/hợp đồng.");
        return router.push({ name: 'workflow-task-info', params: { id: record.id } });
    }

    openEntity(entityType, entityId, "workflow-task-info");
};

// ===== API helpers =====
const onRangeChange = (dates, dateStrings) => {
    if (dateStrings[0] && dateStrings[1]) {
        dataFilter.value.start_date = dateStrings[0]
        dataFilter.value.end_date = dateStrings[1]
    } else {
        dataFilter.value.start_date = null
        dataFilter.value.end_date = null
    }
    fetchTasks()
}

// Payload: nếu không chọn loại → gửi cả 2 (qua mảng linked_type_in nếu BE hỗ trợ)
const buildTaskQuery = () => {
    const f = { ...dataFilter.value }

    // 1. Linked type
    if (!f.linked_type) {
        delete f.linked_type
    }

    // 2. Department
    if (f.id_department) {
        f.department_id = Number(f.id_department)
    }
    delete f.id_department

    // 3. Search by title
    if (f.title && f.title.trim() !== "") {
        f.search = f.title.trim()
    }
    delete f.title

    // 4. Convert assigned_to
    if (f.assigned_to) {
        f.assigned_to = Number(f.assigned_to)
    }

    // 5. start_date & end_date giữ nguyên (BE hỗ trợ)

    return f
}


// Lấy tổng đúng cho scope hiện tại (không dính internal)
const fetchScopeTotal = async (basePayload) => {
    try {
        if (basePayload.linked_type === 'bidding' || basePayload.linked_type === 'contract') {
            const res = await getTasks({ ...basePayload, page: 1, per_page: 1 })
            return res?.data?.pagination?.total ?? 0
        } else {
            // Tất cả: cộng tổng bidding + contract
            const [rb, rc] = await Promise.all([
                getTasks({ ...basePayload, linked_type: 'bidding', page: 1, per_page: 1 }),
                getTasks({ ...basePayload, linked_type: 'contract', page: 1, per_page: 1 })
            ])
            const tb = rb?.data?.pagination?.total ?? 0
            const tc = rc?.data?.pagination?.total ?? 0
            return tb + tc
        }
    } catch {
        // fallback: dùng số row hiện tại
        return tableData.value.length
    }
}

const fetchTasks = async () => {
    loading.value = true
    try {
        const payload = buildTaskQuery()
        const response = await getTasks(payload)

        let rows = response?.data?.data ?? []


        tableData.value = rows

        const pg = response?.data?.pagination ?? {}

        pagination.value = {
            ...pagination.value,
            current: pg.page ?? 1,
            pageSize: pg.per_page ?? pagination.value.pageSize,
            total: pg.total ?? rows.length
        }

    } catch (e) {
        console.error(e)
        message.error('Không thể tải nhiệm vụ')
    } finally {
        loading.value = false
    }
}


const getUser = async () => {
    try {
        const response = await getUsers()
        listUser.value = response.data
    } catch {
        message.error('Không thể tải người dùng')
    }
}
const getDepartment = async () => {
    try {
        const response = await getDepartments()
        listDepartment.value = response.data
    } catch {
        message.error('Không thể tải phòng ban')
    }
}
const getBiddings = async () => {
    try {
        const res = await getBiddingsAPI()
        listBidding.value = res.data.data
    } catch {
        message.error('Không thể tải gói thầu')
    }
}
const getContracts = async () => {
    try {
        const res = await getContractsAPI()
        listContract.value = res.data
    } catch {
        message.error('Không thể tải hợp đồng')
    }
}

const calculateDeadline = (endDate) => {
    if (!endDate) return { overdue: null, remaining: null }

    const today = new Date()
    const end = new Date(endDate)

    const diff = Math.floor((end - today) / (1000 * 60 * 60 * 24))

    if (diff < 0) return { overdue: Math.abs(diff), remaining: null }
    if (diff === 0) return { overdue: 0, remaining: 0 }
    return { overdue: 0, remaining: diff }
}


const submitForm = () => { fetchTasks() }

watch(() => commonStore.createTaskSignal, () => {
    openDrawer.value = true
})

onMounted(() => {
    fetchTasks()
    getUser()
    getDepartment()
    getBiddings()
    getContracts()
})
</script>



<style>
/* có thể để trong <style scoped> của bạn */
.ellipsis { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: inline-block; vertical-align: bottom; }
.w-200 { max-width: 200px; }
.w-260 { max-width: 260px; }
.line-1 { display: flex; gap: 6px; align-items: center; }
.line-2 { margin-top: 2px; }

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
    font-size: 14px !important;
}

table tr td a {
    font-size: 14px !important;
}

table tr td span {
    font-size: 14px !important;
}

table .ant-progress-small {
    font-size: 14px !important;
}

table .ant-table-thead > tr > th {
    color: #000000 !important;
    font-weight: 500 !important;
    font-size: 14px !important;
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

& :last-child {
    margin-right: 0;
}

.action-icons {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px; /* chỉnh khoảng cách icon */
}

.icon-action {
    font-size: 18px;
    cursor: pointer;
}

</style>
