<template>
    <a-modal
        :open="open"
        @update:open="val => emit('update:open', val)"
        :title="modalTitle"
        width="600px"
        @cancel="closeModal"
        @ok="closeModal"
        ok-text="Đóng"
    >
        <div>
            <a-alert
                type="info"
                message="Chọn/bỏ chọn người dùng để cấp hoặc thu hồi quyền truy cập"
                show-icon
                style="margin-bottom: 12px"
            />

            <!-- ⭐ HIỂN THỊ THÔNG TIN CƠ BẢN ENTITY -->
            <a-card size="small" style="margin-bottom: 12px; background:#fafafa;">
                <div><b>Tên:</b> {{ entityData?.title || '—' }}</div>
                <div><b>Người quản lý:</b> {{ entityData?.manager_name || '—' }}</div>

                <div style="display:flex; gap:16px; margin-top:6px;">
                    <div><b>Bắt đầu:</b> {{ formatDate(entityData?.start_date) }}</div>
                    <div><b>Kết thúc:</b> {{ formatDate(entityData?.end_date) }}</div>
                </div>
            </a-card>

            <div
                class="scroll-container"
                style="max-height: 400px; overflow-y: auto; border: 1px solid #f0f0f0; border-radius: 6px;"
            >

            <a-table
                    :columns="columns"
                    :data-source="users"
                    row-key="id"
                    :pagination="false"
                >
                    <template #bodyCell="{ column, record }">

                        <!-- Checkbox -->
                        <template v-if="column.dataIndex === 'select'">
                            <a-checkbox
                                :checked="record.hasAccess"
                                @change="onToggle(record)"
                            />
                        </template>

                    </template>
                </a-table>
            </div>
        </div>
    </a-modal>
</template>

<script setup>
import { ref, watch, computed } from "vue";
import { message } from "ant-design-vue";
import { getUsers } from "@/api/user";
import { listEntityMembers, addEntityMember, removeEntityMember } from "@/api/entityMembers";
import dayjs from "dayjs";

const props = defineProps({
    open: Boolean,
    entityType: String,
    entityId: Number,
    entityData: Object   // ⭐ thêm dòng này
});
const formatDate = d => d ? dayjs(d).format("DD/MM/YYYY") : "—";
const emit = defineEmits(["update:open", "saved"]);

const users = ref([]);
const saving = ref(false);

const modalTitle = computed(() => {
    switch (props.entityType) {
        case "bidding": return "Quản lý quyền truy cập gói thầu";
        case "contract": return "Quản lý quyền truy cập hợp đồng";
        case "non_workflow": return "Quản lý quyền truy cập việc không quy trình";
        default: return "Quản lý quyền truy cập";
    }
});

const columns = [
    { title: "Chọn", dataIndex: "select", width: 60 },
    { title: "Tên", dataIndex: "name" },
    { title: "Email", dataIndex: "email" },
];


// ⭐ Load dữ liệu đầy đủ + đánh dấu user đã có quyền
const loadFullUsers = async () => {
    if (!props.entityType || !props.entityId) return;

    const resUsers = await getUsers();
    const allUsers = resUsers.data.map(u => ({
        id: Number(u.id),
        name: u.name,
        email: u.email,
        hasAccess: false // mặc định chưa có quyền
    }));

    const resMembers = await listEntityMembers(props.entityType, props.entityId);
    const memberIds = resMembers.data.map(m => Number(m.user_id));

    // đánh dấu user đã có quyền
    allUsers.forEach(u => {
        if (memberIds.includes(u.id)) u.hasAccess = true;
    });

    users.value = allUsers;
};


// ⭐ Toggle quyền ngay lập tức
const onToggle = async (user) => {
    const isChecked = user.hasAccess;

    try {
        if (isChecked) {
            // Bỏ check → remove quyền
            await removeEntityMember({
                entity_type: props.entityType,
                entity_id: props.entityId,
                user_id: user.id,
            });
            user.hasAccess = false;
            message.success(`Đã thu hồi quyền của ${user.name}`);
        } else {
            // Check → add quyền
            await addEntityMember({
                entity_type: props.entityType,
                entity_id: props.entityId,
                user_id: user.id,
            });
            user.hasAccess = true;
            message.success(`Đã cấp quyền cho ${user.name}`);
        }
    } catch (err) {
        message.error("Có lỗi khi cập nhật quyền.");
        console.error(err);
    }
};


// ⭐ Đóng modal
const closeModal = () => emit("update:open", false);


// ⭐ Load dữ liệu khi mở modal
watch(() => props.open, async (val) => {
    if (val) {
        await loadFullUsers();
    }
});
</script>

<style scoped>
/* Thu nhỏ scrollbar */
.scroll-container::-webkit-scrollbar {
    width: 6px;        /* chiều rộng */
}

.scroll-container::-webkit-scrollbar-track {
    background: #f0f0f0;
    border-radius: 10px;
}

.scroll-container::-webkit-scrollbar-thumb {
    background: #c0c0c0;
    border-radius: 10px;
}

.scroll-container::-webkit-scrollbar-thumb:hover {
    background: #a6a6a6;
}
</style>

