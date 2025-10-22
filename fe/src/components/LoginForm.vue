<template>
    <div class="login-mobile">
        <div class="login-content">
            <!-- Logo & Slogan -->
            <div class="logo-section">
<!--                <img src="/logo.png" class="logo-img" alt="Logo" />-->
                <h2 class="slogan">
                    <span>GIẢI PHÁP QUẢN LÝ</span><br />
                    <small>Làm việc mọi lúc mọi nơi</small>
                </h2>
            </div>

            <!-- Form đăng nhập -->
            <a-card class="login-card" :bordered="false">
                <h3 class="login-title">Đăng nhập</h3>

                <a-form
                    :model="formState"
                    layout="vertical"
                    @finish="onFinish"
                    @finishFailed="onFinishFailed"
                >
                    <a-form-item name="email" :rules="[{ required: true, message: 'Vui lòng nhập tên đăng nhập!' }]">
                        <a-input v-model:value="formState.email" placeholder="Tên đăng nhập*" />
                    </a-form-item>

                    <a-form-item name="password" :rules="[{ required: true, message: 'Vui lòng nhập mật khẩu!' }]">
                        <a-input-password v-model:value="formState.password" placeholder="Mật khẩu*" />
                    </a-form-item>

                    <div class="form-footer">
                        <a-checkbox v-model:checked="formState.remember">Giữ tôi luôn đăng nhập</a-checkbox>
                        <a href="#" class="forgot-password">Quên mật khẩu?</a>
                    </div>

                    <a-button type="primary" block html-type="submit" :loading="loading">
                        ĐĂNG NHẬP
                    </a-button>
                </a-form>

                <div class="app-download">
<!--                    <p>Cài đặt ứng dụng trên điện thoại</p>-->
                    <div class="store-links">
<!--                        <img src="/google-play.png" alt="Google Play" />-->
<!--                        <img src="/app-store.png" alt="App Store" />-->
                    </div>
                </div>
            </a-card>
        </div>
    </div>
</template>



<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { login as loginApi } from '../api/auth'
import { useUserStore } from '../stores/user'
import { message } from 'ant-design-vue'
import { connectNotifySocket, onNotify } from '@/utils/notify-socket.js'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const hasServerError = ref(false)

const formState = reactive({
    email: '',
    password: '',
    remember: true
})

const onFinish = async () => {
    loading.value = true
    hasServerError.value = false

    try {
        const response = await loginApi(formState.email, formState.password)

        if (response.data.status === 'success') {
            userStore.setUser(response.data.user)
            const user = response.data.user
            const socket = connectNotifySocket(String(user.id))

            onNotify((data) => {
                console.log('🔔 Notify:', data)
                // bạn có thể hiện message hoặc tăng badge ở đây
            })
            await router.push('/project-overview')
        } else {
            showError(response.data.message || 'Đăng nhập thất bại')
        }
    } catch (error) {
        if (error.response) {
            showError(error.response.data?.message || 'Lỗi từ server.')
        } else if (error.request) {
            hasServerError.value = true
        } else {
            showError('Đã xảy ra lỗi không xác định.')
        }
        console.error('[Login error]', error)
    } finally {
        loading.value = false
    }
}

const onFinishFailed = (errorInfo) => {
    console.warn('Form validation failed:', errorInfo)
}

const showError = (msg) => {
    message.error(msg)
}

const reloadPage = () => {
    location.reload()
}
</script>

<style scoped>
.login-mobile {
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: #d6ccfa;
    min-height: 100vh;
    padding: 16px;
}

.login-content {
    width: 100%;
    max-width: 400px;
}

.logo-section {
    text-align: center;
    margin-bottom: 24px;
}

.logo-img {
    height: 48px;
    margin-bottom: 12px;
}

.slogan {
    font-size: 16px;
    font-weight: 500;
    color: #555;
}
.slogan span {
    color: #5a4ae3;
    font-weight: bold;
}
.slogan small {
    color: #f59e0b;
}

.login-card {
    background: #fff;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.08);
}

.language-select {
    position: absolute;
    top: 16px;
    right: 16px;
}

.login-title {
    text-align: left;
    font-weight: 600;
    margin-bottom: 16px;
}

.form-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    font-size: 14px;
}

.forgot-password {
    color: #1890ff;
}

.app-download {
    text-align: center;
    margin-top: 24px;
}

.store-links {
    display: flex;
    justify-content: center;
    gap: 12px;
    margin-top: 8px;
}

.store-links img {
    height: 36px;
    cursor: pointer;
}
</style>


