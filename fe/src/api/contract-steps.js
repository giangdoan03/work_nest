import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// Lấy tất cả các bước của hợp đồng
export const getContractStepsAPI = (contractId) =>
    instance.get(`/contracts/${contractId}/steps`)

// Tạo bước mới trong hợp đồng
export const createContractStepAPI = (contractId, data) =>
    instance.post(`/contracts/${contractId}/steps`, data)

// Cập nhật bước
export const updateContractStepAPI = (stepId, data) =>
    instance.put(`/contract-steps/${stepId}`, data)

// Xoá bước
export const deleteContractStepAPI = (stepId) =>
    instance.delete(`/contract-steps/${stepId}`)

// Clone bước từ template
export const cloneContractStepsFromTemplateAPI = (contractId) =>
    instance.post(`/contracts/${contractId}/steps/clone`)

// ✅ Bổ sung hàm hoàn thành bước
export const completeContractStepAPI = (stepId) =>
    instance.put(`/contract-steps/${stepId}/complete`)


// ===== Skip step (contract) =====
export const requestSkipContractStep = (stepId, reason) =>
    instance.post(`/contract-steps/${stepId}/request-skip`, { reason })

export const approveSkipContractStep = (stepId) =>
    instance.post(`/contract-steps/${stepId}/approve-skip`)

export const rejectSkipContractStep = (stepId, reason) =>
    instance.post(`/contract-steps/${stepId}/reject-skip`, { reason })