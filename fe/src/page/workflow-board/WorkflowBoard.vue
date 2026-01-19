<template>
    <div class="workflow-board">
        <!-- HEADER -->
        <div class="board-header">
            <WorkflowRoleSwitcher />

            <a-button type="primary" @click="openCreateModal">
                + Tạo hồ sơ trình duyệt
            </a-button>
        </div>

        <!-- BOARD -->
        <div class="board">
            <WorkflowColumn
                v-for="col in columns"
                :key="col.key"
                :column="col"
            />
        </div>

        <!-- BOTTOM -->
        <div class="bottom">
            <WorkflowLog/>
            <WorkflowStats/>
        </div>

        <!-- MODAL -->
        <WorkflowCreateModal
            v-model:open="createOpen"
            @submitted="reloadBoard"
        />
    </div>
</template>
<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

import WorkflowColumn from './components/WorkflowColumn.vue'
import WorkflowLog from './components/WorkflowLog.vue'
import WorkflowStats from './components/WorkflowStats.vue'
import WorkflowRoleSwitcher from './components/WorkflowRoleSwitcher.vue'
import WorkflowCreateModal from './components/WorkflowCreateModal.vue'

const route = useRoute()
const focusTaskId = computed(() => route.query.task_id)

const createOpen = ref(false)

const openCreateModal = () => {
    createOpen.value = true
}

const reloadBoard = () => {
    // sau này emit để reload các column
    // hoặc dùng store
    console.log('Workflow created → reload board')
}

const columns = [
    { key: 'KD_MANAGER', label: 'Kinh doanh', department_id: 3, position_code: 'manager', level: 2 },
    { key: 'TM_MANAGER', label: 'Thương mại', department_id: 4, position_code: 'manager', level: 2 },
    { key: 'PGD_TM', label: 'PGĐ Thương mại', department_id: 4, position_code: 'senior_manager', level: 3 },
    { key: 'PGD_KD', label: 'PGĐ Kinh doanh', department_id: 3, position_code: 'senior_manager', level: 3 },
    { key: 'GD', label: 'Giám đốc', department_id: 6, position_code: 'executive', level: 4 },
    { key: 'DONE', label: 'Hoàn tất', department_id: null, position_code: null, level: 999 },
]
</script>
<style scoped>
.board-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.workflow-board {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.board {
    display: flex;
    gap: 12px;
    overflow-x: auto;
}

.bottom {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 12px;
}
</style>
