import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'
import { checkSession } from '../api/auth'

// Components
import LoginForm from '../components/LoginForm.vue'
import Dashboard from '../components/Dashboard.vue'
import Layout from '../components/Layout.vue'

import ProductList from '../components/ProductList.vue'
import ProductForm from '../components/ProductForm.vue'

import BusinessList from '../components/BusinessList.vue'
import BusinessForm from '../components/BusinessForm.vue'

import MyQRCodes from '../components/MyQRCodes.vue'
import QRCreateForm from '../components/QRCreateForm.vue'

import PersonList from '../components/PersonList.vue'
import PersonForm from '../components/PersonForm.vue'

import EventList from '../components/EventList.vue'
import EventForm from '../components/EventForm.vue'

import StoreList from '../components/StoreList.vue'
import StoreForm from '../components/StoreForm.vue'

import LoyaltyProgramList from '../components/LoyaltyProgramList.vue'
import LoyaltyProgramForm from '../components/LoyaltyProgramForm.vue'

import LoyaltyGiftList from '../components/LoyaltyGiftList.vue'
import LoyaltyGiftForm from '../components/LoyaltyGiftForm.vue'

import VoucherManagement from '../components/VoucherManagement.vue'
import VoucherForm from '../components/VoucherForm.vue'

import LandingPageList from '../components/LandingPageList.vue'

import UserPermissionManager from '../components/UserPermissionManager.vue'

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

            // Products
            { path: 'products', name: 'products', component: ProductList, meta: { breadcrumb: 'Sản phẩm' } },
            { path: 'products/create', name: 'products-create', component: ProductForm, meta: { breadcrumb: 'Thêm sản phẩm', parent: 'products' } },
            { path: 'products/:id/edit', name: 'products-edit', component: ProductForm, meta: { breadcrumb: 'Sửa sản phẩm', parent: 'products' } },

            // QR Codes
            {
                path: 'my-qr-codes',
                name: 'my-qr-codes',
                component: MyQRCodes,
                meta: { breadcrumb: 'Mã QR của tôi' }
            },
            {
                path: 'my-qr-codes/create',
                name: 'qr-create',
                component: QRCreateForm,
                meta: { breadcrumb: 'Tạo mã QR', parent: 'my-qr-codes' }
            },
            {
                path: 'my-qr-codes/:qr_id/edit',
                name: 'qr-edit',
                component: QRCreateForm,
                meta: { breadcrumb: 'Sửa mã QR', parent: 'my-qr-codes' }
            },


            // Businesses
            { path: 'businesses', name: 'businesses', component: BusinessList, meta: { breadcrumb: 'Doanh nghiệp' } },
            { path: 'businesses/create', name: 'businesses-create', component: BusinessForm, meta: { breadcrumb: 'Thêm doanh nghiệp', parent: 'businesses' } },
            { path: 'businesses/:id/edit', name: 'businesses-edit', component: BusinessForm, meta: { breadcrumb: 'Sửa doanh nghiệp', parent: 'businesses' } },

            // Persons
            { path: 'persons', name: 'persons', component: PersonList, meta: { breadcrumb: 'Cá nhân' } },
            { path: 'persons/create', name: 'persons-create', component: PersonForm, meta: { breadcrumb: 'Thêm cá nhân', parent: 'persons' } },
            { path: 'persons/:id/edit', name: 'persons-edit', component: PersonForm, meta: { breadcrumb: 'Sửa cá nhân', parent: 'persons' } },

            // Events
            { path: 'events', name: 'events', component: EventList, meta: { breadcrumb: 'Sự kiện' } },
            { path: 'events/create', name: 'events-create', component: EventForm, meta: { breadcrumb: 'Thêm sự kiện', parent: 'events' } },
            { path: 'events/:id/edit', name: 'events-edit', component: EventForm, meta: { breadcrumb: 'Sửa sự kiện', parent: 'events' } },

            // Stores
            { path: 'stores', name: 'stores', component: StoreList, meta: { breadcrumb: 'Cửa hàng' } },
            { path: 'stores/create', name: 'stores-create', component: StoreForm, meta: { breadcrumb: 'Thêm cửa hàng', parent: 'stores' } },
            { path: 'stores/:id/edit', name: 'stores-edit', component: StoreForm, meta: { breadcrumb: 'Sửa cửa hàng', parent: 'stores' } },

            // Permissions
            { path: 'permissions', name: 'permissions', component: UserPermissionManager, meta: { breadcrumb: 'Phân quyền' } },

            // Loyalty Programs
            { path: 'loyalty/programs', name: 'chuong-trinh', component: LoyaltyProgramList, meta: { breadcrumb: 'Chương trình Loyalty', parent: 'dashboard' } },
            { path: 'loyalty/programs/create', name: 'chuong-trinh-create', component: LoyaltyProgramForm, meta: { breadcrumb: 'Tạo chương trình', parent: 'chuong-trinh' } },
            { path: 'loyalty/programs/:id/edit', name: 'chuong-trinh-edit', component: LoyaltyProgramForm, meta: { breadcrumb: 'Sửa chương trình', parent: 'chuong-trinh' } },

            // Loyalty Gifts
            { path: 'loyalty/gifts', name: 'qua-tang', component: LoyaltyGiftList, meta: { breadcrumb: 'Quà tặng', parent: 'chuong-trinh' } },
            { path: 'loyalty/gifts/create', name: 'qua-tang-create', component: LoyaltyGiftForm, meta: { breadcrumb: 'Tạo quà tặng', parent: 'qua-tang' } },
            { path: 'loyalty/gifts/:id/edit', name: 'qua-tang-edit', component: LoyaltyGiftForm, meta: { breadcrumb: 'Sửa quà tặng', parent: 'qua-tang' } },

            // Voucher Management
            { path: 'loyalty/voucher-management', name: 'goi-voucher', component: VoucherManagement, meta: { breadcrumb: 'Gói voucher', parent: 'chuong-trinh' } },
            { path: 'loyalty/voucher-management/create', name: 'goi-voucher-create', component: VoucherForm, meta: { breadcrumb: 'Tạo gói voucher', parent: 'goi-voucher' } },
            { path: 'loyalty/voucher-management/:id/edit', name: 'goi-voucher-edit', component: VoucherForm, meta: { breadcrumb: 'Sửa gói voucher', parent: 'goi-voucher' } },

            {
                path: 'loyalty/history',
                name: 'lich-su-nguoi-choi',
                component: () => import('../components/LoyaltyHistory.vue'),
                meta: { breadcrumb: 'Lịch sử người chơi', parent: 'dashboard' }
            },
            {
                path: 'custom-pages',
                name: 'trang-tu-thiet-ke',
                component: () => import('../components/LandingPageList.vue'),
                meta: { breadcrumb: 'Trang tự thiết kế', parent: 'dashboard' }
            },
            {
                path: 'scan-history',
                name: 'lich-su-quet',
                component: () => import('../components/ScanHistoryList.vue'),
                meta: { breadcrumb: 'Lịch sử quét', parent: 'dashboard' }
            },
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
                path: '/purchase-history',
                name: 'purchase-history',
                component: () => import('../components/PurchaseHistoryList.vue'),
                meta: { breadcrumb: 'Lịch sử mua gói', parent: 'dashboard' }
            }
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
        next('/')
    }
})

export default router