import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})

export const getEvents = (params) => instance.get('/events', { params })
export const getEvent = (id) => instance.get(`/events/${id}`)
export const createEvent = (data) => instance.post('/events', data)
export const updateEvent = (id, data) => instance.put(`/events/${id}`, data)
export const deleteEvent = (id) => instance.delete(`/events/${id}`)

export const uploadFile = (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return instance.post('/upload', formData)
}

export const uploadFromUrl = (url) => {
    return instance.post('/upload-from-url', { url }) // POST JSON { url: ... }
}
