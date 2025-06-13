<template>
    <div>
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
    import { message } from 'ant-design-vue'
    import { EyeOutlined, DownloadOutlined } from '@ant-design/icons-vue'
    import axios from 'axios'
    import {
        getSharedDocuments,
        getDocumentsByDepartment,
        deleteDocument,
        shareDocument,
        uploadDocument
    } from '../api/document'

    const baseURL = import.meta.env.VITE_API_URL
    const documents = ref([])
    const loading = ref(false)

    const columns = [
        { title: '#', dataIndex: 'id', key: 'id', width: 50 },
        { title: 'Tiêu đề', dataIndex: 'title', key: 'title' },
        { title: 'Ngày upload', dataIndex: 'created_at', key: 'created_at' },
        { title: 'Loại file', dataIndex: 'file_type', key: 'file_type' },
        { title: 'Kích thước', dataIndex: 'file_size', key: 'file_size' },
        { title: 'Tác vụ', key: 'action', width: 100 }
    ]

    const fetchDocuments = async () => {
        loading.value = true
        try {
            const res = await getSharedDocuments()
            documents.value = res.data
        } catch (err) {
            message.error('Không tải được tài liệu được chia sẻ')
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

    onMounted(fetchDocuments)
</script>
