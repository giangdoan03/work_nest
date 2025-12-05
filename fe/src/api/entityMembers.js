import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})


// ⭐ Thêm user vào entity (bidding / contract / non_workflow)
export const addEntityMember = (data) =>
    instance.post('/entity-members/add', data)

// ⭐ Xoá user khỏi entity
export const removeEntityMember = (data) =>
    instance.post('/entity-members/remove', data)

// ⭐ Lấy danh sách user được quyền vào entity
export const listEntityMembers = (entityType, entityId) =>
    instance.get(`/entity-members/list/${entityType}/${entityId}`)

// ⭐ Kiểm tra user có quyền vào entity hay không
export const canAccessEntity = (params = {}) =>
    instance.get('/entity-members/can-access', { params })
