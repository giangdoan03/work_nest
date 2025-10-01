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
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'

import Sidebar from './Sidebar.vue'
import Header from './Header.vue'
import Content from './Content.vue'
import { logout } from '../api/auth'

const collapsed = ref(true)              // Mặc định thu nhỏ lần đầu
const selectedKeys = ref(['1'])

const userStore = useUserStore()
const { user } = storeToRefs(userStore)
const router = useRouter()

onMounted(() => {
    // Chỉ override khi đã có giá trị lưu
    const saved = localStorage.getItem('sidebarCollapsed')
    if (saved !== null) {
        try {
            collapsed.value = JSON.parse(saved)
        } catch {
            // Nếu hỏng dữ liệu -> reset về mặc định thu nhỏ
            collapsed.value = true
            localStorage.removeItem('sidebarCollapsed')
        }
    }

    // (Tùy chọn) Sync trạng thái giữa nhiều tab
    window.addEventListener('storage', onStorage)
})

onBeforeUnmount(() => {
    window.removeEventListener('storage', onStorage)
})

function onStorage(e) {
    if (e.key === 'sidebarCollapsed' && e.newValue !== null) {
        try {
            collapsed.value = JSON.parse(e.newValue)
        } catch {}
    }
}

const toggleCollapsed = () => {
    collapsed.value = !collapsed.value
    localStorage.setItem('sidebarCollapsed', JSON.stringify(collapsed.value))
}

const handleLogout = async () => {
    try {
        await logout()
        user.value = null
        await router.push('/')
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
