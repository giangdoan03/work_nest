<template>
    <div class="header">
        <a-layout-header
            style="background: #fff; padding: 0; display: flex; justify-content: space-between; align-items: center;">
            <!-- Toggle button -->
            <div style="margin-left: 16px;">
                <a-button type="text" @click="$emit('toggle')" style="border: none; box-shadow: none;">
                    <MenuFoldOutlined v-if="!collapsed"/>
                    <MenuUnfoldOutlined v-else/>
                </a-button>
            </div>

            <!-- Breadcrumb -->
            <div style="flex: 1; margin-left: 16px;">
                <a-breadcrumb :key="$route.fullPath" style="margin-left:16px;">
                    <a-breadcrumb-item v-for="(route, index) in breadcrumbs" :key="index">
                        <router-link v-if="route.name !== currentRoute.name" :to="route.to || { name: route.name }">
                            {{ route.meta.breadcrumb }}
                        </router-link>
                        <template v-else>
                          <span style="display:inline-flex;align-items:center;gap:4px;">
                            {{ route.meta.breadcrumb }}
                            <a-button
                                v-if="currentRoute.name === 'tasks'"
                                size="small"
                                @click="onClickCreateTask"
                                style="margin-left:8px"
                            >
                              <template #icon><PlusOutlined/></template>
                            </a-button>
                          </span>
                        </template>
                    </a-breadcrumb-item>
                </a-breadcrumb>
            </div>

            <!-- User Dropdown -->
            <div style="margin-right: 24px; display: flex; align-items: center;">
                <a-dropdown v-if="user" trigger="click" :getPopupContainer="triggerNode => triggerNode.parentNode">
                    <div @click.prevent style="display: flex; align-items: center; cursor: pointer;">
                        <a-avatar size="small" style="margin-right: 8px;">
                            <template #icon>
                                <UserOutlined/>
                            </template>
                        </a-avatar>
                        <span>{{ user.name }}</span>
                    </div>

                    <template #overlay>
                        <a-menu>
                            <a-menu-item key="profile" @click="redirectToProfile">
                                Thông tin cá nhân
                            </a-menu-item>
                            <a-menu-divider/>
                            <a-menu-item key="logout" @click="handleLogout">
                                Đăng xuất
                            </a-menu-item>
                        </a-menu>
                    </template>
                </a-dropdown>
            </div>

        </a-layout-header>
    </div>
</template>

<script setup>
import {useRoute, useRouter} from 'vue-router'
import {computed} from 'vue'
import {storeToRefs} from 'pinia'
import {useUserStore} from '../stores/user'
import {
    MenuUnfoldOutlined,
    MenuFoldOutlined,
    LogoutOutlined,
    DownOutlined,
    UserOutlined,
    PlusOutlined
} from '@ant-design/icons-vue'

const props = defineProps({
    collapsed: Boolean,
    user: Object
})


import {useCommonStore} from '@/stores/common'

const common = useCommonStore()

const onClickCreateTask = () => {
    if (currentRoute.name === 'tasks' /* hoặc 'internal-tasks' */) {
        common.triggerCreateTask('internal')
    }
}


const emit = defineEmits(['toggle', 'logout'])

const userStore = useUserStore()
const {user} = storeToRefs(userStore)

const currentRoute = useRoute()
const router = useRouter()

// Header.vue <script setup> — cập nhật breadcrumbs
const breadcrumbs = computed(() => {
    const all = router.getRoutes()
    const p = currentRoute.params

    const buildParams = {
        'bid-list':            () => ({}),
        'biddings-info':       () => ({ id: p.id || p.bidId }),     // id của gói
        'bidding-step-tasks':  () => ({ bidId: p.bidId, stepId: p.stepId }),
        'bidding-task-info':   () => ({ id: p.id }),
        'internal-tasks':      () => ({}),
        'internal-tasks-info': () => ({ id: p.id }),
        'tasks':               () => ({}),
    }

    const trail = []
    let cur = all.find(r => r.name === currentRoute.name)

    while (cur) {
        if (cur.meta?.breadcrumb) {
            trail.unshift({
                name: cur.name,
                meta: cur.meta,
                to: { name: cur.name, params: (buildParams[cur.name]?.() || {}) }
            })
        }
        const parentName = cur.meta?.parent
        cur = parentName ? all.find(r => r.name === parentName) : null
    }

    return trail
})

const handleLogout = () => {
    userStore.clearUser()     // 👉 Xoá user + quyền
    router.push('/')          // 👉 Về trang login/home
}
const redirectToProfile = () => {
    router.push({
        name: 'persons-info',
        params: {
            id: user.value.id
        }
    })
}
</script>

<style scoped>
.header {
    width: 100%;
}

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
