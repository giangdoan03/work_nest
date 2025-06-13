<template>
    <div>
        <a-space style="margin-bottom: 16px" direction="vertical" size="middle">
            <a-space>
                <a-select
                        v-model:value="filters.department_id"
                        style="width: 200px"
                        placeholder="Phòng ban"
                        :options="departments"
                        allowClear
                />
                <a-range-picker
                        v-model:value="filters.dateRange"
                        :placeholder="['Từ ngày', 'Đến ngày']"
                />
                <a-input
                        v-model:value="filters.title"
                        placeholder="Tìm theo tiêu đề"
                        style="width: 200px"
                        @pressEnter="fetchDocuments"
                />
                <a-button type="primary" @click="fetchDocuments">Tìm kiếm</a-button>
            </a-space>
        </a-space>

        <a-table
                :columns="columns"
                :data-source="documents"
                :pagination="pagination"
                :loading="loading"
                row-key="id"
                @change="handleTableChange"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button type="link" @click="viewDocument(record.id)">
                            <EyeOutlined />
                        </a-button>
                        <a-button type="link" @click="downloadDocument(record)">
                            <DownloadOutlined />
                        </a-button>
                        <a-button type="link" @click="editDocument(record.id)">
                            <EditOutlined />
                        </a-button>
                        <a-popconfirm title="Xác nhận xoá?" @confirm="deleteDoc(record.id)">
                            <a-button type="link" danger>
                                <DeleteOutlined />
                            </a-button>
                        </a-popconfirm>
                    </a-space>
                </template>
            </template>


        </a-table>
    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue'
    import { message } from 'ant-design-vue'
    import { getDocuments, deleteDocument } from '../api/document'
    import {
        EyeOutlined,
        DownloadOutlined,
        EditOutlined,
        DeleteOutlined,
    } from '@ant-design/icons-vue'

    const documents = ref([])
    const loading = ref(false)
    const pagination = ref({ current: 1, pageSize: 10, total: 0 })
    const filters = ref({
        department_id: null,
        dateRange: [],
        title: ''
    })
    const departments = ref([
        { label: 'Nhân sự', value: 1 },
        { label: 'Kinh doanh', value: 2 }
    ])

    const columns = [
        { title: '#', dataIndex: 'id', key: 'id' },
        { title: 'Tiêu đề', dataIndex: 'title', key: 'title' },
        { title: 'Phòng ban', dataIndex: 'department_name', key: 'department_name' },
        { title: 'Người upload', dataIndex: 'uploader_name', key: 'uploader_name' },
        { title: 'Ngày upload', dataIndex: 'created_at', key: 'created_at' },
        { title: 'Quyền truy cập', dataIndex: 'visibility', key: 'visibility' },
        { title: 'Tác vụ', key: 'action' },
    ]

    const fetchDocuments = async () => {
        loading.value = true
        try {
            const params = {
                page: pagination.value.current,
                per_page: pagination.value.pageSize,
                department_id: filters.value.department_id,
                title: filters.value.title,
            }

            if (filters.value.dateRange.length === 2) {
                params.created_from = filters.value.dateRange[0].format('YYYY-MM-DD')
                params.created_to = filters.value.dateRange[1].format('YYYY-MM-DD')
            }

            const res = await getDocuments(params)
            documents.value = res.data.data || res.data
            pagination.value.total = res.data.pager?.total || res.data.length || 0
        } catch (e) {
            message.error('Lỗi tải danh sách tài liệu')
        } finally {
            loading.value = false
        }
    }

    const handleTableChange = (p) => {
        pagination.value.current = p.current
        pagination.value.pageSize = p.pageSize
        fetchDocuments()
    }

    const editDocument = (id) => {
        // router.push(`/documents/${id}/edit`)
    }

    const deleteDoc = async (id) => {
        try {
            await deleteDocument(id)
            message.success('Đã xoá tài liệu')
            await fetchDocuments()
        } catch (e) {
            message.error('Xoá thất bại')
        }
    }

    const viewDocument = (id) => {
        router.push(`/documents/${id}`) // hoặc route phù hợp
    }
    const downloadDocument = (record) => {
        window.open(import.meta.env.VITE_API_URL + '/' + record.file_path, '_blank')
    }

    onMounted(fetchDocuments)
</script>
