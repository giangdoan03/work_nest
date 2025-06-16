<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Quy trình đấu thầu mẫu</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm bước mới</a-button>
        </a-flex>

        <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                style="margin-top: 12px"
                row-key="step_number"
                :scroll="{ y: 'calc(100vh - 330px)' }"
        >
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ index + 1 }}
                </template>
                <template v-if="column.dataIndex === 'step_number'">
                    <a-tag color="blue">Bước {{ record.step_number }}</a-tag>
                </template>
                <template v-if="column.dataIndex === 'title'">
                    <a-typography-text strong style="cursor: pointer;" @click="editStep(record)">
                        {{ text }}
                    </a-typography-text>
                </template>
                <template v-if="column.dataIndex === 'department_ids'">
                    <a-space wrap>
                        <a-tag v-for="id in record.department_ids" :key="id">
                            {{ getDepartmentName(id) }}
                        </a-tag>
                    </a-space>
                </template>

                <template v-else-if="column.dataIndex === 'action'">
                    <a-dropdown placement="left">
                        <a-button>
                            <template #icon><MoreOutlined /></template>
                        </a-button>
                        <template #overlay>
                            <a-menu>
                                <a-menu-item @click="editStep(record)">
                                    <EditOutlined class="icon-action" style="color: blue;" />
                                    Chỉnh sửa
                                </a-menu-item>
                                <a-menu-item>
                                    <a-popconfirm
                                            title="Xoá bước này?"
                                            ok-text="Xoá"
                                            cancel-text="Hủy"
                                            @confirm="deleteStep(record.step_number)"
                                            placement="topRight"
                                    >
                                        <div>
                                            <DeleteOutlined class="icon-action" style="color: red;" />
                                            Xoá
                                        </div>
                                    </a-popconfirm>
                                </a-menu-item>
                            </a-menu>
                        </template>
                    </a-dropdown>
                </template>
            </template>
        </a-table>

        <a-drawer
                title="Thêm/Sửa bước đấu thầu"
                :width="550"
                :open="openDrawer"
                @close="onCloseDrawer"
                :footer-style="{ textAlign: 'right' }"
        >
            <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical" @finish="submitStep">
                <a-form-item label="Số bước (STT)" name="step_number">
                    <a-input-number v-model:value="formData.step_number" min="1" style="width: 100%" />
                </a-form-item>

                <a-form-item label="Tên bước" name="title">
                    <a-input v-model:value="formData.title" placeholder="Nhập tên bước" />
                </a-form-item>

                <a-form-item label="Phòng ban phụ trách" name="department_ids">
                    <a-select
                            v-model:value="formData.department_ids"
                            :options="departmentOptions"
                            mode="multiple"
                            placeholder="Chọn phòng ban"
                            show-search
                            allow-clear
                            option-filter-prop="label"
                    />
                </a-form-item>
            </a-form>

            <template #extra>
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button type="primary" @click="submitStep" :loading="loadingCreate">
                        {{ selectedStep ? 'Cập nhật' : 'Thêm mới' }}
                    </a-button>
                </a-space>
            </template>
        </a-drawer>
    </div>
</template>

<script setup>
    import { ref, onMounted, computed  } from 'vue'
    import {
        getSettingByKey,
        updateSetting,
        createSetting
    } from '../api/setting'
    import { getDepartments } from '../api/department'
    import { message } from 'ant-design-vue'
    import { EditOutlined, DeleteOutlined, MoreOutlined } from '@ant-design/icons-vue'

    const loading = ref(false)
    const loadingCreate = ref(false)
    const openDrawer = ref(false)

    const selectedStep = ref(null)
    const tableData = ref([])

    const departments = ref([])

    const departmentOptions = computed(() =>
        departments.value.map(d => ({
            label: d.name,
            value: d.id
        }))
    )

    const formData = ref({
        step_number: null,
        title: '',
        department_ids: []
    })

    const formRef = ref(null)

    const columns = [
        { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
        {
            title: 'Bước số',
            dataIndex: 'step_number',
            key: 'step_number',
            width: '100px',
            align: 'center'
        },
        { title: 'Tên bước', dataIndex: 'title', key: 'title' },
        {
            title: 'Phòng ban phụ trách',
            dataIndex: 'department_ids', // ✅ sửa lại đúng key
            key: 'department_ids'
        },
        { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px', align: 'center' }
    ]


    const rules = {
        step_number: [{ required: true, message: 'Vui lòng nhập STT' }],
        title: [{ required: true, message: 'Vui lòng nhập tên bước' }],
        department_ids: [{ required: true, type: 'array', min: 1, message: 'Chọn ít nhất 1 phòng ban' }]
    }

    const fetchSteps = async () => {
        loading.value = true
        try {
            const res = await getSettingByKey('bidding_steps')
            const parsed = JSON.parse(res.data.value)
            tableData.value = parsed.steps || []
            settingId.value = res.data.id
        } catch (err) {
            tableData.value = []
            settingId.value = null
        } finally {
            loading.value = false
        }
    }

    const settingId = ref(null)

    const showPopupCreate = () => {
        openDrawer.value = true
    }

    const getDepartmentName = (id) => {
        const dept = departments.value.find(d => d.id === id)
        return dept ? dept.name : ''
    }

    const fetchDepartments = async () => {
        try {
            const res = await getDepartments()
            console.log('Phòng ban:', res)

            if (Array.isArray(res.data)) {
                departments.value = res.data
            } else {
                throw new Error('Dữ liệu không hợp lệ')
            }
        } catch (err) {
            console.error(err)
            message.error('Không thể tải danh sách phòng ban')
        }
    }


    const editStep = (record) => {
        formData.value = { ...record }
        selectedStep.value = record
        openDrawer.value = true
    }

    const submitStep = async () => {
        try {
            await formRef.value?.validate()
            loadingCreate.value = true

            // Nếu sửa thì cập nhật
            const existingIndex = tableData.value.findIndex(s => s.step_number === formData.value.step_number)

            if (existingIndex !== -1 && selectedStep.value) {
                tableData.value.splice(existingIndex, 1, { ...formData.value })
            } else {
                tableData.value.push({ ...formData.value })
            }

            await saveSettingToServer()
            message.success('Lưu bước thành công')
            onCloseDrawer()
        } catch (e) {
            message.error('Không thể lưu bước')
        } finally {
            loadingCreate.value = false
        }
    }

    const deleteStep = async (stepNumber) => {
        tableData.value = tableData.value.filter(s => s.step_number !== stepNumber)
        await saveSettingToServer()
        message.success('Đã xoá bước')
    }

    const saveSettingToServer = async () => {
        const data = {
            key: 'bidding_steps',
            value: JSON.stringify({ steps: tableData.value })
        }
        if (settingId.value) {
            await updateSetting(settingId.value, data)
        } else {
            const res = await createSetting(data)
            settingId.value = res.data.id
        }
    }

    const onCloseDrawer = () => {
        openDrawer.value = false
        selectedStep.value = null
        formData.value = {
            step_number: null,
            title: '',
            department_id: null
        }
        formRef.value?.resetFields()
    }

    onMounted(() => {
        fetchSteps()
        fetchDepartments()
    })
</script>

<style scoped>
    .icon-action {
        font-size: 18px;
        margin-right: 8px;
        cursor: pointer;
    }
</style>
