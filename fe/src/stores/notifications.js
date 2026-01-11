import { defineStore } from "pinia";

export const useNotifyStore = defineStore("notifications", {
    state: () => ({
        items: [],
        unread: 0
    }),

    actions: {
        /** Thêm thông báo từ socket realtime */
        addRealtime(n) {
            const item = {
                id: n.id ?? Date.now(),
                title: n.title,
                content: n.message ?? n.content ?? null,
                url: n.url ?? null,
                created_at: n.created_at ?? new Date(),
                is_unread: true
            };

            // thêm đầu danh sách
            this.items.unshift(item);
            this.unread++;
        },

        /** Ghi dữ liệu từ API */
        setList(list) {
            this.items = list.map(i => ({
                ...i,
                is_unread: Boolean(Number(i.is_unread))
            }));
        },

        /** Thêm tiếp danh sách phía dưới (load more) */
        appendList(list) {
            this.items.push(...list);
        },

        /** Cập nhật số lượng chưa đọc */
        setUnread(count) {
            this.unread = count;
        },

        /** Đánh dấu đã đọc 1 item */
        markRead(id) {
            const i = this.items.find(x => x.id === id);
            if (i && i.is_unread) {
                i.is_unread = false;
                this.unread = Math.max(0, this.unread - 1);
            }
        },

        /** Đánh dấu đã đọc tất cả */
        markAllRead() {
            this.items.forEach(i => i.is_unread = false);
            this.unread = 0;
        }
    }
});
