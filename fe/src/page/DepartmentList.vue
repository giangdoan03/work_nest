<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách phòng ban</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate">Thêm phòng ban mới</a-button>
        </a-flex>

        <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                style="margin-top: 12px;"
                row-key="id"
                :scroll="{ y: 'calc( 100vh - 330px )' }"
        >
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.dataIndex === 'stt'">
                    {{ index + 1 }}
                </template>
                <template v-else-if="column.dataIndex === 'name'">
                    <a-typography-text strong style="cursor: pointer;" @click="showUsersOnly(record)">
                        {{ text }}
                    </a-typography-text>
                </template>
                <template v-else-if="column.dataIndex === 'action'">
                    <a-dropdown placement="left" trigger="click" :getPopupContainer="triggerNode => triggerNode.parentNode">
                        <a-button>
                            <template #icon><MoreOutlined /></template>
                        </a-button>
                        <template #overlay>
                            <a-menu>
                                <a-menu-item @click="showPopupDetail(record)">
                                    <div><EditOutlined class="icon-action" style="color: blue;" /> Chỉnh sửa</div>
                                </a-menu-item>
                                <a-menu-item>
                                    <a-popconfirm
                                            title="Bạn chắc chắn muốn xóa phòng ban này?"
                                            ok-text="Xóa"
                                            cancel-text="Hủy"
                                            @confirm="deleteConfirm(record.id)"
                                            placement="topRight"
                                    >
                                        <div><DeleteOutlined class="icon-action" style="color: red;" /> Xóa</div>
                                    </a-popconfirm>
                                </a-menu-item>
                            </a-menu>
                        </template>
                    </a-dropdown>
                </template>
            </template>
        </a-table>

        <a-drawer
                :title="drawerMode === 'view_users' ? 'Người dùng thuộc phòng ban' : (selectedDepartment ? 'Cập nhật phòng ban' : 'Tạo phòng ban mới')"
                :width="800"
                :open="openDrawer"
                :body-style="{ paddingBottom: '80px' }"
                :footer-style="{ textAlign: 'right' }"
                @close="onCloseDrawer"
        >
            <!-- 👉 Form thêm / cập nhật phòng ban -->
            <template v-if="drawerMode !== 'view_users'">
                <a-form ref="formRef" :model="formData" :rules="rules" layout="vertical">
                    <a-form-item label="Tên phòng ban" name="name">
                        <a-input v-model:value="formData.name" placeholder="Nhập tên phòng ban" />
                    </a-form-item>
                    <a-form-item label="Mô tả" name="description">
                        <a-textarea v-model:value="formData.description" :rows="6" placeholder="Nhập mô tả" />
                    </a-form-item>
                </a-form>
            </template>

            <!-- 👉 Table danh sách người dùng -->
            <template v-else>
                <a-table
                        :columns="userColumns"
                        :data-source="departmentUsers"
                        :loading="loadingUsers"
                        row-key="id"
                        size="small"
                        bordered
                >
                    <template #bodyCell="{ column, record, index }">
                        <template v-if="column.key === 'stt'">
                            {{ index + 1 }}
                        </template>

                        <template v-else-if="column.key === 'name'">
                            <div style="display: flex; align-items: center;">
                                <a-avatar style="background-color: #87d068; margin-right: 8px;">
                                    {{ record.name[0] }}
                                </a-avatar>
                                <span>{{ record.name }}</span>
                            </div>
                        </template>

                        <template v-else-if="column.key === 'email'">
                            {{ record.email }}
                        </template>

                        <template v-else-if="column.key === 'phone'">
                            {{ record.phone }}
                        </template>

                        <template v-else-if="column.key === 'role'">
                            {{ getRoleName(record.role_id) }}
                        </template>
                    </template>

                </a-table>
            </template>

            <!-- Footer -->
            <template #extra v-if="drawerMode !== 'view_users'">
                <a-space>
                    <a-button @click="onCloseDrawer">Hủy</a-button>
                    <a-button
                            v-if="selectedDepartment"
                            type="primary"
                            @click="submitDepartment"
                            :loading="loadingCreate"
                    >Cập nhật</a-button>
                    <a-button
                            v-else
                            type="primary"
                            @click="submitDepartment"
                            :loading="loadingCreate"
                    >Thêm mới</a-button>
                </a-space>
            </template>
        </a-drawer>

    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue';
    import {
        getDepartments,
        createDepartment,
        updateDepartment,
        deleteDepartment,
    } from '../api/department';
    import { getUsers } from '../api/user';
    import { message } from 'ant-design-vue';
    import { EditOutlined, DeleteOutlined, MoreOutlined } from '@ant-design/icons-vue';
    import {getRoles} from "../api/permission";

    const selectedDepartment = ref(null);
    const tableData = ref([]);
    const loading = ref(false);
    const loadingCreate = ref(false);
    const openDrawer = ref(false);
    const formRef = ref(null);
    const roles = ref([]); // Khai báo mảng role

    const drawerMode = ref("form"); // hoặc "view_users"

    const formData = ref({
        name: '',
        description: '',
    });

    const departmentUsers = ref([]);
    const loadingUsers = ref(false);

    const rules = {
        name: [{ required: true, message: 'Vui lòng nhập tên phòng ban' }],
        description: [{ required: true, message: 'Vui lòng nhập mô tả phòng ban' }],
    };

    const columns = [
        { title: 'STT', dataIndex: 'stt', key: 'stt', width: '60px' },
        { title: 'Tên phòng ban', dataIndex: 'name', key: 'name' },
        { title: 'Mô tả', dataIndex: 'description', key: 'description' },
        { title: 'Thời gian tạo', dataIndex: 'created_at', key: 'created_at' },
        { title: 'Cập nhật gần nhất', dataIndex: 'updated_at', key: 'updated_at' },
        { title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px', align: 'center' },
    ];
    const userColumns = [
        { title: 'STT', key: 'stt' },
        { title: 'Họ tên', key: 'name' },
        { title: 'Email', key: 'email' },
        { title: 'Số điện thoại', key: 'phone' },
        { title: 'Vai trò', key: 'role' }
    ];



    const getDepartment = async () => {
        loading.value = true;
        try {
            const res = await getDepartments();
            tableData.value = res.data;
        } catch (e) {
            message.error('Không thể tải phòng ban');
        } finally {
            loading.value = false;
        }
    };

    const getRolesList = async () => {
        try {
            const res = await getRoles();
            roles.value = res.data.map(role => ({
                label: role.description,
                value: role.id
            }));

            console.log('roles', roles)
        } catch (e) {
            console.error('Không thể tải danh sách vai trò');
        }
    };

    const getRoleName = (id) => {
        const role = roles.value.find(r => r.value === String(id)); // hoặc Number(id) nếu `value` là số
        return role ? role.label : 'Không xác định'; // Sử dụng `label` thay vì `description`
    };



    const submitDepartment = async () => {
        try {
            await formRef.value?.validate();
            if (selectedDepartment.value) {
                await updateDepartment(selectedDepartment.value.id, formData.value);
                message.success('Cập nhật phòng ban thành công');
            } else {
                await createDepartment(formData.value);
                message.success('Thêm mới phòng ban thành công');
            }
            await getDepartment();
            onCloseDrawer();
        } catch (e) {
            message.error('Thao tác không thành công');
        }
    };

    const deleteConfirm = async (id) => {
        try {
            await deleteDepartment(id);
            await getDepartment();
        } catch (e) {
            message.error('Xóa phòng ban không thành công');
        }
    };

    const showPopupDetail = async (record) => {
        selectedDepartment.value = record;
        formData.value = { name: record.name, description: record.description };
        openDrawer.value = true;
        await getUsersByDepartment(record.id);
    };

    const showPopupCreate = () => {
        drawerMode.value = "form";
        openDrawer.value = true;
        selectedDepartment.value = null;
        formData.value = { name: '', description: '' };
        departmentUsers.value = [];
    };

    const onCloseDrawer = () => {
        openDrawer.value = false;
        formRef.value?.resetFields();
        selectedDepartment.value = null;
        departmentUsers.value = [];
    };

    const getUsersByDepartment = async (departmentId) => {
        try {
            loadingUsers.value = true;
            const res = await getUsers({ department_id: departmentId });
            departmentUsers.value = res.data || [];
        } catch (e) {
            message.error('Không thể tải danh sách người dùng');
        } finally {
            loadingUsers.value = false;
        }
    };


    const showUsersOnly = async (record) => {
        drawerMode.value = 'view_users';
        selectedDepartment.value = record;
        formData.value = { name: record.name, description: record.description };
        openDrawer.value = true;
        await getUsersByDepartment(record.id);
    };

    onMounted(() => {
        getDepartment();
        getRolesList(); // ✅ Đừng quên dòng này!
    });

</script>

<style scoped>
    .icon-action {
        font-size: 18px;
        margin-right: 8px;
        cursor: pointer;
    }

    &:last-child {
         margin-right: 0;
     }
</style>