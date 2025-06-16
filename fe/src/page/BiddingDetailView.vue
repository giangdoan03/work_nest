<template>
    <div>
        <a-typography-title :level="4">Chi tiết gói thầu</a-typography-title>

        <a-descriptions bordered column="2" title="Thông tin gói thầu" style="margin-bottom: 24px">
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

        <a-typography-title :level="5">Danh sách bước xử lý</a-typography-title>

        <a-spin :spinning="loadingSteps">
            <div v-for="(step, index) in steps" :key="step.id" class="step-box">
                <a-card :title="`Bước ${step.step_number ?? '-'}: ${step.title ?? '-'}`">
                    <p><strong>Phòng ban:</strong> {{ step.department ?? '-' }}</p>
                    <p><strong>Trạng thái:</strong> {{ statusText(step.status) }}</p>
                    <a-button
                            type="primary"
                            @click="startStep(step, index)"
                            :disabled="!canOpenStep(index)"
                    >
                        Mở bước này
                    </a-button>
                </a-card>
            </div>
        </a-spin>
    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue'
    import { getBiddingAPI, cloneFromTemplatesAPI } from '@/api/bidding'
    import axios from 'axios'
    import { useRoute } from 'vue-router'
    import { message } from 'ant-design-vue'

    const route = useRoute()
    const id = route.params.id
    const bidding = ref(null)
    const steps = ref([])
    const loadingSteps = ref(false)

    const getStatusColor = (status) => {
        const map = {
            pending: 'orange',
            submitted: 'blue',
            awarded: 'green',
            lost: 'red',
            cancelled: 'gray'
        }
        return map[status] || 'default'
    }

    const statusText = (status) => {
        return {
            '0': 'Chưa bắt đầu',
            '1': 'Đang xử lý',
            '2': 'Đã hoàn thành',
            '3': 'Bỏ qua'
        }[status] || 'Không rõ'
    }

    const lastCompletedIndex = () => {
        for (let i = steps.value.length - 1; i >= 0; i--) {
            if (steps.value[i].status === '2') return i
        }
        return -1
    }

    const canOpenStep = (index) => {
        const lastDone = lastCompletedIndex()
        if (lastDone === -1) return index === 0 && steps.value[index].status === '0'
        return index === lastDone + 1 && steps.value[index].status === '0'
    }

    const startStep = async (step, index) => {
        if (!canOpenStep(index)) return
        try {
            await axios.put(`/api/bidding-steps/${step.id}`, { status: 1 })
            steps.value[index].status = '1'
            message.success(`Đã mở bước ${step.step_number}`)
        } catch (e) {
            message.error('Không thể cập nhật bước')
        }
    }

    const fetchData = async () => {
        try {
            const res = await getBiddingAPI(id)
            bidding.value = res.data

            loadingSteps.value = true
            let stepRes = await axios.get(`/api/bidding-steps?bidding_id=${id}`)

            // Nếu chưa có bước cho gói thầu thì clone từ template
            if (!stepRes.data?.length) {
                await cloneFromTemplatesAPI(id)
                stepRes = await axios.get(`/api/bidding-steps?bidding_id=${id}`)
            }

            // ✅ Lọc chính xác bước thuộc về gói thầu
            steps.value = stepRes.data.filter(step => step.bidding_id == id)
        } catch (e) {
            message.error('Không thể tải dữ liệu')
        } finally {
            loadingSteps.value = false
        }
    }



    onMounted(fetchData)
</script>

<style scoped>
    .step-box {
        margin-bottom: 16px;
    }
</style>
