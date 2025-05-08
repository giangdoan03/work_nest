<template>
    <div>
        <!-- Nút quay lại -->
        <a-button type="default" @click="goBack" style="margin-bottom: 16px">
            Quay lại danh sách
        </a-button>

        <a-tabs default-active-key="info">
            <a-tab-pane key="info" tab="Thông tin sự kiện">
                <!-- Bổ sung form đầy đủ các trường đã có trong bảng `events` -->
                <a-form :model="form" layout="vertical" @finish="handleSubmit">
                    <a-card style="margin-bottom: 24px" class="bg_card_gray ">
                        <a-row :gutter="24">
                            <!-- Cột trái -->
                            <a-col :xs="24" :md="12">
                                <!-- Ảnh banner -->
                                <a-card class="mb_24">
                                    <a-form-item label="Ảnh sự kiện">
                                        <ImageUploader
                                                type="image"
                                                :modelValue="form.images"
                                                @update:modelValue="val => form.images = val"
                                                @set-cover="handleSetMainImage"
                                        />
                                    </a-form-item>
                                    <a-form-item label="Bìa sự kiện">
                                        <ImageUploader
                                                type="image"
                                                :multiple="false"
                                                :modelValue="normalizeBanner(form.banner)"
                                                @update:modelValue="val => form.banner = val[0]?.url || ''"
                                        />
                                    </a-form-item>

                                    <a-form-item label="Video sự kiện">
                                        <ImageUploader
                                                type="video"
                                                :modelValue="normalizeToArray(form.video)"
                                                @update:modelValue="val => form.video = val"
                                        />
                                    </a-form-item>
                                </a-card>
                                <!-- Tên sự kiện -->
                                <a-card class="mb_24" title="Thông tin">
                                    <a-form-item label="Tên sự kiện" required>
                                        <a-input v-model:value="form.name" placeholder="Nhập tên sự kiện"/>
                                    </a-form-item>
                                    <a-form-item label="Quốc gia">
                                        <a-input v-model:value="form.country"/>
                                    </a-form-item>

                                    <!-- Thành phố -->
                                    <a-form-item label="Thành phố">
                                        <a-input v-model:value="form.city"/>
                                    </a-form-item>

                                    <!-- Quận/Huyện -->
                                    <a-form-item label="Quận/Huyện">
                                        <a-input v-model:value="form.district"/>
                                    </a-form-item>
                                    <!-- Địa điểm -->
                                    <a-form-item label="Địa điểm tổ chức">
                                        <a-input v-model:value="form.location"/>
                                    </a-form-item>
                                </a-card>
                                <a-card title="Trạng thái">
                                    <a-form-item>
                                        <a-switch v-model:checked="form.is_enabled" checked-children="Bật"
                                                  un-checked-children="Tắt"/>
                                    </a-form-item>
                                </a-card>

                            </a-col>

                            <!-- Cột phải -->
                            <a-col :xs="24" :md="12">

                                <!-- Quốc gia -->
                                <a-card class="mb_24" title="Liên hệ">
                                    <a-row :gutter="16">
                                        <a-col>
                                            <a-form-item label="Họ">
                                                <a-input v-model:value="form.contact_first_name"/>
                                            </a-form-item>
                                        </a-col>
                                        <a-col>
                                            <a-form-item label="Tên">
                                                <a-input v-model:value="form.contact_last_name"/>
                                            </a-form-item>
                                        </a-col>
                                    </a-row>
                                    <a-row :gutter="16">
                                        <a-col>
                                            <a-form-item label="Số điện thoại">
                                                <a-input v-model:value="form.contact_phone"/>
                                            </a-form-item>
                                        </a-col>
                                        <a-col>
                                            <a-form-item label="Email">
                                                <a-input v-model:value="form.contact_email"/>
                                            </a-form-item>
                                        </a-col>
                                    </a-row>
                                </a-card>
                                <a-card class="mb_24" title="Định dạng">
                                    <a-form-item>
                                        <a-radio-group v-model:value="form.event_mode">
                                            <a-radio value="online">Trực tuyến</a-radio>
                                            <a-radio value="offline">Ngoại tuyến</a-radio>
                                        </a-radio-group>
                                    </a-form-item>
                                    <a-row :gutter="16">
                                        <a-col>
                                            <a-form-item label="Thời gian bắt đầu">
                                                <a-date-picker show-time v-model:value="form.start_time" style="width: 100%"/>
                                            </a-form-item>
                                        </a-col>
                                        <a-col>
                                            <!-- Thời gian kết thúc -->
                                            <a-form-item label="Thời gian kết thúc">
                                                <a-date-picker show-time v-model:value="form.end_time" style="width: 100%"/>
                                            </a-form-item>
                                        </a-col>
                                    </a-row>
                                </a-card>
                                <!-- Mô tả -->
                                <a-card class="mb_24" title="Mô tả sự kiện">
                                    <div
                                            v-for="(item, index) in form.description"
                                            :key="index"
                                            class="mb-4 p-4 border border-gray-200 rounded"
                                    >
                                        <a-card class="mb_24">
                                            <a-form-item label="Tiêu đề mô tả">
                                                <a-input v-model:value="item.title" placeholder="Nhập tiêu đề mô tả"/>
                                            </a-form-item>

                                            <a-form-item label="Nội dung mô tả">
                                                <div
                                                        :ref="el => setDescriptionEditorRef(index, el)"
                                                        style="min-height: 150px; padding: 8px;"
                                                />
                                            </a-form-item>

                                            <a-button danger @click="removeDescription(index)"
                                                      v-if="form.description.length > 1">
                                                Xoá mô tả
                                            </a-button>
                                        </a-card>
                                    </div>

                                    <a-button type="dashed" block @click="addNewDescription">
                                        + Thêm mô tả
                                    </a-button>
                                </a-card>

                                <!-- Tùy chọn vé -->
                                <a-card class="mb_24" title="Mạng xã hội">
                                    <div
                                            v-for="(item, index) in form.social_links"
                                            :key="index"
                                            style="margin-bottom: 12px; overflow-x: auto"
                                    >
                                        <a-space :size="12" :wrap="false" align="center">
                                            <!-- Logo -->
                                            <ImageUploader
                                                    type="image"
                                                    :multiple="false"
                                                    :hideUploadIfSingle="true"
                                                    :modelValue="item.icon ? [item.icon] : []"
                                                    @update:modelValue="val => item.icon = val[0]?.url || ''"
                                            />

                                            <!-- Select -->
                                            <a-select
                                                    v-model:value="item.type"
                                                    :options="socialPlatforms"
                                                    :field-names="{ label: 'label', value: 'value' }"
                                                    placeholder="Chọn MXH"
                                                    style="width: 90px"
                                            />

                                            <!-- URL input -->
                                            <a-input
                                                    v-model:value="item.url"
                                                    placeholder="https://..."
                                                    style="width: 300px"
                                            />

                                            <!-- Nút xoá -->
                                            <a-button
                                                    type="text"
                                                    danger
                                                    @click="removeSocialLink(index)"
                                                    v-if="form.social_links.length > 1"
                                            >
                                                <DeleteOutlined/>
                                            </a-button>

                                        </a-space>
                                    </div>

                                    <a-button type="dashed" @click="addSocialLink">
                                        ➕ Thêm
                                    </a-button>
                                </a-card>
                            </a-col>
                        </a-row>
                    </a-card>

                    <!-- Nút hành động -->
                    <a-form-item>
                        <a-space>
                            <a-button type="primary" html-type="submit">Lưu</a-button>
                            <a-button @click="goBack">Huỷ</a-button>
                        </a-space>
                    </a-form-item>
                </a-form>

            </a-tab-pane>
            <a-tab-pane key="settings" tab="Cài đặt hiển thị">
                <a-row :gutter="24">
                    <a-col :span="16">
                        <a-form layout="vertical">
                            <!-- Giao diện mẫu -->
                            <a-card title="Chọn giao diện mẫu" style="margin-bottom: 24px;">
                                <a-form-item>
                                    <a-row :gutter="16">
                                        <a-col v-for="tpl in templateOptions" :key="tpl.id" :xs="24" :sm="12" :md="8"
                                               :lg="8" style="margin-bottom: 16px">
                                            <a-card hoverable
                                                    :class="{ 'selected-card': settings.selectedTemplate === tpl.id, 'active-card': isActiveTemplate(tpl.id) }"
                                                    @click="selectTemplate(tpl)">
                                                <template #cover>
                                                    <img :src="tpl.thumbnail" alt="template"
                                                         style="height: 200px; object-fit: cover"/>
                                                </template>
                                                <a-card-meta :title="tpl.title" :description="tpl.description"/>
                                            </a-card>
                                        </a-col>
                                    </a-row>
                                </a-form-item>
                            </a-card>

                            <a-card title="Công ty" style="margin-bottom: 24px;">
                                <!-- Công ty -->
                                <a-form-item>
                                    <a-radio-group v-model:value="settings.company" @change="handleCompanyModeChange">
                                        <a-radio :value="'all'">Tất cả công ty</a-radio>
                                        <a-radio :value="'selected'">Chọn công ty</a-radio>
                                    </a-radio-group>
                                </a-form-item>
                                <div v-if="settings.company === 'selected'" style="margin-bottom: 24px">
                                    <a-select
                                            mode="multiple"
                                            style="width: 100%; margin-bottom: 12px"
                                            placeholder="Chọn công ty"
                                            v-model:value="selectedCompanies"
                                            @change="handleCompanySelect"
                                            :key="settings.company"
                                    >

                                        <a-select-option v-for="b in allBusinesses" :key="b.id" :value="b.id">
                                            {{ b.name }} - {{ b.email }}
                                        </a-select-option>
                                    </a-select>

                                    <a-table :columns="businessColumns" :data-source="businessList" row-key="id"
                                             bordered size="small">
                                        <template #bodyCell="{ column, record }">
                                            <template v-if="column.key === 'logo'">
                                                <img v-if="record.logo?.[0]" :src="record.logo[0]" alt="Logo"
                                                     style="height: 40px; width: 40px; object-fit: cover; border-radius: 4px"/>
                                            </template>
                                            <template v-if="column.key === 'action'">
                                                <a-button type="link" @click="removeBusiness(record.id)" danger>Xoá
                                                </a-button>
                                            </template>
                                        </template>
                                    </a-table>
                                </div>
                            </a-card>
                            <!-- Khảo sát + nút đặt hàng -->
                            <a-card title="Khảo sát" style="margin-bottom: 24px;">
                                <a-form-item>
                                    <a-switch v-model:checked="settings.enableSurvey" disabled
                                              class="custom-disabled-switch"/>
                                </a-form-item>
                            </a-card>
                            <a-form-item>
                                <a-button type="primary" @click="handleSubmit" :loading="loading">Lưu</a-button>
                            </a-form-item>
                        </a-form>
                    </a-col>
                    <a-col :xs="24" :md="8">
                        <div class="iphone-mockup">
                            <div :class="['dynamic-island', { expanded: isIslandExpanded }]">
                                <div class="marquee">
                                    <div class="marquee-content">{{ selectedTemplateData?.title }}</div>
                                </div>
                            </div>
                            <div class="iphone-screen">
                                <component
                                        :is="AsyncTemplate"
                                        :product="form"
                                        :business="businessList"
                                        :store="storeList"
                                        :all-businesses="allBusinesses"
                                        :all-stores="allStores"
                                />
                            </div>
                        </div>
                    </a-col>
                </a-row>
            </a-tab-pane>
        </a-tabs>

        <!-- Modal xem ảnh -->
        <a-modal v-model:open="previewVisible" :title="previewTitle" footer={null}>
            <img :src="previewImage" alt="Preview" style="width: 100%"/>
        </a-modal>
    </div>
</template>

<script setup>
    import {ref, onMounted, nextTick, computed, defineAsyncComponent, watch } from 'vue'
    import {useRoute, useRouter} from 'vue-router'
    import {createEvent, updateEvent, getEvent, uploadFile} from '../api/event'
    import {getBusinesses} from "@/api/business.js";
    // import {uploadFile} from '../api/product'`
    import {message} from 'ant-design-vue'
    import {UploadOutlined, DeleteOutlined} from '@ant-design/icons-vue'
    import dayjs from 'dayjs'
    import {useUserStore} from '../stores/user'
    import ImageUploader from './ImageUploader.vue' // đường dẫn đúng tới file bạn lưu
    import Quill from 'quill'
    import 'quill/dist/quill.snow.css'
    import templateOptions from "@/components/templates/stores";
    import {parseFieldsForList} from '@/utils/formUtils'

    const ticketEditorRefs = ref([])
    const ticketEditorInstances = ref([])


    const userStore = useUserStore()
    const route = useRoute()
    const router = useRouter()
    const isEditMode = computed(() => !!route.params.id)

    const loading = ref(false)
    const isIslandExpanded = ref(false)
    const editorRef = ref(null)
    const quillInstance = ref(null)

    const form = ref({
        user_id: null,
        name: '',
        location: '',
        start_time: null,
        end_time: null,
        description: [
            {
                title: '',
                content: ''
            }
        ],
        event_mode: 'online',
        is_enabled: true,
        contact_first_name: '',
        contact_last_name: '',
        contact_phone: '',
        contact_email: '',
        ticket_options: [
            {
                title: '',
                description: '',
                price: 0
            }
        ],
        social_links: [
            {type: 'facebook', url: '', icon: ''}
        ],

        images: [
            // { url: '', is_main: false }
        ],
        banner: '',
        video: [],
    })

    const allBusinesses = ref([])
    const allStores = ref([])


    const businessList = ref([])

    const storeList = ref([])

    const businessColumns = [
        {title: 'ID', dataIndex: 'id', key: 'id'},
        {title: 'Logo', dataIndex: 'logo', key: 'logo'},
        {title: 'Tên công ty', dataIndex: 'name', key: 'name'},
        {title: 'Email', dataIndex: 'email', key: 'email'},
        {title: 'SĐT', dataIndex: 'phone', key: 'phone'},
        {title: 'Địa chỉ', dataIndex: 'address', key: 'address'},
        {title: 'Hành động', key: 'action'}
    ]

    const socialPlatforms = [
        {label: 'Facebook', value: 'facebook', icon: 'facebook.png'},
        {label: 'Instagram', value: 'instagram', icon: 'instagram.png'},
        {label: 'Twitter', value: 'twitter', icon: 'twitter.png'},
        {label: 'LinkedIn', value: 'linkedin', icon: 'linkedin.png'}
    ]

    const previewImage = ref('')
    const previewVisible = ref(false)
    const previewTitle = ref('')

    const descriptionEditorRefs = ref([])
    const descriptionEditorInstances = ref([])
    const selectedCompanies = ref([])


    const settings = ref({
        selectedTemplate: 'tpl-1',// Template hiển thị

        relatedProducts: 'all',            // 'all' hoặc 'selected'
        selectedProducts: [],              // ID sản phẩm được chọn khi relatedProducts = 'selected'

        company: 'all',                    // 'all' hoặc 'selected'
        selectedCompanies: [],             // ID công ty được chọn khi company = 'selected'

        store: 'all',                      // 'all' hoặc 'selected'
        selectedStores: [],                // ID cửa hàng được chọn khi store = 'selected'

        enableSurvey: false,                // Bật khảo sát
        selectedSurveys: [],               // ID khảo sát được chọn khi enableSurvey = true

        enableOrderButton: true,         // Hiển thị nút đặt hàng

        topProductsMode: 'all',        // 👈 điều khiển radio: 'all' hoặc 'selected'
        topProducts: [],               // 👈 mảng ID sản phẩm top

    })

    const selectedTemplateData = computed(() =>
        templateOptions.find(t => t.id === settings.value.selectedTemplate)
    )

    const AsyncTemplate = computed(() => {
        return selectedTemplateData.value?.component ? defineAsyncComponent(selectedTemplateData.value.component) : null
    })

    const selectTemplate = (tpl) => {
        settings.value.selectedTemplate = tpl.id
    }

    const isActiveTemplate = (tplId) => {
        return settings.value.selectedTemplate === tplId
    }

    // Gọi API doanh nghiệp
    const fetchAllBusinesses = async () => {
        const res = await getBusinesses({ per_page: 1000 });
        allBusinesses.value = parseFieldsForList(res.data.data, ['logo']);
    };


    // Chọn doanh nghiệp từ select box
    const handleCompanySelect = (ids) => {
        businessList.value = parseFieldsForList(
            allBusinesses.value.filter(b => ids.includes(b.id)),
            ['logo']
        );
        selectedCompanies.value = ids;
    };

    // Xoá doanh nghiệp đã chọn
    const removeBusiness = (id) => {
        selectedCompanies.value = selectedCompanies.value.filter(bid => bid !== id);
        businessList.value = businessList.value.filter(b => b.id !== id);
    };

    const handleCompanyModeChange = async (input) => {
        const value = typeof input === 'string' ? input : input?.target?.value;
        if (!value) {
            console.warn('Giá trị không hợp lệ:', input);
            return;
        }

        if (value === 'selected') {
            if (allBusinesses.value.length === 0) await fetchAllBusinesses();
            selectedCompanies.value = [];
            businessList.value = [];
        } else if (value === 'all') {
            await fetchAllBusinesses();
            selectedCompanies.value = allBusinesses.value.map(b => b.id);
            businessList.value = [...allBusinesses.value];
        }
    };


    const fetchEvent = async () => {
        try {
            const response = await getEvent(route.params.id)
            const data = response.data

            if (typeof data.display_settings === 'string') {
                try {
                    const parsedSettings = JSON.parse(data.display_settings)
                    settings.value = {...settings.value, ...parsedSettings}

                } catch (e) {
                    console.warn('display_settings không hợp lệ:', e)
                }
            } else if (typeof data.display_settings === 'object') {
                settings.value = {...settings.value, ...data.display_settings}
            }

            // Parse các trường JSON (nếu là string)
            data.images = typeof data.images === 'string'
                ? JSON.parse(data.images)
                : (Array.isArray(data.images) ? data.images : [])

            data.video = typeof data.video === 'string'
                ? JSON.parse(data.video)
                : (Array.isArray(data.video) ? data.video : [])

            data.ticket_options = (() => {
                if (Array.isArray(data.ticket_options)) return data.ticket_options
                if (typeof data.ticket_options === 'string') {
                    try {
                        const parsed = JSON.parse(data.ticket_options)
                        return Array.isArray(parsed) ? parsed : []
                    } catch (e) {
                        console.warn('⚠️ ticket_options không phải JSON:', data.ticket_options)
                        return [] // fallback nếu là HTML cũ
                    }
                }
                return []
            })()


            data.banner = data.banner || ''

            // Gán vào form
            Object.assign(form.value, data)

            form.value.social_links = typeof data.social_links === 'string'
                ? JSON.parse(data.social_links)
                : (Array.isArray(data.social_links) ? data.social_links : [])


            // Convert thời gian về dayjs nếu có
            if (form.value.start_time) {
                form.value.start_time = dayjs(form.value.start_time)
            }

            if (form.value.end_time) {
                form.value.end_time = dayjs(form.value.end_time)
            }

        } catch (error) {
            console.error('Lỗi lấy sự kiện:', error)
            message.error('Không tìm thấy thông tin sự kiện')
        }
    }


    const addNewDescription = async () => {
        if (!Array.isArray(form.value.description)) {
            form.value.description = []
        }

        form.value.description.push({title: '', content: ''})

        await nextTick()

        const index = form.value.description.length - 1
        const container = descriptionEditorRefs.value[index]
        if (container) {
            const quill = new Quill(container, {
                theme: 'snow',
                placeholder: 'Nhập nội dung mô tả...',
                modules: {
                    toolbar: [
                        ['bold', 'italic', 'underline', 'strike'],
                        [{list: 'ordered'}, {list: 'bullet'}],
                        [{header: [1, 2, false]}],
                        ['link', 'image'],
                        ['clean']
                    ]
                }
            })

            descriptionEditorInstances.value[index] = quill
        }
    }


    const removeDescription = async (index) => {
        form.value.description.splice(index, 1)
        descriptionEditorRefs.value.splice(index, 1)
        descriptionEditorInstances.value.splice(index, 1)

        await nextTick()

        form.value.description.forEach((item, idx) => {
            const container = descriptionEditorRefs.value[idx]
            if (container && !descriptionEditorInstances.value[idx]) {
                const quill = new Quill(container, {
                    theme: 'snow',
                    placeholder: 'Nhập nội dung mô tả...',
                    modules: {
                        toolbar: [
                            ['bold', 'italic', 'underline', 'strike'],
                            [{list: 'ordered'}, {list: 'bullet'}],
                            [{header: [1, 2, false]}],
                            ['link', 'image'],
                            ['clean']
                        ]
                    }
                })

                quill.root.innerHTML = item.content || ''
                descriptionEditorInstances.value[idx] = quill
            }
        })
    }


    const setDescriptionEditorRef = (index, el) => {
        if (el) {
            descriptionEditorRefs.value[index] = el
        }
    }


    const addSocialLink = () => {
        form.value.social_links.push({type: '', url: ''})
    }

    const removeSocialLink = (index) => {
        form.value.social_links.splice(index, 1)
    }


    const handleSetMainImage = async (image) => {
        try {
            const eventId = route.params.id

            // Tạo bản sao images và cập nhật is_main
            const updatedImages = form.value.images.map(img => ({
                ...img,
                is_main: img.url === image.url
            }))

            // Gọi API cập nhật CHỈ trường images
            await updateEvent(eventId, {
                images: JSON.stringify(updatedImages)
            })

            // Cập nhật lại vào form để đồng bộ UI
            form.value.images = updatedImages

            message.success('Đã cập nhật ảnh chính thành công')
        } catch (err) {
            console.error(err)
            message.error('Không thể cập nhật ảnh chính')
        }
    }

    const validateImages = () => {
        if (!form.value.images || form.value.images.length === 0) {
            message.error('Bạn cần thêm ít nhất 1 ảnh cho sự kiện')
            return false
        }

        if (!form.value.banner || form.value.banner === '') {
            message.error('Bạn cần chọn ảnh bìa cho sự kiện')
            return false
        }

        return true
    }


    const validateDisplaySettings = () => {

        if (settings.value.company === 'selected' && (!selectedCompanies.value || selectedCompanies.value.length === 0)) {
            message.error('Vui lòng chọn ít nhất 1 doanh nghiệp!')
            return false
        }

        return true
    }


    const handleSubmit = async () => {
        try {
            loading.value = true

            if (!validateImages()) return

            if (!form.value.name?.trim()) {
                message.error('Vui lòng nhập tên sự kiện')
                return
            }

            if (!form.value.location?.trim()) {
                message.error('Vui lòng nhập địa điểm tổ chức')
                return
            }

            if (!form.value.start_time) {
                message.error('Vui lòng chọn thời gian bắt đầu')
                return
            }

            if (!form.value.end_time) {
                message.error('Vui lòng chọn thời gian kết thúc')
                return
            }

            if (!validateDisplaySettings()) return

            form.value.user_id = userStore.user?.id

            form.value.description = form.value.description.map((item, index) => ({
                ...item,
                content: descriptionEditorInstances.value[index]?.root.innerHTML || ''
            }))

            form.value.ticket_options = form.value.ticket_options.map((ticket, index) => ({
                ...ticket,
                description: ticketEditorInstances.value[index]?.root.innerHTML || ''
            }))

            // settings.value.selectedStores = selectedStores.value
            // settings.value.selectedProducts = selectedProductIds.value
            // settings.value.selectedSurveys = selectedSurveys.value
            // settings.value.topProducts = selectedTopProducts.value

            settings.value.selectedCompanies = selectedCompanies.value

            const payload = {
                ...form.value,
                display_settings: JSON.stringify(settings.value)
            }

            payload.social_links = JSON.stringify(
                (Array.isArray(form.value.social_links) ? form.value.social_links : []).filter(
                    item => item.type && item.url
                )
            )

            payload.images = JSON.stringify(
                (Array.isArray(form.value.images) ? form.value.images : []).map(img => ({
                    url: img.url,
                    is_main: img.is_main || false
                }))
            )

            payload.video = JSON.stringify(Array.isArray(form.value.video) ? form.value.video : [])
            payload.ticket_options = JSON.stringify(form.value.ticket_options)
            payload.banner = form.value.banner || ''

            let eventId

            if (isEditMode.value) {
                await updateEvent(route.params.id, payload)
                eventId = route.params.id
                message.success('Cập nhật sự kiện thành công')
            } else {
                const res = await createEvent(payload)
                eventId = res?.data?.id
                if (!eventId) throw new Error('Không lấy được ID sự kiện sau khi tạo')
                message.success('Tạo sự kiện thành công')
            }

            router.push('/events')

        } catch (error) {
            console.error('Lỗi khi lưu sự kiện:', error)
            message.error('Có lỗi xảy ra khi lưu sự kiện')
        } finally {
            loading.value = false
        }
    }



    const normalizeToArray = (val) => {
        if (Array.isArray(val)) return val
        if (typeof val === 'string' && val !== '') {
            return [{
                url: val,
                preview: val,
                uid: Date.now().toString(),
                isCover: true
            }]
        }
        return []
    }

    const normalizeBanner = (val) => {
        if (!val) return []
        return [{
            url: val,
            preview: val,
            uid: Date.now().toString()
        }]
    }


    const goBack = () => router.push('/events')

    onMounted(async () => {
        await fetchAllBusinesses() // 👈 PHẢI gọi trước
        if (isEditMode.value) {
            await fetchEvent()

            // 👇 Công ty liên quan
            if (settings.value.company === 'selected') {
                selectedCompanies.value = settings.value.selectedCompanies || []
                businessList.value = parseFieldsForList(
                    allBusinesses.value.filter(b => selectedCompanies.value.includes(b.id))
                )
            } else if (settings.value.company === 'all') {
                businessList.value = parseFieldsForList(allBusinesses.value)
            }



            // ✅ Khởi tạo nếu thiếu
            if (!Array.isArray(form.value.ticket_options) || form.value.ticket_options.length === 0) {
                form.value.ticket_options = [{ title: '', description: '', price: 0 }]
            }

            if (!Array.isArray(form.value.description) || form.value.description.length === 0) {
                form.value.description = [{ title: '', content: '' }]
            }

            if (!Array.isArray(form.value.social_links) || form.value.social_links.length === 0) {
                form.value.social_links = [{ type: '', url: '', icon: '' }]
            }

        } else {
            // ✅ Tạo mới mặc định
            form.value.ticket_options = [{ title: '', description: '', price: 0 }]
            form.value.description = [{ title: '', content: '' }]
            form.value.social_links = [{ type: '', url: '', icon: '' }]
        }

        await nextTick()

        // ✅ Mount Quill cho mô tả vé
        form.value.ticket_options.forEach((ticket, index) => {
            const container = ticketEditorRefs.value[index]
            if (container && !ticketEditorInstances.value[index]) {
                const quill = new Quill(container, {
                    theme: 'snow',
                    placeholder: 'Nhập mô tả vé...',
                    modules: {
                        toolbar: [
                            ['bold', 'italic', 'underline', 'strike'],
                            [{ list: 'ordered' }, { list: 'bullet' }],
                            [{ header: [1, 2, false] }],
                            ['link'],
                            ['clean']
                        ]
                    }
                })

                if (ticket.description) {
                    quill.root.innerHTML = ticket.description
                }

                ticketEditorInstances.value[index] = quill
            }
        })

        // ✅ Mount Quill cho mô tả sự kiện
        form.value.description.forEach((desc, index) => {
            const container = descriptionEditorRefs.value[index]
            if (container && !descriptionEditorInstances.value[index]) {
                const quill = new Quill(container, {
                    theme: 'snow',
                    placeholder: 'Nhập nội dung mô tả...',
                    modules: {
                        toolbar: [
                            ['bold', 'italic', 'underline', 'strike'],
                            [{ list: 'ordered' }, { list: 'bullet' }],
                            [{ header: [1, 2, false] }],
                            ['link'],
                            ['clean']
                        ]
                    }
                })

                if (desc.content) {
                    quill.root.innerHTML = desc.content
                }

                descriptionEditorInstances.value[index] = quill
            }
        })
    })

    watch(selectedCompanies, (val) => {
        if (settings.value.company === 'selected') {
            businessList.value = allBusinesses.value.filter(b => val.includes(b.id))
        }
    })



</script>

<style>
    .mb_24 {
        margin-bottom: 24px;
    }

    .bg_card_gray {
        background: #f3f4f5;
    }


    .custom-disabled-switch.ant-switch-disabled {
        background: #d9d9d9 !important; /* Màu xám */
        border-color: #d9d9d9 !important;
    }

    .link-list-wrapper {
        margin-top: 20px;
    }

    .iphone-mockup {
        width: 310px;
        height: 640px;
        margin: 0 auto;
        border: 10px solid #1c1c1e;
        border-radius: 48px;
        background: #000;
        position: relative;
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
        overflow: hidden;
    }

    /* Notch */
    .notch {
        position: absolute;
        top: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 150px;
        height: 30px;
        background: #000;
        border-bottom-left-radius: 16px;
        border-bottom-right-radius: 16px;
        z-index: 2;
    }

    /* Inner screen */
    .iphone-screen {
        width: 100%;
        height: 100%;
        background: #fff;
        border-radius: 36px;
        overflow-y: auto;
        padding-bottom: 12px;
        box-sizing: border-box;
        position: relative;
        z-index: 1;
    }

    /* Image and info inside screen */
    .screen-img {
        width: 100%;
        height: auto;
        border-radius: 0;
        object-fit: cover;
    }

    .info {
        padding: 12px;
        font-size: 14px;
        text-align: center;
    }

    .dynamic-island {
        position: absolute;
        top: 14px;
        left: 50%;
        transform: translateX(-50%);
        width: 110px;
        height: 30px;
        background: #000;
        border-radius: 20px;
        z-index: 2;
        transition: all 0.3s ease;
        box-shadow: 0 0 6px rgba(255, 255, 255, 0.05);
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        padding: 0 8px;
    }

    .dynamic-island.expanded {
        width: 180px;
        height: 40px;
        border-radius: 24px;
    }

    .marquee {
        width: 100%;
        overflow: hidden;
        white-space: nowrap;
        position: relative;
    }

    .marquee-content {
        display: inline-block;
        padding-left: 100%;
        animation: scrollText 10s linear infinite;
        color: #fff;
        font-size: 12px;
        opacity: 0.8;
    }

    .active-card {
        box-shadow: 0 0 8px #52c41a;
    }

    @keyframes scrollText {
        0% {
            transform: translateX(0);
        }
        100% {
            transform: translateX(-100%);
        }
    }

</style>
