import { defineStore } from "pinia";

export const useCommentNotifyStore = defineStore("commentNotify", {
    state: () => ({
        items: [],
        unread: 0
    }),

    actions: {
        addRealtime(msg) {
            const item = {
                id: msg.id ?? Date.now(),
                task_id: msg.task_id,
                author_id: msg.author_id,
                author_name: msg.author_name ?? "Ẩn danh",
                author_avatar: msg.author_avatar ?? null,
                content: msg.content ?? "",
                task_title: msg.task_title ?? "",
                created_at: msg.created_at ?? new Date(),
                is_unread: true
            };

            this.items.unshift(item);
            this.unread++;
        },

        markRead(id) {
            const it = this.items.find(i => i.id === id);
            if (it && it.is_unread) {
                it.is_unread = false;
                this.unread = Math.max(0, this.unread - 1);
            }
        },

        markAllRead() {
            this.items.forEach(i => i.is_unread = false);
            this.unread = 0;
        }
    }
});
