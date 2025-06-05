<template>
    <div class="change-password">
        <a-typography-title :level="4" style="margin-bottom: 24px;">Thay đổi mật khẩu</a-typography-title>
        <a-form ref="formRef" :model="form" :rules="rules" layout="vertical" @finish="handleSubmit">
            <a-form-item label="Mật khẩu cũ" name="old_password" type="password" autocomplete="off">
                <a-input v-model:value="form.old_password" placeholder="Nhập mật khẩu cũ" />
            </a-form-item>
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

const formRef = ref();

const form = ref({
    old_password: '',
    new_password: '',
    new_password_confirmation: '',
});


const validatePass = async (_rule, value) => {    
    if (value === '') {
        return Promise.reject('Vui lòng nhập mật khẩu mới');
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
    old_password: [{ required: true, message: 'Mật khẩu cũ là bắt buộc', trigger: 'change' }],
    new_password: [{ required: true, validator: validatePass,  trigger: 'change' }],
    new_password_confirmation: [{ required: true, validator: validatePass2, trigger: 'change' }],
}

const resetFormValidate = () => {
    formRef.value.resetFields();
};

const handleSubmit = () => {
    console.log(form.value);
}


</script>
<style scoped>
.change-password {
    width: 100%;
    height: 100%;
}
</style>