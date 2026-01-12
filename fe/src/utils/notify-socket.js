import { io } from "socket.io-client";

let notifySocket = null;
let chatSocket = null;

let notifyUserId = null;
let chatUserId = null;

// listener list
const listeners = {
    notify: new Set(),
    chat: new Set()
};

// ==============================
// 1) SOCKET THÔNG BÁO
// ==============================
export function connectNotifyChannel(userId) {
    if (!userId) return null;
    userId = String(userId);

    if (notifySocket && notifyUserId === userId) return notifySocket;

    // nếu user đổi -> disconnect socket cũ
    if (notifySocket && notifyUserId !== userId) {
        notifySocket.disconnect();
        notifySocket = null;
    }

    notifyUserId = userId;

    notifySocket = io("https://notify.bee-soft.net/notify", {
        path: "/socket.io/",
        transports: ["websocket"],
        auth: { userId },
        reconnection: true,
        reconnectionDelay: 3000
    });

    notifySocket.on("connect", () => {
        console.log("🔔 Notify connected:", notifySocket.id);
        notifySocket.emit("register", userId);
    });

    notifySocket.on("notify", (payload) => {
        listeners.notify.forEach(fn => fn(payload));
    });

    return notifySocket;
}


// ==============================
// 2) SOCKET COMMENT REALTIME
// ==============================
export function connectChatChannel(userId) {
    if (!userId) return null;
    userId = String(userId);

    if (chatSocket && chatUserId === userId) return chatSocket;

    if (chatSocket && chatUserId !== userId) {
        chatSocket.disconnect();
        chatSocket = null;
    }

    chatUserId = userId;

    chatSocket = io("https://notify.bee-soft.net/chat", {
        path: "/socket.io/",
        transports: ["websocket"],
        auth: { userId },
        reconnection: true,
        reconnectionDelay: 3000
    });

    chatSocket.on("connect", () => {
        console.log("💬 Chat connected:", chatSocket.id);
        chatSocket.emit("register", userId);
    });

    chatSocket.on("task:new_comment", (payload) => {
        console.log("📥 Realtime comment:", payload);
        listeners.chat.forEach(fn => fn(payload));
    });


    return chatSocket;
}


// ==============================
// 3) REGISTER EVENT  (có auto-remove)
// ==============================
export function onNotifyEvent(callback) {
    listeners.notify.add(callback);
    return () => listeners.notify.delete(callback);
}

export function onIncomingComment(callback) {
    listeners.chat.add(callback);
    return () => listeners.chat.delete(callback);
}


// ==============================
// 4) GỬI COMMENT REALTIME
// ==============================
export function sendCommentRealtime(payload) {
    if (chatSocket) chatSocket.emit("task:new_comment", payload);
}
