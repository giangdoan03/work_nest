<template>
    <a-card title="Hồ sơ cần duyệt" :bordered="true">
        <template #extra>
            <a-space>
                <a-input
                    v-model:value="query.q"
                    allowClear
                    placeholder="Tìm theo tên tài liệu / người gửi"
                    style="width: 260px"
                    @pressEnter="reload()"
                />
                <a-segmented
                    v-model:value="tab"
                    :options="[
            { label: 'Chờ duyệt', value: 'pending' },
            { label: 'Đã xử lý', value: 'resolved' }
          ]"
                    @change="reload"
                />
                <a-button @click="reload()" :loading="loading" type="default">Làm mới</a-button>
            </a-space>
        </template>

        <a-table
            :data-source="rows"
            :columns="columns"
            :loading="loading"
            row-key="rowKey"
            :pagination="pagination"
            @change="handleTableChange"
        >
            <!-- Ô tiêu chuẩn cho mọi cột -->
            <template #bodyCell="{ column, record }">
                <!-- Tên tài liệu -->
                <template v-if="column.key === 'name'">
                    <div class="file-name">
                        <a-typography-text strong :title="record.name">{{ record.name }}</a-typography-text>
                        <div class="muted" v-if="record.task_title">Thuộc task: {{ record.task_title }}</div>
                    </div>
                </template>

                <!-- Người gửi -->
                <template v-else-if="column.key === 'sender'">
                    <a-space>
                        <user-outlined/>
                        <span :title="record.sender_name">{{ record.sender_name }}</span>
                    </a-space>
                    <div class="muted">{{ formatDateTime(record.created_at) }}</div>
                </template>

                <!-- Trạng thái -->
                <template v-else-if="column.key === 'status'">
                    <a-tag v-if="record.status==='pending'" color="gold">Đang chờ bạn</a-tag>
                    <a-tag v-else-if="record.status==='approved'" color="green">Đã duyệt</a-tag>
                    <a-tag v-else-if="record.status==='rejected'" color="red">Đã từ chối</a-tag>
                    <div class="muted" v-if="record.step_info">
                        Bước {{ record.step_info.sequence }} · {{ record.step_info._approver_name }}
                    </div>
                </template>

                <!-- Hành động -->
                <template v-else-if="column.key === 'actions'">
                    <a-space>
                        <a-tooltip title="Xem trước">
                            <a-button size="small" shape="circle" @click="preview(record)">
                                <eye-outlined/>
                            </a-button>
                        </a-tooltip>
                        <a-tooltip title="Tải xuống / mở">
                            <a-button size="small" shape="circle" @click="download(record)">
                                <download-outlined/>
                            </a-button>
                        </a-tooltip>
                        <template v-if="tab==='pending'">
                            <a-button size="small" type="primary" :loading="acting[record.approval_id]==='approve'"
                                      @click="openApprove(record)">Duyệt
                            </a-button>
                            <a-button size="small" danger :loading="acting[record.approval_id]==='reject'"
                                      @click="openReject(record)">Từ chối
                            </a-button>
                        </template>
                    </a-space>
                </template>
            </template>
        </a-table>

    </a-card>

    <!-- Modal xác nhận duyệt -->
    <a-modal v-model:open="modals.approve.open" title="Xác nhận duyệt tài liệu"
             okText="Duyệt" :okButtonProps="{ type: 'primary' }"
             :confirm-loading="modals.approve.loading"
             @ok="submitApprove" @cancel="closeApprove">
        <p><strong>{{ modals.approve.record?.name }}</strong></p>
        <a-textarea v-model:value="modals.approve.comment" :rows="3" placeholder="Ghi chú (tuỳ chọn)"/>
    </a-modal>

    <!-- Modal từ chối -->
    <a-modal v-model:open="modals.reject.open" title="Từ chối tài liệu"
             okText="Từ chối" :okButtonProps="{ danger: true }"
             :confirm-loading="modals.reject.loading"
             @ok="submitReject" @cancel="closeReject">
        <p><strong>{{ modals.reject.record?.name }}</strong></p>
        <a-textarea v-model:value="modals.reject.comment" :rows="3" placeholder="Lý do từ chối (khuyến nghị)"/>
    </a-modal>
</template>

<script setup>
import {
    EyeOutlined, DownloadOutlined, UserOutlined
} from '@ant-design/icons-vue'
import {ref, reactive, onMounted} from 'vue'
import {message} from 'ant-design-vue'
import dayjs from 'dayjs'
import {openPreviewFile} from '@/utils/formUtils';

import {useUserStore} from '@/stores/user'

const store = useUserStore()

// APIs
import {getMyPendingFilesAPI, getMyResolvedFilesAPI, actOnApprovalAPI} from '@/api/taskFiles'

const table = ref({
    data: [],
    total: 0,
    loading: false,
    page: 1,
    pageSize: 10,
})
const activeTab = ref('pending') // ví dụ có tab chờ duyệt / đã xử lý

const props = defineProps({
    mySignatureUrl: {type: String, default: ''}   // ← khai báo prop
})// thêm file nhỏ export API act

// ------------- state -------------
const tab = ref('pending')
const loading = ref(false)
const rows = ref([])
const acting = reactive({}) // { [approval_id]: 'approve' | 'reject' | null }

const pagination = reactive({
    page: 1,
    pageSize: 10,
    total: 0,
})

const query = reactive({
    q: ''
})

const columns = [
    {title: 'Tài liệu', dataIndex: 'name', key: 'name'},
    {title: 'Người gửi', dataIndex: 'sender', key: 'sender', width: 220},
    {title: 'Trạng thái', key: 'status', width: 180},
    {title: 'Thao tác', key: 'actions', width: 240},
]

// ------------- helpers -------------
const rowKey = r => `${r.source}:${r.approval_id || r.id}`
const formatDateTime = s => s ? dayjs(s).format('HH:mm DD/MM/YYYY') : ''


async function reloadList() {
    table.value.loading = true
    try {
        const params = {page: table.value.page, pageSize: table.value.pageSize, user_id: store.currentUser.id}
        let res
        if (activeTab.value === 'pending') {
            res = await getMyPendingFilesAPI(params)
        } else {
            res = await getMyResolvedFilesAPI(params)
        }
        table.value.data = res.data.items || []
        table.value.total = res.data.total || 0
    } catch (e) {
        message.error(e?.response?.data?.message || 'Không tải được danh sách.')
    } finally {
        table.value.loading = false
    }
}


function mapApiRow(r) {
    // Chuẩn hoá record để render thống nhất
    return {
        rowKey: rowKey(r),
        approval_id: Number(r.approval_id ?? r.id),   // id phê duyệt/instance/step
        document_id: Number(r.document_id ?? r.task_file_id ?? r.file_id),
        name: r.file_name || r.name || r.title || '(Không tên)',
        file_url: r.file_url || r.url || r.file_path || '',
        task_title: r.task_title || r.task_name || null,
        sender_name: r.created_by_name || r.owner_name || r.sender_name || '—',
        created_at: r.created_at,
        status: String(r.status || 'pending'),
        step_info: r.steps?.[0] || r.step || null,    // nếu API trả steps
    }
}

// ------------- data fetch -------------
async function reload() {
    loading.value = true
    try {
        const params = {
            page: pagination.page,
            pageSize: pagination.pageSize,
            q: query.q || undefined,
        }
        const api = tab.value === 'pending' ? getMyPendingFilesAPI : getMyResolvedFilesAPI
        const {data} = await api(params)

        const list = Array.isArray(data?.items) ? data.items : (data?.data || [])
        const total = Number(data?.total ?? data?.pagination?.total ?? list.length)

        rows.value = list.map(mapApiRow)
        pagination.total = total
    } catch (e) {
        message.error(e?.response?.data?.message || 'Không tải được danh sách duyệt.')
    } finally {
        loading.value = false
    }
}




function handleTableChange({current, pageSize}) {
    pagination.page = current
    pagination.pageSize = pageSize
    reload()
}

// ------------- actions -------------
function preview(rec) {
    openPreviewFile(rec);
}

function download(rec) {
    if (!rec?.file_url) return
    window.open(rec.file_url, '_blank', 'noopener')
}

// Approve
const modals = reactive({
    approve: {open: false, loading: false, comment: '', record: null},
    reject: {open: false, loading: false, comment: '', record: null}
})

function openApprove(rec) {
    modals.approve.record = rec
    modals.approve.comment = ''
    modals.approve.open = true
}

function closeApprove() {
    modals.approve.open = false
    modals.approve.record = null
    modals.approve.comment = ''
}

async function submitApprove() {
    try {
        modals.approve.loading = true
        const record = modals.approve.record

        await actOnApprovalAPI(record.approval_id, {
            action: 'approve',
            comment: modals.approve.comment,
        })

        message.success('Đã duyệt tài liệu.')
        modals.approve.open = false
        await reloadList() // nếu bạn có hàm load danh sách
    } catch (e) {
        message.error(e?.response?.data?.messages?.error || 'Duyệt thất bại')
    } finally {
        modals.approve.loading = false
    }
}


// Reject
function openReject(rec) {
    modals.reject.record = rec
    modals.reject.comment = ''
    modals.reject.open = true
}

function closeReject() {
    modals.reject.open = false
    modals.reject.record = null
    modals.reject.comment = ''
}

async function submitReject() {
    try {
        modals.reject.loading = true
        const record = modals.reject.record

        await actOnApprovalAPI(record.approval_id, {
            action: 'reject',
            comment: modals.reject.comment,
        })

        message.success('⛔ Đã từ chối tài liệu.')
        modals.reject.open = false
        await reloadList()
    } catch (e) {
        message.error(e?.response?.data?.messages?.error || 'Từ chối thất bại')
    } finally {
        modals.reject.loading = false
    }
}

// ------------- lifecycle -------------
onMounted(reload)
</script>

<style scoped>
.file-name .muted,
.muted {
    color: #999;
    font-size: 12px;
}
</style>
