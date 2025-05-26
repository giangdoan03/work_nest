<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-select v-model:value="selectedRole" placeholder="Chọn vai trò" style="width: 200px" @change="fetchDepartment">
                <a-select-option v-for="role in roles" :key="role.id" :value="role.id">
                    {{ role.name }}
                </a-select-option>
            </a-select>
            <a-button type="primary" @click="saveDepartment">Lưu phân quyền lại</a-button>
        </a-space>

        <a-table 
            :columns="columns" 
            :data-source="tableData" 
            :pagination="false" 
            :loading="loading"
            row-key="module"
            :scroll="{ y: 'calc( 100vh - 330px )' }"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.dataIndex == 'stt'">
                    <a-checkbox
                        :checked="department?.[record.module]?.[column.dataIndex] || false"
                        @change="e => department[record.module][column.dataIndex] = e.target.checked"
                    />
                </template>
                <template v-else-if="column.dataIndex == 'action'">
                    <EditOutlined class="icon-action" style="color: blue;"/>
                    <DeleteOutlined class="icon-action" style="margin: 0; color: red;"/>
                </template>
                <template v-else>
                    {{ record.module }}
                </template>
            </template>
        </a-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getRoles, getPermissionMatrix,  } from '../api/permission'
import { message } from 'ant-design-vue'
import { EditOutlined, DeleteOutlined } from '@ant-design/icons-vue';

const roles = ref([])
const selectedRole = ref(null)
const tableData = ref([])
const department = ref({})
const loading = ref(false)

const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
    { title: 'Tên phòng ban', dataIndex: 'name', key: 'name' },
    { title: 'Mô tả', dataIndex: 'description', key: 'description' },
    { title: 'Thời gian tạo', dataIndex: 'create_at', key: 'create_at' },
    { title: 'Cập nhật gần nhất', dataIndex: 'update_at', key: 'update_at' },
    { title: 'Hành động', dataIndex: 'action', key: 'action' },
]

const fetchRoles = async () => {
    loading.value = true
    try {
        const response = await getRoles()
        roles.value = response.data

        if (roles.value.length > 0) {
            selectedRole.value = roles.value[0].id
            await fetchDepartment()
        }
    } catch (e) {
        message.error('Không thể tải vai trò')
    } finally {
        loading.value = false
    }
}

const fetchDepartment = async () => {
    loading.value = true
    try {
        const res = await getPermissionMatrix(selectedRole.value)
        department.value = res.data.data || {}
        tableData.value = Object.entries(department.value).map(([module, actions]) => ({
            module,
            ...actions
        }))
    } catch (e) {
        message.error('Không thể tải phân quyền')
    } finally {
        loading.value = false
    }
}

const saveDepartment = async () => {
    loading.value = true
    // try {
    //     await saveRoleDepartment(selectedRole.value, department.value)
    //     message.success('Lưu quyền thành công!')
    // } catch (e) {
    //     message.error('Lưu quyền thất bại!')
    // } finally {
    //     loading.value = false
    // }
}

onMounted(fetchRoles)
</script>
<style scoped>
.icon-action{
    font-size: 18px;
    margin-right: 24px;
    cursor: pointer;
}
&:last-child{
    margin-right: 0;
}
</style>
