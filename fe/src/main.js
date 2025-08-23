import { createApp } from 'vue'
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

import App from './App.vue'
import router from './router'
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'
import './styles/global.css'

const app = createApp(App)

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

app.use(pinia)
app.use(router)
app.use(Antd)

// 🔹 Title động theo route meta
const APP_NAME = import.meta.env.VITE_APP_TITLE || 'Work Nest'
router.afterEach((to) => {
    const rawTitle = typeof to.meta?.title === 'function'
        ? to.meta.title(to)
        : (to.meta?.title || to.meta?.breadcrumb || '')
    document.title = rawTitle ? `${rawTitle} · ${APP_NAME}` : APP_NAME
})

app.mount('#app')
