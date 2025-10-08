<template>
    <div>
        <a-card>
            <a-space style="margin-bottom: 16px" direction="vertical" size="middle">
                <a-space>
                    <a-select
                        v-model:value="selectedDept"
                        :options="departmentOptions"
                        placeholder="Chọn phòng ban"
                        style="min-width: 240px"
                        @change="fetchDocuments"
                        allowClear
                    />
                    <a-input
                        v-model:value="filterTitle"
                        placeholder="Lọc theo tiêu đề"
                        style="min-width: 200px"
                    />
                    <a-button ref="uploadBtn" type="primary" @click="showUploadModal">
                        Upload tài liệu
                    </a-button>
                </a-space>
            </a-space>
            <a-table
                :columns="columns"
                :data-source="filteredDocs"
                row-key="id"
                :loading="loading"
                :pagination="{ pageSize: 10 }"
            >
                <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'action'">
                        <a-space>
                            <!-- Đi tới trang chi tiết -->
                            <a-tooltip title="Xem chi tiết">
                                <a-button type="link" @click="goDetail(record)">
                                    <EyeOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Xem nhanh trong modal -->
                            <a-tooltip title="Xem nhanh">
                                <a-button type="link" @click="openDetailModal(record)">
                                    <InfoCircleOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Mở link gốc -->
                            <a-tooltip title="Mở link gốc">
                                <a-button type="link" @click="openOriginal(record)" :disabled="!record.file_path">
                                    <ExportOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Sao chép link -->
                            <a-tooltip title="Sao chép link">
                                <a-button type="link" @click="copyLink(record)" :disabled="!record.file_path">
                                    <CopyOutlined />
                                </a-button>
                            </a-tooltip>

                            <!-- Sửa -->
                            <a-tooltip title="Sửa">
                                <a-button type="link" @click="editDoc(record)">
                                    <EditOutlined />
                                </a-button>
                            </a-tooltip>
                        </a-space>
                    </template>
                </template>
            </a-table>
        </a-card>


        <!-- Modal thêm / sửa tài liệu -->
        <a-modal
            v-model:open="uploadVisible"
            :title="isEditMode ? 'Sửa tài liệu' : 'Thêm tài liệu'"
            @ok="submitUpload"
            @cancel="closeModal"
            :destroyOnClose="true"
            @afterClose="onModalClosed"
            okText="Lưu tài liệu"
            cancelText="Huỷ"
        >
            <a-form layout="vertical">
                <a-form-item label="Tiêu đề">
                    <a-input v-model:value="uploadForm.title" />
                </a-form-item>

                <a-form-item label="Phòng ban">
                    <a-select v-model:value="uploadForm.department_id" :options="departmentOptions" />
                </a-form-item>

                <a-form-item label="Chế độ chia sẻ">
                    <a-radio-group v-model:value="uploadForm.visibility">
                        <a-radio value="private">Chỉ mình tôi</a-radio>
                        <a-radio value="department">Phòng ban</a-radio>
                        <a-radio value="custom">Tùy chỉnh</a-radio>
                    </a-radio-group>
                </a-form-item>

                <a-form-item v-if="uploadForm.visibility === 'custom'" label="Chia sẻ với người dùng">
                    <a-select
                        v-model:value="uploadForm.shared_users"
                        mode="multiple"
                        :options="userOptions"
                        placeholder="Chọn người dùng"
                        style="width: 100%"
                    />
                </a-form-item>

                <a-form-item v-if="uploadForm.visibility === 'custom'" label="Chia sẻ với phòng ban">
                    <a-select
                        v-model:value="uploadForm.shared_departments"
                        mode="multiple"
                        :options="departmentOptions"
                        placeholder="Chọn phòng ban"
                        style="width: 100%"
                    />
                </a-form-item>

                <a-form-item label="Link tài liệu">
                    <a-input v-model:value="uploadForm.fileUrl" placeholder="Nhập link tài liệu (VD: https://...)" />
                </a-form-item>
            </a-form>
        </a-modal>

        <!-- Modal xem nhanh chi tiết -->
        <a-modal
            v-model:open="detailVisible"
            title="Chi tiết tài liệu"
            :footer="null"
            @cancel="detailVisible = false"
        >
            <a-descriptions bordered size="small" :column="1" v-if="selectedDoc">
                <a-descriptions-item label="Tiêu đề">{{ selectedDoc.title }}</a-descriptions-item>
                <a-descriptions-item label="Phòng ban">{{ selectedDoc.department_name }}</a-descriptions-item>
                <a-descriptions-item label="Người upload">{{ selectedDoc.uploader_name }}</a-descriptions-item>
                <a-descriptions-item label="Ngày upload">{{ selectedDoc.created_at }}</a-descriptions-item>
                <a-descriptions-item label="Chế độ chia sẻ">{{ selectedDoc.visibility }}</a-descriptions-item>
                <a-descriptions-item label="Link tài liệu">
                    <a :href="safeUrl(selectedDoc.file_path)" target="_blank">Mở link</a>
                </a-descriptions-item>
            </a-descriptions>
        </a-modal>


    </div>
</template>

<script setup>
import { ref, onMounted, nextTick, computed } from 'vue'
import { useRouter } from 'vue-router'
import { getDocumentsByDepartment, uploadDocument, updateDocument } from '@/api/document'
import { message } from 'ant-design-vue'
import {
    EyeOutlined,
    CopyOutlined,
    InfoCircleOutlined,
    EditOutlined,
    ExportOutlined
} from '@ant-design/icons-vue'

const router = useRouter()
const baseURL = import.meta.env.VITE_API_URL

/* ===== State ===== */
const documents = ref([])
const selectedDept = ref(null)
const loading = ref(false)
const filterTitle = ref('')
const detailVisible = ref(false)
const selectedDoc = ref(null)

const uploadVisible = ref(false)
const uploadBtn = ref(null)
const isEditMode = ref(false)
const editingDocId = ref(null)

const uploadForm = ref({
    title: '',
    department_id: null,
    fileUrl: '',
    visibility: 'private',
    shared_users: [],
    shared_departments: [],
})

/* ===== Options (mock) ===== */
const departmentOptions = ref([
    { label: 'Phòng Hành chính - Nhân sự', value: 1 },
    { label: 'Phòng Tài chính - Kế toán', value: 2 },
    { label: 'Phòng Thương mại', value: 3 },
    { label: 'Phòng Dịch vụ - Kỹ thuật', value: 4 },
])
const userOptions = ref([
    { label: 'Nguyễn Văn A', value: 5 },
    { label: 'Trần Thị B', value: 8 },
    { label: 'Phạm Văn C', value: 12 },
])

/* ===== Table ===== */
const columns = [
    { title: '#', dataIndex: 'id', key: 'id', width: 50 },
    { title: 'Tiêu đề', dataIndex: 'title', key: 'title' },
    { title: 'Phòng ban', dataIndex: 'department_name', key: 'department_name' },
    { title: 'Người upload', dataIndex: 'uploader_name', key: 'uploader_name' },
    { title: 'Ngày upload', dataIndex: 'created_at', key: 'created_at' },
    { title: 'Quyền truy cập', dataIndex: 'visibility', key: 'visibility' },
    { title: 'Tác vụ', key: 'action', width: 160 },
]

/* ===== Helpers ===== */
const safeUrl = (p) => {
    const path = String(p || '')
    if (!path) return ''
    return /^https?:\/\//i.test(path) ? path : `${baseURL}/${path}`
}

/* Lọc client-side theo tiêu đề */
const filteredDocs = computed(() => {
    const q = (filterTitle.value || '').trim().toLowerCase()
    if (!q) return documents.value
    return (documents.value || []).filter(d => (d.title || '').toLowerCase().includes(q))
})

/* ===== Fetch ===== */
const fetchDocuments = async () => {
    loading.value = true
    try {
        const res = await getDocumentsByDepartment(selectedDept.value)
        documents.value = res?.data?.data || []
    } catch (err) {
        console.error(err)
        message.error('Lỗi khi tải tài liệu theo phòng ban')
    } finally {
        loading.value = false
    }
}

/* ===== Actions: điều hướng / mở link / copy ===== */
const goDetail = (doc) => {
    router.push({ name: 'document.detail', params: { id: doc.id } })
}

const openOriginal = (doc) => {
    const url = safeUrl(doc.file_path)
    if (!url) return
    window.open(url, '_blank', 'noopener')
}

const copyLink = async (doc) => {
    const url = safeUrl(doc.file_path)
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

/* ===== Modal + CRUD ===== */
const showUploadModal = () => {
    uploadVisible.value = true
}

const openDetailModal = (doc) => {
    selectedDoc.value = doc
    detailVisible.value = true
}

const editDoc = (doc) => {
    uploadForm.value = {
        title: doc.title,
        department_id: doc.department_id,
        fileUrl: doc.file_path,
        visibility: doc.visibility || 'private',
        shared_users: doc.shared_users || [],
        shared_departments: doc.shared_departments || []
    }
    isEditMode.value = true
    editingDocId.value = doc.id
    uploadVisible.value = true
}

const submitUpload = async () => {
    const {
        title, department_id, fileUrl, visibility, shared_users, shared_departments
    } = uploadForm.value

    if (!title || !department_id || !fileUrl) {
        return message.error('Vui lòng điền đầy đủ thông tin!')
    }

    try {
        if (isEditMode.value) {
            await updateDocument(editingDocId.value, {
                title,
                department_id,
                file_url: fileUrl,
                visibility,
                shared_users,
                shared_departments
            })
        } else {
            const formData = new FormData()
            formData.append('title', title)
            formData.append('department_id', department_id)
            formData.append('file_url', fileUrl)
            formData.append('visibility', visibility)
            shared_users.forEach(uid => formData.append('shared_users[]', uid))
            shared_departments.forEach(did => formData.append('shared_departments[]', did))
            await uploadDocument(formData)
        }

        uploadVisible.value = false
        uploadForm.value = {
            title: '',
            department_id: null,
            fileUrl: '',
            visibility: 'private',
            shared_users: [],
            shared_departments: []
        }
        isEditMode.value = false
        editingDocId.value = null

        await fetchDocuments()
    } catch (err) {
        console.error(err)
        message.error('Thao tác thất bại!')
    }
}

const closeModal = () => {
    uploadVisible.value = false
}

const onModalClosed = () => {
    nextTick(() => uploadBtn.value?.focus())
}

/* ===== Lifecycle ===== */
onMounted(fetchDocuments)
</script>
