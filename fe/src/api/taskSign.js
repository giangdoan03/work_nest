import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

/**
 * Ký tài liệu — auto detect user trong session
 * body: { task_id, note, signature_marker? }
 */
export const signTaskAPI = (data) =>
    instance.post('/tasks/sign', data)

/**
 * Ký trực tiếp theo taskId
 * body: { note, signature_marker? }
 */
export const signTaskByIdAPI = (taskId, data = {}) =>
    instance.post(`/tasks/${taskId}/sign`, data)

/**
 * Lấy trạng thái ký của task
 */
export const getTaskSignStatusAPI = (taskId) =>
    instance.get(`/tasks/${taskId}/sign-status`)

/**
 * Lịch sử ký của task
 */
export const getTaskSignHistoryAPI = (taskId) =>
    instance.get(`/tasks/${taskId}/sign-history`)

/**
 * Upload file PDF đã ký thủ công
 * data: FormData { file: File }
 */
export const uploadSignedFileAPI = (taskId, formData) =>
    instance.post(`/tasks/${taskId}/sign/upload`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
    })

/**
 * Tải file đã ký
 */
export const downloadSignedFileAPI = (taskId) =>
    instance.get(`/tasks/${taskId}/sign/download`, {
        responseType: 'blob'
    })
