import axios from 'axios'

const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // 👈 Bắt buộc để giữ session
})

// nhiệm vụ cá nhân Task
export const getComments = (task_id) =>  instance.get(`/tasks/${task_id}/comments`)

export const createComment = (task_id, data={}) =>  instance.post(`/tasks/${task_id}/comments`, data)

export const deleteComment = (comment_id, data={}) =>  instance.delete(`/comments/${comment_id}`)

export const updateComment = ( comment_id, data={}) =>  instance.put(`/comments/${comment_id}`, data)







