import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

export const getPurchaseHistories = () => instance.get('/purchase-history')
export const getPurchaseHistory = (id) => instance.get(`/purchase-history/${id}`)
export const createPurchaseHistory = (data) => instance.post('/purchase-history', data)
export const updatePurchaseHistory = (id, data) => instance.put(`/purchase-history/${id}`, data)
export const deletePurchaseHistory = (id) => instance.delete(`/purchase-history/${id}`)
