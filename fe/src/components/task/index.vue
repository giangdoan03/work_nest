<template>
    <div class="task">
        <div class="action">
            <a-button type="primary" v-if="!isEditMode" style="margin-right: 8px;" @click="editTask">Chỉnh sửa</a-button>
            <a-button type="primary" v-if="isEditMode" style="margin-right: 8px;" @click="saveEditTask">Lưu</a-button>
            <a-button v-if="isEditMode" style="margin-right: 8px;" @click="cancelEditTask">Hủy</a-button>
            <a-button ><EllipsisOutlined /></a-button>
        </div>
        <div class="task-info">
            <div class="task-info-left">
                <div class="task-info-content">
                    <a-form ref="formRef" :model="formData" :rules="isEditMode ? rules : ''" layout="vertical">
                        <div class="task-in">
                            <a-row :gutter="16">
                                <a-col :span="12">
                                    <a-form-item label="Tên" name="title">
                                        <a-typography-text v-if="!isEditMode">{{ formData.title }}</a-typography-text>
                                        <a-input v-else v-model:value="formData.title" placeholder="Nhập tên nhiệm vụ" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12">
                                    <a-form-item label="Độ Ưu tiên" name="priority">
                                        <a-typography-text v-if="!isEditMode">{{ getPriorityName(formData.priority) }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.priority" :options="priorityOption" placeholder="Chọn độ ưu tiên" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12">
                                    <a-form-item label="Thời gian" name="time">
                                        <a-typography-text v-if="!isEditMode">{{ formData.start_date + " → " + formData.end_date}}</a-typography-text>
                                        <a-config-provider :locale="locale">
                                            <a-range-picker  v-if="isEditMode" format="DD-MM-YYYY" @change="changeDateTime" style="width: 100%;"></a-range-picker>
                                        </a-config-provider>
                                    </a-form-item>
                                </a-col>
                                
                                <a-col :span="12">
                                    <a-form-item label="Gắn tới người dùng" name="assigned_to">
                                        <a-typography-text v-if="!isEditMode">{{ getUserById(formData.assigned_to) }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.assigned_to" :options="userOption" placeholder="Chọn người dùng" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12">
                                    <a-form-item label="Loại nhiệm vụ" name="linked_type">
                                        <a-typography-text v-if="!isEditMode">{{ formData.title }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.linked_type" :options="linkedTypeOption" placeholder="Chọn loại nhiệm vụ" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12" v-if="['bidding', 'contract'].includes(formData.linked_type)">
                                    <a-form-item :label="formData.linked_type == 'bidding' ? 'Liên kết gói thầu' : 'Liên kết hợp đồng'" name="linked_id">
                                        <a-typography-text v-if="!isEditMode">{{ formData.title }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.linked_id" :options="linkedIdOption" :placeholder="formData.linked_type == 'bidding' ? 'Chọn gói thầu' : 'Chọn hợp đồng'" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12" v-if="['bidding', 'contract'].includes(formData.linked_type)">
                                    <a-form-item label="Bước tiến trình" name="bidding_step_id" >
                                        <a-typography-text v-if="!isEditMode">{{ formData.title }}</a-typography-text>
                                        <a-input v-else v-model:value="formData.bidding_step_id" placeholder="Chọn bước tiến trình" />
                                    </a-form-item>
                                </a-col>
                                
                                <a-col :span="24">
                                    <a-form-item label="Mô tả" name="description">
                                        <a-typography-text v-if="!isEditMode">{{ formData.description }}</a-typography-text>
                                        <a-textarea v-else v-model:value="formData.description" :rows="4"
                                            placeholder="Nhập mô tả " />
                                    </a-form-item>
                                </a-col>
                            </a-row>
                        </div>
                        <div class="task-in">Content</div>
                        <div class="task-in-end">Content</div>
                    </a-form>
                </div>
            </div>
            <div class="task-info-left">
    
            </div>
        </div>
    </div>
</template>
<script setup>
import { EllipsisOutlined } from '@ant-design/icons-vue';
import { ref, computed, onMounted } from 'vue';
import { message } from 'ant-design-vue'
import 'dayjs/locale/vi';
dayjs.locale('vi');
import dayjs from 'dayjs';
import viVN from 'ant-design-vue/es/locale/vi_VN';
import { getUsers } from '@/api/user';
import { useRoute, useRouter } from 'vue-router';
import { getTaskDetail } from '@/api/internal';


const route = useRoute();
const locale = ref(viVN);
const isEditMode = ref(false);

const listUser = ref([])
const loading = ref(false)

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
});
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
const linkedIdOption = computed(()=>{
    return [];
})
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
const getUserById = (userId) =>  {
    let data = listUser.value.find(ele => ele.id == userId);
    if(!data){
        return "" ;
    }
    return data.name;
}
const getPriorityName = (priorityId) =>  {
    let data = priorityOption.value.find(ele => ele.value == priorityId);
    if(!data){
        return "" ;
    }
    return data.label;
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
const editTask = () => {
    isEditMode.value = true;
}
const saveEditTask = () => {
    isEditMode.value = false;
}
const cancelEditTask = () => {
    isEditMode.value = false;
}
const getDetailTaskById = async () => {
    await getTaskDetail(route.params.id).then(res => {
        console.log(res);
        formData.value = res.data
    }).catch(err => {

    })
}
onMounted(() => {
    getDetailTaskById();
    getUser();    
})

</script>
<style scoped>
.task-info{
    margin-top: 16px;
}
.task-info-content{
    border: 1px solid #bebebece;
    border-radius: 8px;
}
.task-in{
    border-bottom: 1px solid #bebebece;
    padding: 14px;
}
.task-in-end{
    padding: 14px;
    border-bottom: none;
}

:deep(label){
    color: #999999 !important;
}
:deep(.ant-form-item){

}
</style>