import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

export const getDocuments = (params) => instance.get('/documents', {params})
export const deleteDocument = (id) => instance.delete(`/documents/${id}`)
export const getDocumentsByDepartment = (departmentId) =>
    instance.get('/documents/by-department', {
        params: {department_id: departmentId}
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

export const uploadDocumentToWP = (formData, onUploadProgress) =>
    instance.post('/documents/upload-to-wp', formData, {
        headers: {'Content-Type': 'multipart/form-data'}, onUploadProgress
    })

export const uploadRemoteToWP = (payload) =>
    instance.post('/documents/upload-remote-to-wp', payload, {
        headers: {'Content-Type': 'application/json'}
    })

export const uploadDocumentLink = (payload) =>
    instance.post('/documents/upload-link', payload)

export const getDocumentById = async (id) => {
    try {
        const res = await instance.get(`/documents/${id}`)
        return res.data?.data || res.data
    } catch (err) {
        console.error('getDocumentById error:', err)
        throw err.response?.data || err
    }
}

export function getMyApprovalInboxFiles() {
    return instance.get('/approvals/inbox-files')
}

export const getDocumentDetail = (id) => instance.get(`/documents/${id}`)

export function uploadSignedPdf(formData) {
    return instance.post('/documents/signed', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
    })
}

