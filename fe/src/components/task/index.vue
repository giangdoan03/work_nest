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
                                        <template v-if="!isEditMode">
                                            <a-typography-text>
                                                {{ (formData.start_date || "Trống") + " → " + (formData.end_date || "Trống") }}
                                            </a-typography-text>
                                        </template>
                                        <template v-else>
                                            <a-config-provider :locale="locale">
                                                <a-range-picker
                                                        v-model:value="dateRange"
                                                        format="YYYY-MM-DD"
                                                        @change="changeDateTime"
                                                        :getPopupContainer="triggerNode => triggerNode.parentNode"
                                                        style="width: 100%;"
                                                />
                                            </a-config-provider>
                                        </template>

                                        <!-- ✅ Luôn hiển thị lịch sử gia hạn -->
                                        <!-- <a-timeline v-if="extensions.length" style="margin-top: 20px;">
                                            <a-timeline-item v-for="item in sortedExtensions" :key="item.id">
                                                <template #dot>
                                                    <CalendarOutlined />
                                                </template>
                                                <span :style="{ color: extensionErrors[item.id] ? 'red' : 'inherit' }">
                                                    {{ formatDate(item.old_end_date) }} → <b>{{ formatDate(item.new_end_date) }}</b>
                                                    <span v-if="item.reason">({{ item.reason }})</span>
                                                    <span v-if="extensionErrors[item.id]" style="margin-left: 8px; font-weight: bold;">
                                                        {{ extensionErrors[item.id] }}
                                                    </span>
                                                </span>
                                            </a-timeline-item>
                                        </a-timeline> -->
                                    </a-form-item>
                                </a-col>

                                <a-col :span="12">
                                    <a-form-item label="Ngày còn lại">
                                        <a-tag :color="getRemainingDaysColor" size="small" style="font-size: 12px; padding: 2px 6px;">
                                            {{ getRemainingDaysText }}
                                        </a-tag>
                                    </a-form-item>
                                </a-col>


                                <a-col :span="12">
                                    <a-form-item label="Độ ưu tiên" name="priority">
                                        <a-tag v-if="!isEditMode" :color="checkPriority(formData.priority).color">
                                            {{ checkPriority(formData.priority).label }}
                                        </a-tag>
                                        <a-select v-else v-model:value="formData.priority" :options="priorityOption" placeholder="Chọn độ ưu tiên" />
                                    </a-form-item>
                                </a-col>

                                <a-col :span="12">
                                    <a-form-item label="Trạng thái" name="status">
                                        <template v-if="!isEditMode">
                                            <a-tag v-if="formData.approval_status === 'approved'" color="success">Hoàn thành</a-tag>
                                            <a-tag v-else :color="checkStatus(formData.status).color">
                                                {{ checkStatus(formData.status).label }}
                                            </a-tag>
                                        </template>
                                        <a-select v-else v-model:value="formData.status" :options="statusOption" placeholder="Chọn trạng thái" />
                                    </a-form-item>
                                </a-col>

                                <a-col :span="12" v-if="formData.status === 'request_approval'">
                                    <a-form-item label="Trạng thái duyệt" name="approval_status">
                                        <a-tag :color="getApprovalColor(formData.approval_status)">
                                            {{ getApprovalText(formData.approval_status) }}
                                        </a-tag>
                                    </a-form-item>
                                </a-col>

                                <a-col :span="6" v-if="formData.status === 'request_approval'">
                                    <a-form-item label="Cấp hiện tại">
                                        <span>{{ formData.current_level || '—' }}</span>
                                    </a-form-item>
                                </a-col>

                                <a-col :span="6" v-if="formData.status === 'request_approval'">
                                    <a-form-item label="Tổng cấp duyệt">
                                        <span>{{ formData.approval_steps || '—' }}</span>
                                    </a-form-item>
                                </a-col>

                                <a-col :span="12">
                                    <a-form-item label="Gắn tới người dùng" name="assigned_to">
                                        <a-typography-text v-if="!isEditMode">{{ getUserById(formData.assigned_to) }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.assigned_to" :options="userOption" placeholder="Chọn người dùng" />
                                    </a-form-item>
                                </a-col>

                                <a-col :span="12">
                                    <a-form-item label="Phòng ban" name="id_department">
                                        <a-typography-text v-if="!isEditMode">{{ getDepartmentById(formData.id_department) }}</a-typography-text>
                                        <a-select v-else v-model:value="formData.id_department" :options="departmentOptions" placeholder="Chọn người dùng" />
                                    </a-form-item>
                                </a-col>

                                <a-col :span="24">
                                    <a-form-item label="Tiến trình" name="progress">
                                        <template v-if="!isEditMode">
                                            <a-progress 
                                                :percent="formData.progress || 0" 
                                                :status="getProgressStatus(formData.progress)"
                                                :format="(percent) => `${percent}%`"
                                                :stroke-width="20"
                                            />
                                        </template>
                                        <template v-else>
                                            <a-slider
                                                v-model:value="formData.progress"
                                                :min="0"
                                                :max="100"
                                                :step="5"
                                                :marks="{ 0: '0%', 25: '25%', 50: '50%', 75: '75%', 100: '100%' }"
                                                style="width: calc(90% + 50px); margin: 0 auto; display: block;"
                                            />
                                            <div style="margin-top: 24px;">
                                                <a-progress 
                                                    :percent="formData.progress || 0" 
                                                    :status="getProgressStatus(formData.progress)"
                                                    :format="(percent) => `${percent}%`"
                                                    :stroke-width="16"
                                                    style="width: calc(90% + 50px); margin: 0 auto; display: block;"
                                                />
                                            </div>
                                        </template>
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
                                            :file-list="computedUploadList"
                                            :show-upload-list="true"
                                            :before-upload="handleBeforeUpload"
                                            :on-remove="handleRemoveFile"
                                            :multiple="true"
                                            :disabled="loadingUploadFile"
                                            list-type="text"
                                        >
                                            <a-button size="large" style="margin-top: 12px;">
                                                <template #icon><PaperClipOutlined /></template>
                                            </a-button>
                                        </a-upload>
                                    </a-form-item>

                                    <!-- ✅ Nhập link tài liệu thủ công -->
                                    <a-form-item label="Link tài liệu">
                                        <div style="margin-bottom: 10px;">
                                            <a-input
                                                v-model:value="manualLink.title"
                                                placeholder="Tiêu đề tài liệu"
                                                style="margin-bottom: 5px;"
                                            />
                                            <a-input
                                                v-model:value="manualLink.url"
                                                placeholder="URL tài liệu (https://...)"
                                                type="url"
                                            />
                                            <a-button
                                                type="primary"
                                                size="small"
                                                @click="addManualLink"
                                                :disabled="!manualLink.title || !manualLink.url"
                                                style="margin-top: 5px;"
                                            >
                                                Thêm link
                                            </a-button>
                                        </div>
                                    </a-form-item>


                                    <!-- ✅ Hiển thị danh sách link đã thêm -->
                                    <a-form-item v-if="manualLinks.length" label="Link đã thêm">
                                        <a-list bordered size="small" :data-source="manualLinks">
                                            <template #renderItem="{ item, index }">
                                                <a-list-item :key="index">
                                                    <div style="width: 100%">
                                                        <strong>{{ item.title }}</strong><br />
                                                        <a :href="item.url" target="_blank">{{ item.url }}</a>
                                                        <a style="color: red; float: right;" @click="manualLinks.splice(index, 1)">Xoá</a>
                                                    </div>
                                                </a-list-item>
                                            </template>
                                        </a-list>

                                    </a-form-item>


                                    <!-- ✅ Tách form item khác để nhập tiêu đề -->
                                    <a-form-item v-if="pendingFiles.length" label="Tiêu đề tài liệu">
                                        <div v-for="(file, index) in pendingFiles" :key="index" style="margin-bottom: 10px;">
                                            <a-input
                                                v-model:value="file.title"
                                                placeholder="Nhập tiêu đề file"
                                                :status="!file.title ? 'error' : ''"
                                            />
                                        </div>
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
            <a-typography-title :level="5">Lịch sử phê duyệt</a-typography-title>
            <a-table :columns="logColumns" :data-source="logData" row-key="id">
                <template #bodyCell="{ column, record }">
                    <template v-if="column.dataIndex === 'level'">Cấp {{ record.level }}</template>
                    <template v-if="column.dataIndex === 'status'">
                        <a-tag :color="getStatusColor(record.status)">
                            {{ getStatusText(record.status) }}
                        </a-tag>
                    </template>
                    <template v-if="column.dataIndex === 'approved_by_name'">
                        {{ record.approved_by_name || '—' }}
                    </template>
                    <template v-if="column.dataIndex === 'comment'">
                        {{ record.comment || '—' }}
                    </template>
                </template>
            </a-table>
        </div>
    </div>
</template>
<script setup>
    import { EllipsisOutlined, PaperClipOutlined, PlusOutlined, CaretDownOutlined, CalendarOutlined } from '@ant-design/icons-vue';
    import { ref, computed, onMounted, watch, reactive, nextTick } from 'vue';
    import { message } from 'ant-design-vue'
    import 'dayjs/locale/vi';
    dayjs.locale('vi');
    import dayjs from 'dayjs';
    import viVN from 'ant-design-vue/es/locale/vi_VN';
    import { getUsers } from '@/api/user';
    import { useRoute, useRouter } from 'vue-router';
    import {
        getTaskDetail,
        updateTask,
        uploadTaskFileAPI,
        getTaskFilesAPI,
        deleteTaskFilesAPI,
        uploadTaskLinkAPI
    } from '@/api/task';
    import {getBiddingsAPI, updateBiddingStepAPI} from "@/api/bidding";
    import { getContractsAPI } from "@/api/contract";
    import {getContractStepsAPI, updateContractStepAPI} from '@/api/contract-steps';
    import { getBiddingStepsAPI } from '@/api/bidding';
    import { getDepartments } from '@/api/department'
    import Comment from './Comment.vue';
    import SubTasks from './SubTasks.vue'
    import { useUserStore } from '@/stores/user';
    import {updateStepTemplateAPI} from "@/api/step-template.js";
    import { getApprovalHistoryByTask } from '@/api/taskApproval'
    import {getTaskExtensions} from "@/api/task.js";
    import { formatDate } from '@/utils/formUtils';
    import { useTaskDrawerStore } from '@/stores/taskDrawerStore';

    const extensions = ref([]);
    const extensionHistory = ref([]);


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
    const listDepartment = ref([])

    const formDataSave = ref()
    const logData = ref([])
    const taskId = route.params.id;
    const drawerVisible = ref(false);

    const drawerStore = useTaskDrawerStore();

    // onMounted(() => {
    //     if (drawerStore.shouldReopen) {
    //         drawerVisible.value = true; // mở lại drawer
    //         drawerStore.reset(); // chỉ mở 1 lần
    //     }
    // });


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
        id_department: null,
        progress: 0,
    });
    const priorityOption = ref([
        {value: "low", label: "Thấp", color: "success"},
        {value: "normal", label: "Thường", color: "warning"},
        {value: "high", label: "Cao", color: "error"},
    ])
    const statusOption = computed(() => {
        return [
            { value: 'todo', label: 'Việc cần làm', color: 'warning' },
            { value: 'doing', label: 'Đang thực hiện', color: 'processing' },
            { value: 'request_approval', label: 'Gửi duyệt', color: 'blue' },
            // { value: 'done', label: 'Hoàn thành', color: 'success' },
            { value: 'overdue', label: 'Quá hạn', color: 'error' },
        ];
    });
    const departmentOptions = computed(()=>{
        return listDepartment.value.map(ele => {
            return { value: ele.id, label: ele.name }
        })
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

    const sortedExtensions = computed(() => {
        return [...extensionHistory.value].sort((a, b) => new Date(a.updated_at) - new Date(b.updated_at));
    });

    const extensionErrors = computed(() => {
        const result = {};
        let prevNewDate = null;

        sortedExtensions.value.forEach((item) => {
            const oldDate = new Date(item.old_end_date);
            const newDate = new Date(item.new_end_date);

            // Điều kiện lỗi: new < old hoặc old ≠ new của lần trước
            if (newDate < oldDate || (prevNewDate && oldDate.getTime() !== prevNewDate.getTime())) {
                result[item.id] = '❗Không hợp lệ';
            }

            prevNewDate = newDate;
        });

        return result;
    });

    // Lấy data từ trường days_overdue và days_remaining
    const getRemainingDays = computed(() => {
        // Nếu có trường days_overdue (quá hạn)
        if (formData.value.days_overdue !== undefined && formData.value.days_overdue > 0) {
            return -formData.value.days_overdue; // Trả về số âm để biểu thị quá hạn
        }
        
        // Nếu có trường days_remaining (còn hạn)
        if (formData.value.days_remaining !== undefined && formData.value.days_remaining >= 0) {
            return formData.value.days_remaining;
        }
        
        // Fallback: tính toán thủ công nếu không có data từ server
        if (!formData.value.end_date) return null;
        
        const today = new Date();
        const endDate = new Date(formData.value.end_date);
        const diffTime = endDate.getTime() - today.getTime();
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        return diffDays;
    });

    const getRemainingDaysText = computed(() => {
        const days = getRemainingDays.value;
        if (days === null) return 'Chưa có hạn';
        if (days < 0) return `Quá hạn ${Math.abs(days)} ngày`;
        if (days === 0) return 'Hết hạn hôm nay';
        if (days === 1) return 'Còn 1 ngày';
        return `Còn ${days} ngày`;
    });

    const getRemainingDaysColor = computed(() => {
        const days = getRemainingDays.value;
        if (days === null) return 'default';
        if (days < 0) return 'error';
        if (days <= 1) return 'warning';
        if (days <= 3) return 'orange';
        return 'success';
    });

    // Trạng thái tiến trình
    const getProgressStatus = (progress) => {
        if (!progress) return 'normal';
        if (progress >= 100) return 'success';
        if (progress >= 80) return 'normal';
        if (progress >= 50) return 'active';
        return 'exception';
    };


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
    const getDepartmentById = (userId) =>  {
        let data = listDepartment.value.find(ele => ele.id == userId);
        if(!data){
            return "" ;
        }
        return data.name;
    }
    const changeDateTime = (day) => {
        if (day && day.length === 2) {
            formData.value.start_date = day[0]?.format('YYYY-MM-DD')
            formData.value.end_date = day[1]?.format('YYYY-MM-DD')
        } else {
            formData.value.start_date = ""
            formData.value.end_date = ""
        }
    }

    const editTask = () => {
        formDataSave.value = {...formData.value}
        isEditMode.value = true;
    }
    const saveEditTask = async () => {
        loadingUpdate.value = true;

        // 🔄 Đồng bộ step_id từ step_code
        const found = stepOption.value.find(item => item.value === formData.value.step_code);
        formData.value.step_id = found ? found.step_id : null;

        // Nếu không sửa ngày thì giữ nguyên
        if (!formData.value.start_date && !formData.value.end_date) {
            formData.value.start_date = formDataSave.value.start_date;
            formData.value.end_date = formDataSave.value.end_date;
        }

        // 🔁 Nếu gửi duyệt thì thêm thông tin duyệt vào payload
        if (formData.value.status === 'pending_approval') {
            formData.value.approval_status = 'pending';
            formData.value.current_level = 1;
        }

        // ✅ Nếu đổi ngày kết thúc → thêm lý do gia hạn
        const isEndDateChanged = formData.value.end_date !== formDataSave.value.end_date;
        if (isEndDateChanged) {
            formData.value.extend_reason = 'Gia hạn thời gian'; // Bạn có thể dùng modal để hỏi lý do cụ thể nếu muốn
        }

        const hasInvalidTitle = pendingFiles.value.some(f => !f.title?.trim());
        if (hasInvalidTitle) {
            message.error('Vui lòng nhập tiêu đề cho tất cả tài liệu đính kèm.');
            return;
        }

        try {
            const res = await updateTask(route.params.id, formData.value);

            // Upload file nếu có
            for (const file of pendingFiles.value) {
                const formDataFile = new FormData();
                formDataFile.append('file', file.raw);
                formDataFile.append('title', file.title);
                formDataFile.append('user_id', store.currentUser.id);
                await uploadTaskFileAPI(route.params.id, formDataFile);
            }

            // Gán task vào step nếu có step_id
            if (formData.value.step_id) {
                await updateBiddingStepAPI(formData.value.step_id, {
                    task_id: route.params.id
                });
            }

            pendingFiles.value = [];
            await fetchTaskFiles();
            await getDetailTaskById();
            await fetchExtensionHistory();
            await nextTick();
            extensionErrors.value = calculateExtensionErrors(extensionHistory.value);

            message.success("Cập nhật thành công");
        } catch (error) {
            formData.value = formDataSave.value;
            message.destroy();
            message.error("Không thể cập nhật chỉnh sửa");
        } finally {
            loadingUpdate.value = false;
            isEditMode.value = false;
        }
    };

    const calculateExtensionErrors = (extensions) => {
        const errors = {};

        extensions.forEach(item => {
            const oldDate = new Date(item.old_end_date);
            const newDate = new Date(item.new_end_date);

            if (newDate < oldDate) {
                errors[item.id] = 'Gia hạn không hợp lệ (ngày kết thúc mới < cũ)';
            }

            // ✅ Thêm điều kiện khác nếu cần, ví dụ:
            // if (!item.reason || item.reason.trim() === '') {
            //     errors[item.id] = 'Lý do gia hạn không được để trống';
            // }
        });

        return errors;
    };



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
        pendingFiles.value.push({
            raw: file,         // file gốc
            name: file.name,   // tên file
            title: ''          // sẽ nhập sau, bắt buộc
        });
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

    const getApprovalText = (status) =>{
        switch (status) {
            case 'pending': return 'Đang chờ duyệt'
            case 'approved': return 'Đã duyệt'
            case 'rejected': return 'Đã từ chối'
            default: return 'Không xác định'
        }
    };
    const getApprovalColor = (status) => {
        switch (status) {
            case 'pending': return 'orange'
            case 'approved': return 'green'
            case 'rejected': return 'red'
            default: return 'default'
        }
    }


    const fetchExtensions = async () => {
        try {
            const res = await getTaskExtensions(route.params.id);
            console.log('📦 API extensions:', res.data); // ✅ debug ở đây
            extensions.value = res.data.extensions || [];
        } catch (error) {
            console.error('❌ Lỗi fetch extensions:', error);
            extensions.value = [];
        }
    };

    const fetchExtensionHistory = async () => {
        try {
            const res = await getTaskExtensions(route.params.id);
            extensionHistory.value = res.data.extensions || [];
        } catch (e) {
            console.error('❌ Lỗi khi lấy lịch sử gia hạn:', e);
            extensionHistory.value = [];
        }
    };


    const logColumns = [
        { title: 'Cấp', dataIndex: 'level' },
        { title: 'Trạng thái', dataIndex: 'status' },
        { title: 'Người duyệt', dataIndex: 'approved_by_name' },
        { title: 'Ghi chú', dataIndex: 'comment' },
    ]

    const getStatusColor = (status) => {
        switch (status) {
            case 'pending': return 'orange'
            case 'approved': return 'green'
            case 'rejected': return 'red'
            default: return ''
        }
    }

    const getStatusText = (status) => {
        switch (status) {
            case 'pending':
                return 'Đang chờ'
            case 'approved':
                return 'Đã duyệt'
            case 'rejected':
                return 'Từ chối'
            default:
                return 'Không xác định'
        }
    }

    const fetchLogHistory = async () => {
        try {
            const res = await getApprovalHistoryByTask(route.params.id)
            console.log('🧾 Log history:', res.data)
            logData.value = Array.isArray(res.data) ? res.data : []
        } catch (e) {
            console.error('Lỗi khi lấy log:', e)
            logData.value = []
        }
    }

    const computedUploadList = computed(() => {
        const uploaded = fileList.value.map(f => ({
            ...f,
            name: f.title ? `${f.title} (${f.name})` : f.name,
            url: f.is_link ? f.link_url : f.link_url // ✅ thêm url nếu là link
        }));

        const pending = pendingFiles.value.map((f, idx) => ({
            uid: 'pending-' + idx,
            name: f.title ? `${f.title} (${f.name})` : f.name,
            status: 'ready'
        }));

        return [...uploaded, ...pending];
    });



    const manualLink = reactive({ title: '', url: '' });
    const manualLinks = ref([]);

    const addManualLink = async () => {
        if (!manualLink.title || !manualLink.url) return;

        manualLinks.value.push({ ...manualLink });

        // Gọi API ngay khi thêm
        const formData = new FormData();
        formData.append('title', manualLink.title);
        formData.append('url', manualLink.url);
        formData.append('user_id', store.currentUser.id);

        await uploadTaskLinkAPI(route.params.id, formData);

        // Load lại danh sách tài liệu
        await fetchTaskFiles();

        // Reset input
        manualLink.title = '';
        manualLink.url = '';
    };

    const getDepartment = async () => {
        try {
            const response = await getDepartments();
            listDepartment.value = response.data;
        } catch (e) {
            message.error('Không thể tải người dùng')
        } finally {
        }
    }


    const goBack = () => {
        if (window.history.length > 1) {
            router.back();
        } else {
            router.push('/internal-tasks'); // fallback nếu không có trang trước
        }
    }


    watch(() => formData.value.step_code, (newCode) => {
        const found = stepOption.value.find(item => item.value === newCode)
        formData.value.step_id = found ? found.step_id : null;
    })

    watch(
        () => [formData.value.start_date, formData.value.end_date],
        ([start, end]) => {
            if (start && end) {
                dateRange.value = [dayjs(start), dayjs(end)]
            } else {
                dateRange.value = []
            }
        },
        { immediate: true }
    )

    onMounted(async () => {
        try {
            await getDepartment()
            await getDetailTaskById()
            await getUser()
            await getListBidding()
            await getListContract()
            await fetchTaskFiles()
            await fetchLogHistory()
            await fetchExtensions();
            await fetchExtensionHistory(); // ✅ Thêm vào đây
            handleChangeLinkedId()

        } catch (e) {
            console.error('❌ Lỗi khi gọi API log:', e)
            logData.value = []
        }
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
    
    /* Dropdown đi cùng khi scroll */
    :deep(.ant-select-dropdown) {
        position: fixed !important;
        z-index: 1050 !important;
    }
    
    /* Đảm bảo dropdown hiển thị đúng vị trí */
    :deep(.ant-select-dropdown .ant-select-item) {
        position: relative;
    }
</style>