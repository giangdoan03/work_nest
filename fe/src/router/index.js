import {createRouter, createWebHistory} from 'vue-router'
import {useUserStore} from '../stores/user'

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
import ContractList from '../page/ContractList.vue'
import DocumentList from '../page/documents/DocumentList.vue'
import MyDocumentList from '../page/documents/MyDocumentList.vue'
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
import ContractStepTasks from '../components/ContractStepTask/ContractStepTasks.vue'
import UserGuide from '../components/UserGuide.vue'
import DocumentInfoPage from '../page/documents/DocumentInfoPage.vue'
import Forbidden403 from "@/page/Forbidden403.vue"
import { message } from "ant-design-vue";
import { canAccessEntity } from "@/api/entityMembers";

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
                meta: {breadcrumb: 'Không có quyền truy cập'}
            },

            // Dashboard
            {
                path: '/project-overview',
                name: 'project-overview',
                component: ProjectOverview,
                meta: {breadcrumb: 'Tổng quan'}
            },
            {path: 'dashboard', name: 'dashboard', component: Dashboard, meta: {breadcrumb: 'Trang chủ'}},

            // User
            {path: 'user/:id/info', name: 'persons-info', component: UserInfo, meta: {breadcrumb: 'Thông tin cá nhân'}},
            {path: '/users/:id', name: 'user-detail', component: UserDetail, meta: {breadcrumb: 'Thông tin cá nhân'}},

            // Permissions
            {
                path: 'permissions',
                name: 'permissions',
                component: UserPermissionManager,
                meta: {breadcrumb: 'Phân quyền'}
            },
            {
                path: 'user-management',
                name: 'user-management',
                component: UserManagement,
                meta: {breadcrumb: 'Quản lý người dùng'}
            },

            // Internal Tasks (Việc quy trình)
            {path: 'workflow', name: 'workflow', component: InternalTasks, meta: {breadcrumb: 'Việc quy trình'}},
            {
                path: 'workflow/:id/info',
                name: 'workflow-info',
                component: TaskDetail,
                meta: {breadcrumb: 'Chi tiết công việc', parent: 'workflow'}
            },

            // Biddings
            {
                path: '/bid-list',
                name: 'bid-list',
                component: BidList,
                meta: {breadcrumb: 'Đấu thầu'}
            },
            {
                path: '/bid-detail/:id',
                name: 'bid-detail',
                component: BidDetail,
                props: true, // ✅ để tự động nhận param id
                meta: { breadcrumb: 'Chi tiết gói thầu', parent: 'bid-list', requiresEntityAccess: true, entityType: 'bidding' }
            },
            {
                path: '/biddings/:bidId/steps/:stepId/tasks',
                name: 'bidding-step-tasks',
                component: BiddingStepTasks,
                meta: { breadcrumb: 'Công việc', parent: 'biddings-info', requiresEntityAccess: true, entityType: 'bidding' },
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
                meta: { breadcrumb: 'Chi tiết công việc', parent: 'bidding-step-tasks', requiresEntityAccess: true, entityType: 'bidding' }
            },


            {
                path: '/contract/:contractId/steps/:stepId/tasks',
                name: 'contract-step-tasks',
                component: ContractStepTasks,
                meta: { breadcrumb: 'Công việc', parent: 'contract-detail', requiresEntityAccess: true, entityType: 'contract' },
                props: route => ({
                    contractId: Number(route.params.contractId),
                    stepId: Number(route.params.stepId),
                }),
            },
            {
                path: '/contract/:contractId/steps/:stepId/tasks/:id/info',
                name: 'contract-task-info-in-step',
                component: TaskDetail,
                props: true,
                meta: { breadcrumb: 'Chi tiết công việc', parent: 'contract-step-tasks', requiresEntityAccess: true, entityType: 'contract' },
            },

            // Contracts
            {
                path: 'contract-list',
                name: 'contracts-tasks',
                component: ContractList,
                meta: { breadcrumb: 'Hợp đồng' }
            },
            {
                path: 'contract-tasks/:id/info',
                name: 'contract-task-info',
                component: TaskDetail,
                meta: { breadcrumb: 'Chi tiết nhiệm vụ hợp đồng' }
            },
            {
                path: 'contracts/:id',
                name: 'contract-detail',
                component: ContractDetail,
                meta: { breadcrumb: 'Chi tiết hợp đồng', parent: 'contracts-tasks', requiresEntityAccess: true, entityType: 'contract' }
            },

            {
                path: '/workflow/tasks/:id/info',
                name: 'workflow-task-info',
                component: InternalTasks,
                meta: { section: 'workflow', requiresEntityAccess: true, entityType: 'workflow-task' },
            },



            // router/index.js
            {
                path: '/workflow',
                name: 'workflow',
                component: InternalTasks,
                meta: { breadcrumb: 'Việc quy trình' },
            },
            {
                path: '/workflow/tasks/:id/info',
                name: 'workflow-task-info',
                component: TaskDetail,
                meta: { breadcrumb: 'Chi tiết nhiệm vụ', parent: 'workflow' }, // 👈 quan trọng
            },
            {
                path: '/contract-tasks/:id/info',
                redirect: to => ({ name: 'workflow-task-info', params: { id: to.params.id } }),
            },
            {
                path: '/workflow/bidding-tasks/:id/info',
                redirect: to => ({ name: 'workflow-task-info', params: { id: to.params.id } }),
            },



            // Settings
            {
                path: '/settings/bidding',
                name: 'cau-hinh-dau-thau',
                component: BiddingStepTemplateList,
                meta: {breadcrumb: 'Cấu hình đấu thầu', parent: 'cau-hinh'}
            },
            {
                path: '/settings/contract',
                name: 'cau-hinh-hop-dong',
                component: ContractsStepTemplateList,
                meta: {breadcrumb: 'Cấu hình hợp đồng', parent: 'cau-hinh'}
            },

            // Customers
            {
                path: '/customers',
                name: 'customers',
                component: () => import('../components/CustomerList.vue'),
                meta: {breadcrumb: 'Khách hàng', parent: 'dashboard'}
            },
            {
                path: '/customers/:id',
                name: 'customer-detail',
                component: CustomerDetail,
                meta: {breadcrumb: 'Chi tiết khách hàng', parent: 'customers'}
            },

            // My Tasks
            {path: '/my-tasks', name: 'my-tasks', component: MyTasks, meta: {breadcrumb: 'Nhiệm vụ của tôi'}},
            {
                path: '/task-approvals',
                name: 'task-approvals',
                component: () => import('../page/TaskApprovalList.vue'),
                meta: {breadcrumb: 'Duyệt công văn'}
            },

            // Charts
            {path: '/gantt-chart', name: 'GanttChart', component: GanttChart, meta: {breadcrumb: 'Biểu đồ thống kê'}},

            // Steps
            {
                path: '/bidding-steps/:id/info',
                name: 'BiddingStepDetail',
                component: () => import('../components/StepDetail.vue'),
                props: r => ({id: Number(r.params.id), type: 'bidding'})
            },
            {
                path: '/contract-steps/:id/info',
                name: 'ContractStepDetail',
                component: () => import('../components/StepDetail.vue'),
                props: r => ({id: Number(r.params.id), type: 'contract'})
            },

            // Việc không quy trình
            {path: '/non-workflow', name: 'non-workflow', component: Tasks, meta: {breadcrumb: 'Việc không quy trình'}},
            {
                path: '/non-workflow/tasks/:id/info',
                name: 'tasks-detail',
                component: TaskDetail,
                meta: {breadcrumb: 'Chi tiết công việc', parent: 'non-workflow', requiresEntityAccess: true, entityType: 'non-workflow-task'}
            },

            {
                path: '/workflow/bidding-tasks/:id/info',
                name: 'workflow-bidding-tasks',
                component: TaskDetail,
                meta: {breadcrumb: 'Chi tiết nhiệm vụ', parent: 'workflow'},
                props: true,
            },
            {
                path: '/biddings/:id/info',
                name: 'biddings-info',
                component: BidDetail,
                meta: {breadcrumb: 'Chi tiết gói thầu', parent: 'bid-list'},
                props: true,
            },

            {
                path: '/bidding-tasks/:id/info',
                name: 'bidding-task-info',
                component: TaskDetail,
                props: true,
                meta: {breadcrumb: 'Chi tiết công việc', parent: 'bid-list'}
            },

            // Department Tasks
            {
                path: 'department-task/:id/info',
                name: 'department-task-detail',
                component: TaskDetail,
                meta: {breadcrumb: 'Chi tiết nhiệm vụ phòng', parent: 'project-overview', section: 'overview'},
                props: true
            },
            {
                path: '/documents/:id',
                name: 'documents-info',
                component: DocumentInfoPage,
                meta: {breadcrumb: 'Tài liệu'}
            },
            {
                path: '/documents/:id',
                name: 'document.detail',
                component: DocumentInfoPage,
                props: true,
            },
            {
                path: '/non-workflow/:id/info',
                redirect: to => ({ name: 'tasks-detail', params: { id: Number(to.params.id) } }),
            },
            {
                path: '/departments',
                name: 'departments',
                component: DepartmentList,
                meta: { breadcrumb: 'Phòng ban' }
            },

            {
                path: '/documents',
                name: 'documents',
                component: DocumentList,
                meta: { breadcrumb: 'Tài liệu theo phòng ban' }
            },
            {
                path: '/my-documents',
                name: 'my-documents',
                component: MyDocumentList,  // của tôi
                meta: { breadcrumb: 'Tài liệu của tôi' }
            },
            {
                path: '/documents/:id',
                name: 'document-detail',
                component: DocumentInfoPage,
                props: true,
                meta: { breadcrumb: 'Chi tiết tài liệu' }
            },



            {
                path: '/user-guide',
                name: 'user-guide',
                component: UserGuide,
                meta: { breadcrumb: 'Hướng dẫn sử dụng' }
            },



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
    'GanttChart': 'gantt',
    'project-overview': 'project',
    'tasks': 'task',
    'tasks-detail': 'task',
    'non-workflow': 'task',
    'department-task-detail': 'task',
    'user-guide': 'guide',
}

router.beforeEach(async (to, from, next) => {
    const userStore = useUserStore()
    const isLoggedIn = !!userStore.user

    if (isLoggedIn) {
        if (!userStore.permissions || Object.keys(userStore.permissions).length === 0) {
            await userStore.fetchPermissions()
        }

        const module = routePermissionMap[to.name]

        // ⛔ Permission check chung (giữ nguyên logic cũ)
        if (module && module !== 'guide' && !userStore.hasPermission(module, 'view')) {
            return next('/403')
        }
    }

    if (!isLoggedIn && to.path !== '/') return next('/')
    if (isLoggedIn && to.path === '/') return next('/project-overview')

    // -----------------------------------------
    // 🔐 KIỂM TRA QUYỀN TRUY CẬP ENTITY (Bidding, Contract, Workflow Task, Non-workflow)
    // -----------------------------------------
    if (to.meta.requiresEntityAccess) {
        const userId = userStore.user?.id;
        if (!userId) return next('/403');

        let entityType = to.meta.entityType;

        if (entityType === 'workflow-task' || entityType === 'non-workflow-task') {
            entityType = 'internal';
        }

        let entityId = null;

        if (entityType === 'contract') {
            entityId = to.params.contractId || to.params.id;
        }
        else if (entityType === 'bidding') {
            entityId = to.params.bidId || to.params.id; // 👈 FIX ở đây
        }
        else {
            entityId = to.params.id;
        }

        if (!entityId) return next('/403');

        try {
            const res = await canAccessEntity({
                entity_type: entityType,
                entity_id: entityId,
                user_id: userId,
            });

            if (!res.data?.access) {
                message.error("Bạn không có quyền truy cập mục này.");
                return next('/403');
            }
        } catch (e) {
            return next('/403');
        }
    }




    next()
})



export default router
