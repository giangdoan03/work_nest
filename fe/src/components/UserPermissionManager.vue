<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-select v-model:value="selectedRole" placeholder="Chọn vai trò" style="width: 200px" @change="fetchPermissions">
                <a-select-option v-for="role in roles" :key="role.id" :value="role.id">
                    {{ role.name }}
                </a-select-option>
            </a-select>
            <a-button type="primary" @click="savePermissions">Lưu phân quyền</a-button>
        </a-space>

        <a-spin :spinning="loading">
            <a-table :columns="columns" :data-source="tableData" :pagination="false" row-key="module">
                <template #bodyCell="{ column, record }">
                    <template v-if="column.dataIndex !== 'module'">
                        <a-checkbox
                            :checked="permissions?.[record.module]?.[column.dataIndex] || false"
                            @change="e => permissions[record.module][column.dataIndex] = e.target.checked"
                        />
                    </template>
                    <template v-else>
                        {{ record.module }}
                    </template>
                </template>
            </a-table>
        </a-spin>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getRoles, getPermissionMatrix, saveRolePermissions } from '../api/permission'
import { message } from 'ant-design-vue'
import { useUserStore } from '@/stores/user'
const userStore = useUserStore()

const roles = ref([])
const selectedRole = ref(null)
const tableData = ref([])
const permissions = ref({})
const loading = ref(false)

const columns = [
    { title: 'Module', dataIndex: 'module', key: 'module' },
    { title: 'View', dataIndex: 'view', key: 'view' },
    { title: 'Create', dataIndex: 'create', key: 'create' },
    { title: 'Update', dataIndex: 'update', key: 'update' },
    { title: 'Delete', dataIndex: 'delete', key: 'delete' }
]

const fetchRoles = async () => {
    loading.value = true
    try {
        const response = await getRoles()
        roles.value = response.data

        if (roles.value.length > 0) {
            selectedRole.value = roles.value[0].id
            await fetchPermissions()
        }
    } catch (e) {
        message.error('Không thể tải vai trò')
    } finally {
        loading.value = false
    }
}

const fetchPermissions = async () => {
    loading.value = true
    try {
        const res = await getPermissionMatrix(selectedRole.value)
        const raw = res.data.data || {}

        const allModules = Object.keys(raw)
        const defaultActions = { view: false, create: false, update: false, delete: false }

        // Đảm bảo mỗi module có đủ 4 hành động
        permissions.value = {}
        tableData.value = []

        for (const module of allModules) {
            permissions.value[module] = { ...defaultActions, ...raw[module] }
            tableData.value.push({
                module,
                ...permissions.value[module]
            })
        }

    } catch (e) {
        message.error('Không thể tải phân quyền')
    } finally {
        loading.value = false
    }
}


const savePermissions = async () => {
    loading.value = true
    try {
        await saveRolePermissions(selectedRole.value, permissions.value)
        message.success('Lưu quyền thành công!')

        // Nếu đang chỉnh vai trò của chính mình → cập nhật lại permissions
        if (userStore.user?.role_id === selectedRole.value) {
            await userStore.fetchPermissions(true) // force reload
        }
    } catch (e) {
        message.error('Lưu quyền thất bại!')
    } finally {
        loading.value = false
    }
}


onMounted(fetchRoles)
</script>
