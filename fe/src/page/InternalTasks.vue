<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách nhiệm vụ</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm nhiệm vụ mới</a-button>
        </a-flex>

        <a-table :columns="columns" :data-source="tableData" :loading="loading"
            style="margin-top: 12px;" row-key="module" :scroll="{ y: 'calc( 100vh - 330px )' }">
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.dataIndex == 'title'">
                    <a-typography-text strong style="cursor: pointer;" @click="showPopupDetail(record)">{{ text }}</a-typography-text>
                </template>
                <template v-if="column.dataIndex == 'priority'">
                    <a-tag v-if="text" :color="checkPriority(text).color">{{ checkPriority(text).title }}</a-tag>
                </template>
                <template v-if="['created_by', 'assigned_to'].includes(column.dataIndex)">
                    {{ getUserById(text) }}
                </template>
                <template v-if="column.dataIndex == 'linked_type'">
                    {{ getLinkedType(text) }}
                </template>
                <template v-if="column.dataIndex == 'step_code'">
                    {{ getStepByStepNo(text) }}
                </template>
                <template v-else-if="column.dataIndex == 'action'">
                    <a-dropdown placement="left">
                        <a-button>
                            <template #icon>
                                <MoreOutlined />
                            </template>
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
                                    <div>
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
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getTasks, deleteTask } from '../api/task'
import { getUsers } from '@/api/user';
import { message } from 'ant-design-vue'
import { useRoute, useRouter } from 'vue-router';
import { InfoCircleOutlined, DeleteOutlined, MoreOutlined } from '@ant-design/icons-vue';
import { CONTRACTS_STEPS, BIDDING_STEPS } from '@/common'
import DrawerCreateTask from "../components/common/DrawerCreateTask.vue";

const router = useRouter()
const tableData = ref([])
const loading = ref(false)
const openDrawer = ref(false)
const listUser = ref([])


const columns = [
    // { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
    { title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title' },
    { title: 'Độ ưu tiên', dataIndex: 'priority', key: 'priority' },
    { title: 'Người tạo', dataIndex: 'created_by', key: 'created_by' },
    { title: 'Người được giao', dataIndex: 'assigned_to', key: 'assigned_to' },
    { title: 'Loại Task', dataIndex: 'linked_type', key: 'linked_type' },
    { title: 'Tiến trình', dataIndex: 'step_code', key: 'step_code' },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px', align:'center' },
]

const getInternalTask = async () => {
    loading.value = true
    try {
        const response = await getTasks();        
        tableData.value = response.data.data ? response.data.data : [];
    } catch (e) {
        message.error('Không thể tải nhiệm vụ')
    } finally {
        loading.value = false
    }
}

const deleteConfirm = async (internalId) => {
    try {
        await deleteTask(internalId);
        getInternalTask();
    } catch (e) {
        message.error('Xóa nhiệm vụ không thành công')
    } finally {
    }
}
const showPopupDetail = async (record) => {    
    router.push({
        name: "internal-tasks-info",
        params: { id: record.id, task_name: record.name}
    })
}
const showPopupCreate = () => {
    openDrawer.value = true;
}
const submitForm = () => {
    getInternalTask();
}
const checkPriority = (text) => {
    switch (text) {
        case 'low':
            return { title: "Thấp", color: "success"};
        case 'normal':
            return { title: "Thường", color: "warning"};
        case 'high':
            return { title: "Cao", color: "error"};    
        default:
            return { title: "", color: ""};
    }
};

const getUserById = (userId) =>  {
    let data = listUser.value.find(ele => ele.id == userId);
    if(!data){
        return "" ;
    }
    return data.name;
}
const getLinkedType = (text) =>  {
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

const getStepByStepNo = (step) =>  {
    let data = CONTRACTS_STEPS.find(ele => ele.step_code == step);
    if(!data){
        data = BIDDING_STEPS.find(ele => ele.step_code == step);
        if(!data){
            return "Trống" ;
        }
    }
    return data.name;
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
onMounted(() => {
    getInternalTask();
    getUser();    

})
</script>
<style scoped>
:deep(.ant-pagination){
    margin-bottom: 0 !important;
}
.icon-action {
    font-size: 18px;
    margin-right: 8px;
    cursor: pointer;
}

&:last-child {
    margin-right: 0;
}
</style>
