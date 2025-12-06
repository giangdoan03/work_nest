<template>
    <div>

        <!-- Header -->
        <a-card bordered style="margin-bottom: 16px">
            <a-flex justify="space-between" align="center">

                <!-- LEFT ZONE -->
                <a-space align="center" size="middle">

                    <!-- Back -->
                    <a-button
                        type="default"
                        @click="router.push('/documents/department')"
                        style="display:flex; align-items:center;"
                    >
                        ← Quay lại
                    </a-button>

                    <!-- Title -->
                    <a-typography-title :level="4" style="margin:0;">
                        Quản lý tài liệu
                    </a-typography-title>

                    <!-- Filter -->
                    <a-select
                        v-model:value="filterDept"
                        placeholder="Lọc theo phòng ban"
                        allow-clear
                        style="width:200px"
                        :options="departmentOptions"
                        @change="fetchDocuments"
                    />
                </a-space>

                <!-- RIGHT ZONE -->
                <a-space>

                    <!-- Search -->
                    <a-input
                        v-model:value="searchText"
                        placeholder="Tìm kiếm tài liệu"
                        allow-clear
                        style="width:260px"
                        @input="debouncedSearch"
                    >
                        <template #prefix><SearchOutlined /></template>
                    </a-input>

                    <!-- Add document -->
                    <a-button type="primary" @click="openCreate">
                        + Thêm tài liệu
                    </a-button>
                </a-space>

            </a-flex>
        </a-card>

        <a-card bordered>

            <!-- Bulk delete -->
            <a-popconfirm
                title="Bạn chắc chắn muốn xoá các tài liệu đã chọn?"
                ok-text="Xoá"
                cancel-text="Hủy"
                :disabled="selectedRowKeys.length===0"
                @confirm="handleBulkDelete"
            >
                <a-button
                    danger
                    :disabled="selectedRowKeys.length===0"
                >
                    Xoá {{ selectedRowKeys.length }} tài liệu
                </a-button>
            </a-popconfirm>

            <!-- Table -->
            <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                :row-selection="rowSelection"
                row-key="id"
                :pagination="pagination"
                @change="handleTableChange"
                style="margin-top:10px"
            >
                <template #bodyCell="{column, record}">

                    <!-- Link mở tài liệu -->
                    <template v-if="column.dataIndex === 'title'">
                        <a-typography-text strong style="cursor:pointer" @click="openDetail(record)">
                            {{ record.title }}
                        </a-typography-text>
                    </template>

                    <!-- Phòng ban -->
                    <template v-else-if="column.dataIndex === 'department'">
                        {{ getDeptName(record.department_id) }}
                    </template>

                    <!-- Người xem -->
                    <template v-else-if="column.dataIndex === 'allowed_users'">
                        <a-avatar-group>
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


                    <!-- Hành động -->
                    <template v-else-if="column.dataIndex === 'action'">
                        <a-space>

                            <!-- Edit -->
                            <a-button size="small" @click="openEdit(record)">
                                <EditOutlined />
                            </a-button>

                            <!-- Share document -->
                            <template v-if="canShare">
                                <a-tooltip title="Chia sẻ tài liệu">
                                    <a-button
                                        size="small"
                                        @click="openShareModal(record)"
                                    >
                                        <UserAddOutlined />
                                    </a-button>
                                </a-tooltip>
                            </template>

                            <!-- Delete -->
                            <a-popconfirm
                                title="Xoá tài liệu này?"
                                ok-text="Xoá"
                                cancel-text="Hủy"
                                @confirm="handleDelete(record.id)"
                            >
                                <a-button size="small" danger>
                                    <DeleteOutlined />
                                </a-button>
                            </a-popconfirm>

                        </a-space>
                    </template>


                </template>
            </a-table>
        </a-card>

        <!-- Modal -->
        <DocumentFormModal
            v-model:open="openForm"
            :departments="departmentOptions"
            :edit-data="selectedDocument"
            @saved="fetchDocuments"
        />

        <ShareDocumentModal
            v-model:open="shareModalOpen"
            :document="shareTarget"
            :users="users"
            :departments="departments"
            @saved="fetchDocuments"
        />

    </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from "vue";
import { message } from "ant-design-vue";
import { SearchOutlined, EditOutlined, DeleteOutlined, DownloadOutlined, UserAddOutlined } from "@ant-design/icons-vue";

import DocumentFormModal from "./DocumentFormModal.vue";
import ShareDocumentModal from "./ShareDocumentModal.vue";
import BaseAvatar from '../../components/common/BaseAvatar.vue'

import {
    getDocuments,
    deleteDocument,
    canAccessDocument
} from "@/api/docs";

import { getUsers } from "@/api/user";
import { getDepartments } from "@/api/department";
const apiBaseUrl = import.meta.env.VITE_API_URL;

import { useRouter } from "vue-router";
const router = useRouter();
import { useUserStore } from '@/stores/user'
import { storeToRefs } from 'pinia'

const userStore = useUserStore()
const user = computed(() => userStore.user)


const shareModalOpen = ref(false);
const shareTarget = ref(null);

const openShareModal = (record) => {
    shareTarget.value = record;
    shareModalOpen.value = true;
};
// =============================
// STATE
// =============================

const columns = [
    { title: "Tên tài liệu", dataIndex: "title",  width: 200 },
    { title: "Phòng ban", dataIndex: "department", width: 140 },
    { title: "Người xem", dataIndex: "allowed_users", width: 180 },
    { title: "Hành động", dataIndex: "action", width: 120 }
];


const loading = ref(false);
const tableData = ref([]);

const users = ref([]);
const departments = ref([]);

const filterDept = ref(null);
const searchText = ref("");
const openForm = ref(false);
const selectedDocument = ref(null);

const selectedRowKeys = ref([]);
const rowSelection = {
    selectedRowKeys,
    onChange: keys => selectedRowKeys.value = keys
};

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0
});

// =============================
// OPTIONS
// =============================
const departmentOptions = computed(() =>
    departments.value.map(d => ({ value: d.id, label: d.name }))
);

const getUser = (id) => users.value.find(u => u.id == id);

const getAvatarUrl = (avatarPath) => {
    if (!avatarPath) return null;
    return `${apiBaseUrl}/${avatarPath}`;
};

// =============================
// HELPERS
// =============================
const getDeptName = id =>
    departments.value.find(d => d.id == id)?.name ?? "—";

const getUserName = id =>
    users.value.find(u => u.id == id)?.name ?? "";

const avatarColor = (name) => {
    if (!name) return "#ccc";
    let hash = 0;
    for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash);
    const hue = Math.abs(hash) % 360;
    return `hsl(${hue}, 70%, 55%)`;
};

// =============================
// FETCH DOCUMENTS
// =============================
const fetchDocuments = async () => {
    loading.value = true;

    try {
        const res = await getDocuments({
            search: searchText.value || undefined,
            department_id: filterDept.value || undefined
        });

        tableData.value = res.data;
        pagination.value.total = res.data.length;

    } catch (e) {
        console.error(e);
        message.error("Không thể tải tài liệu");
    }

    loading.value = false;
};


// Debounce search
let timeout = null;
const debouncedSearch = () => {
    clearTimeout(timeout);
    timeout = setTimeout(() => {
        pagination.value.current = 1;
        fetchDocuments();
    }, 300);
};

// Pagination
const handleTableChange = p => {
    pagination.value.current = p.current;
    pagination.value.pageSize = p.pageSize;
    fetchDocuments();
};

// =============================
// CRUD
// =============================


const openCreate = () => {
    selectedDocument.value = null;
    openForm.value = true;
};

const openEdit = record => {
    selectedDocument.value = record;
    openForm.value = true;
};

// Delete
const handleDelete = id => async () => {
    try {
        await deleteDocument(id);
        message.success("Đã xoá tài liệu");
        await fetchDocuments();
    } catch {
        message.error("Xoá thất bại");
    }
};

// Bulk delete
const handleBulkDelete = async () => {
    try {
        await Promise.all(selectedRowKeys.value.map(id => deleteDocument(id)));
        selectedRowKeys.value = [];
        message.success("Đã xoá tài liệu");
        await fetchDocuments();
    } catch {
        message.error("Xoá hàng loạt thất bại");
    }
};

// =============================
// OPEN DETAIL (CHECK ACCESS)
// =============================
const openDetail = async record => {
    const data = JSON.parse(localStorage.getItem("user"));

    if (!data?.user?.id)
        return message.error("Không xác định người dùng");

    const userId = data.user.id;

    const res = await canAccessDocument({
        document_id: record.id,
        user_id: userId
    });

    if (!res.data.access) {
        return message.error("Bạn không có quyền xem tài liệu này");
    }

    await router.push({name: "document-detail", params: {id: record.id}});
};



// =============================
// INIT
// =============================
const loadUsers = async () => {
    const res = await getUsers();
    users.value = res.data;
};

const loadDepartments = async () => {
    const res = await getDepartments();
    departments.value = res.data;
};

const canShare = computed(() =>
    ['admin', 'super_admin'].includes(user.value?.role_code)
)

watch(user, () => {
    console.log("User changed:", user.value)
}, { immediate: true })


onMounted(() => {
    loadUsers();
    loadDepartments();
    fetchDocuments();
});
</script>
