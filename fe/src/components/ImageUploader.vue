<template>
    <div>
        <div class="image-container">
            <div v-for="(file, index) in internalList" :key="file.uid" class="image-item">
                <iframe
                    v-if="file.isYoutube"
                    :src="getYouTubeEmbedUrl(file.url)"
                    width="100%"
                    height="100%"
                    frameborder="0"
                    allowfullscreen
                ></iframe>

                <!-- Nếu là ảnh -->
                <img
                    v-else-if="file.preview && isImage(file.preview)"
                    :src="file.preview"
                    class="image-preview"
                />

                <!-- Nếu là video -->
                <video v-else-if="isVideo(file.preview)" :src="file.preview" class="image-preview" controls/>

                <!-- File khác -->
                <div v-else class="file-icon">📄</div>
                <div class="tool_tip_text" v-if="props.multiple" @click="showYoutubeModal(file.url)">
                    <PlayCircleOutlined />
                    <div v-if="props.type !== 'video'">
                        <span v-if="file.is_main" class="cover-label">Ảnh chính</span>
                        <a v-else href="javascript:void(0)" @click="setAsCover(index)" class="cover-link">
                            Đặt làm ảnh chính
                        </a>
                    </div>
                </div>

                <!-- Controls -->
                <button @click="remove(index)" class="remove-btn">
                    <DeleteOutlined/>
                </button>
            </div>

            <!-- Thêm -->
            <div class="add-image-box" v-if="!(hideUploadIfSingle && !props.multiple && internalList.length >= 1)">
                <input
                    type="file"
                    :accept="accept"
                    @change="onFileChange"
                    ref="fileInput"
                    style="display: none"
                />
                <a href="javascript:void(0)" @click="$refs.fileInput.click()">Thêm</a>
                <a @click="openUrlModal" class="add-url-link">Thêm từ URL</a>
            </div>
        </div>

        <!-- Modal URL -->
        <a-modal
            v-model:open="showUrlModal"
            title="Thêm từ URL"
            :footer="null"
            centered
            destroyOnClose
        >
            <a-input v-model:value="urlInput" placeholder="Nhập URL"/>
            <div class="modal-footer">
                <a-button @click="showUrlModal = false" style="margin-right: 8px">Hủy</a-button>
                <a-button type="primary" :loading="isAddingUrl" @click="addUrl">Thêm</a-button>
            </div>
        </a-modal>

        <a-modal
            v-model:open="youtubePreview.visible"
            :footer="null"
            :closable="false"
            centered
            width="600px"
            :bodyStyle="{ padding: 0 }"
            :aStyle="{ zIndex: 1050 }"
            wrap-class-name="modal_video_youtube"
            destroyOnClose
        >
            <iframe
                v-if="youtubePreview.videoId"
                :src="`https://www.youtube.com/embed/${youtubePreview.videoId}?autoplay=0`"
                width="100%"
                height="400"
                style="border: none; display: block;"
                allow="autoplay; encrypted-media"
                allowfullscreen
            ></iframe>
        </a-modal>


    </div>
</template>

<script setup>
import {computed, nextTick, ref, watch} from 'vue'
import {uploadFile, uploadFromUrl} from '../api/event'
import {DeleteOutlined, PlayCircleOutlined} from '@ant-design/icons-vue'
import {message} from 'ant-design-vue'

const props = defineProps({
    modelValue: {
        type: Array,
        default: () => [],
        required: true
    },
    type: {
        type: String,
        default: 'image' // 'image' | 'video'
    },
    multiple: {
        type: Boolean,
        default: true
    },
    hideUploadIfSingle: {
        type: Boolean,
        default: false
    }
})



const emit = defineEmits(['update:modelValue'])

const internalList = ref([])
const fileInput = ref(null)
let showUrlModal = ref(false)
const isAddingUrl = ref(false)

const accept = computed(() => {
    if (props.type === 'image') return 'image/*'
    if (props.type === 'video') return 'video/*'
    return '*/*'
})


const youtubePreview = ref({
    visible: false,
    videoId: ''
})

const urlInput = ref('')

// Đồng bộ dữ liệu từ ngoài vào
watch(
    () => props.modelValue,
    (val) => {
        const list = Array.isArray(val) ? val : (val ? [val] : [])

        internalList.value = list.map(item => {
            const isStr = typeof item === 'string'
            const url = isStr ? item : item?.url || ''
            return {
                ...(isStr ? {} : item),
                url,
                preview: item?.preview || url,
                isYoutube: isYoutubeUrl(url),
                isCover: item?.isCover === 1 || item?.isCover === true || item?.is_cover == 1 || item?.is_cover === '1',
                uid: item?.uid || Date.now().toString()
            }
        })
    },
    { immediate: true }
)



function emitChange() {
    emit('update:modelValue', internalList.value)
}


const acceptTypes = computed(() => {
    return props.type === 'video'
        ? ['video/mp4', 'video/webm', 'video/ogg']
        : ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
})

function isFileTypeAccepted(file) {
    return acceptTypes.value.includes(file.type)
}

async function onFileChange(event) {
    const files = event.target.files
    if (!files || files.length === 0) return

    for (const file of files) {
        if (!isFileTypeAccepted(file)) {
            message.error(`Định dạng không hợp lệ. Chỉ chấp nhận ${props.type === 'video' ? 'video' : 'ảnh'}!`)
            continue
        }

        try {
            const response = await uploadFile(file)
            const url = response.data.url

            const newItem = {
                uid: Date.now().toString(),
                url,
                preview: url,
                isCover: false,
                isYoutube: false
            }

            if (props.multiple) {
                internalList.value.push(newItem)
            } else {
                internalList.value = [newItem] // 🟢 Chỉ giữ 1 ảnh duy nhất
            }
        } catch (err) {
            console.error('Upload thất bại:', err)
            message.error('Tải file thất bại!')
        }
    }

    emitChange()
    event.target.value = ''
}


const showYoutubeModal = (url) => {
    const id = extractYoutubeId(url)
    if (id) {
        youtubePreview.value = {
            visible: true,
            videoId: id
        }
    }
}

const extractYoutubeId = (url) => {
    const match = url.match(
        /(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/
    )
    return match ? match[1] : ''
}

function getYouTubeThumbnail(url) {
    const match = url.match(
        /(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/)([\w-]{11})/
    )
    return match ? `https://img.youtube.com/vi/${match[1]}/hqdefault.jpg` : null
}

function openUrlModal() {
    showUrlModal.value = true
    nextTick(() => document.querySelector('input[placeholder="Nhập URL"]')?.focus())
}

function isValidUrl(url) {
    try {
        new URL(url)
        return true
    } catch (_) {
        return false
    }
}

function detectUrlType(url) {
    const isYoutube = isYoutubeUrl(url)
    if (isYoutube) return 'youtube'

    const imageExt = /\.(jpe?g|png|gif|webp|bmp|svg)$/i
    const videoExt = /\.(mp4|webm|ogg)$/i

    if (imageExt.test(url)) return 'image'
    if (videoExt.test(url)) return 'video'

    return 'unknown'
}

async function addUrl() {
    const url = urlInput.value.trim()
    if (!url) return

    if (!isValidUrl(url)) {
        message.error('Định dạng URL không hợp lệ!')
        return
    }

    isAddingUrl.value = true

    try {
        const urlType = detectUrlType(url)

        if (props.type === 'image' && urlType !== 'image') {
            message.error('Chỉ chấp nhận URL hình ảnh!')
            return
        }

        if (props.type === 'video' && urlType !== 'video' && urlType !== 'youtube') {
            message.error('Chỉ chấp nhận URL YouTube!')
            return
        }

        const isYoutube = urlType === 'youtube'
        let fileUrl = url
        let previewUrl = url

        if (isYoutube) {
            previewUrl = getYouTubeThumbnail(url)
        } else {
            const response = await uploadFromUrl(url)
            if (!response?.data?.url) throw new Error('Upload thất bại hoặc không trả về URL')
            fileUrl = response.data.url
            previewUrl = fileUrl
        }

        const newItem = {
            uid: Date.now().toString(),
            url: fileUrl,
            preview: previewUrl,
            isCover: false,
            isYoutube
        }

        if (props.multiple) {
            internalList.value.push(newItem)
        } else {
            internalList.value = [newItem] // 🔥 Ghi đè khi multiple = false
        }


        emitChange()
        urlInput.value = ''
        showUrlModal.value = false

    } catch (err) {
        console.error('Tải ảnh/video từ URL thất bại:', err)
        message.error('Không thể thêm URL. Vui lòng kiểm tra lại liên kết!')
    } finally {
        isAddingUrl.value = false
    }
}

function remove(index) {
    internalList.value.splice(index, 1)
    emitChange()
}

function setAsCover(index) {
    internalList.value.forEach((f, i) => {
        f.isCover = i === index
        f.is_main = i === index
    })

    emit('update:modelValue', internalList.value)
    emit('set-cover', internalList.value[index])
}
function isImage(url) {
    return url.startsWith('data:image') || /\.(jpg|jpeg|png|gif|webp|svg)$/i.test(url)
}

function isVideo(url) {
    return url.startsWith('data:video') || /\.(mp4|webm|ogg|mov)$/i.test(url)
}

function getYouTubeEmbedUrl(url) {
    const match = url.match(/(?:v=|youtu\.be\/)([\w-]{11})/)
    return match ? `https://www.youtube.com/embed/${match[1]}` : ''
}

function isYoutubeUrl(url) {
    return /(?:youtube\.com\/watch\?v=|youtu\.be\/)([\w-]{11})/.test(url)
}

</script>
<style>
.modal_video_youtube .ant-modal-content {
    padding: 0 !important;
}
</style>
<style scoped>

.cover-link {
    color: #ffffff;
    cursor: pointer;
    font-size: 11px;
    margin-top: 4px;
    display: inline-block;
    line-height: 1.1;
}

.image-preview {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

iframe.image-preview {
    object-fit: contain;
}

.file-icon {
    font-size: 32px;
    color: #999;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
}

.image-container {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.image-item {
    position: relative;
    width: 100px;
    height: 100px;
    border: 1px solid #ccc;
    border-radius: 8px;
    overflow: hidden;
}

.image-item:hover .tool_tip_text {
    display: block;
}

.tool_tip_text {
    visibility: visible;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    color: #ffffff;
    font-size: 16px;
    font-style: normal;
    font-weight: 400;
    line-height: 133%;
    text-decoration-line: underline;
    background: rgba(0, 0, 0, .7);
    width: 100%;
    height: 100%;
    text-align: center;
    padding-top: 40%;
    cursor: pointer;
    display: none;
}

.image-preview {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.cover-label {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: rgba(0, 0, 0, 0.6);
    color: #fff;
    font-size: 12px;
    text-align: center;
}

.remove-btn {
    position: absolute;
    top: 2px;
    right: 2px;
    color: red;
    width: 15px;
    height: 15px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    font-weight: 700;
    border: none;
}

.cover-btn {
    position: absolute;
    bottom: 2px;
    left: 2px;
    background: #000;
    color: white;
    font-size: 10px;
    padding: 2px;
    border-radius: 4px;
    cursor: pointer;
}

.add-image-box {
    width: 100px;
    height: 100px;
    border: 1px dashed #ccc;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

.add-url-link {
    color: green;
    font-size: 12px;
    margin-top: 4px;
    cursor: pointer;
}

.modal-footer {
    text-align: right;
    margin-top: 10px;
}

</style>
