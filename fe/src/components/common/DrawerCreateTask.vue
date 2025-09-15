<template>
    <div class="draw-create-task">
        <a-drawer
            title="Tạo nhiệm vụ mới"
            :width="700"
            :open="props.openDrawer"
            :body-style="{ paddingBottom: '80px' }"
            :footer-style="{ textAlign: 'right' }"
            @close="onCloseDrawer"
        >
            <a-alert
                v-if="props.createAsRoot"
                type="info"
                message="Đang tạo nhiệm vụ gốc"
                show-icon
                style="margin-bottom:12px"
            />
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Tên nhiệm vụ" name="title">
                            <a-input v-model:value="formData.title" placeholder="Nhập tên nhiệm vụ" />
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
                                    @change="changeDateTime"
                                    style="width: 100%;"
                                    :getPopupContainer="triggerNode => triggerNode.parentNode"
                                />
                            </a-config-provider>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Độ ưu tiên" name="priority">
                            <a-select
                                v-model:value="formData.priority"
                                :options="priorityOption"
                                placeholder="Chọn độ ưu tiên"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Trạng thái" name="status">
                            <a-select v-model:value="formData.status" :options="statusOption" placeholder="Chọn trạng thái" />
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
                                :filter-option="(input, option) => normalizeText(option?.label ?? '').includes(normalizeText(input))"
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
                                <a-input :value="getLinkedTypeLabel(props.type)" disabled />
                            </template>
                        </a-form-item>
                    </a-col>

                    <a-col :span="12">
                        <a-form-item label="Phòng ban" name="department_id">
                            <a-select
                                v-model:value="formData.id_department"
                                :options="departmentOptions"
                                @change="handleChangeDepartment"
                                placeholder="Chọn phòng ban"
                            />
                        </a-form-item>
                    </a-col>

                    <!-- BIDDING -->
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
                                :disabled="disableStepSelect"
                                :loading="loadingStepsOptions"
                                placeholder="Chọn bước gói thầu"
                            />
                        </a-form-item>
                    </a-col>

                    <!-- CONTRACT -->
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
                                <a-radio :value="1">1 cấp duyệt</a-radio>
                                <a-radio :value="2">2 cấp duyệt</a-radio>
                            </a-radio-group>
                        </a-form-item>
                    </a-col>

                    <a-col :span="24">
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" :rows="4" placeholder="Nhập mô tả " />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>

            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" @click="submitForm" html-type="submit" :loading="loadingCreate">
                        Lưu lại
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useUserStore } from '@/stores/user.js'
import { createTask, getTasksByBiddingStep, getTasksByContractStep } from '@/api/task.js'
import { getBiddingAPI, getBiddingsAPI } from '@/api/bidding.js'
import { getContractAPI, getContractsAPI } from '@/api/contract.js'
import { message } from 'ant-design-vue'
import { getContractStepsAPI } from '@/api/contract-steps'
import { getBiddingStepsAPI } from '@/api/bidding'
import { getDepartments } from '@/api/department'
import { useStepStore } from '@/stores/step'
import { useCommonStore } from '@/stores/common'

import dayjs from 'dayjs'
dayjs.locale('vi')
import viVN from 'ant-design-vue/es/locale/vi_VN'
import { defineProps } from '@vue/runtime-core'

const stepStore = useStepStore()
const commonStore = useCommonStore()
const parentTaskId = computed(() => commonStore.parentTaskId) // ✅ NEW
const emit = defineEmits(['update:openDrawer', 'submitForm'])
const store = useUserStore()
const selectedStep = computed(() => stepStore.selectedStep)

const props = defineProps({
    openDrawer: Boolean,
    taskParent: String,
    listUser: { type: Array, default: () => [] },
    type: { type: String, default: 'internal' },
    taskMeta: { type: Object, default: () => ({}) },
    createAsRoot: { type: Boolean, default: false },
})

const locale = ref(viVN)

const loadingCreate = ref(false)
const formRef = ref(null)
const loading = ref(false)
const listBidding = ref([])
const listContract = ref([])
const dateRange = ref()
const listDepartment = ref([])
const stepOption = ref([])

const formData = ref({
    title: '',
    created_by: '',
    step_code: null,
    linked_type: null,
    description: '',
    linked_id: null,
    assigned_to: null,
    proposed_by: null,
    start_date: '',
    end_date: '',
    status: null,
    priority: null,
    parent_id: null,
    approval_steps: 1,
    id_department: null,
    step_id: null
})

const effectiveParentId = computed(() =>
    props.createAsRoot
        ? null
        : (props.taskParent ?? (parentTaskId.value ? Number(parentTaskId.value) : null))
)

/* ---------------- Helpers / Validate ---------------- */
const setDefaultData = () => {
    formData.value = {
        title: '',
        created_by: null,
        step_code: null,
        linked_type: null,
        description: '',
        linked_id: null,
        assigned_to: null,
        start_date: '',
        end_date: '',
        status: null,
        priority: null,
        // ✅ NEW: ưu tiên props.taskParent -> Pinia.parentTaskId
        parent_id: props.taskParent ?? (parentTaskId.value ? Number(parentTaskId.value) : null),
        id_department: null,
        approval_steps: null,
        proposed_by: null,
        step_id: null
    }
    dateRange.value = null
}


import { useRoute } from 'vue-router'
const currentRoute = useRoute()


// === Route params: /biddings/:bidId/steps/:stepId/tasks ===
const routeBidId  = computed(() => currentRoute.params.bidId  || currentRoute.params.bid_id  || null)
const routeStepId = computed(() => currentRoute.params.stepId || currentRoute.params.step_id || null)

// Khóa select bước khi pref-fill từ URL
const lockStepSelect = ref(false)
const disableStepSelect = computed(() => !formData.value.linked_id || lockStepSelect.value)

// Prefill bước từ URL /biddings/:bidId/steps/:stepId/tasks rồi khóa select
const prefillStepFromRouteIfEmpty = async () => {
    const bidId  = routeBidId.value
    const stepId = routeStepId.value

    // chỉ áp dụng với bidding và khi URL đầy đủ
    if (!bidId || !stepId) return

    // Nếu chưa set loại → set "bidding"
    if (!formData.value.linked_type) formData.value.linked_type = 'bidding'

    // Nếu chưa có linked_id → set từ route
    if (!formData.value.linked_id) formData.value.linked_id = String(bidId)

    // Nạp option bước cho gói thầu hiện tại rồi gán step theo stepId
    await loadStepOptions('bidding', formData.value.linked_id)

    // Tìm option có step_id khớp (options: { value: step_number, label, step_id })
    const picked = stepOption.value.find(o => String(o.step_id) === String(stepId))
    if (picked) {
        formData.value.step_code = picked.value   // step_number
        formData.value.step_id   = picked.step_id // step_id
        lockStepSelect.value     = true           // khóa không cho đổi nữa
    }
}

watch(
    () => ({
        open: props.openDrawer,
        type: formData.value.linked_type,
        id: formData.value.linked_id,
        selId: selectedStep.value?.id,
        pId: parentTaskId.value
    }),
    async ({ open }) => {
        if (!open) return

        // Ưu tiên step đang chọn trong store
        if (selectedStep.value) {
            setFormStepFromStore(selectedStep.value)
        } else {
            // Fallback từ commonStore
            formData.value.linked_type = props.type || commonStore.linkedType || formData.value.linked_type
            if (!formData.value.linked_id) {
                formData.value.linked_id = commonStore.biddingIdParent ? String(commonStore.biddingIdParent) : null
            }
            // Fallback *từ route* nếu vẫn thiếu và URL có /biddings/:bidId/steps/:stepId/tasks
            if (!formData.value.linked_type && routeBidId.value) {
                formData.value.linked_type = 'bidding'
            }
            if (!formData.value.linked_id && routeBidId.value) {
                formData.value.linked_id = String(routeBidId.value)
            }
        }

        // parent_id (props > Pinia)
        formData.value.parent_id = effectiveParentId.value

        if (formData.value.linked_id) formData.value.linked_id = String(formData.value.linked_id)

        await ensureLinkedIdInOptions()
        linkedName.value = await getNameLinked(formData.value.linked_id)
        await loadStepOptions(formData.value.linked_type, formData.value.linked_id)

        // ⬇️ Prefill từ URL nếu chưa có bước
        await prefillStepFromRouteIfEmpty()

        // Lưu vào store dùng chung
        commonStore.setLinkedType(formData.value.linked_type)
        commonStore.setLinkedIdParent(formData.value.linked_id)
    },
    { immediate: true }
)



const normalizeText = (s = '') =>
    s.toString().normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()

const validateTitle = async (_r, v) => {
    if (v === '') return Promise.reject('Vui lòng nhập họ và tên')
    if (v.length > 200) return Promise.reject('Họ và tên không vượt quá 200 ký tự')
    return Promise.resolve()
}
const validateTime = async () => {
    if (formData.value.start_date === '') return Promise.reject('Vui lòng nhập thời gian nhiệm vụ')
    return Promise.resolve()
}
const validatePriority = async () => (!formData.value.priority ? Promise.reject('Vui lòng chọn độ ưu tiên') : Promise.resolve())
const validateAsigned = async () => (!formData.value.assigned_to ? Promise.reject('Vui lòng chọn người phụ trách') : Promise.resolve())
const validateProposed = async () => (!formData.value.proposed_by ? Promise.reject('Vui lòng chọn người đề nghị') : Promise.resolve())
const validateLinkedType = async () => (!formData.value.linked_type ? Promise.reject('Vui lòng chọn loại nhiệm vụ') : Promise.resolve())
const validateDepartment = async () => (!formData.value.id_department ? Promise.reject('Vui lòng chọn phòng ban') : Promise.resolve())
const validateDescription = async (_r, v) => (v === '' ? Promise.reject('Vui lòng nhập mô tả nhiệm vụ') : Promise.resolve())
const validateApprovalSteps = async (_r, v) => {
    if (v === undefined || v === null || v === '') return Promise.reject('Vui lòng chọn cấp duyệt')
    if (![1, 2].includes(v)) return Promise.reject('Giá trị cấp duyệt không hợp lệ')
    return Promise.resolve()
}
const validateStep = async () => {
    if (['bidding', 'contract'].includes(formData.value.linked_type)) {
        if (!formData.value.step_code && !formData.value.step_id) {
            return Promise.reject('Vui lòng chọn bước')
        }
    }
    return Promise.resolve()
}

const rules = computed(() => ({
    title: [{ required: true, validator: validateTitle, trigger: 'change' }],
    time: [{ required: true, validator: validateTime, trigger: 'change' }],
    priority: [{ required: true, validator: validatePriority, trigger: 'change' }],
    assigned_to: [{ required: true, validator: validateAsigned, trigger: 'change' }],
    proposed_by: [{ required: true, validator: validateProposed, trigger: 'change' }],
    linked_type: [{ required: true, validator: validateLinkedType, trigger: 'change' }],
    description: [{ required: true, validator: validateDescription, trigger: 'change' }],
    department_id: [{ required: true, validator: validateDepartment, trigger: 'change' }],
    approval_steps: [{ required: true, message: 'Vui lòng chọn cấp duyệt' }],
    step_code: [{ validator: validateStep, trigger: 'change' }]
}))

const priorityOption = ref([
    { value: 'low', label: 'Thấp' },
    { value: 'normal', label: 'Thường' },
    { value: 'high', label: 'Cao' }
])
const statusOption = computed(() => [
    { value: 'doing', label: 'Đang chuẩn bị' },
    { value: 'pending_approval', label: 'Đã gửi duyệt', color: 'gold' },
    { value: 'done', label: 'Hoàn thành' },
    { value: 'overdue', label: 'Quá hạn' }
])
const linkedTypeOption = ref([
    { value: 'bidding', label: 'Gói thầu' },
    { value: 'contract', label: 'Hợp đồng' },
    { value: 'internal', label: 'Nhiệm vụ nội bộ' }
])
const departmentOptions = computed(() => listDepartment.value.map(ele => ({ value: ele.id, label: ele.name })))
const linkedIdOption = computed(() => {
    if (formData.value.linked_type === 'bidding') {
        return listBidding.value.map(ele => ({ value: String(ele.id), label: ele.title }))
    }
    if (formData.value.linked_type === 'contract') {
        const arr = Array.isArray(listContract.value)
            ? listContract.value
            : (Array.isArray(listContract.value?.data) ? listContract.value.data : [])
        return arr.map(ele => ({ value: String(ele.id), label: ele.title || ele.name || `Hợp đồng #${ele.id}` }))
    }
    return []
})
const userOption = computed(() => (props.listUser || []).map(u => ({ value: u.id, label: u.name })))

/* ---------------- API: master lists ---------------- */
const getDepartment = async () => {
    try {
        const response = await getDepartments()
        listDepartment.value = response.data
    } catch {
        message.error('Không thể tải phòng ban')
    }
}
const getBiddingTask = async () => {
    loading.value = true
    try {
        const response = await getBiddingsAPI()
        listBidding.value = response?.data?.data ? response.data.data : []
    } catch {
        message.error('Không thể tải gói thầu')
    } finally {
        loading.value = false
    }
}
const getContractTask = async () => {
    loading.value = true
    try {
        const response = await getContractsAPI({ page: 1, per_page: 1000 })
        const arr = Array.isArray(response.data?.data) ? response.data.data : []
        listContract.value = arr.map(r => ({ ...r, id: String(r.id), title: r.title ?? r.name ?? '' }))
    } catch {
        message.error('Không thể tải hợp đồng')
    } finally {
        loading.value = false
    }
}

/* ---------------- Step options loader (cache) ---------------- */
const stepsCache = new Map()
const stepsLoadToken = ref(0)
const loadingStepsOptions = ref(false)

const normalizeStepOptions = arr =>
    (Array.isArray(arr) ? arr : []).map(ele => ({ value: ele.step_number, label: ele.title, step_id: ele.id }))

const syncStepCodeWithOptions = () => {
    const found = stepOption.value.find(opt => opt.value === formData.value.step_code)
    if (!found) {
        formData.value.step_code = null
        formData.value.step_id = null
    }
}

const loadStepOptions = async (type, id) => {
    if (!['bidding', 'contract'].includes(type) || !id) {
        stepOption.value = []
        syncStepCodeWithOptions()
        return
    }
    const key = `${type}:${id}`
    if (stepsCache.has(key)) {
        stepOption.value = stepsCache.get(key)
        syncStepCodeWithOptions()
        return
    }
    const token = ++stepsLoadToken.value
    loadingStepsOptions.value = true
    try {
        const res = type === 'bidding' ? await getBiddingStepsAPI(id) : await getContractStepsAPI(id)
        if (token !== stepsLoadToken.value) return
        const opts = normalizeStepOptions(res.data)
        stepsCache.set(key, opts)
        stepOption.value = opts
        syncStepCodeWithOptions()
    } finally {
        if (token === stepsLoadToken.value) loadingStepsOptions.value = false
    }
}

/* ---------------- Linked name (hiển thị) ---------------- */
const linkedName = ref('Trống')
const getNameLinked = async id => {
    if (!id) return 'Trống'
    if (formData.value.linked_type === 'bidding') {
        const found = listBidding.value.find(x => String(x.id) === String(id))
        if (found) return found.title
        const res = await getBiddingAPI(id)
        return res.data?.title ?? 'Gói thầu không tồn tại'
    }
    if (formData.value.linked_type === 'contract') {
        const arr = Array.isArray(listContract.value) ? listContract.value : (Array.isArray(listContract.value?.data) ? listContract.value.data : [])
        const found = arr.find(x => String(x.id) === String(id))
        if (found) return found.title
        const res = await getContractAPI(id)
        return res.data?.title ?? res.data?.name ?? 'Hợp đồng không tồn tại'
    }
    return 'Trống'
}

/* ---------------- Ensure selected linked exists ---------------- */
const ensureLinkedIdInOptions = async () => {
    if (formData.value.linked_type !== 'bidding' || !formData.value.linked_id) return
    const exists = listBidding.value.some(item => String(item.id) === String(formData.value.linked_id))
    if (!exists) {
        try {
            const res = await getBiddingAPI(formData.value.linked_id)
            if (res?.data) listBidding.value.push(res.data)
        } catch (err) {
            console.error('Không thể lấy thông tin gói thầu:', err)
        }
    }
}

/* ---------------- UI Handlers ---------------- */
const handleChangeLinkedType = () => {
    formData.value.linked_id = null
    formData.value.step_code = null
    formData.value.step_id = null
    stepOption.value = []
}
const handleChangeDepartment = () => {}
const handleChangeLinkedId = () => {
    formData.value.step_code = null
    formData.value.step_id = null
}

const changeDateTime = (day, date) => {
    if (day) {
        formData.value.start_date = convertDateFormat(date[0])
        formData.value.end_date = convertDateFormat(date[1])
    } else {
        formData.value.start_date = ''
        formData.value.end_date = ''
    }
}
const convertDateFormat = dateStr => {
    const [day, month, year] = dateStr.split('-')
    return `${year}-${month}-${day}`
}

/* ---------------- Create ---------------- */
const createDrawerInternal = async () => {
    if (loadingCreate.value) return
    const payload = { ...formData.value }

    // ✅ NEW: thiết lập parent_id từ props/Pinia nếu chưa có
    payload.parent_id = props.createAsRoot ? null : effectiveParentId.value
    // map step_code -> step_id nếu thiếu
    if (['bidding', 'contract'].includes(payload.linked_type)) {
        if (!payload.step_id && payload.step_code) {
            const found = stepOption.value.find(it => String(it.value) === String(payload.step_code))
            payload.step_id = found?.step_id ?? null
        }
        if (!payload.step_id && stepOption.value.length === 1) {
            payload.step_id = stepOption.value[0].step_id
            payload.step_code = stepOption.value[0].value
        }
        if (!payload.step_id) {
            message.error('Vui lòng chọn bước trước khi lưu')
            return
        }
    }

    // ép kiểu số
    ;['created_by', 'assigned_to', 'proposed_by', 'parent_id', 'id_department', 'approval_steps', 'step_id'].forEach(k => {
        payload[k] = payload[k] !== undefined && payload[k] !== null && payload[k] !== '' ? Number(payload[k]) : null
    })
    payload.created_by = store.currentUser?.id || null

    loadingCreate.value = true
    try {
        const res = await createTask(payload)
        message.success('Thêm mới nhiệm vụ thành công')
        await refreshStepTasks({ preferNewTaskStep: true })
        emit('submitForm', res.data)
        onCloseDrawer()
    } catch (err) {
        console.error('[createDrawerInternal] error:', err)
        message.error('Thêm mới nhiệm vụ không thành công')
    } finally {
        loadingCreate.value = false
    }
}

// refresh danh sách task của step tương ứng
async function refreshStepTasks ({ preferNewTaskStep = true } = {}) {
    const stepId = (preferNewTaskStep && formData.value.step_id) ? formData.value.step_id : (selectedStep.value?.id || null)
    if (!stepId) return

    const linkedType = (preferNewTaskStep && formData.value.linked_type)
        ? formData.value.linked_type
        : (selectedStep.value?.linked_type || formData.value.linked_type || 'bidding')

    const filter = {}
    const resTasks = linkedType === 'contract'
        ? await getTasksByContractStep(stepId, filter)
        : await getTasksByBiddingStep(stepId, filter)

    const tasks = Array.isArray(resTasks.data?.data) ? resTasks.data.data : (resTasks.data || [])
    stepStore.setRelatedTasks(tasks)
}

const submitForm = async () => {
    try {
        await formRef.value?.validate()
        await createDrawerInternal()
    } catch {}
}
const resetFormValidate = () => formRef.value?.resetFields()
const onCloseDrawer = () => {
    emit('update:openDrawer', false)
    setDefaultData()
    resetFormValidate()
}
const getLinkedTypeLabel = val => ({ bidding: 'Gói thầu', contract: 'Hợp đồng', internal: 'Nhiệm vụ nội bộ' }[val] || val)

/* ---------------- Sync từ StepStore vào form ---------------- */
const setFormStepFromStore = step => {
    const type = props.type || 'bidding'
    formData.value.linked_type = type
    if (type === 'bidding') formData.value.linked_id = step?.bidding_id || null
    else if (type === 'contract') formData.value.linked_id = step?.contract_id || null
    else formData.value.linked_id = null

    formData.value.step_code = step?.step_number || null
    formData.value.step_id = step?.id || null
}

/* ---------------- Watch tổng hợp ---------------- */
watch(
    () => ({
        open: props.openDrawer,
        type: formData.value.linked_type,
        id: formData.value.linked_id,
        selId: selectedStep.value?.id,
        pId: parentTaskId.value // ✅ theo dõi thay đổi parent trong store
    }),
    async ({ open }) => {
        if (!open) return

        // Ưu tiên fill từ step đang chọn
        if (selectedStep.value) {
            setFormStepFromStore(selectedStep.value)
        } else {
            // fallback từ commonStore
            formData.value.linked_type = props.type || commonStore.linkedType || formData.value.linked_type
            if (!formData.value.linked_id) {
                formData.value.linked_id = commonStore.biddingIdParent ? String(commonStore.biddingIdParent) : null
            }
        }

        // ✅ NEW: set parent_id (props > Pinia)
        formData.value.parent_id = props.taskParent ?? (parentTaskId.value ? Number(parentTaskId.value) : formData.value.parent_id)

        // chuẩn hóa type/id
        if (formData.value.linked_id) formData.value.linked_id = String(formData.value.linked_id)

        await ensureLinkedIdInOptions()
        linkedName.value = await getNameLinked(formData.value.linked_id)
        await loadStepOptions(formData.value.linked_type, formData.value.linked_id)

        // lưu vào store dùng chung
        commonStore.setLinkedType(formData.value.linked_type)
        commonStore.setLinkedIdParent(formData.value.linked_id)
    },
    { immediate: true }
)

// map step_code -> step_id
watch(() => formData.value.step_code, (code) => {
    const f = stepOption.value.find(o => o.value === code)
    formData.value.step_id = f ? f.step_id : null
})

/* ---------------- Mounted ---------------- */
onMounted(async () => {
    formData.value.linked_type = props.type || commonStore.linkedType || formData.value.linked_type
    // ✅ set parent mặc định cả khi mới mount
    if (!formData.value.parent_id) {
        formData.value.parent_id = props.taskParent ?? (parentTaskId.value ? Number(parentTaskId.value) : null)
    }
    await Promise.all([getBiddingTask(), getContractTask(), getDepartment()])
})
</script>

<style scoped>
/* tuỳ bạn thêm style nếu cần */
</style>
