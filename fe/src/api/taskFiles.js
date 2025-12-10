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
// export const uploadTaskFileLinkAPI = (taskId, payload) => uploadTaskFileLink(taskId, payload)

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

export const getPinnedFilesAPI = (taskId) =>
    instance.get(`/tasks/${taskId}/pinned-files`)

export const pinTaskFileAPI = (fileId, payload = {}) =>
    instance.post(`/task-files/${fileId}/pin`, payload)

export const unpinTaskFileAPI = (fileId, payload = {}) =>
    instance.post(`/task-files/${fileId}/unpin`, payload)

// src/api/taskFiles.js
// Gửi link tài liệu bằng FormData
export const uploadTaskFileLinkAPI = (taskId, payload) => {
    const fd = new FormData()
    fd.append('title', payload.title)
    fd.append('url', payload.url)
    fd.append('user_id', String(payload.user_id))
    return instance.post(`/tasks/${taskId}/files/link`, fd) // <-- FormData
}

// Nhận file nội bộ vào task_files (adopt) bằng FormData
export const adoptTaskFileFromPathAPI = (taskId, payload) => {
    const fd = new FormData()
    fd.append('task_id', String(payload.task_id))   // đảm bảo truyền task_id
    fd.append('user_id', String(payload.user_id))
    fd.append('file_path', payload.file_path)
    if (payload.file_name) fd.append('file_name', payload.file_name)
    return instance.post(`/tasks/${taskId}/files/adopt`, fd) // <-- FormData
}


export const getMyPendingFilesAPI = (params = {}) =>
    instance.get('/document-approvals/inbox-files', { params })

export const getMyResolvedFilesAPI = (params = {}) =>
    instance.get('/document-approvals/resolved-files-by-me', { params })

export function getCommentFilesByTask(taskId) {
    return instance.get(`/tasks/${taskId}/comment-files`)
}
// src/api/taskFiles.js (hoặc api riêng cho comments)
export function sendCommentApproval(commentId, payload) {
    // payload: { user_id: number, approver_ids: number[], note?: string }
    return instance.post(`/comments/${commentId}/send-approval`, payload, {
        headers: { 'Content-Type': 'application/json' }
    })
}

export const actOnApprovalAPI = (approvalId, payload) =>
    instance.post(`/document-approvals/${approvalId}/act`, {
        action: payload.action,          // 'approve' | 'reject'  (lowercase)
        comment: payload.comment || '',
        // có thể thêm pos_row, pos_index, order_index nếu BE cần
    })


// DELETE document (bảng documents)
export const deleteDocumentAPI = (documentId) =>
    instance.delete(`/documents/${documentId}`)

// DELETE task file (bảng task_files) — bạn đã có deleteTaskFile, alias:
export const deleteTaskFileAPI = (fileId) =>
    instance.delete(`/task-files/${fileId}`)

// DELETE comment (bảng task_comments)
export const deleteCommentAPI = (commentId) =>
    instance.delete(`/comments/${commentId}`)

// xử lý preferred_marker trong file Google Docs/Sheets
export function replaceMarkerInTaskFile(taskId, userId, departmentId) {
    return instance.post(`/marker/replace`, {
        task_id: taskId,
        user_id: userId,
        department_id: departmentId ?? null, // ⭐ gửi nếu có
    });
}

// 🔥 API xoá hàng loạt tài liệu Office
export function bulkDeleteDocuments(payload) {
    return instance.post('/documents/bulk-delete', payload);
}



export default {
    // list & upload
    getTaskFiles,
    getTaskFilesAPI,
    uploadTaskFile,
    uploadTaskFileAPI,
    uploadTaskFileLink,
    uploadTaskFileLinkAPI,
    getCommentFilesByTask,
    sendCommentApproval,
    actOnApprovalAPI,

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
    getPinnedFilesAPI,
    pinTaskFileAPI,
    unpinTaskFileAPI,
    adoptTaskFileFromPathAPI,

    getMyPendingFilesAPI,
    getMyResolvedFilesAPI,
    replaceMarkerInTaskFile,
    bulkDeleteDocuments
}
