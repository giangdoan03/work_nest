<template>
    <a-modal
        :open="open"
        title="Thêm tài liệu"
        @cancel="closeModal"
        @ok="handleSubmit"
    >
        <a-form layout="vertical">
            <a-form-item label="Tiêu đề" required>
                <a-input v-model:value="form.title" />
            </a-form-item>

            <a-form-item label="Link tài liệu" required>
                <a-input v-model:value="form.file_url" />
            </a-form-item>

            <a-form-item label="Phòng ban">
                <a-select
                    v-model:value="form.department_id"
                    :options="departments"
                    allow-clear
                />
            </a-form-item>
        </a-form>
    </a-modal>
</template>

<script setup>
import { ref, watch } from "vue";
import { message } from "ant-design-vue";
import { createDocument, updateDocument } from "@/api/docs";

const props = defineProps({
    open: Boolean,
    editData: Object,
    departments: Array
});

const emit = defineEmits(["update:open", "saved"]);

const form = ref({
    title: "",
    file_url: "",
    department_id: null
});

// Load dữ liệu khi edit
watch(() => props.editData, (val) => {
    if (val) form.value = { ...val };
    else form.value = { title: "", file_url: "", department_id: null };
});

// Đóng modal
const closeModal = () => emit("update:open", false);

// Lưu tài liệu
const handleSubmit = async () => {
    try {
        const raw = localStorage.getItem("user");
        const userData = raw ? JSON.parse(raw) : null;
        const currentUser = userData?.user;

        if (!currentUser?.id) return message.error("Không tìm thấy user");

        const payload = {
            title: form.value.title,
            file_url: form.value.file_url,
            department_id: form.value.department_id,
            created_by: currentUser.id
        };

        if (props.editData?.id) {
            await updateDocument(props.editData.id, payload);
            message.success("Cập nhật thành công");
        } else {
            await createDocument(payload);
            message.success("Tạo mới thành công");
        }

        emit("saved");
        emit("update:open", false);

    } catch (e) {
        message.error("Lưu thất bại");
    }
};


</script>
