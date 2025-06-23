<template>
    <div class="sub-task">
        <a-row justify="space-between">
            <a-col>
                <a-typography-title :level="5" style="color: #7c7c7c;"> Sub-Tasks</a-typography-title>
            </a-col>
            <a-col>
                <PlusOutlined style="font-size: 16px;cursor: pointer;" @click="showPopupCreate"/>
            </a-col>
        </a-row>
        <div v-if="!listSubTask.length" style="margin-bottom: 16px;">
            Không có dữ liệu
        </div>
        <div v-else>
            <a-table
                :columns="columns"
                :data-source="listSubTask"
                :loading="loadingSubTask"
                row-key="id"
                :pagination="false"
            >
                <template #bodyCell="{ column, record, text }">
                    <template v-if="column.key === 'title'">
                        <a-typography-link strong>{{ text }}</a-typography-link>
                    </template>
                    <template v-if="column.key === 'assigned_to'">
                        <a-typography-text>{{ getUserById(record.assigned_to) }}</a-typography-text>
                    </template>
                    <template v-if="column.key === 'date'">
                        <a-typography-text v-if="!isEditMode">{{ record.end_date }}</a-typography-text>
                    </template>
                    <template v-if="column.key === 'action'">
                        <a-dropdown>
                            <CaretDownOutlined />
                            <template #overlay>
                                <a-menu>
                                    <a-menu-item>
                                        Chi tiết
                                    </a-menu-item>
                                    <a-menu-item>
                                        Sửa
                                    </a-menu-item>
                                    <a-menu-item>
                                        Xóa
                                    </a-menu-item>
                                </a-menu>
                            </template>
                        </a-dropdown>
                    </template>
                </template>
            </a-table>
        </div>
    </div>
</template>
<script setup>

</script>
<style lang="scss">
    
</style>