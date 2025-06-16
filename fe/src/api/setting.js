import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

// 🔧 Đúng với route nhóm: /api/settings
export const getSettings = () => instance.get('/settings')
export const getSetting = (id) => instance.get(`/settings/${id}`)
export const getSettingByKey = (key) => instance.get(`/settings/key/${key}`)
export const createSetting = (data) => instance.post('/settings', data)
export const updateSetting = (id, data) => instance.put(`/settings/${id}`, data)
export const deleteSetting = (id) => instance.delete(`/settings/${id}`)
