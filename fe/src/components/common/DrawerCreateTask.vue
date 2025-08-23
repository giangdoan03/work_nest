<template>
    <div class="draw-create-task">
        <a-drawer title="Tạo nhiệm vụ mới" :width="700" :open="props.openDrawer" :body-style="{ paddingBottom: '80px' }"
                  :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Tên nhiệm vụ" name="title">
                            <a-input v-model:value="formData.title" placeholder="Nhập tên nhiệm vụ"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Người đề nghị" name="proposed_by">
                            <a-select
                                v-model:value="formData.proposed_by"
                                :options="userOption"
                                placeholder="Chọn người dùng"
                                show-search
                                option-filter-prop="label"
                                :filter-option="(input, option) =>
        normalizeText(option?.label ?? '').includes(normalizeText(input))
      "
                                :getPopupContainer="trigger => trigger.parentNode"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Thời gian" name="time">
                            <a-config-provider :locale="locale">
                                <a-range-picker v-model:value="dateRange" format="DD-MM-YYYY" @change="changeDateTime"
                                                style="width: 100%;"
                                                :getPopupContainer="triggerNode => triggerNode.parentNode"></a-range-picker>
                            </a-config-provider>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Độ Ưu tiên" name="priority">
                            <a-select v-model:value="formData.priority" :options="priorityOption"
                                      placeholder="Chọn độ ưu tiên"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Trạng thái" name="status">
                            <a-select v-model:value="formData.status" :options="statusOption"
                                      placeholder="Chọn trạng thái"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Người thực hiện" name="assigned_to">
                            <a-select
                                v-model:value="formData.assigned_to"
                                :options="userOption"
                                placeholder="Chọn người dùng"
                                show-search
                                option-filter-prop="label"
                                :filter-option="(input, option) =>
        normalizeText(option?.label ?? '').includes(normalizeText(input))
      "
                                :getPopupContainer="trigger => trigger.parentNode"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Loại nhiệm vụ" name="linked_type">
                            <template v-if="!props.type">
                                <a-select
                                    v-model:value="formData.linked_type"
                                    :options="linkedTypeOption"
                                    @change="handleChangeLinkedType"
                                    placeholder="Chọn loại nhiệm vụ"
                                />
                            </template>
                            <template v-else>
                                <a-input :value="getLinkedTypeLabel(props.type)" disabled/>
                            </template>
                        </a-form-item>
                    </a-col>

                    <a-col :span="12">
                        <a-form-item label="Phòng ban" name="department_id">
                            <a-select v-model:value="formData.id_department" :options="departmentOptions"
                                      @change="handleChangeDepartment" placeholder="Chọn phòng ban"/>
                        </a-form-item>
                    </a-col>
                    <!-- ==================== BIDDING ==================== -->
                    <a-col :span="12" v-if="formData.linked_type === 'bidding'">
                        <a-form-item label="Liên kết gói thầu" name="linked_id">
                            <a-select
                                v-model:value="formData.linked_id"
                                :options="linkedIdOption"
                                @change="handleChangeLinkedId"
                                placeholder="Chọn gói thầu"
                                :disabled="!!formData.linked_id"
                            />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12" v-if="formData.linked_type === 'bidding'">
                        <a-form-item label="Bước gói thầu" name="step_code">
                            <a-select
                                v-model:value="formData.step_code"
                                :options="stepOption"
                                :disabled="!formData.linked_id || !!formData.step_code"
                                placeholder="Chọn bước gói thầu"
                            />
                        </a-form-item>
                    </a-col>

                    <!-- ==================== CONTRACT ==================== -->
                    <a-col :span="12" v-if="formData.linked_type === 'contract'">
                        <a-form-item label="Liên kết hợp đồng" name="linked_id">
                            <a-select
                                v-model:value="formData.linked_id"
                                :options="linkedIdOption"
                                @change="handleChangeLinkedId"
                                placeholder="Chọn hợp đồng"
                                :disabled="!!formData.linked_id"
                            />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12" v-if="formData.linked_type === 'contract'">
                        <a-form-item label="Bước hợp đồng" name="step_code">
                            <a-select
                                v-model:value="formData.step_code"
                                :options="stepOption"
                                :disabled="!formData.linked_id || !!formData.step_code"
                                placeholder="Chọn bước hợp đồng"
                            />
                        </a-form-item>
                    </a-col>

                    <a-col :span="24">
                        <a-form-item
                            label="Cấp duyệt"
                            name="approval_steps"
                            :rules="[{ validator: validateApprovalSteps, trigger: 'change' }]"
                        >
                            <a-radio-group v-model:value="formData.approval_steps">
                                <!--                                <a-radio :value="0">Không cấp duyệt</a-radio>-->
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
                    <a-button type="primary" @click="submitForm" html-type="submit" :loading="loadingCreate">Lưu lại
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>
<script setup>
import {ref, onMounted, computed, watch} from 'vue'
import {useUserStore} from '@/stores/user.js'
import {createTask, getTasksByBiddingStep, getTasksByContractStep} from '@/api/task.js'
import {getBiddingAPI, getBiddingsAPI} from '@/api/bidding.js'
import {getContractAPI, getContractsAPI} from '@/api/contract.js'
import {message} from 'ant-design-vue'
import {getContractStepsAPI} from '@/api/contract-steps';
import {getBiddingStepsAPI} from '@/api/bidding';
import {getDepartments} from '@/api/department'

import {useStepStore} from '@/stores/step'

const stepStore = useStepStore()

const emit = defineEmits(['update:openDrawer', 'submitForm'])
const store = useUserStore()
const selectedStep = computed(() => stepStore.selectedStep)
import {useCommonStore} from '@/stores/common'

const commonStore = useCommonStore()

import dayjs from 'dayjs';

dayjs.locale('vi');
import viVN from 'ant-design-vue/es/locale/vi_VN';
import {defineEmits, defineProps} from "@vue/runtime-core";

const props = defineProps({
    openDrawer: Boolean,
    taskParent: String,
    listUser: {
        type: Array,
        default: () => [],
    },
    type: {
        type: String,
        default: 'internal' // fallback nếu không truyền
    },
    taskMeta: {
        type: Object,
        default: () => ({})
    },
})


const locale = ref(viVN);

const loadingCreate = ref(false)
const formRef = ref(null);
const loading = ref(false)
const listBidding = ref([])
const listContract = ref([])
const dateRange = ref()
const listDepartment = ref([])
const formData = ref({
    title: "",
    created_by: "",
    step_code: null,
    linked_type: null,
    description: "",
    linked_id: null,
    assigned_to: null,
    proposed_by: null,
    start_date: "",
    end_date: "",
    status: null,
    priority: null,
    parent_id: null,
    approval_steps: 1,
    id_department: null
})

// SETUP

const setDefaultData = () => {
    formData.value = {
        title: "",
        created_by: null,
        step_code: null,
        linked_type: null,
        description: "",
        linked_id: null,
        assigned_to: null,
        start_date: "",
        end_date: "",
        status: null,
        priority: null,
        parent_id: props.taskParent ? props.taskParent : null,
        id_department: null,
        approval_steps: null
    }
    dateRange.value = null
}

const normalizeText = (s = '') =>
    s.toString()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase();

const validateTitle = async (_rule, value) => {
    if (value === '') {
        return Promise.reject('Vui lòng nhập họ và tên');
    } else if (value.length > 200) {
        return Promise.reject('Họ và tên không vượt quá 200 ký tự');
    } else {
        return Promise.resolve();
    }
};
const validateTime = async (_rule) => {

    if (formData.value.start_date === '') {
        return Promise.reject('Vui lòng nhập thời gian nhiệm vụ');
    } else {
        return Promise.resolve();
    }
};
const validatePriority = async (_rule) => {
    if (!formData.value.priority) {
        return Promise.reject('Vui lòng nhập chọn độ ưu tiên');
    } else {
        return Promise.resolve();
    }
};
const validateAsigned = async (_rule) => {
    if (!formData.value.assigned_to) {
        return Promise.reject('Vui lòng chọn người phụ trách');
    } else {
        return Promise.resolve();
    }
};

const validateProposed = async (_rule) => {
    if (!formData.value.proposed_by) {
        return Promise.reject('Vui lòng chọn người đề nghị');
    } else {
        return Promise.resolve();
    }
};
const validateLinkedType = async (_rule) => {
    if (!formData.value.linked_type) {
        return Promise.reject('Vui lòng chọn loại nhiệm vụ');
    } else {
        return Promise.resolve();
    }
};

const validateDepartment = async (_rule) => {
    if (!formData.value.id_department) {
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

const validateApprovalSteps = async (_rule, value) => {
    if (value === undefined || value === null || value === '') {
        return Promise.reject('Vui lòng chọn cấp duyệt');
    } else if (![1, 2].includes(value)) {
        return Promise.reject('Giá trị cấp duyệt không hợp lệ');
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
        proposed_by: [{required: true, validator: validateProposed, trigger: 'change'}],
        linked_type: [{required: true, validator: validateLinkedType, trigger: 'change'}],
        description: [{required: true, validator: validateDescription, trigger: 'change'}],
        department_id: [{required: true, validator: validateDepartment, trigger: 'change'}],
        approval_steps: [{required: true, message: 'Vui lòng chọn cấp duyệt'}]
    }
})

const priorityOption = ref([
    {value: "low", label: "Thấp"},
    {value: "normal", label: "Thường"},
    {value: "high", label: "Cao"},
])
const statusOption = computed(() => {
    return [
        {value: 'doing', label: "Đang chuẩn bị"},
        {value: 'pending_approval', label: "Đã gửi duyệt", color: "gold"},
        {value: 'done', label: "Hoàn thành"},
        {value: 'overdue', label: "Quá hạn"},
    ]
})
const linkedTypeOption = ref([
    {value: "bidding", label: "Gói thầu"},
    {value: "contract", label: "Hợp đồng"},
    {value: "internal", label: "Nhiệm vụ nội bộ"},
])

const departmentOptions = computed(() => {
    return listDepartment.value.map(ele => {
        return {value: ele.id, label: ele.name}
    })
})

const stepOption = ref([])
const linkedIdOption = computed(() => {
    if (formData.value.linked_type === 'bidding') {
        return listBidding.value.map(ele => ({
            value: String(ele.id),
            label: ele.title,
        }))
    } else if (formData.value.linked_type === 'contract') {
        return listContract.value.map(ele => ({
            value: String(ele.id),
            label: ele.title,
        }))
    } else return []
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
const getDepartment = async () => {
    try {
        const response = await getDepartments();
        listDepartment.value = response.data;
    } catch (e) {
        message.error('Không thể tải người dùng')
    } finally {
    }
}
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

        if (formData.value.step_code) {
            const match = stepOption.value.find(opt => opt.value === formData.value.step_code)
            if (!match) {
                formData.value.step_code = null // hoặc bạn có thể tự tạo option đặc biệt
            }
        }
    })
}
const getBiddingStep = async () => {
    await getBiddingStepsAPI(formData.value.linked_id).then(res => {
        stepOption.value = res.data ? res.data.map(ele => {
            return {value: ele.step_number, label: ele.title, step_id: ele.id}
        }) : []

        if (formData.value.step_code) {
            const match = stepOption.value.find(opt => opt.value === formData.value.step_code)
            if (!match) {
                formData.value.step_code = null // hoặc bạn có thể tự tạo option đặc biệt
            }
        }

    })
}
const createDrawerInternal = async () => {
    if (loadingCreate.value) return;

    formData.value.created_by = store.currentUser.id;
    formData.value.step_id = selectedStep.value?.id ?? null;

    loadingCreate.value = true;

    try {
        // 1. Gọi API tạo task
        const res = await createTask(formData.value);
        message.success('Thêm mới nhiệm vụ thành công');

        // 2. Làm mới danh sách nhiệm vụ của Step hiện tại
        await refreshStepTasks();

        // 3. Emit cho component cha
        emit('submitForm', res.data);

        // 4. Đóng drawer
        onCloseDrawer();
    } catch (err) {
        console.error('[createDrawerInternal] error:', err);
        message.error('Thêm mới nhiệm vụ không thành công');
    } finally {
        loadingCreate.value = false;
    }
};

// ==================== HÀM CON ====================
async function refreshStepTasks() {
    const stepId = selectedStep.value?.id;
    if (!stepId) return;

    const filter = {};
    const user = store.currentUser;

    // lọc theo role
    if (user?.role_id === 3) {
        filter.assigned_to = user.id;
    } else if (user?.role_id === 2) {
        filter.id_department = user.department_id;
    }

    const linkedType = selectedStep.value?.linked_type || formData.value.linked_type || 'bidding';

    // gọi API phù hợp
    let resTasks;
    if (linkedType === 'contract') {
        resTasks = await getTasksByContractStep(stepId, filter);
    } else {
        resTasks = await getTasksByBiddingStep(stepId, filter);
    }

    const tasks = Array.isArray(resTasks.data?.data)
        ? resTasks.data.data
        : (resTasks.data || []);

    stepStore.setRelatedTasks(tasks);
}

const getNameLinked = async (id) => {
    if (!id) return 'Trống';

    if (formData.value.linked_type === 'bidding') {
        const found = listBidding.value.find(x => x.id === id);
        if (found) return found.title;

        const res = await getBiddingAPI(id);
        return res.data?.title ?? 'Gói thầu không tồn tại';
    }

    if (formData.value.linked_type === 'contract') {
        const found = listContract.value.find(x => x.id === id);
        if (found) return found.title;

        const res = await getContractAPI(id);
        return res.data?.title ?? 'Hợp đồng không tồn tại';
    }

    return 'Trống';
};

// 3. watch để cập nhật tên khi linked_id hoặc linked_type thay đổi
const linkedName = ref('');
watch(
    () => [formData.value.linked_id, formData.value.linked_type],
    async ([id]) => {
        linkedName.value = await getNameLinked(id);
    },
    {immediate: true}
);


const ensureLinkedIdInOptions = async () => {
    if (formData.value.linked_type !== 'bidding' || !formData.value.linked_id) return;

    const exists = listBidding.value.some(
        item => String(item.id) === String(formData.value.linked_id)
    );

    if (!exists) {
        try {
            const res = await getBiddingAPI(formData.value.linked_id);
            if (res?.data) {
                listBidding.value.push(res.data);
            }
        } catch (err) {
            console.error('Không thể lấy thông tin gói thầu:', err);
        }
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

const getLinkedTypeLabel = (val) => {
    const map = {
        bidding: 'Gói thầu',
        contract: 'Hợp đồng',
        internal: 'Nhiệm vụ nội bộ'
    }
    return map[val] || val
}


onMounted(async () => {
    if (props.type) {
        formData.value.linked_type = props.type
    } else {
        formData.value.linked_type = commonStore.linkedType
    }

    await getBiddingTask()
    await getContractTask()
    await getDepartment()

    if (formData.value.linked_id) {
        formData.value.linked_id = String(formData.value.linked_id)
    }

    // 3) Nếu tạo mới thì lấy linked_id mặc định từ store cha
    if (!formData.value.linked_id) {
        formData.value.linked_id = commonStore.biddingIdParent ? String(commonStore.biddingIdParent) : null
    } else {
        formData.value.linked_id = String(formData.value.linked_id)
    }


    // console.log('linked_type:', formData.value.linked_type)
    // console.log('linked_id:', formData.value.linked_id)
    // console.log('linkedIdOption:', linkedIdOption.value)

    await ensureLinkedIdInOptions()

    if (formData.value.linked_id) {
        await fetchStepOptions()
    }

    // 👉 gọi lưu vào store tại đây:
    commonStore.setLinkedType(formData.value.linked_type)
    commonStore.setLinkedIdParent(formData.value.linked_id)
})


watch(
    () => props.openDrawer,        // mỗi lần Drawer được mở
    (isOpen) => {
        if (isOpen) {
            formData.value.linked_type = props.type || commonStore.linkedType
            formData.value.linked_id = commonStore.linkedIdParent ? String(commonStore.linkedIdParent) : null
        }
    }
)


watch(() => formData.value.linked_id, async (newVal, oldVal) => {
    if (!newVal || newVal === oldVal) return

    await ensureLinkedIdInOptions()
    await fetchStepOptions()
})


// Hàm gán giá trị từ store
const setFormStepFromStore = (step) => {
    const type = props.type || 'bidding';

    formData.value.linked_type = type;

    if (type === 'bidding') {
        formData.value.linked_id = step?.bidding_id || null;
    } else if (type === 'contract') {
        formData.value.linked_id = step?.contract_id || null;
    } else {
        formData.value.linked_id = null;
    }

    formData.value.step_code = step?.step_number || null;
    formData.value.step_id = step?.id || null;
}

// Hàm gọi API theo loại nhiệm vụ
const fetchStepOptions = async () => {
    if (formData.value.linked_type === 'bidding') {
        await getBiddingStep()
    } else if (formData.value.linked_type === 'contract') {
        await getContractStep()
    }

    // Xử lý kiểm tra step_code có tồn tại trong stepOption không
    const stepValid = stepOption.value.find(opt => opt.value === formData.value.step_code)
    if (!stepValid) {
        formData.value.step_code = null
        formData.value.step_id = null
    }
}

// Watch selectedStep: khi Drawer được mở lại
watch(() => selectedStep.value, (step) => {
    if (!step) return
    setFormStepFromStore(step)
    if (formData.value.linked_id) fetchStepOptions()
}, {immediate: true})

// Watch linked_id: khi thay đổi gói thầu/hợp đồng
watch(() => formData.value.linked_id, async (newVal, oldVal) => {
    if (!newVal || newVal === oldVal) return
    await fetchStepOptions()
})

// Watch step_code: cập nhật step_id tương ứng
watch(() => formData.value.step_code, (newCode) => {
    const found = stepOption.value.find(item => item.value === newCode)
    formData.value.step_id = found ? found.step_id : null
})


</script>
<style scoped>

</style>