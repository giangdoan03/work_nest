<template>
    <a-card size="small" bordered class="switcher">
        <div class="switcher-row">
            <a-space>
                <a-typography-text strong>Vai trò:</a-typography-text>

                <a-select
                    v-model:value="role"
                    style="width: 220px"
                    :options="roles"
                />
            </a-space>

            <a-button type="primary" @click="openCreateModal">
                + Tạo hồ sơ trình duyệt
            </a-button>
        </div>
    </a-card>

    <!-- MODAL -->
    <WorkflowCreateModal
        v-model:open="createOpen"
        @submitted="onCreated"
    />
</template>

<script setup>
import { ref, watch } from 'vue'
import WorkflowCreateModal from './WorkflowCreateModal.vue'

/* ================= ROLE ================= */
const role = ref('NV_KD')

const roles = [
    { label: 'Nhân viên Kinh doanh', value: 'NV_KD' },
    { label: 'Trưởng phòng Kinh doanh', value: 'TP_KD' },
    { label: 'Nhân viên Thương mại', value: 'NV_TM' },
    { label: 'Trưởng phòng Thương mại', value: 'TP_TM' },
    { label: 'PGĐ Thương mại', value: 'PGD_TM' },
    { label: 'PGĐ Kinh doanh', value: 'PGD_KD' },
    { label: 'Giám đốc', value: 'GD' },
]

watch(role, (v) => {
    console.log('🔁 Đổi role:', v)
    // TODO: set store (pinia)
})

/* ================= MODAL ================= */
const createOpen = ref(false)

const openCreateModal = () => {
    createOpen.value = true
}

const onCreated = () => {
    console.log('✅ Workflow created')
    // TODO: emit event / store reload board
}
</script>

<style scoped>
.switcher {
    margin-bottom: 12px;
}

.switcher-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
}
</style>
