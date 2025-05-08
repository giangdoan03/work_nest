<template>
    <div>
        <a-space style="margin-bottom: 16px;">
            <a-input v-model:value="search" placeholder="Tên, SĐT hoặc Mã số thuế..." @pressEnter="fetchBusinesses" />
            <a-button type="primary" @click="fetchBusinesses">Tìm kiếm</a-button>
            <a-button type="primary" @click="goToCreate">Thêm mới</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="businesses"
            :pagination="pagination"
            row-key="id"
            :loading="loading"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <!-- Hiển thị ảnh đại diện -->
                <template v-if="column.key === 'logo'">
                    <img
                        v-if="record.logo && Array.isArray(record.logo) && record.logo.length > 0"
                        :src="record.logo[0]"
                        alt="Logo"
                        style="height: 40px;"
                    />
                </template>

                <!-- Hiển thị trạng thái -->
                <template v-else-if="column.key === 'status'">
                    <a-tag :color="record.status === '1' || record.status === 1 ? 'green' : 'red'">
                        {{ record.status === '1' || record.status === 1 ? 'Hoạt động' : 'Ngừng hoạt động' }}
                    </a-tag>
                </template>

                <!-- Hành động -->
                <template v-else-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="goToEdit(record.id)">Sửa</a-button>
                        <a-popconfirm title="Xác nhận xoá?" @confirm="deleteBusiness(record.id)">
                            <a-button type="link" danger>Xoá</a-button>
                        </a-popconfirm>
                    </a-space>
                </template>
            </template>
        </a-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getBusinesses, deleteBusiness as apiDeleteBusiness } from '../api/business'
import { message } from 'ant-design-vue'
import { formatDate } from '../utils/formUtils' // hoặc '../utils/date' tùy vào vị trí file

const router = useRouter()
const businesses = ref([])
const loading = ref(false)
const search = ref('')
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

const columns = [
    { title: 'Ảnh', dataIndex: 'logo', key: 'logo' },
    { title: 'Thông tin', dataIndex: 'name', key: 'name' },
    { title: 'Địa chỉ', dataIndex: 'address', key: 'address' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
    { title: 'Khu vực', dataIndex: 'city', key: 'city' },
    {
        title: 'Ngày tạo',
        dataIndex: 'created_at',
        key: 'created_at',
        customRender: ({ text }) => formatDate(text)
    },
    { title: 'Thời gian cập nhật', dataIndex: 'updated_at', key: 'updated_at', customRender: ({ text }) => formatDate(text) },
    { title: 'Hành động', key: 'action' },
]

const fetchBusinesses = async () => {
    loading.value = true
    try {
        const response = await getBusinesses({
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: search.value,
        })
        businesses.value = response.data.data.map(item => {
            if (typeof item.logo === 'string') {
                try {
                    const parsed = JSON.parse(item.logo)
                    item.logo = Array.isArray(parsed) ? parsed : []
                } catch (e) {
                    item.logo = []
                }
            }
            return item
        })
        pagination.value.total = response.data.pager.total
    } catch (error) {
        message.error('Lỗi tải doanh nghiệp')
    } finally {
        loading.value = false
    }
}


const handleTableChange = (paginationParam) => {
    pagination.value.current = paginationParam.current
    pagination.value.pageSize = paginationParam.pageSize
    fetchBusinesses()
}

const goToCreate = () => router.push('/businesses/create')
const goToEdit = (id) => router.push(`/businesses/${id}/edit`)

const deleteBusiness = async (id) => {
    try {
        await apiDeleteBusiness(id)
        message.success('Đã xoá doanh nghiệp')
        fetchBusinesses()
    } catch (error) {
        message.error('Lỗi xoá doanh nghiệp')
    }
}

onMounted(fetchBusinesses)
</script>
