import { defineStore } from 'pinia';

export const useTaskDrawerStore = defineStore('taskDrawer', {
    state: () => ({
        shouldReopen: false,
        lastFilterKey: null,
        tab: '1', // tab mặc định
    }),
    actions: {
        setShouldReopen(val = true) {
            this.shouldReopen = val;
        },
        setFilterKey(key) {
            this.lastFilterKey = key;
        },
        setTab(tabKey) {
            this.tab = tabKey;
        },
        reset() {
            this.shouldReopen = false;
            this.lastFilterKey = null;
            this.tab = '1';
        }
    },
    persist: {
        storage: sessionStorage // optional: giữ lại sau khi reload
    }
});
