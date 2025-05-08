import axios from 'axios'

const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})

export const getBusinesses = (params) => api.get('/businesses', { params })
export const getBusiness = (id) => api.get(`/businesses/${id}`)
export const createBusiness = (data) => api.post('/businesses', data)
export const updateBusiness = (id, data) => api.put(`/businesses/${id}`, data)
export const deleteBusiness = (id) => api.delete(`/businesses/${id}`)

export const uploadFile = (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/upload', formData)
}
