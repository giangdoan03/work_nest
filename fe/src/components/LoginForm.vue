<template>
    <div class="login-wrapper">
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
                <a-form-item label="Email" name="email" :rules="[
                    { required: true, message: 'Please input your email!' },
                    { type: 'email', message: 'Invalid email format!' }
                ]"
                >
                    <a-input v-model:value="formState.email" placeholder="Enter your email"/>
                </a-form-item>

                <a-form-item label="Password" name="password"
                             :rules="[{ required: true, message: 'Please input your password!' }]">
                    <a-input-password v-model:value="formState.password" placeholder="Enter your password"/>
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
    </div>
</template>

<script setup>
    import {reactive, ref} from 'vue'
    import {useRouter} from 'vue-router'
    import {login as loginApi} from '../api/auth'
    import {useUserStore} from '../stores/user'

    const router = useRouter()
    const userStore = useUserStore()
    const loading = ref(false)

    const formState = reactive({
        email: '',
        password: '',
        remember: true
    })

    const onFinish = async () => {
        loading.value = true
        try {
            const response = await loginApi(formState.email, formState.password)

            if (response.data.status === 'success') {
                userStore.setUser(response.data.user)
                router.push('/dashboard')
            } else {
                alert(response.data.message)
            }
        } catch (error) {
            console.error(error)
            alert('Login failed. Please try again.')
        } finally {
            loading.value = false
        }
    }

    const onFinishFailed = (errorInfo) => {
        console.log('Failed:', errorInfo)
    }
</script>

<style scoped>
    .login-wrapper {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f5f7fa;
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
