import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

export const getDocuments = (params) => instance.get('/documents', {params})
export const deleteDocument = (id) => instance.delete(`/documents/${id}`)
export const getDocumentsByDepartment = (departmentId) =>
    instance.get('/documents/by-department', {
        params: { department_id: departmentId }
    });

export const getSharedDocuments = () =>
    instance.get('/documents/shared/me')
export const uploadDocument = (formData) =>
    instance.post('/documents/upload', formData, {
        headers: {'Content-Type': 'multipart/form-data'}
    })
export const shareDocument = (permissions) =>
    instance.post('/documents/share', {permissions})
export const updateDocument = (id, data) =>
    instance.put(`/documents/${id}`, data, {
        headers: {
            'Content-Type': 'application/json'
        }
    })
