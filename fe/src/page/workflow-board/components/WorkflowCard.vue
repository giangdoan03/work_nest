<template>
    <a-card
        size="small"
        class="workflow-card"
        :class="{ highlight }"
        hoverable
        @click="goDetail"
    >
        <!-- Title -->
        <div class="title">{{ doc.title }}</div>

        <!-- Meta -->
        <div class="meta">
            <a-tag color="blue">{{ doc.department_name }}</a-tag>
            <a-tag>{{ doc.status }}</a-tag>
        </div>

        <!-- Actions -->
        <div class="actions" @click.stop>
            <a-space size="small">
                <a-button
                    v-if="canApprove"
                    type="primary"
                    size="small"
                    @click="emitApprove"
                >
                    Duyệt
                </a-button>

                <a-button
                    v-if="canApprove"
                    danger
                    size="small"
                    @click="emitReject"
                >
                    Từ chối
                </a-button>

                <a-button
                    v-if="canReturn"
                    size="small"
                    @click="emitReturn"
                >
                    ↩ Trả về phòng
                </a-button>
            </a-space>
        </div>

        <!-- Footer -->
        <div class="footer">
            <span>#{{ doc.id }}</span>
            <span>{{ doc.assigned_to_name }}</span>
        </div>
    </a-card>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

import {
    approveWorkflow,
    rejectWorkflow,
    returnWorkflowToPreviousStep
} from '@/api/workflow'

await approveWorkflow(doc.id, { comment: 'OK' })
await rejectWorkflow(doc.id, { reason: 'Thiếu hồ sơ' })
await returnWorkflowToPreviousStep(doc.id, { reason: 'Bổ sung lại' })

const props = defineProps({
    doc: Object,
    highlight: Boolean,
})

const emit = defineEmits([
    'approve',
    'reject',
    'return',
])

const router = useRouter()
const userStore = useUserStore()

/* ================== NAVIGATION ================== */
const goDetail = () => {
    router.push({
        name: 'workflow-task-info',
        params: { id: props.doc.id },
    })
}

/* ================== PERMISSION ================== */
/**
 * Gợi ý logic (tuỳ DB của bạn):
 * - manager / senior_manager / executive → được duyệt
 */
const canApprove = computed(() =>
    ['manager', 'senior_manager', 'executive']
        .includes(userStore.user?.position_code)
)

const canReturn = computed(() =>
    ['manager', 'senior_manager']
        .includes(userStore.user?.position_code)
)

/* ================== EMITS ================== */
const emitApprove = () => emit('approve', props.doc)
const emitReject  = () => emit('reject', props.doc)
const emitReturn  = () => emit('return', props.doc)
</script>

<style scoped>
.workflow-card {
    cursor: pointer;
}

.workflow-card.highlight {
    border: 1px solid #1677ff;
    box-shadow: 0 0 0 2px rgba(22, 119, 255, 0.25);
}

.title {
    font-weight: 600;
}

.meta {
    margin-top: 6px;
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
}

.actions {
    margin-top: 8px;
}

.footer {
    margin-top: 6px;
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    color: #888;
}
</style>
