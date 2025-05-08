import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Đảm bảo giữ session
})

// === Loyalty Programs ===
export const getLoyaltyPrograms = (params) => instance.get('/loyalty-programs', { params })
export const getLoyaltyProgram = (id) => instance.get(`/loyalty-programs/${id}`)
export const createLoyaltyProgram = (data) => instance.post('/loyalty-programs', data)
export const updateLoyaltyProgram = (id, data) => instance.put(`/loyalty-programs/${id}`, data)
export const deleteLoyaltyProgram = (id) => instance.delete(`/loyalty-programs/${id}`)

// === Loyalty Gifts ===
export const getLoyaltyGifts = (params) => instance.get('/loyalty-gifts', { params })
export const getLoyaltyGift = (id) => instance.get(`/loyalty-gifts/${id}`)
export const createLoyaltyGift = (data) => instance.post('/loyalty-gifts', data)
export const updateLoyaltyGift = (id, data) => instance.put(`/loyalty-gifts/${id}`, data)
export const deleteLoyaltyGift = (id) => instance.delete(`/loyalty-gifts/${id}`)

// === Voucher Packages ===
export const getVoucherPackages = (params) => instance.get('/loyalty-vouchers', { params })
export const getVoucherPackage = (id) => instance.get(`/loyalty-vouchers/${id}`)
export const createVoucherPackage = (data) => instance.post('/loyalty-vouchers', data)
export const updateVoucherPackage = (id, data) => instance.put(`/loyalty-vouchers/${id}`, data)
export const deleteVoucherPackage = (id) => instance.delete(`/loyalty-vouchers/${id}`)
export const toggleVoucherPackageStatus = (id, status) =>
    instance.post(`/loyalty-vouchers/${id}/status`, { status })

// === History APIs ===
export const getParticipationHistory = () => instance.get('/loyalty/participation-history')
export const getWinningHistory = () => instance.get('/loyalty/winning-history')

// === Upload ===
export const uploadFile = (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return instance.post('/upload', formData)
}

export const uploadFromUrl = (url) => {
    return instance.post('/upload-from-url', { url })
}
