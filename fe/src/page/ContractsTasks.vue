<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách hợp đồng</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm hợp đồng mới</a-button>
        </a-flex>

        <a-table :columns="columns" :data-source="tableData" :loading="loading"
            style="margin-top: 12px;" row-key="id" :scroll="{y: 'calc( 100vh - 330px )' }">
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex == 'stt'">
                    {{ index+1 }}
                </template>
                <template v-else-if="column.dataIndex == 'status'">
                    <a-tag :color="getStatusColor(record.status)">
                        {{ record.status }}
                    </a-tag>
                </template>
                <template v-else-if="column.dataIndex == 'action'">
                    <EditOutlined class="icon-action" style="color: blue;" @click="showPopupDetail(record)"/>
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

        <a-drawer title="Tạo hợp đồng mới" :width="700" :open="openDrawer" :body-style="{ paddingBottom: '80px' }"
            :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Tên hợp đồng" name="name">
                            <a-input v-model:value="formData.name" placeholder="Nhập tên hợp đồng" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Mã hợp đồng" name="code">
                            <a-input v-model:value="formData.code" placeholder="Nhập mã hợp đồng" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Trạng thái" name="status">
                            <a-select v-model:value="formData.status" placeholder="Chọn trạng thái">
                                <a-select-option value="pending">Chờ xử lý</a-select-option>
                                <a-select-option value="in_progress">Đang thực hiện</a-select-option>
                                <a-select-option value="completed">Hoàn thành</a-select-option>
                                <a-select-option value="cancelled">Đã hủy</a-select-option>
                            </a-select>
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Gói thầu đã trúng" name="bidding_id">
                            <a-select
                                    v-model:value="formData.bidding_id"
                                    :options="awardedBiddings"
                                    placeholder="Chọn gói thầu đã trúng"
                                    allow-clear
                                    show-search
                                    :filter-option="(input, option) =>
          option.label.toLowerCase().includes(input.toLowerCase())"
                            />
                        </a-form-item>
                    </a-col>
                </a-row>
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
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" placeholder="Nhập mô tả hợp đồng" :rows="4" />
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
import { ref, onMounted, computed } from 'vue'
import { message } from 'ant-design-vue'
import { EditOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import dayjs from 'dayjs';
import { getBiddingsAPI } from '../api/bidding'
import { getContractsAPI ,createContractAPI} from "../api/contract"; // ✅ đảm bảo đúng path
import { formatDate } from '@/utils' // đường dẫn tuỳ theo vị trí thực tế

const formRef = ref(null);
const selectedContract = ref(null)
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)
const formData = ref({
    name: "",
    code: "",
    status: "pending",
    start_date: null,
    end_date: null,
    description: "",
    bidding_id: null,
})

const awardedBiddings = ref([])

const columns = [
    { title: 'Tên hợp đồng', dataIndex: 'name', key: 'name' },
    { title: 'Mã hợp đồng', dataIndex: 'code', key: 'code' },
    { title: 'Trạng thái', dataIndex: 'status', key: 'status' },
    { title: 'Ngày bắt đầu', dataIndex: 'start_date', key: 'start_date' },
    { title: 'Ngày kết thúc', dataIndex: 'end_date', key: 'end_date' },
    { title: 'Thời gian tạo', dataIndex: 'created_at', key: 'created_at' },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px' },
]

const getStatusColor = (status) => {
    const colors = {
        pending: 'orange',
        in_progress: 'blue',
        completed: 'green',
        cancelled: 'red'
    }
    return colors[status] || 'default'
}

const fetchAwardedBiddings = async () => {
    try {
        const res = await getBiddingsAPI()
        awardedBiddings.value = res.data.data
            .filter(bid => bid.status === 'awarded')
            .map(bid => ({
                label: bid.title,
                value: parseInt(bid.id)
            }))
    } catch (e) {
        console.error(e)
        message.error('Không thể tải gói thầu đã trúng')
    }
}

const validateName = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập tên hợp đồng');
    } else if(value.length > 200){
        return Promise.reject('Tên hợp đồng không vượt quá 200 ký tự');
    } else {
        return Promise.resolve();
    }
};

const validateCode = async (_rule, value) => {
    if (value === '') {
        return Promise.reject('Vui lòng nhập mã hợp đồng');
    } else if(value.length > 50){
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
        name: [{ required: true, validator: validateName, trigger: 'change' }],
        code: [{ required: true, validator: validateCode, trigger: 'change' }],
        status: [{ required: true, message: 'Vui lòng chọn trạng thái', trigger: 'change' }],
        start_date: [{ required: true, message: 'Vui lòng chọn ngày bắt đầu', trigger: 'change' }],
        end_date: [
            { required: true, message: 'Vui lòng chọn ngày kết thúc', trigger: 'change' },
            { validator: validateDates, trigger: 'change' }
        ],
        description: [{ required: true, message: 'Vui lòng nhập mô tả', trigger: 'change' }],
        bidding_id: [{ required: true, message: 'Vui lòng chọn gói thầu đã trúng', trigger: 'change' }],
    }
})

// TODO: Implement these API functions in your api folder
const getContracts = async () => {
    loading.value = true
    try {
        const response = await getContractsAPI()
        tableData.value = response.data.map(item => ({
            id: item.id,
            name: item.name || item.title, // fallback nếu API dùng 'title'
            code: item.code,
            status: item.status,
            start_date: item.start_date,
            end_date: item.end_date,
            created_at: item.created_at,
            description: item.description
        }))
    } catch (e) {
        console.error(e)
        message.error('Không thể tải danh sách hợp đồng')
    } finally {
        loading.value = false
    }
}
const submitForm = async() => {
    try {
        await formRef.value?.validate()
        if(selectedContract.value){
            await updateContract();
        } else {
            await createContract();
        }
    } catch (error) {
        // Validation failed
    }
}

const createContract = async () => {
    if (loadingCreate.value) return;
    loadingCreate.value = true;
    try {
        const payload = {
            ...formData.value,
            title: formData.value.name // 👈 Bổ sung dòng này để thỏa mãn yêu cầu API
        }
        await createContractAPI(payload);
        message.success('Thêm mới hợp đồng thành công');
        await getContracts();
        onCloseDrawer();
    } catch (e) {
        console.error(e);
        message.error('Thêm mới hợp đồng không thành công')
    } finally {
        loadingCreate.value = false
    }
}


const updateContract = async () => {
    if(loadingCreate.value) return;
    loadingCreate.value = true;
    try {
        // await updateContractAPI(selectedContract.value.id, formData.value);
        message.success('Cập nhật hợp đồng thành công');
        await getContracts();
        onCloseDrawer()
    } catch (e) {
        message.error('Cập nhật hợp đồng không thành công')
    } finally {
        loadingCreate.value = false
    }
}

const deleteConfirm = async (contractId) => {
    try {
        // await deleteContractAPI(contractId);
        message.success('Xóa hợp đồng thành công');
        await getContracts();
    } catch (e) {
        message.error('Xóa hợp đồng không thành công')
    }
}

const showPopupDetail = (record) => {
    selectedContract.value = record
    formData.value = {
        name: record.name,
        code: record.code,
        status: record.status,
        start_date: dayjs(record.start_date),
        end_date: dayjs(record.end_date),
        description: record.description,
        bidding_id: record.bidding_id || null // nếu có
    }
    openDrawer.value = true
    fetchAwardedBiddings()
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
    }
}

const resetFormValidate = () => {
    formRef.value?.resetFields();
};

onMounted(getContracts)
</script>

<style scoped>
:deep(.ant-pagination){
    margin-bottom: 0 !important;
}
.icon-action {
    font-size: 18px;
    margin-right: 24px;
    cursor: pointer;
}

&:last-child {
    margin-right: 0;
}
</style> 