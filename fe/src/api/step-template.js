import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// ✅ PHẢI NHẬN params
export const getStepTemplatesAPI = (params) =>
    instance.get('/step-templates', { params })

export const createStepTemplateAPI = (data) =>
    instance.post('/step-templates', data)

export const updateStepTemplateAPI = (id, data) =>
    instance.put(`/step-templates/${id}`, data)

export const deleteStepTemplateAPI = (id) =>
    instance.delete(`/step-templates/${id}`)
