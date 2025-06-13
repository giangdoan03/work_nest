import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

export const getDocumentPermissions = (documentId) =>
    instance.get('/document-permissions', {
        params: documentId ? { document_id: documentId } : {}
    })

export const updateDocumentPermission = (id, data) =>
    instance.put(`/document-permissions/${id}`, data)

export const deleteDocumentPermission = (id) =>
    instance.delete(`/document-permissions/${id}`)
