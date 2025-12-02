import axios from 'axios'
import {message} from "ant-design-vue";

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

export const getDocuments = (params) => instance.get('/documents', {params})
export const deleteDocument = (id) => instance.delete(`/documents/${id}`)
export const getDocumentsByDepartment = (departmentId) => instance.get('/documents/by-department', {params: {department_id: departmentId}});
export const getSharedDocuments = () => instance.get('/documents/shared/me')
export const uploadDocument = (formData) => instance.post('/documents/upload', formData, {headers: {'Content-Type': 'multipart/form-data'}})
export const shareDocument = (permissions) => instance.post('/documents/share', {permissions})
export const updateDocument = (id, data) => instance.put(`/documents/${id}`, data, {headers: {'Content-Type': 'application/json'}})
export const uploadDocumentToWP = (formData, onUploadProgress) => instance.post('/documents/upload-to-wp', formData,
    {headers: {'Content-Type': 'multipart/form-data'}, onUploadProgress})
export const uploadRemoteToWP = (payload) => instance.post('/documents/upload-remote-to-wp', payload, {headers: {'Content-Type': 'application/json'}})
export const uploadDocumentLink = (payload) => instance.post('/documents/upload-link', payload)
export const getDocumentById = async (id) => {
    try {
        const res = await instance.get(`/documents/${id}`)
        return res.data?.data || res.data
    } catch (err) {
        console.error('getDocumentById error:', err)
        throw err.response?.data || err
    }
}

export function getMyApprovalInboxFiles() {return instance.get('/approvals/inbox-files')}
export const getDocumentDetail = (id) => instance.get(`/documents/${id}`)
export const uploadSignedPdf = (formData) => instance.post('/documents/upload-signed', formData)
export const saveSignedDocument = (payload) => instance.post('/documents/signed', payload)
export const uploadTaskFileSigned = (formData) => instance.post('/task-files/upload-signed', formData, {headers: { 'Content-Type': 'multipart/form-data' }})
export const approveDocument = (payload) => instance.post('/documents/approve', payload, {headers: { 'Content-Type': 'application/json' }});
export const deleteDocumentAPI = (documentId, opts = {}) =>
    instance.delete(`/document-approvals/document/${documentId}`, { params: { force: opts.force ? 1 : 0 }});


export const deleteCommentAPI = (id) => instance.delete(`/comments/${id}`);

export async function uploadPdfToWordPress(pdfUrl, filename) {
    try {
        const res = await instance.post(
            "/wp-media/url",
            {
                url: pdfUrl,
                filename,               // ⚡ tên file truyền từ FE
                title: filename,
                alt_text: filename,
            },
            {
                headers: { "Content-Type": "application/json" }
            }
        );

        return res.data;

    } catch (e) {
        console.error("Upload WordPress error:", e.response?.data || e);
        message.error("Không upload PDF lên WordPress");
        return null;
    }
}


export const saveConvertedDocument = (payload) =>
    instance.post('/documents/converted', payload, {
        headers: { 'Content-Type': 'application/json' }
    });

export const getConvertedPdfList = (taskId) =>
    instance.get('/documents/converted', {
        params: { task_id: taskId }
    });

export const deleteConvertedPdf = (id) =>
    instance.delete(`/documents/converted/${id}`);

export const bulkDeleteConvertedPdf = (ids) =>
    instance.post("/documents/converted/bulk-delete", { ids });








