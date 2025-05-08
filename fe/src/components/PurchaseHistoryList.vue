<template>
    <div>
        <a-page-header title="Lịch sử mua gói" />

        <a-table
            :columns="columns"
            :data-source="data"
            :pagination="pagination"
            row-key="id"
            :loading="loading"
        >
            <template #bodyCell="{ column, record, index }">
                <!-- STT -->
                <template v-if="column.key === 'stt'">
                    {{ index + 1 }}
                </template>

                <!-- Trạng thái gói -->
                <template v-else-if="column.key === 'status'">
                    <div>
                        <a-tag :color="record.status === 'pending' ? 'orange' : 'green'">
                            {{ record.status === 'pending' ? 'Chờ duyệt' : 'Kích hoạt' }}
                        </a-tag>
                        <br />
                        <a-tag :color="record.paid ? 'green' : 'red'">
                            {{ record.paid ? 'Đã thanh toán' : 'Chưa thanh toán' }}
                        </a-tag>
                    </div>
                </template>

                <!-- Trạng thái hết hạn -->
                <template v-else-if="column.key === 'expired'">
                    <a-tag :color="record.expired ? 'red' : 'green'">
                        {{ record.expired ? 'Hết hạn' : 'Chưa hết hạn' }}
                    </a-tag>
                </template>

                <!-- Hành động -->
                <template v-else-if="column.key === 'action'">
                    <a-space>
                        <a-tooltip title="Chi tiết">
                            <a-button type="link" icon="info-circle" />
                        </a-tooltip>
                        <a-tooltip title="Thanh toán">
                            <a-button type="link" icon="dollar-circle" />
                        </a-tooltip>
                    </a-space>
                </template>
            </template>
        </a-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getPurchaseHistories } from '../api/purchaseHistory'
import { message } from 'ant-design-vue'

const data = ref([])
const loading = ref(false)

const pagination = ref({
    total: 0,
    current: 1,
    pageSize: 10
})

const columns = [
    { title: 'STT', key: 'stt' },
    { title: 'Tên gói', dataIndex: 'package_name', key: 'package_name' },
    { title: 'Số lượng mã còn lại', dataIndex: 'remaining', key: 'remaining' },
    { title: 'Trạng thái gói', key: 'status' },
    { title: 'Trạng thái hết hạn', key: 'expired' },
    { title: 'Trạng thái nâng cấp', dataIndex: 'upgrade_status', key: 'upgrade_status' },
    { title: 'Ngày đăng ký', dataIndex: 'registered_at', key: 'registered_at' },
    { title: 'Ngày bắt đầu hợp đồng', dataIndex: 'start_date', key: 'start_date' },
    { title: 'Ngày hết hạn theo hợp đồng', dataIndex: 'end_date', key: 'end_date' },
    { title: 'Người đăng ký', dataIndex: 'registered_by', key: 'registered_by' },
    { title: 'Hành động', key: 'action' },
]

const fetchData = async () => {
    loading.value = true
    try {
        const res = await getPurchaseHistories()
        data.value = res.data.data
        pagination.value.total = res.data.pager.total
    } catch (err) {
        message.error('Không thể tải dữ liệu lịch sử mua gói')
    } finally {
        loading.value = false
    }
}

onMounted(fetchData)
</script>
