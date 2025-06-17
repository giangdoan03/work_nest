<template>
    <div>
        <a-descriptions bordered :column="2" title="Thông tin gói thầu">
            <a-descriptions-item label="Tên">{{ bidding?.title }}</a-descriptions-item>
            <a-descriptions-item label="Trạng thái">
                <a-tag :color="getStatusColor(bidding?.status)">{{ bidding?.status }}</a-tag>
            </a-descriptions-item>
            <a-descriptions-item label="Chi phí">{{ bidding?.estimated_cost?.toLocaleString() }} đ</a-descriptions-item>
            <a-descriptions-item label="Khách hàng ID">{{ bidding?.customer_id }}</a-descriptions-item>
            <a-descriptions-item label="Ngày bắt đầu">{{ bidding?.start_date }}</a-descriptions-item>
            <a-descriptions-item label="Ngày kết thúc">{{ bidding?.end_date }}</a-descriptions-item>
            <a-descriptions-item label="Mô tả" :span="2">{{ bidding?.description }}</a-descriptions-item>
        </a-descriptions>

        <a-typography-title :level="5">Tiến trình xử lý</a-typography-title>

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
                            <p>Phòng ban: {{ step.department ?? '-' }}</p>
                            <p>
                                Trạng thái:
                                <span :style="{ color: getStepStatusColor(step.status) }">
                                    {{ statusText(step.status) }}
                                </span>
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
            width="480"
        >
            <template v-if="selectedStep">
                <a-descriptions
                    bordered
                    size="small"
                    :column="1"
                    title="Thông tin bước"
                >
                    <a-descriptions-item label="Bước số">{{ selectedStep.step_number }}</a-descriptions-item>
                    <a-descriptions-item label="Tiêu đề">{{ selectedStep.title }}</a-descriptions-item>
                    <a-descriptions-item label="Phòng ban">{{ selectedStep.department }}</a-descriptions-item>
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
                    <a-descriptions-item label="Ngày tạo">{{ selectedStep.created_at }}</a-descriptions-item>
                    <a-descriptions-item label="Ngày cập nhật">{{ selectedStep.updated_at }}</a-descriptions-item>
                </a-descriptions>
            </template>
        </a-drawer>

    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
    getBiddingAPI,
    cloneFromTemplatesAPI,
    getBiddingStepsAPI,
    updateBiddingStepAPI,
    completeBiddingStepAPI
} from '@/api/bidding'
import axios from 'axios'
import { useRoute } from 'vue-router'
import { message } from 'ant-design-vue'

const route = useRoute()
const id = route.params.id
const bidding = ref(null)
bidding.value = {}
const steps = ref([])
const loadingSteps = ref(false)

const drawerVisible = ref(false)
const selectedStep = ref(null)

const openStepDrawer = (step) => {
    selectedStep.value = { ...step }
    drawerVisible.value = true
}

const getStatusColor = (status) => {
    const map = {
        pending: 'orange',
        submitted: 'blue',
        awarded: 'green',
        lost: 'red',
        cancelled: 'gray',
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

const updateStepStatus = async (newStatus, step) => {
    try {
        if (newStatus === '2') {
            await completeBiddingStepAPI(step.id)
            message.success('Đã hoàn thành và mở bước kế tiếp')
        } else {
            await updateBiddingStepAPI(step.id, { status: newStatus })
            message.success('Đã cập nhật trạng thái bước')
        }

        drawerVisible.value = false
        await fetchData()
    } catch (e) {
        console.error(e)
        message.error('Lỗi khi cập nhật bước')
    }
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

onMounted(fetchData)
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
</style>