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
        <a-drawer title="Tạo nhiệm vụ mới" :width="700" :open="openDrawer" :body-style="{ paddingBottom: '80px' }"
            :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Tên nhiệm vụ" name="title">
                            <a-input v-model:value="formData.title" placeholder="Nhập tên nhiệm vụ" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Thời gian" name="time">
                            <a-config-provider :locale="locale">
                                <a-range-picker format="DD-MM-YYYY" @change="changeDateTime" style="width: 100%;"></a-range-picker>
                            </a-config-provider>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Độ Ưu tiên" name="priority">
                            <a-select v-model:value="formData.priority" :options="priorityOption" placeholder="Chọn độ ưu tiên" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Gắn tới người dùng" name="assigned_to">
                            <a-select v-model:value="formData.assigned_to" :options="userOption" placeholder="Chọn người dùng" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Loại nhiệm vụ" name="linked_type">
                            <a-select v-model:value="formData.linked_type" :options="linkedTypeOption" placeholder="Chọn loại nhiệm vụ" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12" v-if="['bidding', 'contract'].includes(formData.linked_type)">
                        <a-form-item :label="formData.linked_type == 'bidding' ? 'Liên kết gói thầu' : 'Liên kết hợp đồng'" name="linked_id">
                            <a-select v-model:value="formData.linked_id" :options="linkedIdOption" :placeholder="formData.linked_type == 'bidding' ? 'Chọn gói thầu' : 'Chọn hợp đồng'" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12" v-if="['bidding', 'contract'].includes(formData.linked_type)">
                        <a-form-item label="Bước tiến trình" name="bidding_step_id" >
                            <a-input v-model:value="formData.bidding_step_id" placeholder="Chọn bước tiến trình" />
                        </a-form-item>
                    </a-col>
                    
                    <a-col :span="24">
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" :rows="4"
                                placeholder="Nhập mô tả " />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" @click="submitForm" html-type="submit" :loading="loadingCreate" >Thêm mới</a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getTasks, createTask, updateTask, deleteTask } from '../api/internal'
import { getUsers } from '@/api/user';
import { message } from 'ant-design-vue'
import { useRoute, useRouter } from 'vue-router';
import { InfoCircleOutlined, DeleteOutlined, MoreOutlined } from '@ant-design/icons-vue';
import { CONTRACTS_STEPS, BIDDING_STEPS } from '@/common'
import 'dayjs/locale/vi';
dayjs.locale('vi');
import dayjs from 'dayjs';
import viVN from 'ant-design-vue/es/locale/vi_VN';
import {useUserStore} from '../../src/stores/user'


const store = useUserStore()
const locale = ref(viVN);
const route = useRoute()
const router = useRouter()
const formRef = ref(null);
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)
const listUser = ref([])
const formData = ref({
    title: "",
    created_by: "",
    step_code: "",
    linked_type: null,
    description: "",
    linked_id: "",
    assigned_to: null,
    start_date: "",
    end_date: "",
    status: "",
    priority: null,
    parent_id: null,
    bidding_step_id: null,
})

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
const validateTitle = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập họ và tên');
    } else if(value.length > 200){
        return Promise.reject('Họ và tên không vượt quá 200 ký tự');
    } else {
        return Promise.resolve();
    }
};
const validateTime = async (_rule, value) => {
    
    if (formData.value.start_date === '') {
        return Promise.reject('Vui lòng nhập thời gian nhiệm vụ');
    } else {
        return Promise.resolve();
    }
};
const validatePriority = async (_rule, value) => {    
    if (!formData.value.priority) {
        return Promise.reject('Vui lòng nhập chọn độ ưu tiên');
    } else {
        return Promise.resolve();
    }
};
const validateAsigned = async (_rule, value) => {
  if (!formData.value.assigned_to) {
    return Promise.reject('Vui lòng chọn người phụ trách');
  } else {
    return Promise.resolve();
  }
};
const validateLinkedType = async (_rule, value) => {    
    if (!formData.value.linked_type) {
        return Promise.reject('Vui lòng chọn loại nhiệm vụ');
    } else {
        return Promise.resolve();
    }
};
const validateDescription = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập mô tả nhiệm vụ');
    } else {
        return Promise.resolve();
    }
};
const rules = computed(() => {
    return {
        title: [{ required: true, validator: validateTitle, trigger: 'change' }],
        time: [{ required: true, validator: validateTime, trigger: 'change' }],
        priority: [{ required: true, validator: validatePriority, trigger: 'change' }],
        assigned_to: [{ required: true, validator: validateAsigned, trigger: 'change' }],
        linked_type: [{ required: true, validator: validateLinkedType,  trigger: 'change' }],
        description: [{ required: true, validator: validateDescription,  trigger: 'change' }],
    }
})
const priorityOption = ref([
    {value: "low", label: "Thấp"},
    {value: "normal", label: "Thường"},
    {value: "hight", label: "Cao"},
])
const linkedTypeOption = ref([
    {value: "bidding", label: "Gói thầu"},
    {value: "contract", label: "Hợp đồng"},
    {value: "internal", label: "Nhiệm vụ nội bộ"},
])

const linkedIdOption = computed(()=>{
    return [];
})

const userOption =  computed(()=>{
    if(!listUser.value || !listUser.value.length){
        return[]
    }else {
        return listUser.value.map(ele => {
            return {
                value: ele.id,
                label: ele.name,
            }
        })
    }
})

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
const getBiddingTask = async () => {
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
const getContractTask = async () => {
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

const changeDateTime = (day, date) => {
    if(day){
        formData.value.start_date = convertDateFormat(date[0]);
        formData.value.end_date = convertDateFormat(date[1]);
    }else {
        formData.value.start_date = "";
        formData.value.end_date = "";
    }
    
}
const convertDateFormat = (dateStr) =>  {
    const [day, month, year] = dateStr.split('-');
    return `${year}-${month}-${day}`;
}

const submitForm = async() => {    
    try {
        await formRef.value?.validate()
        createDrawerInternal();
    } catch (error) {
        
    }
}
const createDrawerInternal = async () => {
    if(loadingCreate.value){
        return;
    }
    formData.value.created_by = store.currentUser.id;
    loadingCreate.value = true;
    try {
        await createTask(formData.value);
        getInternalTask();
        onCloseDrawer();
    } catch (e) {
        message.error('Thêm mới nhiệm vụ không thành công')
    } finally {
        loadingCreate.value = false
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

    // formData.value.title = record.title;
    // formData.value.created_by = record.created_by;
    // formData.value.priority = record.priority;
    // formData.value.step_code = record.step_code;
    // formData.value.linked_type = record.linked_type;
    // openDrawer.value = true;
}
const showPopupCreate = () => {
    openDrawer.value = true;
}
const onCloseDrawer = () => {
    openDrawer.value = false;
    setDefaultData();
    resetFormValidate()
}
const setDefaultData = () =>{
    formData.value = {
        title: "",
        created_by: "",
        step_code: "",
        linked_type: null,
        description: "",
        linked_id: "",
        assigned_to: null,
        start_date: "",
        end_date: "",
        status: "",
        priority: null,
        parent_id: null,
        bidding_step_id: null,
    }
}
const resetFormValidate = () => {
    formRef.value.resetFields();
};

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
        case 'bidding':
            return "Gói thầu";
        case 'bidding':
            return "Gói thầu";
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
