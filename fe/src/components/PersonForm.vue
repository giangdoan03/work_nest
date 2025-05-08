<template>
    <div>
        <!-- Nút quay lại -->
        <a-button type="default" @click="goBack" style="margin-bottom: 16px">
            Quay lại danh sách
        </a-button>
        <a-tabs default-active-key="info">
            <a-tab-pane key="info" tab="Thông tin cá nhân">
                <a-form :model="form" layout="vertical" @finish="handleSubmit">
                    <a-card style="margin-bottom: 24px">
                        <!-- Ảnh đại diện -->
                        <a-form-item label="Ảnh đại diện">
                            <a-upload
                                list-type="picture-card"
                                :file-list="avatarFileList"
                                :on-preview="handlePreview"
                                :on-remove="(file) => handleRemoveFile('avatar', file)"
                                :before-upload="(file) => handleBeforeUpload('avatar', file)"
                            >
                                <div>
                                    <upload-outlined/>
                                    <div style="margin-top: 8px">Upload</div>
                                </div>
                            </a-upload>
                        </a-form-item>

                        <!-- Họ tên -->
                        <a-form-item label="Họ và tên" required>
                            <a-input v-model:value="form.name" placeholder="Nhập họ tên"/>
                        </a-form-item>

                        <!-- Email -->
                        <a-form-item label="Email" required>
                            <a-input v-model:value="form.email" placeholder="example@mail.com"/>
                        </a-form-item>

                        <!-- Số điện thoại -->
                        <a-form-item label="Số điện thoại" required>
                            <a-input v-model:value="form.phone" placeholder="Nhập số điện thoại"/>
                        </a-form-item>

                        <!-- Chức danh -->
                        <a-form-item label="Chức danh">
                            <a-input v-model:value="form.job_title" placeholder="VD: Giám đốc Marketing"/>
                        </a-form-item>

                        <!-- Tiểu sử -->
                        <a-form-item label="Tiểu sử">
                            <a-textarea v-model:value="form.bio" :rows="4"
                                        placeholder="Giới thiệu ngắn gọn về cá nhân..."/>
                        </a-form-item>
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

                                    <a-table :columns="businessColumns" :data-source="businessList" row-key="id"
                                             bordered
                                             size="small">
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

        <!-- Modal xem ảnh -->
        <a-modal v-model:open="previewVisible" :title="previewTitle" footer={null}>
            <img :src="previewImage" alt="Preview" style="width: 100%"/>
        </a-modal>
    </div>
</template>

<script setup>
import {ref, onMounted, computed, defineAsyncComponent, nextTick} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {createPerson, updatePerson, getPerson} from '../api/person'
import {createBusiness, getBusinesses, getBusiness, updateBusiness} from '../api/business'
import {createProduct, getProduct, getProducts, updateProduct, uploadFile} from '../api/product'
import {getStores} from '../api/store'
import {message} from 'ant-design-vue'
import {UploadOutlined} from '@ant-design/icons-vue'

import templateOptions from '@/components/templates/persons'
import {parseFieldsForList} from '@/utils/formUtils'

import {useUserStore} from '../stores/user'

const userStore = useUserStore()

const route = useRoute()
const router = useRouter()

const form = ref({
    user_id: null, // 👈 Thêm dòng này
    name: '',
    email: '',
    phone: '',
    job_title: '',
    bio: '',
    avatar: ''
})


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


const avatarFileList = ref([])
const previewImage = ref('')
const previewVisible = ref(false)
const previewTitle = ref('')


const loading = ref(false)
const isIslandExpanded = ref(false)
const businessList = ref([])
const storeList = ref([])


const allProducts = ref([])
const productList = ref([])
const allBusinesses = ref([])
const allStores = ref([])
const selectedProductIds = ref([]);
const selectedStores = ref([])
const otherLinksText = ref('')


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
    businessList.value = allBusinesses.value.filter(b => ids.includes(b.id));
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


const parseAvatar = (avatar) => {
    try {
        const parsed = JSON.parse(avatar);
        return Array.isArray(parsed) && parsed.length > 0 ? parsed[0] : ''
    } catch {
        return ''
    }
}

const fetchPerson = async () => {
    try {
        const response = await getPerson(route.params.id)
        Object.assign(form.value, response.data)

        if (form.value.avatar) {
            avatarFileList.value = [
                {
                    uid: '1',
                    name: 'avatar.jpg',
                    status: 'done',
                    url: form.value.avatar
                }
            ]
        }
    } catch (error) {
        message.error('Không tìm thấy thông tin cá nhân')
    }
}


const validatePersonForm = () => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    const phoneRegex = /^[0-9]{9,15}$/

    if (!form.value.name?.trim()) {
        message.error('Tên cá nhân là bắt buộc')
        return false
    }

    if (!form.value.email || !emailRegex.test(form.value.email)) {
        message.error('Vui lòng nhập email hợp lệ')
        return false
    }

    if (!form.value.phone || !phoneRegex.test(form.value.phone)) {
        message.error('Vui lòng nhập số điện thoại hợp lệ')
        return false
    }

    if (!form.value.job_title?.trim()) {
        message.error('Vui lòng nhập chức danh')
        return false
    }

    if (!avatarFileList.value || avatarFileList.value.length === 0) {
        message.error('Vui lòng upload ảnh đại diện')
        return false
    }

    if (
        settings.value.company === 'selected' &&
        (!selectedCompanies.value?.length)
    ) {
        message.error('Chọn ít nhất 1 công ty')
        return false
    }

    if (
        settings.value.store === 'selected' &&
        (!selectedStores.value?.length)
    ) {
        message.error('Chọn ít nhất 1 cửa hàng')
        return false
    }

    return true
}


const validateDisplaySettings = () => {
    const rules = [
        {
            condition: settings.value.relatedProducts === 'selected' && (!selectedProductIds.value?.length),
            message: 'Vui lòng chọn ít nhất 1 sản phẩm liên quan!'
        },
        {
            condition: settings.value.topProductsMode === 'selected' && (!selectedTopProducts.value?.length),
            message: 'Vui lòng chọn ít nhất 1 sản phẩm hàng đầu!'
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

    for (const rule of rules) {
        if (rule.condition) {
            message.error(rule.message)
            return false
        }
    }

    return true
}



const handleSubmit = async () => {
    try {
        loading.value = true

        if (!validatePersonForm() || !validateDisplaySettings()) {
            loading.value = false
            return
        }

        // ✅ Chuyển từ textarea (nếu có) thành mảng
        if (otherLinksText.value !== undefined) {
            form.value.other_links = otherLinksText.value
                .split('\n')
                .map(s => s.trim())
                .filter(Boolean)
        }

        // 👇 Đồng bộ selections vào settings
        settings.value.selectedCompanies = selectedCompanies.value
        settings.value.selectedStores = selectedStores.value
        settings.value.selectedProducts = selectedProductIds.value

        // 👇 Gán settings vào display_settings
        form.value.display_settings = JSON.stringify(settings.value)

        // 👇 Gán user_id nếu cần
        form.value.user_id = userStore.user?.id

        // 👇 Gọi API
        if (isEditMode.value){
            await updatePerson(route.params.id, form.value)
            message.success('Cập nhật cá nhân thành công')
        } else {
            await createPerson(form.value)
            message.success('Tạo mới cá nhân thành công')
        }

        router.push('/persons')
    } catch (error) {
        console.error('Lỗi:', error)
        message.error('Có lỗi xảy ra')
    } finally {
        loading.value = false
    }
}


const handlePreview = (file) => {
    previewImage.value = file.url || file.thumbUrl
    previewVisible.value = true
    previewTitle.value = file.name || ''
}

const handleBeforeUpload = async (field, file) => {
    const hide = message.loading('Đang tải lên...', 0)
    try {
        const response = await uploadFile(file)
        const url = response.data.url
        form.value.avatar = url
        avatarFileList.value = [
            {
                uid: Date.now(),
                name: file.name,
                status: 'done',
                url
            }
        ]
        message.success('Upload thành công')
    } catch (error) {
        message.error('Upload thất bại')
    } finally {
        hide()
    }
    return false
}

const handleRemoveFile = () => {
    form.value.avatar = ''
    avatarFileList.value = []
}

const goBack = () => router.push('/persons')

onMounted(async () => {
    await fetchAllProducts()
    await fetchAllBusinesses()
    await fetchAllStores()

    await nextTick() // Đảm bảo DOM đã render xong

    if (isEditMode.value) {
        await fetchPerson();
        // await fetchBusiness()

        // 👇 Nếu có display_settings thì parse vào settings
        if (form.value.display_settings) {
            try {
                const ds = form.value.display_settings

                if (typeof ds === 'string') {
                    const parsedSettings = JSON.parse(ds)
                    Object.assign(settings.value, parsedSettings)
                } else if (typeof ds === 'object') {
                    Object.assign(settings.value, ds)
                }
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
                ['logo']  // 👈 Có thể thêm 'cover_image', 'library_images' nếu cần
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
        padding-top: 40px; /* để chừa notch */
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