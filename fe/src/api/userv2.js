import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})

export const uploadFile = (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return instance.post('/users/upload-avatar', formData)
}


// Lấy chi tiết của 1 phòng ban 
export const getDepartmentDetail = (userId) =>
    instance.get(`/users/${userId}`, { params: { user_id: userId } })

export const createDepartment = (data) =>
    instance.post(`/users`, {
        name: data.name,
        description: data.description
})
export const updateDepartment= (userId, data) =>
    instance.put(`/users/${userId}`, {
    name: data.name,
    description: data.description
})
export const deleteDepartment= (userId) =>
    instance.delete(`/users/${userId}`)
