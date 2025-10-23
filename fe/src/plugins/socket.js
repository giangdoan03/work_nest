import { io } from "socket.io-client";

let socket = null;

export function getSocket() {
    if (socket) return socket;

    const URL = import.meta.env.VITE_SOCKET_URL || "https://notify.bee-soft.net";
    const PATH = import.meta.env.VITE_SOCKET_PATH || "/socket.io";

    socket = io(URL, {
        path: PATH,
        transports: ["websocket"],
        withCredentials: true,
        auth: {
            userId: window.__APP_USER_ID__ || "",
            tenantId: window.__APP_TENANT_ID__ || "",
        },
        autoConnect: true,
    });

    socket.on("connect", () => console.log("✅ Socket connected", socket.id));
    socket.on("disconnect", (reason) => console.log("⚠️ Socket disconnected:", reason));
    socket.on("connect_error", (err) => console.error("❌ Socket error:", err.message));

    return socket;
}
