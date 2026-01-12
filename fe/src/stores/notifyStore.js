// stores/notifyStore.js
import { defineStore } from "pinia";
import { connectNotifyChannel, onNotifyEvent } from "@/utils/notify-socket.js";
import { useUserStore } from "@/stores/user";

export const useNotifyStore = defineStore("notifyStore", {

    state: () => ({
        items: [],
        unread: 0,
        socketConnected: false,
        _unsubscribe: null,
    }),

    actions: {
        initSocket() {
            const userId = useUserStore().user?.id;
            if (!userId) return;

            // tránh tạo socket nhiều lần
            if (this.socketConnected) return;

            console.log("🔌 [NotifyStore] init socket:", userId);

            // mở socket
            connectNotifyChannel(userId);

            // hủy listener cũ nếu có
            if (this._unsubscribe) this._unsubscribe();

            // đăng ký listener mới
            this._unsubscribe = onNotifyEvent((data) => {
                console.log("📥 realtime received:", data);
                this.addRealtime(data);
            });

            this.socketConnected = true;
        },

        addRealtime(data) {
            const id = data.id ?? data.notify_id ?? Date.now();

            // Kiểm tra trùng ID
            const exists = this.items.some(i => i.id === id);
            if (exists) return; // không thêm

            const item = {
                id,
                title: data.title,
                content: data.message ?? data.content ?? "",
                url: data.url ?? null,
                created_at: data.created_at ?? new Date(),
                is_unread: true
            };

            // Thêm vào đầu, không duplicate
            this.items = [item, ...this.items];

            // Cập nhật unread chuẩn
            this.unread = this.items.filter(i => i.is_unread).length;
        },

        setList(list) {
            const map = new Map();

            // API list trước
            list.forEach(i => map.set(i.id, {
                ...i,
                is_unread: !!Number(i.is_unread)
            }));

            // Merge realtime (loại trùng ID tự động)
            this.items.forEach(i => map.set(i.id, i));

            // Cập nhật store
            this.items = Array.from(map.values());
            this.unread = this.items.filter(x => x.is_unread).length;
        },

        markRead(id) {
            this.items = this.items.map(i =>
                i.id === id
                    ? { ...i, is_unread: false }
                    : i
            );

            this.unread = Math.max(0, this.unread - 1);
        }
    }
});
