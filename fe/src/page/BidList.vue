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
                :scroll="{ y: 'calc(100vh - 330px)' }"
        >
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ index + 1 }}
                </template>
                <template v-else-if="column.dataIndex === 'status'">
                    <a-tag :color="getStatusColor(record.status)">{{ record.status }}</a-tag>
                </template>
                <template v-else-if="column.dataIndex === 'action'">
                    <EyeOutlined
                            class="icon-action"
                            style="color: green;"
                            @click="goToDetail(record.id)"
                    />
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
        cloneFromTemplatesAPI
    } from '@/api/bidding'
    import {updateBiddingAPI} from "../api/bidding";

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
        end_date: null
    })

    const columns = [
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

    const getBiddings = async () => {
        loading.value = true
        try {
            const res = await getBiddingsAPI()
            tableData.value = res.data.data // ✅ chỉ lấy mảng `data`
        } catch (e) {
            message.error('Không thể tải gói thầu')
        } finally {
            loading.value = false
        }
    }

    const goToDetail = (id) => {
        router.push({ name: 'bid-detail', params: { id } })
    }

    const createBidding = async () => {
        loadingCreate.value = true
        try {
            const formatted = {
                ...formData.value,
                start_date: dayjs(formData.value.start_date).format('YYYY-MM-DD'),
                end_date: dayjs(formData.value.end_date).format('YYYY-MM-DD')
            }
            const res = await createBiddingAPI(formatted)
            await cloneFromTemplatesAPI(res.data.id)
            message.success('Tạo gói thầu thành công')
            onCloseDrawer()
            getBiddings()
        } catch (e) {
            message.error('Không thể tạo gói thầu')
        } finally {
            loadingCreate.value = false
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


    const submitForm = async () => {
        try {
            await formRef.value?.validate()

            if (selectedBidding.value) {
                await updateBiddingAPI(selectedBidding.value.id, {
                    ...formData.value,
                    start_date: dayjs(formData.value.start_date).format('YYYY-MM-DD'),
                    end_date: dayjs(formData.value.end_date).format('YYYY-MM-DD'),
                })
                message.success('Cập nhật thành công')
            } else {
                const res = await createBiddingAPI(formData.value)
                await cloneFromTemplatesAPI(res.data.id)
                message.success('Tạo gói thầu thành công')
            }

            onCloseDrawer()
            await getBiddings()
        } catch (e) {
            message.error('Có lỗi xảy ra')
        } finally {
            loadingCreate.value = false
        }
    }


    const onCloseDrawer = () => {
        openDrawer.value = false
        selectedBidding.value = null
        formRef.value?.resetFields()
    }

    const showPopupCreate = () => {
        openDrawer.value = true
    }

    onMounted(getBiddings)
</script>

<style scoped>
    .icon-action {
        font-size: 18px;
        margin-right: 24px;
        cursor: pointer;
    }
</style>