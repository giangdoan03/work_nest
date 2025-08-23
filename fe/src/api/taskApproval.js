import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

/**
 * 🔹 Lấy danh sách nhiệm vụ cần duyệt (theo user hiện tại)
 * @param {Object} params - pagination/filter options (page, limit,...)
 */
export const getTaskApprovals = (params = {}) =>
    instance.get('/task-approvals', { params })

/**
 * 🔹 Phê duyệt nhiệm vụ tại cấp duyệt hiện tại
 * @param {number|string} approvalId
 * @param {Object} data - Dữ liệu bổ sung, ví dụ { comment: '...' }
 */
export const approveTaskAPI = (approvalId, data = {}) =>
    instance.post(`/task-approvals/${approvalId}/approve`, data)

/**
 * 🔹 Từ chối duyệt nhiệm vụ
 * @param {number|string} approvalId
 * @param {Object} data - Dữ liệu bổ sung, ví dụ { comment: '...' }
 */
export const rejectTaskAPI = (approvalId, data = {}) =>
    instance.post(`/task-approvals/${approvalId}/reject`, data)

/**
 * 🔹 Lấy lịch sử duyệt của một task (log các cấp đã duyệt)
 * @param {number|string} taskId
 */
export const getApprovalHistoryByTask = (taskId) =>
    instance.get(`/tasks/${taskId}/approvals`)

/**
 * 🔹 Lấy trạng thái duyệt đầy đủ theo từng cấp
 * @param {number|string} taskId
 */
export const getFullApprovalStatus = (taskId) =>
    instance.get(`/task-approvals/full-status/${taskId}`)

/**
 * 🔹 Kiểm tra quyền trước khi mở modal duyệt / từ chối
 * @param {number|string} id - id của task_approval
 */
export const canActApprovalAPI = (id) =>
    instance.get(`/task-approvals/${id}/can-act`)

/**
 * 🔹 (Optional) Lấy danh sách approvers theo cấp duyệt
 * @param {number|string} taskId
 * @param {number} level
 */
export const getApproversByLevelAPI = (taskId, level) =>
    instance.get(`/tasks/${taskId}/approvers`, { params: { level } })
