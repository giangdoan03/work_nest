import axios from 'axios'

const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // để giữ session nếu dùng cookie
})

// Tạo QR mới
export const createQR = (data) => api.post('/qr-codes', data)

// Lấy danh sách tất cả QR (có thể kèm phân trang, tìm kiếm)
export const getQRList = (params) => api.get('/qr-codes/list', { params })

// ✅ Lấy chi tiết 1 QR code theo qr_id
export const getQR = (qr_id) => api.get(`/qr-codes/${qr_id}`)

// Cập nhật QR theo qr_id
export const updateQR = (qr_id, data) => api.put(`/qr-codes/${qr_id}`, data)

// Xoá QR theo qr_id
export const deleteQR = (qr_id) => api.delete(`/qr-codes/${qr_id}`)

// Dùng để xử lý redirect QR
export const scanQR = (shortCode) => api.get(`/qr-codes/scan/${shortCode}`)
