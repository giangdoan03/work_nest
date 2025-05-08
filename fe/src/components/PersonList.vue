<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-input v-model:value="search" placeholder="Tìm kiếm cá nhân..." @pressEnter="fetchPersons" />
            <a-button type="primary" @click="fetchPersons">Tìm kiếm</a-button>
            <a-button type="primary" @click="goToCreate">Tạo mới</a-button>
        </a-space>

        <a-table
            :columns="columns"
            :data-source="persons"
            :pagination="pagination"
            :loading="loading"
            row-key="id"
            @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'avatar'">
                    <img :src="record.avatar" alt="avatar" style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px" />
                </template>
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="goToEdit(record.id)">Sửa</a-button>
                        <a-popconfirm title="Xác nhận xoá?" @confirm="deletePerson(record.id)">
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
import { getPersons, deletePerson as apiDeletePerson } from '../api/person'
import { message } from 'ant-design-vue'

const router = useRouter()
const persons = ref([])
const loading = ref(false)
const search = ref('')
const pagination = ref({ current: 1, pageSize: 10, total: 0 })

const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: 'Ảnh đại diện', dataIndex: 'avatar', key: 'avatar' },
    { title: 'Tên', dataIndex: 'name', key: 'name' },
    { title: 'Email', dataIndex: 'email', key: 'email' },
    { title: 'Số điện thoại', dataIndex: 'phone', key: 'phone' },
    { title: 'Chức danh', dataIndex: 'job_title', key: 'job_title' },
    { title: 'Hành động', key: 'action' },
]

const fetchPersons = async () => {
    loading.value = true
    try {
        const response = await getPersons({
            page: pagination.value.current,
            per_page: pagination.value.pageSize,
            search: search.value,
        })

        // 👇 Nếu API trả về mảng đơn giản, không có .data.data thì sửa như sau:
        persons.value = Array.isArray(response.data) ? response.data : response.data.data || []

        // 👇 Nếu không có phân trang từ backend thì bỏ dòng này:
        pagination.value.total = response.data.pager?.total || response.data.length || 0

    } catch (e) {
        message.error('Lỗi tải danh sách cá nhân')
    } finally {
        loading.value = false
    }
}


const handleTableChange = (p) => {
    pagination.value.current = p.current
    pagination.value.pageSize = p.pageSize
    fetchPersons()
}

const goToCreate = () => router.push('/persons/create')
const goToEdit = (id) => router.push(`/persons/${id}/edit`)

const deletePerson = async (id) => {
    try {
        await apiDeletePerson(id)
        message.success('Đã xoá cá nhân')
        fetchPersons()
    } catch (e) {
        message.error('Xoá thất bại')
    }
}

onMounted(fetchPersons)
</script>
