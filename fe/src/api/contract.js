import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// API bidding
export const getContractsAPI = () => instance.get('/contracts')
export const getContractAPI = (id) => instance.get(`/contracts/${id}`)
export const createContractAPI = (data) => instance.post('/contracts', data)
export const updateContractAPI = (id, data) => instance.put(`/contracts/${id}`, data)
export const deleteContractAPI = (id) => instance.delete(`/contracts/${id}`)
export const cloneFromTemplatesAPI = (biddingId) => instance.post(`/contracts/${biddingId}/init-steps`)

// Lấy danh sách bước theo bidding_id
export const getContractStepsAPI = (biddingId) =>
    instance.get(`/bidding-steps`, { params: { bidding_id: biddingId } })

// Cập nhật trạng thái bước
export const updateContractStepAPI = (stepId, data) =>
    instance.put(`/bidding-steps/${stepId}`, data)

export const completeContractStepAPI = (stepId) =>
    instance.put(`/bidding-steps/${stepId}/complete`)



