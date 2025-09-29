<template>
    <a-layout style="min-height: 100vh;">
        <a-row>
            <a-col :flex="collapsed ? '60px' : '200px'" style="transition: all 0.2s;">
                <Sidebar
                    :collapsed="collapsed"
                    :selectedKeys="selectedKeys"
                    @update:collapsed="collapsed = $event"
                    @update:selectedKeys="selectedKeys = $event"
                />
            </a-col>
            <a-col :flex="collapsed ? 'calc(100% - 60px)' : 'calc(100% - 200px)'" style="overflow: hidden; transition: all 0.2s;">
                <div>
                    <a-layout>
                        <Header
                            :collapsed="collapsed"
                            :user="user"
                            @toggle="toggleCollapsed"
                            @logout="handleLogout"
                        />
                        <Content />
                    </a-layout>
                </div>
            </a-col>
        </a-row>
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

// const collapsed = ref(false)
const collapsed = ref(true)
const selectedKeys = ref(['1'])
const userStore = useUserStore()
const { user } = storeToRefs(userStore)

const router = useRouter()
import { logout } from '../api/auth'

// Load collapsed state from localStorage on mount
onMounted(() => {
    // Nếu tồn tại key thì xóa luôn
    if (localStorage.getItem('sidebarCollapsed') !== null) {
        localStorage.removeItem('sidebarCollapsed')
    }
})

// Toggle menu
const toggleCollapsed = () => {
    // collapsed.value = !collapsed.value
    collapsed.value = true
    // Save to localStorage
    localStorage.setItem('sidebarCollapsed', JSON.stringify(collapsed.value))
}

// Check session user khi load layout
// onMounted(async () => {
//     await fetchUser()
// })

// Hàm fetch user từ API


// Xử lý logout
const handleLogout = async () => {
    try {
        await logout();
        user.value = null;
        await router.push('/');
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
