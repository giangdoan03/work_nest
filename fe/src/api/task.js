import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// 🔹 Lấy danh sách tất cả task
export const getTasks = (params = {}) => instance.get('/tasks', { params })

// 🔹 Lấy chi tiết task theo ID
export const getTaskDetail = (id) => instance.get(`/tasks/${id}`)

// 🔹 Tạo task mới
export const createTask = (data) => instance.post('/tasks', data)

// 🔹 Cập nhật task
export const updateTask = (id, data) => instance.put(`/tasks/${id}`, data)

// 🔹 Lấy danh sách task theo step của bidding
export const getTasksByBiddingStep = (biddingStepId, params = {}) =>
    instance.get(`/bidding-steps/${biddingStepId}/tasks`, { params })


// 🔹 Lấy danh sách task theo step của contract
export const getTasksByContractStep = (contractStepId, params = {}) =>
    instance.get(`/contract-steps/${contractStepId}/tasks`, { params })

// 🔹 Xoá task
export const deleteTask = (id) => instance.delete(`/tasks/${id}`)

// 🔹 Hoàn thành task (nếu có route này)
export const completeTaskAPI = (id) => instance.put(`/tasks/${id}/complete`)

// 🔹 Lấy danh sách nhiệm vụ của user hiện tại
export const getMyTasksAPI = (params = {}) => instance.get('/my-tasks', { params })

// 🔹 Đính kèm file vào task
export const uploadTaskFileAPI = (taskId, formData) =>
    instance.post(`/tasks/${taskId}/upload-file`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
    })

/**
 * 🔹 Upload link tài liệu cho task
 * @param {number|string} taskId
 * @param {Object} data - { title, url, user_id }
 */
export const uploadTaskLinkAPI = (taskId, data) =>
    instance.post(`/tasks/${taskId}/files/link`, data, {
        headers: { 'Content-Type': 'multipart/form-data' }
    })

// 🔹 Lấy bình luận cho task
export const getComments = (task_id, data={}) =>  instance.get(`/tasks/${task_id}/comments`, {params: data})

// 🔹 Gửi bình luận cho task
export const createComment = (task_id, data={}) =>  instance.post(`/tasks/${task_id}/comments`, data)

// 🔹 xóa bình luận cho task
export const deleteComment = (comment_id, data={}) =>  instance.delete(`/comments/${comment_id}`)

// 🔹 cập nhật bình luận cho task
export const updateComment = ( comment_id, data={}) =>  instance.put(`/comments/${comment_id}`, data)

// 🔹 Lấy danh sách comment của task
export const getSubTasks = (taskId) =>
    instance.get(`/tasks/${taskId}/subtasks`)

// 🔹 Lấy file đính kèm của task
export const getTaskFilesAPI = (taskId) => instance.get(`/tasks/${taskId}/files`)

// 🔹 Xoá file đính kèm của task
export const deleteTaskFilesAPI = (taskId) => instance.delete(`/task-files/${taskId}`)


// 🔹 Gia hạn deadline cho task
export const extendTaskDeadlineAPI = (taskId, data) =>
    instance.post(`/tasks/${taskId}/extend`, data)

// 🔹 Đếm số lần user hiện tại đã gia hạn task
export const countTaskExtensionsAPI = (taskId) =>
    instance.get(`/tasks/${taskId}/extensions/count`)

// 🔹 Lấy lịch sử gia hạn deadline của task
export const getTaskExtensions = (taskId) =>
    instance.get(`/tasks/${taskId}/extensions`);



// 🔔 Inbox bình luận của tôi
export const getMyRecentCommentsAPI = (params = {}) =>
    instance.get('/my/comments', { params });

export const getMyUnreadCommentsCountAPI = (userId) =>
    instance.get('/my/comments/unread-count', { params: { user_id: userId } });

export const markCommentsReadAPI = (userId, commentIds = []) =>
    instance.post('/comments/mark-read', { user_id: userId, comment_ids: commentIds });

export const markCommentReadAPI = (commentId, userId) =>
    instance.post(`/comments/${commentId}/read`, { user_id: userId });

export const sendTaskForApprovalAPI = (taskId, approverIds) =>
    instance.post(`/tasks/${taskId}/approvals/send`, { approver_ids: approverIds })

/**
 * Cập nhật danh sách người duyệt & reset về cấp 1 khi đang pending
 * @param {number|string} taskId
 * @param {number[]} approverIds
 */
export const updateTaskApprovalStepsAPI = (taskId, approverIds) =>
    instance.put(`/tasks/${taskId}/approvals/steps`, { approver_ids: approverIds })




