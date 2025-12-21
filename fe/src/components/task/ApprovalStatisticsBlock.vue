<template>
    <a-spin :spinning="loading">
        <a-table
            :columns="columns"
            :data-source="data"
            row-key="user_id"
            size="small"
            bordered
            :pagination="false"
        />
    </a-spin>
</template>

<script setup>
import { ref, h, onMounted, watch } from 'vue'
import { Tag, Tooltip } from 'ant-design-vue'
import { getApprovalStatisticsByTask } from '@/api/approvalSessions.js'

const props = defineProps({
    taskId: { type: Number, required: true },
})

const data = ref([])
const loading = ref(false)

const columns = [
    {
        title: 'CBNV',
        dataIndex: 'user_name',
    },
    {
        title: 'Tổng số lỗi',
        dataIndex: 'total_error',
        align: 'center',
    },
    {
        title: 'Ngưỡng cho phép',
        dataIndex: 'threshold',
        align: 'center',
    },
    {
        title: 'Thuộc phiên',
        dataIndex: 'violation_sessions',
        align: 'center',
        customRender: ({ record }) => {
            const sessions = record.violation_sessions || []
            if (!sessions.length) {
                return h(Tag, { color: 'green' }, () => 'Không vi phạm')
            }

            return h(
                'div',
                { style: 'display:flex;gap:4px;flex-wrap:wrap' },
                sessions.map(s =>
                    h(
                        Tooltip,
                        { title: `Cấp duyệt: ${s.level}`, key: s.session_id },
                        {
                            default: () =>
                                h(
                                    Tag,
                                    { color: 'red' },
                                    () => `Phiên #${s.session_no}`
                                ),
                        }
                    )
                )
            )
        },
    },
    {
        title: 'Tổng số lần quá hạn',
        dataIndex: 'overdue_count',
        align: 'center',
        customRender: ({ text }) =>
            h(
                'span',
                {
                    style: `
                        color:${text > 0 ? '#cf1322' : '#52c41a'};
                        font-weight:600;
                    `,
                },
                text
            ),
    },
]

const load = async () => {
    if (!props.taskId) return
    loading.value = true
    try {
        const res = await getApprovalStatisticsByTask(props.taskId)
        data.value = Array.isArray(res.data)
            ? res.data.sort((a, b) => b.overdue_count - a.overdue_count)
            : []
    } finally {
        loading.value = false
    }
}


defineExpose({ reload: load })
</script>

