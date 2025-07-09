<template>
    <div>
        <a-page-header
            title="Chi tiết hợp đồng"
            sub-title="Xem thông tin và tiến trình xử lý"
            @back="goBack"
            style="padding: 0 0 20px;"
        />
        <a-descriptions bordered :column="2" size="middle">
            <!-- Nhóm 1: Cơ bản -->
            <a-descriptions-item label="Tên hợp đồng">
                <strong>{{ contract?.title }}</strong>
            </a-descriptions-item>
            <a-descriptions-item label="Trạng thái">
                <a-tag :color="getStatusColor(contract?.status)">
                    {{ getStatusText(contract?.status) }}
                </a-tag>
            </a-descriptions-item>

            <!-- Nhóm 2: Gói thầu + Chi phí -->
            <a-descriptions-item label="Gói thầu">
                <a @click="goToBiddingDetail(contract?.bidding_id)" style="color: #1890ff; cursor: pointer;">
                    {{ getBiddingTitle(contract?.bidding_id) }}
                </a>
            </a-descriptions-item>
            <a-descriptions-item label="Chi phí dự tính">
                {{ getBiddingCost(contract?.bidding_id) }}
            </a-descriptions-item>

            <!-- Nhóm 3: Thời gian -->
            <a-descriptions-item label="Ngày bắt đầu">
                {{ formatDate(contract?.start_date) }}
            </a-descriptions-item>
            <a-descriptions-item label="Ngày kết thúc">
                {{ formatDate(contract?.end_date) }}
            </a-descriptions-item>

            <!-- Nhóm 4: Người liên quan -->
            <a-descriptions-item label="Người phụ trách">
                <a @click="goToUserDetail(contract?.assigned_to)" style="color: #1890ff; cursor: pointer;">
                    {{ getAssignedUserName(contract?.assigned_to) }}
                </a>
            </a-descriptions-item>
            <a-descriptions-item label="Khách hàng">
                <a @click="goToCustomerDetail(contract?.id_customer)" style="color: #1890ff; cursor: pointer;">
                    {{ getCustomerName(contract?.id_customer) }}
                </a>
            </a-descriptions-item>

            <!-- Nhóm 5: Mô tả -->
            <a-descriptions-item label="Mô tả" :span="2">
                <div style="white-space: pre-line;">{{ contract?.description || 'Không có mô tả' }}</div>
            </a-descriptions-item>
        </a-descriptions>

        <a-typography-title :level="5" class="mt-30 mb-30">Tiến trình xử lý</a-typography-title>

        <a-spin :spinning="loadingSteps">
            <a-steps direction="vertical" :current="currentStepIndex()">
                <a-step
                    v-for="(step, index) in steps"
                    :key="step.id"
                    :title="`Bước ${step.step_number ?? '-'}: ${step.title ?? '-'}`"
                    :status="mapStepStatus(step.status)"
                    @click="openStepDrawer(step)"
                >
                    <template #description>
                        <div style="background: #fafafa; padding: 12px; border: 1px solid #f0f0f0; border-radius: 6px;">
                            <p>Phòng ban:
                                <a-tag
                                    v-for="(dep, i) in parseDepartment(step.department)"
                                    :key="i"
                                    color="blue"
                                    style="margin-right: 5px;"
                                >
                                    {{ dep }}
                                </a-tag>
                            </p>
                            <p>
                                Trạng thái:
                                <a-tag :color="getStepStatusColor(step.status)">
                                    {{ statusText(step.status) }}
                                </a-tag>
                            </p>
                            <p>
                                Người phụ trách:
                                <a v-if="step.assigned_to" @click.stop="goToUserDetail(step.assigned_to)">
                                    {{ getAssignedUserName(step.assigned_to) }}
                                </a>
                                <span v-else>Không xác định</span>
                            </p>
                        </div>
                    </template>
                </a-step>
            </a-steps>
        </a-spin>

        <a-drawer
            title="Chi tiết bước xử lý"
            placement="right"
            :visible="drawerVisible"
            @close="drawerVisible = false"
            width="580"
        >
            <template v-if="selectedStep">
                <a-descriptions bordered size="small" :column="1" title="Thông tin bước">
                    <a-descriptions-item label="Bước số">{{ selectedStep.step_number }}</a-descriptions-item>
                    <a-descriptions-item label="Tiêu đề">{{ selectedStep.title }}</a-descriptions-item>
                    <a-descriptions-item label="Phòng ban">
                        <template #default>
                            <a-tag
                                v-for="(dep, index) in parseDepartment(selectedStep.department)"
                                :key="index"
                                color="blue"
                                style="margin-right: 4px;"
                            >
                                {{ dep }}
                            </a-tag>
                        </template>
                    </a-descriptions-item>
                    <a-descriptions-item label="Trạng thái">
                        <a-select
                            v-model:value="selectedStep.status"
                            style="width: 100%"
                            @change="(value) => updateStepStatus(value, selectedStep)"
                        >
                            <a-select-option value="0">Chưa bắt đầu</a-select-option>
                            <a-select-option value="1">Đang xử lý</a-select-option>
                            <a-select-option value="2">Hoàn thành</a-select-option>
                            <a-select-option value="3">Bỏ qua</a-select-option>
                        </a-select>
                    </a-descriptions-item>
                    <a-descriptions-item label="Người phụ trách">
                        <a-select
                            v-model:value="selectedStep.assigned_to"
                            style="width: 100%"
                            placeholder="Chọn người phụ trách"
                            @change="(value) => updateStepAssignedTo(value, selectedStep)"
                            :allowClear="true"
                        >
                            <a-select-option
                                v-for="user in users"
                                :key="user.id"
                                :value="user.id"
                            >
                                {{ user.name }}
                            </a-select-option>
                        </a-select>
                    </a-descriptions-item>
                    <a-descriptions-item label="Ngày bắt đầu /kết thúc">
                        <a-typography-text type="secondary" v-if="!showEditDate" @click="editDate">
                            {{ formatDate(selectedStep.created_at) }} - {{ formatDate(selectedStep.updated_at) }}
                        </a-typography-text>
                        <a-range-picker
                            v-model:value="dateRange"
                            v-if="showEditDate"
                            style="width: 100%"
                            :allowClear="false"
                            @change="updateStepStartEndDate"
                        />
                    </a-descriptions-item>
                </a-descriptions>

                <a-divider>Danh sách công việc thuộc bước này</a-divider>

                <a-empty v-if="relatedTasks.length === 0" description="Không có công việc" />

                <a-list
                    v-else
                    :dataSource="relatedTasks"
                    :rowKey="task => task.id"
                >
                    <template #renderItem="{ item }">
                        <a-list-item>
                            <a-list-item-meta>
                                <template #title>
                                    <router-link :to="`/internal-tasks/${item.id}/info`">
                                        {{ item.title }}
                                    </router-link>
                                </template>
                                <template #description>
                                    {{ item.description }} | Phụ trách: {{ getAssignedUserName(item.assigned_to) }}
                                </template>
                            </a-list-item-meta>

                            <template #actions>
                                <a-tag :color="getTaskStatusColor(item.status)">
                                    {{ getTaskStatusText(item.status) }}
                                </a-tag>
                            </template>
                        </a-list-item>
                    </template>
                </a-list>



            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import {onMounted, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {message} from 'ant-design-vue'
import {formatCurrency, formatDate} from '@/utils/formUtils'
import dayjs from 'dayjs'
import {getContractAPI} from '@/api/contract'
import { getBiddingsAPI } from '@/api/bidding'

import {
    cloneContractStepsFromTemplateAPI,
    completeContractStepAPI,
    getContractStepsAPI,
    updateContractStepAPI
} from '@/api/contract-steps'
import {getTaskDetail, getTasks, getTasksByBiddingStep, getTasksByContractStep} from '@/api/task' // giả sử bạn có API như vậy

import {getCustomers} from '@/api/customer'
import {getUsers} from '@/api/user.js'
const biddings = ref([])

const router = useRouter()
const route = useRoute()
const id = route.params.id
const isNewContract = ref(route.query.new === '1') // 👈 xác định hợp đồng mới
const users = ref([])

const contract = ref({})
const steps = ref([])
const loadingSteps = ref(false)

const drawerVisible = ref(false)
const selectedStep = ref(null)
const customers = ref([])
const customerName = ref('Đang tải...')
const allTasks = ref([])
const relatedTasks = ref([])

const showEditDate = ref(false)
const dateRange = ref([])

const editDate = () => {
    showEditDate.value = true
    dateRange.value = [dayjs(selectedStep.value.start_date), dayjs(selectedStep.value.end_date)]
}
const updateStepStartEndDate = (value, option) => {
    if(value.length === 2) {
        selectedStep.value.start_date = value[0].format('YYYY-MM-DD')
        selectedStep.value.end_date = value[1].format('YYYY-MM-DD')
    }else{
        // dateRange.value = []
    }
    showEditDate.value = false
}
const fetchBiddings = async () => {
    try {
        const res = await getBiddingsAPI()
        biddings.value = res.data?.data || []
    } catch (e) {
        console.error('Không thể tải danh sách gói thầu', e)
    }
}

const getBiddingTitle = (id) => {
    const found = biddings.value.find(b => String(b.id) === String(id))
    return found?.title || `Gói thầu #${id}`
}

const openStepDrawer = async (step) => {
    selectedStep.value = { ...step }
    drawerVisible.value = true

    try {
        const res = await getTasksByContractStep(step.id)
        console.log('res', step.id)
        relatedTasks.value = res.data || []
    } catch (e) {
        console.error('Không thể tải công việc của bước', e)
        message.error('Không thể tải danh sách công việc')
        relatedTasks.value = []
    }
}

const getTaskStatusText = (status) => ({
    todo: 'Chưa bắt đầu',
    doing: 'Đang làm',
    done: 'Hoàn thành',
    overdue: 'Trễ hạn',
}[status] || 'Không rõ')

const getTaskStatusColor = (status) => ({
    todo: 'default',
    doing: 'blue',
    done: 'green',
    overdue: 'red',
}[status] || 'default')

const getStatusColor = (status) => {
    const map = {
        0: 'gray',
        1: 'blue',
        2: 'orange',
        3: 'cyan',
        4: 'green',
        5: 'red',
    }
    return map[status] || 'default'
}

const getStatusText = (status) => {
    const map = {
        0: 'Nháp',
        1: 'Đang thực hiện',
        2: 'Chờ duyệt',
        3: 'Đã duyệt',
        4: 'Hoàn thành',
        5: 'Đã hủy',
    }
    return map[status] || 'Không xác định'
}

const statusText = (status) => ({
    '0': 'Chưa bắt đầu',
    '1': 'Đang xử lý',
    '2': 'Đã hoàn thành',
    '3': 'Bỏ qua',
}[status] || 'Không rõ')

const mapStepStatus = (status) => ({
    '0': 'wait',
    '1': 'process',
    '2': 'finish',
    '3': 'error',
}[status] || 'wait')

const getStepStatusColor = (status) => ({
    '0': 'default',
    '1': 'blue',
    '2': 'green',
    '3': 'orange',
}[status] || 'default')

const lastCompletedIndex = () => {
    for (let i = steps.value.length - 1; i >= 0; i--) {
        if (steps.value[i].status === '2') return i
    }
    return -1
}

const currentStepIndex = () => {
    const last = lastCompletedIndex()
    const next = last + 1
    return next >= steps.value.length ? steps.value.length - 1 : next
}

const updateStepStatus = async (newStatus, step) => {
    try {
        if (newStatus === '2') {
            await completeContractStepAPI(step.id)
            message.success('Đã hoàn thành và mở bước kế tiếp')
        } else {
            await updateContractStepAPI(step.id, { status: newStatus })
            message.success('Đã cập nhật trạng thái bước')
        }
        drawerVisible.value = false
        await fetchSteps()
    } catch (e) {
        const msg = e?.response?.data?.messages?.error || 'Đã xảy ra lỗi'
        if (e?.response?.status === 400) {
            message.warning(msg) // ⚠️ Cảnh báo nhẹ nhàng
        } else {
            message.error(msg) // ❌ Lỗi khác thì vẫn báo lỗi đỏ
        }
        console.warn('Lỗi cập nhật bước:', msg)
    }
}

const updateStepAssignedTo = async (newUserId, step) => {
    try {
        await updateContractStepAPI(step.id, { assigned_to: newUserId })
        message.success('Cập nhật người phụ trách thành công')
        drawerVisible.value = false
        await fetchSteps()
    } catch (e) {
        const msg = e?.response?.data?.messages?.error || 'Không thể cập nhật người phụ trách'
        message.error(msg)
        console.warn('Lỗi cập nhật người phụ trách:', msg)
    }
}


const fetchCustomers = async () => {
    try {
        const res = await getCustomers()
        customers.value = res.data?.data || []
    } catch (e) {
        console.error(e)
        message.error('Không thể tải danh sách khách hàng')
    }
}

const getCustomerName = (id) => {
    if (!id || !customers.value.length) return 'Đang tải...'
    const customer = customers.value.find(c => String(c.id) === String(id))
    return customer ? customer.name : `Khách hàng #${id}`
}

const getCustomerNameById = async (id) => {
    try {
        const res = await getCustomers({ id })
        const matched = res.data?.data?.find(c => c.id === id)
        customerName.value = matched?.name || `Khách hàng #${id}`
    } catch {
        customerName.value = 'Không thể tải khách hàng'
    }
}

const fetchSteps = async () => {
    loadingSteps.value = true
    try {
        if (isNewContract.value && steps.value.length === 0) {
            await cloneContractStepsFromTemplateAPI(id)
        }

        const stepRes = await getContractStepsAPI(id)
        steps.value = Array.isArray(stepRes.data) ? stepRes.data : []

        // Nếu sau khi fetch đã có steps thì không clone lại nữa
        isNewContract.value = false
    } catch (e) {
        console.error(e)
        message.error('Không thể tải bước xử lý')
    } finally {
        loadingSteps.value = false
    }
}

const fetchData = async () => {
    try {
        // 1. Lấy thông tin hợp đồng
        const res = await getContractAPI(id)
        contract.value = res.data
        // 2. Lấy tên khách hàng nếu có
        if (contract.value.id_customer) {
            try {
                const customerRes = await getCustomers({ id: contract.value.id_customer })
                const matched = customerRes.data?.data?.find(c => String(c.id) === String(contract.value.id_customer))
                customerName.value = matched?.name || `Khách hàng #${contract.value.id_customer}`
            } catch (e) {
                console.warn('Không thể tải khách hàng', e)
                customerName.value = 'Không thể tải khách hàng'
            }
        } else {
            customerName.value = 'Không có khách hàng'
        }

        // 3. Lấy bước xử lý
        await fetchSteps()
    } catch (e) {
        console.error(e)
        message.error('Không thể tải hợp đồng')
    }
}

const goToCustomerDetail = (customerId) => {
    if (!customerId) return
    router.push(`/customers/${customerId}`)
}
const parseDepartment = (val) => {
    if (!val) return []
    try {
        const parsed = JSON.parse(val)
        return Array.isArray(parsed) ? parsed : []
    } catch {
        return []
    }
}

const getAssignedUserName = (userId) => {
    if (!userId || !users.value.length) return 'Không xác định'
    const found = users.value.find(u => String(u.id) === String(userId))
    return found?.name || `Người dùng #${userId}`
}

const fetchUsers = async () => {
    try {
        const res = await getUsers()
        users.value = Array.isArray(res.data) ? res.data : res.data?.data || []
    } catch (e) {
        console.error('Không thể tải danh sách người dùng', e)
    }
}

const getBiddingCost = (id) => {
    const bidding = biddings.value.find(b => String(b.id) === String(id))
    return bidding ? formatCurrency(bidding.estimated_cost) : 'Không có dữ liệu'
}


const fetchTasks = async () => {
    try {
        const res = await getTasks({ linked_type: 'contract' }) // ✅ đúng format
        allTasks.value = res.data?.data || []
    } catch (e) {
        console.error('Không thể tải danh sách task', e)
    }
}


const goToUserDetail = (userId) => {
    if (!userId) return
    router.push(`/users/${userId}`)
}

const goToBiddingDetail = (id) => {
    if (!id) return
    router.push(`/bid-detail/${id}`)
}

const goBack = () => {
    router.push('/contracts-tasks')
}

onMounted(() => {
    fetchData()
    fetchCustomers()
    fetchUsers()
    fetchBiddings()
    fetchTasks() // 👈 Thêm dòng này
})
</script>

<style scoped>
.step-actions {
    margin-top: 12px;
    text-align: right;
}
.ant-steps-item-title {
    color: rgba(0, 0, 0, 0.85) !important;
    font-weight: 500;
    cursor: pointer;
}
.mt-30 {
    margin-top: 30px;
}
.mb-30 {
    margin-bottom: 30px;
}
</style>
