<template>
    <div class="drawer-create-subtask">
        <a-drawer
            :open="open"
            title="Thêm việc con"
            :width="800"
            :body-style="{ paddingBottom: '80px' }"
            :footer-style="{ textAlign: 'right' }"
            @close="onClose"
        >
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Tên nhiệm vụ" name="title">
                            <a-input v-model:value="formData.title" placeholder="Nhập tên subtask" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Người đề nghị" name="proposed_by">
                            <a-select
                                v-model:value="formData.proposed_by"
                                :options="userOptions"
                                placeholder="Chọn người dùng"
                                show-search
                                option-filter-prop="label"
                                :filter-option="(input, option) => normalizeText(option?.label ?? '').includes(normalizeText(input))"
                                :getPopupContainer="trigger => trigger.parentNode"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Thời gian" name="time">
                            <a-config-provider :locale="locale">
                                <a-range-picker
                                    v-model:value="dateRange"
                                    format="DD-MM-YYYY"
                                    @change="onChangeDate"
                                    style="width: 100%;"
                                    :getPopupContainer="t => t.parentNode"
                                />
                            </a-config-provider>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Độ ưu tiên" name="priority">
                            <a-select v-model:value="formData.priority" :options="priorityOptions" placeholder="Chọn" />
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Trạng thái" name="status">
                            <a-select v-model:value="formData.status" :options="statusOptions" placeholder="Chọn" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Người thực hiện" name="assigned_to">
                            <a-select
                                v-model:value="formData.assigned_to"
                                :options="userOptions"
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
                        <a-form-item label="Phòng ban" name="id_department">
                            <a-select
                                v-model:value="formData.id_department"
                                :options="departmentOptions"
                                placeholder="Chọn phòng ban"
                            />
                        </a-form-item>
                    </a-col>

                    <!-- Khóa nguồn gốc theo task cha -->
                    <a-col :span="12">
                        <a-form-item label="Nguồn gốc">
                            <a-space direction="vertical" size="small">
                                <a-tag color="blue">{{ getLinkedTypeLabel(parentTask?.linked_type) }}</a-tag>
                                <a-typography-text type="secondary">
                                    {{ linkedName }}
                                </a-typography-text>
                                <a-typography-text type="secondary">
                                    Bước: {{ parentTask?.step_code ?? '—' }}
                                </a-typography-text>
                            </a-space>
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row>
                    <a-col :span="24">
                        <a-form-item
                            label="Cấp duyệt"
                            name="approval_steps"
                            :rules="[{ validator: validateApprovalSteps, trigger: 'change' }]"
                        >
                            <a-radio-group v-model:value="formData.approval_steps">
                                <a-radio :value="1">1 cấp duyệt</a-radio>
                                <a-radio :value="2">2 cấp duyệt</a-radio>
                            </a-radio-group>
                        </a-form-item>
                    </a-col>

                    <a-col :span="24">
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" :rows="4" placeholder="Nhập mô tả" />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>

            <!-- Footer -->
            <template #extra>
                <a-space>
                    <a-button @click="onClose">Hủy</a-button>
                    <a-button :loading="loading" @click="onSubmit">Lưu nháp</a-button>
                    <a-button type="primary" :loading="loading" @click="openSendApprovalFromForm">
                        Lưu & gửi duyệt
                    </a-button>
                </a-space>
            </template>
        </a-drawer>

        <!-- Modal chọn người duyệt -->
        <a-modal
            v-model:open="sendApprovalVisible"
            title="Chọn người duyệt (≥ 1 cấp)"
            :confirm-loading="loading"
            @ok="confirmSendThenCreate"
        >
            <a-form layout="vertical">
                <a-form-item label="Người duyệt (theo thứ tự cấp 1 → cấp 2)">
                    <a-select
                        v-model:value="approverIdsSelected"
                        mode="multiple"
                        :options="userOptions"
                        placeholder="Chọn ít nhất 1 người duyệt"
                        :max-tag-count="3"
                    />
                </a-form-item>
                <a-alert type="info" show-icon>
                    Thứ tự người duyệt sẽ theo thứ tự bạn chọn trong danh sách.
                </a-alert>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import dayjs from 'dayjs'
import viVN from 'ant-design-vue/es/locale/vi_VN'
import { message } from 'ant-design-vue'
import { createTask } from '@/api/task'
import { getBiddingAPI } from '@/api/bidding'
import { getContractAPI } from '@/api/contract'
import { getDepartments } from '@/api/department'
import { useUserStore } from '@/stores/user'
// Nếu BE có API riêng để gửi duyệt sau khi tạo, bật import này và dùng ở confirmSendThenCreate
// import { sendTaskForApprovalAPI } from '@/api/task-approval'

const props = defineProps({
    open: Boolean,
    parentTask: { type: Object, default: () => ({}) }, // cần: id, linked_type, linked_id, step_id/step_code, id_department
    listUser: { type: Array, default: () => [] },      // danh sách user để chọn
    // Nếu BE có trường đánh dấu “cấp cuối cùng”, truyền tên field tại đây (tùy chọn)
    terminalFlagField: { type: String, default: '' }
})
const emit = defineEmits(['update:open', 'created'])

const store = useUserStore()
const locale = ref(viVN)

const formRef = ref(null)
const loading = ref(false)
const dateRange = ref(null)
const listDepartment = ref([])
const linkedName = ref('')

const formData = ref({
    title: '',
    description: '',
    assigned_to: null,
    proposed_by: null,
    start_date: '',
    end_date: '',
    status: 'doing',
    priority: 'normal',
    id_department: null,
    approval_steps: 1,

    // Khóa theo task cha
    parent_id: null,
    linked_type: null,
    linked_id: null,
    step_id: null,
    step_code: null
})

const userOptions = computed(() =>
    props.listUser.map(u => ({ value: u.id, label: u.name }))
)

const departmentOptions = computed(() =>
    listDepartment.value.map(d => ({ value: d.id, label: d.name }))
)

const priorityOptions = ref([
    { value: 'low', label: 'Thấp' },
    { value: 'normal', label: 'Thường' },
    { value: 'high', label: 'Cao' }
])

const statusOptions = ref([
    { value: 'doing', label: 'Đang chuẩn bị' },
    { value: 'pending_approval', label: 'Đã gửi duyệt' },
    { value: 'done', label: 'Hoàn thành' },
    { value: 'overdue', label: 'Quá hạn' }
])

const normalizeText = (s = '') => s.toString().normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()

const rules = computed(() => ({
    title: [{ required: true, message: 'Vui lòng nhập tên', trigger: 'blur' }],
    time: [{ validator: validateTime, trigger: 'change' }],
    priority: [{ required: true, message: 'Vui lòng chọn ưu tiên', trigger: 'change' }],
    assigned_to: [{ required: true, message: 'Vui lòng chọn người thực hiện', trigger: 'change' }],
    proposed_by: [{ required: true, message: 'Vui lòng chọn người đề nghị', trigger: 'change' }],
    id_department: [{ required: true, message: 'Vui lòng chọn phòng ban', trigger: 'change' }],
    approval_steps: [{ validator: validateApprovalSteps, trigger: 'change' }]
}))

function validateTime() {
    if (!formData.value.start_date || !formData.value.end_date) {
        return Promise.reject('Vui lòng chọn thời gian')
    }
    return Promise.resolve()
}

function validateApprovalSteps(_r, v) {
    if (![1, 2].includes(Number(v))) return Promise.reject('Giá trị cấp duyệt không hợp lệ')
    return Promise.resolve()
}

function getLinkedTypeLabel(t) {
    return ({ bidding: 'Gói thầu', contract: 'Hợp đồng', internal: 'Nhiệm vụ nội bộ' }[t] || t || '—')
}

function convertDateFormat(d) {
    const [dd, mm, yyyy] = d.split('-')
    return `${yyyy}-${mm}-${dd}`
}

function onChangeDate(dayjsArr, strArr) {
    if (dayjsArr) {
        formData.value.start_date = convertDateFormat(strArr[0])
        formData.value.end_date   = convertDateFormat(strArr[1])
    } else {
        formData.value.start_date = ''
        formData.value.end_date   = ''
    }
}

async function fetchDepartments() {
    try {
        const res = await getDepartments()
        listDepartment.value = res.data || []
    } catch {
        message.error('Không thể tải phòng ban')
    }
}

async function resolveLinkedName() {
    const t = props.parentTask?.linked_type
    const id = props.parentTask?.linked_id
    if (!t || !id) { linkedName.value = '—'; return }
    try {
        if (t === 'bidding') {
            const r = await getBiddingAPI(id)
            linkedName.value = r?.data?.title ?? `Gói thầu #${id}`
        } else if (t === 'contract') {
            const r = await getContractAPI(id)
            linkedName.value = r?.data?.title ?? r?.data?.name ?? `Hợp đồng #${id}`
        } else {
            linkedName.value = 'Nội bộ'
        }
    } catch {
        linkedName.value = '—'
    }
}

function hydrateFromParent() {
    const p = props.parentTask || {}
    formData.value.parent_id     = p.id ?? null
    formData.value.linked_type   = p.linked_type ?? null
    formData.value.linked_id     = p.linked_id ?? null
    formData.value.step_id       = p.step_id ?? null
    formData.value.step_code     = p.step_code ?? null
    formData.value.id_department = p.id_department ?? null
}

function resetForm() {
    formRef.value?.resetFields?.()
    dateRange.value = null
    formData.value = {
        title: '',
        description: '',
        assigned_to: null,
        proposed_by: null,
        start_date: '',
        end_date: '',
        status: 'doing',
        priority: 'normal',
        id_department: props.parentTask?.id_department ?? null,
        approval_steps: 1,
        parent_id: props.parentTask?.id ?? null,
        linked_type: props.parentTask?.linked_type ?? null,
        linked_id: props.parentTask?.linked_id ?? null,
        step_id: props.parentTask?.step_id ?? null,
        step_code: props.parentTask?.step_code ?? null
    }
}

function onClose() {
    emit('update:open', false)
    resetForm()
}

/* ================== APPROVAL FLOW ================== */
const sendApprovalVisible  = ref(false)
const approverIdsSelected  = ref([])

// Build payload chung
function buildCreatePayload() {
    const payload = { ...formData.value }
    ;['assigned_to','proposed_by','id_department','approval_steps','parent_id','step_id'].forEach(k => {
        payload[k] = payload[k] != null && payload[k] !== '' ? Number(payload[k]) : null
    })
    payload.created_by = store.currentUser?.id ?? null
    if (props.terminalFlagField) payload[props.terminalFlagField] = 1
    return payload
}

// Lưu nháp
async function onSubmit() {
    try {
        await formRef.value?.validate()
        loading.value = true
        const payload = buildCreatePayload()
        // giữ status theo form (mặc định 'doing')
        const res = await createTask(payload)
        message.success('Đã tạo việc con')
        emit('created', res.data)
        onClose()
    } catch (e) {
        if (e?.errorFields) return
        console.error('Create subtask error:', e)
        message.error('Tạo việc con thất bại')
    } finally {
        loading.value = false
    }
}

// Mở modal chọn người duyệt
const openSendApprovalFromForm = async () => {
    try {
        await formRef.value?.validate()
        // gợi ý: người thực hiện đứng đầu
        approverIdsSelected.value = approverIdsSelected.value?.length
            ? approverIdsSelected.value.slice()
            : (formData.value.assigned_to ? [Number(formData.value.assigned_to)] : [])
        sendApprovalVisible.value = true
    } catch {
        // lỗi validate đã hiển thị
    }
}

// Xác nhận: tạo task + gửi duyệt
async function confirmSendThenCreate() {
    if (!Array.isArray(approverIdsSelected.value) || approverIdsSelected.value.length === 0) {
        message.warning('Cần chọn tối thiểu 1 người duyệt.')
        return
    }
    const uniqueIds = [...new Set(
        approverIdsSelected.value.map(n => Number(n)).filter(Number.isInteger)
    )]
    if (!uniqueIds.length) {
        message.warning('Danh sách người duyệt không hợp lệ.')
        return
    }

    try {
        loading.value = true
        const payload = buildCreatePayload()
        // chuyển sang trạng thái gửi duyệt
        payload.status = 'pending_approval'

        // Cách 1: BE nhận approver_ids ngay khi tạo
        payload.approver_ids = uniqueIds

        const res = await createTask(payload)

        // Cách 2: Nếu BE yêu cầu gọi riêng sau create, dùng API riêng:
        // await sendTaskForApprovalAPI(res.data.id, uniqueIds)

        message.success('Đã tạo & gửi phê duyệt')
        sendApprovalVisible.value = false
        approverIdsSelected.value = []
        emit('created', res.data)
        onClose()
    } catch (e) {
        console.error(e)
        message.error(e?.response?.data?.message || 'Gửi phê duyệt thất bại.')
    } finally {
        loading.value = false
    }
}
/* ================== /APPROVAL FLOW ================== */

watch(() => props.open, (v) => { if (v) { hydrateFromParent(); resolveLinkedName() } })
onMounted(async () => { await fetchDepartments(); if (props.open) { hydrateFromParent(); resolveLinkedName() } })
</script>

<style scoped>
</style>
