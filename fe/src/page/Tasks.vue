<template>
    <div>
        <a-card bordered>
            <a-row justify="space-between" :gutter="[12,12]">
                <a-col flex="auto">
                    <a-space>
                        <!-- Nhóm thông tin / bộ đếm -->
                        <a-typography-text type="secondary">
                            Tổng {{ totalTasks }} nhiệm vụ
                        </a-typography-text>

                        <!-- Icon mở drawer filter chi tiết -->
                        <a-badge :count="activeFilterCount || null" :offset="[0,6]">
                            <a-button type="default" @click="showFilterDrawer = true">
                                <template #icon><FilterOutlined /></template>
                                Bộ lọc
                            </a-button>
                        </a-badge>
                    </a-space>
                </a-col>

                <a-col flex="none" style="text-align:right">
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
                style="margin-top:8px; table-layout:fixed;"
                row-key="id"
                :scroll="{ x: 'max-content' }"
                class="custom_table_list_task tiny-scroll"
            >
                <template #bodyCell="{ column, record, index, text }">
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
                                :style="{ backgroundColor: getAvatarColor(record.assignee?.name), verticalAlign:'middle', cursor:'default' }"
                            >
                                {{ record.assignee?.name?.charAt(0).toUpperCase() || '?' }}
                            </a-avatar>
                        </a-tooltip>
                    </template>

                    <!-- Tiến độ -->
                    <template v-if="column.dataIndex === 'progress'">
                        <a-progress
                            :percent="Number(record.progress)"
                            :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"
                            :status="record.progress >= 100 ? 'success' : 'active'"
                            size="small"
                            :show-info="true"
                        />
                    </template>

                    <!-- Ngày bắt đầu/kết thúc -->
                    <template v-if="column.dataIndex === 'start_date' || column.dataIndex === 'end_date'">
                        {{ formatDate(text) || '—' }}
                    </template>

                    <!-- Deadline -->
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
                        <a-tag v-else>—</a-tag>
                    </template>

                    <!-- Trạng thái -->
                    <template v-if="column.dataIndex === 'status'">
                        <a-tag :color="getStatusColor(text)">
                            {{ getStatusLabel(text) }}
                        </a-tag>
                    </template>

                    <!-- Actions -->
                    <template v-else-if="column.dataIndex === 'action'">
                        <a-dropdown placement="left" :trigger="['click']" :getPopupContainer="n => n.parentNode">
                            <a-button>
                                <template #icon><MoreOutlined /></template>
                            </a-button>
                            <template #overlay>
                                <a-menu>
                                    <a-menu-item @click="showPopupDetail(record)">
                                        <InfoCircleOutlined class="icon-action" style="color: blue;" />
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
                                            <div style="width:100%; text-align:start;">
                                                <DeleteOutlined class="icon-action" style="color: red;" />
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
        </a-card>

        <!-- Drawer Create (nếu bạn muốn tạo task nhanh, giữ lại như InternalTasks.vue) -->
        <DrawerCreateTask
            v-model:open-drawer="openDrawer"
            :list-user="listUser"
            @submitForm="submitForm"
        />

        <!-- Drawer lọc nâng cao -->
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
                            :getPopupContainer="n => n.parentNode"
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
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import {
    InfoCircleOutlined,
    DeleteOutlined,
    MoreOutlined,
    FilterOutlined
} from '@ant-design/icons-vue'

import DrawerCreateTask from '@/components/common/DrawerCreateTask.vue'
import viVN from 'ant-design-vue/es/locale/vi_VN'
import { formatDate } from '@/utils/formUtils'

import { getTasks, deleteTask } from '@/api/task'
import { getDepartments } from '@/api/department'
import { getUsers } from '@/api/user'

import { useUserStore } from '@/stores/user'
import { useCommonStore } from '@/stores/common'

const userStore = useUserStore()
const commonStore = useCommonStore()
const router = useRouter()

const showFilterDrawer = ref(false)
const loading = ref(false)
const openDrawer = ref(false)

const tableData = ref([])
const listUser = ref([])
const listDepartment = ref([])

const locale = ref(viVN)
const dateRange = ref([])

const dataFilter = ref({
    linked_type: 'internal', // ✅ cố định nội bộ
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
    onChange: (keys) => { selectedRowKeys.value = keys }
}))

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
    showSizeChanger: true,
    showQuickJumper: true,
    showTotal: t => `Tổng ${t} nhiệm vụ`
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

const optionsAssigned = computed(() =>
    listUser.value.map(u => ({ value: u.id, label: u.name }))
)
const optionsDepartment = computed(() =>
    listDepartment.value.map(d => ({ value: d.id, label: d.name }))
)

const columns = [
    {
        title: 'STT',
        key: 'index',
        width: 50,
        align: 'center',
        fixed: 'left',
        customRender: ({ index }) => {
            const cur = Number(pagination.value?.current ?? 1)
            const size = Number(pagination.value?.pageSize ?? 10)
            return (cur - 1) * size + index + 1
        }
    },
    { title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title', width: 200, ellipsis: true },
    { title: 'Ưu tiên', dataIndex: 'priority', key: 'priority' },
    { title: 'Người thực hiện', dataIndex: 'assigned_to', key: 'assigned_to', width: 120, align: 'center' },
    { title: 'Bắt đầu', dataIndex: 'start_date', key: 'start_date', align: 'center' },
    { title: 'Kết thúc', dataIndex: 'end_date', key: 'end_date', align: 'center' },
    { title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: 150, align: 'center' },
    {
        title: 'Hạn',
        dataIndex: 'deadline',
        key: 'deadline',
        align: 'center',
        customRender: ({ record }) => {
            const o = record.days_overdue
            const r = record.days_remaining
            if (o > 0) return `Quá hạn ${o} ngày`
            else if (r >= 0) return `Còn ${r} ngày`
            else return '—'
        }
    },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 100, align: 'center' },
    { title: 'Thao tác', dataIndex: 'action', key: 'action', width: 80, align: 'center' }
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
        case 'low': return { title: 'Thấp',   color: 'success' }
        case 'normal': return { title: 'Thường', color: 'warning' }
        case 'high': return { title: 'Cao',    color: 'error' }
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

// Thông tin phụ cho tooltip title
const getTitleInfo = (r = {}) => {
    const bits = []
    if (r.parent_id && r.parent_title) bits.push(`Việc cha: ${r.parent_title}`)
    if (r.step_name) bits.push(`Bước: ${r.step_name}`) // nếu task nội bộ có bước, sẽ hiện
    const subline = bits.join(' · ')
    const lines = [ r.title || '', ...bits ]
    return { subline, lines }
}

// ===== Filters / Actions =====
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
    dataFilter.value.linked_type = 'internal' // ✅ cố định lại
    dateRange.value = []
    applyDrawerFilters()
}

const applyDrawerFilters = () => {
    dataFilter.value.page = 1
    fetchTasks()
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

const showPopupDetail = async (record) => {
    await router.push({
        name: 'tasks-detail', // 👈 Đặt name route cho trang chi tiết "việc không quy trình" của bạn
        params: { id: record.id }
    })
}


// Payload ép chỉ nội bộ, ép kiểu số, fallback theo role
const buildTaskQuery = () => {
    const f = { ...dataFilter.value }

    // ép cứng nội bộ
    f.linked_type = 'internal'

    if (f.id_department !== null && f.id_department !== undefined && f.id_department !== '') {
        f.id_department = Number(f.id_department)
    }
    if (f.assigned_to !== null && f.assigned_to !== undefined && f.assigned_to !== '') {
        f.assigned_to = Number(f.assigned_to)
    }
    if (f.id_department && !f.department_id) {
        f.department_id = f.id_department
    }

    // fallback role nếu chưa chọn người/phòng ban
    if (!f.assigned_to && !f.id_department) {
        const user = userStore.currentUser
        const roleId = Number(user?.role_id)
        if (roleId === 3) f.assigned_to = Number(user.id)
        else if (roleId === 2) f.id_department = Number(user.department_id)
    }

    return f
}

const fetchTasks = async () => {
    loading.value = true
    try {
        const payload = buildTaskQuery()
        const res = await getTasks(payload)
        tableData.value = res?.data?.data ?? []
        const pg = res?.data?.pagination ?? {}
        pagination.value = {
            ...pagination.value,
            current: pg.page ?? 1,
            total: pg.total ?? 0,
            pageSize: pg.per_page ?? pagination.value.pageSize
        }
    } catch {
        message.error('Không thể tải nhiệm vụ')
    } finally {
        loading.value = false
    }
}

const getUser = async () => {
    try {
        const { data } = await getUsers()
        listUser.value = data
    } catch {
        message.error('Không thể tải người dùng')
    }
}
const getDepartment = async () => {
    try {
        const { data } = await getDepartments()
        listDepartment.value = data
    } catch {
        message.error('Không thể tải phòng ban')
    }
}

const submitForm = () => { fetchTasks() }

// Lắng nghe tín hiệu mở tạo task nhanh từ store chung (nếu có)
import { watch } from 'vue'
watch(() => commonStore.createTaskSignal, () => {
    openDrawer.value = true
})

onMounted(() => {
    fetchTasks()
    getUser()
    getDepartment()
})
</script>

<style>
.ellipsis { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: inline-block; vertical-align: bottom; }
.w-200 { max-width: 200px; }
.w-260 { max-width: 260px; }
.line-1 { display: flex; gap: 6px; align-items: center; }
.line-2 { margin-top: 2px; }

.custom_table_list_task td { white-space: normal !important; }
.custom_table_list_task table tr td { font-size: 14px !important; }
table tr td a { font-size: 14px !important; }
table tr td span { font-size: 14px !important; }
table .ant-progress-small { font-size: 14px !important; }
table .ant-table-thead > tr > th { color: #83868c !important; font-weight: 400 !important; font-size: 14px !important; }
</style>

<style scoped>
:deep(.ant-pagination) { margin-bottom: 0 !important; }
.icon-action { font-size: 18px; margin-right: 8px; cursor: pointer; }
</style>
