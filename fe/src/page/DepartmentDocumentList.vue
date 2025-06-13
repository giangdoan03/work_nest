<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-select
                    v-model:value="selectedDept"
                    :options="departmentOptions"
                    placeholder="Chọn phòng ban"
                    style="min-width: 240px"
                    @change="fetchDocuments"
                    allowClear
            />
        </a-space>

        <a-table
                :columns="columns"
                :data-source="documents"
                row-key="id"
                :loading="loading"
                :pagination="{ pageSize: 10 }"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-tooltip title="Xem tài liệu">
                            <a-button type="link" @click="viewDoc(record)">
                                <EyeOutlined />
                            </a-button>
                        </a-tooltip>
                        <a-tooltip title="Tải xuống">
                            <a-button type="link" @click="downloadDoc(record)">
                                <DownloadOutlined />
                            </a-button>
                        </a-tooltip>
                    </a-space>
                </template>
            </template>
        </a-table>
    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue'
    import { getDocumentsByDepartment } from '../api/document'
    import { message } from 'ant-design-vue'
    import { EyeOutlined, DownloadOutlined } from '@ant-design/icons-vue'

    const baseURL = import.meta.env.VITE_API_URL

    const documents = ref([])
    const selectedDept = ref(null)
    const loading = ref(false)

    // ✅ Nếu danh sách phòng ban cố định (hoặc truyền sẵn từ parent)
    const departmentOptions = ref([
        { label: 'Phòng Nhân sự', value: 1 },
        { label: 'Phòng Kinh doanh', value: 2 },
        { label: 'Phòng Kỹ thuật', value: 3 },
    ])

    const columns = [
        { title: '#', dataIndex: 'id', key: 'id', width: 50 },
        { title: 'Tiêu đề', dataIndex: 'title', key: 'title' },
        { title: 'Phòng ban', dataIndex: 'department_name', key: 'department_name' },
        { title: 'Người upload', dataIndex: 'uploader_name', key: 'uploader_name' },
        { title: 'Ngày upload', dataIndex: 'created_at', key: 'created_at' },
        { title: 'Quyền truy cập', dataIndex: 'visibility', key: 'visibility' },
        { title: 'Tác vụ', key: 'action', width: 100 },
    ]

    const fetchDocuments = async () => {
        loading.value = true
        try {
            const res = await getDocumentsByDepartment(selectedDept.value) // null thì get all
            documents.value = res.data.data
        } catch (err) {
            message.error('Lỗi khi tải tài liệu theo phòng ban')
        } finally {
            loading.value = false
        }
    }



    const viewDoc = (doc) => {
        window.open(`${baseURL}/${doc.file_path}`, '_blank')
    }

    const downloadDoc = (doc) => {
        const link = document.createElement('a')
        link.href = `${baseURL}/${doc.file_path}`
        link.download = doc.title || 'tai-lieu'
        link.click()
    }

    onMounted(() => {
        fetchDocuments() // không chọn sẵn phòng ban => load all
    })
</script>
