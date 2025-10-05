import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

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
import ContractDetail from '../page/ContractDetail.vue'
import UserDetail from '../page/UserDetail.vue'
import MyTasks from '../page/MyTasks.vue'
import ProjectOverview from '../page/ProjectOverview.vue'
import GanttChart from '../page/GanttChart.vue'
import Tasks from '../page/Tasks.vue'
import BiddingStepTasks from '../components/BiddingStepTask/BiddingStepTasks.vue'
import DocumentInfoPage from '../page/documents/DocumentInfoPage.vue'
import Forbidden403 from "@/page/Forbidden403.vue"

const routes = [
    {
        path: '/',
        component: LoginForm
    },
    {
        path: '/',
        component: Layout,
        children: [
            // Errors
            {
                path: '/403',
                name: 'forbidden',
                component: Forbidden403,
                meta: { breadcrumb: 'Không có quyền truy cập' }
            },

            // Dashboard
            {
                path: '/project-overview',
                name: 'project-overview',
                component: ProjectOverview,
                meta: { breadcrumb: 'Tổng quan' }
            },
            { path: 'dashboard', name: 'dashboard', component: Dashboard, meta: { breadcrumb: 'Trang chủ' } },

            // User
            { path: 'user/:id/info', name: 'persons-info', component: UserInfo, meta: { breadcrumb: 'Thông tin cá nhân' } },
            { path: '/users/:id', name: 'user-detail', component: UserDetail, meta: { breadcrumb: 'Thông tin cá nhân' } },

            // Permissions
            { path: 'permissions', name: 'permissions', component: UserPermissionManager, meta: { breadcrumb: 'Phân quyền' } },
            { path: 'user-management', name: 'user-management', component: UserManagement, meta: { breadcrumb: 'Quản lý người dùng' } },

            // Internal Tasks (Việc quy trình)
            { path: 'workflow', name: 'workflow', component: InternalTasks, meta: { breadcrumb: 'Việc quy trình' } },
            { path: 'workflow/:id/info', name: 'workflow-info', component: TaskDetail, meta: { breadcrumb: 'Chi tiết công việc', parent: 'workflow' } },

            // Biddings
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
                props: true, // ✅ để tự động nhận param id
                meta: { breadcrumb: 'Chi tiết gói thầu', parent: 'bid-list' }
            },
            {
                path: '/biddings/:bidId/steps/:stepId/tasks',
                name: 'bidding-step-tasks',
                component: BiddingStepTasks,
                meta: { breadcrumb: 'Công việc', parent: 'biddings-info' },
                props: route => ({
                    bidId: Number(route.params.bidId),
                    stepId: Number(route.params.stepId),
                }),
            },
            {
                path: '/biddings/:bidId/steps/:stepId/tasks/:id/info',
                name: 'bidding-task-info-in-step',
                component: TaskDetail,
                props: true,
                meta: { breadcrumb: 'Chi tiết công việc', parent: 'bidding-step-tasks' }
            },

            // Contracts
            { path: 'contracts-tasks', name: 'contracts-tasks', component: ContractsTasks, meta: { breadcrumb: 'Hợp đồng' } },
            { path: 'contract-tasks/:id/info', name: 'contract-task-info', component: TaskDetail, meta: { breadcrumb: 'Chi tiết nhiệm vụ hợp đồng' } },
            { path: 'contracts/:id', name: 'contract-detail', component: ContractDetail, meta: { breadcrumb: 'Chi tiết hợp đồng'} },

            // Documents
            { path: '/documents', name: 'documents', component: DocumentList, meta: { breadcrumb: 'Tài liệu', parent: 'dashboard' } },
            { path: '/documents/my', name: 'documents-my', component: DocumentList, meta: { breadcrumb: 'Tài liệu của tôi', parent: 'documents' } },
            { path: '/documents/shared', name: 'documents-shared', component: DocumentSharedList, meta: { breadcrumb: 'Được chia sẻ với tôi', parent: 'documents' } },
            { path: '/documents/department', name: 'documents-department', component: DepartmentDocumentList, meta: { breadcrumb: 'Theo phòng ban', parent: 'documents' } },
            { path: '/documents/permission', name: 'documents-permission', component: DocumentPermissionList, meta: { breadcrumb: 'Phân quyền tài liệu', parent: 'documents' } },
            { path: '/documents/settings', name: 'documents-settings', component: DocumentSettingForm, meta: { breadcrumb: 'Cấu hình tài liệu', parent: 'documents' } },

            // Settings
            { path: '/settings/bidding', name: 'cau-hinh-dau-thau', component: BiddingStepTemplateList, meta: { breadcrumb: 'Cấu hình đấu thầu', parent: 'cau-hinh' } },
            { path: '/settings/contract', name: 'cau-hinh-hop-dong', component: ContractsStepTemplateList, meta: { breadcrumb: 'Cấu hình hợp đồng', parent: 'cau-hinh' } },

            // Customers
            { path: '/customers', name: 'customers', component: () => import('../components/CustomerList.vue'), meta: { breadcrumb: 'Khách hàng', parent: 'dashboard' } },
            { path: '/customers/:id', name: 'customer-detail', component: CustomerDetail, meta: { breadcrumb: 'Chi tiết khách hàng', parent: 'customers' } },

            // My Tasks
            { path: '/my-tasks', name: 'my-tasks', component: MyTasks, meta: { breadcrumb: 'Nhiệm vụ của tôi' } },
            { path: '/task-approvals', name: 'task-approvals', component: () => import('../page/TaskApprovalList.vue'), meta: { breadcrumb: 'Duyệt nhiệm vụ' } },

            // Charts
            { path: '/gantt-chart', name: 'GanttChart', component: GanttChart, meta: { breadcrumb: 'Biểu đồ thống kê' } },

            // Steps
            { path: '/bidding-steps/:id/info', name: 'BiddingStepDetail', component: () => import('../components/StepDetail.vue'), props: r => ({ id: Number(r.params.id), type: 'bidding' }) },
            { path: '/contract-steps/:id/info', name: 'ContractStepDetail', component: () => import('../components/StepDetail.vue'), props: r => ({ id: Number(r.params.id), type: 'contract' }) },

            // Việc không quy trình
            { path: '/non-workflow', name: 'non-workflow', component: Tasks, meta: { breadcrumb: 'Việc không quy trình' } },
            {
                path: '/non-workflow/tasks/:id/info',
                name: 'tasks-detail',
                component: TaskDetail,
                meta: { breadcrumb: 'Chi tiết công việc', parent: 'non-workflow' }
            },

            {
                path: '/workflow/bidding-tasks/:id/info',
                name: 'workflow-bidding-tasks',
                component: TaskDetail,
                meta: { breadcrumb: 'Chi tiết nhiệm vụ', parent: 'workflow' },
                props: true,
            },
            {
                path: '/biddings/:id/info',
                name: 'biddings-info',
                component: BidDetail,
                meta: { breadcrumb: 'Chi tiết gói thầu', parent: 'bid-list' },
                props: true,
            },

            {
                path: '/bidding-tasks/:id/info',
                name: 'bidding-task-info',
                component: TaskDetail,
                props: true,
                meta: { breadcrumb: 'Chi tiết công việc', parent: 'bid-list' }
            },

            // Department Tasks
            { path: 'department-task/:id/info', name: 'department-task-detail', component: TaskDetail, meta: { breadcrumb: 'Chi tiết nhiệm vụ phòng', parent: 'project-overview', section: 'overview' }, props: true },
            {
                path: '/documents/:id',
                name: 'documents-info',
                component: DocumentInfoPage,
                meta: { breadcrumb: 'Tài liệu' }
            },
            {
                path: '/documents/:id',
                name: 'document.detail',
                component: DocumentInfoPage,
                props: true,
            }

        ]
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

const routePermissionMap = {
    'workflow': 'task',
    'workflow-info': 'task',
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
    'non-workflow': 'task',              // ✅ thêm
    'department-task-detail': 'task',
}

router.beforeEach(async (to, from, next) => {
    const userStore = useUserStore()
    const isLoggedIn = !!userStore.user

    if (isLoggedIn) {
        if (!userStore.permissions || Object.keys(userStore.permissions).length === 0) {
            await userStore.fetchPermissions()
        }

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
