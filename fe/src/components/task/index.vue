<template>
    <div class="task">
        <a-page-header
            title="Chi tiết nhiệm vụ"
            @back="goBack"
            style="padding: 0 0 20px;"
        />
        <div class="action">
            <a-button type="primary" v-if="!isEditMode" style="margin-right: 8px;" @click="editTask">Chỉnh sửa</a-button>
            <a-button type="primary" v-if="isEditMode" style="margin-right: 8px;" @click="saveEditTask">Lưu</a-button>
            <a-button v-if="isEditMode" style="margin-right: 8px;" @click="cancelEditTask">Hủy</a-button>
            <a-button ><EllipsisOutlined /></a-button>
        </div>
        <div class="task-info">
            <div class="task-info-left">
                <div class="task-info-content">
                    <a-form ref="formRef" :model="formData" :rules="isEditMode ? rules : {}" layout="vertical">
                        <div class="task-in">
                            <a-row :gutter="16">
                                <a-col :span="12">
                                    <a-form-item label="Tên" name="title">
                                        <a-typography-text v-if="!isEditMode">{{ formData.title }}</a-typography-text>
                                        <a-input v-else v-model:value="formData.title" placeholder="Nhập tên nhiệm vụ" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12">
                                    <a-form-item label="Loại nhiệm vụ" name="linked_type">
                                        <a-tag v-if="!isEditMode">
                                            <strong>{{ getTextLinkedType }}</strong>
                                        </a-tag>
                                        <a-select v-else v-model:value="formData.linked_type" :options="linkedTypeOption" @change="handleChangeLinkedType()" placeholder="Chọn loại nhiệm vụ" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12" v-if="['bidding', 'contract'].includes(formData.linked_type)">
                                    <a-form-item :label=" !formData.linked_type ? 'Trống' : formData.linked_type == 'bidding' ? 'Liên kết gói thầu' : 'Liên kết hợp đồng'" name="linked_type">
                                        <a-typography-text v-if="!isEditMode">{{ getNameLinked(formData.linked_id) }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.linked_id" :options="linkedIdOption" @change="handleChangeLinkedId" :placeholder="formData.linked_type == 'bidding' ? 'Chọn gói thầu' : 'Chọn hợp đồng'" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12" v-if="['bidding', 'contract'].includes(formData.linked_type)">
                                    <a-form-item :label=" !formData.linked_type ? 'Trống' : formData.linked_type == 'bidding' ? 'Tiến trình gói thầu' : 'Tiến trình hợp đồng'" name="step_code">
                                        <a-typography-text v-if="!isEditMode">{{ getStepByStepNo(formData.step_code) }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.step_code" @change="handleChangeStep()" :options="stepOption" :disabled="!formData.linked_id" :placeholder="formData.linked_type == 'bidding' ? 'Chọn gói thầu' : 'Chọn hợp đồng'" />
                                    </a-form-item>
                                </a-col>
                            </a-row>
                        </div>
                        <div class="task-in">
                            <a-row :gutter="16">
                                <a-col :span="12">
                                    <a-form-item label="Thời gian" name="time">
                                        <a-typography-text v-if="!isEditMode">{{ (formData.start_date ? (formData.start_date) : "Trống") + " → " + (formData.end_date ? (formData.end_date) : "Trống") }}</a-typography-text>
                                        <a-config-provider :locale="locale" v-else>
                                            <a-range-picker v-model:value="dateRange" format="YYYY-MM-DD" @change="changeDateTime" style="width: 100%;"></a-range-picker>
                                        </a-config-provider>
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12">
                                    <a-form-item label="Độ ưu tiên" name="priority">
                                        <a-tag v-if="!isEditMode" :color="checkPriority(formData.priority).color">{{ checkPriority(formData.priority).label }}</a-tag>
                                        <a-select v-else v-model:value="formData.priority" :options="priorityOption" placeholder="Chọn độ ưu tiên" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12">
                                    <a-form-item label="Trạng thái" name="status">
                                        <a-tag v-if="!isEditMode" :color="checkStatus(formData.status).color">{{ checkStatus(formData.status).label }}</a-tag>
                                        <a-select v-else v-model:value="formData.status" :options="statusOption" placeholder="Chọn trạng thái" />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="12">
                                    <a-form-item label="Gắn tới người dùng" name="assigned_to">
                                        <a-typography-text v-if="!isEditMode">{{ getUserById(formData.assigned_to) }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.assigned_to" :options="userOption" placeholder="Chọn người dùng" />
                                    </a-form-item>
                                </a-col>
                            </a-row>
                        </div>
                        <div class="task-in-end">
                            <a-row :gutter="16">
                                <a-col :span="24">
                                    <a-form-item label="Mô tả" name="description">
                                        <a-typography-text v-if="!isEditMode">{{ formData.description ? formData.description : "Trống" }}</a-typography-text>
                                        <a-textarea
                                                v-else
                                                v-model:value="formData.description"
                                                :rows="4"
                                                placeholder="Nhập mô tả "
                                        />
                                    </a-form-item>
                                </a-col>
                                <a-col :span="24">
                                    <a-form-item label="Tài liệu" name="file">
                                        <a-upload
                                                v-if="isEditMode"
                                                :file-list="fileList.concat(pendingFiles.map((f, idx) => ({ uid: 'pending-' + idx, name: f.name, status: 'ready' })) )"
                                                :show-upload-list="true"
                                                :before-upload="handleBeforeUpload"
                                                :on-remove="handleRemoveFile"
                                                :multiple="true"
                                                :disabled="loadingUploadFile"
                                                list-type="text"
                                        >
                                            <a-button size="large" style="margin-top: 12px;">
                                                <template #icon>
                                                    <PaperClipOutlined />
                                                </template>
                                            </a-button>
                                        </a-upload>
                                        <template v-else>
                                            <div v-if="fileList.length" style="margin-top: 10px;">
                                                <a-list bordered size="small">
                                                    <template #default>
                                                        <a-list-item v-for="item in fileList" :key="item.uid">
                                                            <a :href="item.url" target="_blank">{{ item.name }}</a>
                                                        </a-list-item>
                                                    </template>
                                                </a-list>
                                            </div>
                                            <div v-else>Chưa có tài liệu</div>
                                        </template>
                                    </a-form-item>
                                </a-col>
                            </a-row>
                        </div>
                    </a-form>
                </div>
            </div>
            <div class="task-info-left" v-if="!formData.parent_id">
                <div class="task-info-content">
                    <div class="task-in-end">
                        <SubTasks :list-user="listUser" />
                    </div>
                </div>
            </div>
            <div class="task-info-left">
                <div class="task-info-content">
                    <div class="task-in-end">
                        <Comment />
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
<script setup>
    import { EllipsisOutlined, PaperClipOutlined, PlusOutlined, CaretDownOutlined } from '@ant-design/icons-vue';
    import { ref, computed, onMounted, watch } from 'vue';
    import { message } from 'ant-design-vue'
    import 'dayjs/locale/vi';
    dayjs.locale('vi');
    import dayjs from 'dayjs';
    import viVN from 'ant-design-vue/es/locale/vi_VN';
    import { getUsers } from '@/api/user';
    import { useRoute, useRouter } from 'vue-router';
    import { getTaskDetail, updateTask, uploadTaskFileAPI, getTaskFilesAPI, deleteTaskFilesAPI } from '@/api/task';
    import {getBiddingsAPI, updateBiddingStepAPI} from "@/api/bidding";
    import { getContractsAPI } from "@/api/contract";
    import {getContractStepsAPI, updateContractStepAPI} from '@/api/contract-steps';
    import { getBiddingStepsAPI } from '@/api/bidding';
    import Comment from './Comment.vue';
    import SubTasks from './SubTasks.vue'
    import { useUserStore } from '@/stores/user';
    import {updateStepTemplateAPI} from "@/api/step-template.js";


    const route = useRoute();
    const router = useRouter();
    const locale = ref(viVN);
    const isEditMode = ref(false);

    const listUser = ref([])
    const loading = ref(false)
    const loadingSubTask = ref(false)
    const loadingUpdate = ref(false)
    const listContract = ref([]);
    const listBidding = ref([]);
    const dateRange = ref([]);
    const listSubTask = ref([])

    const formDataSave = ref()
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
        status: "",
        priority: null,
        parent_id: null,
    });
    const priorityOption = ref([
        {value: "low", label: "Thấp", color: "success"},
        {value: "normal", label: "Thường", color: "warning"},
        {value: "high", label: "Cao", color: "error"},
    ])
    const statusOption = computed(() => {
        return [
            {value: 'todo', label: "Việc cần làm", color: "warning"},
            {value: 'doing', label: "Đang thực hiện", color: "processing"},
            {value: 'done', label: "Hoàn thành", color: "success"},
            {value: 'overdue', label: "Quá hạn", color: "error"},
        ]
    })
    const linkedTypeOption = ref([
        {value: "bidding", label: "Gói thầu"},
        {value: "contract", label: "Hợp đồng"},
        {value: "internal", label: "Nhiệm vụ nội bộ"},
    ])

    const getTextLinkedType = computed(()=>{
        let data = linkedTypeOption.value.find(ele => ele.value === formData.value.linked_type)
        if(data){
            return data.label;
        }else {
            return "Nhiệm vụ nội bộ"
        }
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
    const getNameLinked = (id)=>{
        if(formData.value.linked_type === 'bidding' && listBidding.value && listBidding.value.length){
            let check = listBidding.value.find(ele => ele.id == id)
            if(check) return check.title
            else return 'Gói thầu không tồn tại'
        }else if(formData.value.linked_type === 'contract' && listContract.value && listContract.value.length){
            let check = listContract.value.find(ele => ele.id == id)
            if(check) return check.title
            else return 'Hợp đồng không tồn tại'
        }
        return "Trống"
    }
    const linkedIdOption = computed(()=>{
        if(formData.value.linked_type === 'bidding'){
            return listBidding.value.map(ele => {
                return { value: ele.id, label: ele.title}
            })
        }else if(formData.value.linked_type === 'contract'){
            return listContract.value.map(ele => {
                return { value: ele.id, label: ele.title}
            })
        }
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
    const stepOption = ref([])

    // Method
    const handleChangeLinkedType = () => {
        formData.value.linked_id = null;
        formData.value.step_code = null;
    };
    const handleChangeLinkedId = () => {
        if(formData.value.linked_type === 'bidding'){
            getBiddingStep()
        }else if(formData.value.linked_type === 'contract'){
            getContractStep()
        }
    };

    const handleChangeStep = (e) => {
        console.log('e',e)
    }
    const getContractStep = async () => {
        await getContractStepsAPI(formData.value.linked_id).then(res => {
            stepOption.value = res.data ? res.data.map(ele => {
                return { value: ele.step_number, label: ele.title, step_id: ele.id}
            }) : []
        }).catch(err => {

        })
    }
    const getBiddingStep = async () => {
        await getBiddingStepsAPI(formData.value.linked_id).then(res => {
            stepOption.value = res.data ? res.data.map(ele => {
                return { value: ele.step_number, label: ele.title, step_id: ele.id}
            }) : []
        }).catch(err => {

        })
    }
    const getStepByStepNo = (step) =>  {
        let data = stepOption.value.find(ele => ele.value === step);
        if(!data){
            return "Trống" ;
        }else {
            return data.label;
        }
    }
    const checkPriority = (text) => {
        let data = priorityOption.value.find(ele => ele.value == text);
        if(data){
            return data
        }else {
            return {value: "", label: "", color: ""}
        }
    };
    const checkStatus = (text) => {
        let data = statusOption.value.find(ele => ele.value == text);
        if(data){
            return data
        }else {
            return {value: "", label: "", color: ""}
        }
    };
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
    const changeDateTime = (day, date) => {
        if(day){
            formData.value.start_date = date[0]
            formData.value.end_date = date[1]
        }else {
            formData.value.start_date = "";
            formData.value.end_date = "";
        }

    }
    const editTask = () => {
        formDataSave.value = {...formData.value}
        isEditMode.value = true;
    }
    const saveEditTask = async () => {
        loadingUpdate.value = true;

        // 🔄 Đồng bộ step_id thủ công từ step_code
        const found = stepOption.value.find(item => item.value === formData.value.step_code)
        formData.value.step_id = found ? found.step_id : null;

        if (!formData.value.start_date && !formData.value.end_date) {
            formData.value.start_date = formDataSave.value.start_date;
            formData.value.end_date = formDataSave.value.end_date;
        }
        try {
            const res = await updateTask(route.params.id, formData.value);

            for (const file of pendingFiles.value) {
                const formDataFile = new FormData();
                formDataFile.append('file', file);
                formDataFile.append('user_id', store.currentUser.id);
                await uploadTaskFileAPI(route.params.id, formDataFile);
            }

            if (formData.value.step_id) {
                console.log('✅ Gọi updateBiddingStepAPI', formData.value.step_id)
                await updateBiddingStepAPI(formData.value.step_id, {
                    task_id: route.params.id
                });
            }

            pendingFiles.value = [];
            await fetchTaskFiles();
            await getDetailTaskById();

            message.success("Cập nhật thành công");
        } catch (error) {
            formData.value = formDataSave.value;
            message.destroy();
            message.error("Không thể cập nhật chỉnh sửa");
        } finally {
            loadingUpdate.value = false;
            isEditMode.value = false;
        }
    }

    const cancelEditTask = () => {
        isEditMode.value = false;
    }
    const getDetailTaskById = async () => {
        await getTaskDetail(route.params.id).then(res => {
            formData.value = res.data;
        }).catch(err => {

        })
    }
    const getListBidding = async () => {
        await getBiddingsAPI().then(res =>{
            listBidding.value = res.data.data
        }).catch(err => {

        })
    }
    const getListContract = async () => {
        await getContractsAPI().then(res =>{

            listContract.value = res.data;
        }).catch(err => {

        })
    }

    const store = useUserStore();
    const fileList = ref([]);
    const loadingUploadFile = ref(false);
    const pendingFiles = ref([]);

    const fetchTaskFiles = async () => {
        try {
            const res = await getTaskFilesAPI(route.params.id);
            fileList.value = (res.data || []).map(f => ({
                uid: f.id || f.file_name,
                name: f.file_name,
                status: 'done',
                url: f.file_path,
                ...f
            }));
        } catch (e) {
            fileList.value = [];
        }
    };

    const handleBeforeUpload = (file) => {
        pendingFiles.value.push(file);
        return false; // Không upload ngay
    };

    const handleRemoveFile = async (file) => {
        if (file.uid && file.uid.toString().startsWith('pending-')) {
            // Xóa khỏi pendingFiles
            const idx = Number(file.uid.replace('pending-', ''));
            pendingFiles.value.splice(idx, 1);
            return true;
        } else {
            // Xóa file đã upload trên server
            try {
                await deleteTaskFilesAPI(file.id);
                await fetchTaskFiles();
                message.success('Xóa file thành công');
            } catch (e) {
                message.error('Xóa file thất bại');
            }
            return true;
        }
    };

    const goBack = () => {
        router.push('/internal-tasks')
    }


    watch(() => formData.value.step_code, (newCode) => {
        const found = stepOption.value.find(item => item.value === newCode)
        formData.value.step_id = found ? found.step_id : null;
        console.log('formData.value', formData.value)
    })

    onMounted(async() => {
        await getDetailTaskById();
        await getUser();
        await getListBidding();
        await getListContract();
        await fetchTaskFiles();
        handleChangeLinkedId();
    })

</script>
<style scoped>
    .task{
        max-height: calc( 100vh - 160px);
        overflow-y: auto;
    }
    .task-info{
        margin-top: 16px;
    }
    .task-info-left{
        margin-bottom: 20px;
    }
    .task-info-content{
        border: 1px solid #bebebece;
        border-radius: 8px;
    }
    .task-in{
        border-bottom: 1px solid #bebebece;
        padding: 14px;
        padding-bottom: 0;
    }
    .task-in-end{
        padding: 14px;
        border-bottom: none;
    }

    :deep(label){
        color: #999999 !important;
    }
    :deep(.ant-form-item){
        margin-bottom: 14px;
    }
    :deep(.ant-form-item-label){
        padding-bottom: 0;
    }
</style>