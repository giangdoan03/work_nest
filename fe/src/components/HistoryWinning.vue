<!-- src/components/HistoryWinning.vue -->
<template>
    <a-table :columns="columns" :dataSource="data" rowKey="id" :loading="loading" />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getWinningHistory } from '../api/loyalty'

const loading = ref(false)
const data = ref([])

const columns = [
    { title: 'Họ và tên', dataIndex: 'name' },
    { title: 'Điện thoại', dataIndex: 'phone' },
    { title: 'Số ĐT nạp thẻ', dataIndex: 'redeem_phone' },
    { title: 'Địa chỉ', dataIndex: 'address' },
    { title: 'Quà tặng', dataIndex: 'gift_name' },
    { title: 'Chương trình', dataIndex: 'program_name' },
    { title: 'Lý do', dataIndex: 'reason' },
    { title: 'Đối tượng', dataIndex: 'object_type' },
    { title: 'Thời gian trúng thưởng', dataIndex: 'won_at' },
    { title: 'Thời gian nhận quà', dataIndex: 'received_at' },
]
const fetchData = async () => {
    loading.value = true
    try {
        const res = await getWinningHistory()
        data.value = res.data
    } catch (e) {
        console.error('Lỗi tải dữ liệu trúng thưởng', e)
    } finally {
        loading.value = false
    }
}

onMounted(fetchData)
</script>
