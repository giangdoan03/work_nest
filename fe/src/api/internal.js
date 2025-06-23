import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})

// nhiệm vụ cá nhân Task
export const getTasks = (data) => 
    instance.get('/tasks', { params: data })

export const createTask = (data) =>
    instance.post(`/tasks`, data)

export const updateTask= (taskId, data) =>
    instance.put(`/tasks/${taskId}`, data)

export const deleteTask= (taskId) =>
    instance.delete(`/tasks/${taskId}`)

export const getTaskDetail = (taskId) =>
    instance.get(`/tasks/${taskId}`, { params: { task_id: taskId } })

// API SUB task
export const getSubTasks = (taskId) =>
    instance.get(`/tasks/${taskId}/subtasks`)




