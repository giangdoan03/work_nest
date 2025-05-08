import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})

// Lấy danh sách vai trò (roles)
export const getRoles = () => instance.get('/roles')

// Lấy bảng quyền của 1 vai trò (trả về dạng matrix)
export const getPermissionMatrix = (roleId) =>
    instance.get(`/permissions/matrix`, { params: { role_id: roleId } })

// Gửi quyền đã chọn để lưu
export const saveRolePermissions = (roleId, permissions) =>
    instance.post(`/permissions/save`, {
        role_id: roleId,
        permissions
    })
