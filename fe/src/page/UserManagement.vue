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
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.dataIndex == 'stt'">
                    {{ index+1 }}
                </template>
                <template v-if="column.dataIndex == 'name'">
                    <a-typography-text strong style="cursor: pointer;" @click="showPopupDetail(record)">{{ text }}</a-typography-text>
                </template>
                <template v-if="column.dataIndex == 'department'">
                    {{ getNameDepartments(record.department_id) }}
                </template>
                <template v-else-if="column.dataIndex == 'action'">
                    <a-dropdown placement="left">
                        <a-button>
                            <template #icon>
                                <MoreOutlined />
                            </template>
                        </a-button>
                        <template #overlay>
                        <a-menu>
                            <a-menu-item @click="showPopupDetail(record)">
                                <EditOutlined class="icon-action" style="color: blue;" />
                                Chỉnh sửa
                            </a-menu-item>
                            <a-menu-item>
                                <a-popconfirm
                                    title="Bạn chắc chắn muốn xóa người dùng này?"
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
                    <a-col :span="24">
                        <a-form-item label="Phòng ban" name="department">
                            <a-select v-model:value="formData.department_id" :options="optionsDepartment" placeholder="Chọn phòng ban" />
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
import { getDepartments } from '@/api/department'
import { message } from 'ant-design-vue'
import { EditOutlined, DeleteOutlined, MoreOutlined } from '@ant-design/icons-vue';

const formRef = ref(null);
const selectedUser = ref(null)
const tableData = ref([])
const loading = ref(false)
const loadingCreate = ref(false)
const openDrawer = ref(false)
const departments = ref([])
const formData = ref({
    name: "",
    email: "",
    phone: "",
    password: "",
    department_id: null,
    confirm_password: "",
})

const columns = [
    { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
    { title: 'Tên người dùng', dataIndex: 'name', key: 'name' },
    { title: 'Email', dataIndex: 'email', key: 'email' },
    { title: 'Số điện thoại', dataIndex: 'phone', key: 'phone' },
    { title: 'Phòng ban', dataIndex: 'department', key: 'department' },
    { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px', align:'center' },
]

////validate các trường

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
const validateDepartment = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng chọn phòng ban');
    } else {
        return Promise.resolve();
    }
};
const rules = computed(() => {
    return {
        name: [{ required: true, validator: validateName, trigger: 'change' }],
        email: [{ required: true, validator: validateEmail, trigger: 'change' }],
        phone: [{ required: true, validator: validatePhone, trigger: 'change' }],
        department: [{ required: true, validator: validateDepartment, trigger: 'change' }],
        password: [{ required: true, validator: validatePass, trigger: 'change' }],
        confirm_password: [{ required: true, validator: validateConfirmPassword,  trigger: 'change' }],
    }
})

const optionsDepartment = computed(() =>{
    if (!departments.value) {
        return []
    }else {
        return departments.value.map(ele => {
            return {
                value: ele.id,
                label: ele.name,
            }
        })
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
        if(e.response.data.error == 400){
            message.error('Email đã tồn tại, vui lòng nhập email khác!')
            return
        }
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
    formData.value.department_id = record.department_id;
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
        department_id: null,
        password: "",
        confirm_password: "",
    }
}

const resetFormValidate = () => {
    formRef.value.resetFields();
};
// lấy danh sách phòng ban
const getListDepartments = async () => {
    await getDepartments().then(res => {
        if (res.data) {
            departments.value = res.data;
        }
    });
}

const getNameDepartments = (value) => {
    const department = departments.value.find(item => item.id === value)
    return department ? department.name : ""
}

onMounted(() => {
    getUser();
    getListDepartments();
})
</script>
<style scoped>
:deep(.ant-pagination){
    margin-bottom: 0 !important;
}
.icon-action {
    font-size: 18px;
    margin-right: 8px;
    cursor: pointer;
}

&:last-child {
    margin-right: 0;
}
</style>
