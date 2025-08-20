<template>
    <div style="width: 400px; height: 200px; margin: 0 auto; margin-top: 20px">
        <Pie :data="chartData" :options="chartOptions" style="width:400px; height:200px;" />
    </div>
</template>

<script setup>
import { computed } from 'vue'
import { Pie } from 'vue-chartjs'
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

ChartJS.register(ArcElement, Tooltip, Legend)

const props = defineProps({
    data: {
        type: Array,
        default: () => []
    }
})

// 🏷️ Map trạng thái sang tiếng Việt
const statusLabels = {
    todo: 'Chưa làm',
    doing: 'Đang thực hiện',
    done: 'Hoàn thành',
    overdue: 'Quá hạn',
    request_approval: 'Chờ duyệt',
    cancel: 'Hủy',
    evaluating: 'Đang đánh giá'
}

// 🎨 Map trạng thái sang màu
const statusColors = {
    todo: '#d9d9d9',
    doing: '#ff4d4f',
    done: '#52c41a',
    overdue: '#1890ff',
    request_approval: '#faad14',
    cancel: '#bfbfbf',
    evaluating: '#722ed1'
}

const chartData = computed(() => {
    const counts = props.data.reduce((acc, task) => {
        const status = task.status || 'unknown'
        acc[status] = (acc[status] || 0) + 1
        return acc
    }, {})

    return {
        labels: Object.keys(counts).map(status => statusLabels[status] || status),
        datasets: [
            {
                data: Object.values(counts),
                backgroundColor: Object.keys(counts).map(status => statusColors[status] || '#999')
            }
        ]
    }
})

const chartOptions = {
    responsive: true,
    maintainAspectRatio: false, // quan trọng để height ăn theo div cha
    plugins: {
        legend: {
            position: 'right',
            labels: {
                font: {
                    size: 12
                }
            }
        },
        tooltip: {
            callbacks: {
                label: function(context) {
                    const label = context.label || ''
                    const value = context.parsed
                    return `${label}: ${value}`
                }
            }
        }
    }
}
</script>
