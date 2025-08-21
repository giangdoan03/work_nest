<template>
    <div style="width: 800px; height: 200px; margin: 20px auto 0;">
        <Bar :data="chartData" :options="chartOptions" style="width:800px; height:200px;" />
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
import dayjs from 'dayjs'

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend)

const props = defineProps({ data: Array })

const chartData = computed(() => {
    // Đếm số công việc theo tháng (01–12)
    const monthCount = props.data.reduce((acc, task) => {
        const month = task.end_date ? dayjs(task.end_date).format('MM') : '00'
        acc[month] = (acc[month] || 0) + 1
        return acc
    }, {})

    // Đảm bảo đủ 12 tháng, gán 0 nếu không có dữ liệu
    const allMonths = Array.from({ length: 12 }, (_, i) => String(i + 1).padStart(2, '0'))

    return {
        labels: allMonths,
        datasets: [
            {
                label: 'Số công việc',
                data: allMonths.map(m => monthCount[m] || 0),
                backgroundColor: [
                    '#73d13d', '#ff7875', '#8c8c8c', '#9254de', '#ffc53d', '#597ef7',
                    '#ff85c0', '#ffa940', '#36cfc9', '#ff4d4f', '#40a9ff', '#b37feb'
                ]
            }
        ]
    }
})

const chartOptions = {
    responsive: true,
    plugins: {
        legend: { display: false }
    },
    scales: {
        x: { title: { display: true, text: 'Tháng' } },
        y: {
            beginAtZero: true,
            title: { display: true, text: 'Số lượng' },
            ticks: {
                stepSize: 1,    // 🟢 luôn tăng theo số nguyên
                precision: 0    // 🟢 bỏ số thập phân như 1.5
            }
        }
    }
}

</script>
