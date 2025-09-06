<template>
    <div class="cp-wrapper">
        <a-card class="cp-card" :bodyStyle="{padding:'20px 20px 8px'}">
            <div class="cp-header">
                <div>
                    <div class="cp-title">Thay đổi mật khẩu</div>
                    <div class="cp-sub">Đặt mật khẩu mạnh để bảo vệ tài khoản tốt hơn.</div>
                </div>
                <a-tag color="blue">Bảo mật</a-tag>
            </div>

            <a-form
                ref="formRef"
                :model="form"
                :rules="rules"
                layout="vertical"
                size="middle"
                autocomplete="off"
                @finish="handleSubmit"
            >
                <!-- Mật khẩu mới -->
                <a-form-item label="Mật khẩu mới" name="new_password" has-feedback>
                    <a-input-password
                        v-model:value="form.new_password"
                        placeholder="Nhập mật khẩu mới"
                        :maxlength="64"
                        autocomplete="new-password"
                        @pressEnter="submit"
                        @input="noop"
                    />
                    <div class="cp-meter">
                        <a-progress
                            :percent="strength.percent"
                            :show-info="false"
                            :stroke-color="strength.color"
                        />
                        <span :style="{ color: strength.color }" class="cp-meter-label">{{ strength.label }}</span>
                    </div>
                </a-form-item>

                <!-- Nhập lại -->
                <a-form-item
                    label="Nhập lại mật khẩu mới"
                    name="new_password_confirmation"
                    has-feedback
                    :dependencies="['new_password']"
                >
                    <a-input-password
                        v-model:value="form.new_password_confirmation"
                        placeholder="Nhập lại mật khẩu mới"
                        :maxlength="64"
                        autocomplete="new-password"
                        @pressEnter="submit"
                    />
                </a-form-item>

                <!-- Checklist điều kiện -->
                <div class="cp-checklist">
                    <div class="cp-check" :class="{ ok: conds.len }">
                        <span class="dot"></span>Tối thiểu 8 ký tự
                    </div>
                    <div class="cp-check" :class="{ ok: conds.upper }">
                        <span class="dot"></span>Chứa chữ in hoa (A–Z)
                    </div>
                    <div class="cp-check" :class="{ ok: conds.lower }">
                        <span class="dot"></span>Chứa chữ thường (a–z)
                    </div>
                    <div class="cp-check" :class="{ ok: conds.num }">
                        <span class="dot"></span>Chứa số (0–9)
                    </div>
                    <div class="cp-check" :class="{ ok: conds.sym }">
                        <span class="dot"></span>Ký tự đặc biệt (!@#$…)
                    </div>
                    <div class="cp-check" :class="{ ok: conds.space }">
                        <span class="dot"></span>Không có khoảng trắng
                    </div>
                </div>

                <a-divider style="margin: 12px 0" />

                <div class="cp-actions">
                    <a-space>
                        <a-button @click="reset" :disabled="loading">Xoá nhập</a-button>
                        <a-button type="primary" html-type="submit" :loading="loading" :disabled="loading">Lưu</a-button>
                    </a-space>
                </div>
            </a-form>
        </a-card>

        <!-- Modal xem “mẹo” (tuỳ chọn) -->
        <!-- <a-modal :open="tipsOpen" ...> </a-modal> -->
    </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { message } from 'ant-design-vue'
import { updateUser } from '@/api/user.js'

const props = defineProps({
    dataUser: { type: Object, default: () => ({}) }
})

const formRef = ref()
const loading = ref(false)

const form = ref({
    new_password: '',
    new_password_confirmation: '',
})

/* ===== Strength meter ===== */
const strength = computed(() => {
    const v = form.value.new_password || ''
    if (!v) return { percent: 0, label: 'Chưa nhập', color: '#bfbfbf' }
    let score = 0
    if (v.length >= 8) score++
    if (/[A-Z]/.test(v)) score++
    if (/[a-z]/.test(v)) score++
    if (/\d/.test(v)) score++
    if (/[^A-Za-z0-9]/.test(v)) score++
    const percent = Math.min(100, score * 20)
    const label = percent < 40 ? 'Yếu' : percent < 80 ? 'Trung bình' : 'Mạnh'
    const color  = percent < 40 ? '#ff4d4f' : percent < 80 ? '#1677ff' : '#52c41a'
    return { percent, label, color }
})

/* Checklist điều kiện hiển thị */
const conds = computed(() => {
    const v = form.value.new_password || ''
    return {
        len: v.length >= 8,
        upper: /[A-Z]/.test(v),
        lower: /[a-z]/.test(v),
        num: /\d/.test(v),
        sym: /[^A-Za-z0-9]/.test(v),
        space: !/\s/.test(v),
    }
})

/* ===== Validators ===== */
const validatePass = async (_r, v) => {
    if (!v) return Promise.reject('Vui lòng nhập mật khẩu mới')
    if (/\s/.test(v)) return Promise.reject('Mật khẩu không được chứa khoảng trắng')
    if (v.length < 8) return Promise.reject('Mật khẩu tối thiểu 8 ký tự')
    if (v.length > 64) return Promise.reject('Mật khẩu tối đa 64 ký tự')
    return Promise.resolve()
}
const validatePass2 = async (_r, v) => {
    if (!v) return Promise.reject('Vui lòng nhập lại mật khẩu mới')
    if (v !== form.value.new_password) return Promise.reject('Mật khẩu không khớp')
    return Promise.resolve()
}

const rules = {
    new_password: [{ required: true, validator: validatePass, trigger: ['blur','change'] }],
    new_password_confirmation: [{ required: true, validator: validatePass2, trigger: ['blur','change'] }],
}

/* ===== Actions ===== */
const submit = () => formRef.value?.submit()
const reset  = () => formRef.value?.resetFields()
const noop   = () => {}

const handleSubmit = async () => {
    if (loading.value) return
    loading.value = true
    try {
        const params = { password: form.value.new_password }
        const res = await updateUser(props.dataUser?.id, params)
        if (res?.data?.status === 'success') {
            message.success('Cập nhật mật khẩu thành công')
            reset()
        } else {
            message.error(res?.data?.message || 'Cập nhật mật khẩu thất bại')
        }
    } catch {
        message.error('Cập nhật mật khẩu thất bại')
    } finally {
        loading.value = false
    }
}
</script>

<style scoped>
/* Shell */
.cp-wrapper{
    max-width: 560px;
    margin: 0 auto;
}
.cp-card{
    border: 1px solid #f0f0f0;
    border-radius: 16px;
    box-shadow: 0 8px 22px rgba(0,0,0,.05);
}

/* Header */
.cp-header{
    display:flex; align-items:flex-start; justify-content:space-between;
    margin-bottom: 4px;
}
.cp-title{
    font-size:18px; font-weight:600; color:#141414; line-height:1.2;
}
.cp-sub{
    color:#8c8c8c; margin-top:4px; font-size:13px;
}

/* Meter */
.cp-meter{ display:flex; align-items:center; gap:8px; margin-top:8px; }
.cp-meter :deep(.ant-progress-inner){ height:6px; }
.cp-meter-label{ font-size:12px; }

/* Checklist */
.cp-checklist{
    display:grid; grid-template-columns:1fr 1fr;
    gap:6px 12px; margin-top:4px;
}
.cp-check{
    display:flex; align-items:center; gap:8px;
    font-size:12px; color:#8c8c8c;
}
.cp-check.ok{ color:#52c41a; }
.cp-check .dot{
    width:8px; height:8px; border-radius:999px; background:#d9d9d9; display:inline-block;
}
.cp-check.ok .dot{ background:#52c41a; }

.cp-actions{
    display:flex; justify-content:flex-end; margin-bottom: 8px;
}
</style>
