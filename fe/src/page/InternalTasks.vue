<template>
    <div>
        <a-flex justify="space-between">
            <div>
                <a-typography-title :level="4">Danh sách nhiệm vụ</a-typography-title>
            </div>
            <a-button type="primary" @click="showPopupCreate('internal')">Thêm nhiệm vụ mới</a-button>
        </a-flex>

        <a-row :gutter="[14,14]" style="margin-top: 10px;">
            <a-col :span="9">
                <!-- ✅ Bộ lọc nhanh -->
                <a-space>
                    <!-- Lọc theo loại -->
                    <a-button-group>
                        <a-button :type="dataFilter.linked_type === null ? 'primary' : 'default'" @click="filterByType(null)">Tất cả ({{ totalTasks }})
                        </a-button>
                        <a-button :type="dataFilter.linked_type === 'bidding' ? 'primary' : 'default'" @click="filterByType('bidding')">Gói thầu
                        </a-button>
                        <a-button :type="dataFilter.linked_type === 'contract' ? 'primary' : 'default'" @click="filterByType('contract')">Hợp đồng
                        </a-button>
                        <a-button :type="dataFilter.linked_type === 'internal' ? 'primary' : 'default'" @click="filterByType('internal')">Công việc nội bộ
                        </a-button>
                    </a-button-group>

                    <!-- Lọc theo độ ưu tiên -->
                    <a-button-group>
                        <a-button :type="dataFilter.priority === null ? 'primary' : 'default'" @click="filterByPriority(null)">Tất cả
                        </a-button>
                        <a-button :type="dataFilter.priority === 'low' ? 'primary' : 'default'" danger ghost @click="filterByPriority('low')">Thấp
                        </a-button>
                        <a-button :type="dataFilter.priority === 'normal' ? 'primary' : 'default'" @click="filterByPriority('normal')" style="background: #faad14; color: white">Thường
                        </a-button>
                        <a-button :type="dataFilter.priority === 'high' ? 'primary' : 'default'" @click="filterByPriority('high')" style="background: #f5222d; color: white">Cao
                        </a-button>
                    </a-button-group>
                </a-space>
            </a-col>
        </a-row>

        <a-row :gutter="[14,14]" style="margin-top: 10px;">
            <a-col :span="2">
                <!-- ✅ Nút xoá -->
                <a-button danger type="primary" :disabled="selectedRowKeys.length === 0" @click="handleBulkDelete">
                    Xoá {{ selectedRowKeys.length }} nhiệm vụ
                </a-button>
            </a-col>
            <a-col :span="4">
                <a-input v-model:value="dataFilter.title" placeholder="Tìm việc theo tiêu đề" allow-clear @input="onTitleSearch"/>
            </a-col>
            <a-col :span="4">
                <a-select
                        :allowClear="true"
                        style="width: 100%"
                        v-model:value="dataFilter.id_department"
                        :options="optionsDepartment"
                        placeholder="Chọn phòng ban"
                        @change="getInternalTask()"
                />
            </a-col>
            <a-col :span="3">
                <a-select
                        :allowClear="true"
                        style="width: 100%"
                        v-model:value="dataFilter.status"
                        :options="statusOption"
                        placeholder="Chọn trạng thái"
                        @change="getInternalTask()"
                />
            </a-col>
            <a-col :span="3">
                <a-select
                        :allowClear="true"
                        style="width: 100%"
                        v-model:value="dataFilter.assigned_to"
                        :options="optionsAssigned"
                        placeholder="Người phụ trách"
                        @change="getInternalTask()"
                />
            </a-col>
            <a-col :span="4">
                <a-config-provider :locale="locale">
                    <a-range-picker
                            v-model:value="dateRange"
                            format="YYYY-MM-DD"
                            style="width: 100%;"
                            @change="onRangeChange"
                            allowClear
                            :placeholder="['Từ ngày', 'Đến ngày']"
                            :getPopupContainer="triggerNode => triggerNode.parentNode"
                    />
                </a-config-provider>
            </a-col>
        </a-row>

        <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                @change="handleTableChange"
                :pagination="pagination"
                :row-selection="rowSelection"
                style="margin-top: 8px;table-layout: fixed;"
                row-key="id"
                :scroll="{ x: 'max-content'}"
                class="custom_table_list_task tiny-scroll"
        >
            <template #bodyCell="{ column, record, index, text }">
                <template v-if="column.dataIndex === 'title'">
                    <a-tooltip :title="text">
                        <a-typography-text strong style="cursor: pointer; display: inline-block; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" @click="showPopupDetail(record)">
                            {{ text }}
                        </a-typography-text>
                    </a-tooltip>
                </template>

                <template v-if="column.dataIndex === 'priority'">
                    <a-tag v-if="text" :color="checkPriority(text).color">{{ checkPriority(text).title }}</a-tag>
                </template>

                <template v-if="column.dataIndex === 'assigned_to'">
                    <a-tooltip :title="record.assignee?.name || '—'">
                        <a-avatar size="large" :style="{ backgroundColor: getAvatarColor(record.assignee?.name),verticalAlign: 'middle',cursor: 'default'}">
                            {{ record.assignee?.name?.charAt(0).toUpperCase() || '?' }}
                        </a-avatar>
                    </a-tooltip>
                </template>

                <template v-if="column.dataIndex === 'linked_type'">
                    <a-tag :color="getLinkedTypeTag(text).color" style="cursor: pointer;">
                        {{ getLinkedTypeTag(text).label }}
                    </a-tag>
                </template>

                <template v-if="column.dataIndex === 'linked_id'">
                    <a-tooltip :title="getLinkedName(record.linked_type, text)">
                        <span v-if="record.linked_type === 'bidding' || record.linked_type === 'contract'"
                              style="color: #1890ff; cursor: pointer; display: inline-block; max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                              @click="goToLinkedDetail(record)">
                          {{ getLinkedName(record.linked_type, text) }}
                        </span>
                    </a-tooltip>
                </template>

                <template v-if="column.dataIndex === 'step_info'">
                    <div class="step_info_title">
                        <a-tooltip :title="getLinkedName(record.linked_type, record.linked_id)
                          ? 'Thuộc: ' + getLinkedName(record.linked_type, record.linked_id): ''">
                        <span v-if="record.step_code" style="color: #1890ff; cursor: pointer;"
                              @click="goToLinkedDetail(record)">
                          B{{ record.step_code }} - {{ record.step_name || '—' }}
                        </span>
                            <span v-else>
                          {{ record.step_name || '—' }}
                        </span>
                        </a-tooltip>
                    </div>
                </template>

                <template v-if="column.dataIndex === 'progress'">
                    <a-progress
                            :percent="Number(record.progress)"
                            :stroke-color="{
                              '0%': '#108ee9',
                              '100%': '#87d068',
                            }"
                            :status="record.progress >= 100 ? 'success' : 'active'"
                            size="small"
                            :show-info="true"
                    />
                </template>
                <template v-if="column.dataIndex === 'start_date' || column.dataIndex === 'end_date'">
                    {{ formatDate(text) || '—' }}
                </template>

                <template v-if="column.dataIndex === 'deadline'">
                    <a-tag v-if="record.days_overdue > 0" color="error">
                        Quá hạn {{ record.days_overdue }} ngày
                    </a-tag>
                    <a-tag v-else-if="record.days_remaining > 0" color="green">
                        Còn {{ record.days_remaining }} ngày
                    </a-tag>
                    <a-tag v-else-if="record.days_remaining === 0" :color="'#faad14'">
                        Hạn chót hôm nay
                    </a-tag>
                    <a-tag v-else>
                        —
                    </a-tag>
                </template>
                <template v-if="column.dataIndex === 'status'">
                    <a-tag :color="getStatusColor(text)">
                        {{ getStatusLabel(text) }}
                    </a-tag>
                </template>

                <template v-else-if="column.dataIndex === 'action'">
                    <a-dropdown placement="left" :trigger="['click']"
                                :getPopupContainer="triggerNode => triggerNode.parentNode">
                        <a-button>
                            <template #icon>
                                <MoreOutlined/>
                            </template>
                        </a-button>
                        <template #overlay>
                            <a-menu>
                                <a-menu-item @click="showPopupDetail(record)">
                                    <InfoCircleOutlined class="icon-action" style="color: blue;"/>
                                    Chi tiết
                                </a-menu-item>
                                <a-menu-item>
                                    <a-popconfirm
                                            title="Bạn chắc chắn muốn xóa nhiệm vụ này?"
                                            ok-text="Xóa"
                                            cancel-text="Hủy"
                                            @confirm="deleteConfirm(record.id)"
                                            placement="topRight"
                                    >
                                        <div style="width: 100%; text-align: start;">
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
        <DrawerCreateTask
                v-model:open-drawer="openDrawer"
                :list-user="listUser"
                @submitForm="submitForm"
        />
    </div>
</template>

<script setup>
    import {ref, onMounted, computed} from 'vue'
    import {getTasks, deleteTask} from '../api/task'
    import {getDepartments} from '../api/department'
    import {getUsers} from '@/api/user';
    import {message} from 'ant-design-vue'
    import {useRoute, useRouter} from 'vue-router';
    import {InfoCircleOutlined, DeleteOutlined, MoreOutlined, UnorderedListOutlined} from '@ant-design/icons-vue';
    import DrawerCreateTask from "../components/common/DrawerCreateTask.vue";
    import viVN from 'ant-design-vue/es/locale/vi_VN';
    import {debounce} from 'lodash-es'
    import {formatDate} from '@/utils/formUtils'

    import {getBiddingsAPI} from '@/api/bidding.js'
    import {getContractsAPI} from '@/api/contract.js'

    import { useUserStore } from '@/stores/user'
    const userStore = useUserStore()
    import { useCommonStore } from '@/stores/common';
    const commonStore = useCommonStore()

    const locale = ref(viVN);
    const router = useRouter()
    const tableData = ref([])
    const loading = ref(false)
    const openDrawer = ref(false)
    const listUser = ref([])
    const listDepartment = ref([])
    const dataFilter = ref({
        linked_type: null,
        id_department: null,
        status: null,
        priority: null,
        assigned_to: null,
        due_date: null,
        start_date: null,
        end_date: null,
        title: '',
        page: 1,
        per_page: 10
    })

    const selectedRowKeys = ref([])

    const rowSelection = computed(() => ({
        selectedRowKeys: selectedRowKeys.value,
        onChange: (newSelectedRowKeys) => {
            selectedRowKeys.value = newSelectedRowKeys
        }
    }))

    const onTitleSearch = debounce(() => {
        dataFilter.value.page = 1
        getInternalTask()
    }, 500)

    const dateRange = ref([])
    const totalTasks = computed(() => pagination.value.total)
    const filteredCount = computed(() => tableData.value.length)

    const getAvatarColor = (name) => {
        if (!name) return '#ccc';

        // Hash tên thành 1 số
        let hash = 0;
        for (let i = 0; i < name.length; i++) {
            hash = name.charCodeAt(i) + ((hash << 5) - hash);
        }

        // Tạo màu HSL từ hash
        const hue = Math.abs(hash) % 360;
        return `hsl(${hue}, 65%, 55%)`; // màu tươi sáng, đẹp
    };


    const onRangeChange = (dates, dateStrings) => {
        if (dateStrings[0] && dateStrings[1]) {
            dataFilter.value.start_date = dateStrings[0]
            dataFilter.value.end_date = dateStrings[1]
        } else {
            dataFilter.value.start_date = null
            dataFilter.value.end_date = null
        }
        getInternalTask()
    }

    const handleBulkDelete = async () => {
        try {
            await Promise.all(selectedRowKeys.value.map(id => deleteTask(id)))
            message.success(`Đã xoá ${selectedRowKeys.value.length} nhiệm vụ`)
            selectedRowKeys.value = []
            await getInternalTask()
        } catch (e) {
            message.error('Xoá hàng loạt thất bại')
        }
    }

    const filterByType = (type) => {
        dataFilter.value.linked_type = type
        getInternalTask()
    }

    const filterByPriority = (priority) => {
        dataFilter.value.priority = priority
        getInternalTask()
    }

    const optionsLinkType = computed(() => {
        return [
            {value: 'bidding', label: "Gói thầu"},
            {value: 'contract', label: "Hợp đồng"},
            {value: 'internal', label: "Nhiệm vụ nội bộ"},
        ]
    })
    const priorityOption = computed(() => {
        return [
            {value: 'low', label: "Thấp"},
            {value: 'normal', label: "Thường"},
            {value: 'high', label: "Cao"},
        ]
    })
    const statusOption = computed(() => {
        return [
            {value: 'todo', label: "Việc cần làm"},
            {value: 'doing', label: "Đang thực hiện"},
            {value: 'done', label: "Hoàn thành"},
            {value: 'overdue', label: "Quá hạn"},
        ]
    })
    const optionsAssigned = computed(() => {
        return listUser.value.map(ele => {
            return {value: ele.id, label: ele.name}
        })
    })
    const optionsDepartment = computed(() => {
        return listDepartment.value.map(ele => {
            return {value: ele.id, label: ele.name}
        })
    })

    const pagination = ref({
        current: 1,
        pageSize: 10,
        total: 0,
        showSizeChanger: true,
        showQuickJumper: true,
        showTotal: total => `Tổng ${total} nhiệm vụ`
    })

    const columns = [
        {
            title: 'STT',
            key: 'index',
            width: 60,
            align: 'center',
            fixed: 'left',
            customRender: ({ index }) => {
                const cur = Number(pagination.value?.current ?? 1)
                const size = Number(pagination.value?.pageSize ?? 10)
                return (cur - 1) * size + index + 1
            }
        },
        {title: 'Tên nhiệm vụ', dataIndex: 'title', key: 'title', width: 250, ellipsis: true},
        {title: 'Bước tiến trình', dataIndex: 'step_info', key: 'step_info', width: 200, ellipsis: true},
        {title: 'Loại Task', dataIndex: 'linked_type', key: 'linked_type'},
        // { title: 'Gói thầu || Hợp đồng', dataIndex: 'linked_id', key: 'linked_id' },
        {title: 'Độ ưu tiên', dataIndex: 'priority', key: 'priority'},
        {title: 'Người thực hiện', dataIndex: 'assigned_to', key: 'assigned_to', width: 140,},
        {title: 'Bắt đầu', dataIndex: 'start_date', key: 'start_date'},
        {title: 'Kết thúc', dataIndex: 'end_date', key: 'end_date'},
        {title: 'Tiến độ', dataIndex: 'progress', key: 'progress', width: 200,},
        {
            title: 'Hạn',
            dataIndex: 'deadline',
            key: 'deadline',
            customRender: ({record}) => {
                const overdue = record.days_overdue;
                const remaining = record.days_remaining;

                if (overdue > 0) {
                    return `Quá hạn ${overdue} ngày`;
                } else if (remaining >= 0) {
                    return `Còn ${remaining} ngày`;
                } else {
                    return '—';
                }
            }
        },
        {
            title: 'Trạng thái',
            dataIndex: 'status',
            key: 'status',
            width: 120,
        },

        {title: 'Hành động', dataIndex: 'action', key: 'action', width: '120px', align: 'center'},
    ];

    const changeDateTime = (day, date) => {
        if (date) {
            dataFilter.value.due_date = date;
        } else {
            dataFilter.value.due_date = "";
        }
        dataFilter.value.page = 1
        getInternalTask()
    }
    const getInternalTask = async () => {
        loading.value = true
        try {
            const user = userStore.currentUser;

            // Xóa filter cũ (tránh chồng chéo)
            dataFilter.value.assigned_to = null
            dataFilter.value.id_department = null

            // 👇 Phân quyền lọc theo vai trò
            const roleId = Number(user?.role_id)
            if (roleId === 3) {
                dataFilter.value.assigned_to = user.id
            } else if (roleId === 2) {
                dataFilter.value.id_department = user.department_id
            }
            // Admin không cần giới hạn

            const response = await getTasks(dataFilter.value)

            tableData.value = response.data.data ?? []

            const pg = response.data.pagination
            pagination.value = {
                ...pagination.value,
                current: pg.page,
                total: pg.total,
                pageSize: pg.per_page
            }
        } catch (e) {
            message.error('Không thể tải nhiệm vụ')
        } finally {
            loading.value = false
        }
    }


    const listBidding = ref([])
    const listContract = ref([])

    const getBiddings = async () => {
        try {
            const res = await getBiddingsAPI()
            listBidding.value = res.data.data
        } catch (e) {
            message.error('Không thể tải gói thầu')
        }
    }

    const getContracts = async () => {
        try {
            const res = await getContractsAPI()
            listContract.value = res.data
        } catch (e) {
            message.error('Không thể tải hợp đồng')
        }
    }

    const getLinkedName = (type, id) => {
        if (type === 'bidding' && Array.isArray(listBidding.value)) {
            const found = listBidding.value.find(ele => ele.id === id)
            return found ? found.title : '—'
        } else if (type === 'contract' && Array.isArray(listContract.value)) {
            const found = listContract.value.find(ele => ele.id === id)
            return found ? found.title : '—'
        }
        return '—'
    }


    const getLinkedTypeTag = (type) => {
        switch (type) {
            case 'bidding':
                return {label: 'Gói thầu', color: 'blue'}
            case 'contract':
                return {label: 'Hợp đồng', color: 'green'}
            case 'internal':
                return {label: 'Nội bộ', color: 'default'}
            default:
                return {label: 'Không rõ', color: 'red'}
        }
    }


    const goToLinkedDetail = (record) => {
        if (record.linked_type === 'bidding') {
            router.push(`/bid-detail/${record.linked_id}`)
        } else if (record.linked_type === 'contract') {
            router.push(`/contracts/${record.linked_id}`)
        }
    }

    const deleteConfirm = async (internalId) => {
        try {
            await deleteTask(internalId);
            await getInternalTask();
        } catch (e) {
            message.error('Xóa nhiệm vụ không thành công')
        } finally {
        }
    }
    const showPopupDetail = async (record) => {
        await router.push({
            name: "internal-tasks-info",
            params: {id: record.id, task_name: record.name}
        })
    }
    const showPopupCreate = (v) => {
        commonStore.setLinkedType(v);
        openDrawer.value = true;
    }
    const submitForm = () => {
        getInternalTask();
    }
    const checkPriority = (text) => {
        switch (text) {
            case 'low':
                return {title: "Thấp", color: "success"};
            case 'normal':
                return {title: "Thường", color: "warning"};
            case 'high':
                return {title: "Cao", color: "error"};
            default:
                return {title: "", color: ""};
        }
    };

    const getUserById = (userId) => {
        let data = listUser.value.find(ele => ele.id === userId);
        if (!data) {
            return "";
        }
        return data.name;
    }
    const getLinkedType = (text) => {
        switch (text) {
            case 'bidding':
                return "Gói thầu";
            case 'contract':
                return "Hợp đồng";
            case 'internal':
                return "Nhiệm vụ nội bộ";
            default:
                return ""
        }
    }

    const getUser = async () => {
        loading.value = true
        try {
            const response = await getUsers();
            listUser.value = response.data;
        } catch (e) {
            message.error('Không thể tải người dùng')
        } finally {
            loading.value = false
        }
    }
    const getDepartment = async () => {
        loading.value = true
        try {
            const response = await getDepartments();
            listDepartment.value = response.data;
        } catch (e) {
            message.error('Không thể tải người dùng')
        } finally {
            loading.value = false
        }
    }

    const handleTableChange = (pager) => {
        dataFilter.value.page = pager.current
        dataFilter.value.per_page = pager.pageSize
        getInternalTask()
    }

    const getStatusColor = (status) => {
        switch (status) {
            case 'todo':
                return 'default';
            case 'doing':
                return 'blue';
            case 'done':
                return 'green';
            case 'overdue':
                return 'red';
            case 'request_approval':
                return 'orange';
            default:
                return 'default';
        }
    };

    const getStatusLabel = (status) => {
        switch (status) {
            case 'todo':
                return 'Chưa bắt đầu';
            case 'doing':
                return 'Đang thực hiện';
            case 'done':
                return 'Hoàn thành';
            case 'overdue':
                return 'Quá hạn';
            case 'request_approval':
                return 'Chờ phê duyệt';
            default:
                return 'Không rõ';
        }
    };

    onMounted(() => {
        getInternalTask();
        getUser();
        getDepartment();
        getBiddings()
        getContracts()
    })
</script>

<style>
    .custom_table_list_task td {
        white-space: normal !important;
    }
    .step_info_title span {
        display: inline-block;
        max-width: 200px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
</style>

<style scoped>
    :deep(.ant-pagination) {
        margin-bottom: 0 !important;
    }

    .icon-action {
        font-size: 18px;
        margin-right: 8px;
        cursor: pointer;
    }

    &
    :last-child {
        margin-right: 0;
    }
</style>
