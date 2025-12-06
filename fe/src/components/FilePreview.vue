<template>
    <div class="doc-detail">

        <!-- HEADER -->
        <div class="doc-header">
            <h2 class="doc-title">{{ doc.title }}</h2>

            <div class="doc-actions">
                <a-button @click="openInNewTab">Mở trong tab mới</a-button>
                <a-button type="primary" @click="downloadFile">Tải xuống</a-button>
            </div>
        </div>

        <!-- INFO BLOCK -->
        <div class="doc-meta">
            <div><b>Phòng ban:</b> {{ doc.department_name }}</div>
            <div><b>Người tạo:</b> {{ creatorName }}</div>
            <div><b>Ngày tạo:</b> {{ formatDate(doc.created_at) }}</div>
            <div><b>Số người được cấp quyền:</b> {{ doc.allowed_users?.length || 0 }}</div>
        </div>

        <!-- ACCESS LIST -->
        <div class="doc-access" v-if="doc.allowed_users?.length">
            <b>Người được cấp quyền:</b>
            <a-avatar-group max-count="8">
                <template v-for="uid in doc.allowed_users" :key="uid">
                    <a-tooltip :title="getUserName(uid)">
                        <a-avatar>{{ getInitial(getUserName(uid)) }}</a-avatar>
                    </a-tooltip>
                </template>
            </a-avatar-group>
        </div>

    </div>

</template>

<script setup>
import { ref, computed, onMounted } from "vue"
import { useRoute } from "vue-router"
import { message } from "ant-design-vue"
import FilePreview from "@/components/FilePreview.vue"
import { getDocument } from "@/api/docs"
import { getUsers } from "@/api/user"
import dayjs from "dayjs"

const route = useRoute()
const doc = ref({})
const users = ref([])

const formatDate = (d) => d ? dayjs(d).format("DD/MM/YYYY HH:mm") : "—"

onMounted(async () => {
    try {
        const id = route.params.id
        const res = await getDocument(id)
        doc.value = res.data

        const u = await getUsers()
        users.value = u.data
    } catch {
        message.error("Không tải được tài liệu")
    }
})

const getUserName = (id) => {
    const u = users.value.find(x => x.id == id)
    return u ? u.name : "Không rõ"
}

const getInitial = (name) =>
    name ? name.trim().charAt(0).toUpperCase() : "?"

const creatorName = computed(() =>
    getUserName(doc.value.created_by)
)

const openInNewTab = () => window.open(doc.value.file_url, "_blank")
const downloadFile = () => window.open(doc.value.file_url, "_blank")

</script>

<style scoped>
.doc-detail {
    max-width: 1000px;
    margin: 0 auto;
    padding: 20px 12px;
}

.doc-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.doc-title {
    margin: 0;
    font-size: 24px;
    font-weight: 600;
}

.doc-meta {
    background: #fafafa;
    padding: 12px 16px;
    border-radius: 6px;
    margin-top: 12px;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
    row-gap: 6px;
}

.doc-access {
    margin-top: 16px;
    padding: 12px 16px;
    background: #fff;
    border-left: 3px solid #1677ff;
    border-radius: 4px;
}

.doc-preview-wrapper {
    margin-top: 20px;
    border: 1px solid #eee;
    border-radius: 6px;
    overflow: hidden;
}

</style>
