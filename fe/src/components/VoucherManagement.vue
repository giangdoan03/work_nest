<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-input v-model:value="search" placeholder="Tên gói voucher" style="width: 200px" />
            <a-select v-model:value="status" placeholder="Trạng thái gói voucher" style="width: 180px">
                <a-select-option value="1">Đang hoạt động</a-select-option>
                <a-select-option value="0">Tạm dừng</a-select-option>
            </a-select>
            <a-range-picker v-model:value="dateRange" />
            <a-button type="primary" @click="fetchVouchers">Tìm kiếm</a-button>
            <a-button @click="resetFilters">Làm mới</a-button>
            <a-button type="primary" @click="goToCreate">+ Thêm mới</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="vouchers"
            :pagination="pagination"
            :loading="loading"
            row-key="id"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'image'">
                    <img :src="record.image" alt="img" style="width: 40px; height: 40px; border-radius: 4px" />
                </template>
                <template v-if="column.key === 'status'">
                      <span :style="{ color: record.status ? 'green' : 'red' }">
                        {{ record.status ? 'Đang hoạt động' : 'Tạm dừng' }}
                      </span>
                </template>
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="goToEdit(record.id)">Sửa</a-button>
                        <a-switch
                            :checked="record.status"
                            @change="val => toggleStatus(record.id, val)"
                            :loading="statusLoading === record.id"
                        />
                    </a-space>
                </template>
            </template>
        </a-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
    getVoucherPackages,
    toggleVoucherPackageStatus,
    deleteVoucherPackage
} from '../api/loyalty'
import { message } from 'ant-design-vue'

const router = useRouter()
const search = ref('')
const status = ref(null)
const dateRange = ref([])
const loading = ref(false)
const statusLoading = ref(null)

const vouchers = ref([])
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

const columns = [
    { title: 'Ảnh', dataIndex: 'image', key: 'image' },
    { title: 'Tên gói voucher', dataIndex: 'name', key: 'name' },
    { title: 'Giá trị voucher(VND)', dataIndex: 'value', key: 'value' },
    { title: 'Số lượng voucher', dataIndex: 'total_quantity', key: 'total_quantity' },
    { title: 'Số lượng đã phát hành', dataIndex: 'issued_quantity', key: 'issued_quantity' },
    { title: 'Số lượng đã sử dụng', dataIndex: 'used_quantity', key: 'used_quantity' },
    { title: 'Trạng thái', key: 'status' },
    { title: 'Thời gian áp dụng', dataIndex: 'apply_time_display', key: 'apply_time_display' },
    { title: 'Thao tác', key: 'action' }
]

const fetchVouchers = async () => {
    loading.value = true
    try {
        const [start, end] = dateRange.value || []
        const response = await getVoucherPackages({
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: search.value,
            status: status.value,
            start_date: start,
            end_date: end
        })
        vouchers.value = response.data.data || []
        pagination.value.total = response.data.pager?.total || vouchers.value.length
    } catch {
        message.error('Lỗi tải danh sách gói voucher')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (p) => {
    pagination.value.current = p.current
    pagination.value.pageSize = p.pageSize
    fetchVouchers()
}

const resetFilters = () => {
    search.value = ''
    status.value = null
    dateRange.value = []
    fetchVouchers()
}

const goToCreate = () => router.push('/loyalty/voucher-management/create')
const goToEdit = (id) => router.push(`/loyalty/voucher-management/${id}/edit`)

const toggleStatus = async (id, val) => {
    statusLoading.value = id
    try {
        await toggleVoucherPackageStatus(id, val)
        message.success('Cập nhật trạng thái thành công')
        fetchVouchers()
    } catch {
        message.error('Lỗi cập nhật trạng thái')
    } finally {
        statusLoading.value = null
    }
}

onMounted(fetchVouchers)
</script>
