import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

// ------------------------------------
// CRUD PHÒNG BAN
// ------------------------------------
export const getDepartments = () => instance.get('/departments')

export const getDepartmentDetail = (departmentId) =>
    instance.get(`/departments/${departmentId}`)

export const createDepartment = (data) =>
    instance.post(`/departments`, data)

export const updateDepartment = (departmentId, data) =>
    instance.put(`/departments/${departmentId}`, data)

export const deleteDepartment = (departmentId) =>
    instance.delete(`/departments/${departmentId}`)


// ------------------------------------
// USER ↔ DEPARTMENT
// ------------------------------------
export const getDepartmentUsers = (departmentId) =>
    instance.get(`/departments/${departmentId}/users`)

// CHUẨN HƠN
export const addUsersToDepartment = (payload) =>
    instance.post(`/departments/${payload.department_id}/users`, payload);


export const removeUserFromDepartment = (departmentId, userId) =>
    instance.delete(`/departments/${departmentId}/users/${userId}`)
