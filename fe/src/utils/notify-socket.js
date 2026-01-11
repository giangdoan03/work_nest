import { io } from "socket.io-client";

let socket = null;
let currentUserId = null;
let notifyCallbacks = [];

export function connectNotifySocket(userId) {
    if (!userId) return null;
    userId = String(userId);

    // Nếu socket tồn tại và đã đúng user → dùng lại
    if (socket && currentUserId === userId) return socket;

    // Nếu đổi user → reset
    if (socket && currentUserId !== userId) {
        socket.disconnect();
        socket = null;
        notifyCallbacks = [];
    }

    currentUserId = userId;

    socket = io("https://notify.bee-soft.net", {
        path: "/socket.io/",
        transports: ["websocket"],
        auth: { userId },
        reconnection: true
    });

    socket.on("connect", () => {
        console.log("⚡ Socket connected:", socket.id);
        socket.emit("register", currentUserId);
    });

    socket.on("notify", (data) => {
        console.log("🔔 Notify received:", data);

        // gửi cho tất cả callback đã đăng ký
        notifyCallbacks.forEach(fn => fn(data));
    });

    return socket;
}

export function onNotify(cb) {
    if (typeof cb === "function") {
        notifyCallbacks.push(cb);
    }
}
