<template>
    <div>
        <a-space style="margin-bottom: 16px;">
            <a-input v-model:value="search" placeholder="Tìm theo loại, tỉnh..." @pressEnter="fetchData" />
            <a-button type="primary" @click="fetchData">Tìm kiếm</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="histories"
            :pagination="pagination"
            row-key="id"
            :loading="loading"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <!-- Ảnh -->
                <template v-if="column.key === 'object_image'">
                    <img v-if="record.object_image" :src="record.object_image" alt="Ảnh" style="width: 50px; height: 50px; object-fit: cover;" />
                </template>

                <!-- Hệ điều hành -->
                <template v-else-if="column.key === 'os'">
                    <a-tag>{{ record.os }}</a-tag>
                </template>

                <!-- Ứng dụng -->
                <template v-else-if="column.key === 'app'">
                    <a-tag color="blue">{{ record.app || 'Không xác định' }}</a-tag>
                </template>

                <!-- Thời gian -->
                <template v-else-if="column.key === 'created_at'">
                    {{ formatDate(record.created_at) }}
                </template>
            </template>
        </a-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { formatDate } from '../utils/formUtils'
import axios from 'axios'

const histories = ref([])
const loading = ref(false)
const search = ref('')
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

const columns = [
    { title: 'STT', key: 'stt', customRender: ({ index }) => index + 1 },
    { title: 'Ảnh đối tượng', key: 'object_image', dataIndex: 'object_image' },
    { title: 'Tên QR Code', key: 'qr_name', dataIndex: 'qr_name' },
    { title: 'Tên đối tượng', key: 'object_name', dataIndex: 'object_name' },
    { title: 'Loại QR Code', key: 'qr_type', dataIndex: 'qr_type' },
    { title: 'Khách hàng', key: 'customer', dataIndex: 'customer' },
    { title: 'Tỉnh thành', key: 'city', dataIndex: 'city' },
    { title: 'Vị trí', key: 'location', dataIndex: 'location' },
    { title: 'SĐT', key: 'phone', dataIndex: 'phone' },
    { title: 'IP', key: 'ip', dataIndex: 'ip' },
    { title: 'Hệ điều hành', key: 'os', dataIndex: 'os' },
    { title: 'Ứng dụng', key: 'app', dataIndex: 'app' },
    { title: 'Thời gian', key: 'created_at', dataIndex: 'created_at' },
]

const fetchData = async () => {
    loading.value = true
    try {
        const response = await axios.get('http://api.giang.test/api/scan-history', {
            params: {
                search: search.value,
                page: pagination.value.current,
                per_page: pagination.value.pageSize
            },
            withCredentials: true
        })
        histories.value = response.data.data
        pagination.value.total = response.data.pager.total
    } catch (err) {
        message.error('Không thể tải dữ liệu')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (p) => {
    pagination.value.current = p.current
    pagination.value.pageSize = p.pageSize
    fetchData()
}

onMounted(fetchData)
</script>
