<template>
    <div style="width: 600px; height: 200px; margin: 0 auto; margin-top: 20px">
        <Bar :data="chartData" :options="chartOptions" style="width:500px; height:200px;" />
    </div>
</template>

<script setup>
import { computed } from 'vue'
import { Bar } from 'vue-chartjs'
import {
    Chart as ChartJS,
    BarElement,
    CategoryScale,
    LinearScale,
    Tooltip,
    Legend
} from 'chart.js'

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend)

// Props từ API: data là mảng tasks, mỗi task có assignee { id, name }
const props = defineProps({
    data: Array
})

const chartData = computed(() => {
    const userCount = props.data.reduce((acc, task) => {
        const name = task.assignee?.name || 'Chưa có'
        acc[name] = (acc[name] || 0) + 1
        return acc
    }, {})

    return {
        labels: Object.keys(userCount),
        datasets: [{
            label: 'Số công việc',
            data: Object.values(userCount),
            backgroundColor: '#69c0ff'
        }]
    }
})

const chartOptions = {
    responsive: true,
    plugins: {
        legend: { display: false }
    },
    scales: {
        x: { ticks: { autoSkip: false } },
        y: { beginAtZero: true }
    }
}
</script>

