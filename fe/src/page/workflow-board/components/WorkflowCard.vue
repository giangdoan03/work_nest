<template>
    <a-card
        size="small"
        class="workflow-card"
        :class="{ highlight }"
        hoverable
        @click="goDetail"
    >
        <div class="title">{{ doc.title }}</div>

        <div class="meta">
            <a-tag color="blue">{{ doc.department_name }}</a-tag>
            <a-tag>{{ doc.status }}</a-tag>
        </div>

        <div class="footer">
            <span>#{{ doc.id }}</span>
            <span>{{ doc.assigned_to_name }}</span>
        </div>
    </a-card>
</template>

<script setup>
import { useRouter } from 'vue-router'

const props = defineProps({
    doc: Object,
    highlight: Boolean,
})

const router = useRouter()

const goDetail = () => {
    router.push({
        name: 'workflow-task-info',
        params: { id: props.doc.id },
    })
}
</script>

<style scoped>
.workflow-card {
    cursor: pointer;
}

.workflow-card.highlight {
    border: 1px solid #1677ff;
    box-shadow: 0 0 0 2px rgba(22, 119, 255, 0.25);
}

.title {
    font-weight: 600;
}

.meta {
    margin-top: 6px;
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
}

.footer {
    margin-top: 6px;
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    color: #888;
}
</style>
