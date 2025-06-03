<template>
    <div class="change-password">
        <a-typography-title :level="4" style="margin-bottom: 24px;">Thay đổi mật khẩu</a-typography-title>
        <a-form :model="form" layout="vertical" @finish="handleSubmit">
            <a-form-item label="Mật khẩu cũ" name="old_password" required>
                <a-input v-model:value="form.old_password" placeholder="Nhập mật khẩu cũ" />
            </a-form-item>
            <a-form-item label="Mật khẩu mới" name="new_password" required>
                <a-input v-model:value="form.new_password" placeholder="Nhập mật khẩu mới" />
            </a-form-item>
            <a-form-item label="Nhập lại mật khẩu mới" name="new_password_confirmation" required>
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

const form = ref({
    old_password: '',
    new_password: '',
    new_password_confirmation: '',
});

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