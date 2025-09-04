<template>
    <a-modal
        :open="open"
        title="Thay đổi mật khẩu"
        :width="420"
        :confirm-loading="loading"
        destroyOnClose
        @cancel="emit('update:open', false)"
        @ok="submit"
    >
        <a-form ref="formRef" :model="form" :rules="rules" layout="vertical">
            <a-form-item label="Mật khẩu mới" name="new_password">
                <a-input-password v-model:value="form.new_password" placeholder="Nhập mật khẩu mới" />
            </a-form-item>

            <a-form-item label="Nhập lại mật khẩu mới" name="new_password_confirmation">
                <a-input-password v-model:value="form.new_password_confirmation" placeholder="Nhập lại mật khẩu mới" />
            </a-form-item>
        </a-form>
    </a-modal>
</template>

<script setup>
    import { ref } from 'vue'
    import { message } from 'ant-design-vue'
    import { updateUser } from '@/api/user'

    const props = defineProps({
        open: { type: Boolean, default: false },
        userId: [String, Number],
        userName: String,   // optional nếu backend cần
        userPhone: String,  // optional nếu backend cần
    })
    const emit = defineEmits(['update:open', 'changed'])

    const formRef = ref()
    const loading = ref(false)
    const form = ref({ new_password: '', new_password_confirmation: '' })

    const rules = {
        new_password: [
            { required: true, message: 'Vui lòng nhập mật khẩu mới' },
            { validator: (_r, v) => (v && v.length <= 20 ? Promise.resolve() : Promise.reject('Mật khẩu không vượt quá 20 ký tự')) }
        ],
        new_password_confirmation: [
            { required: true, message: 'Vui lòng nhập lại mật khẩu mới' },
            { validator: (_r, v) => (v === form.value.new_password ? Promise.resolve() : Promise.reject('Mật khẩu không khớp')) }
        ]
    }

    const submit = async () => {
        await formRef.value?.validate()
        loading.value = true
        try {
            const params = { password: form.value.new_password }
            await updateUser(props.userId, params)
            message.success('Đổi mật khẩu thành công')
            emit('changed')
            emit('update:open', false)
            form.value = { new_password: '', new_password_confirmation: '' }
        } catch (e) {
            message.error('Đổi mật khẩu thất bại')
        } finally {
            loading.value = false
        }
    }
</script>
