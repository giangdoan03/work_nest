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
                        :getPopupContainer="triggerNode => triggerNode.parentNode"
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
                        <a-button type="link" @click="viewDoc(record)">
                            <EyeOutlined />
                        </a-button>
<!--                        <a-button type="link" @click="downloadDocument(record)">-->
<!--                            <DownloadOutlined />-->
<!--                        </a-button>-->
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

    const baseURL = import.meta.env.VITE_API_URL

    const viewDoc = (doc) => {
        const url = doc.file_path.startsWith('http')
            ? doc.file_path
            : `${baseURL}/${doc.file_path}`
        window.open(url, '_blank')
    }


    import { updateDocument } from '../api/document' // giả sử bạn có API này

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
            visibility: doc.visibility
        }

        editModalVisible.value = true
    }

    const submitEdit = async () => {
        editLoading.value = true
        try {
            const { id, ...data } = editForm.value
            await updateDocument(id, data)
            message.success('Cập nhật thành công')
            await fetchDocuments()
            editModalVisible.value = false
        } catch (e) {
            message.error('Cập nhật thất bại')
        } finally {
            editLoading.value = false
        }
    }

    const resetEditForm = () => {
        editForm.value = {
            id: null,
            title: '',
            department_id: null,
            file_path: '',
            visibility: 'private'
        }
        editModalVisible.value = false
    }

    onMounted(fetchDocuments)
</script>
