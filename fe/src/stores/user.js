import { defineStore } from 'pinia'
import { getPermissionMatrix } from '@/api/permission.js'

export const useUserStore = defineStore('user', {
    state: () => ({
        user: null,
        permissions: {}
    }),

    getters: {
        currentUser: (state) => state.user,
        hasPermission: (state) => {
            return (module, action) => {
                return !!(state.permissions[module] && state.permissions[module][action])
            }
        }
    },

    actions: {
        setUser(user) {
            this.user = user
        },
        clearUser() {
            this.user = null
            this.permissions = {}

            // Xoá pinia persist (tuỳ key bạn cấu hình)
            localStorage.removeItem('user')
            localStorage.removeItem('userStore')

            // Nếu bạn cache quyền theo role_id thì có thể dọn thêm:
            Object.keys(localStorage).forEach(key => {
                if (key.startsWith('permissions_')) {
                    localStorage.removeItem(key)
                }
            })
        },

        async fetchPermissions(force = false) {
            const cacheKey = `permissions_${this.user?.role_id}`

            if (!this.user?.role_id) return

            // Thử lấy từ localStorage
            if (!force && Object.keys(this.permissions).length === 0) {
                const cached = localStorage.getItem(cacheKey)
                if (cached) {
                    this.permissions = JSON.parse(cached)
                    return
                }
            }

            try {
                const res = await getPermissionMatrix(this.user.role_id)
                this.permissions = res.data.data || {}

                // Cache lại
                localStorage.setItem(cacheKey, JSON.stringify(this.permissions))
            } catch (err) {
                console.error('Lỗi khi lấy quyền:', err)
                this.permissions = {}
            }
        }

    },

    persist: {
        enabled: true,
        strategies: [
            {
                storage: localStorage,
                paths: ['user', 'permissions']
            }
        ]
    }
})
