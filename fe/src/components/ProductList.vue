<template>
    <div>
        <a-space style="margin-bottom: 16px;">
            <a-input v-model:value="search" placeholder="Tìm kiếm sản phẩm..." @pressEnter="fetchProducts" />
            <a-button type="primary" @click="fetchProducts">Tìm kiếm</a-button>
            <a-button type="primary" @click="goToCreate">Thêm sản phẩm</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="products"
            :pagination="pagination"
            row-key="id"
            :loading="loading"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <!-- Cột ảnh đại diện -->
                <template v-if="column.key === 'avatar'">
                    <img v-if="getAvatarUrl(record.avatar)"
                         :src="getAvatarUrl(record.avatar)"
                         alt="Avatar"
                         style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;" />
                </template>

                <!-- Cột trạng thái -->
                <template v-if="column.key === 'status'">
                    <a-switch
                            :checked="record.status == 1"
                            @change="checked => toggleStatus(record, checked)"
                            checked-children="Bật"
                            un-checked-children="Tắt" />
                </template>

                <!-- Cột hành động -->
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="goToEdit(record.id)">Sửa</a-button>
                        <a-popconfirm title="Xác nhận xoá?" @confirm="deleteProduct(record.id)">
                            <a-button type="link" danger>Xoá</a-button>
                        </a-popconfirm>
                    </a-space>
                </template>
            </template>

        </a-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {getProducts, deleteProduct as apiDeleteProduct, updateProduct, updateProductStatus } from '../api/product'
import { message } from 'ant-design-vue'

// Router
const router = useRouter()

// State
const products = ref([])
const loading = ref(false)
const search = ref('')
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

// Columns table
const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: 'Ảnh đại diện', dataIndex: 'avatar', key: 'avatar' },
    {
        title: 'Tên sản phẩm',
        dataIndex: 'name',
        key: 'name',
        ellipsis: true,
        customRender: ({ text }) => text || 'Không có tên'
    },
    { title: 'SKU', dataIndex: 'sku', key: 'sku' },
    {
        title: 'Giá',
        dataIndex: 'price',
        key: 'price',
        customRender: ({ text }) => text ? formatCurrency(text) : '0 VND'
    },
    {
        title: 'Ngày tạo',
        dataIndex: 'created_at',
        key: 'created_at',
        customRender: ({ text }) => text ? formatDate(text) : 'N/A'
    },
    {
        title: 'Ngày cập nhật',
        dataIndex: 'updated_at',
        key: 'updated_at',
        customRender: ({ text }) => text ? formatDate(text) : 'N/A'
    },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
    { title: 'Hành động', key: 'action' }
]




// Fetch data
const fetchProducts = async () => {
    loading.value = true
    try {
        const response = await getProducts({
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: search.value,
        })

        const result = response.data?.data || []

        result.forEach((p, i) => {
            if (!p) console.warn(`Null product at index ${i}`)
            if (!p?.price) console.warn(`Missing price at index ${i}`, p)
        })

        products.value = result.filter(p => p && p.name)

        pagination.value.total = response.data?.pager?.total || 0
    } catch (error) {
        message.error('Lỗi tải sản phẩm')
        console.error('Fetch Error:', error)
    } finally {
        loading.value = false
    }
}


const getAvatarUrl = (avatar) => {
    if (!avatar) return null
    try {
        const parsed = JSON.parse(avatar)
        if (Array.isArray(parsed) && parsed.length) {
            return parsed[0]
        } else if (typeof parsed === 'string') {
            return parsed
        }
    } catch {
        // Nếu không phải JSON, trả về trực tiếp
        return avatar.replace(/(^"|"$)/g, '') // Loại bỏ dấu nháy nếu có
    }
    return null
}

// Table change
const handleTableChange = (paginationParam) => {
    pagination.value.current = paginationParam.current
    pagination.value.pageSize = paginationParam.pageSize
    fetchProducts()
}

// Router actions
const goToCreate = () => router.push('/products/create')
const goToEdit = (id) => router.push(`/products/${id}/edit`)

// Delete
const deleteProduct = async (id) => {
    try {
        await apiDeleteProduct(id)
        message.success('Đã xoá sản phẩm')
        await fetchProducts()
    } catch (error) {
        message.error('Lỗi xoá sản phẩm')
    }
}

// Parse JSON safely
const parseJson = (value) => {
    try {
        return JSON.parse(value)
    } catch {
        return []
    }
}

// Format tiền VND
const formatCurrency = (value) => {
    if (!value) return ''
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value)
}

// Format ngày giờ Việt Nam
const formatDate = (value) => {
    if (!value) return ''
    const date = new Date(value)
    return date.toLocaleString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false,
    })
}

const toggleStatus = async (record, checked) => {
    try {
        await updateProductStatus(record.id, { status: checked ? 1 : 0 })
        record.status = checked ? 1 : 0
        message.success(`Đã ${checked ? 'bật' : 'tắt'} sản phẩm`)
    } catch (e) {
        message.error('Không thể cập nhật trạng thái')
    }
}



// Init
onMounted(fetchProducts)
</script>
