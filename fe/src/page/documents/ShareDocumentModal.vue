<template>
    <a-modal
        :open="open"
        title="Chia sẻ tài liệu cho user"
        @cancel="emit('update:open', false)"
        @ok="handleSave"
        ok-text="Lưu"
    >
        <a-spin :spinning="loading">
            <a-checkbox-group
                v-model:value="selectedUsers"
                style="display:flex; flex-direction:column; gap:6px;"
            >
                <a-checkbox
                    v-for="u in users"
                    :key="u.id"
                    :value="u.id"
                >
                    {{ u.name }}
                </a-checkbox>
            </a-checkbox-group>
        </a-spin>
    </a-modal>
</template>

<script setup>
import { ref, watch } from "vue";
import { message } from "ant-design-vue";

import {
    addDocumentUserAccess,
    removeDocumentUserAccess
} from "@/api/docs";

const emit = defineEmits(["update:open", "saved"]);

const props = defineProps({
    open: Boolean,
    document: {
        type: Object,
        default: () => ({})   // CHO PHÉP RỖNG
    },
    users: Array
});

const loading = ref(false);
const selectedUsers = ref([]);

// 🟢 Khi mở modal hoặc document thay đổi → load lại danh sách user được phép
watch(
    () => props.document,
    (doc) => {
        if (doc) {
            selectedUsers.value = [...(doc.allowed_users || [])];
        }
    },
    { immediate: true }
);

const handleSave = async () => {
    loading.value = true;

    try {
        const before = props.document.allowed_users || [];
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
