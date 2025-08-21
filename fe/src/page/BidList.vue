<template>
    <div>
        <div>
            <a-flex justify="space-between">
                <a-typography-title :level="4">Danh sách gói thầu</a-typography-title>
                <a-button type="primary" @click="showPopupCreate">Thêm gói thầu mới</a-button>
            </a-flex>
        </div>
        <div class="summary-cards">
            <a-card
                v-for="item in statsBiddings"
                :key="item.key"
                :style="{ backgroundColor: item.bg, cursor:'pointer'}"
                @click="openBidDrawer(item.key,item.label)"
            >
                <a-space direction="vertical" align="center">
                    <component :is="item.icon" :style="{fontSize:'32px',color:item.color}" />
                    <div>{{ item.label }}</div>
                    <h2 class="number" :style="{ color: item.color }">{{ item.count }}</h2>
                </a-space>
            </a-card>
        </div>
        <a-flex justify="space-between">
            <div>
                <a-space>
                    <a-button danger v-if="selectedRowKeys.length" @click="handleBulkDelete">
                        Xóa {{ selectedRowKeys.length }} gói thầu
                    </a-button>
                </a-space>
            </div>
        </a-flex>

        <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                style="margin-top: 12px"
                row-key="id"
                :pagination="pagination"
                :scroll="{ x: 'max-content'}"
                :row-selection="rowSelection"
                @change="handleTableChange"
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
                <!-- Tiến độ -->
                <template v-else-if="column.dataIndex === 'progress'" style="width: 100px">
                    <a-progress
                        @click="openProgressModal(record)" style="cursor: pointer;"
                        :percent="Math.round((record.step_done_count / (record.step_count || 1)) * 100)"
                        :stroke-color="{
                                  '0%': '#108ee9',
                                  '100%': '#87d068',
                                }"
                        :status="record.status === 3 ? 'success' : 'active'"
                        size="small"
                        :show-info="true"
                    />
                </template>

                <!-- Người phụ trách -->
                <template v-else-if="column.dataIndex === 'assigned_to_name'">
                    <a-tooltip :title="record.assigned_to_name">
                        <a-avatar :style="{backgroundColor:getAvatarColor(record.assigned_to_name)}" size="small">
                            {{ getFirstLetter(record.assigned_to_name) }}
                        </a-avatar>
                    </a-tooltip>
                </template>

                <!-- Trạng thái -->
                <template v-else-if="column.dataIndex === 'status'">
                    <a-tag :color="getStatusColor(record.status)">{{ getStatusText(record.status) }}</a-tag>
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
                <template v-if="column.dataIndex === 'due'">
                    <a-tag v-if="record.days_remaining > 0" color="green">
                        Còn {{ record.days_remaining }} ngày
                    </a-tag>
                    <a-tag v-else-if="record.days_remaining === 0 && record.days_overdue === 0" color="gold">
                        Hạn chót hôm nay
                    </a-tag>
                    <a-tag v-else-if="record.days_overdue > 0" color="red">
                        Quá hạn {{ record.days_overdue }} ngày
                    </a-tag>
                    <a-tag v-else color="default">
                        Không xác định
                    </a-tag>
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
                <a-form-item label="Khách hàng" name="customer_id">
                    <a-select
                        v-model:value="formData.customer"
                        label-in-value
                        :options="customerOptions"
                        placeholder="Chọn khách hàng"
                        show-search
                        :filter-option="(input, option) =>
                        (option?.label ?? '').toLowerCase().includes(input.toLowerCase())"
                        @popupScroll="handleCustomerScroll"
                    />
                </a-form-item>
                <a-form-item label="Người phụ trách" name="assigned_to">
                    <a-select v-model:value="formData.assigned_to" :options="userOptions" placeholder="Chọn người phụ trách" />
                </a-form-item>
                <!-- Trạng thái -->
                <!-- Tạo/Sửa: Trạng thái -->
                <!-- chỉ hiện TAG nếu ĐANG SỬA và status là auto (0 hoặc 3) -->
                <template v-if="selectedBidding && isAutoStatus">
                    <a-form-item label="Trạng thái">
                        <a-tag :color="getStatusColor(formData.status)">
                            {{ getStatusText(formData.status) }}
                        </a-tag>
                    </a-form-item>
                </template>
                <template v-else>
                    <a-form-item label="Trạng thái" name="status">
                        <a-select
                            v-model:value="formData.status"
                            :options="editableStatusOptions"
                            placeholder="Chọn trạng thái"
                            allow-clear
                        />
                    </a-form-item>
                </template>


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

        <a-drawer
            :title="drawerBidTitle"
            placement="right"
            :width="1200"
            :open="drawerBidVisible"
            @close="drawerBidVisible = false">
            <a-table
                :columns="drawerBidColumns"
                :data-source="filteredBiddings"
                row-key="id"
                size="small"
                bordered
                :scroll="{ x: 800, y: 400 }"
            >
                <template #bodyCell="{ column, record, index }">
                    <template v-if="column.dataIndex === 'index'">
                        {{ index + 1 }}
                    </template>
                    <!-- Tiến độ -->
                    <template v-else-if="column.dataIndex === 'progress'">
                        <a-progress
                            :percent="Math.round((record.step_done_count / (record.step_count || 1)) * 100)"
                            size="small"
                            :status="record.status === 3 ? 'success' : 'active'"
                        />
                    </template>

                    <!-- Người phụ trách -->
                    <template v-else-if="column.dataIndex === 'assigned_to_name'">
                        <a-tooltip :title="record.assigned_to_name">
                            <a-avatar
                                :style="{ backgroundColor: getAvatarColor(record.assigned_to_name) }"
                                size="small"
                            >
                                {{ getFirstLetter(record.assigned_to_name) }}
                            </a-avatar>
                        </a-tooltip>
                    </template>
                    <template v-else-if="column.key === 'title'">
                        <a-tooltip :title="record.title">
                            <a-typography-text strong style="cursor: pointer" @click="goToDetail(record.id)">
                                {{ truncateText(record.title, 25) }}
                            </a-typography-text>
                        </a-tooltip>
                    </template>
                    <template v-else-if="column.dataIndex === 'estimated_cost'">
                        {{ formatCurrency(record.estimated_cost) }}
                    </template>
                    <template v-else-if="column.dataIndex === 'priority'">
                        <a-tag :color="record.priority === 'high' ? 'red' : 'blue'">
                            {{ record.priority === 'high' ? 'Gấp' : 'Bình thường' }}
                        </a-tag>
                    </template>
                    <template v-else-if="column.dataIndex === 'status'">
                        <a-tag :color="getStatusColor(record.status)">{{ getStatusText(record.status) }}</a-tag>
                    </template>
                    <template v-else-if="column.dataIndex === 'start_date'">{{ formatDate(record.start_date) }}</template>
                    <template v-else-if="column.dataIndex === 'end_date'">{{ formatDate(record.end_date) }}</template>
                    <template v-else-if="column.dataIndex === 'due'">
                        <a-tag v-if="record.days_remaining>0" color="green">Còn {{record.days_remaining}} ngày</a-tag>
                        <a-tag v-else-if="record.days_remaining===0&&record.days_overdue===0" color="gold">Hạn chót hôm nay</a-tag>
                        <a-tag v-else-if="record.days_overdue>0" color="red">Quá hạn {{record.days_overdue}} ngày</a-tag>
                    </template>
                </template>
            </a-table>
        </a-drawer>

    </div>
</template>

<script setup>
    import { ref, onMounted, computed, watch} from 'vue'
    import { message } from 'ant-design-vue'
    import {
        CheckCircleOutlined,
        CloseCircleOutlined,
        ClockCircleOutlined,
        EditOutlined,
        DeleteOutlined,
        EyeOutlined,
        FireOutlined, StopOutlined
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
    import {updateTask} from "@/api/task.js";
    import {getCustomers} from "@/api/customer.js";
    const router = useRouter()

    const formRef = ref(null)
    const selectedBidding = ref(null)
    const tableData = ref([])
    const loading = ref(false)
    const loadingCreate = ref(false)
    const openDrawer = ref(false)

    const progressModalVisible = ref(false)
    const selectedTask = ref(null)
    const newProgressValue = ref(0)
    const progressUpdating = ref(false)
    const customerOptions = ref([])

    const userOptions = ref([])
    const currentPage = ref(1)

    const selectedRowKeys = ref([])
    const selectedRows = ref([])


    const drawerBidVisible = ref(false)
    const drawerBidTitle = ref('')
    const drawerBidFilterKey = ref('')

    const customerPage = ref(1)
    const customerTotal = ref(0)
    const customerLoading = ref(false)

    const drawerBidColumns = [
        { title: 'STT', dataIndex: 'index', key: 'index', width: '50px', align: 'center' },
        { title: 'Tên gói thầu', dataIndex: 'title', key: 'title' },
        { title: 'Tiến độ', dataIndex: 'progress', key: 'progress', align: 'center' },

        { title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'center' },

        { title: 'Độ ưu tiên', dataIndex: 'priority', key: 'priority' },
        { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
        { title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date' },
        { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date' },
        { title: 'Hạn', dataIndex: 'due', key: 'due' }
    ]

    const columns = [
        { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
        { title: 'Tên gói thầu', dataIndex: 'title', key: 'title' },

        { title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: '150px' },
        { title: 'Người phụ trách', dataIndex: 'assigned_to_name', key: 'assigned_to_name', align: 'center' },

        { title: 'Chi phí dự toán', dataIndex: 'estimated_cost', key: 'estimated_cost' },
        { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
        { title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date' },
        { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date' },
        { title: 'Hạn', dataIndex: 'due', key: 'due', align: 'center' },

        { title: 'Hành động', dataIndex: 'action', key: 'action' }
    ];


    const openBidDrawer = (key, title) => {
        drawerBidFilterKey.value = key
        drawerBidTitle.value = title
        drawerBidVisible.value = true
    }

    const filteredBiddings = computed(() => {
        if    (drawerBidFilterKey.value === 'won')      return tableData.value.filter(b => b.status === 3)
        else if (drawerBidFilterKey.value === 'important') return tableData.value.filter(b => b.priority === 'high')
        else if (drawerBidFilterKey.value === 'normal')  return tableData.value.filter(b => b.priority === 'normal')
        else if (drawerBidFilterKey.value === 'overdue') return tableData.value.filter(b => b.days_overdue > 0)
        else if (drawerBidFilterKey.value === 'lost')    return tableData.value.filter(b => b.status === 4)
        return []
    })

    const statsBiddings = computed(() => [
        {
            key: 'won',
            label: 'Trúng thầu',
            count: tableData.value.filter(b => b.status === 3).length,
            color: '#52c41a',
            bg: '#f6ffed',
            icon: CheckCircleOutlined
        },
        {
            key: 'important',
            label: 'Quan trọng',
            count: tableData.value.filter(b => b.priority === 'high').length,
            color: '#faad14',
            bg: '#fffbe6',
            icon: FireOutlined
        },
        {
            key: 'normal',
            label: 'Bình thường',
            count: tableData.value.filter(b => b.priority === 'normal').length,
            color: '#1890ff',
            bg: '#e6f7ff',
            icon: ClockCircleOutlined
        },
        {
            key: 'overdue',
            label: 'Quá hạn',
            count: tableData.value.filter(b => b.days_overdue > 0).length,
            color: '#ff4d4f',
            bg: '#fff1f0',
            icon: CloseCircleOutlined
        },
        {
            key: 'lost',
            label: 'Không trúng',
            count: tableData.value.filter(b => b.status === 4).length,
            color: '#d9363e',
            bg: '#fff1f0',
            icon: StopOutlined
        }
    ])


    const getFirstLetter = (name) => {
        if (!name || name === 'N/A') return '?'
        return name.charAt(0).toUpperCase()
    }

    const getAvatarColor = (name) => {
        if (!name || name === 'N/A') return '#d9d9d9'

        // Generate consistent color based on name
        const colors = [
            '#f5222d', '#fa8c16', '#fadb14', '#52c41a',
            '#13c2c2', '#1890ff', '#722ed1', '#eb2f96',
            '#fa541c', '#faad14', '#a0d911', '#52c41a',
            '#13c2c2', '#1890ff', '#722ed1', '#eb2f96'
        ]

        // Simple hash function to get consistent color for same name
        let hash = 0
        for (let i = 0; i < name.length; i++) {
            hash = name.charCodeAt(i) + ((hash << 5) - hash)
        }
        const index = Math.abs(hash) % colors.length
        return colors[index]
    }


    const openProgressModal = (task) => {
        selectedTask.value = task;
        newProgressValue.value = Number(task.progress) || 0;   // ✅ fix warning
        progressModalVisible.value = true;
    };


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
        customer_id: null,
        estimated_cost: 0,
        status: 0,
        start_date: null,
        end_date: null,
        assigned_to: null,
        customer: null
    })

    const customerLabelById = (id) => {
        const opt = customerOptions.value.find(o => o.value === Number(id))
        return opt?.label || null
    }

    const loadCustomers = async (page = 1) => {
        customerLoading.value = true
        try {
            const res = await getCustomers({ page, per_page: 20 }) // API index
            const list = res.data.data
            customerTotal.value = res.data.pager.total

            if (page === 1) {
                customerOptions.value = []
            }
            customerOptions.value = [
                ...customerOptions.value,
                ...list.map(c => ({
                    value: Number(c.id),
                    label: [c.name, c.phone, c.email].filter(Boolean).join(' • ')
                }))
            ]
        } finally {
            customerLoading.value = false
        }
    }

    const handleCustomerScroll = (e) => {
        const target = e.target
        if (target.scrollTop + target.offsetHeight >= target.scrollHeight - 10) {
            if (customerOptions.value.length < customerTotal.value && !customerLoading.value) {
                customerPage.value++
                loadCustomers(customerPage.value)
            }
        }
    }

    // lần đầu load
    onMounted(() => {
        loadCustomers(1)
    })


    watch(() => openDrawer.value, (open) => {
        if (open) loadCustomers()
    })

    const pagination = ref({
        current: 1,
        pageSize: 10,
        total: 0,
        showSizeChanger: true,
        pageSizeOptions: ['10', '20', '50', '100'],
        showTotal: (total, range) => `${range[0]}-${range[1]} / ${total} gói thầu`
    })

    const handleTableChange = (pag /*, filters, sorter */) => {
        pagination.value.current = pag.current
        pagination.value.pageSize = pag.pageSize
        getCustomers()
    }


    // Định nghĩa mapping trạng thái dùng chung
    const STATUS_MAP = {
        0: { text: 'Trúng thầu', color: 'green' },
        1: { text: 'Quan trọng', color: 'red' },
        2: { text: 'Bình thường', color: 'blue' },
        3: { text: 'Quá hạn', color: 'orange' },
        4: { text: 'Không trúng thầu', color: 'gray' }
    }


    const editableStatusOptions = [
        { value: 1, label: STATUS_MAP[1].text }, // Quan trọng
        { value: 2, label: STATUS_MAP[2].text }, // Bình thường
        { value: 4, label: STATUS_MAP[4].text }  // Không trúng thầu
    ]


    const getStatusText  = s => (s == null ? '' : (STATUS_MAP[s]?.text || 'Không rõ'))
    const getStatusColor = s => STATUS_MAP[s]?.color || 'default'

    // chỉ coi là auto khi giá trị là 0 hoặc 3
    const isAutoStatus = computed(() => [0, 3].includes(Number(formData.value.status)))

    const rules = {
        title: [{ required: true, message: 'Nhập tên gói thầu' }],
        description: [{ required: true, message: 'Nhập mô tả' }],
        start_date: [{ required: true, message: 'Chọn ngày bắt đầu' }],
        end_date: [{ required: true, message: 'Chọn ngày kết thúc' }],
        estimated_cost: [{ required: true, message: 'Nhập chi phí dự toán' }],
        status: [{ required: true, message: 'Chọn trạng thái' }],
        customer: [
            { required: true, message: 'Chọn khách hàng', trigger: 'change' },
            {
                validator: (_rule, v) => (v && v.value ? Promise.resolve() : Promise.reject('Chọn khách hàng')),
                trigger: 'change'
            }
        ],
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
            loadingCreate.value = true

            const formatted = {
                ...formData.value,
                start_date: dayjs(formData.value.start_date).format('YYYY-MM-DD'),
                end_date: dayjs(formData.value.end_date).format('YYYY-MM-DD'),
                customer_id: formData.value.customer?.value ?? null
            }

            // Kiểm tra trước khi set "Đã trúng thầu"
            if (formatted.status === 3 && selectedBidding.value?.id) {
                const res = await canMarkBiddingAsCompleteAPI(selectedBidding.value.id)
                if (!res?.data?.allow) {
                    message.warning(
                        'Bạn cần hoàn thành tất cả các bước trước khi chuyển trạng thái gói thầu sang "Đã trúng thầu".'
                    )
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
        const id = record.customer_id != null ? Number(record.customer_id) : null
        formData.value = {
            ...record,
            status: Number(record.status),
            start_date: dayjs(record.start_date),
            end_date: dayjs(record.end_date),
            customer: id ? { value: id, label: record.customer_name || customerLabelById(id) || `#${id}` } : null
        }
        openDrawer.value = true
    }

    const onCloseDrawer = () => {
        openDrawer.value = false
        selectedBidding.value = null
        formRef.value?.resetFields()
    }

    const showPopupCreate = () => {
        selectedBidding.value = null
        formRef.value?.resetFields()
        formData.value = {
            title: '',
            description: '',
            customer_id: null,
            estimated_cost: 0,
            status: null,
            start_date: null,
            end_date: null,
            assigned_to: null
        }
        openDrawer.value = true
    }

    onMounted(() => {
        fetchUsers()
        getBiddings()
    })

</script>


<style>
.summary-cards .ant-card-body{
    cursor: pointer;
}
.title_chart {
    text-align: center;
    color: rgb(170, 170, 170);
}

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

.summary-cards {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
}
.summary-cards .ant-card {
    flex: 1;
    min-width: 200px;
    text-align: center;
}
.no-tasks {
    text-align: center;
    padding: 32px;
    font-style: italic;
}
</style>