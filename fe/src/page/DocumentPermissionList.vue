<template>
    <div>
        <a-space style="margin-bottom: 16px">
            <a-input-search
                    v-model:value="documentId"
                    placeholder="Nhập ID tài liệu để tra phân quyền"
                    enter-button="Tìm"
                    @search="fetchPermissions"
                    style="max-width: 300px"
            />
        </a-space>

        <a-table
                :columns="columns"
                :data-source="permissions"
                row-key="id"
                :loading="loading"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-select
                                v-model:value="record.permission_type"
                                :options="permissionOptions"
                                style="width: 100px"
                                @change="val => updatePermission(record.id, val)"
                        />
                        <a-popconfirm title="Xoá quyền này?" @confirm="deletePermission(record.id)">
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
    import { ref } from 'vue'
    import { message } from 'ant-design-vue'
    import { onMounted } from 'vue'
    import {
        getDocumentPermissions,
        updateDocumentPermission,
        deleteDocumentPermission
    } from '../api/document-permission'
    import { EyeOutlined, DeleteOutlined } from '@ant-design/icons-vue'

    const documentId = ref('')
    const permissions = ref([])
    const loading = ref(false)

    const columns = [
        { title: '#', dataIndex: 'id', key: 'id' },
        { title: 'Người dùng', dataIndex: 'user_name', key: 'user_name' },
        { title: 'Loại quyền', dataIndex: 'permission_type', key: 'permission_type' },
        { title: 'Tác vụ', key: 'action' }
    ]

    const permissionOptions = [
        { label: 'view', value: 'view' },
        { label: 'edit', value: 'edit' },
        { label: 'download', value: 'download' }
    ]

    const fetchPermissions = async () => {
        loading.value = true
        try {
            const res = await getDocumentPermissions(documentId.value || null)
            permissions.value = res.data
        } catch (err) {
            message.error('Không tải được danh sách phân quyền')
        } finally {
            loading.value = false
        }
    }


    const updatePermission = async (id, value) => {
        try {
            await updateDocumentPermission(id, { permission_type: value })
            message.success('Đã cập nhật quyền')
        } catch (err) {
            message.error('Cập nhật thất bại')
        }
    }

    const deletePermission = async (id) => {
        try {
            await deleteDocumentPermission(id)
            message.success('Đã xoá quyền')
            await fetchPermissions()
        } catch (err) {
            message.error('Xoá thất bại')
        }
    }

    onMounted(() => {
        fetchPermissions()
    })
</script>
