<template>
    <div>
        <a-page-header title="Quản lý khách hàng" />

        <!-- Bộ lọc -->
        <a-row :gutter="[16, 16]" style="margin-bottom: 16px;">
            <a-col :span="4">
                <a-input v-model:value="filters.name" placeholder="Tên khách hàng" />
            </a-col>
            <a-col :span="4">
                <a-input v-model:value="filters.phone" placeholder="Số điện thoại" />
            </a-col>
            <a-col :span="4">
                <a-input v-model:value="filters.email" placeholder="Email" />
            </a-col>
            <a-col :span="4">
                <a-input v-model:value="filters.city" placeholder="Tỉnh/TP" />
            </a-col>
            <a-col :span="6">
                <a-range-picker v-model:value="filters.dateRange" style="width: 100%" />
            </a-col>
            <a-col :span="2">
                <a-button type="primary" block @click="fetchCustomers">Tìm kiếm</a-button>
            </a-col>
        </a-row>

        <a-button @click="exportExcel" style="margin-bottom: 12px;">Export</a-button>

        <!-- Bảng danh sách -->
        <a-table
            :columns="columns"
            :data-source="customers"
            :loading="loading"
            row-key="id"
            :pagination="false"
        >
            <template #bodyCell="{ column, record, index }">
                <!-- Ảnh đại diện -->
                <template v-if="column.key === 'avatar'">
                    <img
                        v-if="record.avatar"
                        :src="record.avatar"
                        alt="avatar"
                        style="width: 50px; height: 50px; object-fit: cover;"
                    />
                </template>
                <!-- STT -->
                <template v-else-if="column.key === 'stt'">
                    {{ index + 1 }}
                </template>
            </template>
        </a-table>
    </div>
</template>

<script setup>
import { ref } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import axios from 'axios'

const customers = ref([])
const loading = ref(false)

const filters = ref({
    name: '',
    phone: '',
    email: '',
    city: '',
    dateRange: [],
})

const columns = [
    { title: 'STT', key: 'stt' },
    { title: 'Ảnh', key: 'avatar', dataIndex: 'avatar' },
    { title: 'Tên khách hàng', key: 'name', dataIndex: 'name' },
    { title: 'Số điện thoại', key: 'phone', dataIndex: 'phone' },
    { title: 'Địa chỉ', key: 'address', dataIndex: 'address' },
    { title: 'Tỉnh thành', key: 'city', dataIndex: 'city' },
    { title: 'Email', key: 'email', dataIndex: 'email' },
    { title: 'Ngày tương tác mới nhất', key: 'last_interaction', dataIndex: 'last_interaction' },
]

const fetchCustomers = async () => {
    loading.value = true
    try {
        const params = {
            search: filters.value.name,
            phone: filters.value.phone,
            email: filters.value.email,
            city: filters.value.city,
            from: filters.value.dateRange[0]
                ? dayjs(filters.value.dateRange[0]).format('YYYY-MM-DD')
                : undefined,
            to: filters.value.dateRange[1]
                ? dayjs(filters.value.dateRange[1]).format('YYYY-MM-DD')
                : undefined,
        }

        const response = await axios.get('http://api.giang.test/api/customer', {
            params,
            withCredentials: true,
        })

        customers.value = response.data.data
    } catch (e) {
        message.error('Không thể tải danh sách khách hàng')
    } finally {
        loading.value = false
    }
}

const exportExcel = () => {
    // Gọi API hoặc sử dụng thư viện export nếu cần
    message.info('Đang phát triển chức năng export...')
}

fetchCustomers()
</script>
