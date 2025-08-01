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
                :row-selection="rowSelection"
                 style="margin-top: 12px;"
                row-key="id"
                :scroll="{y: 'calc( 100vh - 330px )'}">
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ index+1 }}
                </template>
                <template v-if="column.dataIndex === 'name'">
                    <a-tooltip :title="record.name">
                        <a-typography-text strong style="cursor: pointer" @click="goToContractDetail(record.id)">
                            {{ truncateText(record.name, 25) }}
                        </a-typography-text>
                    </a-tooltip>
                </template>

                <template v-else-if="column.dataIndex === 'status'">
                    <a-tag :color="getStatusColor(record.status)">
                        {{ getStatusLabel(record.status) }}
                    </a-tag>
                </template>
                <template v-else-if="column.dataIndex === 'action'">
                    <EyeOutlined
                            class="icon-action"
                            style="color: #1890ff;"
                            @click="goToContractDetail(record.id)"
                    />
                    <EditOutlined
                            class="icon-action"
                            style="color: blue;"
                            @click="showPopupDetail(record)"
                    />
                    <a-popconfirm
                            title="Bạn chắc chắn muốn xóa hợp đồng này?"
                            ok-text="Xóa"
                            cancel-text="Hủy"
                            @confirm="deleteConfirm(record.id)"
                            placement="topRight"
                    >
                        <DeleteOutlined class="icon-action" style="margin: 0; color: red;"/>
                    </a-popconfirm>
                </template>

            </template>
        </a-table>

        <a-drawer :title="selectedContract ? 'Sửa hợp đồng' : 'Tạo hợp đồng mới'" :width="700" :open="openDrawer"
                  :body-style="{ paddingBottom: '80px' }"
                  :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Tên hợp đồng" name="name">
                            <a-input v-model:value="formData.name" placeholder="Nhập tên hợp đồng"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Mã hợp đồng" name="code">
                            <a-input v-model:value="formData.code" placeholder="Nhập mã hợp đồng"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Trạng thái" name="status">
                            <a-select v-model:value="formData.status" placeholder="Chọn trạng thái">
                                <a-select-option :value="0">Nháp</a-select-option>
                                <a-select-option :value="1">Đang thực hiện</a-select-option>
                                <a-select-option :value="2">Chờ duyệt</a-select-option>
                                <a-select-option :value="3">Đã duyệt</a-select-option>
                                <a-select-option :value="4">Hoàn thành</a-select-option>
                                <a-select-option :value="5">Đã hủy</a-select-option>
                            </a-select>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="[16, 0]">
                    <a-col :span="24">
                        <a-checkbox v-model:checked="formData.is_awarded" style="margin-bottom: 12px;"
                                    @change="handleIsAwardedChange">
                            Đã trúng thầu
                        </a-checkbox>
                    </a-col>
                    <a-col :span="24" v-if="formData.is_awarded">
                        <a-form-item label="Gói thầu đã trúng" name="bidding_id">
                            <a-select
                                    v-model:value="formData.bidding_id"
                                    :options="awardedBiddings"
                                    placeholder="Chọn gói thầu đã trúng"
                                    allow-clear
                                    show-search
                                    :filter-option="(input, option) =>option.label.toLowerCase().includes(input.toLowerCase())"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Khách hàng liên quan">
                            <a-select
                                    v-model:value="formData.customer_id"
                                    :options="customerOptions"
                                    placeholder="Chọn khách hàng liên quan"
                                    allow-clear
                                    show-search
                                    :disabled="formData.is_awarded"
                                    :filter-option="(input, option) => option.label.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().includes(input.toLowerCase()) || option.label.toLowerCase().includes(input.toLowerCase())"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Người phụ trách" name="assigned_to">
                            <a-select
                                    v-model:value="formData.assigned_to"
                                    :options="userOptions"
                                    placeholder="Chọn người phụ trách"
                                    allow-clear
                                    show-search
                                    :filter-option="(input, option) => option.label.toLowerCase().includes(input.toLowerCase())"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Ngày bắt đầu" name="start_date">
                            <a-date-picker v-model:value="formData.start_date" style="width: 100%"/>
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Ngày kết thúc" name="end_date">
                            <a-date-picker v-model:value="formData.end_date" style="width: 100%"/>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" placeholder="Nhập mô tả hợp đồng"
                                        :rows="4"/>
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" @click="submitForm" html-type="submit" :loading="loadingCreate">
                        {{ selectedContract ? 'Cập nhật' : 'Thêm mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
    import {computed, onMounted, ref, watch} from 'vue'
    import {message} from 'ant-design-vue'
    import {DeleteOutlined, EditOutlined, EyeOutlined} from '@ant-design/icons-vue';
    import dayjs from 'dayjs';
    import {getBiddingAPI, getBiddingsAPI} from '../api/bidding'
    import {getCustomers} from '../api/customer' // đảm bảo bạn có API này
    import {
        cloneStepsFromTemplateAPI,
        createContractAPI,
        deleteContractAPI,
        getContractsAPI,
        updateContractAPI
    } from "../api/contract"; // ✅ đảm bảo đúng path
    import {canMarkContractAsCompleteAPI} from '@/api/contract'

    import {formatDate} from '@/utils/formUtils'
    import {useRouter} from 'vue-router'
    import {getUsers} from "@/api/user.js";
    import {debounce} from 'lodash'

    const router = useRouter()

    const formRef = ref(null);
    const selectedContract = ref(null)
    const tableData = ref([])
    const loading = ref(false)
    const loadingCreate = ref(false)
    const openDrawer = ref(false)
    const formData = ref({
        name: "",
        code: "",
        status: 0, // ✅ sửa từ "pending" → 0 (tương ứng "Nháp")
        is_awarded: false,
        start_date: null,
        end_date: null,
        description: "",
        bidding_id: null,
        assigned_to: null,
        customer_id: null,
    })

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
            await Promise.all(selectedRowKeys.value.map(id => deleteContractAPI(id)))
            message.success('Đã xoá các hợp đồng đã chọn')
            selectedRowKeys.value = []
            await getContracts()
        } catch (e) {
            message.error('Không thể xoá hợp đồng')
        }
    }

    const truncateText = (text, length = 30) => {
        if (!text) return '';
        return text.length > length ? text.slice(0, length) + '...' : text;
    }

    const steps = ref([]) // hoặc dữ liệu thực tế từ API
    const userOptions = ref([])


    const goToContractDetail = (id) => {
        router.push(`/contracts/${id}`)
    }

    const awardedBiddings = ref([])
    const customers = ref([])
    const filtersCustomers = ref({
        search: '',
        page: 1,
    })
    const customerOptions = computed(() => {
        if (customers.value.length === 0) {
            return []
        }
        return customers.value.map(customer => ({
            label: customer.name,
            value: customer.id
        }))
    })

    const columns = [
        {title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px'},
        {title: 'Tên hợp đồng', dataIndex: 'name', key: 'name'},
        {title: 'Mã hợp đồng', dataIndex: 'code', key: 'code'},
        {title: 'Trạng thái', dataIndex: 'status', key: 'status'},
        {title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date'},
        {title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date'},
        {title: 'Thời gian tạo', dataIndex: 'created_at', key: 'created_at'},
        {title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px'},
    ]

    const getStatusColor = (status) => {
        const colors = {
            0: 'gray',
            1: 'blue',
            2: 'orange',
            3: 'cyan',
            4: 'green',
            5: 'red'
        }

        return colors[status] || 'default'
    }

    const getStatusLabel = (status) => {
        const map = {
            0: 'Nháp',
            1: 'Đang thực hiện',
            2: 'Chờ duyệt',
            3: 'Đã duyệt',
            4: 'Hoàn thành',
            5: 'Đã hủy',
        }

        if (!(status in map)) {
            console.warn('⚠️ Status không hợp lệ:', status)
            return 'Không xác định'
        }

        return map[status]
    }


    const fetchAwardedBiddings = async () => {
        try {
            const res = await getBiddingsAPI({status: '3', per_page: 1000})

            awardedBiddings.value = res.data.data.map(bid => ({
                label: bid.title,
                value: String(bid.id)
            }))
        } catch (e) {
            console.error(e)
            message.error('Không thể tải gói thầu đã trúng')
        }
    }


    const fetchUsers = async () => {
        try {
            const res = await getUsers()
            // Nếu là mảng phẳng
            const rawUsers = Array.isArray(res.data) ? res.data : res.data?.data || []
            userOptions.value = rawUsers.map(u => ({
                label: u.name,
                value: String(u.id)
            }))
        } catch (e) {
            console.error('Không thể tải danh sách người dùng', e)
        }
    }


    const validateName = async (_rule, value) => {
        if (value === '') {
            return Promise.reject('Vui lòng nhập tên hợp đồng');
        } else if (value.length > 200) {
            return Promise.reject('Tên hợp đồng không vượt quá 200 ký tự');
        } else {
            return Promise.resolve();
        }
    };

    const validateCode = async (_rule, value) => {
        if (value === '') {
            return Promise.reject('Vui lòng nhập mã hợp đồng');
        } else if (value.length > 50) {
            return Promise.reject('Mã hợp đồng không vượt quá 50 ký tự');
        } else {
            return Promise.resolve();
        }
    };

    const validateDates = async (_rule, value) => {
        if (!formData.value.start_date || !formData.value.end_date) {
            return Promise.resolve();
        }
        if (dayjs(formData.value.end_date).isBefore(formData.value.start_date)) {
            return Promise.reject('Ngày kết thúc phải sau ngày bắt đầu');
        }
        return Promise.resolve();
    };

    const rules = computed(() => {
        return {
            name: [{required: true, validator: validateName, trigger: 'change'}],
            code: [{required: true, validator: validateCode, trigger: 'change'}],
            status: [{required: true, message: 'Vui lòng chọn trạng thái', trigger: 'change'}],
            start_date: [{required: true, message: 'Vui lòng chọn ngày bắt đầu', trigger: 'change'}],
            end_date: [
                {required: true, message: 'Vui lòng chọn ngày kết thúc', trigger: 'change'},
                {validator: validateDates, trigger: 'change'}
            ],
            description: [{required: true, message: 'Vui lòng nhập mô tả', trigger: 'change'}],
            bidding_id: [{required: true, message: 'Vui lòng chọn gói thầu đã trúng', trigger: 'change'}],
            customer_id: [{required: true, message: 'Không tìm thấy khách hàng', trigger: 'change'}],
        }
    })

    const handleIsAwardedChange = (checked) => {
        formData.value.bidding_id = null
    }

    const getContracts = async () => {
        loading.value = true
        try {
            const response = await getContractsAPI()
            tableData.value = response.data.map(item => ({
                id: item.id,
                name: item.name || item.title,
                code: item.code,
                status: item.status,
                start_date: item.start_date || null,
                end_date: item.end_date || null,
                created_at: formatDate(item.created_at),
                description: item.description,
                bidding_id: item.bidding_id || null,
                customer_id: item.customer_id || null,
                assigned_to: item.assigned_to || null // ✅ THÊM DÒNG NÀY
            }))
        } catch (e) {
            console.error(e)
            message.error('Không thể tải danh sách hợp đồng')
        } finally {
            loading.value = false
        }
    }

    const fetchCustomers = async () => {
        try {
            const params = {
                search: filtersCustomers.value.search,
                page: filtersCustomers.value.page
            }
            const res = await getCustomers(params)
            if (filtersCustomers.value.page === 1) {
                customers.value = res.data.data
            } else {
                customers.value = [...customers.value, ...res.data.data]
            }

            if (res.data.pager.current_page * res.data.pager.per_page < res.data.pager.total) {
                fetchCustomers()
            }
        } catch (err) {

        } finally {
        }
    }
    const submitForm = async () => {
        try {
            await formRef.value?.validate()

            const values = formRef.value?.getFieldsValue()

            // Nếu đang sửa hợp đồng và muốn chuyển sang "Hoàn thành"
            if (values.status === 4 && selectedContract.value?.id) {
                const res = await canMarkContractAsCompleteAPI(selectedContract.value.id)

                if (!res?.data?.allow) {
                    message.warning('Bạn cần hoàn thành tất cả các bước trước khi chuyển trạng thái hợp đồng sang "Hoàn thành".')
                    return
                }
            }

            if (selectedContract.value) {
                await updateContract()
            } else {
                await createContract()
            }
        } catch (error) {
            console.warn('Lỗi validate:', error)
        }
    }


    const isFinalStep = (step) => {
        if (!step) return false
        const maxStepNo = Math.max(...steps.value.map(s => Number(s.step_number)))
        return Number(step.step_number) === maxStepNo
    }

    const isStepAllowedToComplete = (step) => {
        return isFinalStep(step) && areAllStepsCompleted()
    }
    const areAllStepsCompleted = () => {
        if (!steps.value || !Array.isArray(steps.value)) return false
        return steps.value.every(step => Number(step.status) === 2)
    }
    // const isStepAllowedToComplete = (step) => {
    //     const index = steps.value.findIndex(s => s.id === step.id)
    //     if (index === -1) return false
    //     // ✅ Kiểm tra tất cả bước trước đã status = 2 (hoàn thành)
    //     return steps.value.slice(0, index).every(s => s.status === '2')
    // }

    const createContract = async () => {
        if (loadingCreate.value) return;
        loadingCreate.value = true;
        try {
            const payload = {
                ...formData.value,
                title: formData.value.name
            };

            const res = await createContractAPI(payload);
            const newContractId = res.data?.id;

            if (newContractId) {
                // ✅ Gọi API clone bước mẫu
                await cloneStepsFromTemplateAPI(newContractId);
            }

            message.success('Thêm mới hợp đồng thành công');
            await getContracts();
            onCloseDrawer();
        } catch (e) {
            console.error(e);
            message.error('Thêm mới hợp đồng không thành công');
        } finally {
            loadingCreate.value = false;
        }
    }


    const updateContract = async () => {
        if (loadingCreate.value) return;
        loadingCreate.value = true;

        try {
            await updateContractAPI(selectedContract.value.id, {
                ...formData.value,
                title: formData.value.name
            })
            message.success('Cập nhật hợp đồng thành công');
            await getContracts(); // Làm mới danh sách sau khi cập nhật
            onCloseDrawer();      // Đóng form
        } catch (e) {
            console.error(e);
            const msg = e?.response?.data?.messages?.error || 'Cập nhật hợp đồng không thành công';
            message.error(msg);
        } finally {
            loadingCreate.value = false;
        }
    }

    const deleteConfirm = async (contractId) => {
        try {
            await deleteContractAPI(contractId);
            message.success('Xóa hợp đồng thành công');
            await getContracts(); // Làm mới danh sách sau khi xóa
        } catch (e) {
            console.error(e);
            const msg = e?.response?.data?.messages?.error || 'Xóa hợp đồng không thành công';
            message.error(msg);
        }
    }

    const showPopupDetail = async (record) => {
        console.log("📌 RECORD TRUYỀN VÀO:", record)
        selectedContract.value = record

        openDrawer.value = true
        await fetchAwardedBiddings()
        await fetchUsers() // ✅ Bổ sung dòng này để đảm bảo userOptions có dữ liệu

        formData.value = {
            name: record.name,
            code: record.code,
            status: Number(record.status),
            start_date: record.start_date ? dayjs(record.start_date) : null,
            end_date: record.end_date ? dayjs(record.end_date) : null,
            description: record.description,
            bidding_id: record.bidding_id || null,
            assigned_to: record.assigned_to !== null && record.assigned_to !== undefined
                ? String(record.assigned_to)
                : null
        }

        // // ✅ CHÈN LOG SAU KHI GÁN
        // console.log("assigned_to (formData):", formData.value.assigned_to)
        // console.log("userOptions:", userOptions.value.map(x => typeof x.value + ':' + x.value))

    }


    const showPopupCreate = () => {
        openDrawer.value = true
        fetchAwardedBiddings()
    }

    const onCloseDrawer = () => {
        openDrawer.value = false;
        setDefaultData();
        selectedContract.value = null;
        resetFormValidate()
    }

    const setDefaultData = () => {
        formData.value = {
            name: "",
            code: "",
            status: "pending",
            start_date: null,
            end_date: null,
            description: "",
            bidding_id: null, // ✅ thêm dòng này
        }
    }

    const resetFormValidate = () => {
        formRef.value?.resetFields();
    };

    watch(() => formData.value.bidding_id, async (newVal) => {
        if (!newVal) {
            formData.value.customer_id = null
            return
        }

        try {
            const biddingRes = await getBiddingAPI(newVal)

            const customerId = biddingRes.data.customer_id

            if (awardedBiddings.value.map(x => x.value).includes(formData.value.bidding_id)) {
                formData.value.is_awarded = true
            } else {
                formData.value.is_awarded = false
            }
            formData.value.customer_id = customerId // ✅ Gán customer_id để lưu vào backend

        } catch (e) {
            console.error(e)
            formData.value.customer_id = null
        }
    })

    onMounted(() => {
        getContracts();
        fetchUsers()
        fetchCustomers()
    })

</script>

<style scoped>
    :deep(.ant-pagination) {
        margin-bottom: 0 !important;
    }

    .icon-action {
        font-size: 18px;
        margin-right: 24px;
        cursor: pointer;
    }

    &
    :last-child {
        margin-right: 0;
    }

    .icon-action {
        font-size: 18px;
        margin-right: 16px;
        cursor: pointer;
    }
</style> 