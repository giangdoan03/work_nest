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
            />
        </div>
    </a-card>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import WorkflowCard from './WorkflowCard.vue'
import { getWorkflowTasks } from '@/api/workflow' // 👈 API của bạn

const props = defineProps({
    column: Object,
    focusTaskId: [String, Number],
})

const tasks = ref([])

const loadTasks = async () => {
    const col = props.column

    try {
        const res = await getWorkflowTasks({
            department_id: col.department_id,
            position_code: col.position_code,
            level: col.level,
        })

        tasks.value = res.data || []
    } catch (e) {
        tasks.value = []
    }
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
