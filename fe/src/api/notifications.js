import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true,
})

// Lấy danh sách thông báo của user
export function getNotificationAPI(userId, page = 1) {
    return instance.get('/notifications', {
        params: { user_id: userId, page }
    });
}

// Gửi thông báo
export function sendNotificationAPI(payload) {
    return instance.post('/notifications/send', payload);
}

// Đánh dấu đã đọc
export function markNotificationReadAPI(id) {
    return instance.post(`/notifications/read/${id}`);
}
