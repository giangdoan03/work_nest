import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true
})

// Lấy toàn bộ ảnh theo entity_type + entity_id
export const getEntityImages = async (entityType, entityId) => {
    try {
        const res = await instance.get(`/images/${entityType}/${entityId}`)
        return res.data ?? []
    } catch (err) {
        console.error('Lỗi khi gọi getEntityImages:', err)
        return []
    }
}

export const saveEntityImages = async (entityId, images) => {
    try {
        return await instance.post(`/images/save/${entityId}`, { images })
    } catch (err) {
        console.error('Lỗi khi gọi saveEntityImages:', err)
        throw err // để hàm submit bên ngoài vẫn bắt được lỗi
    }
}

