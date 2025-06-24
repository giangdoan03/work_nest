<template>
    <div class="comment">
        <a-typography-title :level="5" style="color: #7c7c7c;">Thông tin cập nhật</a-typography-title>
        <a-input 
            v-model:value="inputValue"
            style="width: 100%;" 
            placeholder="Viết lời nhắn tại đây" 
            @focus="isFocused = true"
            @blur="isFocused = false"
        >
        </a-input>
        <div class="list-file" v-if="selectedFile">
            <div class="file">
                <a-button size="large" style="margin-right: 12px;">
                    <template #icon><FileTextOutlined /></template>
                </a-button>
                <a-typography-text>{{ selectedFile.name }}</a-typography-text>
                <div class="close-file" @click="selectedFile=null">x</div>
            </div>
        </div>
        <div style="margin-top: 16px;">
            <a-button 
                type="primary"
                style="margin-right:
                16px; width: 70px;"
                size="large"
                :disabled="!inputValue.trim() && !selectedFile"
                @click="createNewComment"
            >Gửi</a-button>
            <a-upload
                style="width: 30px;"
                :file-list="listFile"
                :show-upload-list="false"
                :maxCount="1"
                :multiple="true"
                :on-remove="(file) => handleRemoveFile('avatar', file)"
                :before-upload="(file) => handleBeforeUpload('avatar', file)"
                :customRequest="({ file }) => handleBeforeUpload('avatar', file)"
            >
                <a-button size="large">
                    <template #icon><PaperClipOutlined /></template>
                </a-button>
            </a-upload>
        </div>
        <div class="list-comment" v-if="listComment">
            <a-spin :spinning="loadingComment">
                <div class="comment-content" v-for="(item, index) in listComment">
                    <a-row :gutter="[12,12]">
                        <a-col>
                            <a-avatar :url="getUserById(item.user_id).avatar"><template #icon><UserOutlined /></template></a-avatar>
                        </a-col>
                        <a-col flex="1" style="margin-top: 6px;">
                            <a-typography-text style="color: #5c5c5c;">{{ getUserById(item.user_id).name }}</a-typography-text>
                            <div class="content">
                                {{ item.content }}
                            </div>
                        </a-col>
                        <a-col>
                            <a-dropdown>
                                <EllipsisOutlined />
                                <template #overlay>
                                    <a-menu>
                                        <a-menu-item @click="showUpdateCommentModal(item)">
                                            Sửa
                                        </a-menu-item>
                                        <a-menu-item>
                                            <a-popconfirm
                                                title="Bạn chắc chắn muốn xóa comment này?"
                                                ok-text="Xóa"
                                                cancel-text="Hủy"
                                                @confirm="handleDeleteComment(item.id)"
                                                placement="topRight"
                                            >
                                                Xóa
                                            </a-popconfirm>
                                        </a-menu-item>
                                    </a-menu>
                                </template>
                            </a-dropdown>
                        </a-col>
                    </a-row>
                    <div class="content-time">
                        <a-typography-text type="secondary">
                            {{ item.created_at }}
                        </a-typography-text>
                    </div>
                     <a-divider style="height: 1px; background-color: #e0e2e3; margin: 18px 0 10px;" v-if="index != listComment.length-1" />
                </div>
            </a-spin>
        </div>
        <a-modal
            v-model:open="openModalEditComment"
            title="Chỉnh sửa thông tin bình luận"
            okText="Lưu"
            cancelText="Hủy"
            @ok="handleUpdateComment"
            :confirm-loading="loadingUpdate"
        >
            <a-form layout="vertical">
                <a-form-item
                    label="Nội dung bình luận"
                >
                    <a-input v-model:value="selectedComment.content" />
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
import { UserOutlined, PaperClipOutlined, FileTextOutlined, EllipsisOutlined } from '@ant-design/icons-vue'; 
import { getComments, createComment, deleteComment, updateComment } from '@/api/comment';
import { getUsers } from '@/api/user';
import { useRoute } from 'vue-router';
import { useUserStore } from "../../stores/user";
import { message } from 'ant-design-vue';

const store = useUserStore()
const route = useRoute()
const inputValue = ref('');
const isFocused = ref(false);
const listComment = ref([])
const listUser = ref([])
const selectedFile = ref()
const listFile = ref([])
const loadingComment = ref(false)
const loadingUpdate = ref(false)
const openModalEditComment = ref(false)
const selectedComment = ref()

const getUserById = (userId) =>  {
    let data = listUser.value.find(ele => ele.id == userId);
    if(!data){
        return "" ;
    }
    return data;
}
const handleBeforeUpload = async (field, file) => {
    selectedFile.value = file;
    console.log(file);
    
}
const showUpdateCommentModal = (item) =>{
    openModalEditComment.value = true;
    selectedComment.value = {...item}
}
const handleUpdateComment = async() => {
    loadingUpdate.value = true;
    try {
        let params= {
            content : selectedComment.value.content
        }
        let res = await updateComment(route.params.id,params)
        openModalEditComment.value = false;
        getListComment()
        message.success('Cập nhật comment thành công')
    } catch (error) {
        message.error('Không thể cập nhật comment')
    } finally {
        loadingUpdate.value = false;
    }
}
const handleDeleteComment = async(commentId) => {
    try {
        let res = await deleteComment(commentId)
        getListComment()
        message.success('Đã xóa comment thành công')
    } catch (error) {
        message.error('Không thể xóa comment')
    }
}
const createNewComment = async() => {
    if(!inputValue.value.trim() && !selectedFile.value){
        return
    }
    try {
        const formData = new FormData()
        formData.append('user_id', store.currentUser.id)
        formData.append('content', inputValue.value ? inputValue.value.trim() : "")
        formData.append('attachment', selectedFile.value)
        let res = await createComment(route.params.id, formData)
        inputValue.value = '';
        selectedFile.value = null;
        getListComment()
    } catch (error) {
        console.log(error);
    }
}
const getListComment = async() => {
    loadingComment.value = true;
    try {
        let res = await getComments(route.params.id)
        
        listComment.value = res.data
    } catch (error) {
        console.log(error);
    } finally {
        loadingComment.value = false;
    }
}
const getUser = async () => {
    try {
        const response = await getUsers();
        listUser.value = response.data;
    } catch (e) {
        message.error('Không thể tải người dùng')
    }
}

onMounted(() => {
    getListComment()
    getUser()
})
</script>
<style scoped>
    .list-comment{
        margin-top: 20px;
    }
    .comment-content{
        margin-bottom: 10px;
    }
    .content{
        margin-top: 10px;
    }
    .content-time{
        margin-top: 12px;
    }
    .list-file{
        margin-top: 10px;
    }
    .file{
        position: relative;
    }
    .close-file{
        position: absolute;
        top: -14px;
        left: 34px;
        font-size: 20px;
        cursor: pointer;
    }
</style>