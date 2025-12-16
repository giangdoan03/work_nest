import axios from 'axios'

function ensureApiBase(url) {
    const u = String(url || '').replace(/\/+$/, '')
    return /\/api$/.test(u) ? u : `${u}/api`
}

const instance = axios.create({
    baseURL: ensureApiBase(import.meta.env.VITE_API_URL),
    withCredentials: true,
})

export const createApprovalSession = (formData) => {
    return instance.post(
        '/approval-sessions',
        formData,
        { headers: { 'Content-Type': 'multipart/form-data' } }
    )
}

export const getApprovalSessionsByTask = (taskId) => {
    return instance.get(`/tasks/${taskId}/approval-sessions`)
}
