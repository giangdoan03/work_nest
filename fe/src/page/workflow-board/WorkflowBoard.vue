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
                :tasks="getTasksByColumn(col)"
                :focus-task-id="focusTaskId"
                @approve="approveTask"
                @reject="rejectTask"
                @return="returnTask"
            />
        </div>

        <div class="bottom">
            <WorkflowLog />
            <WorkflowStats />
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useHorizontalScroll } from './composables/useHorizontalScroll'
import {
    getWorkflowBoard,
    approveWorkflow,
    rejectWorkflow,
    returnWorkflowToPreviousStep,
} from '@/api/workflow'

import WorkflowColumn from './components/WorkflowColumn.vue'
import WorkflowLog from './components/WorkflowLog.vue'
import WorkflowStats from './components/WorkflowStats.vue'
import WorkflowRoleSwitcher from './components/WorkflowRoleSwitcher.vue'

/* ================= ROUTE ================= */
const route = useRoute()
const focusTaskId = computed(() => route.query.task_id)

/* ================= SCROLL ================= */
const { containerRef, startDrag, onDrag, stopDrag } =
    useHorizontalScroll({ snap: true, snapWidth: 312 })

/* ================= DATA ================= */
const allTasks = ref([])
const loading = ref(false)

onMounted(async () => {
    loading.value = true
    const res = await getWorkflowBoard()   // ✅ CHỈ 1 API
    allTasks.value = res.data.data || []
    loading.value = false
})

/* ================= COLUMNS ================= */
const columns = [
    { key: 'KD_MANAGER', label: 'Kinh doanh', department_id: 3, position_code: 'manager', level: 2 },
    { key: 'TM_MANAGER', label: 'Thương mại', department_id: 4, position_code: 'manager', level: 2 },
    { key: 'PGD_TM', label: 'PGĐ Thương mại', department_id: 4, position_code: 'senior_manager', level: 3 },
    { key: 'PGD_KD', label: 'PGĐ Kinh doanh', department_id: 3, position_code: 'senior_manager', level: 3 },
    { key: 'GD', label: 'Giám đốc', department_id: 6, position_code: 'executive', level: 4 },
    { key: 'DONE', label: 'Hoàn tất', department_id: null, position_code: null, level: 999 },
]

/* ================= FILTER ================= */
const getTasksByColumn = (col) => {
    return allTasks.value.filter(t =>
        Number(t.current_level) === Number(col.level) &&
        Number(t.department_id) === Number(col.department_id) &&
        t.position_code === col.position_code
    )
}


/* ================= ACTIONS ================= */
const reloadBoard = async () => {
    const res = await getWorkflowBoard()
    allTasks.value = res.data.data || []
}

const approveTask = async (task) => {
    await approveWorkflow(task.id)
    await reloadBoard()
}

const rejectTask = async (task) => {
    await rejectWorkflow(task.id, {
        comment: task.comment, // ✅ LẤY TỪ MODAL
    })
    await reloadBoard()
}

const returnTask = async (task) => {
    await returnWorkflowToPreviousStep(task.id, { comment: 'Trả về' })
    await reloadBoard()
}
</script>

<style scoped>
.workflow-board {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

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

.bottom {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 12px;
}
</style>
