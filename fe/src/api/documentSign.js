import axios from 'axios'

const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // giữ session đăng nhập
})

/* ===============================
    DOCUMENT SIGN API
   =============================== */

/** Gửi tài liệu cho nhiều người ký (tạo steps)
 *  body = {
 *     converted_id: 123,
 *     approver_ids: [5, 7, 10]
 *  }
 */
export const sendDocumentToSign = (data) =>
    api.post('/document-sign/send', data)

/** Danh sách tài liệu người dùng cần ký */
export const getMySignInbox = (params) =>
    api.get('/document-sign/inbox', { params })

/** Người dùng ký tài liệu
 *  body = {
 *     converted_id: 123,
 *     signed_pdf_url: "...",
 *     signature_url: "...",
 *     comment: "ghi chú"
 *  }
 */
export const signDocument = (data) =>
    api.post('/document-sign/sign', data)

/** Người dùng từ chối tài liệu */
export const rejectDocument = (data) =>
    api.post('/document-sign/reject', data)

/** Chi tiết chuỗi ký của 1 tài liệu */
export const getDocumentSignDetail = (convertedId) =>
    api.get(`/document-sign/detail/${convertedId}`)


