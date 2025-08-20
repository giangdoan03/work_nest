<template>
    <div class="sub-task">
        <a-row justify="space-between">
            <a-col>
                <a-typography-title :level="5" style="color: #7c7c7c;">Nhiệm vụ con</a-typography-title>
            </a-col>
            <a-col>
                <PlusOutlined style="font-size: 16px;cursor: pointer;" @click="showPopupCreate"/>
            </a-col>
            </a-row>
            <div v-if="!listSubTask.length" style="margin-bottom: 16px;">
                Không có dữ liệu
            </div>
            <div v-else>
                <a-table
                    :columns="columns"
                    :data-source="listSubTask"
                    :loading="loadingSubTask"
                    row-key="id"
                    :pagination="false"
                >
                    <template #bodyCell="{ column, record, text }">
                        <template v-if="column.key === 'title'">
                            <a-typography-link strong  @click="showDetailSubtask(record)">{{ text }}</a-typography-link>
                        </template>
                        <template v-if="column.key === 'assigned_to'">
                            <a-typography-text>{{ getUserById(record.assigned_to) }}</a-typography-text>
                        </template>
                        <template v-if="column.key === 'date'">
                            <a-typography-text>{{ record.end_date }}</a-typography-text>
                        </template>
                        <template v-if="column.key === 'action'">
                            <a-dropdown placement="left" trigger="click"  :getPopupContainer="triggerNode => triggerNode.parentNode">
                                <a-button>
                                <template #icon>
                                    <MoreOutlined />
                                </template>
                            </a-button>
                                <template #overlay>
                                    <a-menu>
                                        <a-menu-item @click="showDetailSubtask(record)">
                                            Chi tiết
                                        </a-menu-item>
                                        
                                            <a-popconfirm
                                                title="Bạn chắc chắn muốn xóa sub task này?"
                                                ok-text="Xóa"
                                                cancel-text="Hủy"
                                                @confirm="handleDeleteSubtask(record.id)"
                                                placement="topRight"
                                            >
                                                <a-menu-item >
                                                    Xóa
                                                </a-menu-item>
                                            </a-popconfirm>
                                    </a-menu>
                                </template>
                            </a-dropdown>
                        </template>
                    </template>
                </a-table>
            </div>
            <DrawerCreateTask 
                v-model:open-drawer="openDrawerCreateTask"
                :list-user="props.listUser"
                :task-parent="route.params.id"
                :type="commonStore.linkedType"
                @submitForm="submitForm"
            />
    </div>
</template>
<script setup>
import { PlusOutlined, MoreOutlined } from '@ant-design/icons-vue'
import { ref, onMounted } from 'vue';
import { getSubTasks, deleteTask } from '@/api/task';
import DrawerCreateTask from "../common/DrawerCreateTask.vue";
import { useRoute, useRouter } from 'vue-router';
import { useCommonStore } from '@/stores/common'
const commonStore = useCommonStore()

const route = useRoute()
const router = useRouter()
const props = defineProps({
    listUser: {
        type: Array,
        default: () => [],
    },
})
// const emit = defineEmits(['update:openDrawer', 'submitForm'])

const openDrawerCreateTask = ref(false)
const loadingSubTask = ref(false)
const listSubTask = ref([])

const columns = ref([
    { title: 'Tên task', key: 'title', dataIndex: 'title' },
    { title: 'Gắn người dùng', key: 'assigned_to', dataIndex: 'assigned_to' },
    { title: 'Thời hạn', key: 'date', dataIndex: 'date' },
    { title: '', key: 'action', dataIndex: 'action', width:"60px" },
])
const getUserById = (userId) =>  {
    let data = props.listUser.find(ele => ele.id === userId);
    if(!data){
        return "" ;
    }
    return data.name;
}
const showDetailSubtask = (record) => {
    router.push({
        name: "internal-tasks-info",
        params: { id: record.id, task_name: record.name},
        query: {
            ...route.query,
            reload: new Date().getTime()
        }
    })
}
const handleDeleteSubtask = async(subtask_id) => {
    loadingSubTask.value = true;
    try {
        await deleteTask(subtask_id);
        await getSubTask();
    } catch (error) {
        console.log(error);
    }
}
const submitForm = () => {
    getSubTask();
}

const drawerTaskType = ref(null)
const currentEditingTask = ref(null)
const showPopupCreate = () => {
    currentEditingTask.value = null
    drawerTaskType.value = commonStore.linkedType
    openDrawerCreateTask.value = true;
}
const getSubTask = async() => {
    loadingSubTask.value = true;
    try {
        let res =  await getSubTasks(route.params.id);        
        listSubTask.value = res.data;
    } catch (error) {
        console.log(error);
    } finally {
        loadingSubTask.value = false;
    } 

}
onMounted(() => {
    getSubTask();  
})

</script>
<style lang="scss">
    
</style>