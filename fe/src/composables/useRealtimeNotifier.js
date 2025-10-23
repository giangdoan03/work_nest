import { getSocket } from "@/plugins/socket.js";

function createId() {
    return String(Date.now()) + "-" + Math.random().toString(36).slice(2, 8);
}

export function useRealtimeNotifier() {
    const socket = getSocket();

    async function dispatch(payload, opts = {}) {
        const {
            retries = 2,
            ackTimeoutMs = 3000,
        } = opts;

        const finalPayload = {
            id: payload.id || createId(),
            ts: payload.ts || Date.now(),
            priority: payload.priority || "normal",
            locale: payload.locale || "vi",
            ...payload,
        };

        if (!finalPayload.entity) throw new Error("entity is required");
        if (!finalPayload.action) throw new Error("action is required");
        if (!finalPayload.title) throw new Error("title is required");

        const targets = finalPayload.targets || {};
        const hasReceivers =
            targets.broadcast ||
            targets.tenantId != null ||
            (targets.rooms && targets.rooms.length) ||
            (targets.roleKeys && targets.roleKeys.length) ||
            (targets.userIds && targets.userIds.length);

        if (!hasReceivers) {
            throw new Error("At least one target (broadcast/tenant/rooms/roleKeys/userIds) is required");
        }

        const sendOnce = () =>
            new Promise((resolve) => {
                let settled = false;
                const timer = setTimeout(() => {
                    if (!settled) {
                        settled = true;
                        resolve(false);
                    }
                }, ackTimeoutMs);

                socket.emit("notify.dispatch", finalPayload, (ack) => {
                    if (settled) return;
                    clearTimeout(timer);
                    settled = true;
                    if (!ack?.ok && ack?.reason) {
                        console.warn("notify.dispatch ack reason:", ack.reason);
                    }
                    resolve(Boolean(ack?.ok));
                });
            });

        for (let i = 0; i <= retries; i++) {
            const ok = await sendOnce();
            if (ok) return true;
            await new Promise(r => setTimeout(r, 200 + i * 200));
        }
        return false;
    }

    return { dispatch };
}
