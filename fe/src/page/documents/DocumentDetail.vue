<template>
    <div>
        <a-page-header
            :title="document?.title || 'Chi tiết tài liệu'"
            @back="goBack"
        />

        <a-card :loading="loading" bordered>

            <!-- Thông tin tài liệu -->
            <a-descriptions bordered column="1" size="middle">

                <a-descriptions-item label="Tên tài liệu">
                    <strong>{{ document?.title }}</strong>
                </a-descriptions-item>

                <a-descriptions-item label="Mô tả">
                    {{ document?.description || '—' }}
                </a-descriptions-item>

                <a-descriptions-item label="File">
                    <a :href="document?.file_url" target="_blank">
                        <DownloadOutlined /> Tải tài liệu
                    </a>
                </a-descriptions-item>

                <a-descriptions-item label="Phòng ban">
                    {{ getDeptName(document?.department_id) }}
                </a-descriptions-item>

                <a-descriptions-item label="Người tạo">
                    <a-space>
                        <a-avatar :style="{ backgroundColor: avatarColor(getUserName(document?.created_by)) }">
                            {{ getUserName(document?.created_by)?.slice(0,1).toUpperCase() }}
                        </a-avatar>
                        {{ getUserName(document?.created_by) }}
                    </a-space>
                </a-descriptions-item>

                <a-descriptions-item label="Ngày tạo">
                    {{ formatDate(document?.created_at) }}
                </a-descriptions-item>

                <a-descriptions-item label="Người được phép xem">

                    <a-empty v-if="allowedUsers.length === 0" description="Không có người nào" />

                    <a-avatar-group v-else>
                        <a-tooltip v-for="u in allowedUsers" :key="u.id" :title="u.name">
                            <a-avatar :style="{ backgroundColor: avatarColor(u.name) }">
                                {{ u.name.slice(0,1).toUpperCase() }}
                            </a-avatar>
                        </a-tooltip>
                    </a-avatar-group>

                </a-descriptions-item>

            </a-descriptions>

            <!-- Actions -->
            <div style="margin-top:16px; text-align:right">
                <a-space>
                    <a-button type="primary" @click="openEdit">
                        <EditOutlined /> Chỉnh sửa
                    </a-button>

                    <a-popconfirm
                        title="Bạn chắc chắn muốn xoá tài liệu này?"
                        ok-text="Xoá"
                        cancel-text="Hủy"
                        @confirm="deleteCurrent"
                    >
                        <a-button danger>
                            <DeleteOutlined /> Xoá
                        </a-button>
                    </a-popconfirm>
                </a-space>
            </div>

        </a-card>

        <!-- Modal form -->
        <DocumentFormModal
            v-model:open="modalVisible"
            :documentData="document"
            :departments="departments"
            :users="users"
            @submitForm="saveEdit"
        />
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { message } from "ant-design-vue";
import dayjs from "dayjs";

import {
    getDocument,
    updateDocument,
    deleteDocument
} from "@/api/documents";

import { getUsers } from "@/api/user";
import { getDepartments } from "@/api/department";
import { listEntityMembers, canAccessEntity } from "@/api/entityMembers";

import DocumentFormModal from "@/components/document/DocumentFormModal.vue";

import { EditOutlined, DeleteOutlined, DownloadOutlined } from "@ant-design/icons-vue";

// Router
const route = useRoute();
const router = useRouter();

const id = Number(route.params.id);

// States
const document = ref(null);
const loading = ref(true);

const users = ref([]);
const departments = ref([]);
const allowedUsers = ref([]);

const modalVisible = ref(false);

// Helpers
const avatarColor = (name) => {
    if (!name) return "#ccc";
    let hash = 0;
    for (let i = 0; i < name.length; i++)
        hash = name.charCodeAt(i) + ((hash << 5) - hash);
    return `hsl(${Math.abs(hash) % 360}, 70%, 55%)`;
};

const formatDate = (d) => (d ? dayjs(d).format("DD/MM/YYYY HH:mm") : "—");

const getUserName = (id) =>
    users.value.find(u => u.value == id)?.label || "";

const getDeptName = (id) =>
    departments.value.find(d => d.value == id)?.label || "—";

// ========================
// LOAD DATA
// ========================
const checkAccess = async () => {
    const user = JSON.parse(localStorage.getItem("user"));
    if (!user) return false;

    const res = await canAccessEntity({
        entity_type: "document",
        entity_id: id,
        user_id: user.id
    });

    return res.data?.access;
};

const loadAllowedUsers = async () => {
    const res = await listEntityMembers("document", id);
    allowedUsers.value = res.data.map(m => ({
        id: +m.user_id,
        name: getUserName(+m.user_id)
    }));
};

const loadUsers = async () => {
    const res = await getUsers();
    users.value = res.data.map(u => ({ value: u.id, label: u.name }));
};

const loadDepartments = async () => {
    const res = await getDepartments();
    departments.value = res.data.map(d => ({ value: d.id, label: d.name }));
};

const loadDocument = async () => {
    loading.value = true;

    try {
        const res = await getDocument(id);
        document.value = res.data;
        await loadAllowedUsers();
    } catch (e) {
        message.error("Không thể tải tài liệu");
    }

    loading.value = false;
};

// ========================
// ACTIONS
// ========================
const goBack = () => router.push({ name: "documents" });

const openEdit = () => {
    modalVisible.value = true;
};

const saveEdit = async (payload) => {
    try {
        await updateDocument(id, payload);
        message.success("Cập nhật thành công");
        modalVisible.value = false;
        await loadDocument();
    } catch {
        message.error("Không thể lưu thay đổi");
    }
};

const deleteCurrent = async () => {
    try {
        await deleteDocument(id);
        message.success("Đã xoá tài liệu");
        await router.push({name: "documents"});
    } catch {
        message.error("Xoá thất bại");
    }
};

// ========================
// INIT
// ========================
onMounted(async () => {
    await loadUsers();
    await loadDepartments();

    const ok = await checkAccess();
    if (!ok) {
        message.error("Bạn không có quyền xem tài liệu này");
        await router.push({name: "documents"});
        return;
    }

    await loadDocument();
});
</script>

<style scoped>
</style>
