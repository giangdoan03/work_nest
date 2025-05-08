<template>
    <a-card title="Trang tự thiết kế">
        <a-space style="margin-bottom: 16px;">
            <a-input v-model:value="search" placeholder="Tìm kiếm" style="width: 180px" />
            <a-button type="primary" @click="fetchData">Tìm kiếm</a-button>
        </a-space>
        <a-table
            :dataSource="data"
            :columns="columns"
            :pagination="pagination"
            :loading="loading"
            rowKey="id"
            bordered
        />
    </a-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getLandingPages } from '@/api/landing'

const data = ref([])
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0
})
const search = ref('')
const loading = ref(false)



const columns = [
    { title: 'ID', dataIndex: 'id' },
    { title: 'Tên trang', dataIndex: 'title' },
    { title: 'Lượt truy cập', dataIndex: 'access_count' },
    { title: 'Trạng thái', dataIndex: 'status' },
    { title: 'Cập nhật', dataIndex: 'updated_at' },
]

const handleTableChange = (paginationInfo) => {
    pagination.value.current = paginationInfo.current
    pagination.value.pageSize = paginationInfo.pageSize
    fetchData(pagination.value.current)
}

const fetchData = async (page = 1) => {
    loading.value = true
    try {
        const res = await getLandingPages({
            page,
            per_page: pagination.value.pageSize,
            search: search.value
        })

        data.value = res.data.data

        const pager = res.data.pager || {}
        pagination.value.total = Number(pager.total || 0)
        pagination.value.current = Number(pager.current_page || 1)
        pagination.value.pageSize = Number(pager.per_page || 10)
    } catch (e) {
        console.error('Lỗi tải danh sách landing pages:', e)
    } finally {
        loading.value = false
    }
}




onMounted(() => fetchData())
</script>

