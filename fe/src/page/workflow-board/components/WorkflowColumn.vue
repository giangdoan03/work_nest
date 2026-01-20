<template>
    <a-card
        :title="column.label"
        size="small"
        class="workflow-column"
    >
        <div class="column-body">
            <WorkflowCard
                v-for="doc in tasks"
                :key="doc.id"
                :doc="doc"
                :highlight="String(doc.id) === String(focusTaskId)"
                @approve="approveTask"
                @reject="rejectTask"
                @return="returnTask"
            />
        </div>
    </a-card>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import WorkflowCard from './WorkflowCard.vue'
import {
    getWorkflowTasks,
    approveWorkflowTask,
    rejectWorkflowTask,
    returnWorkflowTask,
} from '@/api/workflow'

const props = defineProps({
    column: Object,
    focusTaskId: [String, Number],
})

const tasks = ref([])

const loadTasks = async () => {
    const res = await getWorkflowTasks({
        department_id: props.column.department_id,
        position_code: props.column.position_code,
        level: props.column.level,
    })

    tasks.value = res.data?.data || []
}

/* ================== ACTION ================== */
const approveTask = async (task) => {
    await approveWorkflowTask(task.id)
    await loadTasks()
}

const rejectTask = async (task) => {
    await rejectWorkflowTask(task.id)
    await loadTasks()
}

const returnTask = async (task) => {
    await returnWorkflowTask(task.id)
    await loadTasks()
}

onMounted(loadTasks)
watch(() => props.column, loadTasks, { deep: true })
</script>

<style scoped>
.workflow-column {
    width: 300px;
    flex-shrink: 0;
}

.column-body {
    display: flex;
    flex-direction: column;
    gap: 8px;
}
</style>
