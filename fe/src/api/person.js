import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})

export const getPersons = (params) => instance.get('/persons', { params })
export const getPerson = (id) => instance.get(`/persons/${id}`)
export const createPerson = (data) => instance.post('/persons', data)
export const updatePerson = (id, data) => instance.put(`/persons/${id}`, data)
export const deletePerson = (id) => instance.delete(`/persons/${id}`)
