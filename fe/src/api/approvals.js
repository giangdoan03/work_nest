import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

// 🔹 Lấy danh sách instance theo bộ lọc (?target_type, ?target_id, ?status…)
export const getApprovals = (params = {}) =>
    instance.get('/approvals', { params })

// 🔹 Danh sách nhiệm vụ cần duyệt của user hiện tại
export const getApprovalInbox = (params = {}) =>
    instance.get('/approvals/inbox', { params })

// 🔹 Xem chi tiết một phiên duyệt
export const getApproval = (id) =>
    instance.get(`/approvals/${id}`)

// 🔹 Gửi duyệt (tạo mới phiên)
export const sendApproval = (data) =>
    instance.post('/approvals/send', data)
// data = { target_type: 'bidding', target_id: 123, approver_ids: [5,8] }

// 🔹 Phê duyệt / từ chối
export const approveApproval = (id, data = {}) =>
    instance.post(`/approvals/${id}/approve`, data)

export const rejectApproval = (id, data = {}) =>
    instance.post(`/approvals/${id}/reject`, data)

// 🔹 Cập nhật lại danh sách người duyệt
export const updateApprovalSteps = (id, data) =>
    instance.put(`/approvals/${id}/steps`, data)

export const listApprovals = (params = {}) =>
    instance.get('/approvals/list', { params })



export const getApprovalInboxAPI = (params={}) =>
    instance.get('/my/approvals', { params })

export const getApprovalUnreadCountAPI = () =>
    instance.get('/my/approvals/unread-count')

export const markApprovalReadAPI = (stepIds=[]) =>
    instance.post('/approvals/mark-read', { step_ids: stepIds })




export default {
    getApprovals,
    getApprovalInbox,
    getApproval,
    sendApproval,
    approveApproval,
    rejectApproval,
    updateApprovalSteps,
    listApprovals
}
