import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// API bidding
export const getBiddingsAPI = () => instance.get('/biddings')
export const getBiddingAPI = (id) => instance.get(`/biddings/${id}`)
export const createBiddingAPI = (data) => instance.post('/biddings', data)
export const updateBiddingAPI = (id, data) => instance.put(`/biddings/${id}`, data)
export const deleteBiddingAPI = (id) => instance.delete(`/biddings/${id}`)
export const cloneFromTemplatesAPI = (biddingId) => instance.post(`/biddings/${biddingId}/init-steps`)
