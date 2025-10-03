// src/api/taskFiles.js
import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

/** ===============================
 *  Task Files API
 *  ===============================
 *  BE routes:
 *  - POST   /tasks/:taskId/upload-file            -> uploadTaskFile
 *  - POST   /tasks/:taskId/files/link             -> uploadTaskFileLink
 *  - GET    /tasks/:taskId/files                  -> getTaskFiles
 *  - POST   /task-files/:id/update-meta           -> updateTaskFileMeta
 *  - POST   /task-files/:id/replace-file          -> replaceTaskFile
 *  - POST   /task-files/:id/approve               -> approveTaskFile
 *  - POST   /task-files/:id/reject                -> rejectTaskFile
 *  - GET    /task-files/:id/download              -> (URL tải file)
 *  - DELETE /task-files/:id                       -> deleteTaskFile
 */

/** Lấy danh sách tài liệu của 1 task */
export const getTaskFiles = (taskId, params = {}) =>
    instance.get(`/tasks/${taskId}/files`, { params })
export const getTaskFilesAPI = (taskId, params = {}) => getTaskFiles(taskId, params)

/** Upload 1 file vào task (FormData: file, title, user_id) */
export const uploadTaskFile = (taskId, formData) =>
    instance.post(`/tasks/${taskId}/upload-file`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
    })
export const uploadTaskFileAPI = (taskId, formData) => uploadTaskFile(taskId, formData)

/** Lưu link tài liệu cho task (JSON: { title, url, user_id }) */
export const uploadTaskFileLink = (taskId, payload) =>
    instance.post(`/tasks/${taskId}/files/link`, payload)
export const uploadTaskFileLinkAPI = (taskId, payload) => uploadTaskFileLink(taskId, payload)

/** Cập nhật meta (title, link_url nếu là link) – chỉ khi chưa approved */
export const updateTaskFileMeta = (fileId, payload) =>
    instance.post(`/task-files/${fileId}/update-meta`, payload)
export const updateTaskFileMetaAPI = (fileId, payload) => updateTaskFileMeta(fileId, payload)

/** Thay file vật lý – chỉ khi chưa approved (FormData: file) */
export const replaceTaskFile = (fileId, formData) =>
    instance.post(`/task-files/${fileId}/replace-file`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
    })
export const replaceTaskFileAPI = (fileId, formData) => replaceTaskFile(fileId, formData)

/** Duyệt tài liệu */
export const approveTaskFile = (fileId, data = {}) =>
    instance.post(`/task-files/${fileId}/approve`, data)
export const approveTaskFileAPI = (fileId, data = {}) => approveTaskFile(fileId, data)

/** Từ chối tài liệu (note tuỳ chọn) */
export const rejectTaskFile = (fileId, data = {}) =>
    instance.post(`/task-files/${fileId}/reject`, data)
export const rejectTaskFileAPI = (fileId, data = {}) => rejectTaskFile(fileId, data)

/** Xoá tài liệu – BE chặn nếu đã approved (403) */
export const deleteTaskFile = (fileId) =>
    instance.delete(`/task-files/${fileId}`)
export const deleteTaskFilesAPI = (fileId) => deleteTaskFile(fileId)

/** Lấy URL tải xuống trực tiếp (dùng cho <a href> / window.open) */
export const getTaskFileDownloadUrl = (fileId) =>
    `${import.meta.env.VITE_API_URL}/task-files/${fileId}/download`

export default {
    // list & upload
    getTaskFiles,
    getTaskFilesAPI,
    uploadTaskFile,
    uploadTaskFileAPI,
    uploadTaskFileLink,
    uploadTaskFileLinkAPI,

    // item actions
    updateTaskFileMeta,
    updateTaskFileMetaAPI,
    replaceTaskFile,
    replaceTaskFileAPI,
    approveTaskFile,
    approveTaskFileAPI,
    rejectTaskFile,
    rejectTaskFileAPI,
    deleteTaskFile,
    deleteTaskFilesAPI,

    // helpers
    getTaskFileDownloadUrl,
}
