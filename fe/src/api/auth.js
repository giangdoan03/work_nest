import axios from 'axios'

const apiClient = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

export const login = (email, password) => {
    return apiClient.post('/login', { email, password })
}

export const logout = () => {
    return apiClient.get('/logout')
}

export const checkSession = () => {
    return apiClient.get('/check')
}
