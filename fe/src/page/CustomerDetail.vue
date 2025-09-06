<template>
    <a-card bordered>
        <!-- Header -->
        <a-page-header
            class="ph"
            :title="customer?.name || 'Chi tiết khách hàng'"
            @back="$router.back()"
        >
            <template #tags>
                <a-tag v-if="customer" :color="groupColor(customer.customer_group)">
                    {{ groupLabel(customer.customer_group) }}
                </a-tag>
                <a-tag v-if="assigneeName" color="blue">
                    <TeamOutlined /> {{ assigneeName }}
                </a-tag>
            </template>
            <template #extra>
                <a-space>
                    <a-button @click="refresh" :loading="loading">Làm mới</a-button>
                    <a-popconfirm
                        title="Bạn chắc chắn muốn xóa khách hàng này?"
                        ok-text="Xóa"
                        cancel-text="Hủy"
                        @confirm="deleteConfirm"
                    >
                        <a-button danger> Xóa </a-button>
                    </a-popconfirm>
                </a-space>
            </template>

            <!-- Quick stats -->
            <div class="stats">
                <a-card size="small" class="stat">
                    <div class="stat-label">Tương tác</div>
                    <div class="stat-value">{{ interactionLogs.length }}</div>
                </a-card>
                <a-card size="small" class="stat">
                    <div class="stat-label">Hợp đồng</div>
                    <div class="stat-value">{{ contracts.length }}</div>
                </a-card>
                <a-card size="small" class="stat">
                    <div class="stat-label">Gần nhất</div>
                    <div class="stat-value">{{ lastInteractionFromNow }}</div>
                </a-card>
            </div>
        </a-page-header>

        <!-- Content -->
        <a-spin :spinning="loading && !customer">
            <a-tabs v-if="customer" v-model:activeKey="activeTab" animated>
                <!-- Tổng quan -->
                <a-tab-pane key="overview" tab="Tổng quan">
                    <a-descriptions bordered :column="2" size="middle" class="desc">
                        <a-descriptions-item label="Tên khách hàng">
                            <a-typography-text strong>{{ customer.name || '—' }}</a-typography-text>
                        </a-descriptions-item>
                        <a-descriptions-item label="Người phụ trách">
                            <a-tag v-if="assigneeName" color="blue">{{ assigneeName }}</a-tag>
                            <span v-else>—</span>
                        </a-descriptions-item>

                        <a-descriptions-item label="Email">
                            <a-typography-text :copyable="!!customer.email">
                                <a :href="customer.email ? `mailto:${customer.email}` : undefined">{{ customer.email || '—' }}</a>
                            </a-typography-text>
                        </a-descriptions-item>
                        <a-descriptions-item label="Số điện thoại">
                            <a-typography-text :copyable="!!customer.phone">
                                <a :href="customer.phone ? `tel:${customer.phone}` : undefined">{{ customer.phone || '—' }}</a>
                            </a-typography-text>
                        </a-descriptions-item>

                        <a-descriptions-item label="Địa chỉ" :span="2">
                            <a-typography-text>{{ customer.address || '—' }}</a-typography-text>
                        </a-descriptions-item>
                    </a-descriptions>
                </a-tab-pane>

                <!-- Tương tác -->
                <a-tab-pane key="interactions" tab="Tương tác">
                    <a-skeleton :loading="loadingInteractions" active :paragraph="{ rows: 5 }">
                        <a-empty v-if="!interactionLogs.length" description="Chưa có tương tác" />
                        <a-timeline v-else>
                            <a-timeline-item v-for="it in interactionLogs" :key="it.id">
                                <div class="tl-title">
                                    <a-tag>{{ (it.type || '').toUpperCase() }}</a-tag>
                                    <span class="tl-time" :title="formatDate(it.interaction_time)">
                    {{ fromNow(it.interaction_time) }}
                  </span>
                                </div>
                                <div class="tl-content">{{ it.content }}</div>
                            </a-timeline-item>
                        </a-timeline>
                    </a-skeleton>
                </a-tab-pane>

                <!-- Hợp đồng -->
                <a-tab-pane key="contracts" tab="Hợp đồng">
                    <a-skeleton :loading="loadingContracts" active :paragraph="{ rows: 4 }">
                        <a-empty v-if="!contracts.length" description="Chưa có hợp đồng" />
                        <a-list v-else :data-source="contracts" item-layout="vertical" bordered>
                            <template #renderItem="{ item }">
                                <a-list-item>
                                    <a-list-item-meta
                                        :title="item.title"
                                        :description="`Trạng thái: ${item.status || '—'} • ${formatDate(item.start_date)} → ${formatDate(item.end_date)}`"
                                    />
                                    <div>{{ item.content || '' }}</div>
                                </a-list-item>
                            </template>
                        </a-list>
                    </a-skeleton>
                </a-tab-pane>
            </a-tabs>

            <a-result v-else status="warning" title="Không tìm thấy khách hàng" />
        </a-spin>
    </a-card>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/vi'
dayjs.extend(relativeTime); dayjs.locale('vi')

import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import {
    getCustomer,
    getCustomerTransactions,
    getCustomerContracts,
    deleteCustomer
} from '@/api/customer'
import { getUsers } from '@/api/user'
import { TeamOutlined } from '@ant-design/icons-vue'

/* ===== route / state ===== */
const route = useRoute()
const router = useRouter()
const id = computed(() => route.params.id)

const customer = ref(null)
const loading = ref(false)

const interactionLogs = ref([])
const loadingInteractions = ref(false)

const contracts = ref([])
const loadingContracts = ref(false)

const users = ref([])
const activeTab = ref('overview')

/* ===== helpers ===== */
const formatDate = (v) => v ? dayjs(v).format('DD/MM/YYYY HH:mm') : '—'
const fromNow = (v) => v ? dayjs(v).fromNow() : '—'

const lastInteractionFromNow = computed(() => {
    const t = customer.value?.last_interaction
    return t ? fromNow(t) : '—'
})

const assigneeName = computed(() => {
    const uid = Number(customer.value?.assigned_to)
    return users.value.find(u => Number(u.id) === uid)?.name
})

const groupColor = (g) => g === 'vip' ? 'gold' : 'default'
const groupLabel = (g) => g === 'vip' ? 'VIP' : 'Đối tác thường'

/* ===== fetchers ===== */
const fetchCustomer = async () => {
    if (!id.value) {
        message.error('Không có ID khách hàng'); return
    }
    loading.value = true
    try {
        const res = await getCustomer(id.value)
        // API của bạn có thể trả { data: {...} } hoặc {...}
        customer.value = res?.data?.data ?? res?.data ?? null
    } catch {
        customer.value = null
        message.error('Không tìm thấy khách hàng')
    } finally {
        loading.value = false
    }
}

const fetchInteractions = async () => {
    if (!id.value) return
    loadingInteractions.value = true
    try {
        const res = await getCustomerTransactions(id.value)
        interactionLogs.value = res?.data || []
    } catch {
        interactionLogs.value = []
    } finally {
        loadingInteractions.value = false
    }
}

const fetchContracts = async () => {
    if (!id.value) return
    loadingContracts.value = true
    try {
        const res = await getCustomerContracts(id.value)
        contracts.value = Array.isArray(res?.data?.data) ? res.data.data : []
    } catch {
        contracts.value = []
    } finally {
        loadingContracts.value = false
    }
}

const fetchUsers = async () => {
    try {
        const res = await getUsers()
        users.value = res?.data || []
    } catch { users.value = [] }
}

/* ===== actions ===== */
const refresh = async () => {
    await Promise.all([fetchCustomer(), fetchInteractions(), fetchContracts()])
}

const deleteConfirm = async () => {
    if (!id.value) return
    try {
        await deleteCustomer(id.value)
        message.success('Đã xóa khách hàng')
        router.back()
    } catch {
        message.error('Không thể xóa khách hàng')
    }
}

/* ===== init & watch ===== */
onMounted(async () => {
    await Promise.all([fetchUsers(), refresh()])
})

watch(() => id.value, async () => {
    await refresh()
})
</script>

<style scoped>
.ph { padding-left: 10px; padding-top: 0; }
.stats{
    display:flex; gap:12px; flex-wrap:wrap; margin-top:8px;
}
.stat{
    width: 180px;
}
.stat-label{ font-size:12px; color:#888; }
.stat-value{ font-size:20px; font-weight:700; color:#111; }

.desc{ margin-top: 8px; }
.tl-title{ display:flex; align-items:center; gap:8px; }
.tl-time{ color:#999; font-size:12px; }
.tl-content{ margin-top:4px; white-space:pre-wrap; }

:deep(.ant-list-item){ padding: 12px 16px; }
</style>
