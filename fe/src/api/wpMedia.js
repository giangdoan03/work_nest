// src/api/wpMedia.js
import axios from 'axios'

/**
 * Lưu ý: VITE_API_URL nên là .../api (ví dụ https://api.worknest.local/api)
 * => Các path bên dưới KHÔNG có /api ở đầu để tránh bị đúp /api/api/...
 */
const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // keep session cookies for auth-protected endpoints
})

/**
 * Upload a local file to WordPress Media via your backend proxy.
 * Backend route: POST /wp-media  (form-data: file)
 *
 * @param {File|Blob} file - Browser File/Blob object
 * @param {Object} [opts]  - { filename?: string, onUploadProgress?: (e) => void }
 * @returns {Promise<AxiosResponse>} -> { id, source_url, mime_type, title, raw }
 */
export const uploadWpMedia = (file, opts = {}) => {
    const form = new FormData()
    const name = opts.filename || (file && (file.name || `upload_${Date.now()}`))
    form.append('file', file, name)

    return api.post('/wp-media', form, {
        headers: { 'Content-Type': 'multipart/form-data' },
        onUploadProgress: opts.onUploadProgress,
    })
}

/**
 * Upload a remote URL to WordPress Media via your backend proxy.
 * Backend route: POST /wp-media/url
 *
 * @param {Object} payload - { url: string, filename?, title?, alt_text?, caption? }
 * @returns {Promise<AxiosResponse>} -> { id, source_url, mime_type, title, raw }
 */
export const uploadWpMediaByUrl = (payload) => {
    return api.post('/wp-media/url', payload)
}

/**
 * Update media metadata on WordPress.
 * Backend route: PATCH /wp-media/:id
 *
 * @param {number} id
 * @param {Object} payload - { title?, alt_text?, caption? }
 * @returns {Promise<AxiosResponse>} -> { status: 'updated', raw }
 */
export const updateWpMediaMeta = (id, payload) => {
    return api.patch(`/wp-media/${id}`, payload)
}

/**
 * Delete a media item on WordPress.
 * Backend route: DELETE /wp-media/:id
 *
 * @param {number} id
 * @returns {Promise<AxiosResponse>} -> { status: 'deleted', id }
 */
export const deleteWpMedia = (id) => {
    return api.delete(`/wp-media/${id}`)
}

/* ------------------------------------------------------------------ */
/* Optional convenience helpers                                        */
/* ------------------------------------------------------------------ */

/**
 * Shorthand to upload a signature image and get back its public URL.
 * Returns just the URL (string) or throws.
 *
 * @param {File|Blob} file
 * @param {Object} [opts] - { filename?, onUploadProgress? }
 * @returns {Promise<string>} source_url
 */
export const uploadSignatureImage = async (file, opts = {}) => {
    const { data } = await uploadWpMedia(file, opts)
    const url = data?.source_url
    if (!url) throw new Error('No source_url returned from wp-media')
    return url
}

/**
 * Shorthand to upload any remote image/PDF/etc. by URL and get its public URL.
 *
 * @param {string} url
 * @param {Object} [meta] - { filename?, title?, alt_text?, caption? }
 * @returns {Promise<string>} source_url
 */
export const uploadRemoteToWp = async (url, meta = {}) => {
    const payload = { url, ...meta }
    const { data } = await uploadWpMediaByUrl(payload)
    const src = data?.source_url
    if (!src) throw new Error('No source_url returned from wp-media/url')
    return src
}
