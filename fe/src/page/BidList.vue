<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách hợp đồng</a-typography-title>
            </div>
            <div>
                <a-space>
                    <a-button danger v-if="selectedRowKeys.length" @click="handleBulkDelete">
                        Xóa {{ selectedRowKeys.length }} hợp đồng
                    </a-button>
                    <a-button type="primary" @click="showPopupCreate">Thêm hợp đồng mới</a-button>
                </a-space>
            </div>
        </a-flex>

        <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                style="margin-top: 12px"
                row-key="id"
                :scroll="{ y: 'calc(100vh - 400px)' }"
                :row-selection="rowSelection"
        >
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ index + 1 }}
                </template>
                <template v-else-if="column.key === 'title'">
                    <a-tooltip :title="record.title">
                        <a-typography-text strong style="cursor: pointer" @click="goToDetail(record.id)">
                            {{ truncateText(record.title, 25) }}
                        </a-typography-text>
                    </a-tooltip>
                </template>
                <template v-else-if="column.dataIndex === 'status'">
                    <a-tag :color="getStatusColor(record.status)">
                        <template #icon>
                            <CheckCircleOutlined v-if="record.status === 3" />
                            <CloseCircleOutlined v-if="record.status === 4" />
                            <ClockCircleOutlined v-if="record.status === 0" />
                        </template>
                        {{ getStatusText(record.status) }}
                    </a-tag>
                </template>
                <template v-else-if="column.dataIndex === 'estimated_cost'">
                    {{ formatCurrency(record.estimated_cost) }}
                </template>
                <template v-else-if="column.dataIndex === 'start_date' || column.dataIndex === 'end_date'">
                    {{ formatDate(record[column.dataIndex]) }}
                </template>
                <template v-else-if="column.dataIndex === 'action'">
                    <a-tooltip title="Xem chi tiết">
                        <EyeOutlined class="icon-action" style="color: #52c41a;" @click="goToDetail(record.id)" />
                    </a-tooltip>
                    <a-tooltip title="Chỉnh sửa">
                        <EditOutlined class="icon-action" style="color: #1890ff;" @click="showPopupDetail(record)" />
                    </a-tooltip>
                    <a-popconfirm
                            title="Bạn chắc chắn muốn xoá gói thầu này?"
                            ok-text="Xoá"
                            cancel-text="Huỷ"
                            @confirm="deleteConfirm(record.id)"
                            placement="topRight"
                    >
                        <a-tooltip title="Xoá">
                            <DeleteOutlined class="icon-action" style="color: red;" />
                        </a-tooltip>
                    </a-popconfirm>
                </template>

            </template>
        </a-table>

        <a-drawer
                title="Tạo gói thầu mới"
                :width="700"
                :open="openDrawer"
                :footer-style="{ textAlign: 'right' }"
                @close="onCloseDrawer"
        >
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-form-item label="Tên gói thầu" name="title">
                    <a-input v-model:value="formData.title" placeholder="Nhập tên gói thầu" />
                </a-form-item>
                <a-form-item label="Chi tiết mô tả" name="description">
                    <a-textarea v-model:value="formData.description" :rows="3" placeholder="Nhập mô tả chi tiết" />
                </a-form-item>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Ngày bắt đầu" name="start_date">
                            <a-date-picker v-model:value="formData.start_date" style="width: 100%" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Ngày kết thúc" name="end_date">
                            <a-date-picker v-model:value="formData.end_date" style="width: 100%" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-form-item label="Chi phí dự toán" name="estimated_cost">
                    <a-input-number v-model:value="formData.estimated_cost" style="width: 100%" :min="0" />
                </a-form-item>
                <a-form-item label="Người phụ trách" name="assigned_to">
                    <a-select v-model:value="formData.assigned_to" :options="userOptions" placeholder="Chọn người phụ trách" />
                </a-form-item>
                <a-form-item label="Trạng thái" name="status">
                    <a-select v-model:value="formData.status" placeholder="Chọn trạng thái">
                        <a-select-option :value="0">Chưa nộp</a-select-option>
                        <a-select-option :value="1">Đã nộp hồ sơ</a-select-option>
                        <a-select-option :value="2">Vào vòng sau</a-select-option>
                        <a-select-option :value="3">Đã trúng thầu</a-select-option>
                        <a-select-option :value="4">Không trúng</a-select-option>
                        <a-select-option :value="5">Hủy thầu</a-select-option>
                    </a-select>
                </a-form-item>
            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Huỷ</a-button>
                    <a-button type="primary" :loading="loadingCreate" @click="submitForm">
                        {{ selectedBidding ? 'Cập nhật' : 'Tạo mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
    import { ref, onMounted, computed } from 'vue'
    import { message } from 'ant-design-vue'
    import {
        CheckCircleOutlined,
        CloseCircleOutlined,
        ClockCircleOutlined,
        EditOutlined,
        DeleteOutlined,
        EyeOutlined
    } from '@ant-design/icons-vue';
    import dayjs from 'dayjs'
    import {
        getBiddingsAPI,
        createBiddingAPI,
        cloneFromTemplatesAPI, deleteBiddingAPI
    } from '@/api/bidding'
    import {updateBiddingAPI, canMarkBiddingAsCompleteAPI } from "../api/bidding";
    import { formatDate } from '@/utils/formUtils' // nếu bạn đã có
    import {getUsers} from '@/api/user.js'

    import { useRouter } from 'vue-router'
    const router = useRouter()

    const formRef = ref(null)
    const selectedBidding = ref(null)
    const tableData = ref([])
    const loading = ref(false)
    const loadingCreate = ref(false)
    const openDrawer = ref(false)


    const selectedRowKeys = ref([])
    const selectedRows = ref([])

    const rowSelection = computed(() => ({
        selectedRowKeys: selectedRowKeys.value,
        onChange: (keys, rows) => {
            selectedRowKeys.value = keys
            selectedRows.value = rows
        }
    }))

    const handleBulkDelete = async () => {
        try {
            await Promise.all(selectedRowKeys.value.map(id => deleteBiddingAPI(id)))
            message.success(`Đã xoá ${selectedRowKeys.value.length} gói thầu`)
            selectedRowKeys.value = []
            await getBiddings()
        } catch (err) {
            message.error('Không thể xoá gói thầu')
        }
    }

    const truncateText = (text, length = 30) => {
        if (!text) return '';
        return text.length > length ? text.slice(0, length) + '...' : text;
    }


    const formData = ref({
        title: '',
        description: '',
        customer_id: 1,
        estimated_cost: 0,
        status: 0,
        start_date: null,
        end_date: null,
        assigned_to: null
    })

    const userOptions = ref([])

    const currentPage = ref(1)

    const columns = [
        { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
        { title: 'Tên gói thầu', dataIndex: 'title', key: 'title' },
        { title: 'Chi phí dự toán', dataIndex: 'estimated_cost', key: 'estimated_cost' },
        { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
        { title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date' },
        { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date' },
        { title: 'Hành động', dataIndex: 'action', key: 'action' }
    ]

    const getStatusColor = (status) => {
        const map = {
            0: 'orange',   // Chưa nộp
            1: 'blue',     // Đã nộp
            2: 'purple',   // Vào vòng sau
            3: 'green',    // Trúng thầu
            4: 'red',      // Không trúng
            5: 'gray'      // Hủy
        }
        return map[status] || 'default'
    }

    const getStatusText = (status) => {
        const map = {
            0: 'Chưa nộp',
            1: 'Đã nộp hồ sơ',
            2: 'Vào vòng sau',
            3: 'Đã trúng thầu',
            4: 'Không trúng',
            5: 'Hủy thầu',
        }
        return map[status] ?? 'Không rõ'
    }


    const rules = {
        title: [{ required: true, message: 'Nhập tên gói thầu' }],
        description: [{ required: true, message: 'Nhập mô tả' }],
        start_date: [{ required: true, message: 'Chọn ngày bắt đầu' }],
        end_date: [{ required: true, message: 'Chọn ngày kết thúc' }],
        estimated_cost: [{ required: true, message: 'Nhập chi phí dự toán' }],
        status: [{ required: true, message: 'Chọn trạng thái' }]
    }

    const formatCurrency = (value) => {
        if (!value) return '0 đ'
        return Number(value).toLocaleString('vi-VN') + ' đ'
    }

    const fetchUsers = async () => {
        const res = await getUsers()
        userOptions.value = res.data.map(user => ({
            label: user.name,
            value: user.id
        }))
    }

    const getBiddings = async () => {
        loading.value = true
        try {
            const res = await getBiddingsAPI({ page: currentPage.value, per_page: 20 }) // hoặc 100
            tableData.value = res.data.data
        } catch (e) {
            message.error('Không thể tải gói thầu')
        } finally {
            loading.value = false
        }
    }

    const goToDetail = (id) => {
        router.push({ name: 'bid-detail', params: { id } })
    }

    const submitForm = async () => {
        try {
            await formRef.value?.validate()

            const formatted = {
                ...formData.value,
                start_date: dayjs(formData.value.start_date).format('YYYY-MM-DD'),
                end_date: dayjs(formData.value.end_date).format('YYYY-MM-DD')
            }

            // 🚫 Nếu chọn trạng thái "Hoàn thành" (status === 4), kiểm tra trước
            if (formatted.status === 3 && selectedBidding.value?.id) {
                const res = await canMarkBiddingAsCompleteAPI(selectedBidding.value.id)
                if (!res?.data?.allow) {
                    message.warning('Bạn cần hoàn thành tất cả các bước trước khi chuyển trạng thái gói thầu sang "Đã trúng thầu".')
                    return
                }
            }

            if (selectedBidding.value) {
                await updateBiddingAPI(selectedBidding.value.id, formatted)
                message.success('Cập nhật thành công')
            } else {
                const res = await createBiddingAPI(formatted)
                await cloneFromTemplatesAPI(res.data.id)
                message.success('Tạo gói thầu thành công')
            }

            onCloseDrawer()
            await getBiddings()
        } catch (e) {
            console.error('Lỗi submitForm:', e?.response?.data || e)
            const errMsg = e?.response?.data?.message || 'Có lỗi xảy ra'
            message.error(errMsg)
        } finally {
            loadingCreate.value = false
        }
    }


    const deleteConfirm = async (id) => {
        try {
            // Gọi API xoá (bạn cần có API deleteBiddingAPI tương ứng)
            await deleteBiddingAPI(id)
            message.success('Xoá gói thầu thành công')
            await getBiddings()
        } catch (e) {
            message.error('Xoá gói thầu thất bại')
        }
    }

    const showPopupDetail = (record) => {
        selectedBidding.value = record
        formData.value = {
            ...record,
            status: Number(record.status),
            start_date: dayjs(record.start_date),
            end_date: dayjs(record.end_date),
        }
        openDrawer.value = true
    }

    const onCloseDrawer = () => {
        openDrawer.value = false
        selectedBidding.value = null
        formRef.value?.resetFields()
    }

    const showPopupCreate = () => {
        openDrawer.value = true
    }

    onMounted(() => {
        fetchUsers()
        getBiddings()
    })

</script>

<style>
    :deep(.ant-table-tbody > tr:hover) {
        background-color: #f5faff !important;
        transition: background-color 0.3s;
    }
</style>

<style scoped>
    .icon-action {
        font-size: 18px;
        margin-right: 24px;
        cursor: pointer;
    }
</style>