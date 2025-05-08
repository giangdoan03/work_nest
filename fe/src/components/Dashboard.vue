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
                <a-card title="Tình trạng quét" :bordered="false">
                    <v-chart class="chart" :option="option" style="height: 300px;" />
                </a-card>
            </a-col>
            <a-col :xs="24" :lg="8">

            </a-col>

        </a-row>
    </div>
</template>

<script setup>
import {
    AppstoreOutlined,
    InboxOutlined,
    BankOutlined,
    QrcodeOutlined,
    GiftOutlined,
    FormOutlined
} from '@ant-design/icons-vue'

import { ref, h } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import VChart from 'vue-echarts'

use([CanvasRenderer, BarChart, GridComponent, TooltipComponent, LegendComponent])

import { CalendarOutlined } from '@ant-design/icons-vue'
const cards = [
    { title: 'GÓI DỊCH VỤ', value: 3, icon: AppstoreOutlined, class: 'service' },
    { title: 'SẢN PHẨM', value: 2, icon: InboxOutlined, class: 'product' },
    { title: 'DOANH NGHIỆP', value: 0, icon: BankOutlined, class: 'company' },
    { title: 'QR CODE', value: 1, icon: QrcodeOutlined, class: 'qr-code' },
    { title: 'QR CODE MIỄN PHÍ', value: 1, icon: GiftOutlined, class: 'free-qr-code' },
    { title: 'KHẢO SÁT', value: 0, icon: FormOutlined, class: 'survey' }
]


const companies = ref([
    { name: 'CÔNG TY TNHH XNK SEGO', address: 'Trà Vinh', created: '14/11/2023 07:55:36' },
    { name: 'CÔNG TY TNHH XNK SEGO', address: 'Hà Đông, Hà Nội', created: '18/04/2023 15:10:45' },
    { name: 'CÔNG TY TNHH XNK SEGO', address: 'Bà Rịa - Vũng Tàu', created: '31/03/2023 12:23:31' },
])

const renderItem = (item) => {
    return h(
        'a-list-item',
        {},
        {
            default: () => [
                h('div', { class: 'company-item' }, [
                    // Avatar (thay bằng icon)
                    h('div', { class: 'company-avatar' }, [
                        h(BankOutlined, {
                            style: {
                                fontSize: '36px',
                                color: '#1890ff'
                            }
                        })
                    ]),

                    // Info
                    h('div', { class: 'company-info' }, [
                        h('div', { class: 'company-name' }, item.name),
                        h('div', { class: 'company-address' }, `Địa chỉ: ${item.address}`),
                        h('div', { class: 'company-date' }, [
                            h(CalendarOutlined, { style: 'margin-right: 4px;' }),
                            item.created
                        ])
                    ]),

                    // Action
                    h('div', { class: 'company-action' }, [
                        h('a-button', {
                            size: 'small',
                            style: { borderColor: '#52c41a', color: '#52c41a' }
                        }, 'Quét QR Code')
                    ])
                ])
            ]
        }
    )
}

use([CanvasRenderer, BarChart, GridComponent, TooltipComponent, LegendComponent])

const option = ref({
    tooltip: {},
    legend: { data: ['QR'] },
    xAxis: { type: 'category', data: ['Trà Vinh', 'Hà Nội', 'Vũng Tàu', 'TP.HCM'] },
    yAxis: { type: 'value' },
    series: [{
        name: 'QR',
        type: 'bar',
        data: [30, 50, 20, 40],
        itemStyle: { color: '#1890ff' }
    }]
})

</script>

<style scoped>
.mb-2 {
    margin-bottom: 16px;
}
.chart {
    width: 100%;
}
.dashboard {
    padding: 24px;
}

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
    font-size: 28px;
    font-weight: bold;
    margin-bottom: 6px;
}

.card-title {
    font-size: 14px;
    color: #888;
}

.card-value {
    font-size: 22px;
    font-weight: bold;
    line-height: 1.2;
}


.mb-2 {
    margin-bottom: 16px;
}
.mt-4 {
    margin-top: 32px;
}

.company-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap; /* Khi không đủ chỗ sẽ tự xuống dòng */
}

.company-info {
    flex: 1;
    min-width: 150px;
}

.company-name {
    font-weight: 500;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.company-address {
    color: #888;
    font-size: 12px;
}

.company-action {
    margin-left: 8px;
    margin-top: 8px;
}
@media (min-width: 576px) {
    .company-action {
        margin-top: 0;
    }
}
.company-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
}

.company-avatar {
    flex: 0 0 60px;
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
    margin-top: 4px;
}

.company-action {
    flex-shrink: 0;
}

.card :deep(.ant-card-body) {
    padding: 12px;
}

@media (max-width: 576px) {
    .company-action {
        width: 100%;
        text-align: right;
    }
}
:deep(.ant-list-item .ant-list-item-action) {
    margin-inline-start: 0 !important;
}
</style>
