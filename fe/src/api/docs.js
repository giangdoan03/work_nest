import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

/* ===============================
   DOCUMENT CRUD
=============================== */

// Danh sách tài liệu
export const getDocuments = (params) =>
    instance.get('/documents', { params })

// Lấy chi tiết 1 tài liệu
export const getDocument = (id) =>
    instance.get(`/documents/${id}`)

// Tạo tài liệu
export const createDocument = (data) =>
    instance.post('/documents', data)

// Cập nhật tài liệu
export const updateDocument = (id, data) =>
    instance.put(`/documents/${id}`, data)

// Xoá tài liệu
export const deleteDocument = (id) =>
    instance.delete(`/documents/${id}`)


/* ===============================
   ACCESS CONTROL (user + department)
=============================== */

// Cấp quyền user đọc tài liệu
export const addDocumentUserAccess = (data) =>
    instance.post('/documents/user-access/add', data)

// Thu hồi quyền user đọc tài liệu
export const removeDocumentUserAccess = (data) =>
    instance.post('/documents/user-access/remove', data)

// Kiểm tra người dùng có đọc được tài liệu hay không
export const canAccessDocument = (params) =>
    instance.get('/documents/can-access', { params })

