<template>
    <a-card bordered size="small" class="approval-card">
        <a-spin :spinning="loading">
            <div class="approval-block">
                <div
                    v-for="session in sortedSessions"
                    :key="session.session_no"
                    class="session-row"
                    :class="sessionClass(session)"
                >
                    <!-- ================= HEADER ================= -->
                    <div class="session-header">
                        <div class="header-left">
                            <span class="session-title">
                                <FileDoneOutlined />
                                Phiên #{{ session.session_no }}
                            </span>

                            <a-tag
                                v-if="isLatestSession(session)"
                                color="processing"
                                class="current-tag"
                            >
                                <SyncOutlined spin />
                                PHIÊN HIỆN TẠI
                            </a-tag>
                        </div>

                        <div class="header-right">
                            <a-tag :color="session.valid ? 'success' : 'error'">
                                <CheckCircleOutlined v-if="session.valid" />
                                <CloseCircleOutlined v-else />
                                {{ session.valid ? 'HỢP LỆ' : 'KHÔNG HỢP LỆ' }}
                            </a-tag>

                            <span class="time">
                                <ClockCircleOutlined />
                                {{ session.start }} – {{ session.end }}
                            </span>

                            <!-- 🗑 XOÁ PHIÊN -->
                            <a-popconfirm
                                v-if="canDeleteSession(session)"
                                title="Bạn chắc chắn muốn xoá phiên duyệt này?"
                                ok-text="Xoá"
                                cancel-text="Huỷ"
                                ok-type="danger"
                                @confirm="deleteSession(session)"
                            >
                                <a-tooltip title="Xoá phiên duyệt">
                                    <a-button
                                        danger
                                        type="text"
                                        size="small"
                                        class="delete-session-btn"
                                    >
                                        <DeleteOutlined />
                                    </a-button>
                                </a-tooltip>
                            </a-popconfirm>
                        </div>
                    </div>

                    <!-- ================= DOCUMENTS ================= -->
                    <div class="documents">
                        <div class="section-title">
                            <PaperClipOutlined />
                            Tờ trình ({{ session.documents.length }})
                        </div>

                        <a-list
                            size="small"
                            :data-source="session.documents"
                            class="doc-list"
                        >
                            <template #renderItem="{ item }">
                                <a-list-item class="doc-item">
                                    <a-tag color="processing">{{ item.code }}</a-tag>
                                    <span class="doc-name">{{ item.name }}</span>
                                </a-list-item>
                            </template>
                        </a-list>
                    </div>

                    <!-- ================= ERROR SUMMARY ================= -->
                    <div v-if="session.detected_error" class="error-summary">
                        <a-alert
                            type="error"
                            show-icon
                            message="KẾT LUẬN DUYỆT SAI THEO NHÓM"
                        >
                            <template #description>
                                <div class="wrong-group">
                                    <div class="wrong-title">
                                        <WarningOutlined />
                                        Nhóm reviewer bị xác định duyệt sai
                                    </div>

                                    <div class="wrong-list">
                                        <a-tag
                                            v-for="name in session.detected_error.wrong_reviewer_names"
                                            :key="name"
                                            color="error"
                                        >
                                            <UserOutlined />
                                            {{ name }}
                                        </a-tag>
                                    </div>

                                    <div class="wrong-note">
                                        <InfoCircleOutlined />
                                        Phát hiện tại bước
                                        <b>#{{ session.detected_error.detected_step }}</b>,
                                        các bước trước đó thuộc nhóm duyệt sai
                                    </div>
                                </div>
                            </template>
                        </a-alert>
                    </div>

                    <!-- ================= REVIEWERS ================= -->
                    <div class="reviewers">
                        <div
                            v-for="r in session.reviewers"
                            :key="r.user_id"
                            class="reviewer-row"
                            :class="{ wrong: r.is_wrong }"
                        >
                            <div class="reviewer-left">
                                <div class="reviewer-name">
                                    <UserOutlined />
                                    {{ r.step_order }}. {{ r.name }}
                                </div>
                                <div class="reviewer-meta">
                                    {{ r.title }} · {{ r.department }}
                                </div>
                            </div>

                            <div class="reviewer-right">
                                <a-tag size="small" :color=" r.result === 'approved' ? 'success' : r.result === 'rejected' ? 'error' : 'default'">
                                    <CheckOutlined v-if="r.result === 'approved'" />
                                    <CloseOutlined v-if="r.result === 'rejected'" />
                                    {{r.result === 'approved' ? 'Đồng ý' : r.result === 'rejected' ? 'Không đồng ý' : 'Chưa duyệt' }}
                                </a-tag>

                                <span v-if="r.reviewed_at" class="review-time">
                                    <ClockCircleOutlined />
                                    {{ r.reviewed_at }}
                                </span>

                                <a-tag v-if="r.is_wrong" color="warning">
                                    <ExclamationCircleOutlined />
                                    Duyệt sai
                                </a-tag>

                                <a-tag v-if="r.is_detector" color="processing">
                                    <EyeOutlined />
                                    Người phát hiện
                                </a-tag>

                                <!-- ===== ACTION BUTTONS ===== -->
                                <template v-if="canReview(session, r)">
                                    <a-space>
                                        <a-button type="primary" size="small" @click="approve(r)">
                                            <CheckOutlined />
                                            Đồng ý
                                        </a-button>

                                        <a-popconfirm title="Bạn chắc chắn KHÔNG đồng ý?"
                                            ok-text="Xác nhận"
                                            cancel-text="Hủy"
                                            @confirm="openRejectModal(r)"
                                        >
                                            <a-button danger size="small">
                                                <CloseOutlined />
                                                Không đồng ý
                                            </a-button>
                                        </a-popconfirm>
                                    </a-space>
                                </template>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </a-spin>

        <!-- ================= REJECT MODAL ================= -->
        <a-modal
            v-model:open="rejectVisible"
            title="Không đồng ý – Nhập lý do"
            ok-text="Gửi"
            cancel-text="Hủy"
            @ok="submitReject"
        >
            <a-textarea
                v-model:value="rejectReason"
                :rows="4"
                placeholder="Nhập lý do không đồng ý..."
            />
        </a-modal>
    </a-card>
</template>


<script setup>
import {
    CheckOutlined,
    CloseOutlined,
    UserOutlined,
    ClockCircleOutlined,
    WarningOutlined,
    EyeOutlined,
    InfoCircleOutlined,
    FileDoneOutlined,
    PaperClipOutlined,
    SyncOutlined,
    CheckCircleOutlined,
    CloseCircleOutlined,
    ExclamationCircleOutlined,
    DeleteOutlined
} from '@ant-design/icons-vue'

import { ref, computed, onMounted } from 'vue'

import { getApprovalSessionsByTask, deleteApprovalSession } from '@/api/approvalSessions.js'
import {message} from "ant-design-vue";

const props = defineProps({
    taskId: {
        type: Number,
        required: true,
    },
})

const sessions = ref([])
const rejectVisible = ref(false)
const rejectReason = ref('')
const currentReviewer = ref(null)
const loading = ref(false)

const sortedSessions = computed(() =>
    [...sessions.value].sort((a, b) => b.session_no - a.session_no)
)

const isLatestSession = (session) =>
    sortedSessions.value[0]?.session_no === session.session_no

const sessionClass = (session) => ({
    'session-latest': isLatestSession(session),
    'session-valid': session.valid,
    'session-invalid': !session.valid,
})

const currentUserId = 5

const canReview = (session, reviewer) =>
    isLatestSession(session) &&
    reviewer.user_id === currentUserId &&
    !reviewer.result

const approve = (reviewer) => {
    reviewer.result = 'approved'
    reviewer.reviewed_at = 'NOW'
}

const openRejectModal = (reviewer) => {
    currentReviewer.value = reviewer
    rejectVisible.value = true
}

const submitReject = () => {
    currentReviewer.value.result = 'rejected'
    currentReviewer.value.reviewed_at = 'NOW'
    rejectVisible.value = false
}

const loadSessions = async () => {
    loading.value = true
    try {
        const { data } = await getApprovalSessionsByTask(props.taskId)
        sessions.value = data || []
    } catch (e) {
        console.error(e)
    } finally {
        loading.value = false
    }
}

const canDeleteSession = (session) => {
    return true
}


const deleteSession = async (session) => {
    try {
        loading.value = true
        await deleteApprovalSession(session.session_id || session.id)
        message.success('Đã xoá phiên duyệt')
        await loadSessions()
    } catch (e) {
        console.error(e)
        message.error('Không thể xoá phiên duyệt')
    } finally {
        loading.value = false
    }
}


defineExpose({
    reload: loadSessions
})

onMounted(loadSessions)

</script>

<style scoped>
.approval-card {
    background: #fafafa;
    min-height: 300px;
}

.approval-block {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

/* ===== SESSION ===== */
.session-row {
    border-radius: 14px;
    padding: 18px;
    background: #fff;
    border: 1px solid #e5e7eb;
}



/* ===== HEADER ===== */
.session-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
}

.header-left,
.header-right {
    display: flex;
    align-items: center;
    gap: 10px;
}

.session-title {
    font-size: 15px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 6px;
}

.time {
    font-size: 12px;
    color: #8c8c8c;
    display: flex;
    align-items: center;
    gap: 4px;
}

/* ===== SECTION TITLE ===== */
.section-title {
    font-weight: 600;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 6px;
}

/* ===== DOCUMENTS ===== */
.documents {
    margin-bottom: 14px;
}

.doc-item {
    display: flex;
    gap: 10px;
    align-items: center;
}

.doc-name {
    color: #262626;
}

/* ===== ERROR ===== */
.error-summary {
    margin-bottom: 14px;
}

.wrong-group {
    padding: 12px;
    background: #fff1f0;
    border-radius: 8px;
}

.wrong-title {
    font-weight: 600;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 6px;
}

.wrong-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 6px;
}

.wrong-note {
    font-size: 12px;
    color: #595959;
}

/* ===== REVIEWERS ===== */
.reviewers {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.reviewer-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 10px;
    border-radius: 8px;
}

.reviewer-row.wrong {
    background: #fff7e6;
}

.reviewer-left {
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.reviewer-name {
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 6px;
}

.reviewer-meta {
    font-size: 12px;
    color: #8c8c8c;
}

.reviewer-right {
    display: flex;
    align-items: center;
    gap: 8px;
}

.review-time {
    font-size: 12px;
    color: #595959;
    display: flex;
    align-items: center;
    gap: 4px;
}
/* ===== HEADER & DOCUMENT SEPARATOR ===== */
.session-header {
    padding-bottom: 12px;
    border-bottom: 1px solid #e5e7eb;
    margin-bottom: 14px;
}

.documents {
    padding-bottom: 14px;
    border-bottom: 1px solid #e5e7eb;
    margin-bottom: 14px;
}

/* ===== REVIEWER ROW ===== */
.reviewer-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 10px;
    border-bottom: 1px solid #e5e7eb;
}

.reviewer-row:last-child {
    border-bottom: none;
}

/* ===== WRONG REVIEWER ===== */
.reviewer-row.wrong {
    background: #fff7e6;
}

.reviewer-row.wrong:not(:last-child) {
    border-bottom: 1px solid #ffe7ba;
}

.delete-session-btn {
    padding: 0 6px;
    height: 28px;
}

.delete-session-btn:hover {
    background: #fff1f0;
}

</style>
