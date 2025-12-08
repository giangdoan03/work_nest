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

                    <a-button type="primary" :icon="h(PlusOutlined)" @click="showPopupCreate">
                        Thêm phòng ban mới
                    </a-button>
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

                    <template v-else-if="column.key === 'users'">
                        <div style="display: flex; flex-wrap: wrap; gap: 4px;">
                            <a-tag v-for="u in (record.users || [])" :key="u.id" color="blue">
                                {{ u.name }}
                            </a-tag>
                            <span v-if="!record.users || record.users.length === 0">—</span>
                        </div>
                    </template>


                    <template v-else-if="column.dataIndex === 'created_at'">
                        <span :title="formatFull(text)">
                            {{ formatDate(text) }} ·
                            <span class="muted">{{ fromNow(text) }}</span>
                        </span>
                    </template>

                    <template v-else-if="column.dataIndex === 'updated_at'">
                        <span :title="formatFull(text)">
                            {{ formatDate(text) }} ·
                            <span class="muted">{{ fromNow(text) }}</span>
                        </span>
                    </template>

                    <template v-else-if="column.dataIndex === 'action'">
                        <a-dropdown trigger="click" placement="bottomRight">
                            <a-button type="text" :icon="h(MoreOutlined)" />
                            <template #overlay>
                                <a-menu>
                                    <a-menu-item @click="() => openUsersTab(record)">
                                        <EyeOutlined class="mr-6" /> Xem chi tiết
                                    </a-menu-item>

                                    <a-menu-item @click="() => showPopupDetail(record)">
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
                    <div class="users-toolbar">
                        <a-button
                            type="primary"
                            style="margin-bottom: 12px"
                            @click="showAddUserModal"
                        >
                            Thêm người dùng vào phòng ban
                        </a-button>

                    </div>

                    <a-skeleton :loading="loadingUsers" active :paragraph="{ rows: 5 }">
                        <template v-if="Array.isArray(departmentUsers)">
                            <a-table
                                :columns="userColumns"
                                :data-source="departmentUsers"
                                row-key="id"
                                size="small"
                                bordered
                                :locale="{ emptyText: 'Chưa có người dùng' }"
                            >
                                <template #bodyCell="{ column, record, index }">
                                    <template v-if="column.key === 'stt'">
                                        {{ index + 1 }}
                                    </template>

                                    <template v-else-if="column.key === 'name'">
                                        <div class="user-cell">
                                            <BaseAvatar
                                                :src="record.avatar"
                                                :name="record.name"
                                                :size="28"
                                                shape="circle"
                                                :preferApiOrigin="true"
                                            />
                                            <span>{{ record.name }}</span>
                                        </div>
                                    </template>

                                    <template v-else-if="column.key === 'email'">
                                        {{ record.email || '—' }}
                                    </template>

                                    <template v-else-if="column.key === 'phone'">
                                        {{ record.phone || '—' }}
                                    </template>

                                    <template v-else-if="column.key === 'role'">
                                        <span v-if="record.role_in_department">
                                            <a-tag :color="record.role_in_department === 'admin' ? 'red' : 'blue'">
                                                {{ record.role_in_department === 'admin' ? 'Admin phòng' : 'Thành viên' }}
                                            </a-tag>
                                        </span>
                                        <span v-else>
                                            {{ getRoleName(record.role_id) }}
                                        </span>
                                    </template>

                                    <template v-else-if="column.key === 'actions'">
                                        <a-popconfirm
                                            title="Xóa người này khỏi phòng ban?"
                                            ok-text="Xóa"
                                            cancel-text="Hủy"
                                            @confirm="removeUser(record.id)"
                                        >
                                            <a-button type="text" danger>
                                                <DeleteOutlined />
                                            </a-button>
                                        </a-popconfirm>
                                    </template>
                                </template>
                            </a-table>
                        </template>
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

        <!-- Modal thêm user vào phòng ban -->
        <a-modal
            v-model:open="openAddUserModal"
            title="Thêm người dùng vào phòng ban"
            ok-text="Lưu"
            cancel-text="Hủy"
            :confirm-loading="loadingAddUser"
            @ok="submitAddUsers"
            destroyOnClose
        >
            <template v-if="!loadingAddUser">
                <a-select
                    v-model:value="selectedUserIds"
                    mode="multiple"
                    allow-clear
                    style="width: 100%"
                    placeholder="Chọn người dùng"
                    :options="allUsers"
                />
            </template>

            <template v-else>
                <a-skeleton active :paragraph="{ rows: 2 }" />
            </template>
        </a-modal>

    </div>
</template>

<script setup>
import {computed, h, onMounted, ref} from 'vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/vi'
import {message} from 'ant-design-vue'
import {
    DeleteOutlined,
    EditOutlined,
    EyeOutlined,
    MoreOutlined,
    PlusOutlined,
    ReloadOutlined,
    SearchOutlined,
    UserAddOutlined
} from '@ant-design/icons-vue'

import {
    addUsersToDepartment,
    createDepartment,
    deleteDepartment,
    getDepartments,
    removeUserFromDepartment,
    updateDepartment,
    getDepartmentUsers
} from '../api/department'
import {getUsers} from '../api/user'
import {getRoles} from '../api/permission'
import BaseAvatar from '@/components/common/BaseAvatar.vue'

dayjs.extend(relativeTime); dayjs.locale('vi')

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

/* Modal thêm user */
const openAddUserModal = ref(false)
const loadingAddUser = ref(false)
const selectedUserIds = ref([])
const allUsers = ref([])
const fullUsersList = ref([])


/* ===== Columns ===== */
const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: 50, align: 'center', fixed: 'left' },
    { title: 'Tên phòng ban', dataIndex: 'name', key: 'name', width: 180, ellipsis: true },
    { title: 'Mô tả', dataIndex: 'description', key: 'description', width: 200, ellipsis: true },

    {
        title: 'Thành viên',
        dataIndex: 'users',
        key: 'users',
        width: 200
    },

    {
        title: 'Thời gian tạo',
        dataIndex: 'created_at',
        key: 'created_at',
        width: 200
    },
    {
        title: 'Cập nhật gần nhất',
        dataIndex: 'updated_at',
        key: 'updated_at',
        width: 200
    },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: 100, align: 'center', fixed: 'right' }
]


const userColumns = [
    { title: 'STT', key: 'stt', width: 70, align: 'center' },
    { title: 'Họ tên', key: 'name', width: 260 },
    { title: 'Email', key: 'email', width: 220 },
    { title: 'Số điện thoại', key: 'phone', width: 140 },
    { title: 'Vai trò', key: 'role', width: 160 },
    { title: 'Thao tác', key: 'actions', width: 90, align: 'center' }
]

/* ===== Pagination / filtering ===== */
const pagination = ref({
    current: 1,
    pageSize: 10,
    showSizeChanger: true,
    pageSizeOptions: ['10', '20', '50'],
    showTotal: (total, range) => `${range[0]}–${range[1]} / ${total}`
})

const filteredData = computed(() => {
    const q = searchTerm.value.trim().toLowerCase()
    if (!q) return tableData.value

    return tableData.value
        .filter(it => {
            const name = (it.name || '').toLowerCase()
            const desc = (it.description || '').toLowerCase()
            return name.includes(q) || desc.includes(q)
        })
        .map(it => ({ ...it })) // giữ users
})


const onTableChange = (pag, _filters, _sorter) => {
    pagination.value = { ...pagination.value, current: pag.current, pageSize: pag.pageSize }
}

/* ===== Utils ===== */
const formatDate = (v) => (v ? dayjs(v).format('DD/MM/YYYY HH:mm') : '—')
const formatFull = (v) => (v ? dayjs(v).format('dddd, DD/MM/YYYY HH:mm:ss') : '')
const fromNow = (v) => (v ? dayjs(v).fromNow() : '')

/* ===== Roles (system role nếu cần) ===== */
const getRolesList = async () => {
    try {
        const res = await getRoles()
        roles.value = (res?.data || []).map(r => ({
            label: r.description,
            value: String(r.id)
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
    selectedDepartment.value ? `Phòng ban: ${selectedDepartment.value.name}` : 'Tạo phòng ban mới'
)

const showPopupCreate = () => {
    selectedDepartment.value = null
    activeDepartmentId.value = null
    activeTab.value = 'info'
    formData.value = { name: '', description: '' }
    openDrawer.value = true
}

const showPopupDetail = (record) => {
    const depId = record.id ?? record.department_id ?? record.depId ?? record.dep_id;

    selectedDepartment.value = record;
    activeDepartmentId.value = depId;
    activeTab.value = 'info';
    formData.value = { name: record.name, description: record.description };
    openDrawer.value = true;
};

const openUsersTab = async (record) => {

    console.log('record', record)
    const depId = record.id ?? record.department_id ?? record.depId ?? record.dep_id;

    if (!depId) {
        console.error("Không tìm thấy ID phòng ban:", record);
        return message.error("Không xác định được phòng ban!");
    }

    selectedDepartment.value = record;
    activeDepartmentId.value = depId;
    openDrawer.value = true;
    activeTab.value = 'users';

    await getUsersByDepartment(depId);
};


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
        const res = await getDepartmentUsers(departmentId)
        departmentUsers.value = Array.isArray(res?.data) ? res.data : []
    } catch (e) {
        console.log(e)
        message.error("Không thể tải danh sách người dùng")
        departmentUsers.value = []
    } finally {
        loadingUsers.value = false
    }
}




/* ===== Thêm user vào phòng ban ===== */
const showAddUserModal = async () => {
    openAddUserModal.value = true;
    loadingAddUser.value = true;

    try {
        // 1. Lưu danh sách user đang thuộc phòng ban
        const existingUserIds = departmentUsers.value.map(u => u.id);

        // 2. Lấy toàn bộ user trong hệ thống
        const res = await getUsers();
        const list = res?.data || [];

        // ⭐ LƯU DANH SÁCH FULL USER (có role_id)
        fullUsersList.value = list;

        // ⭐ Danh sách hiển thị select
        allUsers.value = list.map(u => ({
            label: u.name,
            value: u.id,
        }));

        // 3. Tự động chọn user đã có trong phòng ban
        selectedUserIds.value = existingUserIds;

    } catch (e) {
        console.log(e);
        message.error("Không thể tải danh sách người dùng");
    } finally {
        loadingAddUser.value = false;
    }
};




const submitAddUsers = async () => {
    console.log("depId:", activeDepartmentId.value);
    console.log("selected:", selectedUserIds.value);

    if (!activeDepartmentId.value) {
        return message.error("Không xác định được phòng ban!");
    }

    const users = selectedUserIds.value.map(id => {
        // 1) User đã thuộc phòng ban → giữ nguyên role_in_department
        const old = departmentUsers.value.find(u => u.id == id);
        if (old && old.role_in_department) {
            return {
                id,
                role: old.role_in_department
            };
        }

        // 2) User mới → set role theo role_id hệ thống
        const full = fullUsersList.value.find(u => u.id == id);

        let role = "user";
        if (full?.role_id == 1 || full?.role_id == 2) {
            role = "admin"; // super admin, admin → admin phòng
        }

        return { id, role };
    });

    const payload = {
        department_id: activeDepartmentId.value,
        users: users
    };

    console.log("🔥 PAYLOAD gửi lên BE:", payload);

    try {
        await addUsersToDepartment(payload);

        message.success("Cập nhật người dùng thành công");
        openAddUserModal.value = false;

        await getUsersByDepartment(activeDepartmentId.value);
    } catch (e) {
        console.log("❌ LỖI API:", e.response?.data || e);
        message.error("Không thể cập nhật danh sách người dùng");
    }
};




/* ===== Xóa user khỏi phòng ban ===== */
const removeUser = async (userId) => {
    if (!activeDepartmentId.value) return
    try {
        await removeUserFromDepartment(activeDepartmentId.value, userId)
        message.success('Đã xóa người dùng khỏi phòng ban')
        await getUsersByDepartment(activeDepartmentId.value)
    } catch {
        message.error('Không thể xóa người dùng khỏi phòng ban')
    }
}

/* ===== Submit / Delete ===== */
const rules = {
    name: [{ required: true, message: 'Vui lòng nhập tên phòng ban', trigger: ['blur', 'change'] }],
    description: [{ required: true, message: 'Vui lòng nhập mô tả phòng ban', trigger: ['blur', 'change'] }]
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
.card-title {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 8px;
}
.title {
    margin: 0;
}
.toolbar {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.mr-6 {
    margin-right: 6px;
}
.muted {
    color: #999;
}

/* Tối ưu ellipsis cho mô tả */
.ellipsis-1 {
    display: inline-block;
    max-width: 520px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Ô họ tên trong Users table */
.user-cell {
    display: flex;
    align-items: center;
    gap: 8px;
}

.users-toolbar {
    display: flex;
    justify-content: flex-end;
    margin-bottom: 12px;
}

/* Có thể bật sticky header nếu muốn */
/* :deep(.ant-table-header){
    position: sticky;
    top: 0;
    z-index: 2;
} */
</style>
