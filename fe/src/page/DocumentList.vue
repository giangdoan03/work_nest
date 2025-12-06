<template>
    <div>
        <a-card>
            <!-- Filters -->
            <!-- BACK BUTTON -->
            <div class="header-row">
                <a-button class="back-btn" @click="router.back()">
                    ← Quay lại
                </a-button>

                <h2 class="page-title">Quản lý tài liệu</h2>
            </div>

            <!-- Filters -->
            <a-space style="margin-bottom: 16px" direction="vertical" size="middle">
                <a-space>
                    <a-select
                        v-model:value="filters.department_id"
                        style="width: 220px"
                        placeholder="Phòng ban"
                        :options="departments"
                        allowClear
                    />
                    <a-range-picker
                        v-model:value="filters.dateRange"
                        :placeholder="['Từ ngày', 'Đến ngày']"
                        :getPopupContainer="triggerNode => triggerNode.parentNode"
                    />
                    <a-input
                        v-model:value="filters.title"
                        placeholder="Tìm theo tiêu đề"
                        style="width: 240px"
                        @pressEnter="fetchDocuments"
                    >
                        <template #prefix><SearchOutlined /></template>
                    </a-input>

                    <a-button type="primary" @click="fetchDocuments">Tìm kiếm</a-button>
                </a-space>
            </a-space>

            <!-- Table -->
            <a-table
                :columns="columns"
                :data-source="documents"
                :pagination="pagination"
                :loading="loading"
                row-key="id"
                @change="handleTableChange"
            >
                <template #bodyCell="{ column, record }">
                    <!-- CỘT NGƯỜI TRUY CẬP -->
                    <template v-if="column.key === 'allowed_users'">
                        <a-avatar-group :maxCount="5">
                            <template v-for="uid in record.allowed_users" :key="uid">
                                <a-tooltip :title="getUserName(uid)">
                                    <BaseAvatar
                                        :src="getUser(uid)?.avatar"
                                        :name="getUser(uid)?.name"
                                        :size="32"
                                        shape="circle"
                                        :preferApiOrigin="true"
                                    />
                                </a-tooltip>
                            </template>
                        </a-avatar-group>
                    </template>
                    <template v-if="column.key === 'action'">
                        <a-space>
                            <!-- Đi tới trang chi tiết -->
                            <a-tooltip title="Xem chi tiết">
                                <a-button type="link" @click="goDetail(record)">
                                    <EyeOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Sửa -->
                            <a-tooltip title="Sửa">
                                <a-button type="link" @click="editDocument(record.id)">
                                    <EditOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Xoá -->
                            <a-popconfirm title="Xác nhận xoá?" @confirm="deleteDoc(record.id)">
                                <a-tooltip title="Xoá">
                                    <a-button type="link" danger>
                                        <DeleteOutlined />
                                    </a-button>
                                </a-tooltip>
                            </a-popconfirm>
                        </a-space>
                    </template>
                </template>
            </a-table>

            <!-- Edit modal -->
            <a-modal
                v-model:open="editModalVisible"
                title="Chỉnh sửa tài liệu"
                @ok="submitEdit"
                @cancel="resetEditForm"
                :confirm-loading="editLoading"
                ok-text="Cập nhật"
                cancel-text="Hủy"
            >
                <a-form layout="vertical">
                    <a-form-item label="Tiêu đề">
                        <a-input v-model:value="editForm.title" placeholder="Nhập tiêu đề" />
                    </a-form-item>

                    <a-form-item label="Phòng ban">
                        <a-select
                            v-model:value="editForm.department_id"
                            :options="departments"
                            placeholder="Chọn phòng ban"
                        />
                    </a-form-item>

                    <a-form-item label="Đường dẫn file">
                        <a-input v-model:value="editForm.file_path" placeholder="Link tài liệu" />
                    </a-form-item>

                    <a-form-item label="Quyền truy cập">
                        <a-select v-model:value="editForm.visibility">
                            <a-select-option value="private">Riêng tư</a-select-option>
                            <a-select-option value="public">Công khai</a-select-option>
                            <a-select-option value="department">Theo phòng ban</a-select-option>
                            <a-select-option value="custom">Tùy chỉnh</a-select-option>
                        </a-select>
                    </a-form-item>
                </a-form>
            </a-modal>
        </a-card>
    </div>
</template>

<script setup>
import { ref, onMounted, h } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { getDocuments, deleteDocument, updateDocument } from '../api/document'
import { getUsers } from '@/api/user'
import dayjs from "dayjs";
import BaseAvatar from '../components/common/BaseAvatar.vue'
import {
    EyeOutlined,
    EditOutlined,
    DeleteOutlined,
    SearchOutlined
} from '@ant-design/icons-vue'

const router = useRouter()

// ===== State =====
const documents = ref([])
const loading = ref(false)
const pagination = ref({ current: 1, pageSize: 10, total: 0 })
const users = ref([])

const getUser = (id) => users.value.find(u => u.id == id) || null
const getUserName = (id) => getUser(id)?.name ?? "Chưa có tên"
const filters = ref({
    department_id: null,
    dateRange: [],
    title: ''
})

const currentUser = ref(null)

const loadCurrentUser = () => {
    const raw = localStorage.getItem("user");
    if (raw) currentUser.value = JSON.parse(raw).user;
}


const formatDate = (dateString) => {
    return dateString ? dayjs(dateString).format("DD/MM/YYYY HH:mm") : "";
};
const departments = ref([
    { label: 'Nhân sự', value: 1 },
    { label: 'Kinh doanh', value: 2 }
])

// ===== Helpers =====
const baseURL = import.meta.env.VITE_API_URL
const safeUrl = (p = '') => {
    if (!p) return ''
    const path = String(p).trim()
    return /^https?:\/\//i.test(path) ? path : `${baseURL}/${path}`
}
const normalizeUrl = (u = '') => {
    const s = u.trim()
    if (!s) return ''
    return /^https?:\/\//i.test(s) ? s : `https://${s}`
}

// tag màu cho visibility
const visColor = v => ({
    private: 'red', department: 'blue', custom: 'gold', public: 'green'
}[String(v || '').toLowerCase()] || 'default')

// ===== Columns =====
const columns = [
    { title: "#", dataIndex: "id", key: "id", width: 70 },
    { title: "Tiêu đề", dataIndex: "title", key: "title" },
    { title: "Phòng ban", dataIndex: "department_name", key: "department_name" },

    { title: "Người truy cập", key: "allowed_users" },

    {
        title: "Ngày upload",
        key: "created_at",
        dataIndex: "created_at",
        customRender: ({ text }) => formatDate(text)
    },

    { title: "Tác vụ", key: "action", width: 220 }
];


// ===== API =====
const fetchDocuments = async () => {
    loading.value = true;

    const params = {
        user_id: currentUser.value?.id,     // ⭐ quan trọng
        department_id: filters.value.department_id,
        title: filters.value.title
    }

    const res = await getDocuments(params);
    documents.value = res.data;
    loading.value = false;
};

const handleTableChange = (p) => {
    pagination.value.current = p.current
    pagination.value.pageSize = p.pageSize
    fetchDocuments()
}

const deleteDoc = async (id) => {
    try {
        await deleteDocument(id)
        message.success('Đã xoá tài liệu')
        await fetchDocuments()
        // nếu trang hiện tại rỗng -> lùi 1 trang
        if (!documents.value.length && pagination.value.current > 1) {
            pagination.value.current--
            await fetchDocuments()
        }
    } catch (e) {
        console.error(e)
        message.error('Xoá thất bại')
    }
}

// ===== Điều hướng tới trang chi tiết =====
const goDetail = (doc) => {
    if (!doc?.id) return
    router.push({ name: 'document.detail', params: { id: doc.id } })
}

// ===== Mở link gốc / Sao chép link =====
const openOriginal = (doc) => {
    const url = safeUrl(doc?.file_path || '')
    if (!url) return
    window.open(url, '_blank', 'noopener')
}
const copyLink = async (doc) => {
    const url = safeUrl(doc?.file_path || '')
    if (!url) return
    try {
        if (navigator.clipboard?.writeText) {
            await navigator.clipboard.writeText(url)
        } else {
            const input = document.createElement('input')
            input.value = url
            document.body.appendChild(input)
            input.select()
            document.execCommand('copy')
            document.body.removeChild(input)
        }
        message.success('Đã sao chép link vào clipboard!')
    } catch {
        message.error('Không sao chép được link.')
    }
}

// ===== Edit modal =====
const editModalVisible = ref(false)
const editLoading = ref(false)
const editForm = ref({
    id: null,
    title: '',
    department_id: null,
    file_path: '',
    visibility: 'private'
})

const editDocument = (id) => {
    const doc = documents.value.find(d => d.id === id)
    if (!doc) return
    editForm.value = {
        id: doc.id,
        title: doc.title,
        department_id: doc.department_id,
        file_path: doc.file_path,
        visibility: doc.visibility || 'private'
    }
    editModalVisible.value = true
}

const submitEdit = async () => {
    editLoading.value = true
    try {
        const { id, ...data } = editForm.value
        data.file_path = normalizeUrl(data.file_path) // chuẩn hoá link
        await updateDocument(id, data)
        message.success('Cập nhật thành công')
        await fetchDocuments()
        editModalVisible.value = false
    } catch (e) {
        console.error(e)
        message.error('Cập nhật thất bại')
    } finally {
        editLoading.value = false
    }
}

const resetEditForm = () => {
    editForm.value = { id: null, title: '', department_id: null, file_path: '', visibility: 'private' }
    editModalVisible.value = false
}
const loadUsers = async () => {
    const res = await getUsers()
    users.value = res.data
}

onMounted(async () => {
    loadCurrentUser()
    await loadUsers()
    await fetchDocuments()
})

</script>

<style>
.header-row {
    display: flex;
    align-items: center;
    justify-content: flex-start;
    gap: 16px;
    margin-bottom: 12px;
}

.back-btn {
    display: flex;
    align-items: center;
    font-size: 14px;
}

.page-title {
    margin: 0;
    font-size: 20px;
    font-weight: 600;
}

</style>
