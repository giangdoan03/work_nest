<template>
    <div>
        <a-card bordered>
            <!-- Toolbar -->
            <div class="card-title">
                <a-typography-title :level="4" class="title">Danh sách phòng ban</a-typography-title>
                <div class="toolbar">
                    <a-input
                        v-model:value="searchTerm"
                        allow-clear
                        style="width: 260px"
                        placeholder="Tìm theo tên hoặc mô tả…"
                    >
                        <template #prefix><SearchOutlined /></template>
                    </a-input>

                    <a-segmented
                        v-model:value="density"
                        :options="[
              { label: 'Gọn', value: 'small' },
              { label: 'Vừa', value: 'middle' },
              { label: 'Rộng', value: 'large' }
            ]"
                    />

                    <a-tooltip title="Làm mới">
                        <a-button :loading="loading" @click="refresh" :icon="h(ReloadOutlined)" />
                    </a-tooltip>

                    <a-button type="primary" :icon="h(PlusOutlined)" @click="showPopupCreate">Thêm phòng ban mới</a-button>
                </div>
            </div>

            <!-- Table -->
            <a-table
                :columns="columns"
                :data-source="filteredData"
                :loading="loading"
                :size="density"
                row-key="id"
                bordered
                :scroll="{ y: 'calc(100vh - 360px)' }"
                :pagination="pagination"
                @change="onTableChange"
            >
                <template #bodyCell="{ column, record, index, text }">
                    <template v-if="column.dataIndex === 'stt'">
                        {{ (pagination.current - 1) * pagination.pageSize + index + 1 }}
                    </template>

                    <template v-else-if="column.dataIndex === 'name'">
                        <a-typography-text
                            strong
                            :style="{
                cursor: 'pointer',
                color: activeDepartmentId === record.id ? 'var(--brand, #fa541c)' : undefined,
                textDecoration: activeDepartmentId === record.id ? 'underline' : undefined
              }"
                            @click="openUsersTab(record)"
                        >
                            {{ text }}
                        </a-typography-text>
                    </template>

                    <template v-else-if="column.dataIndex === 'description'">
                        <a-tooltip :title="text" placement="topLeft">
                            <span class="ellipsis-1">{{ text || '—' }}</span>
                        </a-tooltip>
                    </template>

                    <template v-else-if="column.dataIndex === 'created_at'">
                        <span :title="formatFull(text)">{{ formatDate(text) }} · <span class="muted">{{ fromNow(text) }}</span></span>
                    </template>

                    <template v-else-if="column.dataIndex === 'updated_at'">
                        <span :title="formatFull(text)">{{ formatDate(text) }} · <span class="muted">{{ fromNow(text) }}</span></span>
                    </template>

                    <template v-else-if="column.dataIndex === 'action'">
                        <a-dropdown trigger="click" placement="bottomRight">
                            <a-button type="text" :icon="h(MoreOutlined)" />
                            <template #overlay>
                                <a-menu @click.stop>
                                    <a-menu-item @click="openUsersTab(record)">
                                        <EyeOutlined class="mr-6" /> Xem chi tiết
                                    </a-menu-item>
                                    <a-menu-item @click="showPopupDetail(record)">
                                        <EditOutlined class="mr-6" /> Chỉnh sửa
                                    </a-menu-item>
                                    <a-menu-item danger>
                                        <a-popconfirm
                                            title="Xóa phòng ban này?"
                                            ok-text="Xóa"
                                            cancel-text="Hủy"
                                            @confirm="deleteConfirm(record.id)"
                                        >
                                            <span><DeleteOutlined class="mr-6" /> Xóa</span>
                                        </a-popconfirm>
                                    </a-menu-item>
                                </a-menu>
                            </template>
                        </a-dropdown>
                    </template>
                </template>
            </a-table>
        </a-card>

        <!-- Drawer với Tabs -->
        <a-drawer
            :title="drawerTitle"
            :width="860"
            :open="openDrawer"
            :body-style="{ paddingBottom: '80px' }"
            @close="onCloseDrawer"
        >
            <a-tabs v-model:activeKey="activeTab" animated>
                <a-tab-pane key="info" tab="Thông tin">
                    <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                        <a-form-item label="Tên phòng ban" name="name">
                            <a-input v-model:value="formData.name" placeholder="Nhập tên phòng ban" />
                        </a-form-item>
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" :rows="6" placeholder="Nhập mô tả" />
                        </a-form-item>
                    </a-form>
                </a-tab-pane>

                <a-tab-pane key="users" tab="Người dùng">
                    <a-skeleton :loading="loadingUsers" active :paragraph="{ rows: 5 }">
                        <a-table
                            :columns="userColumns"
                            :data-source="departmentUsers"
                            row-key="id"
                            size="small"
                            bordered
                            :locale="{ emptyText: 'Chưa có người dùng' }"
                        >
                            <template #bodyCell="{ column, record, index }">
                                <template v-if="column.key === 'stt'">{{ index + 1 }}</template>
                                <template v-else-if="column.key === 'name'">
                                    <div class="user-cell">
                                        <BaseAvatar :src="record.avatar" :name="record.name" :size="28" shape="circle" :preferApiOrigin="true" />
                                        <span>{{ record.name }}</span>
                                    </div>
                                </template>
                                <template v-else-if="column.key === 'email'">{{ record.email || '—' }}</template>
                                <template v-else-if="column.key === 'phone'">{{ record.phone || '—' }}</template>
                                <template v-else-if="column.key === 'role'">{{ getRoleName(record.role_id) }}</template>
                            </template>
                        </a-table>
                    </a-skeleton>
                </a-tab-pane>
            </a-tabs>

            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" :loading="loadingCreate" @click="submitDepartment">
                        {{ selectedDepartment ? 'Cập nhật' : 'Thêm mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, h } from 'vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/vi'
dayjs.extend(relativeTime); dayjs.locale('vi')

import { message } from 'ant-design-vue'
import {
    EditOutlined, DeleteOutlined, EyeOutlined, MoreOutlined,
    PlusOutlined, SearchOutlined, ReloadOutlined
} from '@ant-design/icons-vue'

import {
    getDepartments, createDepartment, updateDepartment, deleteDepartment
} from '../api/department'
import { getUsers } from '../api/user'
import { getRoles } from '../api/permission'
import BaseAvatar from '@/components/common/BaseAvatar.vue'

/* ===== State ===== */
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const density = ref('middle') // small | middle | large
const searchTerm = ref('')

const selectedDepartment = ref(null)
const openDrawer = ref(false)
const activeTab = ref('info')

const formRef = ref(null)
const formData = ref({ name: '', description: '' })

const departmentUsers = ref([])
const loadingUsers = ref(false)

const roles = ref([])
const activeDepartmentId = ref(null)

/* ===== Columns ===== */
const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: 70, align: 'center', fixed: 'left' },
    { title: 'Tên phòng ban', dataIndex: 'name', key: 'name', width: 280, ellipsis: true },
    { title: 'Mô tả', dataIndex: 'description', key: 'description', ellipsis: true },
    {
        title: 'Thời gian tạo', dataIndex: 'created_at', key: 'created_at', width: 200,
        sorter: (a,b) => new Date(a.created_at) - new Date(b.created_at)
    },
    {
        title: 'Cập nhật gần nhất', dataIndex: 'updated_at', key: 'updated_at', width: 200,
        sorter: (a,b) => new Date(a.updated_at) - new Date(b.updated_at)
    },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: 100, align: 'center', fixed: 'right' },
]

const userColumns = [
    { title: 'STT', key: 'stt', width: 70, align: 'center' },
    { title: 'Họ tên', key: 'name', width: 260 },
    { title: 'Email', key: 'email', width: 220 },
    { title: 'Số điện thoại', key: 'phone', width: 140 },
    { title: 'Vai trò', key: 'role', width: 160 }
]

/* ===== Pagination / filtering ===== */
const pagination = ref({
    current: 1,
    pageSize: 10,
    showSizeChanger: true,
    pageSizeOptions: ['10','20','50'],
    showTotal: (total, range) => `${range[0]}–${range[1]} / ${total}`
})

const filteredData = computed(() => {
    const q = searchTerm.value.trim().toLowerCase()
    if (!q) return tableData.value
    return tableData.value.filter(it => {
        const name = (it.name || '').toLowerCase()
        const desc = (it.description || '').toLowerCase()
        return name.includes(q) || desc.includes(q)
    })
})

const onTableChange = (pag, _filters, _sorter) => {
    pagination.value = { ...pagination.value, current: pag.current, pageSize: pag.pageSize }
}

/* ===== Utils ===== */
const formatDate = (v) => v ? dayjs(v).format('DD/MM/YYYY HH:mm') : '—'
const formatFull = (v) => v ? dayjs(v).format('dddd, DD/MM/YYYY HH:mm:ss') : ''
const fromNow = (v) => v ? dayjs(v).fromNow() : ''

/* ===== Roles ===== */
const getRolesList = async () => {
    try {
        const res = await getRoles()
        roles.value = (res?.data || []).map(r => ({
            label: r.description, value: String(r.id)
        }))
    } catch {
        // silent
    }
}
const getRoleName = (id) => {
    const role = roles.value.find(r => r.value === String(id))
    return role ? role.label : 'Không xác định'
}

/* ===== Data fetch ===== */
const getDepartment = async () => {
    loading.value = true
    try {
        const res = await getDepartments()
        tableData.value = res?.data || []
    } catch {
        message.error('Không thể tải phòng ban')
    } finally {
        loading.value = false
    }
}
const refresh = () => getDepartment()

/* ===== Drawer actions ===== */
const drawerTitle = computed(() =>
    selectedDepartment.value
        ? `Phòng ban: ${selectedDepartment.value.name}`
        : 'Tạo phòng ban mới'
)

const showPopupCreate = () => {
    selectedDepartment.value = null
    activeDepartmentId.value = null
    activeTab.value = 'info'
    formData.value = { name: '', description: '' }
    openDrawer.value = true
}

const showPopupDetail = (record) => {
    selectedDepartment.value = record
    activeDepartmentId.value = record.id
    activeTab.value = 'info'
    formData.value = { name: record.name, description: record.description }
    openDrawer.value = true
}

const openUsersTab = async (record) => {
    selectedDepartment.value = record
    activeDepartmentId.value = record.id
    openDrawer.value = true
    activeTab.value = 'users'
    await getUsersByDepartment(record.id)
}

const onCloseDrawer = () => {
    openDrawer.value = false
    formRef.value?.resetFields()
    selectedDepartment.value = null
    departmentUsers.value = []
    activeDepartmentId.value = null
}

/* ===== Users of department ===== */
const getUsersByDepartment = async (departmentId) => {
    loadingUsers.value = true
    try {
        const res = await getUsers({ department_id: departmentId })
        departmentUsers.value = res?.data || []
    } catch {
        message.error('Không thể tải danh sách người dùng')
    } finally {
        loadingUsers.value = false
    }
}

/* ===== Submit / Delete ===== */
const rules = {
    name: [{ required: true, message: 'Vui lòng nhập tên phòng ban', trigger: ['blur', 'change'] }],
    description: [{ required: true, message: 'Vui lòng nhập mô tả phòng ban', trigger: ['blur', 'change'] }],
}

const submitDepartment = async () => {
    try {
        await formRef.value?.validate()
        loadingCreate.value = true
        if (selectedDepartment.value) {
            await updateDepartment(selectedDepartment.value.id, formData.value)
            message.success('Cập nhật phòng ban thành công')
        } else {
            await createDepartment(formData.value)
            message.success('Thêm mới phòng ban thành công')
        }
        await getDepartment()
        onCloseDrawer()
    } catch {
        message.error('Thao tác không thành công')
    } finally {
        loadingCreate.value = false
    }
}

const deleteConfirm = async (id) => {
    try {
        await deleteDepartment(id)
        message.success('Đã xóa phòng ban')
        await getDepartment()
    } catch {
        message.error('Xóa phòng ban không thành công')
    }
}

/* ===== Lifecycle ===== */
onMounted(() => {
    getDepartment()
    getRolesList()
})
</script>

<style scoped>
.card-title{
    display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:8px;
}
.title{ margin:0; }
.toolbar{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; }

.mr-6{ margin-right:6px; }
.muted{ color:#999; }

/* Tối ưu ellipsis cho mô tả */
.ellipsis-1{
    display:inline-block; max-width: 520px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
}

/* Ô họ tên trong Users table */
.user-cell{ display:flex; align-items:center; gap:8px; }

/* Cố định sticky header nếu cần thêm cảm giác “enterprise” */
/* :deep(.ant-table-header){ position: sticky; top: 0; z-index: 2; } */
</style>
