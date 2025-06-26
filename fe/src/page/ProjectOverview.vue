<template>
    <div class="project_overview">
        <a-page-header title="Tổng quan dự án" style="padding-top: 0; padding-left: 0" />

        <div style="margin-bottom: 16px;">
            <a-select v-model:value="timeframe" @change="fetchOverview" style="width: 200px;">
                <a-select-option value="all">Tất cả</a-select-option>
                <a-select-option value="week">Tuần này</a-select-option>
                <a-select-option value="month">Tháng này</a-select-option>
                <a-select-option value="year">Năm nay</a-select-option>
            </a-select>
        </div>

        <a-table :dataSource="data" :loading="loading" rowKey="customer_name" bordered>
            <a-table-column title="Khách hàng" :width="250">
                <template #default="{ record }">
                    <router-link :to="`/customers/${record.customer_id}`" class="link-style">
                        {{ record.customer_name }}
                    </router-link>
                </template>
            </a-table-column>


            <a-table-column title="Gói thầu" :width="350">
                <template #default="{ record }">
                    <ul style="padding-left: 16px; margin: 0;">
                        <li
                            v-for="b in record.biddings.filter(i => i?.title?.trim())"
                            :key="b.id"
                        >
                            <router-link :to="`/bid-detail/${b.id}`">{{ b.title }}</router-link>
                        </li>
                    </ul>
                </template>
            </a-table-column>



            <a-table-column title="Hợp đồng" :width="350">
                <template #default="{ record }">
                    <ul style="padding-left: 16px; margin: 0;">
                        <li
                            v-for="c in record.contracts.filter(i => i?.title?.trim())"
                            :key="c.id"
                        >
                            <router-link :to="`/contracts/${c.id}`">{{ c.title }}</router-link>
                        </li>
                    </ul>
                </template>
            </a-table-column>


            <a-table-column title="Task đang chạy">
                <template #default="{ record }">
                    <ul style="padding-left: 16px; margin: 0;">
                        <li
                            v-for="task in record.tasks"
                            :key="task.id"
                        >
                            <router-link :to="`/internal-tasks/${task.id}/info`">
                                {{ task.title }}
                            </router-link>
                            <a-tag
                                :color="task.status === 'done' ? 'green' : task.status === 'doing' ? 'blue' : 'orange'"
                                style="margin-left: 8px"
                            >
                                {{
                                    task.status === 'done'
                                        ? 'Hoàn thành'
                                        : task.status === 'doing'
                                            ? 'Đang làm'
                                            : 'Chưa làm'
                                }}
                            </a-tag>

                        </li>
                    </ul>
                </template>
            </a-table-column>



            <a-table-column title="Tiến độ (%)" dataIndex="progress">
                <template #default="{ record }">
                    <a-progress :percent="+record.progress" size="small" />
                </template>
            </a-table-column>

            <a-table-column title="Người phụ trách">
                <template #default="{ record }">
                    <ul style="padding-left: 16px; margin: 0;">
                        <li
                            v-for="u in record.assignees.filter(i => i?.name?.trim())"
                            :key="u.id"
                        >
                            <router-link :to="`/users/${u.id}`">{{ u.name }}</router-link>
                        </li>
                    </ul>
                </template>
            </a-table-column>

        </a-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getProjectOverviewAPI } from '@/api/project'
import { message } from 'ant-design-vue'

const loading = ref(false)
const data = ref([])
const timeframe = ref('all')

const fetchOverview = async () => {
    loading.value = true
    try {
        const res = await getProjectOverviewAPI({ timeframe: timeframe.value })
        data.value = res.data.data
    } catch (e) {
        message.error('Không thể tải dữ liệu tổng quan')
    } finally {
        loading.value = false
    }
}

onMounted(fetchOverview)
</script>

<style>
    .project_overview a {
        color: #000000e0;
    }
</style>
