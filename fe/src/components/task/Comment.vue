<template>
    <div class="comment">
        <!-- STICKY: Tài liệu ghim (trái) + Drawer người duyệt (phải) -->
<!--        <div class="mention-chips sticky-mentions"-->
<!--             v-if="(pinnedFiles && pinnedFiles.length) || (mentionsSelected && mentionsSelected.length)">-->
<!--            <div class="sticky-head">-->
<!--                &lt;!&ndash; LEFT: tổng số file ghim + arrow toggle &ndash;&gt;-->
<!--                <div class="sticky-left">-->
<!--                    <button-->
<!--                        class="pinned-toggle"-->
<!--                        :disabled="!hasPinnedOverflow"-->
<!--                        @click="toggleSticky"-->
<!--                        :title="hasPinnedOverflow ? (isStickyExpanded ? 'Thu gọn file ghim' : 'Hiện tất cả file ghim') : 'Không có thêm file để mở'"-->
<!--                        role="button"-->
<!--                        :aria-expanded="!!isStickyExpanded"-->
<!--                        aria-controls="pinned-files-region"-->
<!--                    >-->
<!--                        <span class="sticky-title">Tài liệu ghim</span>-->
<!--                        <span class="sticky-count">({{ pinnedTotal }} file)</span>-->
<!--                        <component :is="arrowIcon" class="arrow"/>-->
<!--                    </button>-->
<!--                </div>-->

<!--                &lt;!&ndash; RIGHT: Drawer người duyệt &ndash;&gt;-->
<!--                <div class="sticky-actions">-->
<!--                    <a-tooltip title="Danh sách người duyệt/ký">-->
<!--                        <a-badge :count="mentionsSelected?.length || 0" :offset="[-2, 3]">-->
<!--                            <a-button type="text" size="small" @click="openApproverDrawer = true" class="approver-btn">-->
<!--                                <TeamOutlined/>-->
<!--                                <span class="approver-text">Người duyệt</span>-->
<!--                            </a-button>-->
<!--                        </a-badge>-->
<!--                    </a-tooltip>-->
<!--                </div>-->
<!--            </div>-->

<!--            <div id="pinned-files-region"></div>-->

<!--            &lt;!&ndash; Pinned files &ndash;&gt;-->
<!--            <div v-if="pinnedGroupedByComment.length" class="pinned-files">-->

<!--                <div-->
<!--                    v-for="group in visiblePinnedGroups"-->
<!--                    :key="group.comment_id"-->
<!--                    class="pinned-batch"-->
<!--                >-->
<!--                    &lt;!&ndash; HEADER của batch &ndash;&gt;-->
<!--                    <div class="batch-title">-->
<!--                        <span>Lần {{ group.batch }}: {{ group.files.length }} file</span>-->
<!--                        <small>{{ formatVi(group.created_at) }}</small>-->
<!--                    </div>-->

<!--                    &lt;!&ndash; FILES trong batch &ndash;&gt;-->
<!--                    <div class="pinned-line">-->
<!--                        <div-->
<!--                            v-for="f in group.files"-->
<!--                            :key="f.id || f.file_path"-->
<!--                            class="pinned-pill"-->
<!--                            :title="titleOf(f)"-->
<!--                        >-->
<!--                            <a-tooltip placement="top">-->
<!--                                <template #title>-->
<!--                                    <div v-html="pinTooltip(f)"></div>-->
<!--                                </template>-->

<!--                                <a-->
<!--                                    :href="displayHrefOf(f)"-->
<!--                                    target="_blank"-->
<!--                                    rel="noopener"-->
<!--                                    class="pill-link"-->
<!--                                >-->
<!--                                    <PaperClipOutlined class="pill-icon"/>-->
<!--                                    <span class="pill-text">{{ titleOf(f) }}</span>-->
<!--                                </a>-->
<!--                            </a-tooltip>-->


<!--                            <a-tooltip title="Bỏ ghim">-->
<!--                                <button-->
<!--                                    class="pill-x"-->
<!--                                    type="button"-->
<!--                                    @click.stop.prevent="unpinOnly(f)"-->
<!--                                    :disabled="!canUnpinFile(f)"-->
<!--                                >×-->
<!--                                </button>-->
<!--                            </a-tooltip>-->
<!--                        </div>-->
<!--                    </div>-->
<!--                </div>-->

<!--            </div>-->


<!--        </div>-->

        <!-- LIST COMMENT (bubbles) -->
        <div class="list-comment" v-if="listComment" ref="listEl">
            <a-spin :spinning="loadingComment">
                <div
                    class="tg-row"
                    v-for="(item, index) in listComment"
                    :key="item.id || index"
                    :class="{ me: String(item.user_id) === String(currentUserId) }"
                >
                    <div class="avatar" v-if="String(item.user_id) !== String(currentUserId)">
                        <BaseAvatar
                            :src="getUserById(item.user_id)?.avatar"
                            :name="getUserById(item.user_id)?.name || 'Không rõ'"
                            :size="34"
                            shape="circle"
                            :preferApiOrigin="true"
                        />
                    </div>

                    <div class="bubble" :class="{ me: String(item.user_id) === String(currentUserId) }">

                        <div class="text">
                            <div class="author" v-if="String(item.user_id) !== String(currentUserId)">
                                {{ getUserById(item.user_id)?.name || 'Không rõ' }}
                            </div>

                            <!-- nội dung có thể chứa link -->
                            <div class="msg-content" v-html="formatMessage(item.content)"></div>
                        </div>

                        <!-- Attachments trong bubble -->
                        <div v-if="item.files && item.files.length" class="tg-attachments">

                            <a-tooltip
                                v-for="f in item.files"
                                :key="f.id || f.file_path || f.link_url"
                                placement="top"
                            >
                                <template #title>
                                    {{ f.file_name || prettyUrl(hrefOf(f)) }}
                                </template>

                                <div class="tg-att-item">
                                    <!-- Image -->
                                    <a-image
                                        v-if="kindOfCommentFile(f) === 'image'"
                                        :src="srcWithBustIfImage(f)"
                                        :height="72"
                                        :preview="true"
                                        class="cm-att__thumb"
                                    />

                                    <!-- Non-image -->
                                    <div v-else class="cm-att__icon">
                                        <component :is="pickIcon(kindOfCommentFile(f))" class="cm-att__icon-i"/>
                                    </div>

                                    <!-- File name -->
                                    <div class="cm-att__line">
                                        <a class="tg-file-link"
                                           :href="displayHrefOf(f)"
                                           target="_blank"
                                           rel="noopener"
                                        >
                                            {{ f.file_name || prettyUrl(hrefOf(f)) }}
                                        </a>
                                    </div>
                                </div>

                            </a-tooltip>
                        </div>

                        <div class="meta">
                            <a-tooltip :title="formatVi(item.created_at)">{{ fromNowVi(item.created_at) }}</a-tooltip>
                        </div>
                    </div>
                </div>
            </a-spin>
        </div>

        <!-- FOOTER: composer -->
        <div class="footer-fixed tg-footer" ref="footerEl">
            <a-spin :spinning="uploading" tip="Đang tải lên...">
                <div class="load-more" v-if="currentPage < totalPage && !loadingComment">
                    <a-button size="small" @click="getListComment(currentPage + 1)">Tải thêm</a-button>
                </div>

                <div class="tg-file-strip" v-if="selectedFiles.length">
                    <div
                        v-for="(f, idx) in selectedFiles"
                        :key="idx"
                        class="tg-file-pill"
                    >
                        <PaperClipOutlined/>
                        <span class="name">{{ f.name }}</span>
                        <span class="x" @click.stop.prevent="removeFile(idx)">×</span>
                    </div>
                </div>


                <div class="tg-composer">
                    <!-- Attach -->
                    <a-upload
                        :show-upload-list="false"
                        :multiple="true"
                        :max-count="3"
                        :before-upload="handleBeforeUpload"
                    >
                        <a-button type="text" class="tg-attach-btn" title="Đính kèm">
                            <PaperClipOutlined/>
                        </a-button>
                    </a-upload>

<!--                    <a-tooltip title="Tạo phiên duyệt mới">-->
<!--                        <a-button-->
<!--                            type="text"-->
<!--                            class="tg-attach-btn"-->
<!--                            @click="uploadModalOpen = true"-->
<!--                        >-->
<!--                            <PlusOutlined />-->
<!--                        </a-button>-->
<!--                    </a-tooltip>-->


                    <UploadWithUserModal
                        v-model:open="uploadModalOpen"
                        :task-id="Number(route.params.id)"
                        :users="users"
                        :get-department-name="getDepartmentName"
                        mode="create"
                        @confirm="handleApprovalSessionCreated"
                    />


                    <!-- Ô nhập -->
<!--                    <a-textarea-->
<!--                        v-model:value="inputValue"-->
<!--                        class="tg-input"-->
<!--                        :bordered="false"-->
<!--                        :auto-size="{ minRows: 1, maxRows: 6 }"-->
<!--                        :placeholder="isEditing ? 'Sửa bình luận… (Enter để lưu, Esc để hủy)' : 'Viết lời nhắn… (Enter để gửi, Shift+Enter để xuống dòng, gõ @ để thêm người duyệt)'"-->
<!--                        @keydown="onComposerKeydown"-->
<!--                        @input="onInputDetectMention"-->
<!--                    />-->

                    <a-textarea
                        v-model:value="inputValue"
                        class="tg-input"
                        :bordered="false"
                        :auto-size="{ minRows: 1, maxRows: 6 }"
                        :placeholder="isEditing ? 'Sửa bình luận… (Enter để lưu, Esc để hủy)' : 'Viết lời nhắn… (Enter để gửi, Shift+Enter để xuống dòng)'"
                        @keydown="onComposerKeydown"
                    />

                    <!-- Nút gửi / lưu -->
                    <a-button
                        class="tg-send-btn"
                        :class="{ 'is-active': canSend }"
                        shape="circle"
                        :disabled="!canSend || uploading"
                        :loading="uploading"
                        @click="onSubmit()"
                    >
                        <template v-if="isEditing">
                            <CheckOutlined/>
                        </template>
                        <template v-else>
                            <SendOutlined/>
                        </template>
                    </a-button>
                </div>

                <!-- Mention pop -->
                <div class="mention-row">
                    <a-modal
                        v-model:open="addMentionOpen"
                        title="Thêm người duyệt"
                        centered
                        :footer="null"
                        width="520px"
                        class="mention-modal"
                        :maskClosable="!rosterAllApproved"
                        :keyboard="!rosterAllApproved"
                    >
                        <div class="mention-body">

                            <!-- Nếu đã duyệt 100% → chỉ hiện thông báo, ẩn mọi input -->
                            <div v-if="rosterAllApproved" class="lock-overlay"
                                 style="padding:14px; text-align:center; font-size:15px; color:#444;">
                                Hồ sơ đã duyệt xong — không thể thêm người duyệt.
                            </div>

                            <!-- Nếu CHƯA duyệt xong → hiển thị giao diện thêm người duyệt -->
                            <template v-else>

                                <!-- Chọn người -->
                                <div class="field">
                                    <label class="field-label">Người duyệt:</label>

                                    <a-select
                                        v-model:value="mentionForm.userId"
                                        show-search
                                        :filterOption="filterUser"
                                        placeholder="Chọn người"
                                        style="width:100%"
                                    >
                                        <a-select-option
                                            v-for="u in sortedUsers"
                                            :key="u.id"
                                            :value="String(u.id)"
                                        >
                                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                                <span>{{ u.name }}</span>

                                                <a-tag
                                                    :color="departmentColors[u.department_id]"
                                                    style="border-radius:6px;"
                                                >
                                                    {{ getDepartmentName(u) }}
                                                </a-tag>
                                            </div>
                                        </a-select-option>
                                    </a-select>
                                </div>

                                <!-- Chọn vai trò nếu user đa nhiệm -->
                                <div v-if="Number(selectedUser?.is_multi_role) === 1">
                                    <a-alert
                                        type="warning"
                                        show-icon
                                        message="Người duyệt kiêm nhiệm"
                                        description="Hãy chọn đúng vai trò để luồng duyệt được phân bổ chính xác."
                                        class="role-alert"
                                    />

                                    <div class="field">
                                        <label class="field-label">Vai trò:</label>

                                        <a-radio-group
                                            v-model:value="mentionForm.role"
                                            class="role-radio-group"
                                        >

                                            <!-- Ban Giám Đốc -->
                                            <a-radio value="vu_thi_thuy_bgd">
                                                Ban Giám đốc
                                                <span class="default-text" style="color:red">(mặc định)</span> –
                                                <a-tooltip title="Phó Giám Đốc">
                                                    <a-tag color="blue">vu_thi_thuy_bgd</a-tag>
                                                </a-tooltip>

                                                <a-button
                                                    class="copy-icon-btn"
                                                    type="text"
                                                    style="padding:0; margin-left:6px;"
                                                    @click="copyTag('vu_thi_thuy_bgd')"
                                                >
                                                    <CopyOutlined/>
                                                </a-button>
                                            </a-radio>

                                            <!-- Kế toán -->
                                            <a-radio value="vu_thi_thuy_kt">
                                                Phòng Kế Toán - Tài Chính –
                                                <a-tooltip title="Trưởng phòng kế toán - tài chính">
                                                    <a-tag color="green">vu_thi_thuy_kt</a-tag>
                                                </a-tooltip>

                                                <a-button
                                                    class="copy-icon-btn"
                                                    type="text"
                                                    style="padding:0; margin-left:6px;"
                                                    @click="copyTag('vu_thi_thuy_kt')"
                                                >
                                                    <CopyOutlined/>
                                                </a-button>
                                            </a-radio>

                                            <!-- Thương mại -->
                                            <a-radio value="vu_thi_thuy_tm">
                                                Phòng Thương Mại –
                                                <a-tooltip title="Trưởng phòng thương mại">
                                                    <a-tag color="orange">vu_thi_thuy_tm</a-tag>
                                                </a-tooltip>

                                                <a-button
                                                    class="copy-icon-btn"
                                                    type="text"
                                                    style="padding:0; margin-left:6px;"
                                                    @click="copyTag('vu_thi_thuy_tm')"
                                                >
                                                    <CopyOutlined/>
                                                </a-button>
                                            </a-radio>

                                        </a-radio-group>
                                    </div>
                                </div>

                                <!-- Nút footer -->
                                <div class="modal-footer">
                                    <a-button @click="addMentionOpen = false">Hủy</a-button>
                                    <a-button type="primary" @click="addMention">Thêm</a-button>
                                </div>

                            </template>
                        </div>
                    </a-modal>
                </div>
            </a-spin>
        </div>

        <!-- Drawer người duyệt -->
        <a-drawer
            v-model:open="openApproverDrawer"
            title="Danh sách người duyệt/ký"
            placement="right"
            width="520"
            :get-container="false"
            :style="{ position: 'absolute' }"
            class="approver-drawer"
        >
            <!-- Toolbar (bên phải tiêu đề) -->
            <template #extra>
                <a-switch
                    v-model:checked="filterPendingOnly"
                    checked-children="Chờ"
                    un-checked-children="Tất cả"
                    :title="filterPendingOnly ? 'Chỉ hiện đang chờ' : 'Hiện tất cả'"
                />
            </template>

            <div class="drawer-toolbar">
                <div class="creator-info">
                    <div>
                        Người tạo:
                    </div>
                    <div>
                        <strong>{{ rosterCreatedByName || 'Không rõ' }}</strong>
                        <small v-if="rosterCreatedBy" style="margin-left:8px; color:#6b7280">({{ rosterCreatedBy }})</small>
                    </div>
                </div>

                <!-- tuỳ chọn: nếu bạn có biến progress/all_approved từ API, hiển thị ở đây -->
                <div class="drawer-stats">
                    <span v-if="typeof rosterProgress !== 'undefined'">Tiến độ: {{ rosterProgress }}%</span>
                    <span v-if="typeof rosterAllApproved !== 'undefined' && rosterAllApproved" class="approved-tag">• Đã duyệt xong</span>
                </div>
            </div>

            <!-- NEW: Thông tin lượt upload mới nhất -->
            <div
                v-if="latestBatch && latestFiles && latestFiles.length"
                class="latest-batch-box"
            >
                <div class="lb-header">
                    <div class="lb-title">
                        <strong>Lượt upload #{{ latestBatch }}</strong>
                    </div>
                    <div class="lb-meta">
                        <span class="lb-time">{{ latestBatchMeta?.created_at_vi }}</span>
                    </div>
                </div>

                <div class="lb-file" v-for="f in latestFiles" :key="f.id">
                    <div class="lb-file-icon">
                        <component :is="pickIcon(kindOfCommentFile(f))"/>
                    </div>

                    <div class="lb-file-info">
                        <div class="lb-file-name">
                            <a-tooltip placement="top">
                                <template #title>
                                    {{ f.file_name }}
                                </template>

                                <a
                                    :href="displayHrefOf(f)"
                                    target="_blank"
                                    rel="noopener"
                                    class="lb-file-name-text lb-file-link"
                                >
                                    {{ f.file_name }}
                                </a>
                            </a-tooltip>
                        </div>

                        <div class="lb-file-sub">
                            <span>{{ prettySize(f.file_size) }}</span>
                            <span class="lb-dot">•</span>
                            <span>{{ formatVi(f.created_at) }}</span>
                        </div>
                    </div>
                </div>

            </div>


            <!-- Empty state -->
            <div v-if="finalDrawerMentions.length === 0" class="drawer-empty">
                <div class="empty-icon">😶‍🌫️</div>
                <div>Chưa có người duyệt/ký phù hợp.</div>
                <div class="hint">Hãy thêm người hoặc bỏ lọc để xem tất cả.</div>
            </div>

            <!-- Danh sách -->
            <div v-else class="drawer-list">

                <!-- thay bằng Draggable (PascalCase) -->
                <Draggable
                    v-model="dragList"
                    :item-key="m => `${m.user_id}_${m.department_id}`"
                    handle=".chip-card"
                    ghost-class="chip-ghost"
                    animation="200"
                    :disabled="!canModifyRoster || filterPendingOnly || drawerSearch"
                    @end="handleReorder"
                >
                    <template v-slot:item="{ element: m, index }">
                        <div
                            :key="`${m.user_id}_${m.department_id}_${m.status}`"
                            class="drawer-chip"
                        >
                            <!-- Tooltip hướng dẫn kéo thả; đặt trên chip-card để người dùng thấy khi hover -->
                            <a-tooltip
                                :title="filterPendingOnly || drawerSearch ? 'Tắt bộ lọc hoặc tìm kiếm để sắp xếp lại thứ tự duyệt' : canModifyRoster  ? 'Kéo thả để thay đổi thứ tự duyệt' : 'Chỉ người tạo task mới được sắp xếp thứ tự duyệt'"
                                placement="top"
                            >
                                <div class="chip-card" role="button" tabindex="0" :class="{
                                    'is-approved': m.status === 'approved' && !m.signed,
                                    'is-pending': m.status === 'pending' || m.status === 'processing',
                                    'is-rejected': m.status === 'rejected',
                                    'is-signed': m.signed === true
                                }"
                                >
                                    <!-- Avatar -->
                                    <div class="chip-avatar" aria-hidden="true">
                                        <BaseAvatar
                                            :src="getUserById(m.user_id)?.avatar"
                                            :name="getUserById(m.user_id)?.name || m.name || 'U'"
                                            :size="28"
                                            shape="circle"
                                            :preferApiOrigin="true"
                                        />
                                    </div>

                                    <!-- Thông tin -->
                                    <div class="chip-body">
                                        <div class="name-row enhanced-chip-name">
                                            <span class="chip-name">@{{ m.name }}</span>

                                            <!-- TAG PHÒNG BAN — đẹp, nhạt, chuyên nghiệp -->
                                            <a-tag v-if="m.department_id" color="blue">
                                                {{ getDepartmentName(m) }}
                                            </a-tag>
                                            <!-- TAG SIGNATURE CODE — style dạng 'code' -->
                                            <a-tag
                                                v-if="m.signature_code"
                                                color="purple"
                                                class="sig-tag"
                                            >
                                                {{ m.signature_code }}
                                            </a-tag>
                                        </div>


                                        <div class="meta-row">
                                            <span class="dot" :class="statusDotClass(m.status)"></span>
                                            <span class="chip-state">
                                              {{m.status === 'approved' ? 'Đã duyệt' : m.status === 'rejected' ? 'Đã từ chối' : 'Chờ duyệt' }}
                                            </span>
                                            <span class="meta-sep">•</span>
                                            <span class="chip-time">{{ metaTime(m) }}</span>
                                        </div>

                                        <div class="actions-row">
                                            <!-- 1️⃣ Các nút DUYỆT – TỪ CHỐI -->
                                            <template v-if="canActOnChip(m)">
                                                <a-button
                                                    v-if="m.user_id === currentUserId && m.status === 'pending'"
                                                    size="small"
                                                    type="primary"
                                                    :loading="approveLoading[m.user_id]?.[m.department_id]?.approved"
                                                    @click="handleApproveAction(m, 'approved')"
                                                >
                                                    <template #icon><CheckOutlined /></template>
                                                    Đồng ý
                                                </a-button>


<!--                                                <a-button-->
<!--                                                    size="small"-->
<!--                                                    danger-->
<!--                                                    :loading="approveLoading[m.user_id]?.[m.department_id]?.rejected"-->
<!--                                                    @click="handleApproveAction(m, 'rejected')"-->
<!--                                                >-->
<!--                                                    <template #icon><CloseOutlined /></template>-->
<!--                                                    Từ chối-->
<!--                                                </a-button>-->
                                            </template>
                                            <!-- 4️⃣ Hiển thị “Lượt của ...” -->
                                            <template v-if="!canActOnChip(m) && m.status === 'pending'">
                                                <a-tag color="blue" style="border-radius:12px">
                                                    Lượt của @{{ m.name }}
                                                </a-tag>
                                            </template>

                                            <!-- 5️⃣ Nút X xoá -->
                                            <a-button
                                                v-if="canModifyRoster"
                                                size="small"
                                                type="text"
                                                class="chip-close"
                                                @click="removeMention(m)"
                                            >×</a-button>
                                        </div>

                                    </div>
                                </div>
                            </a-tooltip>
                        </div>
                    </template>

                </Draggable>
            </div>
        </a-drawer>

    </div>
</template>

<script setup>
import {computed, nextTick, onBeforeUnmount, onMounted, ref, watch} from 'vue'
import _ from "lodash";
import {
    CaretDownOutlined,
    CaretUpOutlined,
    CheckOutlined,
    PlusOutlined,
    FileExcelOutlined,
    FilePdfOutlined,
    FilePptOutlined,
    FileTextOutlined,
    FileWordOutlined,
    LinkOutlined,
    PaperClipOutlined,
    SendOutlined,
    TeamOutlined,
    CopyOutlined
} from '@ant-design/icons-vue'

import {
    approveRosterAPI,
    createComment,
    getComments,
    getTaskRosterAPI,
    mergeTaskRosterAPI,
    updateComment,
} from '@/api/task'
import { signTaskForUserAPI } from "@/api/taskSign";

import {
    adoptTaskFileFromPathAPI,
    getPinnedFilesAPI,
    getTaskFilesAPI,
    pinTaskFileAPI, replaceMarkerInTaskFile,
    unpinTaskFileAPI,
    uploadTaskFileLinkAPI,
} from '@/api/taskFiles'

import {getUsers} from '@/api/user'
import {useRoute} from 'vue-router'
import {useUserStore} from '@/stores/user.js'
import {message} from 'ant-design-vue'
import dayjs from 'dayjs'
import 'dayjs/locale/vi'
import relativeTime from 'dayjs/plugin/relativeTime'
import BaseAvatar from '@/components/common/BaseAvatar.vue'
import Draggable from 'vuedraggable'
import {addEntityMember} from "@/api/entityMembers.js";
import UploadWithUserModal from '@/components/task/UploadWithUserModal.vue'
dayjs.extend(relativeTime)
dayjs.locale('vi')
const openUploadModal = ref(false)
const props = defineProps({
    departments: { type: Array, default: () => [] },
    users: { type: Array, default: () => [] },
    roster: { type: Array, default: () => [] }
})
const uploadModalOpen = ref(false)

const emit = defineEmits(['approval-session-created'])

const handleApprovalSessionCreated = (payload) => {
    // payload có thể là { session_id: 29 }
    emit('approval-session-created', payload)
}


const latestBatch = ref(null)
const latestFiles = ref([])
const latestBatchMeta = ref(null)
const approveLoading = ref({})
const signLoading = ref({})

// bạn có thể lắng nghe sự kiện @update để cập nhật lại thứ tự
const handleReorder = async (evt) => {
    if (!canModifyRoster.value) {
        message.warning('Chỉ người tạo task mới được thay đổi thứ tự người duyệt')
        // restore dragList từ mentionsSelected nếu cần
        dragList.value = Array.isArray(finalDrawerMentions.value) ? finalDrawerMentions.value.map(x => ({...x})) : []
        return
    }

    // tiếp tục logic hiện có...
    console.log('drag end, new order', dragList.value)
    mentionsSelected.value = dragList.value.map(m => ({...m}))

    try {
        await persistRoster('replace')
        message.success('Đã lưu thứ tự người duyệt')
    } catch (e) {
        console.error('save reorder failed', e)
        message.error('Không lưu được thứ tự')
    }
}

// new reactive list for draggable
const dragList = ref([])

/* ===== time helpers (VI) ===== */
const tick = ref(Date.now())
let t

function fromNowVi(dt) {
    tick.value
    const d = dayjs(dt)
    return d.isValid() ? d.fromNow() : ''
}

const getDepartmentName = (m) => {
    const dept = props.departments.find(d => Number(d.id) === Number(m.department_id));
    return dept?.name || '';
};


function formatVi(dt) {
    const d = dayjs(dt)
    return d.isValid() ? d.format('HH:mm DD/MM/YYYY') : ''
}

/* ===== state ===== */
const store = useUserStore()
const route = useRoute()

const taskId = computed(() => Number(route.params.taskId || route.params.id))
const currentUserId = computed(() => store.currentUser?.id ?? null)
const canEditOrDelete = (item) =>
    String(item.user_id) === String(currentUserId.value) || !!store.currentUser?.is_admin


const pinnedGroupedByComment = computed(() => {
    if (!Array.isArray(pinnedFiles.value)) return [];

    // group theo batch (null batch tách riêng)
    const grouped = _.groupBy(pinnedFiles.value, f => {
        return f.upload_batch != null ? Number(f.upload_batch) : -1;
    });

    return Object.entries(grouped)
        .map(([batch, files]) => {
            const createdAt = _.minBy(files, f => new Date(f.created_at).getTime())?.created_at;
            return {
                batch: Number(batch),
                created_at: createdAt,
                files
            };
        })
        .filter(g => g.batch !== -1)   // bỏ group rác
        .sort((a, b) => a.batch - b.batch);
});


const inputValue = ref('')
const listComment = ref([])
const listUser = ref([])

const selectedFiles = ref([])

const loadingComment = ref(false)
const loadingUpdate = ref(false)

const totalPage = ref(1)
const currentPage = ref(1)
const uploading = ref(false)

/* ===== sticky + scroll helpers ===== */
const listEl = ref(null)
const footerEl = ref(null)
const listPadBottom = ref('96px')
let ro

function measureFooter() {
    const h = footerEl.value?.offsetHeight || 96
    listPadBottom.value = `${h + 8}px`
}

const currentUserRole = computed(() => store.currentUser?.role || '')

// cho file object f (có pinned_by)
function canUnpinFile(f) {
    if (!f) return false
    // super admin hoặc chính người đã ghim
    return String(currentUserRole.value) === 'super admin' || Number(f.pinned_by) === Number(currentUserId.value)
}

async function unpinOnly(file) {
    if (!file) return;

    const userId = Number(currentUserId.value);
    const userRole = currentUserRole.value;
    let tfId = getTaskFileId(file);
    const pathKey = normalizePath(file.file_path || file.link_url || '');

    if (!tfId) {
        const byPath = taskFileByPath.value[pathKey];
        tfId = byPath?.id ? Number(byPath.id) : null;
    }

    if (!tfId) {
        message.error('Không tìm thấy ID để bỏ ghim');
        return;
    }

    if (!canUnpinFile(file)) {
        message.warning('Bạn không có quyền bỏ ghim file này');
        return;
    }

    const lockKey = `unpin:${tfId}`
    if (pendingPinOps.has(lockKey)) return
    pendingPinOps.add(lockKey)

    // ===== optimistic remove from UI =====
    const prevPinned = (pinnedFiles.value || []).slice()
    pinnedFiles.value = (pinnedFiles.value || []).filter(p => {
        const pid = Number(p.id || p.task_file_id || 0)
        const sameId = pid && pid === Number(tfId)
        const samePath = normalizePath(p.file_path || p.link_url || '') === pathKey
        return !(sameId || samePath)
    })

    try {
        const res = await unpinTaskFileAPI(tfId, {user_id: userId, user_role: userRole})
        // success: keep optimistic removal, optionally show message from server
        message.success(res?.data?.message || 'Đã bỏ ghim')
        // don't immediately call loadPinnedFiles() — avoid re-adding during backend delay
    } catch (e) {
        console.error('unpin failed', e)
        // rollback: restore previous pinned list (or reload from server)
        pinnedFiles.value = prevPinned
        // if server returned 403/permission -> show nice msg
        const status = e?.response?.status
        if (status === 403) {
            message.warning(e.response?.data?.messages?.error || 'Bạn không có quyền')
        } else {
            message.error('Không thể bỏ ghim — thử lại')
        }
    } finally {
        pendingPinOps.delete(lockKey)
    }
}


function scrollToBottom() {
    const el = listEl.value
    if (!el) return
    el.scrollTop = el.scrollHeight
}

/* ===== task_files index để map file_path -> task_files.id ===== */
const taskFileByPath = ref({})
const normalizePath = (u = '') => {
    const s = String(u).split('?')[0]
    return s.replace(/\/+$/, '')
}

/* ===== Drawer người duyệt ===== */
const openApproverDrawer = ref(false)
const filterPendingOnly = ref(false)
const mentionsSelected = ref([])

const drawerMentions = computed(() => {
    const arr = mentionsSelected.value || []
    return filterPendingOnly.value
        ? arr.filter((m) => m.status === 'pending' || m.status === 'processing')
        : arr
})

/* ===== sticky expand/collapse ===== */
const isStickyExpanded = ref(false)
const MAX_FILES_COLLAPSED = 1
const pinnedFiles = ref([])

const hasPinnedOverflow = computed(() => (pinnedFiles.value?.length || 0) > MAX_FILES_COLLAPSED)

const toggleSticky = () => {
    if (!hasPinnedOverflow.value) return
    isStickyExpanded.value = !isStickyExpanded.value
}
const pinnedTotal = computed(() => pinnedFiles.value?.length || 0)

const visiblePinnedGroups = computed(() => {
    if (isStickyExpanded.value) {
        return pinnedGroupedByComment.value;
    }
    // collapsed → chỉ hiển thị batch mới nhất
    return pinnedGroupedByComment.value.slice(-1);
});

const arrowIcon = computed(() =>
    isStickyExpanded.value ? CaretUpOutlined : CaretDownOutlined
)
// store id/name người tạo task trả từ API /tasks/{id}/roster
const rosterCreatedBy = ref(null)
const rosterCreatedByName = ref(null)
const canModifyRoster = computed(() => {
    if (rosterCreatedBy.value == null) return false
    return String(rosterCreatedBy.value) === String(currentUserId.value)
})
const rosterProgress = ref(0)
const rosterAllApproved = ref(false)

// role code của current user — lấy từ store.currentUser.role_code hoặc session fallback
const currentRoleCode = computed(() => {
    // nếu store.currentUser có role_code thì dùng luôn
    const r = store?.currentUser?.role_code ?? store?.currentUser?.role
    return r ? String(r) : null
})

// helper: mapping role_code -> rank (số càng lớn = quyền càng cao)
function normalizeRoleCode(c = '') {
    return String(c || '').toLowerCase().replace(/\s+/g, '_') // 'super admin' -> 'super_admin'
}

function roleRank(code = '') {
    switch (normalizeRoleCode(code)) {
        case 'super_admin':
            return 3
        case 'admin':
            return 2
        case 'user':
            return 1
        default:
            return 0
    }
}

/* ===== task file helpers ===== */
function getTaskFileId(f = {}) {
    if (f.task_file_id || f.taskFileId) return Number(f.task_file_id || f.taskFileId)
    if (typeof f.id === 'number' && (f.file_path || f.link_url)) {
        const key = normalizePath(f.file_path || f.link_url)
        if (taskFileByPath.value[key]?.id === f.id) return f.id
    }
    const byPath = taskFileByPath.value[normalizePath(f.file_path || f.link_url || '')]
    return byPath?.id ? Number(byPath.id) : null
}

async function ensureTaskFileId(file, {autoPin = false} = {}) {
    const existed = getTaskFileId(file)
    if (existed) {
        if (autoPin) {
            try {
                await pinTaskFileAPI(existed, {user_id: store.currentUser.id});
                await loadPinnedFiles();
            } catch (e) { /* ignore pin error */
            }
        }
        return existed
    }

    const path = String(file.file_path ?? file.url ?? '')
    const name = file.file_name || file.name || prettyUrl(path)

    try {
        if (/^https?:\/\//i.test(path)) {
            const {data} = await uploadTaskFileLinkAPI(taskId.value, {
                title: name,
                url: path,
                user_id: Number(store.currentUser.id),
            })
            const created = Array.isArray(data) ? data[0] : data?.data || data
            const key = normalizePath(created?.file_path || created?.link_url || path)
            taskFileByPath.value[key] = {...(created || {}), file_path: created?.file_path || created?.link_url || path}

            const newId = Number(created?.id)
            if (autoPin && newId) {
                try {
                    await pinTaskFileAPI(newId, {user_id: store.currentUser.id});
                    await loadPinnedFiles();
                } catch (e) { /* handle pin error silently */
                }
            }
            return newId
        } else {
            const {data} = await adoptTaskFileFromPathAPI(taskId.value, {
                task_id: Number(taskId.value),
                user_id: Number(store.currentUser.id),
                file_path: path,
                file_name: name,
            })
            const created = data?.data || data
            const key = normalizePath(created?.file_path || path)
            taskFileByPath.value[key] = created
            const newId = Number(created?.id)
            if (autoPin && newId) {
                try {
                    await pinTaskFileAPI(newId, {user_id: store.currentUser.id});
                    await loadPinnedFiles();
                } catch (e) { /* ignore */
                }
            }
            return newId
        }
    } catch (e) {
        console.error('ensureTaskFileId error', e?.response?.data || e)
        message.error('Không tạo được tài liệu để ghim')
        return null
    }
}


async function loadTaskFiles() {
    try {
        const {data} = await getTaskFilesAPI(taskId.value)
        const files = Array.isArray(data) ? data : data?.data || []
        const idx = {}
        for (const f of files) {
            const key = normalizePath(f.file_path || f.link_url || '')
            if (key) idx[key] = {...f, file_path: f.file_path || f.link_url || ''}
        }
        taskFileByPath.value = idx
    } catch (e) {
        console.error('loadTaskFiles error', e)
        taskFileByPath.value = {}
    }
}

const pendingPinOps = new Set()

/* ===== file kind helpers ===== */
const IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'])
const PDF_EXTS = new Set(['pdf'])
const WORD_EXTS = new Set(['doc', 'docx'])
const EXCEL_EXTS = new Set(['xls', 'xlsx', 'csv'])
const PPT_EXTS = new Set(['ppt', 'pptx'])

const extOf = (name = '') => {
    const n = String(name).split('?')[0]
    const m = n.lastIndexOf('.')
    return m >= 0 ? n.slice(m + 1).toLowerCase() : ''
}

function detectKind(o = {}) {
    const t = o.file_type || ''
    if (t) {
        if (String(t).startsWith('image/')) return 'image'
        if (t === 'application/pdf') return 'pdf'
    }
    const e = extOf(o.name || o.url || '')
    if (IMAGE_EXTS.has(e)) return 'image'
    if (PDF_EXTS.has(e)) return 'pdf'
    if (WORD_EXTS.has(e)) return 'word'
    if (EXCEL_EXTS.has(e)) return 'excel'
    if (PPT_EXTS.has(e)) return 'ppt'
    if (/^https?:\/\//i.test(o.url || '')) return 'link'
    return 'other'
}

function pickIcon(k) {
    switch (k) {
        case 'pdf':
            return FilePdfOutlined
        case 'word':
            return FileWordOutlined
        case 'excel':
            return FileExcelOutlined
        case 'ppt':
            return FilePptOutlined
        case 'link':
            return LinkOutlined
        default:
            return FileTextOutlined
    }
}

function prettyUrl(u) {
    try {
        const url = new URL(u)
        const path = url.pathname.replace(/^\/+/, '')
        const short = path.length > 30 ? path.slice(0, 30) + '…' : path
        return url.host + (short ? '/' + short : '')
    } catch {
        return u
    }
}

const hrefOf = (f = {}) => f.file_path || f.link_url || ''
const titleOf = (f = {}) => f.file_name || f.title || prettyUrl(hrefOf(f))
const kindOfCommentFile = (f = {}) => detectKind({name: f.file_name, url: hrefOf(f), file_type: f.file_type})

function isOfficeKind(kind) {
    return kind === 'word' || kind === 'excel' || kind === 'ppt'
}

function absUrl(u = '') {
    try {
        const url = new URL(u, window.location.origin)
        return url.toString()
    } catch {
        return u
    }
}

function officeViewerUrl(u = '') {
    const absolute = absUrl(u)
    return `https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(absolute)}`
}

function displayHrefOf(f = {}) {
    return f.file_path || f.link_url || '';
}

// format date helper (sử dụng dayjs đã import)
const formatDate = (v) => {
    try {
        return v ? dayjs(v).format('DD/MM/YYYY HH:mm') : 'Không rõ thời gian'
    } catch {
        return 'Không rõ thời gian'
    }
}

// Lấy tên người ghim: ưu tiên trường pinned_by_name, fallback dùng danh sách user
function nameOfPinnedBy(f) {
    if (!f) return 'Không rõ'
    if (f.pinned_by_name) return f.pinned_by_name
    const id = Number(f.pinned_by || 0)
    if (id && getUserById(id)?.name) return getUserById(id).name
    // nếu uploaded_by có tên hữu ích
    if (f.uploaded_by && getUserById(Number(f.uploaded_by))?.name) return getUserById(Number(f.uploaded_by)).name
    return f.pinned_by ? String(f.pinned_by) : 'Không rõ'
}

// xây tooltip — trả chuỗi nhiều dòng (Antd sẽ hiển thị \n như xuống dòng)
const pinTooltip = (f) => {
    if (!f) return ''
    const by = nameOfPinnedBy(f)
    const at = formatDate(f.pinned_at || f.updated_at || f.created_at)

    return `<div><strong>Ghim bởi:</strong> ${by}<br><strong>Thời gian:</strong> ${at}</div>`
}



/* ===== Roster actions (Drawer) ===== */
async function handleApproveAction(m, status) {

    if (!['approved', 'rejected'].includes(status)) return;

    if (!canActOnChip(m)) {
        message.warning('Bạn không có quyền thực hiện hành động này (chia lượt duyệt)');
        return;
    }

    const uid  = Number(m.user_id);
    const dept = Number(m.department_id);

    // loading
    if (!approveLoading.value[uid]) approveLoading.value[uid] = {};
    if (!approveLoading.value[uid][dept]) approveLoading.value[uid][dept] = {};
    approveLoading.value[uid][dept][status] = true;

    try {

        await approveRosterAPI(taskId.value, m.note ?? null);

        // ⭐ Replace marker cho người đang duyệt
        await replaceMarkerInTaskFile(taskId.value, uid, dept);

        // ⭐ đồng bộ lại
        await syncRosterFromServer();

        message.success("Đã duyệt");

    } catch (e) {
        console.error("handleApproveAction error", e);
        message.error("Xử lý không thành công");

    } finally {
        approveLoading.value[uid][dept][status] = false;
    }
}

// wrapper: persist roster by replace (calls mergeTaskRosterAPI or direct axios)
async function persistRosterWithPayload(payload) {
    try {
        const mentions = Array.isArray(payload.mentions)
            ? payload.mentions.map(x => ({
                user_id: Number(x.user_id),
                name: x.name,
                role: x.role,
                status: x.status,
                acted_at: x.acted_at || null,
                note: x.note || null,
                department_id: x.department_id ?? null,
                signature_code: x.signature_code ?? null,
            }))
            : [];

        const mode = payload.mode || "merge"; // mặc định merge

        await mergeTaskRosterAPI(taskId.value, mentions, mode);
    } catch (e) {
        console.error("persistRosterWithPayload failed", e);
        throw e;
    }
}




/* users & mentions add/remove */
const getUserById = (id) => listUser.value.find((u) => u.id === id) || {}
const userOptions = computed(() =>
    sortedUsers.value.map(u => ({
        label: u.name,
        value: String(u.id),
    }))
);
const filterUser = (input, option) => (option?.label ?? '').toLowerCase().includes(String(input).toLowerCase())

const selectedUser = computed(() => {
    return listUser.value.find(u => String(u.id) === String(mentionForm.value.userId)) || null;
});

const departmentColors = computed(() => {
    const colors = ["blue", "green", "orange", "purple", "cyan", "magenta", "geekblue", "volcano", "gold", "lime",];

    const map = {};
    let index = 0;

    for (const d of props.departments) {
        map[d.id] = colors[index % colors.length];
        index++;
    }

    return map;
});


const BGD = 6; // ID phòng ban Ban Giám đốc
const sortedUsers = computed(() => {
    return [...props.users].sort((a, b) => {
        // 1) Ban Giám đốc lên đầu
        const aIsBGD = Number(a.department_id) === BGD ? 0 : 1;
        const bIsBGD = Number(b.department_id) === BGD ? 0 : 1;

        if (aIsBGD !== bIsBGD) {
            return aIsBGD - bIsBGD;
        }

        // 2) Nhóm theo phòng ban
        if (Number(a.department_id) !== Number(b.department_id)) {
            return Number(a.department_id) - Number(b.department_id);
        }

        // 3) Sort theo tên trong cùng phòng
        return a.name.localeCompare(b.name, "vi");
    });
});

const multiRoles = {
    vu_thi_thuy_bgd: { department_id: 6, marker_code: "vu_thi_thuy_bgd" },
    vu_thi_thuy_kt:  { department_id: 2, marker_code: "vu_thi_thuy_kt" },
    vu_thi_thuy_tm:  { department_id: 4, marker_code: "vu_thi_thuy_tm" }
};

let addMentionOpen = ref(false)
const mentionForm = ref({
    userId: null,
    role: null   // role = "bgd" | "kt" | "tm"
});
function resetMentionForm() {
    mentionForm.value.userId = null
    mentionForm.value.role = 'approve'
    closeMentionPopover()
}

const addAccess = async (entityType, entityId, userId) => {
    if (!entityType || !entityId || !userId) return;
    try {
        await addEntityMember({
            entity_type: entityType,
            entity_id: Number(entityId),
            user_id: Number(userId)
        });
        console.log(`✔ Added access: ${entityType}#${entityId} → user ${userId}`);
    } catch (e) {
        console.warn("⚠ Không thể thêm quyền truy cập:", e);
    }
};

const addMention = async () => {
    const uid = mentionForm.value.userId;
    if (!uid) return;

    const user = listUser.value.find(u => String(u.id) === String(uid));
    const displayName = user?.name || `#${uid}`;

    let departmentId = null;
    let signatureCode = null;

    // ======================================================
    // ⭐ XÁC ĐỊNH department_id + signature_code
    // ======================================================
    if (Number(user?.is_multi_role) === 1) {

        const roleKey = mentionForm.value.role;         // "bgd" | "kt" | "tm"
        const selected = multiRoles[roleKey];           // LẤY OBJECT TỪ MAP

        if (!selected) {
            message.warning("Vui lòng chọn vai trò/phòng ban duyệt");
            return;
        }

        departmentId = selected.department_id;
        signatureCode = selected.marker_code;

    } else {
        // User 1 vai trò
        departmentId = Number(user?.department_id);
        signatureCode = user?.signature_code ?? null;
    }

    // ======================================================
    // ⭐ CHECK TRÙNG
    // ======================================================
    if (Number(user?.is_multi_role) !== 1) {
        // --- User 1 vai trò → chỉ 1 lần duy nhất ---
        if (mentionsSelected.value.some(m => String(m.user_id) === String(uid))) {
            message.info("Người này đã có trong danh sách");
            insertMention(displayName);
            addMentionOpen.value = false;
            return;
        }
    } else {
        // --- User đa vai trò → cho phép nhiều vai trò ---
        const roleKey = mentionForm.value.role;
        const selected = multiRoles[roleKey];

        // ❗ Nếu FE chưa chọn role (selected = null) → chặn
        if (!selected) {
            message.warning("Vui lòng chọn vai trò/phòng ban duyệt");
            return;
        }

        // Check trùng theo composite key (user_id + department_id)
        const isDup = mentionsSelected.value.some(m =>
            String(m.user_id) === String(uid) &&
            Number(m.department_id) === Number(selected.department_id)
        );

        if (isDup) {
            message.info("Người này đã có trong danh sách với đúng vai trò này");
            insertMention(displayName);
            addMentionOpen.value = false;
            return;
        }

    }


    // ======================================================
    // ⭐ PUSH MENTION
    // ======================================================
    mentionsSelected.value.push({
        user_id: Number(uid),
        name: displayName,
        role: "approve",                          // ⭐ FE luôn gửi approve
        department_id: departmentId,              // ⭐ đúng
        signature_code: signatureCode,            // ⭐ đúng marker_code
        status: "pending",
        added_at: new Date().toISOString().slice(0,19).replace("T"," ")
    });


    insertMention(displayName);
    addMentionOpen.value = false;

    try {
        await persistRoster("merge");
        await syncRosterFromServer();
        message.success("Đã thêm người duyệt");

        // ==================================================
        // ⭐ AUTO-GRANT ACCESS
        // ==================================================
        let entityType = null;
        let entityId = null;

        if (route.path.includes("/biddings/")) {
            entityType = "bidding";
            entityId = Number(route.params.bidId || route.params.id);
        } else if (route.path.includes("/contract/")) {
            entityType = "contract";
            entityId = Number(route.params.contractId || route.params.id);
        } else {
            entityType = "internal";
            entityId = Number(taskId.value);
        }

        await addAccess(entityType, entityId, uid);

    } catch (err) {
        console.error("addMention persist failed", err);
        message.error("Không thể thêm người duyệt — thử lại");

        // rollback
        mentionsSelected.value = mentionsSelected.value.filter(
            m => String(m.user_id) !== String(uid)
        );
    }

    await nextTick();
    document.querySelector(".tg-input textarea.ant-input")?.focus?.();
};



function closeMentionPopover() {
    addMentionOpen.value = false
}

function insertMention(displayName) {
    let v = String(inputValue.value || '')
    v = v.replace(/[ \t]+$/u, '')
    if (/@[^@\s]*$/u.test(v)) {
        v = v.replace(/@[^@\s]*$/u, `@${displayName}`)
    } else {
        if (v && !/\s$/u.test(v)) v += ' '
        v += `@${displayName}`
    }
    inputValue.value = `${v} `
}

function removeMention(m) {
    if (!canModifyRoster.value) {
        message.warning('Chỉ người tạo task mới được xóa người duyệt');
        return;
    }

    const uid = Number(m.user_id);
    const dept = Number(m.department_id ?? 0);

    mentionsSelected.value = mentionsSelected.value.filter(item =>
        !(Number(item.user_id) === uid && Number(item.department_id) === dept)
    );

    const payload = {
        mentions: mentionsSelected.value,
        mode: "replace"
    };

    persistRosterWithPayload(payload);
}



const metaTime = (m) =>
    m.status === 'approved' || m.status === 'rejected'
        ? m.acted_at_vi || formatVi(m.acted_at)
        : m.added_at_vi || formatVi(m.added_at)
const statusDotClass = (status) => (status === 'approved' ? 'ok' : status === 'rejected' ? 'err' : 'proc')


// TÌM NHANH TRONG DRAWER
const drawerSearch = ref('')

// Lọc cuối cùng cho UI (áp dụng search sau filterPendingOnly)
const finalDrawerMentions = computed(() => {
    const arr = drawerMentions.value || []
    const q = vnNorm(drawerSearch.value || '')
    if (!q) return arr
    return arr.filter(m => vnNorm(m.name || '').includes(q))
})

// Khi finalDrawerMentions thay đổi (filter/search), cập nhật dragList
watch(finalDrawerMentions, (v) => {
    dragList.value = Array.isArray(v) ? v.map(x => ({...x})) : []
}, {immediate: true, deep: true})


/* input mention detect */
// function onInputDetectMention(e) {
//     const v = String(e?.target?.value ?? '')
//     if (v.endsWith('@')) addMentionOpen.value = true
// }

/* ===== upload handlers (single file) ===== */
async function handleBeforeUpload(file) {
    if (rosterAllApproved.value) {
        message.warning("Hồ sơ đã duyệt xong, không thể upload thêm tài liệu.");
        return false; // CHẶN LUÔN
    }

    if (selectedFiles.value.length >= 3) {
        message.warning("Chỉ được đính kèm tối đa 3 file");
        return false;
    }

    selectedFiles.value.push(file);
    return false;
}


function removeFile(index) {
    selectedFiles.value.splice(index, 1);
}

/* gửi comment */
const canSend = computed(() => {
    return (
        !!inputValue.value.trim() ||
        selectedFiles.value.length > 0 ||
        (mentionsSelected.value?.length > 0)
    );
});

function vnNorm(s = '') {
    return (s == null ? '' : String(s)).normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim()
}

const userNameMap = computed(() => {
    const map = new Map()
    for (const u of listUser.value || []) {
        const key = vnNorm(u.name || '')
        if (key) map.set(key, u)
    }
    return map
})


const copyTag = async (text) => {
    if (navigator && navigator.clipboard && navigator.clipboard.writeText) {
        try {
            await navigator.clipboard.writeText(text);
            message.success(`Đã copy: ${text}`);
            return;
        } catch (e) {
            console.warn('Clipboard API lỗi, fallback execCommand', e);
        }
    }

    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.setAttribute('readonly', '');
    textarea.style.position = 'absolute';
    textarea.style.left = '-9999px';
    document.body.appendChild(textarea);
    textarea.select();

    try {
        const ok = document.execCommand('copy');
        if (ok) {
            message.success(`Đã copy: ${text}`);
        } else {
            message.error('Copy thất bại (execCommand)');
        }
    } catch (e) {
        console.error(e);
        message.error('Copy thất bại');
    } finally {
        document.body.removeChild(textarea);
    }
};

function extractMentionsFromInput(input = '') {
    const out = []
    if (!input) return out
    const re = /@([^\n\r@]+)/g
    let m
    while ((m = re.exec(input))) {
        const raw = m[1].trim()
        if (!raw) continue
        const cleaned = raw.replace(/[.,;:!?)\]}]+$/, '').trim()
        const key = vnNorm(cleaned)
        const u = userNameMap.value.get(key)
        if (u) out.push({user_id: String(u.id), name: u.name, role: 'approve', status: 'pending'})
    }
    return out
}

function dedupeMentions(arr = []) {
    const seen = new Set()
    const res = []
    for (const m of arr) {
        const id = String(m.user_id)
        if (seen.has(id)) continue
        seen.add(id)
        res.push(m)
    }
    return res
}

async function createNewComment({keepMentions = false} = {}) {
    if (!canSend.value || uploading.value) return;

    uploading.value = true;

    try {
        // ==== 1) Gom mentions trong UI + mentions lấy từ text ====
        const textMentions = extractMentionsFromInput(inputValue.value);
        const mergedMentions = dedupeMentions([
            ...(mentionsSelected.value || []),
            ...textMentions,
        ]);

        const mentionsPayload = mergedMentions.map(m => ({
            user_id: Number(m.user_id),
            name: m.name,
            role: m.role,
            status: m.status || "pending",
        }));

        // ==== 2) Build FormData ====
        const form = new FormData();
        form.append("user_id", store.currentUser.id);
        form.append("content", inputValue.value || "");
        form.append("mentions", JSON.stringify(mentionsPayload));

        // ==== 3) Multi-file upload ====
        if (selectedFiles.value.length) {

            if (rosterAllApproved.value) {
                message.warning("Hồ sơ đã duyệt xong — không thể đính kèm file.");
                uploading.value = false;
                return;
            }

            // 🚫 CHẶN FILE PDF
            for (const f of selectedFiles.value) {
                const ext = f.name.split('.').pop().toLowerCase();
                if (ext === "pdf") {
                    uploading.value = false;
                    message.error("Không được phép upload file PDF.");
                    return;
                }
            }

            // → Nếu hợp lệ thì append
            for (const f of selectedFiles.value) {
                form.append("attachments[]", f, f.name);
            }
        }


        // ==== 4) Gửi comment ====
        const res = await createComment(taskId.value, form);

        // ==== 5) Auto-pin file backend trả về ====
        try {
            const commentData = res?.data?.comment || res?.data || {};

            const files = Array.isArray(commentData?.files) ? commentData.files : [];

            if (files.length) {
                for (const f of files) {
                    try {
                        await ensureTaskFileId(
                            {
                                file_name: f.file_name,
                                file_path: f.file_path,
                                link_url: f.public_url || f.file_path,
                            },
                            {autoPin: true}
                        );
                    } catch (e) {
                        console.warn("Auto-pin file failed:", f, e);
                    }
                }

                await loadPinnedFiles();
            }
        } catch (e) {
            console.warn("Auto-pin stage failed:", e);
        }

        // ==== 6) Reset UI ====
        inputValue.value = "";
        selectedFiles.value = [];
        mentionsSelected.value = keepMentions ? mergedMentions : [];

        // ==== 7) Refresh UI ====
        await getListComment(1);
        await syncRosterFromServer();
        await loadPinnedFiles();

        await nextTick();
        scrollToBottom();

        message.success("Đã gửi bình luận");

        return res;
    } catch (err) {
        console.error("createNewComment error", err);

        const msg =
            err?.response?.data?.messages?.attachment ||
            err?.response?.data?.message ||
            err?.response?.data?.errors ||
            "Không gửi được bình luận";

        message.error(
            typeof msg === "string" ? msg : "Không gửi được bình luận"
        );

        throw err;
    } finally {
        uploading.value = false;
    }
}


// helper: sắp xếp mảng comment theo created_at tăng dần (cũ -> mới)
function sortCommentsAsc(comments = []) {
    return (comments || []).slice().sort((a, b) => {
        const ta = a?.created_at ? new Date(a.created_at).getTime() : 0
        const tb = b?.created_at ? new Date(b.created_at).getTime() : 0
        return ta - tb
    })
}


/* ===== list (paging) ===== */
async function getListComment(page = 1) {
    loadingComment.value = true
    try {
        const res = await getComments(taskId.value, {page})
        // change here depending on API shape:
        const rawComments = res?.data?.comments ?? []
        // ensure comments are sorted oldest -> newest
        const sorted = sortCommentsAsc(Array.isArray(rawComments) ? rawComments : [])

        const el = listEl.value

        if (page === 1) {
            // page 1: replace whole list and scroll to bottom so newest visible
            listComment.value = sorted
            await nextTick()
            measureFooter()
            scrollToBottom()
        } else {
            // page > 1: assume API returned older messages for this page.
            // We want to prepend older messages to the top and keep scroll position stable.
            const prevScrollHeight = el ? el.scrollHeight : 0

            // prepend older items
            listComment.value = [...sorted, ...(listComment.value || [])]

            await nextTick()
            measureFooter()
            if (el) {
                // keep viewport at the same visual message:
                el.scrollTop = (el.scrollTop || 0) + (el.scrollHeight - prevScrollHeight)
            }
        }

        // update paging info (unchanged)
        totalPage.value = Number(res?.data?.pagination?.totalPages ?? 1)
        currentPage.value = page
    } catch (e) {
        console.error(e)
    } finally {
        loadingComment.value = false
    }
}

// Hàm nhận diện link & chèn HTML có thẻ <a>
function formatMessage(content = '') {
    if (!content) return ''
    const text = String(content)
    // regex nhận link: bắt https:// hoặc www.
    const urlRegex = /(https?:\/\/[^\s]+|www\.[^\s]+)/gi
    return text.replace(urlRegex, (url) => {
        const href = url.startsWith('http') ? url : `https://${url}`
        const host = getHost(href)
        return `
      <a href="${href}" target="_blank" rel="noopener noreferrer" class="msg-link">
        <img src="${faviconOf(href)}" alt="" class="msg-link-favicon"/>
        <span class="msg-link-text">${host}</span>
      </a>
    `
    })
}

function getHost(u = '') {
    try {
        const url = new URL(u)
        return url.host.replace(/^www\./, '')
    } catch {
        return u
    }
}

function faviconOf(u = '') {
    try {
        const host = new URL(u).host
        return `https://icons.duckduckgo.com/ip3/${host}.ico`
    } catch {
        return 'https://icons.duckduckgo.com/ip3/example.com.ico'
    }
}

/* ===== users ===== */
// async function getUser() {
//     try {
//         const {data} = await getUsers()
//         listUser.value = Array.isArray(data) ? data : data?.data ?? []
//     } catch (e) {
//         message.error('Không thể tải người dùng')
//     }
// }

/* ===== roster sync/persist ===== */
async function persistRoster(mode = 'merge') {
    try {
        const payload = mentionsSelected.value.map((m) => ({
            user_id: Number(m.user_id),
            name: m.name,
            role: m.role,
            department_id: m.department_id ?? null,   // ⭐ THÊM DÒNG NÀY
            signature_code: m.signature_code ?? null,   // ⭐ THÊM DÒNG NÀY
            status: m.status ?? 'pending',
        }))

        await mergeTaskRosterAPI(taskId.value, payload, mode)
        await syncRosterFromServer()

    } catch (e) {
        console.error('persistRoster error', e)
        message.error('Không thể lưu danh sách người duyệt/ký')
    }
}


async function loadPinnedFiles() {
    try {
        const res = await getPinnedFilesAPI(taskId.value)
        let arr = []
        if (Array.isArray(res.data)) arr = res.data
        else if (Array.isArray(res.data?.pinned_files)) arr = res.data.pinned_files
        else if (Array.isArray(res.data?.files)) arr = res.data.files.filter((x) => Number(x.is_pinned) === 1)
        else {
            const filesRes = await getTaskFilesAPI(taskId.value)
            const filesArr = Array.isArray(filesRes.data)
                ? filesRes.data
                : Array.isArray(filesRes.data?.data)
                    ? filesRes.data.data
                    : []
            arr = filesArr.filter((x) => Number(x.is_pinned) === 1)
        }
        pinnedFiles.value = (arr || []).map((x) => ({
            ...x,
            file_path: x.file_path || x.link_url || '',
            title: x.title || x.file_name || '',
        }))
    } catch (e) {
        console.error('loadPinnedFiles error', e)
        pinnedFiles.value = []
    }
}

function prettySize(bytes) {
    if (!bytes) return '0 KB'
    const kb = bytes / 1024
    if (kb < 1024) return kb.toFixed(1) + ' KB'
    return (kb / 1024).toFixed(1) + ' MB'
}

async function syncRosterFromServer() {
    try {
        const {data} = await getTaskRosterAPI(taskId.value)
        const roster = data?.roster || data || []

        rosterCreatedBy.value = data?.created_by ?? null
        rosterCreatedByName.value = data?.created_by_name ?? null

        latestBatch.value = data.latest_upload_batch || null
        latestFiles.value = data.latest_files || []
        latestBatchMeta.value = data.latest_batch_meta || null

        // 👉 thêm 2 dòng này
        rosterProgress.value = data?.progress ?? 0
        rosterAllApproved.value = data?.all_approved ?? false

        mentionsSelected.value = (Array.isArray(roster) ? roster : []).map((r) => ({
            user_id: String(r.user_id),
            name: r.name,
            role: r.role,
            status: r.status || 'processing',
            acted_at: r.acted_at || null,
            acted_at_vi: r.acted_at_vi || null,
            added_at: r.added_at || null,
            added_at_vi: r.added_at_vi || null,
            department_id: r.department_id ?? null,   // ⭐ đảm bảo giữ phòng ban
            signature_code: r.signature_code ?? null, // ⭐ GIỮ MÃ KÝ
        }))
    } catch (e) {
        console.error('syncRosterFromServer failed', e)
    }
}

/* ===== composer behavior: Enter/Shift+Enter + Esc ===== */
function onComposerKeydown(e) {
    if (e.key === 'Escape' && isEditing.value) {
        e.preventDefault()
        cancelEdit()
        return
    }
    if (e.key !== 'Enter') return
    if (e.shiftKey) return
    e.preventDefault()
    if (canSend.value) void onSubmit()
}

/* ===== inline edit state ===== */
const editingCommentId = ref(null)
const isEditing = computed(() => !!editingCommentId.value)

function cancelEdit() {
    editingCommentId.value = null
    inputValue.value = ''
}


function getRank(member) {
    // role_code lấy từ API (đã có trong roster)
    const role = (member.role_code || member.role || '').toLowerCase();

    if (role === 'super_admin') return 3;
    if (role === 'admin') return 2;

    return 1; // user
}

const normalizePositionCode = (code) => (code || '').toLowerCase()


function canActOnChip(m) {
    if (!m || (m.status || '').toLowerCase() !== 'pending') return false;

    const curUid  = String(currentUserId.value);
    const targetUid = String(m.user_id);

    const rosterArr = mentionsSelected.value || [];

    const curPos = normalizePositionCode(getUserById(currentUserId.value)?.position_code);
    const chipPos = normalizePositionCode(getUserById(m.user_id)?.position_code);

    /* ================================================
       1️⃣ EXECUTIVE — Giám đốc
       Không được ký trước executive phía trên
    ================================================= */
    if (curPos === 'executive') {

        const executives = rosterArr.filter(r =>
            normalizePositionCode(getUserById(r.user_id)?.position_code) === 'executive'
        );

        const iCur  = executives.findIndex(r => String(r.user_id) === curUid);
        const iChip = executives.findIndex(r => String(r.user_id) === targetUid);

        // Nếu tôi & chip đều là executive
        if (iChip >= 0 && iCur >= 0) {

            if (iCur > 0) {
                const previous = executives[iCur - 1];
                if ((previous.status || '').toLowerCase() !== 'approved') return false;
            }

            return iCur === iChip;
        }

        // executive có thể duyệt tất cả cấp dưới
        return true;
    }

    /* ================================================
       2️⃣ SENIOR MANAGER — Phó giám đốc
       Không được vượt executive & không vượt senior_manager đứng trước
    ================================================= */
    if (curPos === 'senior_manager') {

        // Nếu chip là executive → KO ĐƯỢC KÝ
        if (chipPos === 'executive') return false;

        // Lấy danh sách senior_manager theo thứ tự
        const seniors = rosterArr.filter(r =>
            normalizePositionCode(getUserById(r.user_id)?.position_code) === 'senior_manager'
        );

        const iCur  = seniors.findIndex(r => String(r.user_id) === curUid);
        const iChip = seniors.findIndex(r => String(r.user_id) === targetUid);

        if (iChip >= 0 && iCur >= 0) {
            if (iCur > 0) {
                const previous = seniors[iCur - 1];
                if ((previous.status || '').toLowerCase() !== 'approved') return false;
            }

            return iCur === iChip;
        }

        // Phó giám đốc có thể duyệt cấp dưới
        return true;
    }

    /* ================================================
       3️⃣ MANAGER — Trưởng phòng
       Giống admin cũ, không được vượt manager phía trên
    ================================================= */
    if (curPos === 'manager') {

        // Không được ký trước executive hoặc senior_manager
        if (['executive', 'senior_manager'].includes(chipPos)) return false;

        const managers = rosterArr.filter(r =>
            normalizePositionCode(getUserById(r.user_id)?.position_code) === 'manager'
        );

        const iCur  = managers.findIndex(r => String(r.user_id) === curUid);
        const iChip = managers.findIndex(r => String(r.user_id) === targetUid);

        if (iChip >= 0 && iCur >= 0) {
            if (iCur > 0) {
                const previous = managers[iCur - 1];
                if ((previous.status || '').toLowerCase() !== 'approved') return false;
            }

            return iCur === iChip;
        }

        // Manager chỉ được duyệt staff
        return chipPos === 'staff';
    }

    /* ================================================
       4️⃣ STAFF — Nhân viên
       Chỉ ký được chính mình, và phải là pending đầu tiên
    ================================================= */
    const firstPending = rosterArr.find(r => (r.status || '').toLowerCase() === 'pending');

    return firstPending && String(firstPending.user_id) === curUid;
}




async function handleUpdateCommentInline() {
    if (!editingCommentId.value) return
    const newContent = String(inputValue.value || '').trim()
    if (!newContent) {
        message.warning('Nội dung trống')
        return
    }
    loadingUpdate.value = true
    try {
        await updateComment(editingCommentId.value, {content: newContent})
        editingCommentId.value = null
        inputValue.value = ''
        await getListComment(currentPage.value)
        message.success('Đã cập nhật bình luận')
    } catch (e) {
        message.error('Không thể cập nhật bình luận')
    } finally {
        loadingUpdate.value = false
    }
}

async function onSubmit() {
    if (isEditing.value) return handleUpdateCommentInline()
    return createNewComment()
}

/* ===== misc ===== */
function bustUrl(u, ver) {
    if (!u) return u
    const sep = u.includes('?') ? '&' : '?'
    return `${u}${sep}v=${ver || Date.now()}`
}

function srcWithBustIfImage(f) {
    const u = hrefOf(f)
    return kindOfCommentFile(f) === 'image'
        ? bustUrl(u, f.updated_at || f.acted_at || f.added_at || Date.now())
        : u
}

const canFinalSign = computed(() => {
    if (!rosterAllApproved.value) return false;

    const myRank = roleRank(currentRoleCode.value);

    // super_admin hoặc admin được ký
    if (myRank >= roleRank("admin")) return true;

    // Hoặc chính người cuối cùng trong danh sách được ký
    const last = [...(mentionsSelected.value || [])].reverse().find(m => true);
    if (!last) return false;

    return String(last.user_id) === String(currentUserId.value);
});

function canSign(m) {
    // chỉ cho ký khi đã duyệt xong toàn bộ
    if (!rosterAllApproved.value) return false;

    // user chỉ ký nếu họ là người cuối cùng
    const isMe = String(m.user_id) === String(currentUserId.value);

    // hoặc Admin/Super admin ký thay
    const myRank = roleRank(currentRoleCode.value);
    if (myRank >= roleRank("admin")) return true;

    return isMe;
}
const handleUploadConfirm = ({ files, userIds }) => {
    // 1️⃣ Gắn file vào logic hiện tại
    selectedFiles.value.push(...files)

    // 2️⃣ Nếu muốn auto mention / auto assign user
    userIds.forEach(uid => {
        const u = listUser.value.find(x => x.id === uid)
        if (u) {
            insertMention(u.name)
        }
    })
}


/* ===== lifecycle ===== */
onMounted(async () => {
    t = setInterval(() => (tick.value = Date.now()), 60_000)
    // await getUser()
    await getListComment(1)
    await loadTaskFiles()
    await loadPinnedFiles()
    await syncRosterFromServer()
    measureFooter()
    if ('ResizeObserver' in window) {
        ro = new ResizeObserver(() => measureFooter())
        footerEl.value && ro.observe(footerEl.value)
    }
})
watch(
    () => props.users,
    (val) => {
        listUser.value = Array.isArray(val) ? val : []
    },
    { immediate: true }
)

const localRoster = ref([])

watch(() => props.roster, (v) => {
    console.log("🔥 props.roster:", v)
})

// đồng bộ khi prop thay đổi
watch(
    () => props.roster,
    (v) => {
        localRoster.value = (v || []).map(r => ({
            ...r,
            department_id: r.department_id ?? r.dept_id ?? null,   // ⭐ GẮN ĐÚNG
            signature_code: r.signature_code ?? null,
        }))
    },
    { immediate: true }
)
onBeforeUnmount(() => {
    clearInterval(t)
    ro?.disconnect?.()
})
</script>

<style scoped>
:where(.comment) {
    --bg-surface: #fff;
    --bg-subtle: #f0f4f7;
    --bd-soft: #e6ebf1;
    --txt-main: #24292f;
    --txt-muted: #6b7a8c;
    --txt-faint: #8aa0b4;
    --blue-1: #eef6ff;
    --blue-2: #cfe3ff;
    --blue-3: #2a86ff;
    --green-1: #f6ffed;
    --green-2: #b7eb8f;
    --red-1: #fff2f0;
    --red-2: #ffccc7;
}

/* Layout tổng */
.comment {
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 0;
}

/* Sticky header */
.sticky-mentions {
    position: sticky;
    top: 0;
    z-index: 9;
    background: var(--bg-surface);
    border-bottom: 1px solid #eef1f3;
    backdrop-filter: saturate(1.2) blur(0px);
}

.sticky-head {
    display: grid;
    grid-template-columns: 1fr auto;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    padding-left: 0;
    border-bottom: 1px solid #eef1f3;
    background: var(--bg-surface);
}

.pinned-toggle {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 10px;
    border: 1px solid transparent;
    border-radius: 8px;
    background: transparent;
    cursor: pointer;
    line-height: 1;
    transition: background-color .15s ease, border-color .15s ease, box-shadow .15s ease, transform .04s ease;
}

.pinned-toggle:hover:not(:disabled) {
    background: #f6f9ff;
    border-color: #e6efff;
}

.pinned-toggle:focus-visible {
    outline: none;
    box-shadow: 0 0 0 3px rgba(45, 140, 240, .2);
}

.pinned-toggle:disabled {
    cursor: default;
    opacity: .6;
}

.sticky-title {
    font-weight: 600;
    color: #1f2937;
}

.sticky-count {
    color: #64748b;
    font-size: 12px;
}

.arrow {
    font-size: 12px;
    opacity: .9;
    transform: translateY(1px);
}

.sticky-actions {
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.approver-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 0 8px !important;
    height: 28px;
    border-radius: 6px;
}

.approver-btn:hover {
    background: #f6f9ff;
}

.approver-text {
    margin-left: 4px;
}

/* List comments */
.list-comment {
    height: 45vh;
    flex: 1 1 auto;
    overflow: auto;
    padding: 8px 10px 0;
    scrollbar-width: thin;
    scrollbar-color: rgba(0, 0, 0, 0.35) transparent;
}

.list-comment::-webkit-scrollbar {
    width: 6px;
}

.list-comment::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.28);
    border-radius: 8px;
}

/* Bubbles */
.tg-row {
    display: flex;
    gap: 8px;
    margin: 8px 0;
}

.tg-row.me {
    justify-content: flex-end;
}

.tg-row .avatar {
    align-self: flex-end;
}

.bubble {
    max-width: 72%;
    position: relative;
    padding: 8px 10px 6px;
    background: var(--bg-surface);
    border: 1px solid #e6ebf0;
    border-radius: 12px 12px 12px 4px;
    box-shadow: 0 1px 0 rgba(0, 0, 0, 0.03);
}

.bubble.me {
    background: #eaf2ff;
    border-color: #cfe0ff;
    border-radius: 12px 12px 4px 12px;
}

.bubble .actions {
    position: absolute;
    right: 4px;
    top: 4px;
}

.bubble .actions :deep(.ant-btn) {
    padding: 0 6px;
}

.bubble .author {
    font-size: 12px;
    color: var(--txt-muted);
    margin-bottom: 2px;
}

.bubble .text {
    white-space: pre-wrap;
    line-height: 1.38;
    color: var(--txt-main);
}

.bubble .meta {
    font-size: 11px;
    color: var(--txt-faint);
    margin-top: 6px;
    text-align: right;
}

/* Attachments */
.tg-attachments {
    margin-top: 6px;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 8px;
}

.tg-att-item {
    background: #fff;
    border: 1px solid var(--bd-soft);
    border-radius: 10px;
    padding: 6px;
}

.cm-att__thumb {
    width: 100%;
    object-fit: cover;
    border-radius: 6px;
}

.cm-att__icon {
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #fafafa;
    border-radius: 6px;
}

.cm-att__icon-i {
    font-size: 40px;
    opacity: 0.9;
}

.tg-file-link {
    font-size: 13px;
    color: #1677ff;

}

.tg-file-link {
    max-width: 240px;
}

.tg-file-link {
    display: inline-block;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    vertical-align: bottom;
}

.cm-att__line {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-top: 6px;
    gap: 8px;
}

.pin-btn {
    font-size: 16px;
    cursor: pointer;
    transition: color 0.2s;
}

.pin-btn:hover {
    color: #faad14;
}

/* Footer composer */
.footer-fixed {
    position: sticky;
    bottom: 0;
    z-index: 5;
    background: var(--bg-surface);
    border-top: 1px solid #f0f0f0;
    padding-top: 10px;
    box-shadow: 0 -4px 10px rgba(0, 0, 0, 0.03);
}

.load-more {
    text-align: center;
    margin-bottom: 8px;
}

.tg-footer {
    background: var(--bg-subtle);
    padding: 8px 12px;
}

.tg-composer {
    position: relative;
    display: flex;
    align-items: center;
    gap: 8px;
    background: #fff;
    border: 1px solid #dfe6eb;
    border-radius: 24px;
    padding: 6px 44px;
    box-shadow: 0 1px 0 rgba(0, 0, 0, 0.03);
}

.tg-input {
    flex: 1;
    padding-left: 0;
}

.tg-input .ant-input {
    padding: 6px 0 !important;
}

.tg-input textarea.ant-input {
    box-shadow: none !important;
    resize: none;
    background: transparent;
}

.tg-attach-btn, .tg-send-btn {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
}

.tg-attach-btn {
    left: 6px;
    color: #6b7a8c;
}

.tg-send-btn {
    right: 6px;
    width: 32px;
    height: 32px;
    border: none;
    background: #d7e3ff;
    color: #6b7a8c;
}

.tg-send-btn.is-active {
    background: var(--blue-3);
    color: #fff;
}

/* file chip dưới composer */
.tg-file-strip {
    display: flex;
    gap: 6px;
    padding: 6px 4px 0;
    flex-wrap: wrap;
    margin-bottom: 10px;
}

.tg-file-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #fff;
    border: 1px solid #e2e8ef;
    border-radius: 16px;
    padding: 4px 8px;
    font-size: 12px;
}

.tg-file-pill .x {
    cursor: pointer;
    margin-left: 4px;
    opacity: 0.7;
}

/* Chips (approver) – dùng trong Drawer */

.chip-card {
    position: relative;
}

.chip-card {
    display: flex;
    align-items: center;
    gap: 8px;
    border: 1px solid var(--bd-soft);
    border-radius: 20px;
    background: var(--green-1);
    padding: 4px 10px;
    font-size: 13px;
    line-height: 1.4;
    transition: box-shadow 0.15s, transform 0.05s;
}

.chip-card:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.chip-card.is-approved {
    background: var(--green-1);
    border-color: var(--green-2);
}

.chip-card.is-pending {
    background: #e6f4ff;
    border-color: #91caff;
}

.chip-card.is-rejected {
    background: var(--red-1);
    border-color: var(--red-2);
}

.chip-line {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 6px;
}

.chip-name {
    font-weight: 600;
    color: #2b2f36;
}

.chip-time {
    color: #777;
    font-size: 12px;
}

.role-dot, .dot {
    display: inline-block;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    transform: translateY(1px);
}

.role-dot.ok, .dot.ok {
    background: #52c41a;
}

.role-dot.proc, .dot.proc {
    background: #1677ff;
}

.role-dot.err, .dot.err {
    background: #ff4d4f;
}

/* đưa nút × ra góc phải trên */
.chip-close {
    position: absolute !important;
    top: 6px;
    right: 8px;
    padding: 0 !important;
    width: 20px;
    height: 20px;
    line-height: 18px;
    text-align: center;
    border-radius: 50%;
    font-size: 14px;
    color: #9ca3af;
    transition: all 0.15s ease;
}

.chip-close:hover {
    background: rgba(0, 0, 0, 0.04);
    color: #111827;
}

.chip-close:active {
    background: rgba(0, 0, 0, 0.1);
}

/* điều chỉnh khoảng padding phần nội dung để không bị nút che */
.chip-body {
    padding-right: 28px;
}

/* Pinned files → pill */
.pinned-files {
    border-radius: 12px;
    margin: 8px 0;
    padding: 0;
}

.pinned-pill {
    margin-right: 5px;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    max-width: 320px;
    padding: 6px 10px;
    border: 1px solid var(--bd-soft);
    background: #fff6cc;
    border-radius: 999px;
    box-shadow: 0 1px 0 rgba(0, 0, 0, 0.03);
    transition: box-shadow 0.16s, transform 0.04s, border-color 0.16s;
}

.pinned-pill:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    border-color: #cfd8e3;
}

.pill-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
    color: #1f75ff;
    min-width: 0;
}

.pill-icon {
    font-size: 14px;
    opacity: 0.9;
}

.pill-text {
    display: inline-block;
    max-width: 200px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    vertical-align: bottom;
}

.pill-x {
    border: 0;
    background: transparent;
    color: #9aa4b2;
    font-size: 14px;
    line-height: 1;
    padding: 0 4px;
    cursor: pointer;
    border-radius: 6px;
}

.pill-x:hover {
    color: #ff4d4f;
    background: #fff1f0;
}

.more-pill {
    border-radius: 999px !important;
    padding: 2px 8px !important;
    border: 1px solid var(--blue-2);
    background: var(--blue-1);
    color: var(--blue-3);
    cursor: pointer;
}

/* ==== Drawer người duyệt – skin hiện đại, nhịp độ thoáng ==== */
.approver-drawer :deep(.ant-drawer-body) {
    padding: 12px 12px 16px;
    background: linear-gradient(180deg, #fbfdff 0%, #ffffff 100%);
}

.drawer-toolbar {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: 10px;
    align-items: center;
    margin-bottom: 10px;
}

.drawer-search :deep(.ant-input-affix-wrapper) {
    border-radius: 10px;
}

.drawer-stats {
    display: inline-flex;
    gap: 10px;
    font-size: 12px;
    color: #6b7280;
}

.drawer-stats .stat b {
    color: #111827;
}

.drawer-stats .stat-pending b {
    color: #2563eb;
}

/* proc */
.drawer-stats .stat-ok b {
    color: #16a34a;
}

/* ok */
.drawer-stats .stat-err b {
    color: #dc2626;
}

/* err */

.drawer-legend {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    font-size: 12px;
    color: #6b7280;
    padding: 8px 10px;
    border: 1px dashed #e5e7eb;
    border-radius: 10px;
    background: #fafcff;
    margin-bottom: 10px;
}

.drawer-legend .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    display: inline-block;
    transform: translateY(1px);
}

.drawer-legend .dot.ok {
    background: #52c41a;
}

.drawer-legend .dot.proc {
    background: #1677ff;
}

.drawer-legend .dot.err {
    background: #ff4d4f;
}

.drawer-legend .sep {
    opacity: .6;
}

.drawer-empty {
    text-align: center;
    color: #6b7280;
    padding: 28px 0 18px;
}

.drawer-empty .empty-icon {
    font-size: 28px;
    margin-bottom: 6px;
}

.drawer-empty .hint {
    font-size: 12px;
    opacity: .8;
}

/* Danh sách + thẻ người duyệt */
.drawer-list {
    display: grid;
    gap: 10px;
}

.drawer-chip .chip-card {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: 10px;
    align-items: center;
    padding: 10px 12px;
    border-radius: 14px;
    border: 1px solid var(--bd-soft);
    background: #ffffff;
    box-shadow: 0 1px 2px rgba(16, 24, 40, 0.03),
    0 0 0 1px rgba(16, 24, 40, 0.02) inset;
    transition: box-shadow .16s ease, transform .04s ease, border-color .16s ease, background .16s ease;
}

.drawer-chip .chip-card:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 14px rgba(17, 24, 39, 0.06);
    border-color: #e6efff;
    background: #f9fbff;
}


.chip-ghost {
    opacity: 0.4;
    background: #f0f0f0;
    border-radius: 8px;
    transform: scale(0.98);
}

.drawer-chip {
    cursor: grab;
    margin-bottom: 15px;
}

/* Card: 2 cột avatar | nội dung */
.drawer-chip .chip-card {
    display: grid;
    grid-template-columns: auto 1fr;
    gap: 10px;
    align-items: start;
}

/* Avatar cột trái */
.chip-avatar {
    width: 28px;
    height: 28px;
}

/* Thân: 3 hàng */
.chip-body {
    min-width: 0;
    display: grid;
    grid-template-rows: auto auto auto;
    gap: 6px;
}

/* Dòng 1: tên 1 dòng, ellipsis */
.name-row {
    min-width: 0;
}

.chip-name {
    font-weight: 700;
    color: #111827;
    display: inline-block;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Dòng 2: trạng thái + thời gian trên một dòng */
.meta-row {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: #4b5563;
    font-size: 12px;
    min-width: 0;
}

.meta-row .chip-time {
    white-space: nowrap; /* tránh xuống hàng giữa giờ & ngày */
}

.meta-sep {
    opacity: .55;
}

/* Dòng 3: actions cùng một dòng, tự wrap khi thiếu chỗ */
.actions-row {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    flex-wrap: wrap; /* nếu quá hẹp thì các nút tự xuống hàng */
}

/* Giữ màu dot như trước */
.dot.ok {
    background: #52c41a;
}

.dot.proc {
    background: #1677ff;
}

.dot.err {
    background: #ff4d4f;
}

/* Nền theo trạng thái (đã có ở bạn), giữ lại */
.drawer-chip .chip-card.is-approved {
    background: #f6ffed;
    border-color: #b7eb8f;
}

.drawer-chip .chip-card.is-pending {
    background: #eef6ff;
    border-color: #cfe3ff;
}

.drawer-chip .chip-card.is-rejected {
    background: #fff2f0;
    border-color: #ffccc7;
}

/* ===== Mention Popover ===== */
.mention-pop {
    display: flex;
    flex-direction: column;
    gap: 12px;
    min-width: 280px;
    padding: 14px 16px;
    background: #fff;
    border-radius: 10px;
    font-family: "Inter", "Segoe UI", sans-serif;
}

.mention-pop .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
}

.mention-pop .lbl {
    flex-shrink: 0;
    width: 60px;
    font-size: 13px;
    font-weight: 500;
    color: #444;
    text-align: right;
}

/* Select & Segmented alignment */
.mention-pop .ant-select,
.mention-pop .ant-segmented {
    flex: 1;
}

/* Segmented buttons subtle style */
.mention-pop .ant-segmented {
    background: #f6f7fb;
    border-radius: 8px;
}

.mention-pop .ant-segmented-item-selected {
    background: #1677ff !important;
    color: #fff !important;
    font-weight: 500;
}

/* Footer buttons */
.mention-pop .row:last-child {
    margin-top: 6px;
    justify-content: flex-end;
}

.mention-pop .ant-btn {
    border-radius: 6px;
}

.mention-pop .ant-btn-primary {
    box-shadow: 0 2px 0 rgba(0, 0, 0, 0.04);
}

/* Hover states for clarity */
.mention-pop .ant-btn:hover:not(.ant-btn-primary) {
    background: #f5f5f5;
}

.ant-popover-inner {
    border-radius: 12px !important;
    box-shadow: 0 6px 24px rgba(0, 0, 0, 0.08);
    transition: all 0.2s ease-in-out;
}

.msg-content {
    white-space: pre-wrap;
    word-wrap: break-word;
    line-height: 1.5;
    color: var(--txt-main);
}

/* style link đẹp */
.msg-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    text-decoration: none;
    color: #1677ff;
    font-weight: 500;
    background: #f0f6ff;
    border: 1px solid #cfe3ff;
    border-radius: 999px;
    padding: 2px 8px 2px 4px;
    transition: background-color 0.2s, transform 0.05s;
}

.msg-link:hover {
    background: #e6f0ff;
    transform: translateY(-1px);
}

.msg-link-favicon {
    width: 14px;
    height: 14px;
    border-radius: 3px;
}

.msg-link-text {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 140px;
}

.drawer-toolbar {
    gap: 12px;
    padding: 8px 0;
    border-bottom: 1px solid #eef1f3;
    margin-bottom: 8px;
}

.creator-info {
    color: #374151;
    font-size: 14px;
}

.drawer-stats {
    color: #6b7280;
    font-size: 13px;
    font-weight: 500;
}

.approved-tag {
    color: #16a34a;
    margin-left: 8px;
}

.doc-type-selector {
    display: flex;
    gap: 10px;
    margin-top: 4px;
}

.doc-type-pill {
    cursor: pointer;
    padding: 6px 14px;
    border-radius: 16px;
    transition: all 0.2s;
    background: #f1f5f9;
    color: #334155;
    border: 1px solid #e2e8f0;
    font-size: 13px;
    user-select: none;
    margin-right: 0;
}

/* Hover */
.doc-type-pill:hover {
    background: #e2e8f0;
}

/* Active styles */
.active-internal {
    background: #e0e7ff;
    border-color: #6366f1;
    color: #3730a3;
    font-weight: 600;
}

.active-external {
    background: #cffafe;
    border-color: #06b6d4;
    color: #0e7490;
    font-weight: 600;
}

.doc-type-note {
    font-size: 13px;
    color: #334155;
    background: #f1f5f9;
    padding: 8px 12px;
    border-radius: 6px;
    align-items: center;
    gap: 6px;
}

.doc-type-note .icon {
    color: #2563eb;
}

.pinned-batch {
    margin-bottom: 12px;
    padding: 8px 10px;
    border: 1px solid #e6ebf0;
    border-radius: 8px;
    background: #fafcff;
}

.batch-title {
    font-size: 13px;
    font-weight: 600;
    color: #374151;
    margin-bottom: 6px;
    display: flex;
    justify-content: space-between;
}

/* ============================
   Latest Upload Batch Box
   ============================ */
.latest-batch-box {
    border: 1px solid #e6ebf0;
    background: #f9fbff;
    border-radius: 12px;
    padding: 12px 14px;
    margin-bottom: 18px;
}

.lb-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.lb-title {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 15px;
    color: #1e293b;
}

.lb-icon {
    font-size: 18px;
}

.lb-meta .lb-time {
    font-size: 12px;
    color: #64748b;
}

.lb-files {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.lb-file {
    display: grid;
    grid-template-columns: 34px 1fr;
    gap: 10px;
    padding: 8px;
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    transition: 0.18s ease;
    margin-bottom: 10px;
}

.lb-file:hover {
    border-color: #cfe3ff;
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
}

.lb-file-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    opacity: .85;
}

.lb-file-info {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.lb-file-name {
    color: #1d4ed8;
    font-weight: 500;
    text-decoration: none;
}

.lb-file-name:hover {
    text-decoration: underline;
}

.lb-file-sub {
    font-size: 12px;
    color: #475569;
    display: flex;
    align-items: center;
    gap: 6px;
}

.lb-dot {
    font-size: 6px;
    color: #94a3b8;
}
.chip-card.is-signed {
    background: #c6f6d5; /* xanh đậm hơn approved */
    border-color: #38a169;
}

.dot.signed {
    background: #2f855a;
}

/* === Modal tùy chỉnh === */
.mention-modal .ant-modal-content {
    border-radius: 14px;
    padding: 0;
    overflow: hidden;
    box-shadow: 0 12px 32px rgba(0,0,0,0.12);
}

/* Header */
.mention-modal .ant-modal-header {
    padding: 16px 20px;
    background: #f8fafc;
    border-bottom: 1px solid #e5e7eb;
}

.mention-modal .ant-modal-title {
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
}

/* Body */
.mention-body {
    padding: 22px 24px;
    display: flex;
    flex-direction: column;
    gap: 18px;
}

/* Field */
.field {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.field-label {
    font-size: 14px;
    font-weight: 500;
    color: #374151;
}

/* Alert style */
.role-alert {
    border-radius: 8px !important;
    padding: 10px 12px !important;
    background: #fffbe6 !important;
}

/* Radio group */
.role-radio-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding: 6px 10px;
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
}

.role-radio-group .ant-radio-wrapper {
    padding: 4px 6px;
    font-size: 14px;
}

/* Footer */
.modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 10px;
    padding-top: 14px;
    border-top: 1px solid #e5e7eb;
}
.default-text {
    font-size: 12px;
    color: #999;
    margin-left: 6px;
    font-style: italic;
}
.copy-icon-btn {
    padding: 0;
    margin-left: 6px;
    color: #999;
    transition: 0.2s;
}

.copy-icon-btn:hover {
    color: #1677ff !important;
    transform: scale(1.15);
}
/* Responsive */
@media (max-width: 768px) {
    .bubble {
        max-width: 88%;
    }

    .chip-card {
        max-width: 100%;
    }

    .pill-text {
        max-width: 140px;
    }
}
</style>
<style>
.lb-file-name {
    max-width: 240px; /* tuỳ chỉnh theo layout */
}

.lb-file-name-text {
    display: inline-block;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    vertical-align: bottom;
}
.enhanced-chip-name {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 6px;
    margin-bottom: 4px;
}

.dept-tag {
    background: #e8f1ff !important;
    border-color: #c6ddff !important;
    color: #1d4ed8 !important;
    font-size: 11px;
    padding: 0 6px;
    border-radius: 6px;
}

.sig-tag {
    background: #f3e8ff !important;
    border-color: #e0c7ff !important;
    color: #7e22ce !important;
    font-size: 11px;
    padding: 0 6px;
    border-radius: 6px;
    font-family: 'JetBrains Mono', monospace;
}


</style>
