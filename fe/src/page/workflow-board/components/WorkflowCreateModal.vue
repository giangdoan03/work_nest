<template>
    <a-modal
        v-model:open="modalOpen"
        title="Tạo hồ sơ trình duyệt"
        width="600px"
        :confirm-loading="loading"
        @ok="handleSubmit"
        ok-text="Trình duyệt"
        cancel-text="Huỷ"
        destroy-on-close
    >
        <a-form layout="vertical">
            <!-- Tiêu đề -->
            <a-form-item label="Tiêu đề hồ sơ" required>
                <a-input
                    v-model:value="form.title"
                    placeholder="VD: Trình duyệt báo giá dự án A"
                />
            </a-form-item>

            <!-- Phòng ban -->
            <a-form-item label="Phòng trình" required>
                <a-select
                    v-model:value="form.department_id"
                    placeholder="Chọn phòng ban"
                >
                    <a-select-option :value="3">Phòng Kinh doanh</a-select-option>
                    <a-select-option :value="4">Phòng Thương mại</a-select-option>
                </a-select>
            </a-form-item>

            <!-- Ghi chú -->
            <a-form-item label="Ghi chú">
                <a-textarea
                    v-model:value="form.note"
                    :rows="3"
                    placeholder="Nội dung trình duyệt / yêu cầu"
                />
            </a-form-item>

            <!-- Upload -->
            <a-form-item label="Tài liệu đính kèm" required>
                <a-upload
                    multiple
                    :file-list="fileList"
                    :before-upload="() => false"
                    @change="onFileChange"
                >
                    <a-button>Chọn file</a-button>
                </a-upload>
                <div class="hint">
                    Có thể upload nhiều file (PDF, Word, Excel…)
                </div>
            </a-form-item>
        </a-form>
    </a-modal>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { message } from 'ant-design-vue'
import { submitWorkflow } from '@/api/workflow'

/* ================= PROPS & EMITS ================= */
const props = defineProps({
    open: { type: Boolean, default: false },
})
const emit = defineEmits(['update:open', 'submitted'])

/* ================= v-model bridge ================= */
const modalOpen = computed({
    get: () => props.open,
    set: (val) => emit('update:open', val),
})

/* ================= STATE ================= */
const loading = ref(false)

const form = ref({
    title: '',
    department_id: null,
    note: '',
})

const fileList = ref([])

/* ================= WATCH ================= */
watch(() => props.open, (v) => {
    if (!v) resetForm()
})

/* ================= METHODS ================= */
const onFileChange = ({ fileList: fl }) => {
    fileList.value = fl
}

const resetForm = () => {
    form.value = {
        title: '',
        department_id: null,
        note: '',
    }
    fileList.value = []
}

const handleSubmit = async () => {
    if (!form.value.title || !form.value.department_id) {
        message.warning('Vui lòng nhập đầy đủ thông tin')
        return
    }

    if (!fileList.value.length) {
        message.warning('Cần ít nhất 1 file đính kèm')
        return
    }

    const fd = new FormData()
    fd.append('title', form.value.title)
    fd.append('department_id', form.value.department_id)
    fd.append('description', form.value.note || '')

    fileList.value.forEach(f => {
        if (f.originFileObj) {
            fd.append('documents[]', f.originFileObj)
        }
    })

    try {
        loading.value = true
        await submitWorkflow(fd)

        message.success('Đã tạo hồ sơ trình duyệt')
        modalOpen.value = false
        emit('submitted')
    } catch (e) {
        console.error(e)
        message.error('Không thể tạo hồ sơ')
    } finally {
        loading.value = false
    }
}
</script>

<style scoped>
.hint {
    font-size: 12px;
    color: #888;
    margin-top: 4px;
}
</style>
