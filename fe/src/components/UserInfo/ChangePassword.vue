<template>
    <div class="change-password">
        <a-typography-title :level="4" style="margin-bottom: 24px;">Thay đổi mật khẩu</a-typography-title>
        <a-form ref="formRef" :model="form" :rules="rules" layout="vertical" @finish="handleSubmit">
            <a-form-item label="Mật khẩu mới" name="new_password" type="password" autocomplete="off">
                <a-input v-model:value="form.new_password" placeholder="Nhập mật khẩu mới" />
            </a-form-item>
            <a-form-item label="Nhập lại mật khẩu mới" name="new_password_confirmation" type="password" autocomplete="off">
                <a-input v-model:value="form.new_password_confirmation" placeholder="Nhập lại mật khẩu mới" />
            </a-form-item>
            <a-form-item>
                <a-button type="primary" html-type="submit">Lưu</a-button>
            </a-form-item>
        </a-form>
    </div>
</template>
<script setup>
import { ref } from 'vue';
import { updateUser } from '@/api/user.js'
import { message } from 'ant-design-vue';

const props = defineProps({
    dataUser: {
        type: Object,
        default: () => ({})
    }
})
const formRef = ref();
const loading = ref(false);

const form = ref({
    new_password: '',
    new_password_confirmation: '',
});


const validatePass = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập mật khẩu mới');
    } else if(value.length > 20){
        return Promise.reject('Mật khẩu không vượt quá 20 ký tự');
    } else {
        return Promise.resolve();
    }
};
const validatePass2 = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập lại mật khẩu mới');
    } else if (value !== form.value.new_password) {
        return Promise.reject("Mật khẩu không khớp");
    } else {
        return Promise.resolve();
    }
};
const rules = {
    new_password: [{ required: true, validator: validatePass,  trigger: 'change' }],
    new_password_confirmation: [{ required: true, validator: validatePass2, trigger: 'change' }],
}


const handleSubmit = async () => {
    if(loading.value){
        return;
    }
    loading.value = true;
    let params = {
        password: form.value.new_password,
        name: props.dataUser.name,
        phone: props.dataUser.phone,
    }
    await updateUser(props.dataUser.id, params).then(res => {
        if(res.data.status == "success"){
            message.success('Cập nhật mật khẩu thành công');
            form.value = {
                new_password: '',
                new_password_confirmation: '',
            }
        }else{
            message.destroy();
            message.error('Cập nhật mật khẩu thất bại');
        }
    }).catch(() => {
        message.destroy();
        message.error('Cập nhật mật khẩu thất bại');
    }).finally(() => {
        loading.value = false;
    })
    
}


</script>
<style scoped>
.change-password {
    width: 100%;
    height: 100%;
}
</style>