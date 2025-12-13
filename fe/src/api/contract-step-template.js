import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

export const getContractStepTemplatesAPI = (params) =>
    instance.get('/contract-step-templates', { params })

export const createContractStepTemplateAPI = (data) => instance.post('/contract-step-templates', data)

export const updateContractStepTemplateAPI = (id, data) => instance.put(`/contract-step-templates/${id}`, data)

export const deleteContractStepTemplateAPI = (id) => instance.delete(`/contract-step-templates/${id}`)