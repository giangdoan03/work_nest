<template>
    <div>
        <a-typography-title :level="4">Nhiệm vụ cần duyệt</a-typography-title>

        <a-tabs v-model:activeKey="activeTab" @change="handleTabChange">
            <a-tab-pane key="pending" tab="Cần duyệt" />
            <a-tab-pane key="resolved" tab="Đã duyệt / Từ chối" />
        </a-tabs>

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

                <template v-if="column.dataIndex === 'approval_steps'">
                    <span>{{ renderApprovalSteps(record.approval_steps) }}</span>
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
                        <a-button type="link" @click="viewTimeline(record)">Chi tiết</a-button>
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

        <!-- ✅ Modal dòng thời gian duyệt -->
        <a-modal
                v-model:open="timelineVisible"
                title="Chi tiết duyệt nhiệm vụ"
                :footer="null"
                width="600px"
        >
            <a-timeline>
                <a-timeline-item
                        v-for="step in approvalTimeline"
                        :key="step.level"
                        :color="getTimelineColor(step.status)"
                >
                    <template v-if="step.status === 'approved'">
                        ✅ Cấp {{ step.level }}: {{ step.approved_by_name }} đã duyệt lúc {{ formatTime(step.approved_at) }}
                        <div v-if="step.comment">📝 {{ step.comment }}</div>
                    </template>

                    <template v-else-if="step.status === 'rejected'">
                        ❌ Cấp {{ step.level }}: {{ step.approved_by_name }} đã từ chối lúc {{ formatTime(step.approved_at) }}
                        <div v-if="step.comment">📝 {{ step.comment }}</div>
                    </template>

                    <template v-else-if="step.status === 'pending'">
                        ⏳ Cấp {{ step.level }}: Đang chờ duyệt
                    </template>

                    <template v-else>
                        🔜 Cấp {{ step.level }}: Chưa đến lượt
                    </template>
                </a-timeline-item>
            </a-timeline>
        </a-modal>
    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue'
    import { message } from 'ant-design-vue'
    import {
        getTaskApprovals,
        approveTaskAPI,
        rejectTaskAPI,
        getFullApprovalStatus
    } from '@/api/taskApproval'

    // State
    const taskApprovals = ref([])
    const loading = ref(false)
    const activeTab = ref('pending')

    const pagination = ref({
        current: 1,
        pageSize: 10,
        total: 0
    })

    const modalVisible = ref(false)
    const comment = ref('')
    const selectedRecord = ref(null)
    const modalAction = ref('approve')

    const timelineVisible = ref(false)
    const approvalTimeline = ref([])

    // Columns
    const columns = [
        { title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title' },
        { title: 'Cấp hiện tại', dataIndex: 'level', key: 'level' },
        { title: 'Tổng cấp duyệt', dataIndex: 'approval_steps', key: 'approval_steps' },
        { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
        { title: 'Hành động', dataIndex: 'action', key: 'action' }
    ]

    // Fetch data
    const fetchData = async () => {
        loading.value = true
        try {
            const res = await getTaskApprovals({
                page: pagination.value.current,
                limit: pagination.value.pageSize,
                status: activeTab.value === 'pending' ? 'pending' : 'resolved'
            })
            taskApprovals.value = res.data.data
            pagination.value.total = res.data.total
        } catch (e) {
            message.error('Không thể tải danh sách duyệt')
        } finally {
            loading.value = false
        }
    }

    const handleTabChange = () => {
        pagination.value.current = 1
        fetchData()
    }

    const handleTableChange = (paginationChange) => {
        pagination.value.current = paginationChange.current
        pagination.value.pageSize = paginationChange.pageSize
        fetchData()
    }

    const openModal = (record, action) => {
        selectedRecord.value = record
        modalAction.value = action
        comment.value = ''
        modalVisible.value = true
    }

    const handleModalSubmit = async () => {
        try {
            if (modalAction.value === 'approve') {
                await approveTaskAPI(selectedRecord.value.id, { comment: comment.value })
                message.success('Duyệt thành công')
            } else {
                await rejectTaskAPI(selectedRecord.value.id, { comment: comment.value })
                message.success('Từ chối thành công')
            }
            modalVisible.value = false
            await fetchData()
        } catch {
            message.error(modalAction.value === 'approve' ? 'Duyệt thất bại' : 'Từ chối thất bại')
        }
    }

    // Hiển thị cấp duyệt
    const renderApprovalSteps = (steps) => {
        if (!steps || steps === '0') return 'Không duyệt'
        if (steps === '1') return 'Cấp 1'
        if (steps === '2') return '2 cấp'
        return `${steps} cấp`
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

    // Xem timeline duyệt
    const viewTimeline = async (record) => {
        try {
            const res = await getFullApprovalStatus(record.task_id)
            approvalTimeline.value = res.data
            timelineVisible.value = true
        } catch {
            message.error('Không thể tải chi tiết duyệt')
        }
    }

    // Xử lý màu timeline
    const getTimelineColor = (status) => {
        switch (status) {
            case 'approved': return 'green'
            case 'rejected': return 'red'
            case 'pending': return 'orange'
            default: return 'gray'
        }
    }

    const formatTime = (ts) => {
        return ts ? new Date(ts).toLocaleString('vi-VN') : ''
    }

    onMounted(fetchData)
</script>
