<template>
    <router-view />
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
