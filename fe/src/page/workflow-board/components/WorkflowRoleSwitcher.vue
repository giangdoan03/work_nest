<template>
    <a-card size="small" bordered class="switcher">
        <a-space>
            <a-typography-text strong>🔐 Vai trò:</a-typography-text>

            <a-select
                v-model:value="role"
                style="width: 220px"
                :options="roles"
            />
        </a-space>
    </a-card>
</template>

<script setup>
import { ref, watch } from 'vue'

const role = ref('NV_KD')

const roles = [
    { label: 'Nhân viên Kinh doanh', value: 'NV_KD' },
    { label: 'Trưởng phòng Kinh doanh', value: 'TP_KD' },
    { label: 'Nhân viên Thương mại', value: 'NV_TM' },
    { label: 'Trưởng phòng Thương mại', value: 'TP_TM' },
    { label: 'PGĐ Thương mại', value: 'PGD_TM' },
    { label: 'PGĐ Kinh doanh', value: 'PGD_KD' },
    { label: 'Giám đốc', value: 'GD' },
]

watch(role, (v) => {
    console.log('🔁 Đổi role:', v)
    // sau này: set vào store
})
</script>

<style scoped>
.switcher {
    margin-bottom: 12px;
}
</style>
