<template>
    <div class="project_overview">
        <a-page-header title="Tổng quan dự án" style="padding-top: 0; padding-left: 0" />

        <div style="margin-bottom: 16px">
            <a-select v-model:value="timeframe" @change="fetchOverview" style="width: 200px">
                <a-select-option value="all">Tất cả</a-select-option>
                <a-select-option value="week">Tuần này</a-select-option>
                <a-select-option value="month">Tháng này</a-select-option>
                <a-select-option value="year">Năm nay</a-select-option>
            </a-select>
        </div>

        <a-table :dataSource="data" :loading="loading" rowKey="customer_id" bordered>
            <!-- Cột 1: Khách hàng -->
            <a-table-column title="Khách hàng" :width="200">
                <template #default="{ record }">
                    <TeamOutlined style="margin-right: 6px; color: #1890ff" />
                    <router-link :to="`/customers/${record.customer_id}`" class="link-style">
                        {{ record.customer_name }}
                    </router-link>
                </template>
            </a-table-column>

            <!-- Cột 2: Gói thầu + Hợp đồng -->
            <a-table-column title="Gói thầu / Hợp đồng" :width="300">
                <template #default="{ record }">
                    <div>
                        <!-- Gói thầu -->
                        <div v-if="record.biddings.length">
                            <strong style="color: #722ed1">Gói thầu:</strong>
                            <ul>
                                <li v-for="b in record.biddings.filter(b => b?.id && b?.title)" :key="b.id">
                                    <ProfileOutlined style="margin-right: 6px; color: #722ed1" />
                                    <router-link :to="`/bid-detail/${b.id}`">{{ b.title }}</router-link>
                                </li>
                            </ul>
                        </div>

                        <!-- Hợp đồng -->
                        <div>
                            <strong style="color: #fa541c">Hợp đồng:</strong>
                            <ul>
                                <li
                                    v-for="c in record.contracts.filter(c => c?.id && c?.title)"
                                    :key="c.id"
                                >
                                    <FileTextOutlined style="margin-right: 6px; color: #fa541c" />
                                    <router-link :to="`/contracts/${c.id}`">{{ c.title }}</router-link>
                                </li>
                                <!-- Nếu không có hợp đồng hợp lệ -->
                                <li v-if="!record.contracts.some(c => c?.id && c?.title)" style="list-style: none; margin-left: 8px; color: #999">
                                    Chưa có hợp đồng
                                </li>
                            </ul>
                        </div>
                    </div>
                </template>
            </a-table-column>



            <!-- Cột 3: Task gói thầu + hợp đồng -->
            <!-- Cột 3: Task liên quan -->
            <a-table-column title="Task liên quan" :width="400">
                <template #default="{ record }">
                    <div>
                        <!-- Task theo gói thầu -->
                        <div v-if="record.biddings.length">
                            <strong>Task gói thầu:</strong>
                            <div v-for="b in record.biddings" :key="'bid_' + b.id" style="margin-bottom: 8px">
                                <div v-if="b.tasks && b.tasks.length">
                                    <div style="font-weight: bold; margin-top: 4px; color: #722ed1">
                                        {{ b.title }}
                                    </div>
                                    <ul style="padding-left: 18px; margin: 4px 0">
                                        <li v-for="t in b.tasks" :key="t.id">{{ t.title }}</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <!-- Task theo hợp đồng -->
                        <div v-if="record.contracts.length">
                            <strong>Task hợp đồng:</strong>
                            <div v-for="c in record.contracts" :key="'contract_' + c.id" style="margin-bottom: 8px">
                                <div v-if="c.tasks && c.tasks.length">
                                    <div style="font-weight: bold; margin-top: 4px; color: #fa541c">
                                        {{ c.title }}
                                    </div>
                                    <ul style="padding-left: 18px; margin: 4px 0">
                                        <li v-for="t in c.tasks" :key="t.id">{{ t.title }}</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </template>
            </a-table-column>


            <!-- Cột 4: Tiến độ -->
            <a-table-column title="Tiến độ (%)" dataIndex="progress" :width="150">
                <template #default="{ record }">
                    <a-progress :percent="+record.progress" size="small" />
                </template>
            </a-table-column>

            <!-- Cột 5: Người phụ trách -->
            <a-table-column title="Người phụ trách" :width="160">
                <template #default="{ record }">
                    <ul style="padding-left: 0; margin: 0; list-style: none">
                        <li
                            v-for="u in record.assignees.filter(i => i?.name?.trim())"
                            :key="u.id"
                            style="display: flex; align-items: center; margin-bottom: 4px"
                        >
                            <UserOutlined style="margin-right: 6px; color: #13c2c2" />
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
import {
    TeamOutlined,
    ProfileOutlined,
    FileTextOutlined,
    UserOutlined
} from '@ant-design/icons-vue'

const loading = ref(false)
const data = ref([])
const timeframe = ref('all')

const fetchOverview = async () => {
    loading.value = true
    try {
        const res = await getProjectOverviewAPI({ timeframe: timeframe.value })
        const customers = res.data.data

        customers.forEach(customer => {
            const allTasks = customer.tasks || []

            // Gán task cho từng gói thầu
            customer.biddings.forEach(bid => {
                bid.tasks = allTasks.filter(t => t.linked_type === 'bidding' && String(t.linked_id) === String(bid.id))
            })

            // Gán task cho từng hợp đồng
            customer.contracts.forEach(contract => {
                contract.tasks = allTasks.filter(t => t.linked_type === 'contract' && String(t.linked_id) === String(contract.id))
            })
        })

        data.value = customers
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