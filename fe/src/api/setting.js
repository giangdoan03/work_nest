import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

export const getSettings = () => instance.get('/setting')
export const getSetting = (id) => instance.get(`/setting/${id}`)
export const createSetting = (data) => instance.post('/setting', data)
export const updateSetting = (id, data) => instance.put(`/setting/${id}`, data)
export const deleteSetting = (id) => instance.delete(`/setting/${id}`)
