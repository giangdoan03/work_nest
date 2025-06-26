<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách nhiệm vụ</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm nhiệm vụ mới</a-button>
        </a-flex>
        <a-row :gutter="[14,14]" style="margin-top: 10px;">
            <a-col :span="4">
                <a-select
                    :allowClear="true"
                    style="width: 100%" 
                    v-model:value="dataFilter.linked_type" 
                    :options="optionsLinkType" 
                    placeholder="Loại nhiệm vụ" 
                    @change="getInternalTask()"
                />
            </a-col>
            <a-col :span="4">
                <a-select
                    :allowClear="true"
                    style="width: 100%" 
                    v-model:value="dataFilter.department_id" 
                    :options="optionsDepartment" 
                    placeholder="Chọn phòng ban" 
                    @change="getInternalTask()"
                />
            </a-col>
            <a-col :span="4">
                <a-select
                    :allowClear="true"
                    style="width: 100%" 
                    v-model:value="dataFilter.priority" 
                    :options="priorityOption" 
                    placeholder="Chọn độ ưu tiên" 
                    @change="getInternalTask()"
                />
            </a-col>
            <a-col :span="4">
                <a-select
                    :allowClear="true"
                    style="width: 100%" 
                    v-model:value="dataFilter.status" 
                    :options="statusOption" 
                    placeholder="Chọn trạng thái" 
                    @change="getInternalTask()"
                />
            </a-col>
            <a-col :span="4">
                <a-select
                    :allowClear="true"
                    style="width: 100%" 
                    v-model:value="dataFilter.assigned_to" 
                    :options="optionsAssigned" 
                    placeholder="Chọn độ người dùng" 
                    @change="getInternalTask()"
                />
            </a-col>
            <a-col :span="4">
                <a-config-provider :locale="locale">
                    <a-date-picker format="YYYY-MM-DD" @change="changeDateTime" style="width: 100%;"></a-date-picker>
                </a-config-provider>
            </a-col>
        </a-row>

        <a-table :columns="columns" :data-source="tableData" :loading="loading"
            style="margin-top: 8px;" row-key="module" :scroll="{ y: 'calc( 100vh - 360px )' }">
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.dataIndex === 'title'">
                    <a-typography-text strong style="cursor: pointer;" @click="showPopupDetail(record)">{{ text }}</a-typography-text>
                </template>
                <template v-if="column.dataIndex === 'priority'">
                    <a-tag v-if="text" :color="checkPriority(text).color">{{ checkPriority(text).title }}</a-tag>
                </template>
                <template v-if="['created_by', 'assigned_to'].includes(column.dataIndex)">
                    {{ getUserById(text) }}
                </template>
                <template v-if="column.dataIndex === 'linked_type'">
                    {{ getLinkedType(text) }}
                </template>
                <template v-if="column.dataIndex === 'linked_id'">
                      <span
                          v-if="record.linked_type === 'bidding' || record.linked_type === 'contract'"
                          style="color: #1890ff; cursor: pointer;"
                          @click="goToLinkedDetail(record)"
                      >
                        {{ getLinkedName(record.linked_type, text) }}
                      </span>
                    <span v-else>—</span>
                </template>

                <template v-if="column.dataIndex === 'step_code'">
                    {{ getStepByStepNo(text) }}
                </template>
                <template v-else-if="column.dataIndex === 'action'">
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
import { getDepartments } from '../api/department'
import { getUsers } from '@/api/user';
import { message } from 'ant-design-vue'
import { useRoute, useRouter } from 'vue-router';
import { InfoCircleOutlined, DeleteOutlined, MoreOutlined } from '@ant-design/icons-vue';
import { CONTRACTS_STEPS, BIDDING_STEPS } from '@/common'
import DrawerCreateTask from "../components/common/DrawerCreateTask.vue";
import viVN from 'ant-design-vue/es/locale/vi_VN';

import { getBiddingsAPI } from '@/api/bidding.js'
import { getContractsAPI } from '@/api/contract.js'


const locale = ref(viVN);
const router = useRouter()
const tableData = ref([])
const loading = ref(false)
const openDrawer = ref(false)
const listUser = ref([])
const listDepartment = ref([])
const dataFilter = ref({
    linked_type: null,
    department_id: null,
    status: null,
    priority: null,
    assigned_to: null,
    due_date: null,
})

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
        return { value: ele.id, label: ele.name }
    })
})
const optionsDepartment = computed(() => {
    return listDepartment.value.map(ele => {
        return { value: ele.id, label: ele.name }
    })
})

const columns = [
    // { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
    { title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title' },
    { title: 'Độ ưu tiên', dataIndex: 'priority', key: 'priority' },
    { title: 'Người tạo', dataIndex: 'created_by', key: 'created_by' },
    { title: 'Người được giao', dataIndex: 'assigned_to', key: 'assigned_to' },
    { title: 'Loại Task', dataIndex: 'linked_type', key: 'linked_type' },
    { title: 'Thuộc về', dataIndex: 'linked_id', key: 'linked_id' },
    { title: 'Tiến trình', dataIndex: 'step_code', key: 'step_code' },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px', align:'center' },
]
const changeDateTime = (day, date) => {
    if(date){
        dataFilter.value.due_date = date;
    }else {
        dataFilter.value.due_date = "";
    }
    getInternalTask()
}
const getInternalTask = async () => {
    loading.value = true
    try {
        const response = await getTasks(dataFilter.value);        
        tableData.value = response.data.data ? response.data.data : [];
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
        listContract.value = res.data.data
        console.log('listContract.value ', listContract.value )
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
onMounted(() => {
    getInternalTask();
    getUser();
    getDepartment();
    getBiddings()
    getContracts()
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
