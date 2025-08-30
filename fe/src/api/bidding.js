import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// API bidding
export const getBiddingsAPI = (params = {}) => instance.get('/biddings', { params })
export const getBiddingAPI = (id) => instance.get(`/biddings/${id}`)
export const createBiddingAPI = (data) => instance.post('/biddings', data)
export const updateBiddingAPI = (id, data) => instance.put(`/biddings/${id}`, data)
export const deleteBiddingAPI = (id) => instance.delete(`/biddings/${id}`)
export const cloneFromTemplatesAPI = (biddingId) => instance.post(`/biddings/${biddingId}/init-steps`)

// Lấy danh sách bước theo bidding_id
export const getBiddingStepsAPI = (biddingId) => instance.get(`/bidding-steps`, { params: { bidding_id: biddingId } })

// Cập nhật trạng thái bước
export const updateBiddingStepAPI = (stepId, data) => instance.put(`/bidding-steps/${stepId}`, data)

export const completeBiddingStepAPI = (stepId) => instance.put(`/bidding-steps/${stepId}/complete`)

export const canMarkBiddingAsCompleteAPI = (biddingId) => instance.get(`/biddings/${biddingId}/can-complete`)

// === Phê duyệt gói thầu (multi-level) ===

// Gửi gói thầu đi phê duyệt (có danh sách approverIds)
export const sendBiddingForApprovalAPI = (biddingId, approverIds = []) =>
    instance.post(`/biddings/${biddingId}/send-approval`, { approver_ids: approverIds })

// Approve cấp hiện tại
export const approveBiddingAPI = (biddingId, note = null) =>
    instance.post(`/biddings/${biddingId}/approve`, { note })

// Reject cấp hiện tại
export const rejectBiddingAPI = (biddingId, note = null) =>
    instance.post(`/biddings/${biddingId}/reject`, { note })


export const updateApprovalStepsAPI = (id, approverIds) =>
    instance.put(`/biddings/${id}/approval-steps`, { approver_ids: approverIds })

// 👇 Alias để FE cũ gọi vẫn chạy
export const getBiddingProcessAPI = (biddingId) =>
    instance.get(`/bidding-steps`, { params: { bidding_id: biddingId } })

// Lấy 20 bước của 1 gói thầu (ưu tiên dùng)
export const getBiddingStepsByBiddingIdAPI = (biddingId, { withTasks = 1 } = {}) =>
    instance.get(`/biddings/${biddingId}/steps`, { params: { with_tasks: withTasks ? 1 : 0 } })




