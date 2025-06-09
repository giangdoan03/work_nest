<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách người dùng</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm người dùng mới</a-button>
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
                        title="Bạn chắc chắn muốn xóa người dùng này?"
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
        <a-drawer title="Tạo người dùng mới" :width="700" :open="openDrawer" :body-style="{ paddingBottom: '80px' }"
            :footer-style="{ textAlign: 'right' }" @close="onCloseDrawer">
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="24">
                        <a-form-item label="Tên người dùng" name="name">
                            <a-input v-model:value="formData.name" placeholder="Nhập tên người dùng" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Email" name="email">
                            <a-input v-model:value="formData.email" placeholder="Nhập Email" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Số điện thoại" name="phone">
                            <a-input v-model:value="formData.phone" placeholder="Nhập số điện thoại" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="Mật khẩu" name="password">
                            <a-input-password v-model:value="formData.password" placeholder="Nhập Mật khẩu" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="Nhập lại mật khẩu" name="confirm_password">
                            <a-input-password v-model:value="formData.confirm_password" placeholder="Nhập lại mật khẩu" />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" @click="submitForm" html-type="submit" :loading="loadingCreate" >{{ selectedUser ? 'Cập nhật' : 'Thêm mới' }}</a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getUsers, createUser, updateUser, deleteUser } from '../api/user'
import { message } from 'ant-design-vue'
import { EditOutlined, DeleteOutlined } from '@ant-design/icons-vue';

const formRef = ref(null);
const selectedUser = ref(null)
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)
const formData = ref({
    name: "",
    email: "",
    phone: "",
    password: "",
    confirm_password: "",
})

const columns = [
    // { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
    { title: 'Tên người dùng', dataIndex: 'name', key: 'name' },
    { title: 'Email', dataIndex: 'email', key: 'email' },
    { title: 'Thời gian tạo', dataIndex: 'created_at', key: 'created_at' },
    { title: 'Cập nhật gần nhất', dataIndex: 'updated_at', key: 'updated_at' },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px' },
]

function validateEmailtype(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}
function isValidPhoneNumber(phone) {
  const regex = /^(0|\+84)(3[2-9]|5[6|8|9]|7[0|6-9]|8[1-5]|9[0-9])[0-9]{7}$/;
  return regex.test(phone);
}
const validateName = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập họ và tên');
    } else if(value.length > 200){
        return Promise.reject('Họ và tên không vượt quá 200 ký tự');
    } else {
        return Promise.resolve();
    }
};
const validateEmail = async (_rule, value) => {
    if (value === '') {
        return Promise.reject('Vui lòng nhập Email');
    } else if(value.length > 200){
        return Promise.reject('Email không vượt quá 200 ký tự');
    } else if(!validateEmailtype(value)){
        return Promise.reject('Vui lòng nhập đúng định dạng email');
    } else {
        return Promise.resolve();
    }
};
const validatePhone = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập số điện thoại');
    } else if(value.length > 20){
        return Promise.reject('Số điện thoại không vượt quá 20 ký tự');
    } else if(!isValidPhoneNumber(value)){
        return Promise.reject('Vui lòng nhập đúng số điện thoại');
    } else {
        return Promise.resolve();
    }
};
const validatePass = async (_rule, value) => {
  if (value === '') {
    return Promise.reject('Vui lòng nhập lại');
  } else {
    return Promise.resolve();
  }
};
const validateConfirmPassword = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập lại mật khẩu mới');
    } else if (value !== formData.value.password) {
        return Promise.reject("Mật khẩu không khớp");
    } else {
        return Promise.resolve();
    }
};
const rules = computed(() => {
    return {
        name: [{ required: true, validator: validateName, trigger: 'change' }],
        email: [{ required: true, validator: validateEmail, trigger: 'change' }],
        phone: [{ required: true, validator: validatePhone, trigger: 'change' }],
        password: [{ required: true, validator: validatePass, trigger: 'change' }],
        confirm_password: [{ required: true, validator: validateConfirmPassword,  trigger: 'change' }],
    }
})

const getUser = async () => {
    loading.value = true
    try {
        const response = await getUsers();
        tableData.value = response.data;
    } catch (e) {
        message.error('Không thể tải người dùng')
    } finally {
        loading.value = false
    }
}
const submitForm = async() => {
    try {
        await formRef.value?.validate()
        if(selectedUser.value){
            updateDrawerUser();
        }else{
            createDrawerUser();
        }
    } catch (error) {
        
    }
}
const createDrawerUser = async () => {
    if(loadingCreate.value){
        return;
    }
    loadingCreate.value = true;
    if(!formData.value.name || !formData.value.email || !formData.value.phone || !formData.value.password|| !formData.value.confirm_password){
        message.error('Vui lòng nhập đủ thông tin');
        return;
    }
    try {
        await createUser(formData.value);
        getUser();
        onCloseDrawer();
    } catch (e) {
        message.error('Thêm mới người dùng không thành công')
    } finally {
        loadingCreate.value = false
    }
}
const updateDrawerUser = async () => {
    await formRef.value?.validate()
    if(loadingCreate.value){
        return;
    }
    loadingCreate.value = true;
    if(!formData.value.name || !formData.value.email || !formData.value.phone || !formData.value.password|| !formData.value.confirm_password){
        message.error('Vui lòng nhập đủ thông tin người dùng');
        return;
    }
    try {
        await updateUser(selectedUser.value.id, formData.value);
        getUser();
        onCloseDrawer()
    } catch (e) {
        message.error('Cập nhật người dùng không thành công')
    } finally {
        loadingCreate.value = false
    }
}
const deleteConfirm = async (userId) => {
    try {
        await deleteUser(userId);
        getUser();
    } catch (e) {
        message.error('Xóa người dùng không thành công')
    } finally {
    }
}
const showPopupDetail = async (record) => {    
    selectedUser.value = record;
    formData.value.name = record.name;
    formData.value.email = record.email;
    formData.value.phone = record.phone;
    formData.value.password = record.password;
    formData.value.confirm_password = record.confirm_password;
    openDrawer.value = true;
}
const showPopupCreate = () => {
    openDrawer.value = true;
}
const onCloseDrawer = () => {
    openDrawer.value = false;
    setDefaultData();
    selectedUser.value = null;
    resetFormValidate()
}
const setDefaultData = () =>{
    formData.value = {
        name: "",
        email: "",
        phone: "",
        password: "",
        confirm_password: "",
    }
}
const resetFormValidate = () => {
    formRef.value.resetFields();
};

onMounted(getUser)
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
