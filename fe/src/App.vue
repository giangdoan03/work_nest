<template>
    <div class="tiny-scroll">
        <router-view />
    </div>
</template>

<script setup>
import { onMounted, watch } from "vue";
import { useUserStore } from "@/stores/user";
import { useNotifyStore } from "@/stores/notifyStore";
import { checkSession } from "@/api/auth";

import { connectNotifyChannel } from "@/utils/notify-socket.js";

const userStore = useUserStore();
const notifyStore = useNotifyStore();

onMounted(async () => {
    const res = await checkSession().catch(() => null);

    if (res?.data?.status === "success") {
        userStore.setUser(res.data.user);
    } else {
        userStore.clearUser();
    }
});

/**
 * Khi user.id xuất hiện → mở socket
 * KHÔNG đặt handler onNotify ở đây
 * → tránh đăng ký nhiều lần
 */
watch(
    () => userStore.user?.id,
    (id) => {
        if (!id) return;

        console.log("🔌 Init socket for user:", id);
        notifyStore.initSocket(); // gọi trong store, không xử lý ở App.vue
    },
    { immediate: true }
);
</script>

<style>

/* Firefox */
.tiny-scroll .ant-table-body,
.tiny-scroll .ant-table-content,
.tiny-scroll .ant-table-header {
    scrollbar-width: thin;                         /* mảnh hơn */
    scrollbar-color: rgba(0,0,0,.35) transparent;  /* màu tay kéo */
}

/* Chrome/Edge/Safari */
.tiny-scroll .ant-table-body::-webkit-scrollbar,
.tiny-scroll .ant-table-content::-webkit-scrollbar,
.tiny-scroll .ant-table-header::-webkit-scrollbar {
    width: 6px;   /* dọc */
    height: 6px;  /* ngang – chỉnh xuống 4px nếu muốn nhỏ nữa */
}
.tiny-scroll .ant-table-body::-webkit-scrollbar-thumb,
.tiny-scroll .ant-table-content::-webkit-scrollbar-thumb,
.tiny-scroll .ant-table-header::-webkit-scrollbar-thumb {
    background: rgba(0,0,0,.35);
    border-radius: 6px;
}
.tiny-scroll .ant-table-body::-webkit-scrollbar-track,
.tiny-scroll .ant-table-content::-webkit-scrollbar-track,
.tiny-scroll .ant-table-header::-webkit-scrollbar-track {
    background: transparent;
}

/* Firefox */
.task, .content {
    scrollbar-width: thin;
    scrollbar-color: rgba(0,0,0,.35) transparent;
}

/* Chrome */
.task::-webkit-scrollbar {
    width: 3px;
    height: 3px;
}
.task::-webkit-scrollbar-thumb {
    background: rgba(0,0,0,.35);
    border-radius: 3px;
}
.task::-webkit-scrollbar-track {
    background: transparent;
}

</style>
