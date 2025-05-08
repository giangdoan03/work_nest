<!-- BusinessForm.vue -->
<template>
    <div>
        <a-button @click="goBack" style="margin-bottom: 16px">Quay lại</a-button>
        <a-tabs default-active-key="info">
            <a-tab-pane key="info" tab="Thông tin doanh nghiệp">
                <a-form :model="form" layout="vertical" @finish="handleSubmit">
                    <a-card style="margin-bottom: 24px">
                        <!-- Ảnh đại diện / Logo (chỉ 1 ảnh) -->
                        <a-form-item label="Ảnh đại diện / Ảnh logo">
                            <a-upload
                                list-type="picture-card"
                                :file-list="logoFileList"
                                :on-preview="handlePreview"
                                :on-remove="(file) => handleRemoveFile('logo', file)"
                                :before-upload="(file) => handleBeforeUploadSingle('logo', file)"
                                :max-count="1"
                            >
                                <div v-if="logoFileList.length === 0">
                                    <upload-outlined/>
                                    <div style="margin-top: 8px">Ảnh</div>
                                </div>
                            </a-upload>
                        </a-form-item>

                        <!-- Ảnh bìa -->
                        <a-form-item label="Ảnh bìa">
                            <a-upload
                                list-type="picture-card"
                                :file-list="coverFileList"
                                :on-preview="handlePreview"
                                :on-remove="(file) => handleRemoveFile('cover_image', file)"
                                :before-upload="(file) => handleBeforeUploadMultiple('cover_image', file)"
                                multiple
                            >
                                <div>
                                    <upload-outlined/>
                                    <div style="margin-top: 8px">Ảnh</div>
                                </div>
                            </a-upload>
                        </a-form-item>

                        <!-- Thư viện ảnh -->
                        <a-form-item label="Thư viện ảnh">
                            <a-upload
                                list-type="picture-card"
                                :file-list="libraryFileList"
                                :on-preview="handlePreview"
                                :on-remove="(file) => handleRemoveFile('library_images', file)"
                                :before-upload="(file) => handleBeforeUploadMultiple('library_images', file)"
                                multiple
                            >
                                <div>
                                    <upload-outlined/>
                                    <div style="margin-top: 8px">Ảnh</div>
                                </div>
                            </a-upload>
                        </a-form-item>

                        <!-- Video giới thiệu -->
                        <a-form-item label="Video giới thiệu">
                            <a-upload
                                list-type="picture-card"
                                :file-list="videoFileList"
                                :on-preview="handlePreview"
                                :on-remove="(file) => handleRemoveFile('video_intro', file)"
                                :before-upload="(file) => handleBeforeUploadMultiple('video_intro', file)"
                                multiple
                            >
                                <div>
                                    <upload-outlined/>
                                    <div style="margin-top: 8px">Video</div>
                                </div>
                            </a-upload>
                        </a-form-item>

                        <!-- Chứng chỉ -->
                        <a-form-item label="Chứng chỉ, chứng nhận">
                            <a-upload
                                :file-list="certificateFileList"
                                :on-preview="handlePreview"
                                :on-remove="(file) => handleRemoveFile('certificate_file', file)"
                                :before-upload="(file) => handleBeforeUploadMultiple('certificate_file', file)"
                                multiple
                            >
                                <a-button>Tải lên</a-button>
                            </a-upload>
                        </a-form-item>
                    </a-card>

                    <a-card style="margin-bottom: 24px">
                        <!-- Các trường thông tin khác (giữ nguyên bạn đã làm tốt) -->
                        <a-form-item label="Tên Doanh nghiệp">
                            <a-input v-model:value="form.name" placeholder="Nhập tên doanh nghiệp"/>
                        </a-form-item>

                        <a-form-item label="Mã số thuế">
                            <a-input v-model:value="form.tax_code" placeholder="Mã số thuế"/>
                        </a-form-item>

                        <a-form-item label="Quốc gia">
                            <a-input v-model:value="form.country" placeholder="Quốc gia"/>
                        </a-form-item>

                        <a-form-item label="Tỉnh thành">
                            <a-input v-model:value="form.city" placeholder="Tỉnh thành"/>
                        </a-form-item>

                        <a-form-item label="Quận huyện">
                            <a-input v-model:value="form.district" placeholder="Quận huyện"/>
                        </a-form-item>

                        <a-form-item label="Phường xã">
                            <a-input v-model:value="form.ward" placeholder="Phường xã"/>
                        </a-form-item>

                        <a-form-item label="Địa chỉ chi tiết">
                            <a-input v-model:value="form.address" placeholder="Địa chỉ chi tiết"/>
                        </a-form-item>

                        <a-form-item label="Số điện thoại">
                            <a-input v-model:value="form.phone" placeholder="Số điện thoại"/>
                        </a-form-item>

                        <a-form-item label="Email">
                            <a-input v-model:value="form.email" placeholder="Email"/>
                        </a-form-item>

                        <a-form-item label="Website">
                            <a-input v-model:value="form.website" placeholder="Website"/>
                        </a-form-item>

                        <a-form-item label="Mô tả doanh nghiệp">
                            <a-textarea v-model:value="form.description" :rows="4" placeholder="Mô tả doanh nghiệp"/>
                        </a-form-item>

                        <a-form-item label="Nghề nghiệp">
                            <a-input v-model:value="form.career" placeholder="Nghề nghiệp"/>
                        </a-form-item>

                        <a-form-item label="Facebook">
                            <a-input v-model:value="form.facebook_link" placeholder="Link Facebook"/>
                        </a-form-item>

                        <a-form-item label="Thêm liên kết">
                            <a-textarea v-model:value="otherLinksText" :rows="3" placeholder="Mỗi dòng 1 liên kết"/>
                        </a-form-item>

                        <a-form-item label="Trạng thái">
                            <a-switch v-model:checked="form.status" checked-children="Bật" un-checked-children="Tắt"/>
                        </a-form-item>
                    </a-card>

                    <a-form-item>
                        <a-space>
                            <a-button type="primary" html-type="submit" :loading="loading">Lưu</a-button>
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
                                <a-form-item label="Chọn giao diện mẫu">
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

                            <!-- Sản phẩm liên quan -->
                            <a-card title="Sản phẩm" style="margin-bottom: 24px;">
                                <a-form-item>
                                    <a-radio-group v-model:value="settings.relatedProducts"
                                                   @change="handleRelatedProductModeChange">
                                        <a-radio :value="'all'">Tất cả sản phẩm</a-radio>
                                        <a-radio :value="'selected'">Chọn sản phẩm</a-radio>
                                    </a-radio-group>
                                </a-form-item>

                                <div v-if="settings.relatedProducts === 'selected'" style="margin-bottom: 24px">
                                    <a-select mode="multiple" style="width: 100%; margin-bottom: 12px"
                                              placeholder="Chọn sản phẩm" v-model:value="selectedProductIds"
                                              @change="handleProductSelect">
                                        <a-select-option v-for="product in allProducts" :key="product.id"
                                                         :value="product.id">
                                            {{ product.name }} - {{ product.price }}đ
                                        </a-select-option>
                                    </a-select>

                                    <a-table :columns="productColumns" :data-source="productList" row-key="id" bordered
                                             size="small">
                                        <template #bodyCell="{ column, record }">
                                            <template v-if="column.key === 'avatar'">
                                                <img v-if="record.avatar" :src="parseAvatar(record.avatar)" alt="Avatar"
                                                     style="height: 40px; width: 40px; object-fit: cover; border-radius: 4px"/>
                                            </template>
                                            <template v-if="column.key === 'action'">
                                                <a-button type="link" @click="removeProduct(record.id)" danger>Xoá
                                                </a-button>
                                            </template>
                                        </template>
                                    </a-table>
                                </div>
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

                                    <a-table :columns="businessColumns" :data-source="businessList" row-key="id" bordered size="small">
                                        <template #bodyCell="{ column, record }">
                                            <template v-if="column.key === 'logo'">
                                                <img v-if="record.logo?.[0]" :src="record.logo[0]" alt="Logo" style="height: 40px; width: 40px; object-fit: cover; border-radius: 4px"/>
                                            </template>
                                            <template v-if="column.key === 'action'">
                                                <a-button type="link" @click="removeBusiness(record.id)" danger>Xoá
                                                </a-button>
                                            </template>
                                        </template>
                                    </a-table>
                                </div>
                            </a-card>


                            <a-card title="Cửa hàng" style="margin-bottom: 24px;">
                                <!-- Cửa hàng -->
                                <a-form-item>
                                    <a-radio-group v-model:value="settings.store" @change="handleStoreModeChange">
                                        <a-radio :value="'all'">Tất cả cửa hàng</a-radio>
                                        <a-radio :value="'selected'">Chọn cửa hàng</a-radio>
                                    </a-radio-group>
                                </a-form-item>
                                <div v-if="settings.store === 'selected'" style="margin-bottom: 24px">
                                    <a-select mode="multiple" style="width: 100%; margin-bottom: 12px"
                                              placeholder="Chọn cửa hàng" v-model:value="selectedStores"
                                              @change="handleStoreSelect">
                                        <a-select-option v-for="s in allStores" :key="s.id" :value="s.id">
                                            {{ s.name }} - {{ s.address }}
                                        </a-select-option>
                                    </a-select>

                                    <a-table :columns="storeColumns" :data-source="storeList" row-key="id" bordered
                                             size="small">
                                        <template #bodyCell="{ column, record }">
                                            <template v-if="column.key === 'logo'">
                                                <img v-if="record.logo" :src="record.logo" alt="Logo"
                                                     style="height: 40px; width: 40px; object-fit: cover; border-radius: 4px"/>
                                            </template>
                                            <template v-if="column.key === 'action'">
                                                <a-button type="link" @click="removeStore(record.id)" danger>Xoá
                                                </a-button>
                                            </template>
                                        </template>
                                    </a-table>
                                </div>
                            </a-card>

                            <a-form-item>
                                <a-space>
                                    <a-button type="primary" @click="handleSubmit" :loading="loading">Lưu</a-button>
                                    <a-button @click="goBack">Huỷ</a-button>
                                </a-space>
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

        <a-modal v-model:open="previewVisible" :title="previewTitle" footer={null}>
            <img :src="previewImage" alt="Preview" style="width: 100%"/>
        </a-modal>
    </div>
</template>

<script setup>
import { ref, onMounted, computed, defineAsyncComponent, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {createBusiness, getBusinesses, getBusiness, updateBusiness} from '../api/business'
import {createProduct, getProduct, getProducts, updateProduct, uploadFile} from '../api/product'
import {getStores} from '../api/store'
import {message} from 'ant-design-vue'
import {UploadOutlined} from '@ant-design/icons-vue'

import templateOptions from '@/components/templates/businesses'
import Quill from 'quill'
import 'quill/dist/quill.snow.css'
import { parseFieldsForList } from '@/utils/formUtils'

const router = useRouter()
const route = useRoute()
const loading = ref(false)
const otherLinksText = ref('')
const isIslandExpanded = ref(false)
const businessList = ref([])
const storeList = ref([])

const allProducts = ref([])
const productList = ref([])
const allBusinesses = ref([])
const allStores = ref([])
const selectedProductIds = ref([]);
const selectedStores = ref([])


const form = ref({
    name: '', tax_code: '', country: '', city: '', district: '', ward: '', address: '',
    phone: '', email: '', website: '', description: '', career: '', facebook_link: '',
    other_links: '', logo: [], cover_image: [], library_images: [], video_intro: [],
    certificate_file: [], status: true,
});


const productColumns = [
    {title: 'Tên sản phẩm', dataIndex: 'name', key: 'name'},
    {title: 'Hình ảnh', key: 'avatar', dataIndex: 'avatar'},
    {title: 'Giá', dataIndex: 'price', key: 'price'},
    {title: 'Hành động', key: 'action'}
];


const businessColumns = [
    {title: 'ID', dataIndex: 'id', key: 'id'},
    {title: 'Logo', dataIndex: 'logo', key: 'logo'},
    {title: 'Tên công ty', dataIndex: 'name', key: 'name'},
    {title: 'Email', dataIndex: 'email', key: 'email'},
    {title: 'SĐT', dataIndex: 'phone', key: 'phone'},
    {title: 'Địa chỉ', dataIndex: 'address', key: 'address'},
    {title: 'Hành động', key: 'action'}
]


const storeColumns = [
    {title: 'ID', dataIndex: 'id', key: 'id'},
    {title: 'Logo', dataIndex: 'logo', key: 'logo'},
    {title: 'Tên cửa hàng', dataIndex: 'name', key: 'name'},
    {title: 'Địa chỉ', dataIndex: 'address', key: 'address'},
    {title: 'SĐT', dataIndex: 'phone', key: 'phone'},
    {title: 'Email', dataIndex: 'email', key: 'email'},
    {title: 'Hành động', key: 'action'}
]


// File lists
const logoFileList = ref([]);
const coverFileList = ref([]);
const libraryFileList = ref([]);
const videoFileList = ref([]);
const certificateFileList = ref([]);

// Modal preview
const previewImage = ref('');
const previewVisible = ref(false);
const previewTitle = ref('');

const selectedCompanies = ref([])
const selectedSurveys = ref([])

const isEditMode = computed(() => !!route.params.id);

const selectedTemplateData = computed(() =>
    templateOptions.find(t => t.id === settings.value.selectedTemplate)
)

const AsyncTemplate = computed(() => {
    return selectedTemplateData.value?.component ? defineAsyncComponent(selectedTemplateData.value.component) : null
})

const selectTemplate = (tpl) => {
    settings.value.selectedTemplate = tpl.id;
}

const isActiveTemplate = (tplId) => {
    return settings.value.selectedTemplate === tplId;
}


const parseAvatar = (avatar) => {
    try {
        const parsed = JSON.parse(avatar);
        return Array.isArray(parsed) && parsed.length > 0 ? parsed[0] : ''
    } catch {
        return ''
    }
}
const fetchBusiness = async () => {
    try {
        const response = await getBusiness(route.params.id)
        const data = response.data

        console.log('Dữ liệu doanh nghiệp:', data) // 👈 Debug rõ hơn

        Object.assign(form.value, data)

        // Parse other_links từ mảng về textarea
        otherLinksText.value = Array.isArray(data.other_links)
            ? data.other_links.join('\n')
            : (data.other_links || '')

        // 👇 Parse display_settings nếu có
        if (typeof data.display_settings === 'string') {
            try {
                const parsedSettings = JSON.parse(data.display_settings)
                settings.value = { ...settings.value, ...parsedSettings }
            } catch (e) {
                console.warn('display_settings không hợp lệ:', e)
            }
        } else if (typeof data.display_settings === 'object') {
            settings.value = { ...settings.value, ...data.display_settings }
        }

        // Load file list giống như Product
        const fields = ['logo', 'cover_image', 'library_images', 'video_intro', 'certificate_file']
        fields.forEach(field => {
            const fileUrls = form.value[field] || []
            fileUrls.forEach(url => updateFileList(field, url))
        })

    } catch (error) {
        console.error('Lỗi khi fetchBusiness:', error)
        message.error('Không tìm thấy doanh nghiệp')
    }
}


// Update file list
const updateFileList = (field, url) => {
    const file = {uid: Date.now() + Math.random(), name: url.split('/').pop(), status: 'done', url}
    switch (field) {
        case 'logo':
            logoFileList.value = [file];
            break
        case 'cover_image':
            coverFileList.value.push(file);
            break
        case 'library_images':
            libraryFileList.value.push(file);
            break
        case 'video_intro':
            videoFileList.value.push(file);
            break
        case 'certificate_file':
            certificateFileList.value.push(file);
            break
    }
}

// Upload handler for single file (logo)
const handleBeforeUploadSingle = async (field, file) => {
    const {data} = await uploadFile(file)
    form.value[field] = [data.url]
    updateFileList(field, data.url)
    return false
}

// Upload handler for multiple files
const handleBeforeUploadMultiple = async (field, file) => {
    const {data} = await uploadFile(file)
    if (!Array.isArray(form.value[field])) form.value[field] = []
    form.value[field].push(data.url)
    updateFileList(field, data.url)
    return false
}

// Remove file handler
const handleRemoveFile = (field, file) => {
    form.value[field] = form.value[field].filter(url => url !== file.url)
    const updateList = list => list.value = list.value.filter(item => item.url !== file.url)
    switch (field) {
        case 'logo':
            updateList(logoFileList);
            break
        case 'cover_image':
            updateList(coverFileList);
            break
        case 'library_images':
            updateList(libraryFileList);
            break
        case 'video_intro':
            updateList(videoFileList);
            break
        case 'certificate_file':
            updateList(certificateFileList);
            break
    }
}

// Preview modal
const handlePreview = (file) => {
    previewImage.value = file.url || file.thumbUrl
    previewVisible.value = true
    previewTitle.value = file.name || ''
}


const settings = ref({
    selectedTemplate: 'tpl-1',         // Template hiển thị

    relatedProducts: 'all',            // 'all' hoặc 'selected'
    selectedProducts: [],              // ID sản phẩm được chọn khi relatedProducts = 'selected'

    company: 'all',                    // 'all' hoặc 'selected'
    selectedCompanies: [],             // ID công ty được chọn khi company = 'selected'

    store: 'all',                      // 'all' hoặc 'selected'
    selectedStores: [],                // ID cửa hàng được chọn khi store = 'selected'

});

// Gọi API sản phẩm
const fetchAllProducts = async () => {
    try {
        const response = await getProducts({per_page: 1000});
        allProducts.value = response.data.data;
    } catch (err) {
        message.error('Lỗi tải danh sách sản phẩm');
    }
};

// Chọn sản phẩm từ select box
const handleProductSelect = (ids) => {
    productList.value = allProducts.value.filter(p => ids.includes(p.id));
    selectedProductIds.value = ids;
    settings.value.selectedProducts = ids;
};

// Xoá sản phẩm đã chọn
const removeProduct = (id) => {
    selectedProductIds.value = selectedProductIds.value.filter(pid => pid !== id);
    productList.value = productList.value.filter(p => p.id !== id);
    settings.value.selectedProducts = [...selectedProductIds.value];
};

// Khi đổi mode sản phẩm liên quan
const handleRelatedProductModeChange = async (input) => {
    const value = typeof input === 'string' ? input : input?.target?.value;
    if (!value) {
        console.warn('Giá trị không hợp lệ:', input);
        return;
    }

    if (value === 'selected') {
        if (allProducts.value.length === 0) await fetchAllProducts();
        selectedProductIds.value = [];
        productList.value = [];
    } else if (value === 'all') {
        await fetchAllProducts();
        productList.value = allProducts.value;
        selectedProductIds.value = allProducts.value.map(p => p.id);
    }
};


// Gọi API doanh nghiệp
const fetchAllBusinesses = async () => {
    const res = await getBusinesses({per_page: 1000});
    allBusinesses.value = res.data.data;
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


// Gọi API cửa hàng
const fetchAllStores = async () => {
    const res = await getStores({per_page: 1000});
    allStores.value = res.data.data;
};

// Chọn cửa hàng từ select box
const handleStoreSelect = (ids) => {
    storeList.value = allStores.value.filter(s => ids.includes(s.id));
    selectedStores.value = ids;
};

// Xoá cửa hàng đã chọn
const removeStore = (id) => {
    selectedStores.value = selectedStores.value.filter(sid => sid !== id);
    storeList.value = storeList.value.filter(s => s.id !== id);
};

// Khi đổi mode cửa hàng liên quan
const handleStoreModeChange = async (input) => {
    const value = typeof input === 'string' ? input : input?.target?.value;
    if (!value) {
        console.warn('Giá trị không hợp lệ:', input);
        return;
    }

    if (value === 'selected') {
        if (allStores.value.length === 0) await fetchAllStores();
        selectedStores.value = [];
        storeList.value = [];
    } else if (value === 'all') {
        await fetchAllStores();
        selectedStores.value = allStores.value.map(s => s.id);
        storeList.value = [...allStores.value];
    }
};

const validateBusinessForm = () => {
    const phoneRegex = /^[0-9]{9,15}$/
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    if (!form.value.name?.trim()) {
        message.error('Vui lòng nhập tên doanh nghiệp')
        return false
    }

    if (!form.value.tax_code?.trim()) {
        message.error('Vui lòng nhập mã số thuế')
        return false
    }

    if (!form.value.country?.trim()) {
        message.error('Vui lòng nhập quốc gia')
        return false
    }

    if (!form.value.city?.trim()) {
        message.error('Vui lòng nhập tỉnh thành')
        return false
    }

    if (!form.value.district?.trim()) {
        message.error('Vui lòng nhập quận huyện')
        return false
    }

    if (!form.value.ward?.trim()) {
        message.error('Vui lòng nhập phường xã')
        return false
    }

    if (!form.value.address?.trim()) {
        message.error('Vui lòng nhập địa chỉ chi tiết')
        return false
    }

    if (!form.value.phone || !phoneRegex.test(form.value.phone)) {
        message.error('Vui lòng nhập số điện thoại hợp lệ')
        return false
    }

    if (!form.value.email || !emailRegex.test(form.value.email)) {
        message.error('Vui lòng nhập email hợp lệ')
        return false
    }

    if (!logoFileList.value || logoFileList.value.length === 0) {
        message.error('Vui lòng upload ảnh đại diện / logo')
        return false
    }

    return true
}


const validateDisplaySettings = () => {
    const checks = [
        {
            condition: settings.value.relatedProducts === 'selected' && (!selectedProductIds.value?.length),
            message: 'Vui lòng chọn ít nhất 1 sản phẩm liên quan!'
        },
        {
            condition: settings.value.company === 'selected' && (!selectedCompanies.value?.length),
            message: 'Vui lòng chọn ít nhất 1 doanh nghiệp!'
        },
        {
            condition: settings.value.store === 'selected' && (!selectedStores.value?.length),
            message: 'Vui lòng chọn ít nhất 1 cửa hàng!'
        }
    ]

    for (const check of checks) {
        if (check.condition) {
            message.error(check.message)
            return false
        }
    }

    return true
}


// Submit form đã sửa
const handleSubmit = async () => {
    loading.value = true

    try {
        if (!validateBusinessForm() || !validateDisplaySettings()) {
            loading.value = false
            return
        }

        // ✅ Chuyển từ textarea (dạng chuỗi) thành mảng
        form.value.other_links = otherLinksText.value
            .split('\n')
            .map(s => s.trim())
            .filter(Boolean)

        // 👇 Đồng bộ selections vào settings
        settings.value.selectedCompanies = selectedCompanies.value
        settings.value.selectedStores = selectedStores.value
        settings.value.selectedProducts = selectedProductIds.value

        // 👇 Gán settings vào display_settings
        form.value.display_settings = JSON.stringify(settings.value)

        if (isEditMode.value) {
            await updateBusiness(route.params.id, form.value)
            message.success('Cập nhật thành công')
        } else {
            await createBusiness(form.value)
            message.success('Tạo mới thành công')
        }

        router.push('/businesses')
    } catch (error) {
        message.error('Lỗi lưu doanh nghiệp')
    } finally {
        loading.value = false
    }
}



const goBack = () => router.push('/businesses')

onMounted(async () => {
    await fetchAllProducts()
    await fetchAllBusinesses()
    await fetchAllStores()

    await nextTick() // Đảm bảo DOM đã render xong

    if (isEditMode.value) {
        await fetchBusiness()

        // 👇 Nếu có display_settings thì parse vào settings
        if (form.value.display_settings) {
            try {
                const parsedSettings = JSON.parse(form.value.display_settings)
                Object.assign(settings.value, parsedSettings)
            } catch (e) {
                console.warn('⚠️ Lỗi parse display_settings:', e)
            }
        }

        // 👇 Sản phẩm liên quan
        if (settings.value.relatedProducts === 'selected') {
            selectedProductIds.value = settings.value.selectedProducts || []
            productList.value = allProducts.value.filter(p => selectedProductIds.value.includes(p.id))
        } else if (settings.value.relatedProducts === 'all') {
            productList.value = allProducts.value
        }

        if (settings.value.company === 'selected') {
            selectedCompanies.value = settings.value.selectedCompanies || []
            businessList.value = parseFieldsForList(
                allBusinesses.value.filter(b => selectedCompanies.value.includes(b.id)),
                ['logo']
            )
        } else if (settings.value.company === 'all') {
            businessList.value = parseFieldsForList(allBusinesses.value, ['logo'])
        }


        // 👇 Cửa hàng liên quan
        if (settings.value.store === 'selected') {
            selectedStores.value = settings.value.selectedStores || []
            storeList.value = allStores.value.filter(s => selectedStores.value.includes(s.id))
        } else if (settings.value.store === 'all') {
            storeList.value = allStores.value
        }
    }
})

</script>

<style scoped>

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
