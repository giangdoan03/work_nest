import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

// Danh sách lịch sử quét
export const getScanHistories = (params) => instance.get('/scan-history', { params })

// Lấy chi tiết một lịch sử quét
export const getScanHistory = (id) => instance.get(`/scan-history/${id}`)

// Tạo mới bản ghi lịch sử quét
export const createScanHistory = (data) => instance.post('/scan-history', data)

// Xoá bản ghi lịch sử quét
export const deleteScanHistory = (id) => instance.delete(`/scan-history/${id}`)
