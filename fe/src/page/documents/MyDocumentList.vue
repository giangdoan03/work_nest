<template>
    <div>
        <a-card bordered style="margin-bottom: 16px">
            <a-flex justify="space-between" align="center">

                <a-space align="center" size="middle">
                    <a-typography-title :level="4" style="margin:0;">
                        Tài liệu của tôi
                    </a-typography-title>
                </a-space>

                <a-space>
                    <a-input
                        v-model:value="searchText"
                        placeholder="Tìm kiếm tài liệu"
                        allow-clear
                        style="width:260px"
                        @input="debouncedSearch"
                    >
                        <template #prefix><SearchOutlined /></template>
                    </a-input>
                </a-space>

            </a-flex>
        </a-card>

        <a-card bordered>
            <a-table
                :columns="columns"
                :data-source="tableData"
                :loading="loading"
                row-key="id"
                :pagination="pagination"
                @change="handleTableChange"
            >
                <template #bodyCell="{column, record}">
                    <template v-if="column.dataIndex === 'title'">
                        <a-typography-text strong style="cursor:pointer"
                                           @click="openDetail(record)">
                            {{ record.title }}
                        </a-typography-text>
                    </template>

                    <template v-else-if="column.dataIndex === 'department'">
                        {{ getDeptName(record.department_id) }}
                    </template>

                    <template v-else-if="column.dataIndex === 'allowed_users'">
                        <a-avatar-group>
                            <template v-for="uid in record.allowed_users" :key="uid">
                                <a-tooltip :title="getUserName(uid)">
                                    <BaseAvatar
                                        :src="getUser(uid)?.avatar"
                                        :name="getUser(uid)?.name"
                                        :size="32"
                                    />
                                </a-tooltip>
                            </template>
                        </a-avatar-group>
                    </template>
                </template>
            </a-table>
        </a-card>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { SearchOutlined } from "@ant-design/icons-vue";
import BaseAvatar from "@/components/common/BaseAvatar.vue";
import { getDocuments } from "@/api/docs";
import { getUsers } from "@/api/user";
import { getDepartments } from "@/api/department";
import { useUserStore } from "@/stores/user";
import { message } from "ant-design-vue";
import { useRouter } from "vue-router";

const router = useRouter();
const userStore = useUserStore();
const user = computed(() => userStore.user);

// TABLE
const columns = [
    { title: "Tên tài liệu", dataIndex: "title", width: 200 },
    { title: "Phòng ban", dataIndex: "department", width: 140 },
    { title: "Người xem", dataIndex: "allowed_users", width: 180 }
];

const loading = ref(false);
const tableData = ref([]);
const users = ref([]);
const departments = ref([]);
const searchText = ref("");

const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
});

// HELPERS
const getUser = id => users.value.find(u => u.id == id);
const getUserName = id => users.value.find(u => u.id == id)?.name ?? "";
const getDeptName = id => departments.value.find(d => d.id == id)?.name ?? "—";

// API
const fetchMyDocuments = async () => {
    loading.value = true;

    try {
        const res = await getDocuments({
            search: searchText.value || undefined
        });

        const uid = user.value.id;

        tableData.value = res.data.filter(doc =>
            doc.created_by === uid || doc.allowed_users.includes(uid)
        );

        pagination.value.total = tableData.value.length;

    } catch (e) {
        console.error(e);
        message.error("Không thể tải tài liệu");
    }

    loading.value = false;
};

// DEBOUNCE SEARCH
let timeout = null;
const debouncedSearch = () => {
    clearTimeout(timeout);
    timeout = setTimeout(fetchMyDocuments, 300);
};

const handleTableChange = p => {
    pagination.value.current = p.current;
    pagination.value.pageSize = p.pageSize;
    fetchMyDocuments();
};

const openDetail = record => {
    router.push({ name: "document-detail", params: { id: record.id } });
};

// INIT
onMounted(async () => {
    users.value = (await getUsers()).data;
    departments.value = (await getDepartments()).data;
    fetchMyDocuments();
});
</script>
