<template>
    <div class="tiny-scroll">
        <router-view />
    </div>
</template>

<script setup>
import { onMounted, watch } from 'vue'
import { useUserStore } from '@/stores/user'
import { checkSession } from '@/api/auth'

// ⬇️ Socket helpers
import { connectNotifySocket, onNotify } from '@/utils/notify-socket.js'
// (tuỳ chọn) store để +1 badge chuông
// import { useNotifyStore } from '@/stores/notifications'

const userStore = useUserStore()
// const notify = useNotifyStore() // nếu dùng badge

// 1) Khởi tạo user từ session hiện tại
onMounted(async () => {
    try {
        const res = await checkSession()
        if (res.data.status === 'success') {
            userStore.setUser(res.data.user)
        } else {
            userStore.clearUser()
        }
    } catch {
        userStore.clearUser()
    }
})

// 2) Khi có user.id → connect socket & lắng nghe notify
let bootedForUser = null   // ⬅️ guard
watch(() => userStore.user?.id, (id) => {
    if (!id) return
    if (bootedForUser === String(id)) return   // ⬅️ đã boot -> bỏ qua
    bootedForUser = String(id)

    console.log('[App] connect socket as user', id)
    const sock = connectNotifySocket(String(id))

    onNotify((n) => console.log('🔔 Notify:', n))

    // tiện debug từ console
    window.__sock = sock
}, { immediate: true })
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
