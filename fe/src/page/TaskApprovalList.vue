<template>
    <div>
        <a-typography-title :level="4">Nhiệm vụ cần duyệt</a-typography-title>

        <a-table
            :columns="columns"
            :data-source="taskApprovals"
            :loading="loading"
            row-key="id"
            :pagination="pagination"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.dataIndex === 'title'">
                    <router-link :to="`/internal-tasks/${record.task_id}/info`">
                        {{ record.title }}
                    </router-link>
                </template>

                <template v-if="column.dataIndex === 'level'">
                    Cấp {{ record.level }}
                </template>

                <template v-if="column.dataIndex === 'status'">
                    <a-tag :color="getStatusColor(record.status)">
                        {{ getStatusText(record.status) }}
                    </a-tag>
                </template>

                <template v-if="column.dataIndex === 'action'">
                    <a-space>
                        <a-button type="primary" @click="openModal(record, 'approve')">Duyệt</a-button>
                        <a-button danger @click="openModal(record, 'reject')">Từ chối</a-button>
                    </a-space>
                </template>
            </template>
        </a-table>

        <!-- ✅ Modal nhập comment -->
        <a-modal
            v-model:open="modalVisible"
            :title="modalAction === 'approve' ? 'Xác nhận duyệt' : 'Từ chối nhiệm vụ'"
            ok-text="Xác nhận"
            cancel-text="Hủy"
            @ok="handleModalSubmit"
        >
            <a-form layout="vertical">
                <a-form-item label="Ghi chú (không bắt buộc)">
                    <a-textarea v-model:value="comment" placeholder="Nhập lý do hoặc ghi chú..." />
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getTaskApprovals, approveTaskAPI, rejectTaskAPI } from '@/api/taskApproval'
import { message } from 'ant-design-vue'

// Danh sách duyệt
const taskApprovals = ref([])
const loading = ref(false)

// Phân trang
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0
})

// Modal
const modalVisible = ref(false)
const comment = ref('')
const selectedRecord = ref(null)
const modalAction = ref('approve')

// Cột
const columns = [
    { title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title' },
    { title: 'Cấp duyệt', dataIndex: 'level', key: 'level' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
    { title: 'Hành động', dataIndex: 'action', key: 'action' }
]

// Fetch
const fetchData = async () => {
    loading.value = true
    try {
        const res = await getTaskApprovals({
            page: pagination.value.current,
            limit: pagination.value.pageSize
        })
        taskApprovals.value = res.data.data
        pagination.value.total = res.data.total
    } catch (e) {
        message.error('Không thể tải danh sách duyệt')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (paginationChange) => {
    pagination.value.current = paginationChange.current
    pagination.value.pageSize = paginationChange.pageSize
    fetchData()
}

// ✅ Mở modal nhập comment
const openModal = (record, action) => {
    selectedRecord.value = record
    modalAction.value = action
    comment.value = ''
    modalVisible.value = true
}

// ✅ Submit hành động duyệt/từ chối
const handleModalSubmit = async () => {
    try {
        if (modalAction.value === 'approve') {
            await approveTaskAPI(selectedRecord.value.id, comment.value)
            message.success('Duyệt thành công')
        } else {
            await rejectTaskAPI(selectedRecord.value.id, comment.value)
            message.success('Từ chối thành công')
        }

        modalVisible.value = false
        await fetchData()
    } catch {
        message.error(modalAction.value === 'approve' ? 'Duyệt thất bại' : 'Từ chối thất bại')
    }
}

// Hiển thị trạng thái
const getStatusColor = (status) => {
    switch (status) {
        case 'pending': return 'orange'
        case 'approved': return 'green'
        case 'rejected': return 'red'
        default: return ''
    }
}
const getStatusText = (status) => {
    switch (status) {
        case 'pending': return 'Đang chờ'
        case 'approved': return 'Đã duyệt'
        case 'rejected': return 'Từ chối'
        default: return '—'
    }
}

onMounted(fetchData)
</script>
