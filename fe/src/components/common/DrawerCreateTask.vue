<template>
    <div class="draw-create-task">
        <a-drawer title="Tạo nhiệm vụ mới" :width="700" :open="props.openDrawer" :body-style="{ paddingBottom: '80px' }"
                  :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Tên nhiệm vụ" name="title">
                            <a-input v-model:value="formData.title" placeholder="Nhập tên nhiệm vụ"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Thời gian" name="time">
                            <a-config-provider :locale="locale">
                                <a-range-picker v-model:value="dateRange" format="DD-MM-YYYY" @change="changeDateTime" style="width: 100%;"></a-range-picker>
                            </a-config-provider>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Độ Ưu tiên" name="priority">
                            <a-select v-model:value="formData.priority" :options="priorityOption" placeholder="Chọn độ ưu tiên"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Trạng thái" name="status">
                            <a-select v-model:value="formData.status" :options="statusOption" placeholder="Chọn trạng thái"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Gắn tới người dùng" name="assigned_to">
                            <a-select v-model:value="formData.assigned_to" :options="userOption" placeholder="Chọn người dùng"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Loại nhiệm vụ" name="linked_type">
                            <a-select v-model:value="formData.linked_type" :options="linkedTypeOption" @change="handleChangeLinkedType" placeholder="Chọn loại nhiệm vụ"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Phòng ban" name="department_id">
                            <a-select v-model:value="formData.department_id" :options="departmentOptions" @change="handleChangeDepartment" placeholder="Chọn phòng ban"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12" v-if="['bidding', 'contract'].includes(formData.linked_type)">
                        <a-form-item :label="formData.linked_type === 'bidding' ? 'Liên kết gói thầu' : 'Liên kết hợp đồng'" name="linked_id">
                            <a-select v-model:value="formData.linked_id" :options="linkedIdOption" @change="handleChangeLinkedId"
                                      :placeholder="formData.linked_type === 'bidding' ? 'Chọn gói thầu' : 'Chọn hợp đồng'"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12" v-if="['bidding', 'contract'].includes(formData.linked_type)">
                        <a-form-item label="Bước tiến trình" name="step_code">
                            <a-select v-model:value="formData.step_code" :options="stepOption"
                                      :disabled="!formData.linked_id"
                                      :placeholder="formData.linked_type === 'bidding' ? 'Chọn bước gói thầu' : 'Chọn bước hợp đồng'"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="24">
                        <a-form-item label="Cấp duyệt" name="approval_steps">
                            <a-radio-group v-model:value="formData.approval_steps">
                                <a-radio :value="0">Không cấp duyệt</a-radio>
                                <a-radio :value="1">1 cấp duyệt</a-radio>
                                <a-radio :value="2">2 cấp duyệt</a-radio>
                            </a-radio-group>
                        </a-form-item>
                    </a-col>

                    <a-col :span="24">
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" :rows="4" placeholder="Nhập mô tả "/>
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" @click="submitForm" html-type="submit" :loading="loadingCreate">Thêm mới
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>
<script setup>
import {ref, onMounted, computed, watch} from 'vue'
import {useUserStore} from '@/stores/user.js'
import {createTask, updateTask} from '@/api/task.js'
import {getBiddingsAPI} from '@/api/bidding.js'
import {getContractsAPI} from '@/api/contract.js'
import {message} from 'ant-design-vue'
import {useRoute} from 'vue-router';
import {getContractStepsAPI} from '@/api/contract-steps';
import {getBiddingStepsAPI} from '@/api/bidding';


import dayjs from 'dayjs';

dayjs.locale('vi');
import viVN from 'ant-design-vue/es/locale/vi_VN';

const props = defineProps({
    openDrawer: Boolean,
    taskParent: String,
    listUser: {
        type: Array,
        default: () => [],
    },
})
const emit = defineEmits(['update:openDrawer', 'submitForm'])

const store = useUserStore()

const locale = ref(viVN);
const route = useRoute()

const loadingCreate = ref(false)
const formRef = ref(null);
const tableData = ref([])
const loading = ref(false)
const listBidding = ref([])
const listContract = ref([])
const dateRange = ref()

const formData = ref({
    title: "",
    created_by: "",
    step_code: null,
    linked_type: null,
    description: "",
    linked_id: null,
    assigned_to: null,
    start_date: "",
    end_date: "",
    status: null,
    priority: null,
    parent_id: null,
    approval_steps: 0,
    department_id: null
})

const setDefaultData = () => {
    formData.value = {
        title: "",
        created_by: "",
        step_code: null,
        linked_type: null,
        description: "",
        linked_id: null,
        assigned_to: null,
        start_date: "",
        end_date: "",
        status: "",
        priority: null,
        parent_id: props.taskParent ? props.taskParent : null,
        department_id: ""
    }
    dateRange.value = null
}

const validateTitle = async (_rule, value) => {
    if (value === '') {
        return Promise.reject('Vui lòng nhập họ và tên');
    } else if (value.length > 200) {
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

const validateDepartment = async (_rule, value) => {
    if (!formData.value.department_id) {
        return Promise.reject('Vui lòng chọn phòng ban');
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
        title: [{required: true, validator: validateTitle, trigger: 'change'}],
        time: [{required: true, validator: validateTime, trigger: 'change'}],
        priority: [{required: true, validator: validatePriority, trigger: 'change'}],
        assigned_to: [{required: true, validator: validateAsigned, trigger: 'change'}],
        linked_type: [{required: true, validator: validateLinkedType, trigger: 'change'}],
        description: [{required: true, validator: validateDescription, trigger: 'change'}],
        department_id: [{required: true, validator: validateDepartment, trigger: 'change'}],
        approval_steps: [{ required: true, message: 'Vui lòng chọn cấp duyệt' }]
    }
})

const priorityOption = ref([
    {value: "low", label: "Thấp"},
    {value: "normal", label: "Thường"},
    {value: "hight", label: "Cao"},
])
const statusOption = computed(() => {
    return [
        {value: 'todo', label: "Việc cần làm"},
        {value: 'doing', label: "Đang thực hiện"},
        {value: 'pending_approval', label: "Đã gửi duyệt", color: "gold" },
        {value: 'done', label: "Hoàn thành"},
        {value: 'overdue', label: "Quá hạn"},
    ]
})
const linkedTypeOption = ref([
    {value: "bidding", label: "Gói thầu"},
    {value: "contract", label: "Hợp đồng"},
    {value: "internal", label: "Nhiệm vụ nội bộ"},
])

const departmentOptions = ref([
    { value: 'HCNS', label: 'Phòng Hành chính - Nhân sự' },
    { value: 'TCKT', label: 'Phòng Tài chính - Kế toán' },
    { value: 'KD', label: 'Phòng Kinh doanh' },
    { value: 'TM', label: 'Phòng Thương mại' },
    { value: 'DVKT', label: 'Phòng Dịch vụ - Kỹ thuật' },
])


const stepOption = ref([])
const linkedIdOption = computed(() => {
    if (formData.value.linked_type === 'bidding') {
        return listBidding.value.map(ele => {
            return {value: ele.id, label: ele.title}
        })
    } else if (formData.value.linked_type === 'contract') {
        return listContract.value.map(ele => {
            return {value: ele.id, label: ele.title}
        })
    } else return [];
})
const userOption = computed(() => {
    if (!props.listUser || !props.listUser.length) {
        return []
    } else {
        return props.listUser.map(ele => {
            return {
                value: ele.id,
                label: ele.name,
            }
        })
    }
})

//METHOD
const handleChangeLinkedType = () => {
    formData.value.linked_id = null;
    formData.value.step_code = null;
};

const handleChangeDepartment = () => {
    // formData.value.id_department = null;
    // formData.value.step_code = null;
};


const handleChangeLinkedId = () => {
    if (formData.value.linked_type === 'bidding') {
        getBiddingStep()
    } else if (formData.value.linked_type === 'contract') {
        getContractStep()
    }
};
const getContractStep = async () => {
    await getContractStepsAPI(formData.value.linked_id).then(res => {
        stepOption.value = res.data ? res.data.map(ele => {
            return {value: ele.step_number, label: ele.title, step_id: ele.id}
        }) : []
    }).catch(err => {

    })
}
const getBiddingStep = async () => {
    await getBiddingStepsAPI(formData.value.linked_id).then(res => {
        stepOption.value = res.data ? res.data.map(ele => {
            return {value: ele.step_number, label: ele.title, step_id: ele.id}
        }) : []
    }).catch(err => {

    })
}
const createDrawerInternal = async () => {
    if (loadingCreate.value) {
        return;
    }
    formData.value.created_by = store.currentUser.id;
    loadingCreate.value = true;
    try {
        await createTask(formData.value);
        message.success('Thêm mới nhiệm vụ thành công')
        emit('submitForm');
        onCloseDrawer();
    } catch (e) {
        message.error('Thêm mới nhiệm vụ không thành công')
    } finally {
        loadingCreate.value = false
    }
}
const onCloseDrawer = () => {
    emit('update:openDrawer', false)
    setDefaultData();
    resetFormValidate()
}
const getBiddingTask = async () => {
    loading.value = true
    try {
        const response = await getBiddingsAPI();
        listBidding.value = response.data.data ? response.data.data : [];
    } catch (e) {
        message.error('Không thể tải nhiệm vụ')
    } finally {
        loading.value = false
    }
}
const getContractTask = async () => {
    loading.value = true
    try {
        const response = await getContractsAPI();
        listContract.value = response.data ? response.data : [];
    } catch (e) {
        message.error('Không thể tải nhiệm vụ')
    } finally {
        loading.value = false
    }
}
const changeDateTime = (day, date) => {
    if (day) {
        formData.value.start_date = convertDateFormat(date[0]);
        formData.value.end_date = convertDateFormat(date[1]);
    } else {
        formData.value.start_date = "";
        formData.value.end_date = "";
    }

}
const convertDateFormat = (dateStr) => {
    const [day, month, year] = dateStr.split('-');
    return `${year}-${month}-${day}`;
}

const submitForm = async () => {
    try {
        await formRef.value?.validate()
        await createDrawerInternal();
    } catch (error) {

    }
}
const resetFormValidate = () => {
    formRef.value.resetFields();
};

watch(() => formData.value.step_code, (newCode) => {
    const found = stepOption.value.find(item => item.value === newCode)
    formData.value.step_id = found ? found.step_id : null;
})

//Watch onMounted
onMounted(() => {
    if (props.taskParent) {
        formData.value.parent_id = props.taskParent;
    }
    getBiddingTask()
    getContractTask()
    handleChangeLinkedId()
})

</script>
<style scoped>

</style>