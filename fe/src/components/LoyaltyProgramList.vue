<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-input v-model:value="search" placeholder="Tìm kiếm chương trình..." @pressEnter="fetchPrograms" />
            <a-button type="primary" @click="fetchPrograms">Tìm kiếm</a-button>
            <a-button type="primary" @click="goToCreate">Tạo mới</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="programs"
            :pagination="pagination"
            :loading="loading"
            row-key="id"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'image'">
                    <img :src="record.image" alt="image" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px" />
                </template>
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="goToEdit(record.id)">Sửa</a-button>
                        <a-popconfirm title="Xác nhận xoá?" @confirm="deleteProgram(record.id)">
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
import { getLoyaltyPrograms, deleteLoyaltyProgram } from '../api/loyalty'
import { message } from 'ant-design-vue'

const router = useRouter()
const programs = ref([])
const loading = ref(false)
const search = ref('')
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: 'Tên chương trình', dataIndex: 'name', key: 'name' },
    { title: 'Ảnh', dataIndex: 'image', key: 'image' },
    { title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date' },
    { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date' },
    { title: 'Hành động', key: 'action' }
]

const fetchPrograms = async () => {
    loading.value = true
    try {
        const response = await getLoyaltyPrograms({
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: search.value
        })

        programs.value = Array.isArray(response.data) ? response.data : response.data.data || []
        pagination.value.total = response.data.pager?.total || response.data.length || 0
    } catch (e) {
        message.error('Lỗi tải danh sách chương trình')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (p) => {
    pagination.value.current = p.current
    pagination.value.pageSize = p.pageSize
    fetchPrograms()
}

const goToCreate = () => router.push('/loyalty/programs/create')
const goToEdit = (id) => router.push(`/loyalty/programs/${id}/edit`)

const deleteProgram = async (id) => {
    try {
        await deleteLoyaltyProgram(id)
        message.success('Đã xoá chương trình')
        fetchPrograms()
    } catch (e) {
        message.error('Xoá thất bại')
    }
}

onMounted(fetchPrograms)
</script>
