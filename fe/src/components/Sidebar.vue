<template>
    <a-layout-sider
        :collapsed="collapsed"
        :trigger="null"
        collapsible
        collapsedWidth="0"
        width="250"
        breakpoint="lg"
        @breakpoint="handleBreakpoint"
        @collapse="handleCollapse"
        style="background-color: #000000;"
    >
        <div class="logo"/>
        <a-menu
            :selectedKeys="selectedKeys"
            :openKeys="openKeys"
            theme="dark"
            mode="inline"
            @openChange="val => openKeys = val"
            @select="handleSelect"
        >
            <a-menu-item key="dashboard">
                <PieChartOutlined/>
                <span>Tổng quan</span>
            </a-menu-item>

            <a-sub-menu key="quan-ly-doi-tuong">
                <template #title>
                      <span>
                        <AppstoreOutlined/>
                        <span>Quản lý đối tượng</span>
                      </span>
                </template>

                <a-menu-item key="san-pham">
                    <ShoppingOutlined/>
                    <span>Sản phẩm</span>
                </a-menu-item>

                <a-menu-item key="doanh-nghiep-ca-nhan">
                    <BankOutlined/>
                    <span>Doanh nghiệp</span>
                </a-menu-item>

                <a-menu-item key="ca-nhan">
                    <UserOutlined/>
                    <span>Cá nhân</span>
                </a-menu-item>

                <a-menu-item key="cua-hang">
                    <ShopOutlined/>
                    <span>Cửa hàng</span>
                </a-menu-item>

                <a-menu-item key="su-kien">
                    <CalendarOutlined/>
                    <span>Sự kiện</span>
                </a-menu-item>
            </a-sub-menu>

            <a-menu-item key="qr-code-marketing">
                <QrcodeOutlined/>
                <span>QR Code Marketing</span>
            </a-menu-item>

            <a-sub-menu key="chuong-trinh-loyalty">
                <template #title>
                      <span>
                        <GiftOutlined/>
                        <span>Chương trình loyalty</span>
                      </span>
                </template>

                <a-menu-item key="chuong-trinh">
                    <TrophyOutlined/>
                    <span>Chương trình</span>
                </a-menu-item>

                <a-menu-item key="qua-tang">
                    <GiftOutlined/>
                    <span>Quà tặng</span>
                </a-menu-item>

                <a-menu-item key="goi-voucher">
                    <ShoppingCartOutlined/>
                    <span>Gói voucher</span>
                </a-menu-item>

                <a-menu-item key="lich-su-nguoi-choi">
                    <HistoryOutlined/>
                    <span>Lịch sử người chơi</span>
                </a-menu-item>
            </a-sub-menu>

            <a-menu-item key="trang-tu-thiet-ke">
                <EditOutlined/>
                <span>Trang tự thiết kế</span>
            </a-menu-item>

            <a-menu-item key="lich-su-quet">
                <SearchOutlined/>
                <span>Lịch sử quét</span>
            </a-menu-item>

<!--            <a-menu-item key="lich-su-checkin">-->
<!--                <EnvironmentOutlined/>-->
<!--                <span>Lịch sử checkin</span>-->
<!--            </a-menu-item>-->

            <a-menu-item key="quan-ly-khach-hang">
                <TeamOutlined/>
                <span>Quản lý khách hàng</span>
            </a-menu-item>

            <a-menu-item key="cau-hinh">
                <SettingOutlined/>
                <span>Cấu hình</span>
            </a-menu-item>

            <a-menu-item key="lich-su-mua-goi">
                <ClockCircleOutlined/>
                <span>Lịch sử mua gói</span>
            </a-menu-item>
            <a-menu-item key="quan-ly-user">
                <TeamOutlined/>
                <span>Quản lý người dùng</span>
            </a-menu-item>
        </a-menu>
    </a-layout-sider>
</template>

<script setup>
import {
    PieChartOutlined, AppstoreOutlined, ShoppingOutlined, BankOutlined, QrcodeOutlined,
    GiftOutlined, TrophyOutlined, ShoppingCartOutlined, HistoryOutlined, EditOutlined,
    SearchOutlined, EnvironmentOutlined, TeamOutlined, SettingOutlined, ClockCircleOutlined,
    UserOutlined, ShopOutlined, CalendarOutlined
} from '@ant-design/icons-vue'

import {useRouter, useRoute} from 'vue-router'
import {ref, watch, onMounted} from 'vue'

const router = useRouter()
const route = useRoute()

const props = defineProps({
    collapsed: Boolean
})

const emit = defineEmits(['update:collapsed'])

const selectedKeys = ref([])
const openKeys = ref([])

const pathToKeyMap = {
    '/dashboard': 'dashboard',
    '/products': 'san-pham',
    '/businesses': 'doanh-nghiep-ca-nhan',
    '/persons': 'ca-nhan',
    '/stores': 'cua-hang',
    '/events': 'su-kien',
    '/my-qr-codes': 'qr-code-marketing',
    '/my-qr-codes/:id/edit': 'qr-code-marketing',
    '/loyalty/programs': 'chuong-trinh',
    '/loyalty/gifts': 'qua-tang',
    '/loyalty/voucher-management': 'goi-voucher',
    '/loyalty/history': 'lich-su-nguoi-choi',
    '/custom-pages': 'trang-tu-thiet-ke',
    '/scan-history': 'lich-su-quet',
    '/checkin-history': 'lich-su-checkin',
    '/customers': 'quan-ly-khach-hang',
    '/settings': 'cau-hinh',
    '/purchase-history': 'lich-su-mua-goi',
    '/permissions': 'quan-ly-user'
}

const keyToParentMap = {
    // Quản lý đối tượng
    'san-pham': 'quan-ly-doi-tuong',
    'doanh-nghiep-ca-nhan': 'quan-ly-doi-tuong',
    'ca-nhan': 'quan-ly-doi-tuong',
    'cua-hang': 'quan-ly-doi-tuong',
    'su-kien': 'quan-ly-doi-tuong',

    // Chương trình loyalty
    'chuong-trinh': 'chuong-trinh-loyalty',
    'qua-tang': 'chuong-trinh-loyalty',
    'goi-voucher': 'chuong-trinh-loyalty',
    'lich-su-nguoi-choi': 'chuong-trinh-loyalty',

    // Các menu khác
    'trang-tu-thiet-ke': 'dashboard',
    'lich-su-quet': 'dashboard',
    'lich-su-checkin': 'dashboard',
    'quan-ly-khach-hang': 'dashboard',
    'cau-hinh': 'dashboard',
    'lich-su-mua-goi': 'dashboard',
    'quan-ly-user': 'dashboard',
}


const updateSelectedAndOpenKeys = () => {
    const currentPath = route.path

    // Tìm path phù hợp nhất bằng startsWith
    const matchedEntry = Object.entries(pathToKeyMap).find(([path]) =>
        currentPath.startsWith(path)
    )

    const matchedKey = matchedEntry?.[1] || ''
    selectedKeys.value = [matchedKey]

    const parentKey = keyToParentMap[matchedKey]
    openKeys.value = parentKey ? [parentKey] : []
}


onMounted(updateSelectedAndOpenKeys)
watch(() => route.path, updateSelectedAndOpenKeys)

const handleSelect = ({key}) => {
    // Gán selected ngay lập tức để tránh nháy
    selectedKeys.value = [key]

    const path = Object.entries(pathToKeyMap).find(([path, menuKey]) => menuKey === key)?.[0]
    if (path) router.push(path)
}

const handleBreakpoint = (broken) => {
    emit('update:collapsed', broken)
}

const handleCollapse = (collapsed) => {
    emit('update:collapsed', collapsed)
}
</script>
<style>
    .ant-menu-dark {
        background-color: #000000 !important;
    }

    .ant-menu-sub.ant-menu-inline {
        background: #000000 !important;
    }
</style>
<style scoped>
    .logo {
        height: 32px;
        background: rgba(255, 255, 255, 0.3);
        margin: 16px;
    }
</style>
