<template>
    <div class="dashboard">
        <!-- Cards tổng quan -->
        <a-row :gutter="[16, 16]" class="card-row">
            <a-col
                v-for="card in cards"
                :key="card.title"
                :xs="24"
                :sm="12"
                :md="8"
                :lg="6"
                :xl="4"
            >
                <a-card :bordered="false" class="card" :class="card.class">
                    <div class="card-content">
                        <div class="card-icon">
                            <component :is="card.icon" />
                        </div>
                        <div class="card-value">{{ card.value }}</div>
                        <div class="card-title">{{ card.title }}</div>
                    </div>
                </a-card>
            </a-col>
        </a-row>

        <!-- Biểu đồ và danh sách -->
        <a-row :gutter="[16, 16]" class="mt-4">
            <a-col :xs="24" :lg="16">
                <a-card title="Tiến độ công việc theo phòng ban" :bordered="false">
                    <v-chart class="chart" :option="option" style="height: 300px;" />
                </a-card>
            </a-col>
            <a-col :xs="24" :lg="8">
                <a-card title="Khách hàng gần đây" :bordered="false">
                    <a-list :data-source="customers">
                        <template #renderItem="{ item }">
                            <a-list-item>
                                <div class="company-item">
                                    <div class="company-avatar">
                                        <UserOutlined style="font-size: 32px; color: #1890ff" />
                                    </div>
                                    <div class="company-info">
                                        <div class="company-name">{{ item.name }}</div>
                                        <div class="company-address">Công ty: {{ item.company }}</div>
                                        <div class="company-date">Ngày tham gia: {{ item.joined }}</div>
                                    </div>
                                </div>
                            </a-list-item>
                        </template>
                    </a-list>

                </a-card>
            </a-col>
        </a-row>
    </div>
</template>

<script setup>
import {
    FileTextOutlined,
    SolutionOutlined,
    TeamOutlined,
    ClockCircleOutlined,
    CheckCircleOutlined,
    CloseCircleOutlined,
    UserOutlined
} from '@ant-design/icons-vue'

import { ref, h } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import VChart from 'vue-echarts'

use([CanvasRenderer, BarChart, GridComponent, TooltipComponent, LegendComponent])

const cards = [
    { title: 'CÔNG VIỆC', value: 12, icon: FileTextOutlined, class: 'task' },
    { title: 'HỢP ĐỒNG', value: 8, icon: SolutionOutlined, class: 'contract' },
    { title: 'KHÁCH HÀNG', value: 24, icon: TeamOutlined, class: 'customer' },
    { title: 'ĐANG XỬ LÝ', value: 6, icon: ClockCircleOutlined, class: 'processing' },
    { title: 'HOÀN THÀNH', value: 14, icon: CheckCircleOutlined, class: 'completed' },
    { title: 'QUÁ HẠN', value: 2, icon: CloseCircleOutlined, class: 'overdue' }
]

const customers = ref([
    { name: 'Nguyễn Văn A', company: 'Công ty TNHH ABC', joined: '12/05/2024' },
    { name: 'Trần Thị B', company: 'Công ty CP XYZ', joined: '03/04/2024' },
    { name: 'Phạm Văn C', company: 'Công ty TNHH DEF', joined: '28/03/2024' }
])

const renderItem = (item) => {
    return h(
        'a-list-item',
        {},
        {
            default: () => [
                h('div', { class: 'company-item' }, [
                    h('div', { class: 'company-avatar' }, [
                        h(UserOutlined, { style: { fontSize: '32px', color: '#1890ff' } })
                    ]),
                    h('div', { class: 'company-info' }, [
                        h('div', { class: 'company-name' }, item.name),
                        h('div', { class: 'company-address' }, `Công ty: ${item.company}`),
                        h('div', { class: 'company-date' }, `Ngày tham gia: ${item.joined}`)
                    ])
                ])
            ]
        }
    )
}

const option = ref({
    tooltip: {},
    legend: { data: ['Công việc'] },
    xAxis: { type: 'category', data: ['Phòng IT', 'Phòng Kế toán', 'Phòng Kinh doanh', 'Phòng Nhân sự'] },
    yAxis: { type: 'value' },
    series: [{
        name: 'Công việc',
        type: 'bar',
        data: [20, 15, 30, 10],
        itemStyle: { color: '#52c41a' }
    }]
})
</script>

<style scoped>
.card {
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.3s ease;
    height: 100%;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    text-align: center;
    padding: 24px 16px;
}
.card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}
.card-content {
    display: flex;
    flex-direction: column;
    align-items: center;
}
.card-icon {
    font-size: 48px;
    color: #1890ff;
    margin-bottom: 12px;
}
.card-value {
    font-size: 22px;
    font-weight: bold;
    margin-bottom: 6px;
}
.card-title {
    font-size: 14px;
    color: #888;
}
.mt-4 {
    margin-top: 32px;
}
.company-item {
    display: flex;
    align-items: center;
    gap: 12px;
}
.company-avatar {
    flex: 0 0 40px;
}
.company-info {
    flex: 1;
    min-width: 150px;
}
.company-name {
    font-weight: 600;
    margin-bottom: 4px;
}
.company-address {
    color: #888;
    font-size: 12px;
}
.company-date {
    font-size: 12px;
    color: #888;
}
.chart {
    width: 100%;
}
</style>
