import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'
import { checkSession } from '../api/auth'

// Components
import LoginForm from '../components/LoginForm.vue'
import Dashboard from '../components/Dashboard.vue'
import Layout from '../components/Layout.vue'

import UserInfo from '../components/UserInfo/index.vue'

import UserPermissionManager from '../components/UserPermissionManager.vue'

import DepartmentList from '../page/DepartmentList.vue'
import UserManagement from '../page/UserManagement.vue'
import InternalTasks from '../page/InternalTasks.vue'
import TaskDetail from '../components/task/index.vue'
import ContractsTasks from '../page/ContractsTasks.vue'
import DocumentList from '../page/DocumentList.vue'
import DepartmentDocumentList from '../page/DepartmentDocumentList.vue'
import DocumentSharedList from '../page/DocumentSharedList.vue'
import DocumentPermissionList from '../page/DocumentPermissionList.vue'

const routes = [
    {
        path: '/',
        component: LoginForm
    },
    {
        path: '/',
        component: Layout,
        children: [
            { path: 'dashboard', name: 'dashboard', component: Dashboard, meta: { breadcrumb: 'Trang chủ' } },


            // user
            { path: 'user/:id/info', name: 'persons-info', component: UserInfo, meta: { breadcrumb: 'Thông tin cá nhân' } },

            // Permissions
            { path: 'permissions', name: 'permissions', component: UserPermissionManager, meta: { breadcrumb: 'Phân quyền' } },

            // User Management
            { path: 'user-management', name: 'user-management', component: UserManagement, meta: { breadcrumb: 'Quản lý người dùng' } },

            // Internal Tasks
            { path: 'internal-tasks', name: 'internal-tasks', component: InternalTasks, meta: { breadcrumb: 'Nhiệm vụ nội bộ' } },
            { path: 'internal-tasks/:id/info', name: 'internal-tasks-info', component: TaskDetail, meta: { breadcrumb: 'Nhiệm vụ nội bộ', parent: 'internal-tasks' } },

            // Contracts Tasks
            { path: 'contracts-tasks', name: 'contracts-tasks', component: ContractsTasks, meta: { breadcrumb: 'Hợp đồng và công việc' } },

            // Permissions
            { path: 'departments', name: 'departments', component: DepartmentList, meta: { breadcrumb: 'Phòng ban' } },

            {
                path: '/customers',
                name: 'customers',
                component: () => import('../components/CustomerList.vue'),
                meta: { breadcrumb: 'Khách hàng', parent: 'dashboard' }
            },

            {
                path: '/settings',
                name: 'settings',
                component: () => import('../components/SettingList.vue'),
                meta: { breadcrumb: 'Cài đặt', parent: 'dashboard' },
            },

            {
                path: '/documents',
                name: 'documents',
                component: DocumentList,
                meta: { breadcrumb: 'Tài liệu', parent: 'dashboard' },
            },
            {
                path: '/documents/my',
                name: 'documents-my',
                component: DocumentList,
                meta: { breadcrumb: 'Tài liệu của tôi', parent: 'documents' },
            },
            {
                path: '/documents/shared',
                name: 'documents-shared',
                component: DocumentSharedList,
                meta: { breadcrumb: 'Được chia sẻ với tôi', parent: 'documents' },
            },
            {
                path: '/documents/department',
                name: 'documents-department',
                component: DepartmentDocumentList,
                meta: { breadcrumb: 'Theo phòng ban', parent: 'documents' },
            },
            {
                path: '/documents/permission',
                name: 'documents-permission',
                component: DocumentPermissionList,
                meta: { breadcrumb: 'Phân quyền tài liệu', parent: 'documents' },
            },
            // {
            //     path: '/documents/settings',
            //     name: 'documents-settings',
            //     component: () => import('../components/DocumentSetting.vue'),
            //     meta: { breadcrumb: 'Cấu hình tài liệu', parent: 'documents' },
            // },


        ]
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach(async (to, from, next) => {
    try {
        const response = await checkSession()
        const data = response.data
        const isLoggedIn = data.status === 'success'

        if (isLoggedIn) {
            const userStore = useUserStore()
            userStore.setUser(data.user)
        }

        if (!isLoggedIn && to.path !== '/') {
            next('/')
        } else if (isLoggedIn && to.path === '/') {
            next('/dashboard')
        } else {
            next()
        }
    } catch (error) {
        console.error('Error in router guard:', error)

        // ✅ Nếu đang vào trang login ("/") thì vẫn cho hiển thị giao diện
        if (to.path === '/') {
            next()
        } else {
            // ✅ Nếu truy cập trang khác mà không kết nối được -> chuyển về login
            next('/')
        }
    }
})


export default router