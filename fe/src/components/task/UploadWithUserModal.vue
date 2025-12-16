<template>
    <a-modal
        :open="open"
        title="Thêm tài liệu liên quan"
        width="700px"
        centered
        class="upload-user-modal"
        :destroyOnClose="true"
        :body-style="{ maxHeight: '60vh', overflowY: 'auto' }"
        @ok="onOk"
        @cancel="onCancel"
        :ok-button-props="{ disabled: !canSubmit }"
        :confirm-loading="submitting"
    >
        <!-- Upload -->
        <a-upload
            :file-list="fileList"
            :before-upload="handleBeforeUpload"
            @remove="handleRemove"
            :multiple="true"
            :max-count="maxFiles"
            accept=".xls,.xlsx,.doc,.docx"
        >
            <a-button>
                <UploadOutlined />
                Chọn file (Excel, Word)
            </a-button>
        </a-upload>

        <a-divider />

        <!-- Users -->
        <div class="section user-scroll">
            <a-checkbox-group v-model:value="checkedUsers">
                <div
                    v-for="(group, deptName) in usersByDepartment"
                    :key="deptName"
                    class="dept-group"
                >
                    <div class="dept-title">
                        {{ deptName }}
                        <span class="dept-count">({{ group.length }})</span>
                    </div>

                    <div class="user-grid">
                        <label
                            v-for="u in group"
                            :key="`${u.user_id}-${u.department_id}`"
                            class="user-item"
                        >
                            <a-checkbox :value="`${u.user_id}-${u.department_id}`" />

                            <div class="user-inline">
                                <span class="user-name">{{ u.name }}</span>

                                <a-tag size="small" color="blue">
                                    {{ u.position_name }}
                                </a-tag>
                            </div>
                        </label>
                    </div>
                </div>
            </a-checkbox-group>
        </div>
    </a-modal>
</template>

<script setup>
import { ref, computed, toRefs, watch } from 'vue'
import { UploadOutlined } from '@ant-design/icons-vue'
import { message, Upload } from 'ant-design-vue'
import { createApprovalSession } from '@/api/approvalSessions'

/* ================= PROPS ================= */
const props = defineProps({
    open: Boolean,
    taskId: {
        type: [Number, String],
        required: true
    },
    users: {
        type: Array,
        default: () => []
    },
    maxFiles: {
        type: Number,
        default: 3
    },
    getDepartmentName: {
        type: Function,
        default: () => ''
    }
})

const emit = defineEmits(['update:open', 'confirm'])

/* expose props */
const { users, getDepartmentName } = toRefs(props)

/* ================= STATE ================= */
const fileList = ref([])
const checkedUsers = ref([])
const submitting = ref(false)

/* ================= COMPUTED ================= */
const canSubmit = computed(() =>
    !submitting.value &&
    fileList.value.length > 0 &&
    checkedUsers.value.length > 0
)

/* ================= USERS DISPLAY ================= */
const displayUsers = computed(() => {
    const result = []

    users.value.forEach(user => {
        // không kiêm nhiệm
        if (user.is_multi_role !== '1' || !user.multi_roles?.length) {
            result.push({
                user_id: user.id,
                name: user.name,
                department_id: user.department_id,
                department_name: getDepartmentName.value(user),
                position_name: user.position_name
            })
            return
        }

        // kiêm nhiệm
        user.multi_roles.forEach(role => {
            if (role.active !== '1') return

            const isBGD = role.department_name === 'Ban giám đốc'

            result.push({
                user_id: user.id,
                name: user.name,
                department_id: role.department_id,
                department_name: role.department_name,
                position_name: isBGD
                    ? user.position_name
                    : 'Trưởng phòng'
            })
        })
    })

    return result
})

const usersByDepartment = computed(() => {
    const map = {}
    displayUsers.value.forEach(u => {
        const dept = u.department_name || 'Khác'
        if (!map[dept]) map[dept] = []
        map[dept].push(u)
    })
    return map
})

/* ================= UPLOAD ================= */
const ALLOWED_EXTS = ['xls', 'xlsx', 'doc', 'docx']

const handleBeforeUpload = (file) => {
    if (submitting.value) return Upload.LIST_IGNORE

    if (fileList.value.length >= props.maxFiles) {
        message.warning(`Chỉ được đính kèm tối đa ${props.maxFiles} file`)
        return Upload.LIST_IGNORE
    }

    const ext = file.name.split('.').pop().toLowerCase()
    if (!ALLOWED_EXTS.includes(ext)) {
        message.error('Chỉ cho phép file Excel hoặc Word')
        return Upload.LIST_IGNORE
    }

    if (fileList.value.some(f => f.name === file.name)) {
        message.warning('File đã được chọn')
        return Upload.LIST_IGNORE
    }

    fileList.value.push({
        uid: file.uid,
        name: file.name,
        status: 'done',
        originFileObj: file
    })

    return Upload.LIST_IGNORE
}

const handleRemove = (file) => {
    fileList.value = fileList.value.filter(f => f.uid !== file.uid)
    return true
}

/* ================= SUBMIT ================= */
const onOk = async () => {
    if (!canSubmit.value) {
        message.warning('Vui lòng chọn file và người duyệt')
        return
    }

    submitting.value = true

    try {
        const form = new FormData()
        form.append('task_id', props.taskId)
        form.append('approvers', JSON.stringify(checkedUsers.value))

        fileList.value.forEach(f => {
            form.append('files[]', f.originFileObj, f.name)
        })

        await createApprovalSession(form)

        message.success('Tạo phiên duyệt thành công')

        resetForm()                 // ⭐ RESET Ở ĐÂY
        emit('confirm')
        emit('update:open', false)

    } catch (err) {
        console.error(err)
        message.error(
            err?.response?.data?.message ||
            'Không thể tạo phiên duyệt'
        )
    } finally {
        submitting.value = false
    }
}


const resetForm = () => {
    fileList.value = []
    checkedUsers.value = []
    submitting.value = false
}

const onCancel = () => {
    resetForm()                     // ⭐ RESET
    emit('update:open', false)
}

watch(
    () => props.open,
    (val) => {
        if (!val) resetForm()
    }
)
</script>

<style scoped>
.upload-user-modal :deep(.ant-modal-content) {
    border-radius: 14px;
}

.upload-user-modal :deep(.ant-modal-header) {
    border-bottom: 1px solid #f0f0f0;
    padding: 16px 20px;
}

.upload-user-modal :deep(.ant-modal-title) {
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
}

.upload-user-modal :deep(.ant-modal-body) {
    padding: 20px 22px;
}

.section {
    margin-top: 8px;
}

.dept-group {
    margin-bottom: 18px;
}

.dept-title {
    font-size: 14px;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 6px;
}

.dept-count {
    font-size: 12px;
    color: #6b7280;
}

.user-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px 12px;
}

.user-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    background: #fff;
    cursor: pointer;
    transition: all 0.15s ease;
}

.user-item:hover {
    background: #f9fafb;
    border-color: #c7d2fe;
}

.user-inline {
    display: flex;
    align-items: center;
    gap: 8px;
    min-width: 0;
}

.user-name {
    font-size: 14px;
    font-weight: 500;
    color: #111827;
    white-space: nowrap;
    text-overflow: ellipsis;
}

.user-scroll {
    max-height: 45vh;
    overflow-y: auto;
    padding-right: 4px;
}

.user-scroll::-webkit-scrollbar {
    width: 6px;
}

.user-scroll::-webkit-scrollbar-thumb {
    background: #d1d5db;
    border-radius: 6px;
}

.user-scroll::-webkit-scrollbar-thumb:hover {
    background: #9ca3af;
}

@media (max-width: 520px) {
    .user-grid {
        grid-template-columns: 1fr;
    }
}
</style>
