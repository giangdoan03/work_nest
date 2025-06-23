<template>
    <div>
        <a-page-header title="Chi tiết người dùng" @back="() => router.back()" />

        <a-descriptions bordered :column="1" v-if="user">
            <a-descriptions-item label="Họ tên">{{ user.name }}</a-descriptions-item>
            <a-descriptions-item label="Email">{{ user.email }}</a-descriptions-item>
            <a-descriptions-item label="Số điện thoại">{{ user.phone }}</a-descriptions-item>
            <a-descriptions-item label="Phòng ban">{{ getDepartmentName(user.department_id) }}</a-descriptions-item>
        </a-descriptions>

        <a-skeleton active v-else />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getUsers } from '@/api/user'
import { getDepartments } from '@/api/department'

const user = ref(null)
const departments = ref([])
const route = useRoute()
const router = useRouter()

const fetchUser = async () => {
    const res = await getUsers()
    const all = Array.isArray(res.data) ? res.data : res.data?.data || []
    user.value = all.find(u => String(u.id) === String(route.params.id))
}

const fetchDepartments = async () => {
    const res = await getDepartments()
    departments.value = res.data || []
}

const getDepartmentName = (id) => {
    const found = departments.value.find(d => d.id === id)
    return found?.name || `Phòng ban #${id}`
}

onMounted(() => {
    fetchUser()
    fetchDepartments()
})
</script>
