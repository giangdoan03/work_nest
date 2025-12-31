import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

export default defineConfig({
    plugins: [
        vue(),
        vueDevTools(),
    ],

    base: '/', // để path asset tuyệt đối

    server: {
        host: 'worknest.local',
        port: 5173,
        allowedHosts: ['worknest.local'],
        proxy: {
            '/api': {
                target: 'http://api.worknest.local',
                changeOrigin: true,
                // nếu API là HTTP self-signed:
                // secure: false,
                // Nếu cần rewrite prefix:
                // rewrite: path => path.replace(/^\/api/, '/api'),
                // Tip: "credentials" không phải option hợp lệ của proxy http-proxy
                // Cookie/CORS xử lý phía BE bằng CORS headers + SameSite
            },
            '/pdf-proxy': {
                target: 'https://assets.develop.io.vn',
                changeOrigin: true,
                secure: false,
                rewrite: (path) => path.replace(/^\/pdf-proxy/, ''), // giữ nguyên phần còn lại
            },
        },
    },

    resolve: {
        alias: {
            '@': fileURLToPath(new URL('./src', import.meta.url)),
        },
    },

    optimizeDeps: {
        include: [
            'quill',
            'pdfjs-dist',
            'pdfjs-dist/build/pdf.worker.min.mjs',
        ],
    },

    build: {
        target: 'es2019',
        sourcemap: false,
        brotliSize: false,
        chunkSizeWarningLimit: 1500, // chỉ cảnh báo, không ảnh hưởng build

        rollupOptions: {
            output: {
                manualChunks(id) {
                    if (id.includes('node_modules')) {
                        if (id.includes('/vue')) return 'vue'
                        if (id.includes('ant-design-vue')) return 'antdv'
                        if (id.includes('dayjs')) return 'dayjs'
                        if (id.includes('lodash-es')) return 'lodash'
                        return 'vendor'
                    }
                    // có thể tách theo page nặng nếu muốn:
                    // if (id.includes('/src/components/task/')) return 'task';
                    // if (id.includes('/src/page/Bid')) return 'bid';
                },
                // tên file gọn gàng, cache tốt
                entryFileNames: 'assets/[name]-[hash].js',
                chunkFileNames: 'assets/[name]-[hash].js',
                assetFileNames: 'assets/[name]-[hash][extname]',
            },
        },
        cssCodeSplit: true,
        // terserOptions: { compress: { drop_console: true, pure_funcs: ['console.log'] } },
    },
})
