import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})

// Lấy danh sách phòng ban 
export const getDepartments = () => instance.get('/departments')

// Lấy chi tiết của 1 phòng ban 
export const getDepartmentDetail = (departmentId) =>
    instance.get(`/departments/${departmentId}`, { params: { department_id: departmentId } })

export const createDepartment = (data) =>
    instance.post(`/departments`, {
        name: data.name,
        description: data.description
})
export const updateDepartment= (departmentId, data) =>
    instance.put(`/departments/${departmentId}`, {
    name: data.name,
    description: data.description
})
export const deleteDepartment= (departmentId) =>
    instance.delete(`/departments/${departmentId}`)
