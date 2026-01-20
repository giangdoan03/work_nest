<template>
    <a-card
        size="small"
        class="workflow-card"
        :class="{ highlight }"
        hoverable
        @click="goDetail"
    >
        <!-- TITLE -->
        <div class="title">{{ doc.title }}</div>

        <!-- META -->
        <div class="meta">
            <a-tag color="blue">Dept: {{ doc.department_id }}</a-tag>
            <a-tag>{{ doc.status }}</a-tag>
        </div>

        <!-- ACTIONS -->
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
                    @click="openRejectModal"
                >
                    Từ chối
                </a-button>

                <a-button
                    v-if="canReturn"
                    size="small"
                    @click="emitReturn"
                >
                    ↩ Trả về
                </a-button>
            </a-space>
        </div>

        <!-- FOOTER -->
        <div class="footer">
            <span>#{{ doc.id }}</span>
        </div>

        <!-- MODAL: REJECT -->
        <a-modal
            v-model:open="rejectOpen"
            title="Từ chối hồ sơ"
            ok-text="Xác nhận"
            cancel-text="Hủy"
            @ok="confirmReject"
        >
            <a-textarea
                v-model:value="rejectReason"
                placeholder="Nhập lý do từ chối..."
                :rows="4"
            />
        </a-modal>
    </a-card>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { useUserStore } from '@/stores/user'

/* ================== PROPS & EMITS ================== */
const props = defineProps({
    doc: { type: Object, required: true },
    highlight: Boolean,
})

const emit = defineEmits(['approve', 'reject', 'return'])

/* ================== STATE ================== */
const rejectOpen = ref(false)
const rejectReason = ref('')

/* ================== STORE & ROUTER ================== */
const router = useRouter()
const userStore = useUserStore()

/* ================== PERMISSION ================== */
const canApprove = computed(() =>
    ['staff', 'manager', 'senior_manager', 'executive']
        .includes(userStore.user?.position_code)
)

const canReturn = computed(() =>
    ['manager', 'senior_manager']
        .includes(userStore.user?.position_code)
)

/* ================== ACTIONS ================== */
const goDetail = () => {
    router.push({
        name: 'workflow-task-info',
        params: { id: props.doc.id },
    })
}

const emitApprove = () => emit('approve', props.doc)

const openRejectModal = () => {
    rejectReason.value = ''
    rejectOpen.value = true
}

const confirmReject = () => {
    if (!rejectReason.value.trim()) {
        message.error('Vui lòng nhập lý do từ chối')
        return
    }

    emit('reject', {
        ...props.doc,
        comment: rejectReason.value,
    })

    rejectOpen.value = false
}

const emitReturn = () => emit('return', props.doc)
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
