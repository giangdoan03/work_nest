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
                                {{ formatSessionDateTime(session.created_at) }}
                            </span>


                            <!-- ✏️ CẬP NHẬT PHIÊN -->
                            <a-tooltip
                                :title="hasAnyReviewed(session)
                                    ? 'Đã có người duyệt, không thể chỉnh sửa'
                                    : 'Chỉnh sửa phiên duyệt'"
                            >
                                <span>
                                    <a-button
                                        type="text"
                                        size="small"
                                        class="edit-session-btn"
                                        :disabled="hasAnyReviewed(session)"
                                        @click="!hasAnyReviewed(session) && openUpdateSession(session)"
                                    >
                                        <EditOutlined />
                                    </a-button>
                                </span>
                            </a-tooltip>

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
                        <div class="section-title doc-header-inline">
                            <div class="doc-left">
                                <PaperClipOutlined />
                                Tờ trình ({{ session.documents.length }})
                            </div>

                            <a-tooltip title="Người trình">
                                <div class="doc-right">
                                    <UserOutlined />
                                    {{ resolveUserName(session.created_by) }}
                                </div>
                            </a-tooltip>
                        </div>


                        <a-list
                            size="small"
                            :data-source="session.documents"
                            class="doc-list"
                        >
                            <template #renderItem="{ item }">
                                <a-list-item class="doc-item">
                                    <a-tag color="processing">{{ item.code }}</a-tag>

                                    <a href="#" class="doc-link" @click.prevent="openDoc(item)">
                                        {{ item.name }}
                                    </a>

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
                    <Draggable
                        v-model="session.reviewers"
                        item-key="id"
                        handle=".reviewer-left"
                        ghost-class="reviewer-ghost"
                        animation="200"
                        :disabled="!canDrag(session)"
                        :move="checkReviewerMove"
                        @end="handleReviewerReorder(session)"
                    >
                        <template #item="{ element: r }">
                            <div class="reviewer-row" :class="{ wrong: r.is_wrong }">
                                <div class="reviewer-left">
                                    <!-- CHỈ ICON NÀY LÀ HANDLE -->
                                    <span class="drag-handle" v-if="canDrag(session)">
                                        <DragOutlined />
                                    </span>

                                    <div class="reviewer-info">
                                        <div class="reviewer-name">
                                            <UserOutlined />
                                            {{ r.step_order }}. {{ r.name }}
                                        </div>
                                        <div class="reviewer-meta">
                                            {{ r.position_name }} ·
                                            {{ resolveDepartmentName(r.department_id) }}
                                        </div>
                                    </div>
                                </div>


                                <div class="reviewer-right">
                                    <!-- ===== STATUS TAG ===== -->
                                    <a-tooltip
                                        v-if="!canReview(session, r)"
                                        :title="reviewDisabledReason(session, r)"
                                    >
                                        <a-tag
                                            size="small"
                                            :color="
                                                r.result === 'approved'
                                                    ? 'success'
                                                    : r.result === 'rejected'
                                                    ? 'error'
                                                    : 'default'
                                            "
                                        >
                                            <CheckOutlined v-if="r.result === 'approved'" />
                                            <CloseOutlined v-if="r.result === 'rejected'" />
                                            {{
                                                r.result === 'approved'
                                                    ? 'Đồng ý'
                                                    : r.result === 'rejected'
                                                        ? 'Không đồng ý'
                                                        : 'Chưa duyệt'
                                            }}
                                        </a-tag>
                                    </a-tooltip>


                                    <!-- ⏰ TIME BELOW -->
                                    <div v-if="r.reviewed_at && !canReview(session, r)" class="review-time-below">
                                        {{ formatReviewTime(r.reviewed_at) }}
                                    </div>

                                    <!-- ===== ACTION ===== -->
                                    <template v-if="canReview(session, r)">
                                        <a-space>
                                            <a-button
                                                type="primary"
                                                size="small"
                                                @click="approve(r, session)"
                                            >
                                                <CheckOutlined />
                                                Đồng ý
                                            </a-button>

                                            <a-popconfirm
                                                title="Bạn chắc chắn KHÔNG đồng ý?"
                                                ok-text="Xác nhận"
                                                cancel-text="Hủy"
                                                @confirm="openRejectModal(r, session)"
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
                        </template>
                    </Draggable>
                </div>
            </div>
        </a-spin>

        <!-- UPDATE MODAL -->
        <UploadWithUserModal
            v-if="updateSession"
            v-model:open="updateModalOpen"
            :task-id="props.taskId"
            :session-id="updateSession.session_id"
            :reviewers="updateSession.reviewers"
            :users="approvalUsers"
            :departments="departments"
            mode="update"
            @confirm="handleUpdateSuccess"
        />

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
    <!-- FULLSCREEN OVERLAY -->
    <div v-if="openingDoc" class="doc-opening-overlay">
        <a-spin size="large" />
        <div class="overlay-text">
            Đang xử lý chữ ký duyệt…<br />
            <span class="file-name">{{ openingDocName }}</span>
        </div>
    </div>

</template>

<script setup>
import {
    CheckOutlined,
    CloseOutlined,
    UserOutlined,
    ClockCircleOutlined,
    WarningOutlined,
    EditOutlined,
    InfoCircleOutlined,
    FileDoneOutlined,
    PaperClipOutlined,
    SyncOutlined,
    CheckCircleOutlined,
    CloseCircleOutlined,
    DragOutlined,
    DeleteOutlined
} from '@ant-design/icons-vue'
import Draggable from 'vuedraggable'
import { ref, computed, onMounted } from 'vue'
import { message } from 'ant-design-vue'

import {
    getApprovalSessionsByTask,
    deleteApprovalSession,
    approveReviewer,
    rejectReviewer,
    updateApprovalOrder,
    getApprovalSelectableUsers
} from '@/api/approvalSessions.js'

import { useUserStore } from '@/stores/user'
import { storeToRefs } from 'pinia'
import UploadWithUserModal from '@/components/task/UploadWithUserModal.vue'
import {replaceMarkersOnOpenAPI} from "@/api/taskFiles.js";

/* ================= USER ================= */
const userStore = useUserStore()
const { currentUser } = storeToRefs(userStore)
const currentUserId = computed(() => Number(currentUser.value?.id) || null)


import { useRoute } from 'vue-router';
const route = useRoute();
const taskId = Number(route.params.id); // /tasks/:id

/* ================= PROPS ================= */
const props = defineProps({
    taskId: { type: Number, required: true },
    users: { type: Array, default: () => [] },
    departments: { type: Array, default: () => [] }
})

/* ================= DEPARTMENT MAP ================= */
const departmentMap = computed(() => {
    const map = {}
    props.departments.forEach(d => {
        map[d.id] = d.name
    })
    return map
})


const formatReviewTime = (time) => {
    if (!time) return ''
    return new Date(time).toLocaleString('vi-VN', {
        hour: '2-digit',
        minute: '2-digit',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    })
}


const formatSessionDateTime = (time) => {
    if (!time) return ''
    return new Date(time).toLocaleString('vi-VN', {
        hour: '2-digit',
        minute: '2-digit',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    })
}

const openDoc = async (item) => {
    openingDoc.value = true
    openingDocName.value = item.name

    try {
        await replaceMarkersOnOpenAPI(taskId, item.url)
    } catch (e) {
        console.warn('Replace marker skipped', e)
    } finally {
        // ✅ Mở file sau khi xử lý xong (hoặc fail)
        window.open(item.url, '_blank', 'noopener')

        // ⏳ delay nhẹ cho mượt UX
        setTimeout(() => {
            openingDoc.value = false
            openingDocName.value = ''
        }, 300)
    }
}



const resolveDepartmentName = (departmentId) => {
    return departmentMap.value[departmentId] ?? 'Chưa phân phòng'
}

/* ================= STATE ================= */
const sessions = ref([])
const approvalUsers = ref([])
const loading = ref(false)

const rejectVisible = ref(false)
const rejectReason = ref('')
const currentReviewer = ref(null)
const currentSession = ref(null)

const updateModalOpen = ref(false)
const updateSession = ref(null)

const openingDoc = ref(false)
const openingDocName = ref('')

/* ================= COMPUTED ================= */
const sortedSessions = computed(() =>
    [...sessions.value].sort((a, b) => b.session_no - a.session_no)
)

const isLatestSession = (session) =>
    sortedSessions.value[0]?.session_no === session.session_no

const sessionClass = (session) => ({
    'session-latest': isLatestSession(session),
    'session-valid': session.valid,
    'session-invalid': !session.valid
})

/* ================= ACTIONS ================= */
const openUpdateSession = (session) => {
    updateSession.value = {
        ...session,
        reviewers: session.reviewers.map(r => ({ ...r }))
    }
    updateModalOpen.value = true
}

const hasAnyReviewed = (session) =>
    session.reviewers.some(r => r.result !== 'pending')

const handleUpdateSuccess = async () => {
    updateModalOpen.value = false
    await loadSessions()
}

const canReview = (session, reviewer) => {
    if (!isLatestSession(session)) return false

    // 1️⃣ Chỉ đúng user
    if (reviewer.user_id !== currentUserId.value) return false

    // 2️⃣ Chỉ khi pending
    if (reviewer.result !== 'pending') return false

    // 3️⃣ Check thứ tự duyệt
    const previousNotApproved = session.reviewers.some(r =>
        r.step_order < reviewer.step_order &&
        r.result !== 'approved'
    )

    // Giám đốc (level 4) bỏ qua thứ tự
    if (reviewer.level < 4 && previousNotApproved) {
        return false
    }

    return true
}


const reviewDisabledReason = (session, reviewer) => {
    if (reviewer.user_id !== currentUserId.value)
        return 'Không phải lượt của bạn'

    const previousNotApproved = session.reviewers.some(r =>
        r.step_order < reviewer.step_order &&
        r.result !== 'approved'
    )

    if (previousNotApproved)
        return 'Chưa tới lượt duyệt'

    return ''
}

const resolveUserName = (userId) => {
    if (!userId) return '—'
    const u = approvalUsers.value.find(u => Number(u.id) === Number(userId))
    return u?.name || `#${userId}`
}

const openRejectModal = (reviewer, session) => {
    currentReviewer.value = reviewer
    currentSession.value = session
    rejectVisible.value = true
}

const approve = async (reviewer, session) => {
    try {
        loading.value = true
        await approveReviewer(
            session.session_id,
            reviewer.department_id
        )
        message.success('Đã duyệt')
        await loadSessions()
    } catch (err) {
        const msg =
            err?.response?.data?.messages?.error ||
            err?.response?.data?.message ||
            'Không thể duyệt'
        message.warning(msg)
    } finally {
        loading.value = false
    }
}



const submitReject = async () => {
    try {
        loading.value = true
        await rejectReviewer(
            currentSession.value.session_id,
            rejectReason.value
        )
        message.success('Đã từ chối')
        rejectVisible.value = false
        rejectReason.value = ''
        await loadSessions()
    } catch {
        message.error('Không thể từ chối')
    } finally {
        loading.value = false
    }
}


const isSessionCreator = (session) => {
    return session.created_by === currentUserId.value
}


const canDrag = (session) => {
    // chỉ creator mới kéo được
    return isSessionCreator(session)
}


const checkReviewerMove = () => true

const handleReviewerReorder = async (session) => {
    session.reviewers.forEach((r, index) => {
        r.step_order = index + 1
    })

    const payload = session.reviewers.map((r, index) => ({
        id: r.id,
        approval_order: index + 1
    }))

    try {
        await updateApprovalOrder(session.session_id, payload)
        message.success('Đã cập nhật thứ tự duyệt')
    } catch {
        message.error('Không thể cập nhật thứ tự')
        await loadSessions()
    }
}

const canDeleteSession = () => true

const deleteSession = async (session) => {
    try {
        loading.value = true
        await deleteApprovalSession(session.session_id || session.id)
        message.success('Đã xoá phiên duyệt')
        await loadSessions()
    } catch {
        message.error('Không thể xoá phiên duyệt')
    } finally {
        loading.value = false
    }
}

/* ================= LOAD ================= */
const loadApprovalUsers = async () => {
    const res = await getApprovalSelectableUsers()
    approvalUsers.value = res.data.users
}

const loadSessions = async () => {
    loading.value = true
    try {
        const { data } = await getApprovalSessionsByTask(props.taskId)
        sessions.value = data || []
    } finally {
        loading.value = false
    }
}

onMounted(() => {
    loadApprovalUsers()
    loadSessions()
})

defineExpose({ reload: loadSessions })
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
}

.reviewer-row.wrong {
    background: #fff7e6;
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
    flex-wrap: wrap;   /* 👈 BẮT BUỘC */
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
.doc-link {
    color: #1677ff;
    cursor: pointer;
    text-decoration: none;
    font-weight: 500;
}

.doc-link:hover {
    text-decoration: underline;
}

.reviewer-left {
    display: flex;
    gap: 8px;
}

.edit-session-btn {
    padding: 0 6px;
    height: 28px;
}

.edit-session-btn:hover {
    background: #f0f5ff;
}
.edit-session-btn[disabled] {
    color: #bfbfbf;
    cursor: not-allowed;
}
.review-time-below {
    margin-top: 2px;
    font-size: 11px;
    color: #8c8c8c;
    line-height: 1.2;
}
.doc-opening-overlay {
    position: fixed;
    inset: 0;
    z-index: 9999;
    background: rgba(255, 255, 255, 0.85);

    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: 16px;
}

.overlay-text {
    font-size: 14px;
    color: #595959;
    text-align: center;
}

.file-name {
    font-weight: 600;
    color: #262626;
}
.doc-header-inline {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.doc-left {
    display: flex;
    align-items: center;
    gap: 6px;
    font-weight: 600;
}

.doc-right {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: #595959;
}

</style>
