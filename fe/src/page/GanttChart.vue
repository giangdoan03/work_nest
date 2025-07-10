<template>
    <div>
        <div id="GanttChartBidding" style="height: 50vh; width: 100%; overflow: hidden; border-bottom: 1px solid #eee;"></div>
        <div id="ContractGanttDIV" style="height: 50vh; width: 100%; overflow: hidden;"></div>
    </div>
</template>

<script setup>
    import { onMounted } from 'vue'
    import { getBiddingsAPI } from '@/api/bidding'
    import { getContractsAPI } from '@/api/contract'

    const loadScript = (src) => {
        return new Promise((resolve) => {
            const script = document.createElement('script')
            script.src = src
            script.onload = resolve
            document.head.appendChild(script)
        })
    }

    onMounted(async () => {
        await loadScript('https://cdn.jsdelivr.net/npm/jsgantt-improved@2.7.0/dist/jsgantt.js')
        renderBiddingGantt()
        renderContractGantt()
    })

    const renderBiddingGantt = async () => {
        const g = new window.JSGantt.GanttChart(document.getElementById('GanttChartBidding'), 'day')
        if (!g.getDivId()) return alert("Không thể tạo Gantt gói thầu")

        g.setOptions({ /* ... */ })

        const resBidding = await getBiddingsAPI()
        const data = resBidding.data.data

        g.AddTaskItemObject({
            pID: 1,
            pName: '📦 Gantt Gói thầu',
            pStart: '2025-01-01',
            pEnd: '2025-12-31',
            pClass: 'ggroupblack',
            pGroup: 1,
            pOpen: 1,
            pParent: 0,
        })

        data.forEach((item, index) => {
            g.AddTaskItemObject({
                pID: 100 + index,
                pName: `<a href="/biddings/${item.id}" target="_blank">${item.title}</a>`,
                pStart: item.start_date,
                pEnd: item.end_date,
                pClass: 'gtaskblue',
                pGroup: 0,
                pParent: 1,
                pOpen: 1,
                pRes: `Người phụ trách: ${item.assigned_to}`,
                pCaption: '',
            })
        })

        g.Draw()
    }


    const renderContractGantt = async () => {
        const g = new window.JSGantt.GanttChart(document.getElementById('ContractGanttDIV'), 'day')

        if (!g.getDivId()) {
            alert("Không thể khởi tạo Gantt chart cho hợp đồng!")
            return
        }

        g.setOptions({
            vCaptionType: 'Complete',
            vQuarterColWidth: 36,
            vDateTaskDisplayFormat: 'day dd month yyyy',
            vDayMajorDateDisplayFormat: 'mon yyyy - Week ww',
            vWeekMinorDateDisplayFormat: 'dd mon',
            vShowTaskInfoLink: 1,
            vShowEndWeekDate: 0,
            vUseSingleCell: 10000,
            vFormatArr: ['Day', 'Week', 'Month']
        })

        try {
            const res = await getContractsAPI()
            const contracts = Array.isArray(res.data) ? res.data : []
            g.AddTaskItemObject({
                pID: 1000,
                pName: 'Danh sách hợp đồng',
                pStart: '',
                pEnd: '',
                pClass: 'ggroupblack',
                pGroup: 1,
                pOpen: 1,
                pCaption: '',
                pParent: 0,
                pRes: 'Người thực hiện'
            })

            contracts.forEach(contract => {
                g.AddTaskItemObject({
                    pID: parseInt(contract.id),
                    pName: `${contract.title}`,
                    pStart: contract.start_date,
                    pEnd: contract.end_date,
                    pClass: 'gtaskgreen',
                    pComp: 0,
                    pGroup: 0,
                    pParent: 1000,
                    pOpen: 1,
                    pRes: `User ${contract.assigned_to}`,
                    pCaption: '',
                    pNotes: contract.description || '—'
                })
            })

            g.Draw()
        } catch (err) {
            console.error('Lỗi khi render biểu đồ hợp đồng:', err)
        }
    }

</script>

<style scoped>
    @import url('https://cdn.jsdelivr.net/npm/jsgantt-improved@2.7.0/dist/jsgantt.css');
</style>
