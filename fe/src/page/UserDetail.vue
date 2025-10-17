<template>
    <div>
        <a-page-header
            style="padding-left: 0; padding-top: 0"
            title="Chi tiết người dùng"
            @back="() => router.back()"
        />

        <a-card v-if="user" bordered :body-style="{ padding: '16px' }">
            <a-row :gutter="[16,16]">
                <!-- Cột trái: Avatar + Chữ ký -->
                <a-col :xs="24" :md="8" :xl="6">
                    <a-card size="small" bordered class="pane">
                        <div class="center">
                            <a-image
                                :src="avatarUrl"
                                :alt="user.name"
                                :width="132"
                                :preview="{ src: avatarUrl }"
                                :fallback="fallbackAvatar"
                                class="avatar"
                            />
                            <div class="name">{{ user.name }}</div>
                            <div class="badges">
                                <a-tag color="blue" v-if="user.role">{{ user.role }}</a-tag>
                                <a-tag>{{ deptName }}</a-tag>
                            </div>
                        </div>
                        <a-divider />
                        <div class="sig-block">
                            <div class="label">Chữ ký</div>
                            <div class="sig-box">
                                <template v-if="user.signature_url">
                                    <a-image
                                        :src="user.signature_url"
                                        :alt="`Chữ ký - ${user.name}`"
                                        :width="220"
                                        :preview="{ src: user.signature_url, groupName: 'signature' }"
                                        class="signature"
                                    />
                                </template>
                                <template v-else>
                                    <div class="sig-empty">Chưa có chữ ký</div>
                                </template>
                            </div>
                        </div>
                    </a-card>
                </a-col>

                <!-- Cột phải: Thông tin -->
                <a-col :xs="24" :md="16" :xl="18">
                    <a-card size="small" bordered class="pane">
                        <a-descriptions :column="1" bordered size="middle">
                            <a-descriptions-item label="Họ tên">
                                <a-typography-text strong>{{ user.name }}</a-typography-text>
                            </a-descriptions-item>

                            <a-descriptions-item label="Email">
                                <a-typography-paragraph :copyable="{ text: user.email }" style="margin:0">
                                    {{ user.email }}
                                </a-typography-paragraph>
                            </a-descriptions-item>

                            <a-descriptions-item label="Số điện thoại">
                                <a-typography-paragraph :copyable="{ text: user.phone }" style="margin:0">
                                    <span class="mono">{{ user.phone }}</span>
                                </a-typography-paragraph>
                            </a-descriptions-item>

                            <a-descriptions-item label="Phòng ban">
                                {{ deptName }}
                            </a-descriptions-item>

                            <a-descriptions-item label="Quyền / Vai trò">
                                <a-space wrap>
                                    <a-tag color="blue" v-if="user.role_id">#{{ user.role_id }}</a-tag>
                                    <a-tag v-if="user.role">{{ user.role }}</a-tag>
                                </a-space>
                            </a-descriptions-item>

                            <a-descriptions-item label="Tạo lúc">
                                <a-typography-text code>{{ fmtDate(user.created_at) }}</a-typography-text>
                            </a-descriptions-item>

                            <a-descriptions-item label="Cập nhật lúc">
                                <a-typography-text code>{{ fmtDate(user.updated_at) }}</a-typography-text>
                            </a-descriptions-item>

                            <a-descriptions-item label="ID">
                                <a-typography-text keyboard>#{{ user.id }}</a-typography-text>
                            </a-descriptions-item>
                        </a-descriptions>
                    </a-card>
                </a-col>
            </a-row>
        </a-card>

        <a-skeleton active v-else />
    </div>
</template>

<script setup>
import {computed, onMounted, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import { getUserDetail, getUsers } from '@/api/user'
import {getDepartments} from '@/api/department'

const route = useRoute()
const router = useRouter()

const user = ref(null)
const departments = ref([])

// base API (để ghép avatar relative -> absolute)
const API_BASE = import.meta.env.VITE_API_URL?.replace(/\/+$/, '') || ''

const fallbackAvatar =
    'data:image/svg+xml;utf8,' +
    encodeURIComponent(`<svg xmlns='http://www.w3.org/2000/svg' width='128' height='128'>
  <rect width='100%' height='100%' fill='#f0f2f5'/>
  <text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' font-size='16' fill='#999'>No Avatar</text>
</svg>`)

const fmtDate = (str) => {
    if (!str) return '—'
    const d = new Date(str)
    return isNaN(d.getTime()) ? String(str) : d.toLocaleString('vi-VN')
}

const deptName = computed(() => {
    if (!user.value) return '—'
    const found = departments.value.find(d => String(d.id) === String(user.value.department_id))
    return found?.name || `Phòng ban #${user.value.department_id ?? '—'}`
})

// Chuẩn hoá URL avatar: nếu backend trả "uploads/avatars/xxx.png" thì nối với API_BASE gốc (bỏ /api)
const avatarUrl = computed(() => {
    const raw = user.value?.avatar
    if (!raw) return ''
    // nếu đã là http(s)
    if (/^https?:\/\//i.test(raw)) return raw
    // nếu backend trả relative "uploads/..." và VITE_API_URL kết thúc bằng "/api"
    const origin = API_BASE.replace(/\/api$/i, '')
    return `${origin}/${raw.replace(/^\/+/, '')}`
})

const fetchUser = async () => {
    const id = route.params.id

    try {
        // 🔹 Ưu tiên gọi /users/:id
        const res = await getUserDetail(id)
        user.value = res?.data?.data || res?.data || {}
    } catch (err) {
        console.warn('⚠️ getUserDetail lỗi, fallback sang getUsers()', err)

        try {
            // 🔹 fallback: tải toàn bộ danh sách và lọc theo id
            const res = await getUsers()
            const all = Array.isArray(res.data)
                ? res.data
                : res.data?.data || []

            user.value = all.find(u => String(u.id) === String(id)) || null
        } catch (e) {
            console.error('❌ Fallback getUsers() cũng lỗi:', e)
            user.value = null
        }
    }
}


const fetchDepartments = async () => {
    const res = await getDepartments().catch(() => null)
    departments.value = res?.data || []
}

onMounted(async () => {
    await Promise.all([fetchUser(), fetchDepartments()])
})
</script>

<style scoped>
.pane { border-radius: 10px; }
.center { display:flex; flex-direction:column; align-items:center; }
.avatar { border-radius: 999px; overflow: hidden; }
.name { font-weight: 600; margin-top: 10px; font-size: 16px; }
.badges { margin-top: 6px; display:flex; gap:8px; flex-wrap: wrap; justify-content:center; }

.sig-block .label { font-weight: 600; margin-bottom: 6px; }
.sig-box { display:flex; justify-content:center; align-items:center; min-height:120px; background:#fafafa; border:1px dashed #e5e7eb; border-radius:8px; padding:8px; }
.signature { max-height: 120px; object-fit: contain; }
.sig-empty { color:#999; }

.mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace; }
.truncate { max-width: 100%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
</style>
