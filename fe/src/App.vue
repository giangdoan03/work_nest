<template>
    <div class="tiny-scroll">
        <router-view />
    </div>
</template>

<script setup>

import { onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { checkSession } from '@/api/auth'

onMounted(async () => {
    const userStore = useUserStore()
    try {
        const response = await checkSession()
        if (response.data.status === 'success') {
            userStore.setUser(response.data.user)
        } else {
            userStore.clearUser()
        }
    } catch (e) {
        userStore.clearUser()
    }
})
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
