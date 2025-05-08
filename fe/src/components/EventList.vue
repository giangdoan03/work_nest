<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-input v-model:value="search" placeholder="Tìm kiếm sự kiện..." @pressEnter="fetchEvents" />
            <a-button type="primary" @click="fetchEvents">Tìm kiếm</a-button>
            <a-button type="primary" @click="goToCreate">Tạo mới</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="events"
            :pagination="pagination"
            :loading="loading"
            row-key="id"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'banner'">
                    <img :src="record.banner" alt="banner" style="width: 60px; height: 40px; object-fit: cover" />
                </template>
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="goToEdit(record.id)">Sửa</a-button>
                        <a-popconfirm title="Xác nhận xoá?" @confirm="deleteEvent(record.id)">
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
import { getEvents, deleteEvent as apiDeleteEvent } from '../api/event'
import { message } from 'ant-design-vue'
import { formatDate } from '../utils/formUtils' // hoặc '../utils/date' tùy vào vị trí file

const router = useRouter()
const events = ref([])
const loading = ref(false)
const search = ref('')
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: 'Banner', dataIndex: 'banner', key: 'banner' },
    { title: 'Tên', dataIndex: 'name', key: 'name' },
    { title: 'Địa điểm', dataIndex: 'location', key: 'location' },
    { title: 'Thời gian', dataIndex: 'start_time', key: 'start_time', customRender: ({ text }) => formatDate(text) },
    { title: 'Hành động', key: 'action' },
]

const fetchEvents = async () => {
    loading.value = true
    try {
        const response = await getEvents({
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: search.value
        })
        events.value = response.data.data
        pagination.value.total = response.data.pager.total
    } catch (e) {
        message.error('Lỗi tải dữ liệu sự kiện')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (p) => {
    pagination.value.current = p.current
    pagination.value.pageSize = p.pageSize
    fetchEvents()
}

const goToCreate = () => router.push('/events/create')
const goToEdit = (id) => router.push(`/events/${id}/edit`)

const deleteEvent = async (id) => {
    try {
        await apiDeleteEvent(id)
        message.success('Đã xoá sự kiện')
        fetchEvents()
    } catch (e) {
        message.error('Xoá thất bại')
    }
}

onMounted(fetchEvents)
</script>

<style scoped></style>
