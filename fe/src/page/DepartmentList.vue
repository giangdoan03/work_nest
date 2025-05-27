<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách phòng ban</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm phòng ban mới</a-button>
        </a-flex>

        <a-table :columns="columns" :data-source="tableData" :loading="loading"
            style="margin-top: 12px;" row-key="module" :scroll="{ y: 'calc( 100vh - 330px )' }">
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.dataIndex == 'stt'">
                    {{ index+1 }}
                </template>
                <template v-else-if="column.dataIndex == 'action'">
                    <EditOutlined class="icon-action" style="color: blue;" @click="showPopupDetail(record)"/>
                    <a-popconfirm
                        title="Bạn chắc chắn muốn xóa phòng ban này?"
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
        <a-drawer title="Tạo phòng ban mới" :width="450" :open="openDrawer" :body-style="{ paddingBottom: '80px' }"
            :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Tên phòng ban" name="name">
                            <a-input v-model:value="formData.name" placeholder="Nhập tên phòng ban" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Mô tả" name="description">
                            <a-textarea v-model:value="formData.description" :rows="6"
                                placeholder="Nhập mô tả " />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button v-if="selectedDepartment" type="primary" @click="updateDrawerCreate" :loading="loadingCreate" >Cập nhật</a-button>
                    <a-button v-else type="primary" @click="createDrawerCreate" :loading="loadingCreate" >Thêm mới</a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getDepartments, getDepartmentDetail, createDepartment, updateDepartment, deleteDepartment } from '../api/department'
import { message } from 'ant-design-vue'
import { EditOutlined, DeleteOutlined } from '@ant-design/icons-vue';


const selectedDepartment = ref(null)
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)
const formData = ref({
    name: "",
    description: "",
})

const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
    { title: 'Tên phòng ban', dataIndex: 'name', key: 'name' },
    { title: 'Mô tả', dataIndex: 'description', key: 'description' },
    { title: 'Thời gian tạo', dataIndex: 'created_at', key: 'created_at' },
    { title: 'Cập nhật gần nhất', dataIndex: 'updated_at', key: 'updated_at' },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px' },
]
const rules = {
    name: [
        {
        required: true,
        message: 'Vui lòng nhập tên phòng ban',
        },
    ],
    description: [
        {
        required: true,
        message: 'Vui lòng nhập mô tả phòng ban',
        },
    ]
}

const getDepartment = async () => {
    loading.value = true
    try {
        const response = await getDepartments();
        tableData.value = response.data;
        showPopupCreate.value 
    } catch (e) {
        message.error('Không thể tải phòng ban')
    } finally {
        loading.value = false
    }
}

const createDrawerCreate = async () => {
    if(loadingCreate.value){
        return;
    }
    loadingCreate.value = true;
    if(!formData.value.name || !formData.value.description){
        message.error('Vui lòng nhập đủ thông tin');
        return;
    }
    try {
        await createDepartment(formData.value);
        getDepartment();
        onCloseDrawer
    } catch (e) {
        message.error('Thêm mới phòng ban không thành công')
    } finally {
        loadingCreate.value = false
    }
}
const updateDrawerCreate = async () => {
    if(loadingCreate.value){
        return;
    }
    loadingCreate.value = true;
    if(!formData.value.name || !formData.value.description){
        message.error('Vui lòng nhập đủ thông tin phòng ban');
        return;
    }
    try {
        await updateDepartment(selectedDepartment.value.id, formData.value);
        getDepartment();
        onCloseDrawer()
    } catch (e) {
        message.error('Cập nhật phòng ban không thành công')
    } finally {
        loadingCreate.value = false
    }
}
const deleteConfirm = async (departmentId) => {
    try {
        await deleteDepartment(departmentId);
        getDepartment();
    } catch (e) {
        message.error('Xóa phòng ban không thành công')
    } finally {
    }
}
const showPopupDetail = async (record) => {    
    selectedDepartment.value = record;
    formData.value.name = record.name;
    formData.value.description = record.description;
    openDrawer.value = true;
}
const showPopupCreate = () => {
    openDrawer.value = true;
}
const onCloseDrawer = () => {
    openDrawer.value = false;
    formData.value = {
        name: "",
        description: "",
    }
    selectedDepartment.value = null
}

onMounted(getDepartment)
</script>
<style scoped>
.icon-action {
    font-size: 18px;
    margin-right: 24px;
    cursor: pointer;
}

&:last-child {
    margin-right: 0;
}
</style>
