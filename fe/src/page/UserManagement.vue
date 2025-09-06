<template>
    <div>
        <a-card bordered>
            <!-- Toolbar -->
            <div class="card-title">
                <a-typography-title :level="4" class="title">Danh sách người dùng</a-typography-title>
                <div class="toolbar">
                    <a-input
                        v-model:value="searchTerm"
                        allow-clear
                        style="width: 260px"
                        placeholder="Tìm theo tên, email, SĐT…"
                    >
                        <template #prefix><SearchOutlined /></template>
                    </a-input>

                    <a-select
                        v-model:value="filterDept"
                        :options="departmentOptions"
                        style="width: 200px"
                        allow-clear
                        placeholder="Lọc phòng ban"
                    >
                        <template #suffixIcon><TeamOutlined /></template>
                    </a-select>

                    <a-select
                        v-model:value="filterRole"
                        :options="roles"
                        style="width: 200px"
                        allow-clear
                        placeholder="Lọc vai trò"
                    >
                        <template #suffixIcon><IdcardOutlined /></template>
                    </a-select>

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
                        Thêm người dùng mới
                    </a-button>
                </div>
            </div>

            <!-- Table -->
            <a-table
                :columns="columns"
                :data-source="displayData"
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

                    <template v-else-if="column.dataIndex === 'avatar'">
                        <a-tooltip :title="record.name">
                            <BaseAvatar
                                :src="record.avatar"
                                :name="record.name"
                                :size="28"
                                shape="circle"
                                :preferApiOrigin="true"
                            />
                        </a-tooltip>
                    </template>

                    <template v-else-if="column.dataIndex === 'name'">
                        <a-typography-text strong class="link" @click="showPopupDetail(record)">
                            {{ text }}
                        </a-typography-text>
                    </template>

                    <template v-else-if="column.dataIndex === 'email'">
                        <a-tooltip :title="text"><span class="ellipsis-1">{{ text }}</span></a-tooltip>
                    </template>

                    <template v-else-if="column.dataIndex === 'phone'">
                        <span class="mono">{{ text }}</span>
                    </template>

                    <template v-else-if="column.dataIndex === 'department_id'">
                        {{ getDeptName(record.department_id) || '—' }}
                    </template>

                    <template v-else-if="column.dataIndex === 'role_id'">
                        {{ getRoleName(record.role_id) || '—' }}
                    </template>

                    <template v-else-if="column.dataIndex === 'action'">
                        <a-dropdown trigger="click" placement="bottomRight">
                            <a-button type="text" :icon="h(MoreOutlined)" />
                            <template #overlay>
                                <a-menu @click.stop>
                                    <a-menu-item @click="goToUserDetail(record.id)">
                                        <EyeOutlined class="mr-6" /> Xem chi tiết
                                    </a-menu-item>
                                    <a-menu-item @click="showPopupDetail(record)">
                                        <EditOutlined class="mr-6" /> Chỉnh sửa
                                    </a-menu-item>
                                    <a-menu-item danger>
                                        <a-popconfirm
                                            title="Bạn chắc chắn muốn xóa người dùng này?"
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

        <!-- Drawer -->
        <a-drawer
            :title="selectedUser ? 'Sửa người dùng' : 'Tạo người dùng mới'"
            :width="780"
            :open="openDrawer"
            :body-style="{ paddingBottom: '80px' }"
            @close="onCloseDrawer"
        >
            <a-tabs v-model:activeKey="activeTab" animated>
                <!-- Tab: Thông tin -->
                <a-tab-pane key="info" tab="Thông tin">
                    <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="Tên người dùng" name="name" has-feedback>
                                    <a-input v-model:value="formData.name" placeholder="Nhập tên người dùng" />
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item label="Email" name="email" has-feedback>
                                    <a-input v-model:value="formData.email" placeholder="Nhập Email" />
                                </a-form-item>
                            </a-col>
                        </a-row>

                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="Số điện thoại" name="phone" has-feedback>
                                    <a-input v-model:value="formData.phone" placeholder="Nhập số điện thoại" />
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item label="Phòng ban" name="department_id" has-feedback>
                                    <a-select
                                        v-model:value="formData.department_id"
                                        :options="departmentOptions"
                                        placeholder="Chọn phòng ban"
                                        allow-clear
                                    />
                                </a-form-item>
                            </a-col>
                        </a-row>

                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="Loại tài khoản" name="role_id" has-feedback>
                                    <a-select
                                        v-model:value="formData.role_id"
                                        :options="roles"
                                        placeholder="Chọn loại tài khoản"
                                        allow-clear
                                    />
                                </a-form-item>
                            </a-col>
                        </a-row>
                    </a-form>
                </a-tab-pane>

                <!-- Tab: Bảo mật -->
                <a-tab-pane key="security" tab="Bảo mật">
                    <a-alert
                        type="info"
                        banner
                        message="Mật khẩu tối thiểu 8 ký tự, không chứa khoảng trắng. Với tài khoản mới, bắt buộc đặt mật khẩu."
                        style="margin-bottom: 12px;"
                    />
                    <a-form :model="formData" :rules="rules" layout="vertical">
                        <a-form-item>
                            <a-checkbox v-model:checked="changePassword" v-if="!!selectedUser">
                                Đổi mật khẩu cho tài khoản này
                            </a-checkbox>
                        </a-form-item>

                        <a-row :gutter="16" v-if="!selectedUser || changePassword">
                            <a-col :span="12">
                                <a-form-item label="Mật khẩu" name="password" has-feedback>
                                    <a-input-password v-model:value="formData.password" autocomplete="new-password" />
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item
                                    label="Nhập lại mật khẩu"
                                    name="confirm_password"
                                    :dependencies="['password']"
                                    has-feedback
                                >
                                    <a-input-password v-model:value="formData.confirm_password" autocomplete="new-password" />
                                </a-form-item>
                            </a-col>
                        </a-row>
                    </a-form>
                </a-tab-pane>
            </a-tabs>

            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" :loading="loadingCreate" @click="submitForm">
                        {{ selectedUser ? 'Cập nhật' : 'Thêm mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted, computed, h } from 'vue'
import { useRouter } from 'vue-router'
import {
    getUsers, createUser, updateUser, deleteUser
} from '@/api/user'
import { getDepartments } from '@/api/department'
import { getRoles } from '@/api/permission'
import { message } from 'ant-design-vue'
import {
    EditOutlined, DeleteOutlined, MoreOutlined, EyeOutlined,
    PlusOutlined, SearchOutlined, ReloadOutlined,
    TeamOutlined, IdcardOutlined
} from '@ant-design/icons-vue'
import BaseAvatar from '@/components/common/BaseAvatar.vue'

/* ===== State ===== */
const router = useRouter()
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)

const density = ref('middle') // small | middle | large
const searchTerm = ref('')
const filterDept = ref()
const filterRole = ref()

const pagination = ref({
    current: 1,
    pageSize: 10,
    showSizeChanger: true,
    pageSizeOptions: ['10','20','50'],
    showTotal: (total, range) => `${range[0]}–${range[1]} / ${total}`
})

const openDrawer = ref(false)
const activeTab = ref('info')
const selectedUser = ref(null)
const formRef = ref(null)
const changePassword = ref(false)

const formData = ref({
    name: '',
    email: '',
    phone: '',
    department_id: undefined,
    role_id: undefined,
    password: '',
    confirm_password: '',
})

/* ===== Refs for master data ===== */
const departments = ref([])
const roles = ref([]) // [{label, value}]

/* ===== Options ===== */
const departmentOptions = computed(() =>
    (departments.value || []).map(d => ({ value: d.id, label: d.name }))
)

/* ===== Columns ===== */
const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: 70, align: 'center', fixed: 'left' },
    { title: '', dataIndex: 'avatar', key: 'avatar', width: 56, align: 'center' },
    { title: 'Tên người dùng', dataIndex: 'name', key: 'name', sorter: (a,b) => a.name.localeCompare(b.name) },
    { title: 'Email', dataIndex: 'email', key: 'email', sorter: (a,b) => (a.email||'').localeCompare(b.email||'') },
    { title: 'Số điện thoại', dataIndex: 'phone', key: 'phone', width: 140, sorter: (a,b) => (a.phone||'').localeCompare(b.phone||'') },
    { title: 'Phòng ban', dataIndex: 'department_id', key: 'department_id', width: 200 },
    { title: 'Quyền', dataIndex: 'role_id', key: 'role_id', width: 180 },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: 100, align:'center', fixed: 'right' },
]

/* ===== Helpers ===== */
const getDeptName = (id) => {
    const x = departments.value.find(d => d.id === id)
    return x?.name
}
const roleMap = computed(() => {
    const map = new Map()
    roles.value.forEach(r => map.set(Number(r.value), r.label))
    return map
})
const getRoleName = (id) => roleMap.value.get(Number(id))

/* ===== Filters ===== */
const displayData = computed(() => {
    const q = searchTerm.value.trim().toLowerCase()
    const dept = filterDept.value
    const role = filterRole.value
    return (tableData.value || []).filter(u => {
        const okQ = !q
            || (u.name||'').toLowerCase().includes(q)
            || (u.email||'').toLowerCase().includes(q)
            || (u.phone||'').toLowerCase().includes(q)
        const okDept = !dept || u.department_id === dept
        const okRole = !role || Number(u.role_id) === Number(role)
        return okQ && okDept && okRole
    })
})

/* ===== Rules & validators ===== */
const emailRe = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const vnPhoneRe = /^(0|\+84)(3[2-9]|5[6|8|9]|7[0|6-9]|8[1-5]|9[0-9])[0-9]{7}$/

const rules = computed(() => {
    const base = {
        name: [{ required: true, validator: (_r, v) => v ? Promise.resolve() : Promise.reject('Vui lòng nhập họ và tên'), trigger: ['blur','change'] }],
        email: [{
            required: true,
            validator: (_r, v) => !v ? Promise.reject('Vui lòng nhập Email')
                : (v.length>200 ? Promise.reject('Email không vượt quá 200 ký tự')
                    : (emailRe.test(v) ? Promise.resolve() : Promise.reject('Email không hợp lệ'))),
            trigger: ['blur','change']
        }],
        phone: [{
            required: true,
            validator: (_r, v) => !v ? Promise.reject('Vui lòng nhập số điện thoại')
                : (v.length>20 ? Promise.reject('Số điện thoại không vượt quá 20 ký tự')
                    : (vnPhoneRe.test(v) ? Promise.resolve() : Promise.reject('Số điện thoại không hợp lệ'))),
            trigger: ['blur','change']
        }],
        department_id: [{ required: true, message: 'Vui lòng chọn phòng ban', trigger: ['blur','change'] }],
        role_id: [{ required: true, message: 'Vui lòng chọn loại tài khoản', trigger: ['blur','change'] }],
    }
    if (!selectedUser.value || changePassword.value) {
        base.password = [{
            required: true,
            validator: (_r, v) => !v ? Promise.reject('Vui lòng nhập mật khẩu')
                : (/\s/.test(v) ? Promise.reject('Mật khẩu không chứa khoảng trắng')
                    : (v.length < 8 ? Promise.reject('Mật khẩu tối thiểu 8 ký tự') : Promise.resolve())),
            trigger: ['blur','change']
        }]
        base.confirm_password = [{
            required: true,
            validator: (_r, v) => v !== formData.value.password ? Promise.reject('Mật khẩu không khớp') : Promise.resolve(),
            trigger: ['blur','change']
        }]
    }
    return base
})

/* ===== Data fetch ===== */
const getListDepartments = async () => {
    const res = await getDepartments().catch(() => null)
    departments.value = res?.data || []
}
const getListRoles = async () => {
    const res = await getRoles().catch(() => null)
    roles.value = (res?.data || []).map(r => ({ label: r.description, value: Number(r.id) }))
}
const getUser = async () => {
    loading.value = true
    try {
        const res = await getUsers()
        tableData.value = res?.data || []
    } catch {
        message.error('Không thể tải người dùng')
    } finally {
        loading.value = false
    }
}
const refresh = () => getUser()

/* ===== Actions ===== */
const onTableChange = (pag) => {
    pagination.value = { ...pagination.value, current: pag.current, pageSize: pag.pageSize }
}

const goToUserDetail = (id) => {
    router.push(`/users/${id}`)
}

const showPopupCreate = () => {
    selectedUser.value = null
    changePassword.value = true // bắt buộc đặt mật khẩu cho user mới
    activeTab.value = 'info'
    formData.value = {
        name: '', email: '', phone: '',
        department_id: undefined, role_id: undefined,
        password: '', confirm_password: ''
    }
    openDrawer.value = true
}

const showPopupDetail = async (record) => {
    if (!roles.value.length) await getListRoles()
    selectedUser.value = record
    changePassword.value = false
    activeTab.value = 'info'
    formData.value = {
        name: record.name || '',
        email: record.email || '',
        phone: record.phone || '',
        department_id: record.department_id,
        role_id: Number(record.role_id),
        password: '',
        confirm_password: ''
    }
    openDrawer.value = true
}

const onCloseDrawer = () => {
    openDrawer.value = false
    selectedUser.value = null
    changePassword.value = false
    formRef.value?.resetFields?.()
}

const submitForm = async () => {
    try {
        await formRef.value?.validate?.()
        loadingCreate.value = true
        const payload = { ...formData.value }
        // Nếu không đổi mật khẩu ở chế độ sửa, bỏ 2 field này khỏi payload
        if (selectedUser.value && !changePassword.value) {
            delete payload.password
            delete payload.confirm_password
        }
        if (selectedUser.value) {
            await updateUser(selectedUser.value.id, payload)
            message.success('Cập nhật người dùng thành công')
        } else {
            await createUser(payload)
            message.success('Thêm mới người dùng thành công')
        }
        await getUser()
        onCloseDrawer()
    } catch (e) {
        // nếu BE trả lỗi email duplicate:
        const msg = e?.response?.data?.message || e?.response?.data?.error || 'Thao tác không thành công'
        message.error(String(msg).includes('exist') ? 'Email đã tồn tại, vui lòng dùng email khác' : msg)
    } finally {
        loadingCreate.value = false
    }
}

const deleteConfirm = async (userId) => {
    try {
        await deleteUser(userId)
        message.success('Đã xóa người dùng')
        await getUser()
    } catch {
        message.error('Xóa người dùng không thành công')
    }
}

/* ===== Init ===== */
onMounted(async () => {
    await Promise.all([getListDepartments(), getListRoles(), getUser()])
})
</script>

<style scoped>
.card-title{
    display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:8px;
}
.title{ margin:0; }
.toolbar{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; }

.link{ cursor:pointer; color: var(--brand, #1677ff); }
.link:hover{ text-decoration: underline; }

.mr-6{ margin-right:6px; }
.ellipsis-1{
    display:inline-block; max-width: 220px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
}
.mono{ font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }

:deep(.ant-pagination){ margin-bottom: 0 !important; }
</style>
