<!-- src/components/LoyaltyHistory.vue -->
<template>
    <a-card title="Lịch sử người chơi">
        <a-tabs v-model:activeKey="activeTab">
            <a-tab-pane key="participation" tab="Lịch sử tham gia">
                <HistoryParticipation />
            </a-tab-pane>
            <a-tab-pane key="winning" tab="Lịch sử trúng thưởng">
                <HistoryWinning />
            </a-tab-pane>
        </a-tabs>
    </a-card>
</template>

<script setup>
import { ref } from 'vue'
import HistoryParticipation from './HistoryParticipation.vue'
import HistoryWinning from './HistoryWinning.vue'

const activeTab = ref('participation')
</script>
