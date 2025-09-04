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
import DocumentSettingForm from '../page/DocumentSettingForm.vue'
import BiddingStepTemplateList from '../page/BiddingStepTemplateList.vue'
import ContractsStepTemplateList from '../page/ContractsStepTemplateList.vue'
import BidList from '../page/BidList.vue'
import BidDetail from '../page/BidDetail.vue'
import CustomerDetail from '../page/CustomerDetail.vue'
import ContractDetail from '../page/ContractDetail.vue' // 👈 đảm bảo file này tồn tại
import UserDetail from '../page/UserDetail.vue' // 👈 đảm bảo file này tồn tại
import MyTasks from '../page/MyTasks.vue' // 👈 đảm bảo file này tồn tại
import ProjectOverview from '../page/ProjectOverview.vue' // 👈 đảm bảo file này tồn tại
import GanttChart from '../page/GanttChart.vue'
import Tasks from '../page/Tasks.vue'                // 👈 THÊM DÒNG NÀY
import {getPermissionMatrix} from "@/api/permission.js";
import Forbidden403 from "@/page/Forbidden403.vue";
import BiddingStepTasks from "@/components/BiddingStepTask/BiddingStepTasks.vue"; // 👈 đảm bảo file này tồn tại

const routes = [
    {
        path: '/',
        component: LoginForm
    },
    {
        path: '/',
        component: Layout,
        children: [
            {
                path: '/403',
                name: 'forbidden',
                component: Forbidden403,
                meta: { breadcrumb: 'Không có quyền truy cập' }
            },
            {
                path: '/project-overview',
                name: 'project-overview',
                component: ProjectOverview,
                meta: { breadcrumb: 'Tổng quan dự án' }
            },
            { path: 'dashboard', name: 'dashboard', component: Dashboard, meta: { breadcrumb: 'Trang chủ' } },

            // user
            { path: 'user/:id/info', name: 'persons-info', component: UserInfo, meta: { breadcrumb: 'Thông tin cá nhân' } },

            {
                path: '/users/:id',
                name: 'UserDetail',
                component: UserDetail,
                meta: { breadcrumb: 'Thông tin cá nhân' },
            },

            {
                path: '/users/:id',
                name: 'user-detail',
                component: UserDetail,
                meta: { breadcrumb: 'Thông tin cá nhân' }
            },

            // Permissions
            { path: 'permissions', name: 'permissions', component: UserPermissionManager, meta: { breadcrumb: 'Phân quyền' } },

            // User Management
            { path: 'user-management', name: 'user-management', component: UserManagement, meta: { breadcrumb: 'Quản lý người dùng' } },

            // Internal Tasks
            { path: 'internal-tasks', name: 'internal-tasks', component: InternalTasks, meta: { breadcrumb: 'Việc quy trình' } },
            { path: 'internal-tasks/:id/info', name: 'internal-tasks-info', component: TaskDetail, meta: { breadcrumb: 'Việc quy trình', parent: 'internal-tasks' } },
            // bid-list (gốc)
            {
                path: '/bid-list',
                name: 'bid-list',
                component: BidList,
                meta: { breadcrumb: 'Gói thầu' }
            },
            {
                path: '/biddings/:id/info',
                name: 'biddings-info',
                component: BidDetail,
                meta: { breadcrumb: 'Chi tiết gói thầu', parent: 'bid-list' },
                props: true,
            },
            {
                path: '/biddings/:bidId/steps/:stepId/tasks',
                name: 'bidding-step-tasks',               // 👈 DÙNG tên này xuyên suốt
                component: () => import('../components/BiddingStepTask/BiddingStepTasks.vue'),
                meta: { breadcrumb: 'Nhiệm vụ', parent: 'biddings-info' },
                props: route => ({
                    bidId: Number(route.params.bidId),
                    stepId: Number(route.params.stepId),
                }),
            },
            {
                path: '/bidding-tasks/:id/info',
                name: 'bidding-task-info',
                component: TaskDetail,
                meta: { breadcrumb: 'Chi tiết nhiệm vụ', parent: 'bidding-step-tasks' },
                props: true,
            },



            // Contracts Tasks
            { path: 'contracts-tasks', name: 'contracts-tasks', component: ContractsTasks, meta: { breadcrumb: 'Hợp đồng' } },

            {
                path: 'contract-tasks/:id/info',
                name: 'contract-task-info',
                component: TaskDetail,
                meta: { breadcrumb: 'Chi tiết nhiệm vụ hợp đồng' }
            },

            {
                path: 'bidding-tasks/:id/info',
                name: 'bidding-task-info',
                component: TaskDetail,
                meta: { breadcrumb: 'Chi tiết nhiệm vụ đấu thầu' }
            },

            {
                path: 'contracts/:id',
                name: 'contract-detail',
                component: ContractDetail,
                meta: { breadcrumb: 'Chi tiết hợp đồng'},
            },

            {
                path: '/bid-list',
                name: 'bid-list',
                component: BidList,
                meta: { breadcrumb: 'Đấu thầu' }
            },
            {
                path: '/bid-detail/:id',
                name: 'bid-detail',
                component: BidDetail,
                meta: { breadcrumb: 'Chi tiết gói thầu', parent: 'bid-list' }
            },

            // Permissions
            { path: 'departments', name: 'departments', component: DepartmentList, meta: { breadcrumb: 'Phòng ban' } },

            {
                path: '/customers',
                name: 'customers',
                component: () => import('../components/CustomerList.vue'),
                meta: { breadcrumb: 'Khách hàng', parent: 'dashboard' }
            },

            {
                path: '/customers/:id',
                name: 'customer-detail',
                component: CustomerDetail,
                meta: { breadcrumb: 'Chi tiết khách hàng', parent: 'customer-list' }
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
            {
                path: '/documents/settings',
                name: 'documents-settings',
                component: DocumentSettingForm,
                meta: { breadcrumb: 'Cấu hình tài liệu', parent: 'documents' },
            },
            {
                path: '/settings/bidding',
                name: 'cau-hinh-dau-thau',
                component: BiddingStepTemplateList,
                meta: { breadcrumb: 'Cấu hình đấu thầu', parent: 'cau-hinh' },
            },
            {
                path: '/settings/contract',
                name: 'cau-hinh-hop-dong',
                component: ContractsStepTemplateList,
                meta: {
                    breadcrumb: 'Cấu hình hợp đồng',
                    parent: 'cau-hinh'
                }
            },
            {
                path: '/my-tasks',
                name: 'my-tasks',
                component: MyTasks,
                meta: { breadcrumb: 'Nhiệm vụ của tôi' }
            },
            {
                path: '/task-approvals',
                name: 'task-approvals',
                component: () => import('../page/TaskApprovalList.vue'),
                meta: { breadcrumb: 'Duyệt nhiệm vụ' }
            },
            {
                path: '/gantt-chart',
                name: 'GanttChart',
                component: GanttChart,
                meta: { breadcrumb: 'Biểu đồ thống kê' }
            },

            {
                path: '/bidding-steps/:id/info',
                name: 'BiddingStepDetail',
                component: () => import('../components/StepDetail.vue'),
                props: route => ({ id: Number(route.params.id), type: 'bidding' })
            },
            {
                path: '/contract-steps/:id/info',
                name: 'ContractStepDetail',
                component: () => import('../components/StepDetail.vue'),
                props: route => ({ id: Number(route.params.id), type: 'contract' })
            },
            // Việc không quy trình
            {
                path: '/tasks',
                name: 'tasks',
                component: Tasks,
                meta: { breadcrumb: 'Việc không quy trình' }
            },
            {
                path: '/tasks/:id/info',
                name: 'tasks-detail',
                component: TaskDetail,
                meta: { breadcrumb: 'Chi tiết nhiệm vụ', parent: 'tasks' }
            },

            {
                path: '/biddings/:bidId/steps/:stepId/tasks',
                name: 'BiddingStepTasks',
                component: () => import('../components/BiddingStepTask/BiddingStepTasks.vue'),
                // tiện lấy sẵn kiểu number trong props
                props: route => ({
                    bidId: Number(route.params.bidId),
                    stepId: Number(route.params.stepId),
                }),
            }

        ]
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})


const routePermissionMap = {
    'internal-tasks': 'task',
    'internal-tasks-info': 'task',
    'contracts-tasks': 'contract',
    'contract-task-info': 'task',
    'bidding-task-info': 'task',
    'contract-detail': 'contract',
    'documents': 'document',
    'documents-my': 'document',
    'documents-shared': 'document',
    'documents-department': 'document',
    'documents-permission': 'document',
    'documents-settings': 'document',
    'user-management': 'user',
    'permissions': 'permission',
    'departments': 'department',
    'settings': 'setting',
    'cau-hinh-dau-thau': 'step-template',
    'cau-hinh-hop-dong': 'step-template',
    'bid-list': 'bidding',
    'bid-detail': 'bidding',
    'customers': 'customer',
    'customer-detail': 'customer',
    'my-tasks': 'my-task',
    'task-approvals': 'approval',
    'GanttChart': 'gantt',
    'project-overview': 'project',
    'tasks': 'task',
    'tasks-detail': 'task',
}


router.beforeEach(async (to, from, next) => {
    const userStore = useUserStore()

    const isLoggedIn = !!userStore.user

    if (isLoggedIn) {
        // ✅ Nếu chưa có permissions, mới gọi fetch
        if (!userStore.permissions || Object.keys(userStore.permissions).length === 0) {
            await userStore.fetchPermissions()
        }

        // ✅ Check quyền xem route
        const module = routePermissionMap[to.name]
        if (module && !userStore.hasPermission(module, 'view')) {
            return next('/403')
        }
    }

    if (!isLoggedIn && to.path !== '/') return next('/')
    if (isLoggedIn && to.path === '/') return next('/project-overview')

    next()
})



export default router