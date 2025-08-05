<template>
    <div>
        <a-page-header
                title="Chi tiết gói thầu"
                sub-title="Xem thông tin và tiến trình xử lý"
                @back="goBack"
                style="padding: 0 0 20px;"
        />
        <a-descriptions bordered :column="2">
            <!-- Hàng 1 -->
            <a-descriptions-item label="Tên">{{ bidding?.title }}</a-descriptions-item>
            <a-descriptions-item label="Trạng thái">
                <a-tag :color="getStatusColor(bidding?.status)">
                    {{ getStatusText(bidding?.status) }}
                </a-tag>
            </a-descriptions-item>

            <!-- Hàng 2 -->
            <a-descriptions-item label="Chi phí">{{ formatCurrency(bidding?.estimated_cost) }}</a-descriptions-item>
            <a-descriptions-item label="Khách hàng">
                <a @click="goToCustomerDetail(bidding?.customer_id)" style="color: #1890ff; cursor: pointer;">
                    {{ getCustomerName(bidding?.customer_id) }}
                </a>
            </a-descriptions-item>

            <!-- Hàng 3 -->
            <a-descriptions-item label="Phụ trách gói thầu">
                <a
                        v-if="bidding?.assigned_to"
                        @click="goToUserDetail(bidding.assigned_to)"
                        style="color: #1890ff; cursor: pointer;"
                >
                    {{ getAssignedUserName(bidding?.assigned_to) }}
                </a>
                <span v-else>Không xác định</span>
            </a-descriptions-item>

            <a-descriptions-item label="Ngày bắt đầu">{{ formatDate(bidding?.start_date) }}</a-descriptions-item>

            <!-- Hàng 4 -->
            <a-descriptions-item label="Ngày kết thúc">{{ formatDate(bidding?.end_date) }}</a-descriptions-item>
            <a-descriptions-item label="Mô tả">
                {{ bidding?.description }}
            </a-descriptions-item>
        </a-descriptions>

        <a-typography-title :level="5" class="mt-30 mb-30">Tiến trình xử lý</a-typography-title>

        <a-spin :spinning="loadingSteps">
            <a-steps direction="vertical" :current="currentStepIndex()">
                <a-step
                        v-for="(step, index) in steps"
                        :key="step.id"
                        :status="mapStepStatus(step.status)"
                >
                    <template #title>
                        <div
                                @click.stop="openStepDrawer(step)"
                                :class="{'active-step-title': activeStepId === step.id}"
                                style="display: flex;
                                 justify-content: space-between;
                                 align-items: center;
                                 cursor: pointer;
                                 color: #1890ff;">
                                <span style="text-decoration: underline;">
                                  Bước {{ step.step_number ?? '-' }}: {{ step.title ?? '-' }}
                                </span>

                            <a-statistic
                                    :value="step.task_done_count ?? 0"
                                    :suffix="'/' + step.task_count + ' task đã xong'"
                                    :value-style="{ fontSize: '13px', color: '#555' }"
                                    style="padding-left: 10px;"
                            />
                        </div>
                    </template>

                    <template #description>
                        <a-descriptions
                                size="small"
                                :column="1"
                                bordered
                                style="background: #fafafa; padding: 12px; border-radius: 6px;"
                                :labelStyle="{ width: '200px' }"
                        >
                            <a-descriptions-item label="Phòng ban">
                                <template #default>
                                    <a-tag
                                            v-for="(dep, i) in parseDepartment(step.department)"
                                            :key="i"
                                            color="blue"
                                            style="margin-right: 4px;"
                                    >
                                        {{ dep }}
                                    </a-tag>
                                </template>
                            </a-descriptions-item>

                            <a-descriptions-item label="Trạng thái">
                                <a-tag :color="getStepStatusColor(step.status)">
                                    {{ statusText(step.status) }}
                                </a-tag>
                            </a-descriptions-item>

                            <a-descriptions-item label="Phụ trách bước">
                                <template #default>
                                    <a
                                            v-if="step.assigned_to"
                                            @click.stop="goToUserDetail(step.assigned_to)"
                                            style="color: #1890ff; cursor: pointer;"
                                    >
                                        {{ getAssignedUserName(step.assigned_to) }}
                                    </a>
                                    <span v-else>Không xác định</span>
                                </template>
                            </a-descriptions-item>

                            <a-descriptions-item label="Ngày bắt đầu">
                                <span v-if="step.start_date">{{ formatDate(step.start_date) }}</span>
                                <span v-else>--</span>
                            </a-descriptions-item>

                            <a-descriptions-item label="Ngày kết thúc">
                                <span v-if="step.end_date">{{ formatDate(step.end_date) }}</span>
                                <span v-else>--</span>
                            </a-descriptions-item>
                        </a-descriptions>
                    </template>
                </a-step>
            </a-steps>
        </a-spin>


        <!-- Drawer hiển thị chi tiết bước -->
        <a-drawer
                title="Chi tiết bước xử lý"
                placement="right"
                :visible="drawerVisible"
                @close="closeDrawer"
                width="900"
        >
            <template v-if="selectedStep">
                <a-descriptions
                        size="small"
                        :column="1"
                        bordered
                >
                    <a-descriptions-item label="Bước số">{{ selectedStep.step_number }}</a-descriptions-item>
                    <a-descriptions-item label="Tiêu đề">
                        <a-typography-text
                                type="secondary"
                                v-if="!showEditTitle"
                                @click="editTitle"
                        >
                            {{ selectedStep.title || '---' }}
                            <EditOutlined/>
                        </a-typography-text>
                        <a-input
                                v-if="showEditTitle"
                                v-model:value="editedTitle"
                                @pressEnter="updateStepTitle"
                                @blur="updateStepTitle"
                                placeholder="Nhập tiêu đề"
                        />
                    </a-descriptions-item>

                    <a-descriptions-item label="Phòng ban">
                        <template #default>
                            <a-tag v-for="(dep, index) in parseDepartment(selectedStep.department)" :key="index"
                                   color="blue" style="margin-right: 4px;">
                                {{ dep }}
                            </a-tag>
                        </template>
                    </a-descriptions-item>
                    <a-descriptions-item label="Trạng thái">
                        <a-select v-model:value="selectedStep.status" style="width: 100%"
                                  @change="(value) => updateStepStatus(value, selectedStep)">
                            <a-select-option value="0">Chưa bắt đầu</a-select-option>
                            <a-select-option value="1">Đang xử lý</a-select-option>
                            <a-select-option value="2">Hoàn thành</a-select-option>
                            <a-select-option value="3">Bỏ qua</a-select-option>
                        </a-select>
                    </a-descriptions-item>
                    <a-descriptions-item label="Người phụ trách">
                        <a-select
                                v-model:value="selectedStep.assigned_to"
                                style="width: 100%"
                                placeholder="Chọn người phụ trách"
                                @change="(value) => updateStepAssignedTo(value, selectedStep)"
                                :allowClear="true"
                        >
                            <a-select-option
                                    v-for="user in users"
                                    :key="user.id"
                                    :value="user.id"
                            >
                                {{ user.name }}
                            </a-select-option>
                        </a-select>
                    </a-descriptions-item>

                    <a-descriptions-item label="Ngày bắt đầu">
                        <a-typography-text type="secondary" v-if="!showEditDateStart" @click="editDateStart">
                            {{ formatDate(selectedStep.start_date) }}
                            <EditOutlined/>
                        </a-typography-text>
                        <a-date-picker
                                v-if="showEditDateStart"
                                style="width: 100%"
                                v-model:value="dateStart"
                                @change="updateStepStartDate"
                        />
                    </a-descriptions-item>
                    <a-descriptions-item label="Ngày kết thúc">
                        <a-typography-text type="secondary" v-if="!showEditDateEnd" @click="editDateEnd">
                            {{ formatDate(selectedStep.end_date) }}
                            <EditOutlined/>
                        </a-typography-text>
                        <a-date-picker
                                :disabledDate="disabledDate"
                                v-if="showEditDateEnd"
                                style="width: 100%"
                                v-model:value="dateEnd"
                                @change="updateStepEndDate"
                        />
                    </a-descriptions-item>
                </a-descriptions>

                <a-divider>
                </a-divider>

                <a-row :gutter="16" justify="end">
                    <a-col>
                        <a-button type="primary" @click="showPopupCreate">
                            Thêm nhiệm vụ mới
                        </a-button>
                    </a-col>
                </a-row>

                <a-divider>
                    Danh sách công việc của bước này
                </a-divider>

                <!-- Nếu không có task -->
                <a-empty v-if="relatedTasks.length === 0" description="Không có công việc"/>

                <!-- Nếu có task -->
                <template v-else>
                    <!-- Header -->
                    <div style="
                          display: flex;
                          justify-content: space-between;
                          padding: 8px 0;
                          font-weight: 500;
                          color: #555;
                          border-bottom: 1px solid #f0f0f0;
                        "
                    >
                        <span>Nội dung mô tả</span>
                        <span>Trạng thái</span>
                    </div>

                    <!-- Danh sách nhiệm vụ -->
                    <a-list
                            :dataSource="relatedTasks"
                            :rowKey="task => task.id"
                            item-layout="horizontal"
                    >
                        <template #renderItem="{ item }">
                            <a-list-item>
                                <div style="display: flex; justify-content: space-between; width: 100%;">
                                    <!-- Cột trái: nội dung -->
                                    <div>
                                        <div style="font-weight: 600;">
                                            <router-link :to="`/internal-tasks/${item.id}/info`">
                                                {{ item.title }}
                                            </router-link>
                                        </div>
                                        <div style="font-size: 13px; color: #666;">
                                            {{ item.description }}
                                        </div>
                                        <div style="font-size: 13px; color: #999;">
                                            Phụ trách: {{ getAssignedUserName(item.assigned_to) }}
                                        </div>
                                    </div>

                                    <!-- Cột phải: trạng thái thực hiện + duyệt -->
                                    <div style="white-space: nowrap; text-align: right;">
                                        <!-- Luôn hiển thị trạng thái task -->
                                        <a-tag :color="getTaskStatusColor(item.status)">
                                            {{ getTaskStatusText(item.status) }}
                                        </a-tag>

                                        <!-- Nếu đã hoàn thành và đã duyệt -->
                                        <div v-if="item.status === 'done' && item.approval_status === 'approved'">
                                            <a-tag color="green">Hoàn thành & Đã duyệt</a-tag>
                                        </div>

                                        <!-- Nếu hoàn thành nhưng chưa được duyệt hoặc bị từ chối -->
                                        <div v-else-if="item.status === 'done'">
                                            <a-tag :color="getApprovalStatusColor(item.approval_status)">
                                                {{ getApprovalStatusText(item.approval_status) }}
                                            </a-tag>
                                        </div>
                                    </div>
                                </div>
                            </a-list-item>
                        </template>
                    </a-list>
                </template>
            </template>
        </a-drawer>

        <DrawerCreateTask
                v-model:open-drawer="openDrawer"
                :list-user="users"
                type="bidding"
                @submitForm="handleDrawerSubmit"
        />
    </div>
</template>

<script setup>
    import {ref, onMounted, computed} from 'vue'
    import dayjs from 'dayjs'
    import {
        getBiddingAPI,
        cloneFromTemplatesAPI,
        getBiddingStepsAPI,
        updateBiddingStepAPI,
        completeBiddingStepAPI
    } from '@/api/bidding'
    import {getUsers} from '@/api/user.js'
    import {useRoute} from 'vue-router'
    import {message} from 'ant-design-vue'
    import {formatDate, formatCurrency} from '@/utils/formUtils'
    import {getCustomers} from '../api/customer' // file API của bạn
    import {useRouter} from 'vue-router'
    import {EditOutlined} from '@ant-design/icons-vue'
    import {useStepStore} from '@/stores/step'

    const stepStore = useStepStore()
    const router = useRouter()
    const route = useRoute()
    const id = route.params.id
    const bidding = ref({})
    const steps = ref([])
    const loadingSteps = ref(false)

    let drawerVisible = ref(false)
    const selectedStep = ref(null)
    const customers = ref([])
    const users = ref([])
    const openDrawer = ref(false)
    const listUser = ref([])
    const activeStepId = ref(null)

    import {useUserStore} from '@/stores/user'

    const userStore = useUserStore()
    const user = userStore.currentUser


    import {getTasks, getTasksByBiddingStep, getTasksByContractStep} from '@/api/task'
    import DrawerCreateTask from "@/components/common/DrawerCreateTask.vue";
    import {updateContractStepAPI} from "@/api/contract-steps.js"; // nếu chưa import

    const allTasks = ref([])
    const relatedTasks = computed(() => stepStore.relatedTasks)
    const loading = ref(false);

    const dateStart = ref()
    const dateEnd = ref()
    const showEditDateStart = ref(false)
    const showEditDateEnd = ref(false)
    const editDateStart = () => {
        dateStart.value = selectedStep.value.start_date ? dayjs(selectedStep.value.start_date) : null
        showEditDateStart.value = true
        showEditDateEnd.value = false
    }
    const editDateEnd = () => {
        dateEnd.value = selectedStep.value.end_date ? dayjs(selectedStep.value.end_date) : null
        showEditDateStart.value = false
        showEditDateEnd.value = true
    }
    const updateStepStartDate = async (value, option) => {
        selectedStep.value.start_date = value.format('YYYY-MM-DD');
        try {
            await updateBiddingStepAPI(selectedStep.value.id, {start_date: selectedStep.value.start_date})
            message.success('Cập nhật ngày bắt đầu thành công')
            showEditDateStart.value = false
            await fetchSteps()
        } catch (e) {
            const msg = 'Không thể cập nhật ngày bắt đầu'
            message.error(msg)
            console.warn('Lỗi cập nhật ngày bắt đầu:', msg)
        }
    }

    const submitForm = () => {
        getInternalTask();
    }

    const showPopupCreate = () => {
        const step = stepStore.selectedStep // hoặc từ selectedStep.value nếu bạn đang dùng ref

        if (step) {
            // Gán lại selectedStep nếu cần (đảm bảo có dữ liệu mới nhất)
            stepStore.setSelectedStep({...step})

            // Optional: load lại task nếu bạn muốn đảm bảo sau khi thêm sẽ update danh sách
            const dataFilter = {}
            if (String(user.role_id) === '3') {
                dataFilter.assigned_to = user.id
            } else if (String(user.role_id) === '2') {
                dataFilter.id_department = user.department_id
            }

            getTasksByBiddingStep(step.id, dataFilter)
                .then(res => {
                    stepStore.setRelatedTasks(Array.isArray(res.data) ? res.data : [])
                })
                .catch(() => {
                    stepStore.setRelatedTasks([])
                })
        }

        openDrawer.value = true
    }


    const handleDrawerSubmit = async () => {
        const user = userStore.currentUser
        const dataFilter = {}

        if (String(user?.role_id) === '3') {
            dataFilter.assigned_to = user.id
        } else if (String(user?.role_id) === '2') {
            dataFilter.id_department = user.department_id
        }

        if (stepStore.selectedStep?.id) {
            try {
                // ⏳ Đợi một chút để backend hoàn tất insert (nếu cần)
                await new Promise(resolve => setTimeout(resolve, 500))

                // 🧪 In log rõ ràng
                console.log('🔍 Fetching tasks after submit with:', {
                    stepId: stepStore.selectedStep.id,
                    dataFilter
                })

                const res = await getTasksByBiddingStep(stepStore.selectedStep.id, dataFilter)
                console.log('res', res)

                const tasks = Array.isArray(res.data)
                    ? res.data
                    : Array.isArray(res.data?.data)
                        ? res.data.data
                        : []

                console.log('📦 Tasks fetched:', tasks)

                stepStore.setRelatedTasks(tasks)


                await fetchSteps()

                setTimeout(() => {
                    console.log('✅ Tasks trong store:', stepStore.relatedTasks)
                }, 300)

            } catch (err) {
                console.error('❌ Không thể load task sau khi tạo:', err)
                message.error('Không thể tải danh sách công việc sau khi tạo')
            }
        }
    }

    const getInternalTask = async () => {
        loading.value = true
        try {
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

    const showEditTitle = ref(false)
    const editedTitle = ref('')

    const editTitle = () => {
        editedTitle.value = selectedStep.value.title || ''
        showEditTitle.value = true
    }

    // Hàm cập nhật tiêu đề bước
    const updateStepTitle = async () => {
        if (editedTitle.value.trim() === '') {
            message.warning('Tiêu đề không được để trống')
            return
        }

        try {
            await updateBiddingStepAPI(selectedStep.value.id, {
                title: editedTitle.value.trim()
            })
            selectedStep.value.title = editedTitle.value.trim()
            message.success('Cập nhật tiêu đề thành công')
            showEditTitle.value = false
            await fetchSteps()
        } catch (e) {
            console.error('Không thể cập nhật tiêu đề bước', e)
            message.error('Lỗi khi cập nhật tiêu đề')
        }
    }


    const updateStepEndDate = async (value, option) => {
        selectedStep.value.end_date = value.format('YYYY-MM-DD')
        try {
            await updateBiddingStepAPI(selectedStep.value.id, {end_date: selectedStep.value.end_date})
            message.success('Cập nhật ngày kết thúc thành công')
            showEditDateEnd.value = false
            await fetchSteps()
        } catch (e) {
            console.log('e', e)
            const msg = 'Không thể cập nhật ngày kết thúc'
            message.error(msg)
            console.warn('Lỗi cập nhật ngày kết thúc:', msg)
        }
    }
    const disabledDate = current => {
        return current && current < dayjs(selectedStep.value.start_date).endOf('day');
    };

    const openStepDrawer = async (step) => {
        selectedStep.value = {...step}
        stepStore.setSelectedStep({...step})
        activeStepId.value = step.id // 👈 đánh dấu bước đang mở
        drawerVisible.value = true

        const dataFilter = {}

        console.log('user', user)

        if (String(user.role_id) === '3') {
            // Nhân viên → chỉ xem nhiệm vụ của mình
            dataFilter.assigned_to = user.id
        } else if (String(user.role_id) === '2') {
            // Trưởng phòng → xem được nhiệm vụ của cả phòng
            dataFilter.id_department = user.department_id
        }

        console.log('dataFilter', dataFilter)
        try {
            const res = await getTasksByBiddingStep(step.id, dataFilter)
            stepStore.setRelatedTasks(Array.isArray(res.data) ? res.data : [])
        } catch (e) {
            console.error('❌ Không thể tải công việc của bước', e)
            stepStore.setRelatedTasks([])
        }
    }


    const closeDrawer = () => {
        drawerVisible.value = false
        activeStepId.value = null
        showEditDateStart.value = false
        showEditDateEnd.value = false
        dateStart.value = null
        dateEnd.value = null
    }
    const getStatusColor = (status) => {
        const map = {
            0: 'orange',   // Chưa nộp
            1: 'blue',     // Đã nộp
            2: 'purple',   // Vào vòng sau
            3: 'green',    // Trúng thầu
            4: 'red',      // Không trúng
            5: 'gray'      // Hủy
        }
        return map[status] || 'default'
    }

    const statusText = (status) => {
        return {
            '0': 'Chưa bắt đầu',
            '1': 'Đang xử lý',
            '2': 'Đã hoàn thành',
            '3': 'Bỏ qua',
        }[status] || 'Không rõ'
    }

    const getApprovalStatusText = (status) => {
        switch (status) {
            case 'approved':
                return 'Đã duyệt';
            case 'pending':
                return 'Chờ duyệt';
            case 'rejected':
                return 'Từ chối';
            default:
                return 'Không rõ';
        }
    }

    const getApprovalStatusColor = (status) => {
        switch (status) {
            case 'approved':
                return 'green';
            case 'pending':
                return 'blue';
            case 'rejected':
                return 'red';
            default:
                return 'gray';
        }

    }

    const lastCompletedIndex = () => {
        for (let i = steps.value.length - 1; i >= 0; i--) {
            if (steps.value[i].status === '2') return i
        }
        return -1
    }

    const getStepStatusColor = (status) => {
        return {
            '0': 'default',
            '1': 'blue',
            '2': 'green',
            '3': 'orange',
        }[status] || 'default'
    }

    const mapStepStatus = (status) => {
        return {
            '0': 'wait',
            '1': 'process',
            '2': 'finish',
            '3': 'error',
        }[status] || 'wait'
    }

    const currentStepIndex = () => {
        const last = lastCompletedIndex()
        const next = last + 1
        return next >= steps.value.length ? steps.value.length - 1 : next
    }

    const parseDepartment = (val) => {
        try {
            const parsed = JSON.parse(val)
            return Array.isArray(parsed) ? parsed : [val]
        } catch (e) {
            return val ? [val] : []
        }
    }


    const getTaskStatusText = (status) => ({
        todo: 'Chưa bắt đầu',
        doing: 'Đang làm',
        done: 'Hoàn thành',
        overdue: 'Trễ hạn'
    }[status] || 'Không rõ')

    const getTaskStatusColor = (status) => ({
        todo: 'default',
        doing: 'blue',
        done: 'green',
        overdue: 'red'
    }[status] || 'default')

    const updateStepStatus = async (newStatus, step) => {
        try {
            if (newStatus === '2') {
                await completeBiddingStepAPI(step.id)
                message.success('Bước đã hoàn thành và bước kế tiếp đã được mở')
            } else {
                await updateBiddingStepAPI(step.id, {status: newStatus})
                message.success('Đã cập nhật trạng thái bước')
            }

            drawerVisible.value = false
            await fetchData()
        } catch (e) {
            console.warn('⚠️ Lỗi cập nhật bước:', e)

            // Ưu tiên lấy thông báo cụ thể từ server nếu có
            const errMsg =
                e?.response?.data?.messages?.error || // CodeIgniter 4 style
                e?.response?.data?.message ||         // Generic REST error
                '❌ Đã xảy ra lỗi khi cập nhật bước'

            if (e?.response?.status === 400) {
                message.warning(errMsg) // Lỗi logic (ví dụ: chưa hoàn thành bước trước)
            } else {
                message.error(errMsg)   // Lỗi nghiêm trọng (server, network,...)
            }
        }
    }

    const updateStepDate = async (field, date, step) => {
        try {
            const payload = {[field]: date ? date.format('YYYY-MM-DD') : null}
            await updateBiddingStepAPI(step.id, payload)
            message.success(`Đã cập nhật ${field === 'start_date' ? 'ngày bắt đầu' : 'ngày kết thúc'}`)
            await fetchSteps()
        } catch (e) {
            console.error(`Lỗi cập nhật ${field}:`, e)
            message.error(`Không thể cập nhật ${field}`)
        }
    }

    const fetchUsers = async () => {
        try {
            const res = await getUsers()
            users.value = res.data;
        } catch (e) {
            console.error('Không thể tải danh sách người dùng:', e)
        }
    }

    const getAssignedUserName = (userId) => {
        if (!userId || !users.value.length) return 'Không xác định'
        const found = users.value.find(u => String(u.id) === String(userId))
        return found?.name || `Người dùng #${userId}`
    }

    const goToUserDetail = (userId) => {
        if (!userId) return
        router.push({name: 'user-detail', params: {id: userId}})
    }


    const fetchSteps = async () => {
        try {
            loadingSteps.value = true
            const stepRes = await getBiddingStepsAPI(id)
            steps.value = stepRes.data.filter(step => step.bidding_id === id)
        } catch (e) {
            console.error('Lỗi khi tải bước:', e)
            message.error('Không thể tải tiến trình xử lý')
        } finally {
            loadingSteps.value = false
        }
    }


    const updateStepAssignedTo = async (userId, step) => {
        try {
            if (!userId) {
                message.warning('Vui lòng chọn người phụ trách hợp lệ')
                return
            }

            await updateBiddingStepAPI(step.id, {assigned_to: userId})
            message.success('Đã cập nhật người phụ trách')
            await fetchSteps()
        } catch (e) {
            console.error('Lỗi khi cập nhật người phụ trách:', e)
            const msg =
                e?.response?.data?.messages?.error ||
                e?.response?.data?.message ||
                'Cập nhật người phụ trách thất bại'
            message.error(msg)
        }
    }


    const goToCustomerDetail = (customerId) => {
        if (!customerId) return
        router.push({name: 'customer-detail', params: {id: customerId.toString()}})
    }

    const fetchCustomers = async () => {
        try {
            const res = await getCustomers()
            customers.value = res.data?.data || [] // fix ở đây
        } catch (e) {
            console.error(e)
            message.error('Không thể tải danh sách khách hàng')
        }
    }

    const getCustomerName = (id) => {
        if (!id || !customers.value.length) return 'Đang tải...'
        const customer = customers.value.find(c => String(c.id) === String(id))
        return customer ? customer.name : `Khách hàng #${id}`
    }


    const fetchData = async () => {
        try {
            const res = await getBiddingAPI(id)
            bidding.value = res.data

            loadingSteps.value = true
            let stepRes = await getBiddingStepsAPI(id)

            if (!stepRes.data?.length) {
                await cloneFromTemplatesAPI(id)
                stepRes = await getBiddingStepsAPI(id)
            }

            steps.value = stepRes.data.filter((step) => step.bidding_id === id)
        } catch (e) {
            console.error(e)
            message.error('Không thể tải dữ liệu')
        } finally {
            loadingSteps.value = false
        }
    }

    const getStatusText = (status) => {
        const map = {
            0: 'Chưa nộp',
            1: 'Đã nộp hồ sơ',
            2: 'Vào vòng sau',
            3: 'Đã trúng thầu',
            4: 'Không trúng',
            5: 'Hủy thầu',
        }
        return map[status] ?? `Không rõ`
    }
    const goBack = () => {
        if (window.history.length > 1) {
            router.back();
        } else {
            router.push('/bid-list'); // fallback nếu không có trang trước
        }
    }

    onMounted(async () => {
        await Promise.all([
            fetchData(),
            fetchCustomers(),
            fetchUsers()
        ])
    })

</script>

<style>
    .active-step-title .ant-statistic-content span {
        color: #FFFFFF;
    }
</style>

<style scoped>
    .active-step-title {
        background-color: #91d5ff;
        border-radius: 4px;
        padding: 0 8px;
    }

    .active-step-title span {
        color: #ffffff !important;
    }

    .step-actions {
        margin-top: 12px;
        text-align: right;
    }

    .ant-steps-item-title {
        color: rgba(0, 0, 0, 0.85) !important;
        font-weight: 500;
        cursor: pointer;
    }

    .mt-30 {
        margin-top: 30px;
    }

    .mb-30 {
        margin-bottom: 30px;
    }

    .ant-list-items li {
        padding-left: 0;
        padding-right: 0;
    }
</style>
