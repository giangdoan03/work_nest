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
                @approve="onApprove"
                @reject="onReject"
                @return="onReturn"
            />
        </div>
    </a-card>
</template>

<script setup>
import WorkflowCard from './WorkflowCard.vue'

const props = defineProps({
    column: Object,
    tasks: {
        type: Array,
        default: () => [],
    },
    focusTaskId: [String, Number],
})

const emit = defineEmits(['approve', 'reject', 'return'])

const onApprove = (doc) => emit('approve', doc)
const onReject  = (doc) => emit('reject', doc)
const onReturn  = (doc) => emit('return', doc)
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
