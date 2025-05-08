<template>
    <a-layout style="min-height: 100vh;">
        <Sidebar
            :collapsed="collapsed"
            :selectedKeys="selectedKeys"
            @update:collapsed="collapsed = $event"
            @update:selectedKeys="selectedKeys = $event"
        />
        <a-layout>
            <Header
                :collapsed="collapsed"
                :user="user"
                @toggle="toggleCollapsed"
                @logout="handleLogout"
            />
            <Content />
        </a-layout>
    </a-layout>
</template>

<script setup>
import { storeToRefs } from 'pinia'
import { useUserStore } from '../stores/user'
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

import Sidebar from './Sidebar.vue'
import Header from './Header.vue'
import Content from './Content.vue'

const collapsed = ref(false)
const selectedKeys = ref(['1'])
const userStore = useUserStore()
const { user } = storeToRefs(userStore)

const router = useRouter()


// Toggle menu
const toggleCollapsed = () => {
    collapsed.value = !collapsed.value
}

// Check session user khi load layout
// onMounted(async () => {
//     await fetchUser()
// })

// Hàm fetch user từ API


// Xử lý logout
const handleLogout = async () => {
    try {
        await fetch('http://api.giang.test/logout', { credentials: 'include' })
        user.value = null
        router.push('/')
    } catch (error) {
        console.error('Logout error:', error)
    }
}
</script>

<style>
    .bg_card_gray {
        background: #f3f4f5;
    }
</style>
