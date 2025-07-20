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
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.dataIndex == 'stt'">
                    {{ index+1 }}
                </template>
                <template v-if="column.dataIndex == 'name'">
                    <a-typography-text strong style="cursor: pointer;" @click="showPopupDetail(record)">{{ text }}</a-typography-text>
                </template>
                <template v-else-if="column.dataIndex == 'action'">
                    <a-dropdown placement="left" trigger="click"  :getPopupContainer="triggerNode => triggerNode.parentNode">
                        <a-button>
                            <template #icon>
                                <MoreOutlined />
                            </template>
                        </a-button>
                        <template #overlay>
                        <a-menu>
                            <a-menu-item @click="showPopupDetail(record)">
                                <div>
                                    <EditOutlined class="icon-action" style="color: blue;" />
                                    Chỉnh sửa
                                </div>
                            </a-menu-item>
                            <a-menu-item>
                                <a-popconfirm
                                    title="Bạn chắc chắn muốn xóa phòng ban này?"
                                    ok-text="Xóa"
                                    cancel-text="Hủy"
                                    @confirm="deleteConfirm(record.id)"
                                    placement="topRight"
                                >
                                    <div>
                                        <DeleteOutlined class="icon-action" style="color: red;"/>
                                        Xóa
                                    </div>
                                </a-popconfirm>
                            </a-menu-item>
                        </a-menu>
                        </template>
                    </a-dropdown>
                </template>
            </template>
        </a-table>
        <a-drawer title="Tạo phòng ban mới" :width="550" :open="openDrawer" :body-style="{ paddingBottom: '80px' }"
            :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical" @finish="handleCreateDepartment">
                <a-form-item label="Tên phòng ban" name="name">
                    <a-input v-model:value="formData.name" placeholder="Nhập tên phòng ban" />
                </a-form-item>
                <a-form-item label="Mô tả" name="description">
                    <a-textarea v-model:value="formData.description" :rows="6"
                        placeholder="Nhập mô tả " />
                </a-form-item>
            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button v-if="selectedDepartment" type="primary" @click="updateDrawerCreate" :loading="loadingCreate" >Cập nhật</a-button>
                    <a-button v-else type="primary" @click="submitDepartment" :loading="loadingCreate" >Thêm mới</a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getDepartments, getDepartmentDetail, createDepartment, updateDepartment, deleteDepartment } from '../api/department'
import { message } from 'ant-design-vue'
import { EditOutlined, DeleteOutlined, MoreOutlined } from '@ant-design/icons-vue';


const selectedDepartment = ref(null)
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)
const formData = ref({
    name: "",
    description: "",
})
const btnSubmit = ref()
const formRef = ref(null)

const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
    { title: 'Tên phòng ban', dataIndex: 'name', key: 'name' },
    { title: 'Mô tả', dataIndex: 'description', key: 'description' },
    { title: 'Thời gian tạo', dataIndex: 'created_at', key: 'created_at' },
    { title: 'Cập nhật gần nhất', dataIndex: 'updated_at', key: 'updated_at' },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px', align:'center' },
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
const submitDepartment = async () => {
    try {
        await formRef.value?.validate()
        if (selectedDepartment.value) {
            await updateDrawerCreate()
        } else {
            await handleCreateDepartment()
        }
    } catch (error) {
        // Validation failed
    }
}
const handleCreateDepartment = async () => {
    if(loadingCreate.value){
        return;
    }
    loadingCreate.value = true;
    try {
        await createDepartment(formData.value);
        message.success('Thêm mới phòng ban thành công');
        getDepartment();
        onCloseDrawer();
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
    try {
        await updateDepartment(selectedDepartment.value.id, formData.value);
        message.success('Cập nhật phòng ban thành công');
        getDepartment();
        onCloseDrawer();
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
    resetFormValidate()
}
const resetFormValidate = () => {
    formRef.value.resetFields();
};

onMounted(getDepartment)
</script>
<style scoped>
.icon-action {
    font-size: 18px;
    margin-right: 8px;
    cursor: pointer;
}

&:last-child {
    margin-right: 0;
}
</style>
