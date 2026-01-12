// stores/taskUsersStore.js
import { defineStore } from "pinia";

export const useTaskUsersStore = defineStore("taskUsersStore", {
    state: () => ({
        taskId: null,
        users: [],        // danh sách user_id dạng string[]
        reviewers: [],    // reviewers chi tiết (full info)
    }),

    getters: {
        // tiện cho UI
        allUsers(state) {
            return [...new Set([...state.users, ...state.reviewers.map(r => String(r.user_id))])]
        }
    },

    actions: {
        setTaskBaseUsers(taskId, data) {
            this.taskId = taskId;

            const base = [
                data.assigned_to,
                data.collaborated_by,
                data.proposed_by,
                data.created_by
            ]
                .filter(Boolean)
                .map(id => String(id));

            this.users = [...new Set(base)];
        },

        setReviewers(sessions) {
            if (!Array.isArray(sessions)) return;

            // gom reviewers từ tất cả session
            const all = sessions.flatMap(s => s.reviewers || []);

            this.reviewers = all;

            // merge vào danh sách user chính
            const ids = all.map(r => String(r.user_id));
            this.users = [...new Set([...this.users, ...ids])];
        },

        clear() {
            this.taskId = null;
            this.users = [];
            this.reviewers = [];
        }
    }
});
