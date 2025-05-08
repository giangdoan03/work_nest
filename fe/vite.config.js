import {fileURLToPath, URL} from 'node:url'

import {defineConfig} from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
    plugins: [
        vue(),
        vueDevTools(),
    ],
    base: '/', // quan trọng để đúng path
    server: {
        host: 'worknest.local',
        port: 5173,
        allowedHosts: ['worknest.local'], // 👈 thêm dòng này
    },
    proxy: {
        '/api': {
            target: 'http://api.worknest.local',
            changeOrigin: true,
            credentials: true, // 👈 Thêm dòng này
        },
    },
    resolve: {
        alias: {
            '@': fileURLToPath(new URL('./src', import.meta.url))
        },
    },
    optimizeDeps: {
        include: ['quill']
    }
})
