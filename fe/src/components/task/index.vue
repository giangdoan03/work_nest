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
                                                                <a-typography-text v-if="!isEditMode">{{formData.title }}
                                                                </a-typography-text>
                                                                <a-input v-else v-model:value="formData.title"
                                                                         placeholder="Nhập tên nhiệm vụ"/>
                                                            </a-form-item>
                                                        </a-col>
                                                        <a-col :span="12">
                                                            <a-form-item label="Loại công việc" name="linked_type">
                                                                <a-tag v-if="!isEditMode">
                                                                    <strong>{{ getTextLinkedType }}</strong>
                                                                </a-tag>
                                                                <a-select v-else v-model:value="formData.linked_type"
                                                                          :options="linkedTypeOption"
                                                                          @change="handleChangeLinkedType()"
                                                                          placeholder="Chọn loại công việc"/>
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12" v-if="formData.linked_type === 'bidding'">
                                                            <a-form-item label="Công việc con" name="step_code">
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
                                                        <a-col :span="12">
                                                            <a-form-item label="Công việc cháu">
                                                                <template v-if="formData.parent_id">
                                                                    <a-tooltip
                                                                        :title="formData.parent_title || ('#' + formData.parent_id)">
                                                                        <a-typography-link
                                                                            @click="goTaskByParentId(formData.parent_id)">
                                                                            {{formData.parent_title || ('#' + formData.parent_id) }}
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
                                                            <a-form-item label="Gói thầu" name="linked_id">
                                                                <a-typography-text v-if="!isEditMode">{{linkedName}}
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
                                                            <a-form-item label="Người giao việc" name="assigned_by">
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{ getUserById(formData.assigned_by) }}
                                                                </a-typography-text>
                                                                <a-select
                                                                    v-else
                                                                    v-model:value="formData.assigned_by"
                                                                    :options="userOption"
                                                                    placeholder="Chọn người dùng"
                                                                />
                                                            </a-form-item>
                                                        </a-col>

                                                        <a-col :span="12">
                                                            <a-form-item label="Người phối hợp" name="collaborated_by">
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{ getUserById(formData.collaborated_by) }}
                                                                </a-typography-text>
                                                                <a-select v-else v-model:value="formData.collaborated_by"
                                                                          :options="userOption"
                                                                          placeholder="Chọn người dùng"/>
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
                                                            <a-form-item label="Ưu tiên" name="priority">
                                                                <a-tag v-if="!isEditMode"
                                                                       :color="checkPriority(formData.priority).color">
                                                                    {{ checkPriority(formData.priority).label }}
                                                                </a-tag>
                                                                <a-select v-else v-model:value="formData.priority" :options="priorityOption" placeholder="Chọn độ ưu tiên"/>
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
                                                                    {{formData.approval_status === 'approved' ? 'Đã duyệt' : 'Chưa duyệt' }}
                                                                </a-tag>
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
                                                            <!-- Mô tả -->
                                                            <a-form-item label="Mô tả" name="description">
                                                                <a-typography-text v-if="!isEditMode">
                                                                    {{formData.description ? formData.description : "Trống" }}
                                                                </a-typography-text>
                                                                <a-textarea v-else v-model:value="formData.description"
                                                                            :rows="4" placeholder="Nhập mô tả"/>
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
                                                        <!-- Phê duyệt -->
                                                        <a-col :span="24">
                                                            <a-form-item label="Phê duyệt">
                                                                <!-- CẦN DUYỆT -->
                                                                <template v-if="Number(formData.needs_approval) === 1">
                                                                    <div class="approver-list">
                                                                        <template v-if="approverRows.length">
                                                                            <div
                                                                                v-for="row in approverRows"
                                                                                :key="row.id"
                                                                                :class="['approver-item', row.status]"
                                                                            >
                                                                                <span class="name" style="margin-right: 10px">{{ row.name }}</span>
                                                                                <a-tag v-if="row.status==='approved'" color="green">Đã duyệt</a-tag>
                                                                                <a-tag v-else-if="row.status==='rejected'" color="red">Từ chối</a-tag>
                                                                                <a-tag v-else color="orange">Đang chờ</a-tag>
                                                                            </div>
                                                                        </template>
                                                                        <span v-else class="text-muted">Chưa chọn người duyệt</span>
                                                                    </div>
                                                                </template>

                                                                <!-- KHÔNG CẦN DUYỆT -->
                                                                <template v-else>
                                                                    <a-tag>Không cần phê duyệt</a-tag>
                                                                </template>
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
import { EllipsisOutlined, DeleteOutlined } from '@ant-design/icons-vue'
import { computed, nextTick, onMounted, reactive, ref, watch } from 'vue'
import { message } from 'ant-design-vue'
import 'dayjs/locale/vi'
import dayjs from 'dayjs'
import viVN from 'ant-design-vue/es/locale/vi_VN'
import { getUsers } from '@/api/user'
import { useRoute, useRouter } from 'vue-router'
import { formatDate } from '@/utils/formUtils'
import {
    getTaskDetail,
    getTaskFilesAPI,
    updateTask,
    uploadTaskFileAPI,
    getTaskExtensions,
    deleteTask,
} from '@/api/task'
import {
    getBiddingAPI,
    getBiddingsAPI,
    getBiddingStepsAPI,
    updateBiddingStepAPI,
} from '@/api/bidding'
import { getContractAPI, getContractsAPI } from '@/api/contract'
import {
    getContractStepsAPI,
    // ⚠️ Nếu bạn có API tương đương để gán task vào step contract, import ở đây:
    // updateContractStepAPI
} from '@/api/contract-steps'
import { getDepartments } from '@/api/department'
import Comment from './Comment.vue'
import SubTasks from './SubTasks.vue'
import { useUserStore } from '@/stores/user'
import { getApprovalHistoryByTask } from '@/api/taskApproval'
import { useTaskDrawerStore } from '@/stores/taskDrawerStore'
import { useCommonStore } from '@/stores/common'
import debounce from 'lodash-es/debounce'
import AttachmentsCard from '@/components/AttachmentsCard.vue'

const commonStore = useCommonStore()
dayjs.locale('vi')

const extensionHistory = ref([])
const route = useRoute()
const router = useRouter()
const locale = ref(viVN)
const isEditMode = ref(false)

const listUser = ref([])
const loading = ref(false)
const loadingUpdate = ref(false)
const listContract = ref([])
const listBidding = ref([])
const dateRange = ref([])
const listDepartment = ref([])

const formDataSave = ref()
const logData = ref([])

const leftTab = ref('info')
const deleting = ref(false)

const formData = ref({
    title: '',
    created_by: '',
    step_code: null,
    linked_type: null,
    description: '',
    linked_id: null,
    assigned_to: null,
    start_date: '',
    end_date: '',
    status: '',
    priority: null,
    parent_id: null,
    id_department: null,
    progress: 0,
    approver_ids: [],
    needs_approval: 0,
    approval_steps: 0,
    approval_status: '',
})

const priorityOption = ref([
    { value: 'low',    label: 'Thấp',   color: 'success' },
    { value: 'normal', label: 'Thường', color: 'warning' },
    { value: 'high',   label: 'Cao',    color: 'error' },
])

const statusOption = computed(() => [
    { value: 'doing',            label: 'Đang chuẩn bị', color: 'processing' },
    { value: 'request_approval', label: 'Gửi duyệt',     color: 'blue' },
    { value: 'overdue',          label: 'Quá hạn',        color: 'error' },
])

const departmentOptions = computed(() =>
    (listDepartment.value || []).map(ele => ({ value: ele.id, label: ele.name }))
)

const linkedTypeOption = ref([
    { value: 'bidding',  label: 'Gói thầu' },
    { value: 'contract', label: 'Hợp đồng' },
    { value: 'internal', label: 'Nhiệm vụ nội bộ' },
])

const getTextLinkedType = computed(() => {
    const data = linkedTypeOption.value.find(ele => ele.value === formData.value.linked_type)
    return data ? data.label : 'Nhiệm vụ nội bộ'
})

const handleDeleteCurrentTask = async () => {
    try {
        deleting.value = true
        const id = route.params.id
        await deleteTask(id)
        message.success('Đã xoá nhiệm vụ')
        router.back()
    } catch (e) {
        console.error(e)
        message.error('Xoá nhiệm vụ thất bại')
    } finally {
        deleting.value = false
    }
}

// ===== Context theo route (QUAN TRỌNG) =====
const isContractCtx = computed(() => !!route.params.contractId)
const isBiddingCtx  = computed(() => !!route.params.bidId)

const effectiveLinkedType = computed(() => {
    if (isContractCtx.value) return 'contract'
    if (isBiddingCtx.value)  return 'bidding'
    return formData.value.linked_type || 'internal'
})

const effectiveLinkedId = computed(() => {
    if (isContractCtx.value) return String(route.params.contractId)
    if (isBiddingCtx.value)  return String(route.params.bidId)
    return formData.value.linked_id ? String(formData.value.linked_id) : ''
})

// ===== Parent logic =====
const hasParent = computed(() => {
    const pid = formData.value?.parent_id
    return pid !== null && pid !== undefined && pid !== '' && pid !== 0
})
watch(hasParent, v => {
    if (v && leftTab.value === 'subtasks') leftTab.value = 'info'
})

// ===== Users =====
const userOption = computed(() =>
    (listUser.value || []).map(u => ({ value: u.id, label: u.name }))
)

const userNameById = computed(() => {
    const m = new Map()
    ;(listUser.value || []).forEach(u => {
        m.set(String(u.id), u.name || u.full_name || u.email || `#${u.id}`)
    })
    return m
})
const getUserName = id => userNameById.value.get(String(id)) || `#${id}`

// ===== Cache meta task (đi tới parent) =====
const __taskMetaCache = new Map()
const resolveTaskMetaById = async (id) => {
    const key = String(id)
    if (__taskMetaCache.has(key)) return __taskMetaCache.get(key)

    const res = await getTaskDetail(id)
    const t = res?.data || {}

    const meta = {
        id: t.id,
        linked_type: t.linked_type,
        step_id: t.step_id ?? t.step_code ?? null,
        bidding_id: t.linked_type === 'bidding'  ? (t.linked_id ?? null)   : null,
        contract_id: t.linked_type === 'contract' ? (t.linked_id ?? null)  : null,
    }
    __taskMetaCache.set(key, meta)
    return meta
}

const buildDetailUrlFromMeta = (meta) => {
    const taskId = meta.id
    if (meta.bidding_id && meta.step_id)  return `/biddings/${meta.bidding_id}/steps/${meta.step_id}/tasks/${taskId}/info`
    if (meta.contract_id && meta.step_id) return `/contract/${meta.contract_id}/steps/${meta.step_id}/tasks/${taskId}/info`
    if (meta.linked_type === 'bidding')   return `/workflow/bidding-tasks/${taskId}/info`
    if (meta.linked_type === 'contract')  return `/workflow/contract-tasks/${taskId}/info`
    return `/non-workflow/tasks/${taskId}/info`
}

const goTaskByParentId = async (parentId) => {
    if (!parentId) return
    try {
        const meta = await resolveTaskMetaById(parentId)
        router.push(buildDetailUrlFromMeta(meta))
    } catch (e) {
        console.error('Không mở được task cha:', e)
        message.error('Không mở được nhiệm vụ cha')
    }
}

// ===== Approvers / logs =====
const approverIds = computed(() => {
    const raw = formData.value.approver_ids ?? []
    if (Array.isArray(raw)) return raw.map(v => String(v)).filter(Boolean)
    try {
        const parsed = JSON.parse(raw || '[]')
        return Array.isArray(parsed) ? parsed.map(v => String(v)).filter(Boolean) : []
    } catch { return [] }
})

const approvedMap = computed(() => {
    const m = new Map()
    ;(Array.isArray(logData.value) ? logData.value : []).forEach(l => {
        const uid = l.approved_by ?? l.user_id ?? null
        if (!uid) return
        m.set(String(uid), l.status) // approved | rejected | pending
    })
    return m
})

const approverRows = computed(() =>
    approverIds.value.map(idStr => ({
        id: idStr,
        name: getUserName(idStr),
        status: approvedMap.value.get(idStr) || 'pending',
    }))
)

const isApproved = (uid) => logData.value.some(l => l.approved_by === uid && l.status === 'approved')

// ===== Linked name / steps =====
const linkedName = ref('')

const getNameLinked = async (id) => {
    const idStr = String(id || effectiveLinkedId.value || '')
    if (!idStr) return 'Trống'
    try {
        if (effectiveLinkedType.value === 'bidding') {
            const found = (listBidding.value || []).find(x => String(x.id) === idStr)
            if (found) return found.title
            const res = await getBiddingAPI(idStr)
            return res.data?.title || 'Gói thầu không tồn tại'
        }
        if (effectiveLinkedType.value === 'contract') {
            const found = (listContract.value || []).find(x => String(x.id) === idStr)
            if (found) return found.title
            const res = await getContractAPI(idStr)
            return res.data?.title || 'Hợp đồng không tồn tại'
        }
        return 'Trống'
    } catch {
        return effectiveLinkedType.value === 'bidding'
            ? 'Gói thầu không tồn tại'
            : effectiveLinkedType.value === 'contract'
                ? 'Hợp đồng không tồn tại'
                : 'Trống'
    }
}

watch(
    () => [effectiveLinkedId.value, effectiveLinkedType.value],
    async () => { linkedName.value = await getNameLinked(effectiveLinkedId.value) },
    { immediate: true }
)

const searchBidding = debounce(async (value) => {
    const res = await getBiddingsAPI({ search: value, per_page: 20 })
    listBidding.value = res.data.data
}, 400)

const numericProgress = computed({
    get: () => Number(formData.value.progress || 0),
    set: (val) => (formData.value.progress = val),
})

const linkedIdOption = computed(() => {
    if (effectiveLinkedType.value === 'contract') {
        const arr = Array.isArray(listContract.value) ? listContract.value : []
        return arr.map(ele => ({ value: String(ele.id), label: ele.title }))
    }
    if (effectiveLinkedType.value === 'bidding') {
        const arr = Array.isArray(listBidding.value) ? listBidding.value : []
        return arr.map(ele => ({ value: String(ele.id), label: ele.title }))
    }
    return []
})

// ===== Validate =====
const validateTitle = async (_r, v) => {
    if ((v || '') === '') return Promise.reject('Vui lòng nhập tên nhiệm vụ')
    if (v.length > 200) return Promise.reject('Tên nhiệm vụ không vượt quá 200 ký tự')
    return Promise.resolve()
}
const validateTime = async () => {
    if (formData.value.start_date === '') return Promise.reject('Vui lòng nhập thời gian nhiệm vụ')
    return Promise.resolve()
}
const validatePriority = async () => {
    if (!formData.value.priority) return Promise.reject('Vui lòng chọn độ ưu tiên')
    return Promise.resolve()
}
const validateAsigned = async () => {
    if (!formData.value.assigned_to) return Promise.reject('Vui lòng chọn người phụ trách')
    return Promise.resolve()
}
const validateLinkedType = async () => {
    if (!effectiveLinkedType.value) return Promise.reject('Vui lòng chọn loại công việc')
    return Promise.resolve()
}
const validateDescription = async (_r, v) => {
    if (v === '') return Promise.reject('Vui lòng nhập mô tả nhiệm vụ')
    return Promise.resolve()
}
const rules = computed(() => ({
    title:        [{ required: true, validator: validateTitle,        trigger: 'change' }],
    time:         [{ required: true, validator: validateTime,         trigger: 'change' }],
    priority:     [{ required: true, validator: validatePriority,     trigger: 'change' }],
    assigned_to:  [{ required: true, validator: validateAsigned,      trigger: 'change' }],
    linked_type:  [{ required: true, validator: validateLinkedType,   trigger: 'change' }],
    description:  [{ required: true, validator: validateDescription,  trigger: 'change' }],
}))

const stepOption = ref([])

// ===== Methods =====
const handleChangeLinkedType = () => {
    formData.value.linked_type = effectiveLinkedType.value // đồng bộ UI
    formData.value.linked_id   = effectiveLinkedId.value
    formData.value.step_code   = null
}

const handleChangeLinkedId = () => {
    // Lưu vào store tuỳ logic cũ
    commonStore.setLinkedType(effectiveLinkedType.value)
    commonStore.setLinkedIdParent(effectiveLinkedId.value)

    if (effectiveLinkedType.value === 'bidding')  getBiddingStep()
    else if (effectiveLinkedType.value === 'contract') getContractStep()
}

const handleChangeStep = (e) => {
    // e = step_code
    // đã có watcher ở dưới sync sang step_id
}

const getContractStep = async () => {
    const id = effectiveLinkedId.value
    if (!id) { stepOption.value = []; return }
    try {
        const res = await getContractStepsAPI(id)
        stepOption.value = (res.data || []).map(ele => ({
            value: ele.step_number, label: ele.title, step_id: ele.id,
        }))
    } catch { stepOption.value = [] }
}

const getBiddingStep = async () => {
    const id = effectiveLinkedId.value
    if (!id) { stepOption.value = []; return }
    try {
        const res = await getBiddingStepsAPI(id)
        stepOption.value = (res.data || []).map(ele => ({
            value: ele.step_number, label: ele.title, step_id: ele.id,
        }))
    } catch { stepOption.value = [] }
}

const getStepByStepNo = (step) => {
    const data = stepOption.value.find(ele => ele.value === step)
    return data ? data.label : 'Trống'
}

const checkPriority = (text) => priorityOption.value.find(ele => ele.value === text) || { value: '', label: '', color: '' }
const checkStatus   = (text) => statusOption.value.find(ele => ele.value === text)   || { value: '', label: '', color: '' }

const getUser = async () => {
    loading.value = true
    try {
        const response = await getUsers()
        listUser.value = response.data
    } catch (e) {
        message.error('Không thể tải người dùng')
    } finally {
        loading.value = false
    }
}
const getUserById = (userId) => (listUser.value.find(ele => ele.id === userId)?.name) || ''
const getDepartmentById = (id) => (listDepartment.value.find(ele => ele.id === id)?.name) || ''

const changeDateTime = (day) => {
    if (day && day.length === 2) {
        formData.value.start_date = day[0]?.format('YYYY-MM-DD')
        formData.value.end_date   = day[1]?.format('YYYY-MM-DD')
    } else {
        formData.value.start_date = ''
        formData.value.end_date   = ''
    }
}

const editTask = () => {
    formDataSave.value = { ...formData.value }
    isEditMode.value = true
}

const store = useUserStore()
const fileList = ref([])
const loadingUploadFile = ref(false)
const pendingFiles = ref([])

const saveEditTask = async () => {
    loadingUpdate.value = true

    // Đồng bộ step_id từ step_code
    const found = stepOption.value.find(item => item.value === formData.value.step_code)
    formData.value.step_id = found ? found.step_id : null

    // Nếu không sửa ngày thì giữ nguyên
    if (!formData.value.start_date && !formData.value.end_date) {
        formData.value.start_date = formDataSave.value.start_date
        formData.value.end_date   = formDataSave.value.end_date
    }

    // Nếu chọn “Gửi duyệt” trong UI
    if (formData.value.status === 'request_approval') {
        formData.value.approval_status = 'pending'
        formData.value.current_level   = 1
    }

    // Nếu đổi ngày kết thúc → thêm lý do gia hạn
    const isEndDateChanged = formData.value.end_date !== formDataSave.value.end_date
    if (isEndDateChanged) {
        formData.value.extend_reason = 'Gia hạn thời gian'
    }

    const hasInvalidTitle = (pendingFiles.value || []).some(f => !f?.title?.trim())
    if (hasInvalidTitle) {
        message.error('Vui lòng nhập tiêu đề cho tất cả tài liệu đính kèm.')
        loadingUpdate.value = false
        return
    }

    try {
        await updateTask(route.params.id, {
            ...formData.value,
            // đảm bảo backend nhận đúng ngữ cảnh:
            linked_type: effectiveLinkedType.value,
            linked_id:   effectiveLinkedId.value,
        })

        // Upload file nếu có
        for (const file of pendingFiles.value) {
            const formDataFile = new FormData()
            formDataFile.append('file', file.raw)
            formDataFile.append('title', file.title)
            formDataFile.append('user_id', store.currentUser.id)
            await uploadTaskFileAPI(route.params.id, formDataFile)
        }

        // Gán task vào step nếu có step_id
        if (formData.value.step_id) {
            if (effectiveLinkedType.value === 'bidding') {
                await updateBiddingStepAPI(formData.value.step_id, { task_id: route.params.id })
            } else if (effectiveLinkedType.value === 'contract') {
                // Nếu đã có API cho contract step, mở comment dưới:
                // await updateContractStepAPI(formData.value.step_id, { task_id: route.params.id })
            }
        }

        pendingFiles.value = []
        await fetchTaskFiles()
        await getDetailTaskById()
        await fetchExtensionHistory()
        await nextTick()
        message.success('Cập nhật thành công')
    } catch (error) {
        formData.value = formDataSave.value
        message.destroy()
        message.error('Không thể cập nhật chỉnh sửa')
    } finally {
        loadingUpdate.value = false
        isEditMode.value = false
    }
}

const cancelEditTask = () => { isEditMode.value = false }

const getDetailTaskById = async () => {
    try {
        const res = await getTaskDetail(route.params.id)
        formData.value = res.data

        // 🔧 Ép formData khớp context URL để UI/Watcher không gọi sai API
        if (isContractCtx.value) {
            formData.value.linked_type = 'contract'
            formData.value.linked_id   = String(route.params.contractId)
        } else if (isBiddingCtx.value) {
            formData.value.linked_type = 'bidding'
            formData.value.linked_id   = String(route.params.bidId)
        }

        const parentId = Number(route.params.id)
        commonStore.setParentTaskId(parentId)
    } catch (err) {
        console.error(err)
    }
}

const getListBidding = async () => {
    try {
        const res = await getBiddingsAPI()
        listBidding.value = res.data.data
    } catch { /* noop */ }
}

const getListContract = async () => {
    try {
        const res = await getContractsAPI({ per_page: 1000, with_progress: 0 })
        listContract.value = Array.isArray(res.data?.data) ? res.data.data : []
    } catch { listContract.value = [] }
}

const fetchTaskFiles = async () => {
    const taskId = route.params.id
    if (!taskId) { fileList.value = []; return }
    try {
        const res = await getTaskFilesAPI(taskId)
        fileList.value = (res.data || []).map(f => ({
            uid: f.id || f.file_name,
            name: f.file_name,
            status: 'done',
            url: f.file_path,
            ...f,
        }))
    } catch (e) {
        console.error('Lỗi khi fetch task files:', e)
        fileList.value = []
    }
}

const fetchExtensionHistory = async () => {
    try {
        const res = await getTaskExtensions(route.params.id)
        extensionHistory.value = res.data.extensions || []
    } catch (e) {
        console.error('❌ Lỗi khi lấy lịch sử gia hạn:', e)
        extensionHistory.value = []
    }
}

const logColumns = [
    { title: 'Cấp',        dataIndex: 'level' },
    { title: 'Trạng thái', dataIndex: 'status' },
    { title: 'Người duyệt',dataIndex: 'approved_by_name' },
    { title: 'Ghi chú',    dataIndex: 'comment' },
]

const getStatusColor = (status) => {
    switch (status) {
        case 'pending':  return 'orange'
        case 'approved': return 'green'
        case 'rejected': return 'red'
        default:         return ''
    }
}
const getStatusText = (status) => {
    switch (status) {
        case 'pending':  return 'Đang chờ'
        case 'approved': return 'Đã duyệt'
        case 'rejected': return 'Từ chối'
        default:         return 'Không xác định'
    }
}

const fetchLogHistory = async () => {
    const taskId = route.params.id
    if (!taskId) { logData.value = []; return }
    try {
        const res = await getApprovalHistoryByTask(taskId)
        logData.value = Array.isArray(res.data) ? res.data : []
    } catch (e) {
        console.error('Lỗi khi lấy log:', e)
        logData.value = []
    }
}

const manualLink = reactive({ title: '', url: '' })
const manualLinks = ref([])

const getDepartment = async () => {
    try {
        const response = await getDepartments()
        listDepartment.value = response.data
    } catch (e) {
        message.error('Không thể tải người dùng')
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
            el.style.overflowY = 'auto'
            el.style.overflowX = 'hidden'
            el.style.willChange = 'scroll-position'
        }
        const onResize = () => setH()
        const onScroll = () => setH()
        const ro = new ResizeObserver(setH)
        ro.observe(document.body)
        setH()
        window.addEventListener('resize', onResize)
        window.addEventListener('scroll', onScroll, { passive: true })
        el.__autoMH = { ro, onResize, onScroll }
    },
    beforeUnmount(el) {
        const s = el.__autoMH
        if (!s) return
        s.ro.disconnect()
        window.removeEventListener('resize', s.onResize)
        window.removeEventListener('scroll', s.onScroll)
        delete el.__autoMH
    },
}

const goBack = () => {
    if (window.history.length > 1) router.back()
    else router.push('/non-workflow')
}

const goToTask = (id) => {
    if (!id) return
    router.push({ name: 'non-workflow-info', params: { id } })
}

// ===== Watchers =====
watch(() => formData.value.step_code, (newCode) => {
    const found = stepOption.value.find(item => item.value === newCode)
    formData.value.step_id = found ? found.step_id : null
})

watch(
    () => [formData.value.start_date, formData.value.end_date],
    ([start, end]) => {
        dateRange.value = (start && end) ? [dayjs(start), dayjs(end)] : []
    },
    { immediate: true }
)

watch(numericProgress, (val) => {
    if (val === 100 && Number(formData.value.approval_steps) > 0 && formData.value.approval_status !== 'approved') {
        message.warning('Không thể đặt tiến độ 100% trước khi được duyệt!')
        numericProgress.value = 95
    }
})

onMounted(async () => {
    try {
        await getDepartment()
        await getDetailTaskById()
        // Ép theo context ngay sau khi load để tránh gọi nhầm API
        if (isContractCtx.value) {
            formData.value.linked_type = 'contract'
            formData.value.linked_id   = String(route.params.contractId)
        } else if (isBiddingCtx.value) {
            formData.value.linked_type = 'bidding'
            formData.value.linked_id   = String(route.params.bidId)
        }
        await getUser()
        await getListBidding()
        await getListContract()
        await fetchTaskFiles()
        await fetchLogHistory()
        handleChangeLinkedId()
    } catch (e) {
        console.error('❌ Lỗi khi khởi tạo:', e)
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

.approver-list {
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.approver-item {
    color: #999; /* mặc định mờ */
}
.approver-item.approved {
    font-weight: 600;
    color: #000; /* đậm hơn khi đã duyệt */
}

.approver-item {
    color: #999;
    margin-bottom: 4px;
}
.approver-item.approved .name {
    font-weight: 600;
    color: #000;
}
.approver-item.rejected .name {
    font-weight: 600;
    color: #c00;
}

</style>