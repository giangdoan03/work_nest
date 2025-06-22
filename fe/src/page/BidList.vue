<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách gói thầu</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Tạo gói thầu mới</a-button>
        </a-flex>

        <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                style="margin-top: 12px"
                row-key="id"
                :scroll="{ y: 'calc(100vh - 400px)' }"
        >
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ index + 1 }}
                </template>
                <template v-else-if="column.dataIndex === 'status'">
                    <a-tag :color="getStatusColor(record.status)">
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
                    <EyeOutlined class="icon-action" style="color: green;" @click="goToDetail(record.id)" />
                    <EditOutlined class="icon-action" style="color: blue;" @click="showPopupDetail(record)" />
                    <a-popconfirm
                            title="Bạn chắc chắn muốn xoá gói thầu này?"
                            ok-text="Xoá"
                            cancel-text="Huỷ"
                            @confirm="deleteConfirm(record.id)"
                            placement="topRight"
                    >
                        <DeleteOutlined class="icon-action" style="color: red;" />
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
                        <a-select-option value="pending">Chưa xử lý</a-select-option>
                        <a-select-option value="submitted">Đã nộp</a-select-option>
                        <a-select-option value="awarded">Đã trúng thầu</a-select-option>
                        <a-select-option value="lost">Không trúng</a-select-option>
                        <a-select-option value="cancelled">Đã huỷ</a-select-option>
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
    import { ref, onMounted } from 'vue'
    import { message } from 'ant-design-vue'
    import { EditOutlined, DeleteOutlined, EyeOutlined } from '@ant-design/icons-vue'
    import dayjs from 'dayjs'
    import {
        getBiddingsAPI,
        createBiddingAPI,
        cloneFromTemplatesAPI, deleteBiddingAPI
    } from '@/api/bidding'
    import {updateBiddingAPI} from "../api/bidding";
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
    const formData = ref({
        title: '',
        description: '',
        customer_id: 1,
        estimated_cost: 0,
        status: 'pending',
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
        const colors = {
            pending: 'orange',
            submitted: 'blue',
            awarded: 'green',
            lost: 'red',
            cancelled: 'gray'
        }
        return colors[status] || 'default'
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

    const getStatusText = (status) => {
        const map = {
            pending: 'Chưa nộp',
            submitted: 'Đã nộp hồ sơ',
            shortlisted: 'Vào vòng sau',
            awarded: 'Đã trúng thầu',
            lost: 'Không trúng',
            cancelled: 'Hủy thầu'
        }
        return map[status] || status
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
            // Log lỗi chi tiết
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

<style scoped>
    .icon-action {
        font-size: 18px;
        margin-right: 24px;
        cursor: pointer;
    }
</style>