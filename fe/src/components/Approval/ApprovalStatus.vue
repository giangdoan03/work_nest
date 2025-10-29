<template>
    <div class="approval-status">
        <a-card :bordered="false" size="small">
            <div class="approval-header">
                <a-tag color="blue">Trạng thái</a-tag>
            </div>

            <a-divider style="margin: 8px 0"/>

            <a-checkbox-group v-model="checkedList">
                <a-space direction="vertical">
                    <a-checkbox
                        v-for="step in steps"
                        :key="step.role"
                        :checked="step.status === 'approved'"
                        :disabled="!isCurrentUser(step.role)"
                        @change="() => toggleApproval(step)"
                    >
                        <span :style="{ fontWeight: isCurrentUser(step.role) ? '600' : '400' }">
                          {{ step.label }}
                        </span>
                        <template v-if="step.status === 'approved'">
                            <CheckCircleTwoTone twoToneColor="#52c41a" style="margin-left: 4px"/>
                        </template>
                        <template v-else-if="step.status === 'rejected'">
                            <CloseCircleTwoTone twoToneColor="#ff4d4f" style="margin-left: 4px"/>
                        </template>
                        <template v-else>
                            <ClockCircleTwoTone twoToneColor="#1890ff" style="margin-left: 4px"/>
                        </template>
                    </a-checkbox>
                </a-space>
            </a-checkbox-group>
        </a-card>
    </div>
</template>

<script setup>
import {ref, computed} from "vue";
import {
    CheckCircleTwoTone,
    CloseCircleTwoTone,
    ClockCircleTwoTone,
} from "@ant-design/icons-vue";

/* -------------------------------
   Fake data demo (thay bằng API)
--------------------------------*/
const currentUserRole = "PGD"; // giả sử người đang đăng nhập là PGD

const steps = ref([
    {role: "TPTC", label: "TP Tài chính", status: "approved"},
    {role: "TPTM", label: "TP Thương mại", status: "approved"},
    {role: "TPKD", label: "TP Kinh doanh", status: "approved"},
    {role: "PGD", label: "Phó Giám đốc", status: "pending"},
    {role: "GD", label: "Giám đốc", status: "pending"},
]);

const checkedList = ref([]);

/* -------------------------------
   Tính % hoàn thành
--------------------------------*/
const percent = computed(() => {
    const total = steps.value.length;
    const approved = steps.value.filter((s) => s.status === "approved").length;
    return Math.round((approved / total) * 100);
});

/* -------------------------------
   Logic check quyền & cập nhật
--------------------------------*/
function isCurrentUser(role) {
    return role === currentUserRole;
}

function toggleApproval(step) {
    if (!isCurrentUser(step.role)) return;
    step.status = step.status === "approved" ? "pending" : "approved";
    console.log("✅ Cập nhật duyệt:", step.role, step.status);
}
</script>

<style scoped>
.approval-status {
    padding: 4px 0;
}

.approval-header {
    display: flex;
    align-items: center;
    justify-content: flex-start;
}
</style>
