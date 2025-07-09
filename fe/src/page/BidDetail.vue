<template>
    <div>
        <a-page-header
            title="Chi tiết gói thầu"
            sub-title="Xem thông tin và tiến trình xử lý"
            @back="goBack"
            style="padding: 0 0 20px;"
        />
        <a-descriptions bordered :column="2">
            <!-- Hàng 1 -->
            <a-descriptions-item label="Tên">{{ bidding?.title }}</a-descriptions-item>
            <a-descriptions-item label="Trạng thái">
                <a-tag :color="getStatusColor(bidding?.status)">
                    {{ getStatusText(bidding?.status) }}
                </a-tag>
            </a-descriptions-item>

            <!-- Hàng 2 -->
            <a-descriptions-item label="Chi phí">{{ formatCurrency(bidding?.estimated_cost) }}</a-descriptions-item>
            <a-descriptions-item label="Khách hàng">
                <a @click="goToCustomerDetail(bidding?.customer_id)" style="color: #1890ff; cursor: pointer;">
                    {{ getCustomerName(bidding?.customer_id) }}
                </a>
            </a-descriptions-item>

            <!-- Hàng 3 -->
            <a-descriptions-item label="Phụ trách gói thầu">
                <a
                    v-if="bidding?.assigned_to"
                    @click="goToUserDetail(bidding.assigned_to)"
                    style="color: #1890ff; cursor: pointer;"
                >
                    {{ getAssignedUserName(bidding?.assigned_to) }}
                </a>
                <span v-else>Không xác định</span>
            </a-descriptions-item>

            <a-descriptions-item label="Ngày bắt đầu">{{ formatDate(bidding?.start_date) }}</a-descriptions-item>

            <!-- Hàng 4 -->
            <a-descriptions-item label="Ngày kết thúc">{{ formatDate(bidding?.end_date) }}</a-descriptions-item>
            <a-descriptions-item label="Mô tả">
                {{ bidding?.description }}
            </a-descriptions-item>
        </a-descriptions>

        <a-typography-title :level="5" class="mt-30 mb-30">Tiến trình xử lý</a-typography-title>

        <a-spin :spinning="loadingSteps">
            <a-steps direction="vertical" :current="currentStepIndex()">
                <a-step
                    v-for="(step, index) in steps"
                    :key="step.id"
                    :status="mapStepStatus(step.status)"
                >
                    <template #title>
                        <div
                            @click.stop="openStepDrawer(step)"
                            style="
                                  display: flex;
                                  justify-content: space-between;
                                  align-items: center;
                                  cursor: pointer;
                                  color: #1890ff;
                                ">
                                <span style="text-decoration: underline;">
                                  Bước {{ step.step_number ?? '-' }}: {{ step.title ?? '-' }}
                                </span>

                            <span
                                v-if="step.task_count !== undefined"
                                style="font-size: 12px; color: #888; font-weight: normal; padding-left: 10px"
                            >
                                  {{ step.task_done_count ?? 0 }}/{{ step.task_count }} task đã xong
                                </span>
                        </div>
                    </template>

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
                                Phụ trách bước:
                                <a
                                    v-if="step.assigned_to"
                                    @click.stop="goToUserDetail(step.assigned_to)"
                                    style="color: #1890ff; cursor: pointer;"
                                >
                                    {{ getAssignedUserName(step.assigned_to) }}
                                </a>
                                <span v-else>Không xác định</span>
                            </p>
                            <p>
                                Ngày bắt đầu:
                                <span v-if="step.start_date">
                                    {{ formatDate(step.start_date) }}
                                </span>
                                <span v-else> --</span>
                            </p>
                            <p>
                                Ngày kết thúc:
                                <span v-if="step.end_date">
                                    {{ formatDate(step.end_date) }}
                                </span>
                                <span v-else> --</span>
                            </p>

                        </div>
                    </template>
                </a-step>

            </a-steps>
        </a-spin>


        <!-- Drawer hiển thị chi tiết bước -->
        <a-drawer
            title="Chi tiết bước xử lý"
            placement="right"
            :visible="drawerVisible"
            @close="drawerVisible = false"
            width="680"
        >
            <template v-if="selectedStep">
                <a-descriptions
                    size="small"
                    :column="1"
                    bordered
                >
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

                    <a-descriptions-item label="Ngày bắt đầu">
                        <a-typography-text type="secondary" v-if="!showEditDateStart" @click="editDateStart">
                            {{ formatDate(selectedStep.start_date) }}
                        </a-typography-text>
                        <a-date-picker
                            v-if="showEditDateStart"
                            style="width: 100%"
                            v-model:value="dateStart"
                            @change="updateStepStartDate"
                        />
                    </a-descriptions-item>
                    <a-descriptions-item label="Ngày kết thúc">
                        <a-typography-text type="secondary" v-if="!showEditDateEnd" @click="editDateEnd">
                            {{ formatDate(selectedStep.end_date) }}
                        </a-typography-text>
                        <a-date-picker
                            :disabledDate="disabledDate"
                            v-if="showEditDateEnd"
                            style="width: 100%"
                            v-model:value="dateEnd"
                            @change="updateStepEndDate"
                        />
                    </a-descriptions-item>

                </a-descriptions>


                <a-divider>Danh sách công việc của bước này</a-divider>

                <!-- Nếu không có task -->
                <a-empty v-if="relatedTasks.length === 0" description="Không có công việc"/>

                <!-- Nếu có task -->
                <template v-else>
                    <!-- Header -->
                    <div
                        style="
                          display: flex;
                          justify-content: space-between;
                          padding: 8px 16px;
                          font-weight: 500;
                          color: #555;
                          border-bottom: 1px solid #f0f0f0;
                        "
                    >
                        <span>Nội dung mô tả</span>
                        <span>Trạng thái</span>
                    </div>

                    <!-- Danh sách nhiệm vụ -->
                    <a-list
                        :dataSource="relatedTasks"
                        :rowKey="task => task.id"
                        item-layout="horizontal"
                    >
                        <template #renderItem="{ item }">
                            <a-list-item>
                                <div style="display: flex; justify-content: space-between; width: 100%;">
                                    <!-- Cột trái: nội dung -->
                                    <div>
                                        <div style="font-weight: 600;">
                                            <router-link :to="`/internal-tasks/${item.id}/info`">
                                                {{ item.title }}
                                            </router-link>
                                        </div>
                                        <div style="font-size: 13px; color: #666;">
                                            {{ item.description }}
                                        </div>
                                        <div style="font-size: 13px; color: #999;">
                                            Phụ trách: {{ getAssignedUserName(item.assigned_to) }}
                                        </div>
                                    </div>

                                    <!-- Cột phải: trạng thái thực hiện + duyệt -->
                                    <div style="white-space: nowrap; text-align: right;">
                                        <!-- Luôn hiển thị trạng thái task -->
                                        <a-tag :color="getTaskStatusColor(item.status)">
                                            {{ getTaskStatusText(item.status) }}
                                        </a-tag>

                                        <!-- Nếu đã hoàn thành và đã duyệt -->
                                        <div v-if="item.status === 'done' && item.approval_status === 'approved'">
                                            <a-tag color="green">Hoàn thành & Đã duyệt</a-tag>
                                        </div>

                                        <!-- Nếu hoàn thành nhưng chưa được duyệt hoặc bị từ chối -->
                                        <div v-else-if="item.status === 'done'">
                                            <a-tag :color="getApprovalStatusColor(item.approval_status)">
                                                {{ getApprovalStatusText(item.approval_status) }}
                                            </a-tag>
                                        </div>
                                    </div>

                                </div>
                            </a-list-item>
                        </template>
                    </a-list>


                </template>


            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import {ref, onMounted} from 'vue'
import dayjs from 'dayjs'
import {
    getBiddingAPI,
    cloneFromTemplatesAPI,
    getBiddingStepsAPI,
    updateBiddingStepAPI,
    completeBiddingStepAPI
} from '@/api/bidding'
import {getUsers} from '@/api/user.js'
import {useRoute} from 'vue-router'
import {message} from 'ant-design-vue'
import {formatDate, formatCurrency} from '@/utils/formUtils'
import {getCustomers} from '../api/customer' // file API của bạn
import {useRouter} from 'vue-router'

const router = useRouter()
const route = useRoute()
const id = route.params.id
const bidding = ref({})
const steps = ref([])
const loadingSteps = ref(false)

let drawerVisible = ref(false)
const selectedStep = ref(null)
const customers = ref([])
const users = ref([])

import {getTasksByBiddingStep} from '@/api/task' // nếu chưa import

const allTasks = ref([])
const relatedTasks = ref([])

const dateStart = ref()
const dateEnd = ref()
const showEditDateStart = ref(false)
const showEditDateEnd = ref(false)
const editDateStart = () => {
    dateStart.value = dayjs(selectedStep.value.start_date)
    showEditDateStart.value = true
    showEditDateEnd.value = false
}
const editDateEnd = () => {
    dateEnd.value = dayjs(selectedStep.value.end_date)
    showEditDateStart.value = false
    showEditDateEnd.value = true
}
const updateStepStartDate = async (value, option) => {
    selectedStep.value.start_date = value.format('YYYY-MM-DD');
    try {
        await updateBiddingStepAPI(selectedStep.value.id, { start_date: selectedStep.value.start_date })
        message.success('Cập nhật ngày bắt đầu thành công')
        showEditDateStart.value = false
        await fetchSteps()
    } catch (e) {
        const msg = 'Không thể cập nhật ngày bắt đầu'
        message.error(msg)
        console.warn('Lỗi cập nhật ngày bắt đầu:', msg)
    }
}
const updateStepEndDate = async (value, option) => {
    selectedStep.value.end_date = value.format('YYYY-MM-DD')
    try {
        await updateBiddingStepAPI(selectedStep.value.id, { end_date: selectedStep.value.end_date })
        message.success('Cập nhật ngày kết thúc thành công')
        showEditDateEnd.value = false
        await fetchSteps()
    } catch (e) {
        console.log('e', e)
        const msg = 'Không thể cập nhật ngày kết thúc'
        message.error(msg)
        console.warn('Lỗi cập nhật ngày kết thúc:', msg)
    }
}
const disabledDate = current => {
  return current && current < dayjs(selectedStep.value.start_date).endOf('day');
};
const openStepDrawer = async (step) => {
    selectedStep.value = {...step}
    console.log('selectedStep.value', selectedStep.value)
    drawerVisible.value = true

    try {
        const res = await getTasksByBiddingStep(step.id)
        console.log('res', res)
        relatedTasks.value = res.data || []
    } catch (e) {
        console.error('Không thể tải công việc của bước', e)
        message.error('Không thể tải danh sách công việc')
        relatedTasks.value = []
    }
}
const getStatusColor = (status) => {
    const map = {
        0: 'orange',   // Chưa nộp
        1: 'blue',     // Đã nộp
        2: 'purple',   // Vào vòng sau
        3: 'green',    // Trúng thầu
        4: 'red',      // Không trúng
        5: 'gray'      // Hủy
    }
    return map[status] || 'default'
}

const statusText = (status) => {
    return {
        '0': 'Chưa bắt đầu',
        '1': 'Đang xử lý',
        '2': 'Đã hoàn thành',
        '3': 'Bỏ qua',
    }[status] || 'Không rõ'
}

const getApprovalStatusText = (status) => {
    switch (status) {
        case 'approved':
            return 'Đã duyệt';
        case 'pending':
            return 'Chờ duyệt';
        case 'rejected':
            return 'Từ chối';
        default:
            return 'Không rõ';
    }
}

const getApprovalStatusColor = (status) => {
    switch (status) {
        case 'approved':
            return 'green';
        case 'pending':
            return 'blue';
        case 'rejected':
            return 'red';
        default:
            return 'gray';
    }

}

const lastCompletedIndex = () => {
    for (let i = steps.value.length - 1; i >= 0; i--) {
        if (steps.value[i].status === '2') return i
    }
    return -1
}

const getStepStatusColor = (status) => {
    return {
        '0': 'default',
        '1': 'blue',
        '2': 'green',
        '3': 'orange',
    }[status] || 'default'
}

const mapStepStatus = (status) => {
    return {
        '0': 'wait',
        '1': 'process',
        '2': 'finish',
        '3': 'error',
    }[status] || 'wait'
}

const currentStepIndex = () => {
    const last = lastCompletedIndex()
    const next = last + 1
    return next >= steps.value.length ? steps.value.length - 1 : next
}

const parseDepartment = (val) => {
    try {
        const parsed = JSON.parse(val)
        return Array.isArray(parsed) ? parsed : [val]
    } catch (e) {
        return val ? [val] : []
    }
}


const getTaskStatusText = (status) => ({
    todo: 'Chưa bắt đầu',
    doing: 'Đang làm',
    done: 'Hoàn thành',
    overdue: 'Trễ hạn'
}[status] || 'Không rõ')

const getTaskStatusColor = (status) => ({
    todo: 'default',
    doing: 'blue',
    done: 'green',
    overdue: 'red'
}[status] || 'default')

const updateStepStatus = async (newStatus, step) => {
    try {
        if (newStatus === '2') {
            await completeBiddingStepAPI(step.id)
            message.success('Bước đã hoàn thành và bước kế tiếp đã được mở')
        } else {
            await updateBiddingStepAPI(step.id, {status: newStatus})
            message.success('Đã cập nhật trạng thái bước')
        }

        drawerVisible.value = false
        await fetchData()
    } catch (e) {
        console.warn('⚠️ Lỗi cập nhật bước:', e)

        // Ưu tiên lấy thông báo cụ thể từ server nếu có
        const errMsg =
            e?.response?.data?.messages?.error || // CodeIgniter 4 style
            e?.response?.data?.message ||         // Generic REST error
            '❌ Đã xảy ra lỗi khi cập nhật bước'

        if (e?.response?.status === 400) {
            message.warning(errMsg) // Lỗi logic (ví dụ: chưa hoàn thành bước trước)
        } else {
            message.error(errMsg)   // Lỗi nghiêm trọng (server, network,...)
        }
    }
}

const updateStepDate = async (field, date, step) => {
    try {
        const payload = {[field]: date ? date.format('YYYY-MM-DD') : null}
        await updateBiddingStepAPI(step.id, payload)
        message.success(`Đã cập nhật ${field === 'start_date' ? 'ngày bắt đầu' : 'ngày kết thúc'}`)
        await fetchSteps()
    } catch (e) {
        console.error(`Lỗi cập nhật ${field}:`, e)
        message.error(`Không thể cập nhật ${field}`)
    }
}

const fetchUsers = async () => {
    try {
        const res = await getUsers()
        users.value = res.data
    } catch (e) {
        console.error('Không thể tải danh sách người dùng:', e)
    }
}

const getAssignedUserName = (userId) => {
    if (!userId || !users.value.length) return 'Không xác định'
    const found = users.value.find(u => String(u.id) === String(userId))
    return found?.name || `Người dùng #${userId}`
}

const goToUserDetail = (userId) => {
    if (!userId) return
    router.push({name: 'user-detail', params: {id: userId}})
}


const fetchSteps = async () => {
    try {
        loadingSteps.value = true
        const stepRes = await getBiddingStepsAPI(id)
        steps.value = stepRes.data.filter(step => step.bidding_id === id)
    } catch (e) {
        console.error('Lỗi khi tải bước:', e)
        message.error('Không thể tải tiến trình xử lý')
    } finally {
        loadingSteps.value = false
    }
}


const updateStepAssignedTo = async (userId, step) => {
    try {
        if (!userId) {
            message.warning('Vui lòng chọn người phụ trách hợp lệ')
            return
        }

        await updateBiddingStepAPI(step.id, {assigned_to: userId})
        message.success('Đã cập nhật người phụ trách')
        await fetchSteps()
    } catch (e) {
        console.error('Lỗi khi cập nhật người phụ trách:', e)
        const msg =
            e?.response?.data?.messages?.error ||
            e?.response?.data?.message ||
            'Cập nhật người phụ trách thất bại'
        message.error(msg)
    }
}


const goToCustomerDetail = (customerId) => {
    if (!customerId) return
    router.push({name: 'customer-detail', params: {id: customerId.toString()}})
}

const fetchCustomers = async () => {
    try {
        const res = await getCustomers()
        customers.value = res.data?.data || [] // fix ở đây
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


const fetchData = async () => {
    try {
        const res = await getBiddingAPI(id)
        bidding.value = res.data

        loadingSteps.value = true
        let stepRes = await getBiddingStepsAPI(id)

        if (!stepRes.data?.length) {
            await cloneFromTemplatesAPI(id)
            stepRes = await getBiddingStepsAPI(id)
        }

        steps.value = stepRes.data.filter((step) => step.bidding_id === id)
    } catch (e) {
        console.error(e)
        message.error('Không thể tải dữ liệu')
    } finally {
        loadingSteps.value = false
    }
}

const getStatusText = (status) => {
    const map = {
        0: 'Chưa nộp',
        1: 'Đã nộp hồ sơ',
        2: 'Vào vòng sau',
        3: 'Đã trúng thầu',
        4: 'Không trúng',
        5: 'Hủy thầu',
    }
    return map[status] ?? `Không rõ`
}
const goBack = () => {
    router.push('/bid-list')
}

onMounted(async () => {
    await Promise.all([
        fetchData(),
        fetchCustomers(),
        fetchUsers()
    ])
    const res = await getUsers()
    users.value = res.data
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

.ant-list-items li {
    padding-left: 0;
    padding-right: 0;
}
</style>
