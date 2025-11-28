// src/api/documentApprovals.js
import axios from 'axios'

// Nếu VITE_API_URL KHÔNG có /api ở cuối, tự nối thêm:
function ensureApiBase(url) {
    const u = String(url || '').replace(/\/+$/, '')
    return /\/api$/.test(u) ? u : `${u}/api`
}

const instance = axios.create({
    baseURL: ensureApiBase(import.meta.env.VITE_API_URL),
    withCredentials: true,
})

/* ================== APPROVALS (cũ) ================== */
export const getApprovals = (params = {}) =>
    instance.get('/approvals', {params})

export const getApprovalInbox = (params = {}) =>
    instance.get('/approvals/inbox', {params})

export const getApproval = (id) =>
    instance.get(`/approvals/${id}`)

export const sendApproval = async (payload) => {
    const res = await instance.post('/document-approvals/request', payload, {
        validateStatus: (s) => (s >= 200 && s < 300) || s === 409 || s === 422 || s === 201,
    })
    return {ok: res.status >= 200 && res.status < 300, status: res.status, data: res.data}
}


export const getActiveApproval = async (target_type, target_id) => {
    const {data} = await instance.get('/approvals/active-by-target', {params: {target_type, target_id}})
    const inst = data?.instance || null
    return {status: inst?.status || null, instanceId: inst?.id ?? null}
}

export const approveApproval = (id, data = {}) =>
    instance.post(`/approvals/${id}/approve`, data)

export const rejectApproval = (id, data = {}) =>
    instance.post(`/approvals/${id}/reject`, data)

export const updateApprovalSteps = (id, data) =>
    instance.put(`/approvals/${id}/steps`, data)

export const listApprovals = (params = {}) =>
    instance.get('/approvals/list', {params})

export const getApprovalInboxAPI = (params = {}) =>
    instance.get('/my/approvals', {params})

export const getApprovalUnreadCountAPI = () =>
    instance.get('/my/approvals/unread-count')

export const markApprovalReadAPI = (stepIds = []) =>
    instance.post('/approvals/mark-read', {step_ids: stepIds})

/* ================== DOCUMENT APPROVALS (mới) ================== */

// Lấy danh sách tài liệu theo phòng ban (UI list)
export const getDocumentsByDepartment = (params = {}) =>
    instance.get('/documents/by-department', {params})

// Gửi duyệt tài liệu
export const sendDocumentApproval = async (payload) => {
    // payload: { document_id, approver_ids: [], note? }
    const res = await instance.post('/document-approvals/send', payload, {
        validateStatus: (s) => (s >= 200 && s < 300) || s === 409 || s === 422,
    })
    return {ok: res.status >= 200 && res.status < 300, status: res.status, data: res.data}
}

// Duyệt cấp hiện tại
export const approveDocumentApproval = (id) =>
    instance.post(`/document-approvals/${id}/sign`)
// data gợi ý: { comment?, signature_url?, signed_pdf_url?, pos_row?, pos_index?, order_index? }

// Từ chối cấp hiện tại
export const rejectDocumentApproval = (instanceId, data = {}) =>
    instance.post(`/document-approvals/${instanceId}/reject`, data)
// data gợi ý: { comment? }

// Lấy các phiên duyệt theo document_id
export const getDocumentApprovalsByDoc = (document_id) =>
    instance.get('/document-approvals', {params: {document_id}})

// Lấy phiên active của 1 tài liệu
export const getActiveDocumentApproval = async (document_id) => {
    const {data} = await instance.get('/document-approvals/active-by-document', {
        params: {document_id},
        validateStatus: (s) => s >= 200 && s < 300,
    })
    const inst = data?.instance || null
    return {status: inst?.status || null, instanceId: inst?.id ?? null}
}

// (Tuỳ chọn) Upload file PDF đã chèn chữ ký -> trả URL
export const uploadSignedPdf = async (blob, filename = 'signed.pdf') => {
    const fd = new FormData()
    fd.append('file', blob, filename)
    // Đổi endpoint theo server upload bạn dùng
    const {data} = await instance.post('/uploads/pdf', fd, {
        headers: {'Content-Type': 'multipart/form-data'},
    })
    return data?.url
}

// ✅ Lấy danh sách phiên duyệt hoặc chi tiết phiên duyệt
export const getApprovalDetail = (approvalId) =>
    instance.get(`/document-approvals/${approvalId}`)

export const getApprovalsByDocument = (documentId) =>
    instance.get('/document-approvals', {params: {document_id: documentId}})

// ✅ Lấy instance_id active của 1 document (dùng cùng axios instance)
export const fetchActiveInstanceId = async (documentId) => {
    try {
        const {data} = await instance.get('/document-approvals/active-by-document', {
            params: {document_id: documentId},
            validateStatus: (s) => s >= 200 && s < 300,
        })

        return data?.instance?.id ?? null
    } catch (err) {
        console.error('fetchActiveInstanceId error:', err)
        return null
    }
}

// 🔥 Convert file Google Drive → PDF
export function replaceMarkerInTaskFile(taskId, userId) {
    return instance.post(`/marker/replace`, {
        task_id: taskId,   // ✔ Gửi task_id
        user_id: userId    // ✔ Gửi user_id
    });
}




// Export default gộp, tiện import *
export default {
    getApprovals,
    getApprovalInbox,
    getApproval,
    sendApproval,
    approveApproval,
    rejectApproval,
    updateApprovalSteps,
    listApprovals,
    getApprovalInboxAPI,
    getApprovalUnreadCountAPI,
    markApprovalReadAPI,

    getDocumentsByDepartment,
    sendDocumentApproval,
    approveDocumentApproval,
    rejectDocumentApproval,
    getDocumentApprovalsByDoc,
    getActiveDocumentApproval,
    uploadSignedPdf,
    getApprovalDetail,
    getApprovalsByDocument,
    convertDriveToPdfAPI
}
