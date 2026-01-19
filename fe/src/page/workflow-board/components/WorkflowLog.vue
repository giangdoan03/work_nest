<template>
    <a-card size="small" bordered class="log">
        <template #title>📜 LOG</template>

        <div class="log-body mono">
            <div v-for="(l, i) in logs" :key="i">
                {{ l }}
            </div>
        </div>
    </a-card>
</template>

<script setup>
const logs = [
    '[10:01:02] NV_KD gửi hồ sơ',
    '[10:02:15] TP_KD duyệt',
    '[10:03:10] PGD_TM từ chối',
]
</script>

<style scoped>
.log-body {
    background: linear-gradient(180deg, #0f172a, #020617);
    color: #e5e7eb;
    padding: 10px;
    min-height: 140px;
    max-height: 200px;
    overflow-y: auto;
    font-size: 12px;
    border-radius: 6px;
}

.mono {
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas;
}
</style>
