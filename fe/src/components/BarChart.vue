<template>
    <div><Bar :data="chartData" :options="chartOptions" /></div>
</template>

<script setup>
import { computed } from 'vue'
import { Bar } from 'vue-chartjs'
import {
    Chart as ChartJS, BarElement, CategoryScale, LinearScale, Tooltip, Legend
} from 'chart.js'

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend)

const props = defineProps({ data: Array })

const chartData = computed(() => {
    const userCount = props.data.reduce((acc, t) => {
        const name = t.name || 'Chưa có'
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
