import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// API bidding
export const getBiddingsAPI = (params = {}) => instance.get('/biddings', { params })
export const getBiddingAPI = (id) => instance.get(`/biddings/${id}`)
export const createBiddingAPI = (data) => instance.post('/biddings', data)
export const updateBiddingAPI = (id, data) => instance.put(`/biddings/${id}`, data)
export const deleteBiddingAPI = (id) => instance.delete(`/biddings/${id}`)
export const cloneFromTemplatesAPI = (biddingId) => instance.post(`/biddings/${biddingId}/init-steps`)

// Lấy danh sách bước theo bidding_id
export const getBiddingStepsAPI = (biddingId) => instance.get(`/bidding-steps`, { params: { bidding_id: biddingId } })

// Cập nhật trạng thái bước
export const updateBiddingStepAPI = (stepId, data) => instance.put(`/bidding-steps/${stepId}`, data)

export const completeBiddingStepAPI = (stepId) => instance.put(`/bidding-steps/${stepId}/complete`)



