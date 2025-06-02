<template>
    <a-layout-header
        style="background: #fff; padding: 0; display: flex; justify-content: space-between; align-items: center;"
    >
        <div>
            <MenuUnfoldOutlined
                v-if="collapsed"
                class="trigger"
                @click="emit('toggle')"
            />
            <MenuFoldOutlined
                v-else
                class="trigger"
                @click="emit('toggle')"
            />
        </div>

        <!-- Breadcrumb -->
        <div style="flex: 1; margin-left: 16px;">
            <a-breadcrumb>
                <a-breadcrumb-item v-for="(route, index) in breadcrumbs" :key="index">
                    <router-link v-if="route.name !== currentRoute.name" :to="{ name: route.name }">
                        {{ route.meta.breadcrumb }}
                    </router-link>
                    <span v-else>{{ route.meta.breadcrumb }}</span>
                </a-breadcrumb-item>
            </a-breadcrumb>
        </div>

        <!-- User Dropdown -->
        <div style="margin-right: 24px; display: flex; align-items: center;">
            <a-dropdown v-if="user" trigger="click">
                <a @click.prevent style="cursor: pointer;">
                    {{ user.name }} <DownOutlined />
                </a>
                <template #overlay>
                    <a-menu >
                        <a-menu-item key="profile" @click="redirectToProfile">
                            Thông tin cá nhân
                        </a-menu-item>
                        <a-menu-divider />
                        <a-menu-item key="logout" @click="emit('logout')">
                            Đăng xuất
                        </a-menu-item>
                    </a-menu>
                </template>
            </a-dropdown>
        </div>
    </a-layout-header>
</template>

<script setup>
import { useRoute, useRouter } from 'vue-router'
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useUserStore } from '../stores/user'
import {
    MenuUnfoldOutlined,
    MenuFoldOutlined,
    LogoutOutlined,
    DownOutlined
} from '@ant-design/icons-vue'

const props = defineProps({
    collapsed: Boolean,
    user: Object
})

const emit = defineEmits(['toggle', 'logout'])

const userStore = useUserStore()
const { user } = storeToRefs(userStore)

const currentRoute = useRoute()
const router = useRouter()

const breadcrumbs = computed(() => {
    const matched = []
    let current = router.getRoutes().find(r => r.name === currentRoute.name)

    while (current) {
        if (current.meta?.breadcrumb) {
            matched.unshift(current)
        }
        const parentName = current.meta?.parent
        current = parentName ? router.getRoutes().find(r => r.name === parentName) : null
    }

    return matched
})
const redirectToProfile = () => {
    router.push({
        name: 'persons-edit',
        params: {
            id: user.value.id
        }
    })
}
</script>

<style scoped>
.trigger {
    font-size: 18px;
    line-height: 64px;
    padding: 0 24px;
    cursor: pointer;
    transition: color 0.3s;
}

.trigger:hover {
    color: #1890ff;
}
</style>
