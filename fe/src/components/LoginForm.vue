<template>
    <div class="login-wrapper">
        <template v-if="hasServerError">
            <a-result status="500" title="500" sub-title="Sorry, the server is not responding.">
                <template #extra>
                    <a-button type="primary" @click="reloadPage">Reload Page</a-button>
                </template>
            </a-result>
        </template>

        <template v-else>
            <a-card class="login-card" :bordered="false">
                <h2 class="login-title">Welcome Back 👋</h2>

                <a-form
                    :model="formState"
                    name="login-form"
                    autocomplete="off"
                    layout="vertical"
                    @finish="onFinish"
                    @finishFailed="onFinishFailed"
                >
                    <a-form-item
                        label="Email"
                        name="email"
                        :rules="[
              { required: true, message: 'Please input your email!' },
              { type: 'email', message: 'Invalid email format!' }
            ]"
                    >
                        <a-input v-model:value="formState.email" placeholder="Enter your email" />
                    </a-form-item>

                    <a-form-item
                        label="Password"
                        name="password"
                        :rules="[{ required: true, message: 'Please input your password!' }]"
                    >
                        <a-input-password v-model:value="formState.password" placeholder="Enter your password" />
                    </a-form-item>

                    <a-form-item name="remember">
                        <a-checkbox v-model:checked="formState.remember">Remember me</a-checkbox>
                    </a-form-item>

                    <a-form-item>
                        <a-button type="primary" html-type="submit" block :loading="loading">
                            Login
                        </a-button>
                    </a-form-item>
                </a-form>
            </a-card>
        </template>
    </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { login as loginApi } from '../api/auth'
import { useUserStore } from '../stores/user'
import { message } from 'ant-design-vue'

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
.login-wrapper {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #f5f7fa;
    padding: 24px;
}

.login-card {
    width: 100%;
    max-width: 400px;
    border-radius: 12px;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
    padding: 24px;
}

.login-title {
    text-align: center;
    margin-bottom: 24px;
    font-size: 24px;
    font-weight: 600;
    color: #333;
}
</style>
