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

// 🔹 Xoá task
export const deleteTask = (id) => instance.delete(`/tasks/${id}`)

// 🔹 Hoàn thành task (nếu có route này)
export const completeTaskAPI = (id) => instance.put(`/tasks/${id}/complete`)

// 🔹 Lấy danh sách nhiệm vụ của user hiện tại
export const getMyTasksAPI = (params = {}) => instance.get('/my-tasks', { params })

// 🔹 Đính kèm file vào task
export const uploadTaskFileAPI = (taskId, formData) =>
    instance.post(`/tasks/${taskId}/files`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
    })

// 🔹 Lấy bình luận cho task
export const getComments = (task_id) =>  instance.get(`/tasks/${task_id}/comments`)

// 🔹 Gửi bình luận cho task
export const createComment = (task_id, data={}) =>  instance.post(`/tasks/${task_id}/comments`, data)

// 🔹 xóa bình luận cho task
export const deleteComment = (comment_id, data={}) =>  instance.delete(`/comments/${comment_id}`)

// 🔹 cập nhật bình luận cho task
export const updateComment = ( comment_id, data={}) =>  instance.put(`/comments/${comment_id}`, data)

// 🔹 Lấy danh sách comment của task
export const getSubTasks = (taskId) =>
    instance.get(`/tasks/${taskId}/subtasks`)
