<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-input v-model:value="search" placeholder="Tìm kiếm tên quà..." @pressEnter="fetchGifts" />
            <a-select v-model:value="type" style="width: 180px" placeholder="Loại quà">
                <a-select-option value="point">Điểm VNPoint</a-select-option>
                <a-select-option value="physical">Hiện vật</a-select-option>
            </a-select>
            <a-button type="primary" @click="fetchGifts">Tìm kiếm</a-button>
            <a-button type="primary" @click="goToCreate">+ Thêm mới</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="gifts"
            :pagination="pagination"
            :loading="loading"
            row-key="id"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'image'">
                    <img :src="record.image" alt="gift" style="width: 40px; height: 40px; border-radius: 4px;" />
                </template>
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="goToEdit(record.id)">Sửa</a-button>
                        <a-popconfirm title="Xác nhận xoá?" @confirm="deleteGift(record.id)">
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
import { getLoyaltyGifts, deleteLoyaltyGift } from '../api/loyalty'
import { message } from 'ant-design-vue'

import Quill from 'quill'
import 'quill/dist/quill.snow.css'

const router = useRouter()
const search = ref('')
const type = ref()
const gifts = ref([])
const loading = ref(false)
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

const columns = [
    { title: '#', dataIndex: 'id', key: 'id' },
    { title: 'Hình ảnh', dataIndex: 'image', key: 'image' },
    { title: 'Tên quà', dataIndex: 'name', key: 'name' },
    { title: 'Loại', dataIndex: 'type_label', key: 'type_label' },
    { title: 'Giá trị', dataIndex: 'value', key: 'value' },
    { title: 'Trạng thái', dataIndex: 'status_label', key: 'status_label' },
    { title: 'Cập nhật', dataIndex: 'updated_at', key: 'updated_at' },
    { title: 'Hành động', key: 'action' }
]

const fetchGifts = async () => {
    loading.value = true
    try {
        const response = await getLoyaltyGifts({
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: search.value,
            type: type.value
        })
        gifts.value = response.data.data || []
        pagination.value.total = response.data.pager?.total || gifts.value.length
    } catch {
        message.error('Lỗi tải danh sách quà tặng')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (p) => {
    pagination.value.current = p.current
    pagination.value.pageSize = p.pageSize
    fetchGifts()
}

const goToCreate = () => router.push('/loyalty/gifts/create')
const goToEdit = (id) => router.push(`/loyalty/gifts/${id}/edit`)

const deleteGift = async (id) => {
    try {
        await deleteLoyaltyGift(id)
        message.success('Đã xoá quà tặng')
        fetchGifts()
    } catch {
        message.error('Xoá thất bại')
    }
}

onMounted(fetchGifts)
</script>
