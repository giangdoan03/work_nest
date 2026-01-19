<template>
    <a-card size="small" bordered class="stats">
        <template #title>📊 Thống kê trình</template>

        <div class="mono">
            <div v-for="s in stats" :key="s.key">
                [{{ s.key }}] {{ s.count }}/{{ s.limit }}
                <span v-if="s.count > s.limit" class="over">❌ OVER</span>
            </div>
        </div>
    </a-card>
</template>

<script setup>
const stats = [
    { key: 'NV_KD', count: 4, limit: 4 },
    { key: 'TP_KD', count: 3, limit: 3 },
    { key: 'PGD_TM', count: 2, limit: 1 },
]
</script>

<style scoped>
.mono {
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas;
    font-size: 12px;
}

.over {
    color: #ff4d4f;
    font-weight: 600;
}
</style>
