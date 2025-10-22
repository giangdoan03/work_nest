// src/utils/notify-socket.js
import { io } from 'socket.io-client'

let sock = null
let boundHandlers = false
let boundUserId = null

export function connectNotifySocket(userId) {
    userId = String(userId || '')
    if (!userId) return null

    // ĐÃ có socket cho đúng user → dùng lại, KHÔNG tạo mới
    if (sock && boundUserId === userId) return sock

    // Có socket khác user → đóng hẳn và reset state
    if (sock && boundUserId !== userId) {
        try { sock.disconnect() } catch {}
        sock = null
        boundHandlers = false
    }

    boundUserId = userId
    sock = io('https://notify.bee-soft.net', {
        path: '/socket.io/',
        transports: ['websocket', 'polling'],   // ưu tiên websocket
        auth: { userId },
        reconnection: true,
        reconnectionAttempts: Infinity,
        reconnectionDelay: 800,
    })

    // log chuyển transport để dễ debug
    sock.io.on('upgrade', (transport) => {
        console.log('🚚 upgraded to', transport.name) // "websocket"
    })

    sock.on('connect', () => console.log('✅ Connected socket', sock.id))
    sock.on('disconnect', (r) => console.log('❌ Disconnect:', r))
    sock.on('connect_error', (e) => console.log('❌ connect_error:', e?.message || e))

    return sock
}

// đảm bảo chỉ gắn 1 lần
export function onNotify(cb) {
    if (!sock) return
    if (!boundHandlers) {
        sock.off('notify')      // gỡ mọi handler cũ (nếu có)
        sock.on('notify', cb)   // gắn 1 handler duy nhất
        boundHandlers = true
    }
}

export function getSocket() { return sock }
