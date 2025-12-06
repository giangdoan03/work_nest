<template>
    <a-modal
        :open="open"
        width="600px"
        @cancel="emit('update:open', false)"
        @ok="handleSave"
        ok-text="Lưu"
        cancel-text="Hủy"
    >
        <!-- HEADER -->
        <template #title>
            <div style="display:flex; align-items:center; gap:10px;">
                <UserAddOutlined style="font-size:20px; color:#1677ff" />
                <span>Chia sẻ tài liệu</span>
            </div>
        </template>

        <a-spin :spinning="loading">
            <!-- THÔNG TIN TÀI LIỆU -->
            <a-card size="small" style="margin-bottom:15px; background:#fafafa">
                <div style="display:flex; flex-direction:column; gap:4px;">
                    <div><strong>Tài liệu:</strong> {{ document?.title }}</div>
                    <div><strong>Phòng ban:</strong> {{ getDeptName(document?.department_id) }}</div>
                    <div><strong>Đang chia sẻ với: </strong>
                        <a-tag color="blue">{{ selectedUsers.length }} người</a-tag>
                    </div>
                </div>
            </a-card>

            <!-- DANH SÁCH USER -->
            <div style="font-weight:600; margin-bottom:8px;">
                Chọn người được phép xem tài liệu:
            </div>

            <div class="user-list">
                <a-checkbox-group v-model:value="selectedUsers">

                    <div
                        v-for="u in users"
                        :key="u.id"
                        class="user-item"
                    >
                        <a-checkbox :value="+u.id" class="chk"></a-checkbox>

                        <BaseAvatar
                            :src="u.avatar"
                            :name="u.name"
                            :size="28"
                            shape="circle"
                            :preferApiOrigin="true"
                        />

                        <div class="user-info">
                            <div class="name">{{ u.name }}</div>
                            <div class="email">{{ u.email }}</div>
                        </div>
                    </div>

                </a-checkbox-group>
            </div>


        </a-spin>
    </a-modal>
</template>

<script setup>
import { ref, watch } from "vue";
import { message } from "ant-design-vue";
import { UserAddOutlined } from "@ant-design/icons-vue";
import BaseAvatar from '../../components/common/BaseAvatar.vue'

import {
    addDocumentUserAccess,
    removeDocumentUserAccess
} from "@/api/docs";

const emit = defineEmits(["update:open", "saved"]);
const apiBaseUrl = import.meta.env.VITE_API_URL;

const props = defineProps({
    open: Boolean,
    document: Object,
    users: Array,
    departments: Array,
});

const loading = ref(false);
const selectedUsers = ref([]);

// ===========================
// GET DEPARTMENT NAME
// ===========================
const getDeptName = (id) => {
    const dept = props.departments?.find(d => d.id === id);
    return dept?.name ?? "—";
};

// ===========================
// Avatar Color Generator
// ===========================
const avatarColor = (name) => {
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }
    const hue = Math.abs(hash) % 360;
    return `hsl(${hue}, 65%, 55%)`;
};

const getAvatarUrl = (path) => {
    if (!path) return null;
    if (path.startsWith("http")) return path; // avatar full URL? -> dùng luôn
    return `${apiBaseUrl}/${path}`;
};


// ===========================
// Load allowed users
// ===========================
watch(() => props.document, (doc) => {
    if (doc && doc.allowed_users) {
        selectedUsers.value = doc.allowed_users.map(id => Number(id));
    }
}, { immediate: true });


// ===========================
// SAVE
// ===========================
const handleSave = async () => {
    loading.value = true;

    try {
        const before = props.document.allowed_users.map(id => Number(id));
        const after = selectedUsers.value;

        const toAdd = after.filter(x => !before.includes(x));
        const toRemove = before.filter(x => !after.includes(x));

        await Promise.all([
            ...toAdd.map(uid => addDocumentUserAccess({
                document_id: props.document.id,
                user_id: uid
            })),
            ...toRemove.map(uid => removeDocumentUserAccess({
                document_id: props.document.id,
                user_id: uid
            }))
        ]);

        message.success("Cập nhật phân quyền thành công");
        emit("saved");
        emit("update:open", false);

    } catch (e) {
        console.error(e);
        message.error("Không thể lưu phân quyền");
    }

    loading.value = false;
};
</script>

<style scoped>
.user-list {
    max-height: 350px;
    overflow-y: auto;
    padding-right: 5px;
    border-top: 1px solid #f0f0f0;
}

.user-item {
    display: flex;
    grid-template-columns: 32px 40px 1fr; /* checkbox | avatar | info */
    align-items: center;
    padding: 8px 6px;
    border-bottom: 1px solid #f0f0f0;
    gap: 10px;
    width: 45%;
}

.chk {
    display: flex;
    justify-content: center;
}

.user-info .name {
    font-weight: 600;
}

.user-info .email {
    font-size: 12px;
    color: #888;
}

.checkbox-label {
    display: flex;
    align-items: center;
    gap: 10px;
}

.user-info {
    display: flex;
    flex-direction: column;
    margin-left: 4px;
    line-height: 1.2;
}

.name {
    font-weight: 500;
}

.email {
    font-size: 12px;
    color: #888;
}
</style>
<style>
.user-list::-webkit-scrollbar {
    width: 3px;               /* độ rộng rất nhỏ */
}

.user-list::-webkit-scrollbar-thumb {
    background: #bfbfbf;      /* màu xám nhẹ */
    border-radius: 10px;      /* bo tròn đẹp */
}

.user-list::-webkit-scrollbar-thumb:hover {
    background: #999;         /* khi hover đậm hơn nhẹ */
}

.user-list::-webkit-scrollbar-track {
    background: transparent;  /* ẩn track */
}

</style>
