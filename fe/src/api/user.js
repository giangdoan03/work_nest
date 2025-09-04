import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // cần cho session CI4
    // headers: { 'X-Requested-With': 'XMLHttpRequest' }, // bật nếu CI4 bật CSRF strict
})

// ✅ Hàm upload avatar: GỌI endpoint đã lưu DB (Auth::uploadAvatar)
export const uploadAvatar = (file, userId, onUploadProgress) => {
    const fd = new FormData()
    fd.append('file', file)      // key phải là 'file' (khớp rules uploaded[file])
    fd.append('user_id', userId) // BE dùng để update vào bảng users

    return instance.post('/users/upload-avatar', fd, {
        onUploadProgress: e => {
            if (onUploadProgress && e.total) {
                onUploadProgress(Math.round((e.loaded / e.total) * 100))
            }
        },
    })
}

// (tuỳ chọn) Upload file thường: chỉ trả URL, KHÔNG lưu DB
export const uploadFile = (data) => {
    const formData = new FormData()
    Object.entries(data).forEach(([k, v]) => formData.append(k, v))
    return instance.post('/upload', formData) // endpoint upload chung (nếu có)
}

export const getUsers = (params = {}) =>
    instance.get('/users', { params })

export const getUserDetail = (userId) =>
    instance.get(`/users/${userId}`) // không cần params lặp user_id

export const createUser = (data) =>
    instance.post('/users', data)

export const updateUser = (userId, data) =>
    instance.put(`/users/${userId}`, data)

export const deleteUser = (userId) =>
    instance.delete(`/users/${userId}`)
