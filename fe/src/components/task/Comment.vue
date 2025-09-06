<template>
    <div class="comment">
        <!-- LIST COMMENT (chỉ cuộn dọc). Padding-bottom động theo footer -->
        <div
            class="list-comment"
            v-if="listComment"
            ref="listEl"
            :style="{ paddingBottom: listPadBottom }"
        >
            <a-spin :spinning="loadingComment">
                <div
                    class="comment-content"
                    v-for="(item, index) in listComment"
                    :key="item.id || index"
                >
                    <a-row :gutter="[12,12]">
                        <a-col>
                            <a-avatar :src="getUserById(item.user_id)?.avatar">
                                <template #icon><UserOutlined /></template>
                            </a-avatar>
                        </a-col>

                        <a-col flex="1" style="margin-top: 6px;">
                            <a-typography-text style="color: #5c5c5c;">
                                {{ getUserById(item.user_id)?.name || 'Không rõ' }}
                            </a-typography-text>

                            <div class="content">
                                {{ item.content }}
                            </div>

                            <!-- File đính kèm (nhỏ gọn) -->
                            <div v-if="item.files && item.files.length" class="cm-att">
                                <div
                                    v-for="f in item.files"
                                    :key="f.id || f.file_path"
                                    class="cm-att__card"
                                >
                                    <!-- ẢNH -->
                                    <a-image
                                        v-if="kindOfCommentFile(f) === 'image'"
                                        :src="f.file_path"
                                        :height="56"
                                        :preview="true"
                                        class="cm-att__thumb"
                                    />
                                    <!-- FILE KHÁC -->
                                    <div v-else class="cm-att__icon">
                                        <component :is="pickIcon(kindOfCommentFile(f))" class="cm-att__icon-i" />
                                    </div>

                                    <a
                                        class="cm-att__title"
                                        :href="f.file_path"
                                        target="_blank"
                                        rel="noopener"
                                        :title="f.file_name || prettyUrl(f.file_path)"
                                    >
                                        {{ f.file_name || prettyUrl(f.file_path) }}
                                    </a>
                                </div>
                            </div>
                        </a-col>

                        <a-col>
                            <a-dropdown trigger="click" :getPopupContainer="t => t.parentNode">
                                <EllipsisOutlined />
                                <template #overlay>
                                    <a-menu>
                                        <a-menu-item @click="showUpdateCommentModal(item)">Sửa</a-menu-item>
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
                            <a-tooltip :title="formatVi(item.created_at)">
                                {{ fromNowVi(item.created_at) }}
                            </a-tooltip>
                        </a-typography-text>
                    </div>

                    <a-divider
                        v-if="index !== listComment.length - 1"
                        style="height: 1px; background-color: #e0e2e3; margin: 5px 0 5px;"
                    />
                </div>
            </a-spin>
        </div>

        <!-- FOOTER CỐ ĐỊNH: Tải thêm + composer -->
        <div class="footer-fixed" ref="footerEl">
            <div class="load-more" v-if="currentPage < totalPage && !loadingComment">
                <a-button block @click="getListComment(currentPage + 1)">Tải thêm</a-button>
            </div>

            <div class="composer">
                <a-input
                    v-model:value="inputValue"
                    placeholder="Viết lời nhắn tại đây"
                    @keydown.enter.exact.prevent="createNewComment"
                />
                <div class="list-file" v-if="selectedFile">
                    <div class="file">
                        <a-button size="large" style="margin-right: 12px;">
                            <template #icon><FileTextOutlined /></template>
                        </a-button>
                        <a-typography-text>{{ selectedFile.name }}</a-typography-text>
                        <div class="close-file" @click="selectedFile=null">x</div>
                    </div>
                </div>

                <div class="composer-actions">
                    <a-button
                        type="primary"
                        style="margin-right: 12px; width: 80px;"
                        size="large"
                        :disabled="!inputValue.trim() && !selectedFile"
                        @click="createNewComment"
                    >
                        Gửi
                    </a-button>

                    <a-upload
                        :file-list="listFile"
                        :show-upload-list="false"
                        :maxCount="1"
                        :multiple="true"
                        :on-remove="() => handleRemoveFile()"
                        :before-upload="(file) => handleBeforeUpload('attachment', file)"
                        :customRequest="({ file }) => handleBeforeUpload('attachment', file)"
                    >
                        <a-button size="large">
                            <template #icon><PaperClipOutlined /></template>
                        </a-button>
                    </a-upload>
                </div>
            </div>
        </div>

        <!-- Modal sửa -->
        <a-modal
            v-model:open="openModalEditComment"
            title="Chỉnh sửa thông tin bình luận"
            okText="Lưu"
            cancelText="Hủy"
            @ok="handleUpdateComment"
            :confirm-loading="loadingUpdate"
        >
            <a-form layout="vertical">
                <a-form-item label="Nội dung bình luận">
                    <a-input v-model:value="selectedComment.content" />
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import {
    UserOutlined,
    PaperClipOutlined,
    EllipsisOutlined,
    FilePdfOutlined,
    FileWordOutlined,
    FileExcelOutlined,
    FilePptOutlined,
    FileTextOutlined,
    LinkOutlined,
} from '@ant-design/icons-vue'
import { getComments, createComment, deleteComment, updateComment } from '@/api/task'
import { getUsers } from '@/api/user'
import { useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user.js'
import { message } from 'ant-design-vue'

import dayjs from 'dayjs'
import 'dayjs/locale/vi'
import relativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(relativeTime)
dayjs.locale('vi')

/* ===== time helpers (VI) ===== */
const tick = ref(Date.now())
let t
function fromNowVi(dt) {
    // buộc re-render mỗi phút
    // eslint-disable-next-line no-unused-expressions
    tick.value
    const d = dayjs(dt)
    return d.isValid() ? d.fromNow() : ''
}
function formatVi(dt) {
    const d = dayjs(dt)
    return d.isValid() ? d.format('HH:mm DD/MM/YYYY') : ''
}

/* ===== state ===== */
const store = useUserStore()
const route = useRoute()

const inputValue = ref('')
const listComment = ref([])
const listUser = ref([])

const selectedFile = ref()
const listFile = ref([])

const loadingComment = ref(false)
const loadingUpdate = ref(false)
const openModalEditComment = ref(false)
const selectedComment = ref({})

const totalPage = ref(1)
const currentPage = ref(1)

/* ===== refs + padding đáy động ===== */
const listEl = ref(null)
const footerEl = ref(null)
const listPadBottom = ref('96px') // fallback

function measureFooter() {
    const h = footerEl.value?.offsetHeight || 96
    listPadBottom.value = h + 8 + 'px' // +8px cho thoáng
}
function scrollToBottom() {
    const el = listEl.value
    if (!el) return
    el.scrollTop = el.scrollHeight
}

/* ResizeObserver để cập nhật padding khi viewport đổi */
let ro
onMounted(() => {
    measureFooter()
    if ('ResizeObserver' in window) {
        ro = new ResizeObserver(measureFooter)
        footerEl.value && ro.observe(footerEl.value)
    }
})

/* ===== helper nhận diện loại file ===== */
const IMAGE_EXTS = new Set(['jpg','jpeg','png','gif','webp','bmp','svg'])
const PDF_EXTS   = new Set(['pdf'])
const WORD_EXTS  = new Set(['doc','docx'])
const EXCEL_EXTS = new Set(['xls','xlsx','csv'])
const PPT_EXTS   = new Set(['ppt','pptx'])

function extOf(name = '') {
    const n = String(name).split('?')[0]
    const m = n.lastIndexOf('.')
    return m >= 0 ? n.slice(m + 1).toLowerCase() : ''
}
function detectKind(obj = {}) {
    const name = obj.name || ''
    const url = obj.url || ''
    const file_type = obj.file_type || ''
    if (String(file_type).indexOf('image/') === 0) return 'image'
    const e = extOf(name || url)
    if (IMAGE_EXTS.has(e)) return 'image'
    if (PDF_EXTS.has(e))   return 'pdf'
    if (WORD_EXTS.has(e))  return 'word'
    if (EXCEL_EXTS.has(e)) return 'excel'
    if (PPT_EXTS.has(e))   return 'ppt'
    if (/^https?:\/\//i.test(url)) return 'link'
    return 'other'
}
function pickIcon(kind) {
    switch (kind) {
        case 'pdf':  return FilePdfOutlined
        case 'word': return FileWordOutlined
        case 'excel':return FileExcelOutlined
        case 'ppt':  return FilePptOutlined
        case 'link': return LinkOutlined
        default:     return FileTextOutlined
    }
}
function prettyUrl(u) {
    try {
        const url = new URL(u)
        const path = url.pathname.replace(/^\/+/, '')
        const short = path.length > 30 ? path.slice(0, 30) + '…' : path
        return url.host + (short ? '/' + short : '')
    } catch { return u }
}
function kindOfCommentFile(f = {}) {
    return detectKind({ name: f.file_name, url: f.file_path, file_type: f.file_type })
}

/* ===== users ===== */
const getUserById = (userId) => listUser.value.find(ele => ele.id === userId) || {}

/* ===== upload handlers ===== */
const handleBeforeUpload = async (_field, file) => {
    selectedFile.value = file
    return false // chặn upload mặc định
}
const handleRemoveFile = () => { selectedFile.value = null }

/* ===== CRUD ===== */
const showUpdateCommentModal = (item) => {
    openModalEditComment.value = true
    selectedComment.value = { ...item }
}
const handleUpdateComment = async () => {
    if (!selectedComment.value?.id) {
        message.error('Thiếu ID bình luận'); return
    }
    loadingUpdate.value = true
    try {
        const params = { content: selectedComment.value.content }
        await updateComment(selectedComment.value.id, params)
        openModalEditComment.value = false
        await getListComment(currentPage.value)
        message.success('Cập nhật comment thành công')
    } catch {
        message.error('Không thể cập nhật comment')
    } finally {
        loadingUpdate.value = false
    }
}
const handleDeleteComment = async (commentId) => {
    try {
        await deleteComment(commentId)
        if (listComment.value.length === 1 && currentPage.value > 1) {
            await getListComment(currentPage.value - 1)
        } else {
            await getListComment(currentPage.value)
        }
        message.success('Đã xóa comment thành công')
    } catch {
        message.error('Không thể xóa comment')
    }
}

const createNewComment = async () => {
    if (!inputValue.value.trim() && !selectedFile.value) return
    try {
        const form = new FormData()
        form.append('user_id', store.currentUser.id)
        form.append('content', inputValue.value ? inputValue.value.trim() : '')
        if (selectedFile.value) form.append('attachment', selectedFile.value)

        await createComment(route.params.id, form)
        inputValue.value = ''
        selectedFile.value = null

        await getListComment(1)
        await nextTick()
        scrollToBottom()
    } catch (e) {
        console.error(e)
    }
}

/* ===== load list (paging) ===== */
const getListComment = async (page = 1) => {
    loadingComment.value = true
    try {
        const params = { page }
        const res = await getComments(route.params.id, params)

        if (page === 1) {
            listComment.value = res.data.comments
            await nextTick()
            measureFooter()
            scrollToBottom()
        } else {
            const el = listEl.value
            const prevScrollBottom = el ? (el.scrollHeight - el.scrollTop) : 0
            listComment.value = [...listComment.value, ...res.data.comments]
            await nextTick()
            measureFooter()
            if (el) el.scrollTop = el.scrollHeight - prevScrollBottom
        }

        totalPage.value = res.data.pagination.totalPages
        currentPage.value = page
    } catch (e) {
        console.error(e)
    } finally {
        loadingComment.value = false
    }
}

/* ===== load users ===== */
const getUser = async () => {
    try {
        const response = await getUsers()
        listUser.value = response.data
    } catch {
        message.error('Không thể tải người dùng')
    }
}

/* ===== lifecycle ===== */
onMounted(() => {
    t = setInterval(() => (tick.value = Date.now()), 60_000)
    getUser()
    getListComment()
})
onBeforeUnmount(() => {
    clearInterval(t)
    ro?.disconnect?.()
})
</script>

<style scoped>
/* Bố cục: list ở trên (cuộn dọc), footer ở dưới */
.comment{
    display:flex;
    flex-direction:column;
    height:100%;
    min-height:0;
}

/* LIST: chỉ cuộn dọc, không tràn ngang.
   padding-bottom set bằng inline style (listPadBottom) */
.list-comment{
    flex:1 1 auto;
    min-height:0;
    overflow-y:auto;
    overflow-x:hidden;
    padding-right:2px;

    /* scrollbar nhỏ */
    scrollbar-width:thin;                         /* Firefox */
    scrollbar-color:rgba(0,0,0,.35) transparent; /* Firefox */
}
.list-comment::-webkit-scrollbar{ width:6px; }
.list-comment::-webkit-scrollbar-track{ background:transparent; }
.list-comment::-webkit-scrollbar-thumb{
    background:rgba(0,0,0,.28);
    border-radius:8px;
}

/* FOOTER CỐ ĐỊNH trong vùng scroll (sticky) */
.footer-fixed{
    position: sticky;
    bottom: 0;
    z-index: 5;
    background:#fff;
    border-top:1px solid #f0f0f0;
    padding-top:10px;
    box-shadow: 0 -4px 10px rgba(0,0,0,.03);
}
.load-more{ margin-bottom:8px; }

/* Composer */
.composer-actions{
    margin-top:10px;
    display:flex;
    align-items:center;
    gap:8px;
}

/* Khác */
.list-comment{ margin-top:8px; }
.comment-content{ margin-bottom:10px; }
.content{ margin-top:10px; overflow-wrap:anywhere; word-break:break-word; }
.content-time{ margin-top:12px; }
.list-file{ margin-top:10px; }
.file{ position:relative; }
.close-file{
    position:absolute; top:-14px; left:34px; font-size:20px; cursor:pointer;
}

/* ========== comment attachments (mini) ========== */
.cm-att{
    margin-top:8px;
    display:grid;
    grid-template-columns:repeat(auto-fill, minmax(150px, 1fr));
    gap:8px;
}
.cm-att__card{
    border:1px solid #f0f0f0;
    border-radius:10px;
    padding:6px;
    background:#fff;
}
.cm-att__thumb{ width:100%; object-fit:cover; border-radius:6px; }
.cm-att__icon{
    height:56px; display:flex; align-items:center; justify-content:center;
    background:#fafafa; border-radius:6px;
}
.cm-att__icon-i{ font-size:22px; opacity:.9; }
.cm-att__title{
    display:block; margin-top:6px; font-size:12px; line-height:1.2;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis; color:#1677ff;
}
</style>
