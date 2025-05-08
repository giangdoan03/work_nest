<template>
    <a-form layout="vertical" v-if="form">
        <a-form-item label="Chọn sản phẩm">
            <a-select
                v-model:value="form.target_id"
                placeholder="Chọn sản phẩm"
                :options="productOptions"
                show-search
                :filter-option="filterOption"
            >
                <template #option="{ label, avatar, status, disabled }">
                    <div style="display: flex; align-items: center; gap: 8px;" :style="{ opacity: disabled ? 0.5 : 1 }">
                        <img :src="avatar" alt="avatar" style="width: 28px; height: 28px; object-fit: cover; border-radius: 4px;" />
                        <div style="flex: 1;">{{ label }}</div>
                        <a-tag :color="status === 1 ? 'green' : 'red'">{{ status === 1 ? 'Đang kích hoạt' : 'Chưa kích hoạt' }}</a-tag>
                    </div>
                </template>
            </a-select>


        </a-form-item>

        <a-form-item label="Nhập tên cho QR của bạn (tuỳ chọn)">
            <a-input v-model:value="form.qr_name" placeholder="Nhập tên cho QR..." />
        </a-form-item>
    </a-form>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { getProducts } from '@/api/product.js'

// Model nhận từ component cha
const form = defineModel()

// Danh sách sản phẩm
const productOptions = ref([])

const filterOption = (input, option) => {
    return option.label.toLowerCase().includes(input.toLowerCase())
}

// Tải sản phẩm từ API
const fetchProducts = async () => {
    try {
        const res = await getProducts({ per_page: 1000 })
        productOptions.value = (res.data?.data || [])
            // .filter(product => Number(product.status) === 1) // 👉 Chỉ lấy sản phẩm đã kích hoạt
            .map(product => ({
                label: product.name,
                value: Number(product.id),
                avatar: JSON.parse(product.avatar || '[]')[0],
                status: Number(product.status),
                disabled: Number(product.status) !== 1, // 👈 disable option nếu chưa kích hoạt
            }))
    } catch (err) {
        console.error('Lỗi tải sản phẩm:', err)
    }
}

// Đảm bảo target_id luôn là số
watch(() => form?.target_id, (val) => {
    if (typeof val === 'string') {
        form.target_id = Number(val)
    }
})

onMounted(fetchProducts)
</script>
