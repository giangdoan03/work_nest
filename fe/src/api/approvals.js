import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

// 🔹 Lấy danh sách instance theo bộ lọc (?target_type, ?target_id, ?status…)
export const getApprovals = (params = {}) =>
    instance.get('/approvals', {params})

// 🔹 Danh sách nhiệm vụ cần duyệt của user hiện tại
export const getApprovalInbox = (params = {}) =>
    instance.get('/approvals/inbox', {params})

// 🔹 Xem chi tiết một phiên duyệt
export const getApproval = (id) =>
    instance.get(`/approvals/${id}`)

// 🔹 Gửi duyệt (tạo mới phiên)
export const sendApproval = async (payload) => {
    const res = await instance.post('/approvals/send', payload, {
        validateStatus: s => (s >= 200 && s < 300) || s === 409 || s === 422
    });
    return { ok: res.status >= 200 && res.status < 300, status: res.status, data: res.data };
};

export const getActiveApproval = async (target_type, target_id) => {
    const { data } = await instance.get('/approvals/active-by-target', {
        params: { target_type, target_id }
    })
    const inst = data?.instance || null
    return {
        status: inst?.status || null,             // 'pending' | 'approved' | 'rejected' | null
        instanceId: inst?.id ?? null
    }
}



// 🔹 Phê duyệt / từ chối
export const approveApproval = (id, data = {}) =>
    instance.post(`/approvals/${id}/approve`, data)

export const rejectApproval = (id, data = {}) =>
    instance.post(`/approvals/${id}/reject`, data)

// 🔹 Cập nhật lại danh sách người duyệt
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


/* ====================== DOCUMENT APPROVALS (mới) ====================== */

/** Lấy danh sách tài liệu theo phòng ban (phục vụ UI list) */
export const getDocumentsByDepartment = (params = {}) =>
    instance.get('/documents/by-department', { params })
// params gợi ý: { department_id?: number, search?: string }

/** Gửi duyệt 1 tài liệu (chọn sẵn danh sách người duyệt theo THỨ TỰ) */
export const sendDocumentApproval = async (payload) => {
    // payload: { document_id: number, approver_ids: number[] }
    const res = await instance.post('/document-approvals/send', payload, {
        validateStatus: s => (s >= 200 && s < 300) || s === 409 || s === 422
    })
    return {
        ok: res.status >= 200 && res.status < 300,
        status: res.status,
        data: res.data
    }
}

/** Duyệt cấp hiện tại của phiên duyệt tài liệu */
export const approveDocumentApproval = (instanceId, data = {}) =>
    instance.post(`/document-approvals/${instanceId}/approve`, data)
// data: { note?: string }

/** Từ chối cấp hiện tại của phiên duyệt tài liệu */
export const rejectDocumentApproval = (instanceId, data = {}) =>
    instance.post(`/document-approvals/${instanceId}/reject`, data)
// data: { note?: string }

/**
 * Chốt duyệt sau khi client đã "chèn block & tải xuống" (offline)
 * Lưu metadata: số văn bản, người ký, hash trước/sau… để audit/báo cáo
 */
export const finalizeDocumentApproval = (payload) =>
    instance.post('/document-approvals/finalize', payload)
// payload: {
//   document_id: number,
//   approval_instance_id?: number,
//   doc_no: string,
//   signer_name: string,
//   note?: string,
//   hash_before: string,
//   hash_after: string
// }

/* ====================== OPTIONAL tiện ích ====================== */

/** Lấy phiên active theo tài liệu (nếu bạn cần hiển thị trạng thái nhanh) */
export const getActiveDocumentApproval = async (document_id) => {
    const { data } = await instance.get('/approvals/active-by-target', {
        params: { target_type: 'document', target_id: document_id }
    })
    const inst = data?.instance || null
    return {
        status: inst?.status || null,   // 'pending' | 'approved' | 'rejected' | null
        instanceId: inst?.id ?? null
    }
}



export default {
    getApprovals,
    getApprovalInbox,
    getApproval,
    sendApproval,
    approveApproval,
    rejectApproval,
    updateApprovalSteps,
    listApprovals,

    getDocumentsByDepartment,
    sendDocumentApproval,
    approveDocumentApproval,
    rejectDocumentApproval,
    finalizeDocumentApproval,
    getActiveDocumentApproval,
}
