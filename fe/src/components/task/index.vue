<template>
    <div class="task">
        <div class="header-wrapper">
            <a-page-header
                title="Chi tiết nhiệm vụ"
                @back="goBack"
                style="padding: 0;"
            />
            <div class="action">
                <a-button type="primary" v-if="!isEditMode" @click="editTask">Chỉnh sửa</a-button>
                <a-button type="primary" v-if="isEditMode" @click="saveEditTask">Lưu</a-button>
                <a-button v-if="isEditMode" @click="cancelEditTask">Hủy</a-button>
                <a-button><EllipsisOutlined/></a-button>
            </div>
        </div>
        <div class="task-info">
            <a-row :gutter="16">
                <!-- LEFT: 2/3 — Thông tin nhiệm vụ -->
                <a-col :span="16" :xs="24" :lg="16" :xl="16">
                    <a-card title="Chi tiết nhiệm vụ" bordered>
                        <div>
                            <a-tabs v-model:activeKey="leftTab" class="task-left-tabs">
                                <!-- Tab 1: Thông tin nhiệm vụ -->
                                <a-tab-pane key="info" tab="Thông tin">
                                    <div class="task-info-left">
                                        <div class="task-info-content">
                                            <a-form ref="formRef" :model="formData" :rules="isEditMode ? rules : {}" layout="vertical">
                                                <div class="task-in">
                                                    <a-row :gutter="16">
                                                        <a-col :span="12">
                                                            <a-form-item label="Tên công việc" name="title">
                                                                <a-typography-text v-if="!isEditMode">{{ formData.title }}</a-typography-text>
                                                                <a-input v-else v-model:value="formData.title" placeholder="Nhập tên nhiệm vụ"/>
                                                            </a-form-item>
                                                        </a-col>
                                                        <a-col :span="12">
                                                            <a-form-item label="Loại nhiệm vụ" name="linked_type">
                                                                <a-tag v-if="!isEditMode">
                                                                    <strong>{{ getTextLinkedType }}</strong>
                                                                </a-tag>
                                                                <a-select v-else v-model:value="formData.linked_type"
                                                                          :options="linkedTypeOption" @change="handleChangeLinkedType()"
                                                                          placeholder="Chọn loại nhiệm vụ"/>
                                                            </a-form-item>
                                                        </a-col>
                                                        <a-col :span="24">
                                                            <a-form-item label="Công việc cha">
                                                                <template v-if="formData.parent_id">
                                                                    <a-tooltip :title="formData.parent_title || ('#' + formData.parent_id)">
                                                                        <a-typography-link @click="goToTask(formData.parent_id)">
                                                                            {{ formData.parent_title || ('#' + formData.parent_id) }}
                                                                        </a-typography-link>
                                                                    </a-tooltip>
                                                                </template>
                                                                <template v-else>
                                                                    <a-typography-text type="secondary">—</a-typography-text>
                                                                </template>
                                                            </a-form-item>
                                                        </a-col>
                                                        <!-- ================== BIDDING ================== -->
                                                        <a-col :span="12" v-if="formData.linked_type === 'bidding'">
                                                            <a-form-item label="Liên kết gói thầu" name="linked_id">
                                                                <a-typography-text v-if="!isEditMode">{{ linkedName }}</a-typography-text>
                                                                <a-select
                                                                    v-else
                                                                    v-model:value="formData.linked_id"
                                                                    show-search
                                                                    :filterOption="false"
                                                                    placeholder="Chọn gói thầu"
                                                                    :options="linkedIdOption"
                                                                    @search="searchBidding"
                                                                    @change="handleChangeLinkedId(formData.linked_id)"
                                                                />
                                                            </a-form-item>
                                                        </a-col>
                                                        <a-col :span="12" v-if="formData.linked_type === 'bidding'">
                                                            <a-form-item label="Công việc cha" name="step_code">
                                                                <a-typography-text v-if="!isEditMode">{{ getStepByStepNo(formData.step_code) }}</a-typography-text>
                                                                <a-select
                                                                    v-else
                                                                    v-model:value="formData.step_code"
                                                                    :options="stepOption"
                                                                    @change="handleChangeStep"
                                                                    :disabled="!formData.linked_id"
                                                                    placeholder="Chọn tiến trình"
                                                                />
                                                            </a-form-item>
                                                        </a-col>

                                                        <!-- ================== CONTRACT ================== -->
                                                        <a-col :span="12" v-if="formData.linked_type === 'contract'">
                                                            <a-form-item label="Liên kết hợp đồng" name="linked_id">
                                                                <a-typography-text v-if="!isEditMode">{{ linkedName }}</a-typography-text>
                                                                <a-select
                                                                    v-else
                                                                    v-model:value="formData.linked_id"
                                                                    :options="linkedIdOption"
                                                                    @change="handleChangeLinkedId"
                                                                    placeholder="Chọn hợp đồng"
                                                                />
                                                            </a-form-item>
                                                        </a-col>
                                                        <a-col :span="12" v-if="formData.linked_type === 'contract'">
                                                            <a-form-item label="Công việc cha" name="step_code">
                                                                <a-typography-text v-if="!isEditMode">{{ getStepByStepNo(formData.step_code) }}</a-typography-text>
                                                                <a-select
                                                                    v-else
                                                                    v-model:value="formData.step_code"
                                                                    :options="stepOption"
                                                                    @change="handleChangeStep"
                                                                    :disabled="!formData.linked_id"
                                                                    placeholder="Chọn tiến trình"
                                                                />
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
                                                                        {{(formatDate(formData.start_date) || "Trống") + " → " + (formatDate(formData.end_date) || "Trống") }}
                                                                    </a-typography-text>
                                                                </template>
                                                                <template v-else>
                                                                    <a-config-provider :locale="locale">
                                                                        <a-range-picker
                                                                            v-model:value="dateRange"
                                                                            format="DD/MM/YYYY"
                                                                            @change="changeDateTime"
                                                                            :getPopupContainer="triggerNode => triggerNode.parentNode"
                                                                            style="width: 100%;"
                                                                        />
                                                                    </a-config-provider>
                                                                </template>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Ngày còn lại">
                                                                <a-tag v-if="formData.days_overdue > 0" color="error">
                                                                    Quá hạn {{ formData.days_overdue }} ngày
                                                                </a-tag>
                                                                <a-tag v-else-if="formData.days_remaining > 0" color="green">
                                                                    Còn {{ formData.days_remaining }} ngày
                                                                </a-tag>
                                                                <a-tag v-else-if="formData.days_remaining === 0" :color="'#faad14'">
                                                                    Hạn chót hôm nay
                                                                </a-tag>
                                                                <a-tag v-else>
                                                                    —
                                                                </a-tag>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Độ ưu tiên" name="priority">
                                                                <a-tag v-if="!isEditMode" :color="checkPriority(formData.priority).color">
                                                                    {{ checkPriority(formData.priority).label }}
                                                                </a-tag>
                                                                <a-select v-else v-model:value="formData.priority" :options="priorityOption" placeholder="Chọn độ ưu tiên"/>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Trạng thái" name="status">
                                                                <template v-if="!isEditMode">
                                                                    <a-tag v-if="formData.approval_status === 'approved'" color="success">Hoàn
                                                                        thành
                                                                    </a-tag>
                                                                    <a-tag v-else :color="checkStatus(formData.status).color">
                                                                        {{ checkStatus(formData.status).label }}
                                                                    </a-tag>
                                                                </template>
                                                                <a-select v-else v-model:value="formData.status" :options="statusOption" placeholder="Chọn trạng thái"/>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Phê duyệt" name="approval_status">
                                                                <a-tag :color="formData.approval_status === 'approved' ? 'green' : 'orange'">
                                                                    {{ formData.approval_status === 'approved' ? 'Đã duyệt' : 'Chưa duyệt' }}
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
                                                            <a-form-item label="Người thực hiện" name="assigned_to">
                                                                <a-typography-text v-if="!isEditMode">{{getUserById(formData.assigned_to) }}
                                                                </a-typography-text>
                                                                <a-select v-else v-model:value="formData.assigned_to" :options="userOption" placeholder="Chọn người dùng"/>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Phòng ban" name="id_department">
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{ getDepartmentById(formData.id_department) }}
                                                                </a-typography-text>
                                                                <a-select v-else v-model:value="formData.id_department"
                                                                          :options="departmentOptions" placeholder="Chọn người dùng"/>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Tiến độ" name="progress">
                                                                <template v-if="!isEditMode">
                                                                    <a-progress
                                                                        :percent="numericProgress"
                                                                        :stroke-color="{ '0%': '#108ee9', '100%': '#87d068' }"
                                                                        :status="numericProgress >= 100 ? 'success' : 'active'"
                                                                        size="small"
                                                                        :show-info="true"
                                                                    />
                                                                </template>
                                                                <template v-else>
                                                                    <a-slider
                                                                        v-model:value="numericProgress"
                                                                        :min="0"
                                                                        :max="100"
                                                                        :step="5"
                                                                        :marks="{ 0: '0%', 25: '25%', 50: '50%', 75: '75%', 100: '100%' }"
                                                                        style="width: calc(83% + 50px); margin: 0 auto; display: block;"
                                                                    />
                                                                </template>
                                                            </a-form-item>
                                                        </a-col>
                                                        <a-col :span="12">
                                                            <!-- Mô tả -->
                                                            <a-form-item label="Mô tả" name="description">
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{ formData.description ? formData.description : "Trống" }}
                                                                </a-typography-text>
                                                                <a-textarea v-else v-model:value="formData.description" :rows="4" placeholder="Nhập mô tả"/>
                                                            </a-form-item>
                                                        </a-col>


                                                    </a-row>
                                                </div>
                                            </a-form>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="task-info-content">
                                            <div class="task-in-end">
                                                <SubTasks :list-user="listUser" />
                                            </div>
                                        </div>
                                    </div>
                                </a-tab-pane>
                                <!-- Tab 2: Lịch sử phê duyệt -->
                                <a-tab-pane key="approval-history" tab="Lịch sử phê duyệt">
                                    <div class="task-info-content">
                                        <a-row :gutter="16">
                                            <a-col :span="24">
                                                <a-table :columns="logColumns" :data-source="logData" row-key="id">
                                                    <template #bodyCell="{ column, record }">
                                                        <template v-if="column.dataIndex === 'level'">Cấp {{ record.level }}</template>
                                                        <template v-else-if="column.dataIndex === 'status'">
                                                            <a-tag :color="getStatusColor(record.status)">
                                                                {{ getStatusText(record.status) }}
                                                            </a-tag>
                                                        </template>
                                                        <template v-else-if="column.dataIndex === 'approved_by_name'">
                                                            {{ record.approved_by_name || '—' }}
                                                        </template>
                                                        <template v-else-if="column.dataIndex === 'comment'">
                                                            {{ record.comment || '—' }}
                                                        </template>
                                                    </template>
                                                </a-table>
                                            </a-col>
                                        </a-row>
                                    </div>
                                </a-tab-pane>

                                <!-- Tab 3: Tài liệu (MỚI) -->
                                <a-tab-pane key="attachments" tab="Tài liệu">
                                    <div class="task-info-content">
                                        <div class="task-in-end">
                                            <!-- TEMPLATE -->
                                            <a-card bordered class="doc-section">
                                                <template #title>
                                                    Tài liệu đính kèm
                                                </template>

                                                <template #extra>
                                                    <a-segmented
                                                        v-model:value="activeMode"
                                                        :options="[
                                                          { label: 'Upload file', value: 'upload' },
                                                          { label: 'Lưu link', value: 'link' }
                                                        ]"
                                                    />
                                                </template>

                                                <div v-if="activeMode === 'upload'">
                                                    <a-form layout="vertical">
                                                        <a-form-item name="file" class="mb-0">
                                                            <a-upload-dragger
                                                                :file-list="computedUploadList"
                                                                :before-upload="handleBeforeUpload"
                                                                :on-remove="handleRemoveFile"
                                                                :multiple="true"
                                                                :disabled="loadingUploadFile"
                                                                accept="*"
                                                            >
                                                                <p class="ant-upload-drag-icon">
                                                                    <PaperClipOutlined />
                                                                </p>
                                                                <p class="ant-upload-text">Kéo thả file vào đây hoặc bấm để chọn</p>
                                                                <p class="ant-upload-hint">Hỗ trợ nhiều file. Dung lượng/định dạng tuỳ cấu hình server.</p>
                                                            </a-upload-dragger>
                                                        </a-form-item>

                                                        <!-- Tiêu đề cho từng file chờ upload -->
                                                        <a-form-item
                                                            v-if="pendingFiles?.length"
                                                            label="Tiêu đề cho file đã chọn"
                                                            class="mt-3"
                                                        >
                                                            <div class="pending-list">
                                                                <div
                                                                    v-for="(file, index) in (pendingFiles || []).filter(f => f && typeof f === 'object')"
                                                                    :key="file.uid ?? file.name ?? index"
                                                                    class="pending-item"
                                                                >
                                                                    <a-input
                                                                        v-model:value="file.title"
                                                                        :status="!file?.title ? 'error' : ''"
                                                                        :placeholder="`Tiêu đề cho: ${file?.name || 'file #' + (index+1)}`"
                                                                        allow-clear
                                                                    />
                                                                </div>
                                                            </div>
                                                        </a-form-item>

                                                        <a-form-item style="margin-top: 20px">
                                                            <a-space>
                                                                <a-button
                                                                    type="primary"
                                                                    :disabled="!canSubmitUpload"
                                                                    @click="submitUpload"
                                                                >
                                                                    Lưu tài liệu (file)
                                                                </a-button>
                                                                <a-typography-text type="secondary">
                                                                    Yêu cầu: mỗi file cần có tiêu đề.
                                                                </a-typography-text>
                                                            </a-space>
                                                        </a-form-item>
                                                    </a-form>
                                                </div>

                                                <div v-else>
                                                    <a-form layout="vertical">
                                                        <a-form-item label="Tiêu đề tài liệu (link)">
                                                            <a-input
                                                                v-model:value="manualLink.title"
                                                                placeholder="Ví dụ: HSMT - Gói ABC - 2025"
                                                                allow-clear
                                                            />
                                                        </a-form-item>

                                                        <a-form-item label="URL tài liệu">
                                                            <a-input
                                                                v-model:value="manualLink.url"
                                                                placeholder="https://..."
                                                                type="url"
                                                                allow-clear
                                                            >
                                                                <template #prefix><LinkOutlined /></template>
                                                            </a-input>
                                                        </a-form-item>

                                                        <a-form-item>
                                                            <a-space>
                                                                <a-button
                                                                    type="primary"
                                                                    :disabled="!canSubmitLink"
                                                                    @click="submitLink"
                                                                >
                                                                    Lưu tài liệu (link)
                                                                </a-button>
                                                                <a-typography-text type="secondary">
                                                                    URL phải hợp lệ và có tiêu đề.
                                                                </a-typography-text>
                                                            </a-space>
                                                        </a-form-item>

                                                        <a-form-item v-if="manualLinks?.length" label="Link đã thêm">
                                                            <a-list bordered size="small" :data-source="manualLinks" class="link-list">
                                                                <template #renderItem="{ item, index }">
                                                                    <a-list-item :key="index">
                                                                        <div class="link-row">
                                                                            <div class="link-meta">
                                                                                <div class="link-title" :title="item.title">
                                                                                    <strong>{{ item.title }}</strong>
                                                                                </div>
                                                                                <a
                                                                                    class="link-url"
                                                                                    :href="item.url"
                                                                                    target="_blank"
                                                                                    rel="noopener"
                                                                                    :title="item.url"
                                                                                >{{ item.url }}</a>
                                                                            </div>
                                                                            <a-button type="text" danger @click="manualLinks.splice(index, 1)">
                                                                                <DeleteOutlined />
                                                                            </a-button>
                                                                        </div>
                                                                    </a-list-item>
                                                                </template>
                                                            </a-list>
                                                        </a-form-item>
                                                    </a-form>
                                                </div>
                                            </a-card>

                                        </div>
                                    </div>
                                </a-tab-pane>

                                <!-- Tab 4: Nhiệm vụ con -->

                            </a-tabs>
                        </div>
                    </a-card>
                </a-col>
                <!-- RIGHT: 1/3 — Subtasks + Thảo luận -->
                <a-col :span="8" :xs="24" :lg="8" :xl="8">
                    <a-card title="Thảo luận" bordered>
                        <div class="task-info-left">
                            <div class="task-info-content">
                                <div class="task-in-end">
                                    <Comment/>
                                </div>
                            </div>
                        </div>
                    </a-card>
                </a-col>
            </a-row>

<!--            <a-typography-title :level="5">Lịch sử phê duyệt</a-typography-title>-->
<!--            <a-table :columns="logColumns" :data-source="logData" row-key="id">-->
<!--                <template #bodyCell="{ column, record }">-->
<!--                    <template v-if="column.dataIndex === 'level'">Cấp {{ record.level }}</template>-->
<!--                    <template v-if="column.dataIndex === 'status'">-->
<!--                        <a-tag :color="getStatusColor(record.status)">-->
<!--                            {{ getStatusText(record.status) }}-->
<!--                        </a-tag>-->
<!--                    </template>-->
<!--                    <template v-if="column.dataIndex === 'approved_by_name'">-->
<!--                        {{ record.approved_by_name || '—' }}-->
<!--                    </template>-->
<!--                    <template v-if="column.dataIndex === 'comment'">-->
<!--                        {{ record.comment || '—' }}-->
<!--                    </template>-->
<!--                </template>-->
<!--            </a-table>-->
        </div>
    </div>
</template>
<script setup>
import {EllipsisOutlined, PaperClipOutlined, DeleteOutlined, LinkOutlined} from '@ant-design/icons-vue';
import {computed, nextTick, onMounted, reactive, ref, watch} from 'vue';
import {message} from 'ant-design-vue'
import 'dayjs/locale/vi';
import dayjs from 'dayjs';
import viVN from 'ant-design-vue/es/locale/vi_VN';
import {getUsers} from '@/api/user';
import {useRoute, useRouter} from 'vue-router';
import { formatDate  } from '@/utils/formUtils'
import {
    deleteTaskFilesAPI,
    getTaskDetail,
    getTaskFilesAPI,
    updateTask,
    uploadTaskFileAPI,
    uploadTaskLinkAPI
} from '@/api/task';
import {getBiddingAPI, getBiddingsAPI, getBiddingStepsAPI, updateBiddingStepAPI} from "@/api/bidding";
import {getContractAPI, getContractsAPI} from "@/api/contract";
import {getContractStepsAPI} from '@/api/contract-steps';
import {getDepartments} from '@/api/department'
import Comment from './Comment.vue';
import SubTasks from './SubTasks.vue'
import {useUserStore} from '@/stores/user';
import {getApprovalHistoryByTask} from '@/api/taskApproval'
import {getTaskExtensions} from "@/api/task.js";
import {useTaskDrawerStore} from '@/stores/taskDrawerStore';
import {useCommonStore} from '@/stores/common';
import debounce from "lodash-es/debounce";

const commonStore = useCommonStore()

dayjs.locale('vi');

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

const leftTab = ref('info') // tab mặc định

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
        {value: 'doing', label: 'Đang chuẩn bị', color: 'processing'},
        {value: 'request_approval', label: 'Gửi duyệt', color: 'blue'},
        // { value: 'done', label: 'Hoàn thành', color: 'success' },
        {value: 'overdue', label: 'Quá hạn', color: 'error'},
    ];
});
const departmentOptions = computed(() => {
    return listDepartment.value.map(ele => {
        return {value: ele.id, label: ele.name}
    })
})

const linkedTypeOption = ref([
    {value: "bidding", label: "Gói thầu"},
    {value: "contract", label: "Hợp đồng"},
    {value: "internal", label: "Nhiệm vụ nội bộ"},
])

const getTextLinkedType = computed(() => {
    let data = linkedTypeOption.value.find(ele => ele.value === formData.value.linked_type)
    if (data) {
        return data.label;
    } else {
        return "Nhiệm vụ nội bộ"
    }
})

// ✅ parent_id khác null/undefined/''/0 mới coi là "có cha"
const hasParent = computed(() => {
    const pid = formData.value?.parent_id
    return pid !== null && pid !== undefined && pid !== '' && pid !== 0
})

// Nếu có cha thì không cho ở tab "Việc con"
watch(hasParent, (v) => {
    if (v && leftTab.value === 'subtasks') leftTab.value = 'info'
})

const userOption = computed(() => {
    if (!listUser.value || !listUser.value.length) {
        return []
    } else {
        return listUser.value.map(ele => {
            return {
                value: ele.id,
                label: ele.name,
            }
        })
    }
})

// 1. biến reactive hiển thị tên:
const linkedName = ref('');

// 2. hàm lấy tên (ưu tiên list, nếu không có thì call API)
const getNameLinked = async (id) => {
    if (!id) return 'Trống'
    const idStr = String(id)

    if (formData.value.linked_type === 'bidding') {
        const found = (Array.isArray(listBidding.value) ? listBidding.value : [])
            .find(x => String(x.id) === idStr)
        if (found) return found.title
        const res = await getBiddingAPI(id)
        return res.data?.title ?? 'Gói thầu không tồn tại'
    }

    if (formData.value.linked_type === 'contract') {
        const found = (Array.isArray(listContract.value) ? listContract.value : [])
            .find(x => String(x.id) === idStr)
        if (found) return found.title
        const res = await getContractAPI(id)
        return res.data?.title ?? 'Hợp đồng không tồn tại'
    }

    return 'Trống'
}


// 3. watch để cập nhật tên khi linked_id hoặc linked_type thay đổi
watch(
    () => [formData.value.linked_id, formData.value.linked_type],
    async ([id]) => {
        linkedName.value = await getNameLinked(id);
    },
    { immediate: true }
);


const searchBidding = debounce(async (value) => {
    const res = await getBiddingsAPI({ search: value, per_page: 20 })
    listBidding.value = res.data.data
}, 400)    // chờ 400ms sau khi dừng gõ mới gọi API


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

const numericProgress = computed({
    get: () => Number(formData.value.progress || 0),
    set: (val) => formData.value.progress = val
})

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
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
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


const linkedIdOption = computed(() => {
    if (formData.value.linked_type === 'contract') {
        const arr = Array.isArray(listContract.value) ? listContract.value : []
        return arr.map(ele => ({ value: String(ele.id), label: ele.title }))
    }
    if (formData.value.linked_type === 'bidding') {
        const arr = Array.isArray(listBidding.value) ? listBidding.value : []
        return arr.map(ele => ({ value: String(ele.id), label: ele.title }))
    }
    return []
})

const validateTitle = async (_rule, value) => {
    if ((value || '') === '') return Promise.reject('Vui lòng nhập tên nhiệm vụ')
    if (value.length > 200) return Promise.reject('Tên nhiệm vụ không vượt quá 200 ký tự')
    return Promise.resolve()
}
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
        title: [{required: true, validator: validateTitle, trigger: 'change'}],
        time: [{required: true, validator: validateTime, trigger: 'change'}],
        priority: [{required: true, validator: validatePriority, trigger: 'change'}],
        assigned_to: [{required: true, validator: validateAsigned, trigger: 'change'}],
        linked_type: [{required: true, validator: validateLinkedType, trigger: 'change'}],
        description: [{required: true, validator: validateDescription, trigger: 'change'}],
    }
})
const stepOption = ref([])

// Method
const handleChangeLinkedType = () => {
    formData.value.linked_id = null;
    formData.value.step_code = null;
};
const handleChangeLinkedId = () => {
    const type = formData.value.linked_type
    const linkedId = formData.value.linked_id
    commonStore.setLinkedType(type)
    commonStore.setLinkedIdParent(linkedId)

    if (type === 'bidding') getBiddingStep(linkedId)
    else if (type === 'contract') getContractStep()
}

const handleChangeStep = (e) => {
    console.log('e', e)
}
const getContractStep = async () => {
    await getContractStepsAPI(formData.value.linked_id).then(res => {
        stepOption.value = res.data ? res.data.map(ele => {
            return {value: ele.step_number, label: ele.title, step_id: ele.id}
        }) : []
    }).catch(err => {

    })
}

const getBiddingStep = async (id) => {
    await getBiddingStepsAPI(formData.value.linked_id).then(res => {
        stepOption.value = res.data ? res.data.map(ele => {
            return {value: ele.step_number, label: ele.title, step_id: ele.id}
        }) : []
    }).catch(err => {

    })
}

const getStepByStepNo = (step) => {
    let data = stepOption.value.find(ele => ele.value === step);
    if (!data) {
        return "Trống";
    } else {
        return data.label;
    }
}
const checkPriority = (text) => {
    let data = priorityOption.value.find(ele => ele.value === text);
    if (data) {
        return data
    } else {
        return {value: "", label: "", color: ""}
    }
};
const checkStatus = (text) => {
    let data = statusOption.value.find(ele => ele.value === text);
    if (data) {
        return data
    } else {
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
const getUserById = (userId) => {
    let data = listUser.value.find(ele => ele.id === userId);
    if (!data) {
        return "";
    }
    return data.name;
}
const getDepartmentById = (userId) => {
    let data = listDepartment.value.find(ele => ele.id === userId);
    if (!data) {
        return "";
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

    const hasInvalidTitle = (pendingFiles.value || []).some(f => !f?.title?.trim())
    if (hasInvalidTitle) {
        message.error('Vui lòng nhập tiêu đề cho tất cả tài liệu đính kèm.')
        return
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
    try {
        const res = await getTaskDetail(route.params.id)
        formData.value = res.data
        const parentId = Number(route.params.id)
        commonStore.setParentTaskId(parentId)

    } catch (err) {
        console.error(err)
    }
}


const getListBidding = async () => {
    await getBiddingsAPI().then(res => {
        listBidding.value = res.data.data
    }).catch(err => {

    })
}

const getListContract = async () => {
    try {
        const res = await getContractsAPI({ per_page: 1000, with_progress: 0 })
        // ✅ chỉ lấy mảng
        listContract.value = Array.isArray(res.data?.data) ? res.data.data : []
    } catch {
        listContract.value = []
    }
}

const store = useUserStore();
const fileList = ref([]);
const loadingUploadFile = ref(false);
const pendingFiles = ref([]);

const fetchTaskFiles = async () => {
    const taskId = route.params.id;

    if (!taskId) {
        console.warn('Thiếu taskId trong route.params');
        fileList.value = [];
        return;
    }

    try {
        const res = await getTaskFilesAPI(taskId);
        fileList.value = (res.data || []).map(f => ({
            uid: f.id || f.file_name,
            name: f.file_name,
            status: 'done',
            url: f.file_path,
            ...f
        }));
    } catch (e) {
        console.error('Lỗi khi fetch task files:', e);
        fileList.value = [];
    }
};


const handleBeforeUpload = (file) => {
    // Ant Upload cung cấp sẵn file.uid
    pendingFiles.value.push({
        uid: file.uid,
        raw: file,
        name: file.name,
        title: ''
    })
    return false // tự xử lý upload
}


const handleRemoveFile = async (file) => {
    const uid = file?.uid

    // Nếu là pending (chưa upload) → xoá local
    const isPending = Array.isArray(pendingFiles.value)
        && pendingFiles.value.some(f => f?.uid === uid)

    if (isPending) {
        pendingFiles.value = pendingFiles.value.filter(f => f?.uid !== uid)
        return true
    }

    // Nếu là file đã upload → gọi API xoá server
    try {
        await deleteTaskFilesAPI(file.id)
        await fetchTaskFiles()
        message.success('Xóa file thành công')
    } catch (e) {
        message.error('Xóa file thất bại')
    }
    return true
}

const getApprovalText = (status) => {
    switch (status) {
        case 'pending':
            return 'Đang chờ duyệt'
        case 'approved':
            return 'Đã duyệt'
        case 'rejected':
            return 'Đã từ chối'
        default:
            return 'Không xác định'
    }
};
const getApprovalColor = (status) => {
    switch (status) {
        case 'pending':
            return 'orange'
        case 'approved':
            return 'green'
        case 'rejected':
            return 'red'
        default:
            return 'default'
    }
}


const fetchExtensions = async () => {
    try {
        const res = await getTaskExtensions(route.params.id);
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
    {title: 'Cấp', dataIndex: 'level'},
    {title: 'Trạng thái', dataIndex: 'status'},
    {title: 'Người duyệt', dataIndex: 'approved_by_name'},
    {title: 'Ghi chú', dataIndex: 'comment'},
]

const getStatusColor = (status) => {
    switch (status) {
        case 'pending':
            return 'orange'
        case 'approved':
            return 'green'
        case 'rejected':
            return 'red'
        default:
            return ''
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
    const taskId = route.params.id

    if (!taskId) {
        console.warn('Thiếu task ID từ route.params');
        logData.value = []
        return
    }

    try {
        const res = await getApprovalHistoryByTask(taskId)
        logData.value = Array.isArray(res.data) ? res.data : []
    } catch (e) {
        console.error('Lỗi khi lấy log:', e)
        logData.value = []
    }
}

const computedUploadList = computed(() => {
    const uploaded = Array.isArray(fileList.value)
        ? fileList.value.filter(Boolean).map(f => ({
            ...f,
            uid: f.uid || f.id || f.file_name || f.name,   // đảm bảo có uid
            name: f.title ? `${f.title} (${f.file_name || f.name})` : (f.file_name || f.name),
            url: f.is_link ? f.link_url : f.file_path,     // đừng gán luôn link_url
            status: 'done'
        }))
        : []

    const pending = Array.isArray(pendingFiles.value)
        ? pendingFiles.value
            .filter(f => f && typeof f === 'object')       // 🔒 lọc undefined/null
            .map(f => ({
                uid: f.uid,                                  // dùng uid thật từ Upload
                name: f.title ? `${f.title} (${f.name})` : f.name,
                status: 'ready'
            }))
        : []

    return [...uploaded, ...pending]
})


const manualLink = reactive({title: '', url: ''});
const manualLinks = ref([]);

const addManualLink = async () => {
    if (!manualLink.title || !manualLink.url) return;
    manualLinks.value.push({...manualLink});
    const formData = new FormData();
    formData.append('title', manualLink.title);
    formData.append('url', manualLink.url);
    formData.append('user_id', store.currentUser.id);
    await uploadTaskLinkAPI(route.params.id, formData);
    await fetchTaskFiles();
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

const approvalStatusOption = [
    {value: 'pending', label: 'Chờ duyệt'},
    {value: 'approved', label: 'Đã duyệt'},
    {value: 'rejected', label: 'Từ chối'}
];

function checkApprovalStatus(status) {
    switch (status) {
        case 'approved':
            return {label: 'Đã duyệt', color: 'green'};
        case 'pending':
            return {label: 'Chờ duyệt', color: 'orange'};
        case 'rejected':
            return {label: 'Từ chối', color: 'red'};
        default:
            return {label: 'Không rõ', color: 'gray'};
    }
}

// CHẾ ĐỘ: 'upload' | 'link'
const activeMode = ref('upload') // giá trị mặc định

// Validate đơn giản:
const canSubmitUpload = computed(() => {
    const arr = Array.isArray(pendingFiles.value)
        ? pendingFiles.value.filter(f => f && typeof f === 'object')
        : []
    if (!arr.length) return false
    return arr.every(f => typeof f.title === 'string' && f.title.trim().length > 0)
})

const canSubmitLink = computed(() => {
    const t = (manualLink.title || '').trim()
    const u = (manualLink.url || '').trim()
    if (!t || !u) return false
    try {
        const url = new URL(u)
        return !!url.protocol && !!url.host
    } catch { return false }
})

function submitUpload() {
    // TODO: gọi API upload theo pendingFiles (raw + title)
    // sau khi thành công -> reset
    // pendingFiles.value = []; computedUploadList.value = []
}

function submitLink() {
    const t = (manualLink.title || '').trim()
    const u = (manualLink.url || '').trim()
    if (!t || !u) return
    manualLinks.value.push({ title: t, url: u })
    manualLink.title = ''
    manualLink.url = ''
}


const goBack = () => {
    if (window.history.length > 1) {
        router.back();
    } else {
        router.push('/internal-tasks');
    }
}

const goToTask = (id) => {
    if (!id) return;
    router.push({
        name: 'internal-tasks-info',
        params: { id }
    });
};


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
    {immediate: true}
)

watch(numericProgress, (val) => {
    if (val === 100 && formData.value.approval_steps > 0 && formData.value.approval_status !== 'approved') {
        message.warning('Không thể đặt tiến độ 100% trước khi được duyệt!');
        numericProgress.value = 95; // hoặc giá trị trước đó nếu bạn lưu
    }
});

onMounted(async () => {
    try {
        await getDepartment()
        await getDetailTaskById()
        await getUser()
        await getListBidding()
        await getListContract()
        await fetchTaskFiles()
        await fetchLogHistory()
        // await fetchExtensions();
        // await fetchExtensionHistory();
        handleChangeLinkedId()

    } catch (e) {
        console.error('❌ Lỗi khi gọi API log:', e)
        logData.value = []
    }
})


</script>
<style scoped>

.task-info {
    margin-top: 16px;
}

.task-info-left {
    margin-bottom: 20px;
}

.task-info-content {
    border-radius: 8px;
}

.task-in {
    border-bottom: 1px solid #bebebece;
    padding-bottom: 0;
}

.task-in-end {
    border-bottom: none;
}

:deep(label) {
    color: #999999 !important;
}

:deep(.ant-form-item) {
    margin-bottom: 14px;
}

:deep(.ant-form-item-label) {
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
.panel {
    border: 1px solid #bebebece;
    border-radius: 8px;
    background: #fff;
}

.mt16 { margin-top: 16px; }
.mb16 { margin-bottom: 16px; }

/* các khối form cũ giữ nguyên */
.task-in {
    border-bottom: 1px solid #bebebece;
    padding-bottom: 0;
}
.task-in-end {
    border-bottom: none;
}

/* cột phải bám theo khi cuộn, dừng ở dưới header */
.sticky {
    position: sticky;
    top: 76px; /* chỉnh theo chiều cao header của bạn */
}

.task-left-tabs :deep(.ant-tabs-tab) { font-weight: 500; }
.mt16 { margin-top: 16px; }
.task-info-content { border-radius:8px; background:#fff; }
.task-in { border-bottom:1px solid #bebebece; padding-bottom:0; }
.task-in-end { border-bottom:none; }
.p-14 {
    padding: 14px;
}
.header-wrapper {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px; /* giữ khoảng cách dưới */
}

.action {
    display: flex;
    gap: 8px; /* khoảng cách giữa nút */
}

.doc-section :deep(.ant-upload.ant-upload-drag) {
    border-radius: 12px;
}
.pending-list {
    display: grid;
    gap: 8px;
}
.pending-item :deep(.ant-input) {
    height: 36px;
}
.link-list :deep(.ant-list-item) {
    padding: 8px 12px;
}
.link-row {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 8px;
}
.link-meta {
    flex: 1;
    min-width: 0;
}
.link-title {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.link-url {
    display: inline-block;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.hint {
    font-size: 12px;
}
.mt-3 { margin-top: 12px; }
.mb-0 { margin-bottom: 0; }

</style>