import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// 🔹 Lấy danh sách tất cả task
export const getTasksAPI = (params = {}) => instance.get('/tasks', { params })

// 🔹 Lấy chi tiết task theo ID
export const getTaskAPI = (id) => instance.get(`/tasks/${id}`)

// 🔹 Tạo task mới
export const createTaskAPI = (data) => instance.post('/tasks', data)

// 🔹 Cập nhật task
export const updateTaskAPI = (id, data) => instance.put(`/tasks/${id}`, data)

// 🔹 Xoá task
export const deleteTaskAPI = (id) => instance.delete(`/tasks/${id}`)

// 🔹 Hoàn thành task (nếu có route này)
export const completeTaskAPI = (id) => instance.put(`/tasks/${id}/complete`)

// 🔹 Lấy danh sách nhiệm vụ của user hiện tại
export const getMyTasksAPI = (params = {}) => instance.get('/my-tasks', { params })

// 🔹 Đính kèm file vào task
export const uploadTaskFileAPI = (taskId, formData) =>
    instance.post(`/tasks/${taskId}/files`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
    })

// 🔹 Gửi bình luận cho task
export const addTaskCommentAPI = (taskId, data) =>
    instance.post(`/tasks/${taskId}/comments`, data)

// 🔹 Lấy danh sách comment của task
export const getTaskCommentsAPI = (taskId) =>
    instance.get(`/tasks/${taskId}/comments`)
