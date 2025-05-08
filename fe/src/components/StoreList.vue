<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-input v-model:value="search" placeholder="Tìm kiếm cửa hàng..." @pressEnter="fetchStores" />
            <a-button type="primary" @click="fetchStores">Tìm kiếm</a-button>
            <a-button type="primary" @click="goToCreate">Tạo mới</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="stores"
            :pagination="pagination"
            :loading="loading"
            row-key="id"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'logo'">
                    <img :src="record.logo" alt="logo" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px" />
                </template>
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="goToEdit(record.id)">Sửa</a-button>
                        <a-popconfirm title="Xác nhận xoá?" @confirm="deleteStore(record.id)">
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
import { getStores, deleteStore as apiDeleteStore } from '../api/store'
import { message } from 'ant-design-vue'
import { formatDate } from '../utils/formUtils' // hoặc '../utils/date' tùy vào vị trí file

const router = useRouter()
const stores = ref([])
const loading = ref(false)
const search = ref('')
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: 'Logo', dataIndex: 'logo', key: 'logo' },
    { title: 'Tên cửa hàng', dataIndex: 'name', key: 'name' },
    { title: 'Email', dataIndex: 'email', key: 'email' },
    { title: 'Số điện thoại', dataIndex: 'phone', key: 'phone' },
    { title: 'Hành động', key: 'action' },
    {
        title: 'Ngày tạo',
        dataIndex: 'created_at',
        key: 'created_at',
        customRender: ({ text }) => formatDate(text)
    }
]

const fetchStores = async () => {
    loading.value = true
    try {
        const response = await getStores({
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: search.value
        })
        stores.value = response.data.data
        pagination.value.total = response.data.pager.total
    } catch (e) {
        message.error('Lỗi tải danh sách cửa hàng')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (p) => {
    pagination.value.current = p.current
    pagination.value.pageSize = p.pageSize
    fetchStores()
}

const goToCreate = () => router.push('/stores/create')
const goToEdit = (id) => router.push(`/stores/${id}/edit`)

const deleteStore = async (id) => {
    try {
        await apiDeleteStore(id)
        message.success('Đã xoá cửa hàng')
        fetchStores()
    } catch (e) {
        message.error('Xoá thất bại')
    }
}

onMounted(fetchStores)
</script>