<template>
    <div>
        <a-page-header title="Chi tiết khách hàng" @back="$router.back()" />

        <a-descriptions v-if="customer" bordered :column="1" size="small" title="Thông tin khách hàng">
            <a-descriptions-item label="Tên khách hàng">{{ customer.name }}</a-descriptions-item>
            <a-descriptions-item label="Email">{{ customer.email }}</a-descriptions-item>
            <a-descriptions-item label="Số điện thoại">{{ customer.phone }}</a-descriptions-item>
            <a-descriptions-item label="Địa chỉ">{{ customer.address }}</a-descriptions-item>
        </a-descriptions>

        <a-spin v-else />
    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue'
    import { useRoute } from 'vue-router'
    import { getCustomer } from '@/api/customer'
    import { message } from 'ant-design-vue'

    const route = useRoute()
    const customer = ref(null)

    onMounted(async () => {
        const id = route.params.id
        if (!id) {
            message.error('Không có ID khách hàng')
            return
        }

        try {
            const res = await getCustomer(id)
            customer.value = res.data?.data ?? res.data
        } catch (e) {
            message.error('Không tìm thấy khách hàng')
        }
    })
</script>
