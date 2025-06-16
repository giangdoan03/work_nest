import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

export const getDocumentSettings = () => instance.get('/document-settings')

export const saveDocumentSettings = (data) => instance.post('/document-settings', data)
