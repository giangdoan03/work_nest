<template>
    <div>
        <a-button @click="goBack" style="margin-bottom: 16px">Quay lại</a-button>

        <a-tabs default-active-key="info">
            <a-tab-pane key="info" tab="Thông tin cửa hàng">
                <a-form :model="form" layout="vertical" @finish="handleSubmit">
                    <a-card style="margin-bottom: 24px">
                        <a-form-item label="Tên cửa hàng" required>
                            <a-input v-model:value="form.name" placeholder="Nhập tên cửa hàng"/>
                        </a-form-item>

                        <a-form-item label="Email">
                            <a-input v-model:value="form.email" placeholder="example@mail.com"/>
                        </a-form-item>

                        <a-form-item label="Số điện thoại">
                            <a-input v-model:value="form.phone" placeholder="Nhập số điện thoại"/>
                        </a-form-item>

                        <a-form-item label="Địa chỉ">
                            <a-input v-model:value="form.address" placeholder="Nhập địa chỉ"/>
                        </a-form-item>

                        <a-form-item label="Mô tả ngắn gọn">
                            <div ref="editorRef"
                                 style="min-height: 200px; padding: 8px;"/>
                        </a-form-item>

                        <a-form-item label="Logo">
                            <a-upload
                                    list-type="picture-card"
                                    :file-list="logoFileList"
                                    :on-preview="handlePreview"
                                    :on-remove="handleRemoveFile"
                                    :before-upload="handleBeforeUpload"
                            >
                                <div>
                                    <upload-outlined/>
                                    <div style="margin-top: 8px">Upload</div>
                                </div>
                            </a-upload>
                        </a-form-item>

                        <a-form-item>
                            <a-switch v-model:checked="form.status" checked-children="Bật" un-checked-children="Tắt"/>
                        </a-form-item>
                    </a-card>

                    <a-form-item>
                        <a-button type="primary" html-type="submit">Lưu</a-button>
                        <a-button @click="goBack">Huỷ</a-button>
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

                            <a-card title="Sản phẩm hàng đầu (Top)" style="margin-bottom: 24px;">
                                <a-form-item>
                                    <a-radio-group v-model:value="settings.topProductsMode" @change="handleTopProductModeChange">
                                        <a-radio :value="'all'">Tất cả sản phẩm</a-radio>
                                        <a-radio :value="'selected'">Chọn sản phẩm</a-radio>
                                    </a-radio-group>
                                </a-form-item>

                                <div v-if="settings.topProductsMode === 'selected'" style="margin-bottom: 24px">
                                    <a-select mode="multiple" style="width: 100%; margin-bottom: 12px" placeholder="Chọn sản phẩm top"
                                              v-model:value="selectedTopProducts"
                                              @change="handleTopProductSelect">
                                        <a-select-option v-for="product in allProducts" :key="product.id" :value="product.id">
                                            {{ product.name }} - {{ product.price }}đ
                                        </a-select-option>
                                    </a-select>

                                    <a-table :columns="productColumns" :data-source="topProductList" row-key="id"
                                             bordered size="small">
                                        <template #bodyCell="{ column, record }">
                                            <template v-if="column.key === 'avatar'">
                                                <img v-if="record.avatar" :src="parseAvatar(record.avatar)" alt="Avatar"
                                                     style="height: 40px; width: 40px; object-fit: cover; border-radius: 4px"/>
                                            </template>
                                            <template v-if="column.key === 'action'">
                                                <a-button type="link" @click="removeTopProduct(record.id)" danger>Xoá
                                                </a-button>
                                            </template>
                                        </template>
                                    </a-table>
                                </div>
                            </a-card>


                            <!-- Sản phẩm liên quan -->
                            <a-card title="Sản phẩm mới" style="margin-bottom: 24px;">
                                <a-form-item>
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
                                        <a-table :columns="productColumns" :data-source="productList" row-key="id" bordered size="small">
                                            <template #bodyCell="{ column, record }">
                                                <template v-if="column.key === 'avatar'">
                                                    <img v-if="record.avatar" :src="parseAvatar(record.avatar)"
                                                         alt="Avatar"
                                                         style="height: 40px; width: 40px; object-fit: cover; border-radius: 4px"/>
                                                </template>
                                                <template v-if="column.key === 'action'">
                                                    <a-button type="link" @click="removeProduct(record.id)" danger>Xoá
                                                    </a-button>
                                                </template>
                                            </template>
                                        </a-table>
                                    </div>
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

        <a-modal v-model:open="previewVisible" :title="previewTitle" footer={null}>
            <img :src="previewImage" style="width: 100%" alt=""/>
        </a-modal>
    </div>
</template>

<script setup>
    import {ref, onMounted, nextTick, computed, defineAsyncComponent} from 'vue'
    import {useRoute, useRouter} from 'vue-router'
    import {getStore, createStore, updateStore, getStores} from '../api/store'
    import {getProduct, getProducts, uploadFile} from '../api/product'
    import {useUserStore} from '../stores/user'
    import {message} from 'ant-design-vue'
    import {DeleteOutlined, UploadOutlined} from '@ant-design/icons-vue'
    import Quill from 'quill'
    import 'quill/dist/quill.snow.css'
    import templateOptions from "@/components/templates/stores";
    import {getBusinesses} from "@/api/business.js";
    import {getCategories} from "@/api/category.js";
    import {normalizeProductData} from "@/utils/formUtils.js";
    import {createPerson, updatePerson} from "../api/person";
    import {parseFieldsForList} from '@/utils/formUtils'

    const userStore = useUserStore()
    const router = useRouter()
    const route = useRoute()
    const isEditMode = computed(() => !!route.params.id)

    const loading = ref(false)
    const isIslandExpanded = ref(false)
    const editorRef = ref(null)
    const quillInstance = ref(null)

    const form = ref({
        user_id: null,
        name: '',
        email: '',
        phone: '',
        address: '',
        description: '',
        logo: '',
        status: true,
        product_ids: []
    })

    const selectedProductIds = ref([])
    const selectedCompanies = ref([])
    const selectedStores = ref([])
    const selectedSurveys = ref([])
    const selectedTopProducts = ref([])

    const allProducts = ref([])
    const productList = ref([])

    const allBusinesses = ref([])
    const allStores = ref([])


    const businessList = ref([])

    const storeList = ref([])

    const storeColumns = [
        {title: 'ID', dataIndex: 'id', key: 'id'},
        {title: 'Logo', dataIndex: 'logo', key: 'logo'},
        {title: 'Tên cửa hàng', dataIndex: 'name', key: 'name'},
        {title: 'Địa chỉ', dataIndex: 'address', key: 'address'},
        {title: 'SĐT', dataIndex: 'phone', key: 'phone'},
        {title: 'Email', dataIndex: 'email', key: 'email'},
        {title: 'Hành động', key: 'action'}
    ]


    const businessColumns = [
        {title: 'ID', dataIndex: 'id', key: 'id'},
        {title: 'Logo', dataIndex: 'logo', key: 'logo'},
        {title: 'Tên công ty', dataIndex: 'name', key: 'name'},
        {title: 'Email', dataIndex: 'email', key: 'email'},
        {title: 'SĐT', dataIndex: 'phone', key: 'phone'},
        {title: 'Địa chỉ', dataIndex: 'address', key: 'address'},
        {title: 'Hành động', key: 'action'}
    ]


    // Gọi API sản phẩm
    const fetchAllProducts = async () => {
        try {
            const response = await getProducts({per_page: 1000});
            allProducts.value = response.data.data;
        } catch (err) {
            message.error('Lỗi tải danh sách sản phẩm');
        }
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

    const topProductList = ref([])

    const removeTopProduct = (id) => {
        selectedTopProducts.value = selectedTopProducts.value.filter(pid => pid !== id)
        topProductList.value = topProductList.value.filter(p => p.id !== id)
        settings.value.topProducts = [...selectedTopProducts.value]
    }

    const handleTopProductModeChange = async (input) => {
        const value = typeof input === 'string' ? input : input?.target?.value
        if (!value) return

        if (value === 'selected') {
            if (allProducts.value.length === 0) await fetchAllProducts()
            selectedTopProducts.value = []
            topProductList.value = []
        } else if (value === 'all') {
            await fetchAllProducts()
            topProductList.value = allProducts.value
            selectedTopProducts.value = allProducts.value.map(p => p.id)
        }
    }

    const handleTopProductSelect = (ids) => {
        selectedTopProducts.value = ids
        topProductList.value = allProducts.value.filter(p => ids.includes(p.id))
        settings.value.topProducts = [...ids]
    }


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

    const fetchCategories = async () => {
        try {
            const response = await getCategories()
            categories.value = response.data
        } catch (e) {
            message.error('Không tải được danh mục')
        }
    }


    const enableAddProduct = ref(false)

    const logoFileList = ref([])
    const previewImage = ref('')
    const previewVisible = ref(false)
    const previewTitle = ref('')

    const productColumns = [
        {title: 'ID', dataIndex: 'id', key: 'id'},
        {title: 'Ảnh', dataIndex: 'avatar', key: 'avatar'},
        {title: 'Tên sản phẩm', dataIndex: 'name', key: 'name'},
        {title: 'Giá', dataIndex: 'price', key: 'price'},
        {title: 'Hành động', key: 'action'}
    ]

    const parseAvatar = (avatar) => {
        try {
            const parsed = JSON.parse(avatar)
            return Array.isArray(parsed) && parsed.length > 0 ? parsed[0] : ''
        } catch {
            return ''
        }
    }

    const handleProductSelect = (ids) => {
        productList.value = allProducts.value.filter(p => ids.includes(p.id))
        form.value.product_ids = [...ids]
    }

    const removeProduct = (id) => {
        selectedProductIds.value = selectedProductIds.value.filter(pid => pid !== id)
        productList.value = productList.value.filter(p => p.id !== id)
        form.value.product_ids = [...selectedProductIds.value]
    }

    const fetchProducts = async () => {
        try {
            const response = await getProducts({per_page: 1000})
            allProducts.value = response.data.data
        } catch (err) {
            message.error('Lỗi tải danh sách sản phẩm')
        }
    }

    const fetchStore = async () => {
        try {
            const response = await getStore(route.params.id)
            Object.assign(form.value, response.data)

            if (form.value.display_settings) {
                try {
                    const parsed = JSON.parse(form.value.display_settings)
                    settings.value = { ...settings.value, ...parsed }
                } catch (e) {
                    console.warn('Không parse được display_settings:', e)
                }
            }

            if (form.value.product_ids) {
                enableAddProduct.value = true
                selectedProductIds.value = JSON.parse(form.value.product_ids)
            }

            if (form.value.logo) {
                logoFileList.value = [
                    {
                        uid: '1',
                        name: 'logo.jpg',
                        status: 'done',
                        url: form.value.logo
                    }
                ]
            }
        } catch (error) {
            message.error('Không tìm thấy thông tin cửa hàng')
        }
    }
    const validateStoreForm = () => {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        const phoneRegex = /^[0-9]{9,15}$/

        if (!form.value.name?.trim()) {
            message.error('Tên cửa hàng là bắt buộc')
            return false
        }

        if (!logoFileList.value?.length) {
            message.error('Vui lòng upload logo cửa hàng')
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

        if (!form.value.address?.trim()) {
            message.error('Vui lòng nhập địa chỉ')
            return false
        }

        return true
    }

    const validateDisplaySettings = () => {

        if (
            settings.value.relatedProducts === 'selected' &&
            (!selectedProductIds.value || selectedProductIds.value.length === 0)
        ) {
            message.error('Vui lòng chọn ít nhất 1 sản phẩm liên quan!')
            return false
        }

        if (
            settings.value.topProductsMode === 'selected' &&
            (!selectedTopProducts.value || selectedTopProducts.value.length === 0)
        ) {
            message.error('Vui lòng chọn ít nhất 1 sản phẩm hàng đầu!')
            return false
        }

        if (
            settings.value.company === 'selected' &&
            (!selectedCompanies.value || selectedCompanies.value.length === 0)
        ) {
            message.error('Vui lòng chọn ít nhất 1 doanh nghiệp!')
            return false
        }

        if (
            settings.value.store === 'selected' &&
            (!selectedStores.value || selectedStores.value.length === 0)
        ) {
            message.error('Vui lòng chọn ít nhất 1 cửa hàng!')
            return false
        }

        return true
    }


    const handleSubmit = async () => {
        loading.value = true

        if (!validateStoreForm() || !validateDisplaySettings()) {
            loading.value = false
            return
        }

        try {
            // ✅ Gán user_id nếu chưa có
            form.value.user_id = userStore.user?.id

            // ✅ Gán product_ids riêng (ngoài display_settings)
            form.value.product_ids = [...selectedProductIds.value]

            if (quillInstance.value) {
                form.value.description = quillInstance.value.root.innerHTML
            }


            // ✅ Đồng bộ selections vào settings
            settings.value.selectedCompanies = selectedCompanies.value
            settings.value.selectedStores = selectedStores.value
            settings.value.selectedProducts = selectedProductIds.value
            settings.value.selectedSurveys = selectedSurveys.value
            settings.value.topProducts = selectedTopProducts.value // nếu có

            // ✅ Gán vào display_settings
            form.value.display_settings = JSON.stringify(settings.value)

            if (isEditMode.value && route.params.id) {
                await updateStore(route.params.id, form.value)
                message.success('Cập nhật thành công')
            } else {
                await createStore(form.value)
                message.success('Tạo mới thành công')
            }

            router.push('/stores')
        } catch (error) {
            message.error('Có lỗi xảy ra')
        } finally {
            loading.value = false
        }
    }


    const handleBeforeUpload = async (file) => {
        const hide = message.loading('Đang tải lên...', 0)
        try {
            const res = await uploadFile(file)
            form.value.logo = res.data.url
            logoFileList.value = [
                {
                    uid: Date.now(),
                    name: file.name,
                    status: 'done',
                    url: res.data.url
                }
            ]
            message.success('Tải lên thành công')
        } catch (err) {
            message.error('Tải lên thất bại')
        } finally {
            hide()
        }
        return false
    }

    const handleRemoveFile = () => {
        form.value.logo = ''
        logoFileList.value = []
    }

    const handlePreview = (file) => {
        previewImage.value = file.url
        previewVisible.value = true
        previewTitle.value = file.name || ''
    }


    const goBack = () => router.push('/stores')

    onMounted(async () => {
        if (isEditMode.value) {
            await fetchStore() // lấy store có display_settings
            await Promise.all([
                fetchAllProducts(),
                fetchAllBusinesses(),
                fetchAllStores()
            ])

            // 👇 Sản phẩm liên quan
            if (settings.value.relatedProducts === 'selected') {
                selectedProductIds.value = settings.value.selectedProducts || []
                productList.value = allProducts.value.filter(product => selectedProductIds.value.includes(product.id.toString()))
            } else if (settings.value.relatedProducts === 'all') {
                selectedProductIds.value = allProducts.value.map(p => p.id.toString())
                productList.value = [...allProducts.value]
            }

            // 👇 Sản phẩm Top
            if (settings.value.topProductsMode === 'selected') {
                selectedTopProducts.value = settings.value.topProducts || []
                topProductList.value = allProducts.value.filter(product => selectedTopProducts.value.includes(product.id.toString()))
            } else if (settings.value.topProductsMode === 'all') {
                selectedTopProducts.value = allProducts.value.map(p => p.id.toString())
                topProductList.value = [...allProducts.value]
            }

            // 👇 Công ty liên quan
            if (settings.value.company === 'selected') {
                selectedCompanies.value = settings.value.selectedCompanies || []
                businessList.value = parseFieldsForList(
                    allBusinesses.value.filter(b => selectedCompanies.value.includes(b.id.toString())),
                    ['logo']
                )
            } else {
                selectedCompanies.value = allBusinesses.value.map(b => b.id.toString())
                businessList.value = [...allBusinesses.value]
            }

            // 👇 Cửa hàng liên quan
            if (settings.value.store === 'selected') {
                selectedStores.value = settings.value.selectedStores || []
                storeList.value = allStores.value.filter(s => selectedStores.value.includes(s.id.toString()))
            } else {
                selectedStores.value = allStores.value.map(s => s.id.toString())
                storeList.value = [...allStores.value]
            }
        }

        if (editorRef.value) {
            quillInstance.value = new Quill(editorRef.value, {
                theme: 'snow',
                placeholder: 'Nhập mô tả sản phẩm...',
                modules: {
                    toolbar: [
                        ['bold', 'italic', 'underline', 'strike'],
                        [{list: 'ordered'}, {list: 'bullet'}],
                        [{header: [1, 2, false]}],
                        ['link'],
                        ['clean']
                    ]
                }
            })

            // 👇 Gán mô tả sau khi Quill khởi tạo xong
            if (isEditMode.value && form.value.description) {
                quillInstance.value.root.innerHTML = form.value.description
            }
        } else {
            console.warn('⚠️ Không tìm thấy DOM editorRef để gắn Quill.')
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