<!-- src/components/HistoryParticipation.vue -->
<template>
    <a-table :columns="columns" :dataSource="data" rowKey="id" :loading="loading" />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getParticipationHistory } from '../api/loyalty'

const loading = ref(false)
const data = ref([])

const columns = [
    { title: 'Họ và tên', dataIndex: 'name' },
    { title: 'Điện thoại', dataIndex: 'phone' },
    { title: 'Địa chỉ', dataIndex: 'address' },
    { title: 'Quà tặng', dataIndex: 'gift_name' },
    { title: 'Chương trình', dataIndex: 'program_name' },
    { title: 'Đối tượng', dataIndex: 'object_type' },
    { title: 'Sản phẩm quét', dataIndex: 'scanned_product' },
    { title: 'Trạng thái trúng thưởng', dataIndex: 'winning_status' },
    { title: 'Thời gian tham gia', dataIndex: 'joined_at' },
]

const fetchData = async () => {
    loading.value = true
    try {
        const res = await getParticipationHistory()
        data.value = res.data
    } catch (e) {
        console.error('Lỗi tải dữ liệu lịch sử tham gia', e)
    } finally {
        loading.value = false
    }
}

onMounted(fetchData)
</script>
