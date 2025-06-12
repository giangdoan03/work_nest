import axios from 'axios'

const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // để giữ session login
})

// CRUD chính
export const getCustomers = (params) => api.get('/customers', { params }) // GET danh sách (có lọc)
export const getCustomer = (id) => api.get(`/customers/${id}`)           // GET chi tiết
export const createCustomer = (data) => api.post('/customers', data)     // POST tạo mới
export const updateCustomer = (id, data) => api.put(`/customers/${id}`, data) // PUT cập nhật
export const deleteCustomer = (id) => api.delete(`/customers/${id}`)     // DELETE xoá

// Nhật ký tương tác (interaction logs)
export const createCustomerTransaction = (data) => api.post('/customers/transactions', data) // POST ghi nhật ký
export const getCustomerTransactions = (customerId) => api.get(`/customers/${customerId}/transactions`) // GET lịch sử tương tác

// Các hàm mở rộng nếu có thêm route trong tương lai
export const getCustomerContracts = (customerId) => api.get(`/customers/${customerId}/contracts`) // Giả định có contracts (nếu có route này sau)
