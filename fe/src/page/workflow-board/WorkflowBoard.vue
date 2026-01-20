<template>
    <div class="workflow-board">
        <WorkflowRoleSwitcher />

        <div
            class="board"
            ref="containerRef"
            @mousedown="startDrag"
            @mousemove="onDrag"
            @mouseup="stopDrag"
            @mouseleave="stopDrag"
            @touchstart="startDrag"
            @touchmove="onDrag"
            @touchend="stopDrag"
        >
            <WorkflowColumn
                v-for="col in columns"
                :key="col.key"
                :column="col"
                :focus-task-id="focusTaskId"
            />
        </div>

        <div class="bottom">
            <WorkflowLog />
            <WorkflowStats />
        </div>
    </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useHorizontalScroll } from './composables/useHorizontalScroll'

import WorkflowColumn from './components/WorkflowColumn.vue'
import WorkflowLog from './components/WorkflowLog.vue'
import WorkflowStats from './components/WorkflowStats.vue'
import WorkflowRoleSwitcher from './components/WorkflowRoleSwitcher.vue'

const route = useRoute()
const focusTaskId = computed(() => route.query.task_id)

const { containerRef, startDrag, onDrag, stopDrag } =
    useHorizontalScroll({ snap: true, snapWidth: 312 })

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
.board {
    display: flex;
    gap: 12px;
    overflow-x: auto;
    padding-bottom: 6px;

    cursor: grab;
    user-select: none;
    -webkit-overflow-scrolling: touch;
}

.board.dragging {
    cursor: grabbing;
}

/* scrollbar */
.board::-webkit-scrollbar {
    height: 6px;
}
.board::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.3);
    border-radius: 999px;
}

.board {
    scrollbar-width: thin;
}
</style>
