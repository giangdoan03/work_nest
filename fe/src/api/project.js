import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

export const getProjectOverviewAPI = (params = {}) =>
    instance.get('/project-overview', { params })