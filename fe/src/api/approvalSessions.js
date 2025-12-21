import axios from 'axios'

function ensureApiBase(url) {
    const u = String(url || '').replace(/\/+$/, '')
    return /\/api$/.test(u) ? u : `${u}/api`
}

const instance = axios.create({
    baseURL: ensureApiBase(import.meta.env.VITE_API_URL),
    withCredentials: true,
})

export const createApprovalSession = (formData) => {
    return instance.post(
        '/approval-sessions',
        formData,
        { headers: { 'Content-Type': 'multipart/form-data' } }
    )
}

export const getApprovalSessionsByTask = (taskId) => {
    return instance.get(`/tasks/${taskId}/approval-sessions`)
}

export const deleteApprovalSession = (sessionId) => {
    return instance.delete(`/approval-sessions/${sessionId}`)
}

export const approveReviewer = (sessionId) => {
    return instance.post(`/approval-sessions/${sessionId}/approve`)
}

export const rejectReviewer = (sessionId, reason) => {
    const formData = new FormData()
    formData.append('reason', reason)

    return instance.post(
        `/approval-sessions/${sessionId}/reject`,
        formData
    )
}

export const updateApprovalOrder = (sessionId, reviewers) => {
    return instance.post(
        `/approval-sessions/${sessionId}/reorder-reviewers`,
        { reviewers }
    )
}

export const updateApprovalSession = (sessionId, formData) => {
    return instance.post(
        `/approval-sessions/${sessionId}/update`,
        formData,
        { headers: { 'Content-Type': 'multipart/form-data' } }
    )
}

// Lấy danh sách user dùng cho modal create + update
export const getApprovalSelectableUsers = () => {
    return instance.get(
        '/approval-sessions/selectable-users'
    )
}

export const getApprovalStatisticsByTask = (taskId) => {
    return instance.get(
        `/approval-sessions/task/${taskId}/statistics`
    )
}

// Gửi yêu cầu bỏ qua bước
export const requestSkipBiddingStep = (stepId, reason) => {
    return instance.post(
        `/bidding-steps/${stepId}/request-skip`,
        { reason }
    )
}

// Người giao việc duyệt bỏ qua bước
export const approveSkipBiddingStep = (stepId) => {
    return instance.post(
        `/bidding-steps/${stepId}/approve-skip`
    )
}

export const rejectSkipBiddingStep = (stepId, reason) => {
    const formData = new FormData()
    formData.append('reason', reason || '')

    return instance.post(
        `/bidding-steps/${stepId}/reject-skip`,
        formData
    )
}





