import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})
export const uploadFile = (data) => {
    const formData = new FormData();
    Object.entries(data).forEach(([key, value]) => {
        formData.append(key, value);
    });
    return instance.post('/users/upload-avatar', formData)
}

export const getUsers = () => 
    instance.get('/users')

export const getUserDetail = (userId) =>
    instance.get(`/users/${userId}`, { params: { user_id: userId } })

export const createUser = (data) =>
    instance.post(`/users`, data)

export const updateUser= (userId, data) =>
    instance.put(`/users/${userId}`, data)

export const deleteUser= (userId) =>
    instance.delete(`/users/${userId}`)
