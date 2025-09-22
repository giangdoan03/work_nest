<template>
    <div class="task">
        <div class="header-wrapper">
            <a-page-header
                title="Về danh sách"
                @back="goBack"
                style="padding: 0;"
            />
            <div class="action">
                <a-button type="primary" v-if="!isEditMode" @click="editTask">Chỉnh sửa</a-button>
                <a-button type="primary" v-if="isEditMode" @click="saveEditTask">Lưu</a-button>
                <a-button v-if="isEditMode" @click="cancelEditTask">Hủy</a-button>
                <a-dropdown trigger="click">
                    <a-button>
                        <EllipsisOutlined/>
                    </a-button>
                    <template #overlay>
                        <a-menu>
                            <a-menu-item danger>
                                <a-popconfirm
                                    title="Bạn chắc chắn muốn xoá nhiệm vụ này?"
                                    ok-text="Xoá"
                                    cancel-text="Huỷ"
                                    ok-type="danger"
                                    :disabled="deleting"
                                    @confirm="handleDeleteCurrentTask"
                                >
                                    <template #icon>
                                        <DeleteOutlined/>
                                    </template>
                                    <span :class="{ 'is-loading': deleting }">Xoá nhiệm vụ</span>
                                </a-popconfirm>
                            </a-menu-item>
                        </a-menu>
                    </template>
                </a-dropdown>
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
                                            <a-form ref="formRef" :model="formData" :rules="isEditMode ? rules : {}"
                                                    layout="vertical">
                                                <div class="task-in">
                                                    <a-row :gutter="16">
                                                        <a-col :span="12">
                                                            <a-form-item label="Tên công việc" name="title">
                                                                <a-typography-text v-if="!isEditMode">{{
                                                                        formData.title
                                                                    }}
                                                                </a-typography-text>
                                                                <a-input v-else v-model:value="formData.title"
                                                                         placeholder="Nhập tên nhiệm vụ"/>
                                                            </a-form-item>
                                                        </a-col>
                                                        <a-col :span="12">
                                                            <a-form-item label="Loại nhiệm vụ" name="linked_type">
                                                                <a-tag v-if="!isEditMode">
                                                                    <strong>{{ getTextLinkedType }}</strong>
                                                                </a-tag>
                                                                <a-select v-else v-model:value="formData.linked_type"
                                                                          :options="linkedTypeOption"
                                                                          @change="handleChangeLinkedType()"
                                                                          placeholder="Chọn loại nhiệm vụ"/>
                                                            </a-form-item>
                                                        </a-col>
                                                        <a-col :span="24">
                                                            <a-form-item label="Công việc cha xxx">
                                                                <template v-if="formData.parent_id">
                                                                    <a-tooltip
                                                                        :title="formData.parent_title || ('#' + formData.parent_id)">
                                                                        <a-typography-link
                                                                            @click="goTaskByParentId(formData.parent_id)">
                                                                            {{
                                                                                formData.parent_title || ('#' + formData.parent_id)
                                                                            }}
                                                                        </a-typography-link>
                                                                    </a-tooltip>
                                                                </template>
                                                                <template v-else>
                                                                    <a-typography-text type="secondary">—
                                                                    </a-typography-text>
                                                                </template>
                                                            </a-form-item>
                                                        </a-col>
                                                        <!-- ================== BIDDING ================== -->
                                                        <a-col :span="12" v-if="formData.linked_type === 'bidding'">
                                                            <a-form-item label="Liên kết gói thầu" name="linked_id">
                                                                <a-typography-text v-if="!isEditMode">{{
                                                                        linkedName
                                                                    }}
                                                                </a-typography-text>
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
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{ getStepByStepNo(formData.step_code) }}
                                                                </a-typography-text>
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
                                                                <a-typography-text v-if="!isEditMode">{{ linkedName }}
                                                                </a-typography-text>
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
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{ getStepByStepNo(formData.step_code) }}
                                                                </a-typography-text>
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
                                                                        {{
                                                                            (formatDate(formData.start_date) || "Trống") + " → " + (formatDate(formData.end_date) || "Trống")
                                                                        }}
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
                                                                <a-tag v-else-if="formData.days_remaining > 0"
                                                                       color="green">
                                                                    Còn {{ formData.days_remaining }} ngày
                                                                </a-tag>
                                                                <a-tag v-else-if="formData.days_remaining === 0"
                                                                       :color="'#faad14'">
                                                                    Hạn chót hôm nay
                                                                </a-tag>
                                                                <a-tag v-else>
                                                                    —
                                                                </a-tag>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Độ ưu tiên" name="priority">
                                                                <a-tag v-if="!isEditMode"
                                                                       :color="checkPriority(formData.priority).color">
                                                                    {{ checkPriority(formData.priority).label }}
                                                                </a-tag>
                                                                <a-select v-else v-model:value="formData.priority"
                                                                          :options="priorityOption"
                                                                          placeholder="Chọn độ ưu tiên"/>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Trạng thái" name="status">
                                                                <template v-if="!isEditMode">
                                                                    <a-tag
                                                                        v-if="formData.approval_status === 'approved'"
                                                                        color="success">Hoàn
                                                                        thành
                                                                    </a-tag>
                                                                    <a-tag v-else
                                                                           :color="checkStatus(formData.status).color">
                                                                        {{ checkStatus(formData.status).label }}
                                                                    </a-tag>
                                                                </template>
                                                                <a-select v-else v-model:value="formData.status"
                                                                          :options="statusOption"
                                                                          placeholder="Chọn trạng thái"/>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Phê duyệt" name="approval_status">
                                                                <a-tag
                                                                    :color="formData.approval_status === 'approved' ? 'green' : 'orange'">
                                                                    {{
                                                                        formData.approval_status === 'approved' ? 'Đã duyệt' : 'Chưa duyệt'
                                                                    }}
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
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{ getUserById(formData.assigned_to) }}
                                                                </a-typography-text>
                                                                <a-select v-else v-model:value="formData.assigned_to"
                                                                          :options="userOption"
                                                                          placeholder="Chọn người dùng"/>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Phòng ban" name="id_department">
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{ getDepartmentById(formData.id_department) }}
                                                                </a-typography-text>
                                                                <a-select v-else v-model:value="formData.id_department"
                                                                          :options="departmentOptions"
                                                                          placeholder="Chọn người dùng"/>
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
                                                                    {{
                                                                        formData.description ? formData.description : "Trống"
                                                                    }}
                                                                </a-typography-text>
                                                                <a-textarea v-else v-model:value="formData.description"
                                                                            :rows="4" placeholder="Nhập mô tả"/>
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
                                                <SubTasks :list-user="listUser"/>
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
                                                        <template v-if="column.dataIndex === 'level'">Cấp
                                                            {{ record.level }}
                                                        </template>
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
                                            <AttachmentsCard :task-id="route.params.id"
                                                             :department-id="formData.id_department"/>
                                        </div>
                                    </div>
                                </a-tab-pane>
                            </a-tabs>
                        </div>
                    </a-card>
                </a-col>
                <!-- RIGHT: 1/3 — Subtasks + Thảo luận -->
                <a-col :span="8" :xs="24" :lg="8" :xl="8" class="right-col">
                    <a-card title="Thảo luận" bordered class="discussion-card">
                        <div class="task-info-left">
                            <div class="task-info-content">
                                <div class="task-in-end discussion-scroll" v-auto-maxheight="12">
                                    <Comment/>
                                </div>
                            </div>
                        </div>
                    </a-card>
                </a-col>
            </a-row>
        </div>
    </div>
</template>
<script setup>
import {
    EllipsisOutlined, DeleteOutlined
} from '@ant-design/icons-vue';
import {computed, nextTick, onMounted, reactive, ref, watch} from 'vue';
import {message} from 'ant-design-vue'
import 'dayjs/locale/vi';
import dayjs from 'dayjs';
import viVN from 'ant-design-vue/es/locale/vi_VN';
import {getUsers} from '@/api/user';
import {useRoute, useRouter} from 'vue-router';
import {formatDate} from '@/utils/formUtils'
import {
    getTaskDetail,
    getTaskFilesAPI,
    updateTask,
    uploadTaskFileAPI,
} from '@/api/task';
import {getBiddingAPI, getBiddingsAPI, getBiddingStepsAPI, updateBiddingStepAPI} from "@/api/bidding";
import {getContractAPI, getContractsAPI} from "@/api/contract";
import {getContractStepsAPI} from '@/api/contract-steps';
import {getDepartments} from '@/api/department'
import Comment from './Comment.vue';
import SubTasks from './SubTasks.vue'
import {useUserStore} from '@/stores/user';
import {getApprovalHistoryByTask} from '@/api/taskApproval'
import {getTaskExtensions, deleteTask} from "@/api/task.js";
import {useTaskDrawerStore} from '@/stores/taskDrawerStore';
import {useCommonStore} from '@/stores/common';
import debounce from "lodash-es/debounce";
import AttachmentsCard from '@/components/AttachmentsCard.vue'

const commonStore = useCommonStore()

dayjs.locale('vi');

const extensionHistory = ref([]);
const route = useRoute();
const router = useRouter();
const locale = ref(viVN);
const isEditMode = ref(false);

const listUser = ref([])
const loading = ref(false)
const loadingUpdate = ref(false)
const listContract = ref([]);
const listBidding = ref([]);
const dateRange = ref([]);
const listDepartment = ref([])

const formDataSave = ref()
const logData = ref([])

const leftTab = ref('info') // tab mặc định
const deleting = ref(false)

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

const handleDeleteCurrentTask = async () => {
    try {
        deleting.value = true
        const id = route.params.id
        await deleteTask(id)
        message.success('Đã xoá nhiệm vụ')
        // điều hướng về danh sách (tuỳ page của bạn)
        router.back()
    } catch (e) {
        console.error(e)
        message.error('Xoá nhiệm vụ thất bại')
    } finally {
        deleting.value = false
    }
}

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


// Cache nhẹ để bấm nhiều lần không gọi API lặp
const __taskMetaCache = new Map();

/**
 * Lấy meta task theo id (có cache)
 */
const resolveTaskMetaById = async (id) => {
    const key = String(id);
    if (__taskMetaCache.has(key)) return __taskMetaCache.get(key);

    const res = await getTaskDetail(id);       // ✅ dùng sẵn API bạn đang import
    const t = res?.data || {};

    // Chuẩn hoá meta tối thiểu cần để build URL
    const meta = {
        id: t.id,
        linked_type: t.linked_type,           // 'bidding' | 'contract' | 'internal' | ...
        step_id: t.step_id ?? t.step_code ?? null,

        // Nếu backend của bạn dùng linked_id = id của bidding/contract cha:
        // - bidding: dùng linked_id làm bidding_id
        // - contract: dùng linked_id làm contract_id
        bidding_id: t.linked_type === 'bidding' ? (t.linked_id ?? null) : null,
        contract_id: t.linked_type === 'contract' ? (t.linked_id ?? null) : null,
    };

    __taskMetaCache.set(key, meta);
    return meta;
};

/**
 * Build URL chi tiết theo 5 pattern dựa trên meta
 */
const buildDetailUrlFromMeta = (meta) => {
    const taskId = meta.id;

    // Ưu tiên route có step (bidding/contract + step)
    if (meta.bidding_id && meta.step_id) {
        return `/biddings/${meta.bidding_id}/steps/${meta.step_id}/tasks/${taskId}/info`;
    }
    if (meta.contract_id && meta.step_id) {
        return `/contract/${meta.contract_id}/steps/${meta.step_id}/tasks/${taskId}/info`;
    }

    // Workflow dạng đơn
    if (meta.linked_type === 'bidding') {
        return `/workflow/bidding-tasks/${taskId}/info`;
    }
    if (meta.linked_type === 'contract') {
        return `/workflow/contract-tasks/${taskId}/info`;
    }

    // Non-workflow (internal)
    return `/non-workflow/tasks/${taskId}/info`;
};

/**
 * 👉 HÀM DÙNG CHUNG TẠI TEMPLATE:
 * Chỉ cần truyền parentId, hàm tự gọi API và điều hướng.
 */
const goTaskByParentId = async (parentId) => {
    if (!parentId) return;
    try {
        const meta = await resolveTaskMetaById(parentId);
        const url = buildDetailUrlFromMeta(meta);
        router.push(url);
    } catch (e) {
        console.error('Không mở được task cha:', e);
        message.error('Không mở được nhiệm vụ cha');
    }
};


// 1. biến reactive hiển thị tên:
const linkedName = ref('');

// 2. hàm lấy tên (ưu tiên list, nếu không có thì call API)
const getNameLinked = async (id) => {
    if (!id) return 'Trống'
    const idStr = String(id)
    try {
        if (formData.value.linked_type === 'bidding') {
            const found = (Array.isArray(listBidding.value) ? listBidding.value : [])
                .find(x => String(x.id) === idStr)
            if (found) return found.title
            const res = await getBiddingAPI(id)
            return res.data?.title || 'Gói thầu không tồn tại'
        }
        if (formData.value.linked_type === 'contract') {
            const found = (Array.isArray(listContract.value) ? listContract.value : [])
                .find(x => String(x.id) === idStr)
            if (found) return found.title
            const res = await getContractAPI(id)
            return res.data?.title || 'Hợp đồng không tồn tại'
        }
        return 'Trống'
    } catch (e) {
        // 404 hay lỗi mạng đều fallback mềm, KHÔNG throw
        return formData.value.linked_type === 'bidding'
            ? 'Gói thầu không tồn tại'
            : formData.value.linked_type === 'contract'
                ? 'Hợp đồng không tồn tại'
                : 'Trống'
    }
}


// 3. watch để cập nhật tên khi linked_id hoặc linked_type thay đổi
watch(
    () => [formData.value.linked_id, formData.value.linked_type],
    async ([id]) => {
        try {
            linkedName.value = await getNameLinked(id)
        } catch {
            linkedName.value = 'Trống'
        }
    },
    {immediate: true}
);


const searchBidding = debounce(async (value) => {
    const res = await getBiddingsAPI({search: value, per_page: 20})
    listBidding.value = res.data.data
}, 400)    // chờ 400ms sau khi dừng gõ mới gọi API


const numericProgress = computed({
    get: () => Number(formData.value.progress || 0),
    set: (val) => formData.value.progress = val
})


const linkedIdOption = computed(() => {
    if (formData.value.linked_type === 'contract') {
        const arr = Array.isArray(listContract.value) ? listContract.value : []
        return arr.map(ele => ({value: String(ele.id), label: ele.title}))
    }
    if (formData.value.linked_type === 'bidding') {
        const arr = Array.isArray(listBidding.value) ? listBidding.value : []
        return arr.map(ele => ({value: String(ele.id), label: ele.title}))
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
    const id = formData.value.linked_id
    if (!id) {
        stepOption.value = [];
        return
    }
    try {
        const res = await getContractStepsAPI(id)
        stepOption.value = (res.data || []).map(ele => ({
            value: ele.step_number, label: ele.title, step_id: ele.id
        }))
    } catch {
        stepOption.value = []
    }
}

const getBiddingStep = async () => {
    const id = formData.value.linked_id
    if (!id) {
        stepOption.value = [];
        return
    }
    try {
        const res = await getBiddingStepsAPI(id)
        stepOption.value = (res.data || []).map(ele => ({
            value: ele.step_number, label: ele.title, step_id: ele.id
        }))
    } catch {
        stepOption.value = []
    }
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
        const res = await getContractsAPI({per_page: 1000, with_progress: 0})
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


const manualLink = reactive({title: '', url: ''});
const manualLinks = ref([]);


const getDepartment = async () => {
    try {
        const response = await getDepartments();
        listDepartment.value = response.data;
    } catch (e) {
        message.error('Không thể tải người dùng')
    } finally {
    }
}


const vAutoMaxheight = {
    mounted(el, binding) {
        const extra = Number(binding?.value ?? 0)
        const setH = () => {
            const rect = el.getBoundingClientRect()
            const vh = window.innerHeight || document.documentElement.clientHeight
            const h = Math.max(120, vh - rect.top - extra)
            el.style.maxHeight = h + 'px'
            el.style.overflowY = 'auto'   // ✅ chỉ cuộn dọc
            el.style.overflowX = 'hidden' // ✅ chặn cuộn ngang
            el.style.willChange = 'scroll-position'
        }
        const onResize = () => setH()
        const onScroll = () => setH()
        const ro = new ResizeObserver(setH)
        ro.observe(document.body)
        setH()
        window.addEventListener('resize', onResize)
        window.addEventListener('scroll', onScroll, {passive: true})
        el.__autoMH = {ro, onResize, onScroll}
    },
    beforeUnmount(el) {
        const s = el.__autoMH
        if (!s) return
        s.ro.disconnect()
        window.removeEventListener('resize', s.onResize)
        window.removeEventListener('scroll', s.onScroll)
        delete el.__autoMH
    }
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
        params: {id}
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

.mt16 {
    margin-top: 16px;
}

.mb16 {
    margin-bottom: 16px;
}

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

.task-left-tabs :deep(.ant-tabs-tab) {
    font-weight: 500;
}

.mt16 {
    margin-top: 16px;
}

.task-info-content {
    border-radius: 8px;
    background: #fff;
}

.task-in {
    border-bottom: 1px solid #bebebece;
    padding-bottom: 0;
}

.task-in-end {
    border-bottom: none;
}

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

/* vùng cuộn của Comment */
.discussion-scroll {
    overflow-y: auto; /* ✅ chỉ dọc */
    overflow-x: hidden; /* ✅ chặn ngang */
    scrollbar-gutter: stable;
    padding-right: 2px;
    overscroll-behavior: contain; /* mượt hơn trên mobile */
    scrollbar-width: thin; /* Firefox */
    scrollbar-color: rgba(0, 0, 0, .35) transparent; /* Firefox */
}

/* Chrome/Edge/Safari */
.discussion-scroll::-webkit-scrollbar {
    width: 6px;
}

.discussion-scroll::-webkit-scrollbar-track {
    background: transparent;
}

.discussion-scroll::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, .28);
    border-radius: 8px;
}

.discussion-scroll:hover::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, .38);
}

/* cho text dài/URL tự xuống dòng, tránh tạo thanh ngang */
.comment .content,
.comment .cm-att,
.comment .cm-att__title {
    overflow-wrap: anywhere;
    word-break: break-word;
}

/* ảnh/preview không vượt quá khung */
.comment img,
.comment :deep(.ant-image-img) {
    max-width: 100%;
    height: auto;
}

/* fix flex child trong ant-col gây tràn ngang khi có text dài */
.comment :deep(.ant-col[flex="1"]) {
    min-width: 0;
}

</style>