import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

export const getContractsAPI = () => instance.get('/contracts')

export const getContractAPI = (id) => instance.get(`/contracts/${id}`)

export const createContractAPI = (data) => instance.post('/contracts', data)

export const updateContractAPI = (id, data) => instance.put(`/contracts/${id}`, data)

export const deleteContractAPI = (id) => instance.delete(`/contracts/${id}`)

export const getContractStepCountAPI = (id) => instance.get(`/contracts/${id}/step-count`)

export const getContractStepDetailsAPI = (id) => instance.get(`/contracts/${id}/step-details`)

export const getContractsByCustomerAPI = (customerId) => instance.get(`/contracts/by-customer/${customerId}`)

export const cloneStepsFromTemplateAPI = (contractId) =>
    instance.post(`/contracts/${contractId}/clone-from-template`);

export const canMarkContractAsCompleteAPI = (contractId) =>
    instance.get(`/contracts/can-complete/${contractId}`);