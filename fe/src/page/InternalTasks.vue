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
                    {{ getStepById(text) }}
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
                    <a-col :span="24">
                        <a-form-item label="Tên nhiệm vụ" name="title">
                            <a-range-picker></a-range-picker>
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
                        <a-form-item label="Độ Ưu tiên" name="priority">
                            <a-select v-model:value="formData.priority" :options="priorityOption" placeholder="Chọn độ ưu tiên" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Bước tiến trình" name="step_code">
                            <a-input v-model:value="formData.step_code" placeholder="Nhập Mật khẩu" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Loại nhiệm vụ" name="linked_type">
                            <a-select v-model:value="formData.linked_type" :options="linkedTypeOption" placeholder="Chọn loại nhiệm vụ" />
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
                    <a-button type="primary" @click="submitForm" html-type="submit" :loading="loadingCreate" >{{ selectedInternal ? 'Cập nhật' : 'Thêm mới' }}</a-button>
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

const route = useRoute()
const router = useRouter()
const formRef = ref(null);
const selectedInternal = ref(null)
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

function validateEmailtype(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}
function isValidPhoneNumber(phone) {
  const regex = /^(0|\+84)(3[2-9]|5[6|8|9]|7[0|6-9]|8[1-5]|9[0-9])[0-9]{7}$/;
  return regex.test(phone);
}
const validateName = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập họ và tên');
    } else if(value.length > 200){
        return Promise.reject('Họ và tên không vượt quá 200 ký tự');
    } else {
        return Promise.resolve();
    }
};
const validateEmail = async (_rule, value) => {
    if (value === '') {
        return Promise.reject('Vui lòng nhập Email');
    } else if(value.length > 200){
        return Promise.reject('Email không vượt quá 200 ký tự');
    } else if(!validateEmailtype(value)){
        return Promise.reject('Vui lòng nhập đúng định dạng email');
    } else {
        return Promise.resolve();
    }
};
const validatePhone = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập số điện thoại');
    } else if(value.length > 20){
        return Promise.reject('Số điện thoại không vượt quá 20 ký tự');
    } else if(!isValidPhoneNumber(value)){
        return Promise.reject('Vui lòng nhập đúng số điện thoại');
    } else {
        return Promise.resolve();
    }
};
const validatePass = async (_rule, value) => {
  if (value === '') {
    return Promise.reject('Vui lòng nhập lại');
  } else {
    return Promise.resolve();
  }
};
const validateConfirmPassword = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập lại mật khẩu mới');
    } else if (value !== formData.value.step_code) {
        return Promise.reject("Mật khẩu không khớp");
    } else {
        return Promise.resolve();
    }
};
const rules = computed(() => {
    return {
        title: [{ required: true, validator: validateName, trigger: 'change' }],
        created_by: [{ required: true, validator: validateEmail, trigger: 'change' }],
        priority: [{ required: true, validator: validatePhone, trigger: 'change' }],
        step_code: [{ required: true, validator: validatePass, trigger: 'change' }],
        linked_type: [{ required: true, validator: validateConfirmPassword,  trigger: 'change' }],
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

const getInternal = async () => {
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
const submitForm = async() => {
    try {
        await formRef.value?.validate()
        if(selectedInternal.value){
            updateDrawerInternal();
        }else{
            createDrawerInternal();
        }
    } catch (error) {
        
    }
}
const createDrawerInternal = async () => {
    if(loadingCreate.value){
        return;
    }
    loadingCreate.value = true;
    try {
        await createTask(formData.value);
        getInternal();
        onCloseDrawer();
    } catch (e) {
        message.error('Thêm mới nhiệm vụ không thành công')
    } finally {
        loadingCreate.value = false
    }
}
const updateDrawerInternal = async () => {
    await formRef.value?.validate()
    if(loadingCreate.value){
        return;
    }
    loadingCreate.value = true;
    try {
        await updateTask(selectedInternal.value.id, formData.value);
        getInternal();
        onCloseDrawer()
    } catch (e) {
        message.error('Cập nhật nhiệm vụ không thành công')
    } finally {
        loadingCreate.value = false
    }
}
const deleteConfirm = async (internalId) => {
    try {
        await deleteTask(internalId);
        getInternal();
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

    // selectedInternal.value = record;
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
    selectedInternal.value = null;
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
    if(text == 'low'){
        return { title: "Thấp", color: "success"};
    }else if(text == 'normal'){
        return { title: "Thường", color: "warning"};
    }else if(text == 'high'){
        return { title: "Cao", color: "error"};
    }
    return { title: "", color: ""};
};

const getUserById = (userId) =>  {
    let data = listUser.value.find(ele => ele.id == userId);
    if(!data){
        return "" ;
    }
    return data.name;
}
const getLinkedType = (text) =>  {
    if(text == 'bidding'){
        return "Gói thầu";
    }else if(text == 'contract'){
        return "Hợp đồng";
    }else if(text == 'internal'){
        return "Nhiệm vụ";
    }
    return "";
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

const getStepById = (text) =>  {
    let data = CONTRACTS_STEPS.find(ele => ele.step_no == text);
    if(!data){
        data = BIDDING_STEPS.find(ele => ele.step_no == text);
        if(!data){
            return "" ;
        }
    }
    return data.name;
}

onMounted(() => {
    getInternal();
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
