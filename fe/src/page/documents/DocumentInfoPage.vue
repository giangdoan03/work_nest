<template>
    <div class="doc-container">

        <!-- HEADER -->
        <div class="doc-header">

            <!-- LEFT -->
            <div class="header-left">
                <a-button class="back-btn" @click="$router.back()">
                    ← Quay lại
                </a-button>

                <div class="title-box">
                    <h2 class="doc-title">{{ doc.title }}</h2>
                    <p class="doc-subtitle">{{ doc.department_name }}</p>
                </div>
            </div>

            <!-- RIGHT -->
            <div class="doc-actions">
                <a-button @click="openInNewTab">Mở tab mới</a-button>
                <a-button type="primary" @click="downloadFile">Tải xuống</a-button>
            </div>
        </div>


        <!-- INFORMATION CARD -->
        <a-card class="info-card">
            <a-descriptions bordered size="middle" :column="2">
                <a-descriptions-item label="Phòng ban">{{ doc.department_name }}</a-descriptions-item>
                <a-descriptions-item label="Người tạo">{{ creatorName }}</a-descriptions-item>
                <a-descriptions-item label="Ngày tạo">{{ formatDate(doc.created_at) }}</a-descriptions-item>
                <a-descriptions-item label="Số người được cấp quyền">
                    {{ doc.allowed_users?.length || 0 }}
                </a-descriptions-item>
            </a-descriptions>
        </a-card>

        <!-- ACCESS LIST CARD -->
        <a-card
            v-if="doc.allowed_users?.length"
            title="Người được cấp quyền"
            class="access-card"
        >
            <a-avatar-group>
                <template v-for="uid in doc.allowed_users" :key="uid">
                    <a-tooltip :title="getUserName(uid)">
                        <BaseAvatar
                            :src="getUser(uid)?.avatar"
                            :name="getUser(uid)?.name"
                            :size="36"
                            shape="circle"
                            :preferApiOrigin="true"
                        />
                    </a-tooltip>
                </template>
            </a-avatar-group>
        </a-card>


    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue"
import { useRoute } from "vue-router"
import { message } from "ant-design-vue"
import { getDocument } from "@/api/docs"
import { getUsers } from "@/api/user"
import dayjs from "dayjs"
import BaseAvatar from '../../components/common/BaseAvatar.vue'
const route = useRoute()
const doc = ref({})
const users = ref([])
const getUser = (id) => users.value.find(u => u.id == id)

const formatDate = d => d ? dayjs(d).format("DD/MM/YYYY HH:mm") : "—"

onMounted(async () => {
    try {
        const id = route.params.id
        const res = await getDocument(id)
        doc.value = res.data

        const u = await getUsers()
        users.value = u.data
    } catch (e) {
        message.error("Không tải được tài liệu")
    }
})

const getUserName = id => {
    const u = users.value.find(x => x.id == id)
    return u ? u.name : "Không rõ"
}

const getInitial = name =>
    name ? name.trim().charAt(0).toUpperCase() : "?"

const creatorName = computed(() =>
    getUserName(doc.value.created_by)
)

const openInNewTab = () => window.open(doc.value.file_url, "_blank")
const downloadFile = () => window.open(doc.value.file_url, "_blank")
</script>

<style scoped>
/* Container */
.doc-container {
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
}

/* HEADER */
/* HEADER improved layout */
.header-left {
    display: flex;
    align-items: center;
    gap: 16px;
}

.back-btn {
    display: flex;
    align-items: center;
    font-size: 14px;
}

.title-box {
    display: flex;
    flex-direction: column;
}

.doc-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 18px;
}

.doc-title {
    margin: 0;
    font-size: 26px;
    font-weight: 600;
}

.doc-subtitle {
    margin: 0;
    margin-top: 4px;
    font-size: 14px;
    color: #888;
}

/* ACTION BUTTONS */
.doc-actions {
    display: flex;
    gap: 10px;
}

/* INFO CARD */
.info-card {
    margin-bottom: 20px;
    border-radius: 8px;
}

/* ACCESS CARD */
.access-card {
    border-radius: 8px;
}

/* Avatar spacing */
a-avatar {
    margin-right: 4px;
}
</style>
