<template>
<div class="user-info">
    <a-card>
        <a-row>
            <a-col flex="165px">
                <a-menu 
                    v-model:openKeys="openKeys"
                    v-model:selectedKeys="selectedKeys"
                    mode="inline"
                    class="user-info-menu"
                    @openChange="val => openKeys = val"
                    @select="handleClick"
                >
                    <a-menu-item v-for="item in items" :key="item.key">
                        <span> {{ item.label }} </span>
                    </a-menu-item>
    
                </a-menu>
            </a-col>
            <a-col flex="1">
                <div class="user-info-content">
                    <UserInfo /> 
                </div>
            </a-col>
        </a-row>
    </a-card>
</div>
</template>

<script setup>
import { ref, watch, onMounted} from 'vue';
import UserInfo from './UserInfo.vue';
import ChangePassword from './ChangePassword.vue';
import { getUserDetail } from '../../api/user';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute()
const router = useRouter()

const selectedKeys = ref(['user-info']);
const openKeys = ref();

const items = ref([
    {
        key: 'UserInfo',
        label: 'Thông tin cá nhân',
    },
    {
        key: 'ChangePassword',
        label: 'Thay đổi mật khẩu',
    },
    // {
    //     key: 'logout',
    //     label: 'Đăng xuất',
    // },
]);

const handleClick = (e) => {
    selectedKeys.value = [e.key]
    console.log(111,e);
};

onMounted(() => {

});
</script>

<style scoped>
.user-info {
    width: 100%;
    height: 100%;
    background-color: #fff;
}
.user-info-menu {
    height: 100%;
    border-inline-end: none !important;
}
.user-info-content{
    width: 100%;
    height: 100%;
    margin-left: 16px;
    border-left: 1px solid #f0f0f0;
    padding: 0 24px;
}
</style>
